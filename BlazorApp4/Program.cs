using BlazorApp4.Components;
using BlazorApp4.Data;
using BlazorApp4.Services;
using Microsoft.EntityFrameworkCore;
using MySqlConnector;

var builder = WebApplication.CreateBuilder(args);

var connectionString = BuildConnectionString(builder.Configuration);
var serverVersion = ResolveServerVersion(connectionString);
LogConnectionTarget(connectionString, serverVersion);

builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();
builder.Services.AddDbContextFactory<AppDbContext>(options =>
    options.UseMySql(connectionString, serverVersion, mysql =>
        mysql.EnableRetryOnFailure(3)));
builder.Services.AddScoped<IInventoryRepository, InventoryRepository>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<CustomAuthProvider>();
builder.Services.AddSingleton<SearchState>();
builder.Services.AddCascadingAuthenticationState();

var app = builder.Build();

await InitializeDatabaseAsync(app);

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseAntiforgery();
app.MapStaticAssets();
app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

// Diagnostika uchun: bazaga ulanish ishlayaptimi-yo'qmi ko'rsatadi.
app.MapGet("/db-check", async (IDbContextFactory<AppDbContext> factory) =>
{
    try
    {
        await using var db = await factory.CreateDbContextAsync();
        var canConnect = await db.Database.CanConnectAsync();
        var products = canConnect ? await db.InventoryItems.CountAsync() : 0;
        var users = canConnect ? await db.Users.CountAsync() : 0;

        return Results.Json(new { ok = canConnect, products, users });
    }
    catch (Exception ex)
    {
        return Results.Json(new { ok = false, error = ex.Message }, statusCode: 500);
    }
});

app.Run();

static string BuildConnectionString(IConfiguration configuration)
{
    // 1) Explicit connection strings / URLs always win.
    var explicitConnection = FirstNonEmpty(
        Environment.GetEnvironmentVariable("MYSQL_CONNECTION"),
        Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection"),
        Environment.GetEnvironmentVariable("MYSQL_URL"),
        Environment.GetEnvironmentVariable("DATABASE_URL"));

    if (!string.IsNullOrWhiteSpace(explicitConnection))
    {
        return NormalizeMySqlUrl(explicitConnection);
    }

    // 2) Many hosts expose separate variables instead of one URL.
    //    Railway: MYSQLHOST/MYSQLPORT/...   Clever Cloud: MYSQL_ADDON_*   Others: MYSQL_*/DB_*
    var host = FirstNonEmpty(
        Environment.GetEnvironmentVariable("MYSQLHOST"),
        Environment.GetEnvironmentVariable("MYSQL_HOST"),
        Environment.GetEnvironmentVariable("MYSQL_ADDON_HOST"),
        Environment.GetEnvironmentVariable("DB_HOST"),
        Environment.GetEnvironmentVariable("MARIADB_HOST"));

    if (!string.IsNullOrWhiteSpace(host))
    {
        var portValue = FirstNonEmpty(
            Environment.GetEnvironmentVariable("MYSQLPORT"),
            Environment.GetEnvironmentVariable("MYSQL_PORT"),
            Environment.GetEnvironmentVariable("MYSQL_ADDON_PORT"),
            Environment.GetEnvironmentVariable("DB_PORT"),
            Environment.GetEnvironmentVariable("MARIADB_PORT"));

        var port = uint.TryParse(portValue, out var parsedPort) && parsedPort > 0 ? parsedPort : 3306;

        return new MySqlConnectionStringBuilder
        {
            Server = host,
            Port = port,
            Database = FirstNonEmpty(
                Environment.GetEnvironmentVariable("MYSQLDATABASE"),
                Environment.GetEnvironmentVariable("MYSQL_DATABASE"),
                Environment.GetEnvironmentVariable("MYSQL_ADDON_DB"),
                Environment.GetEnvironmentVariable("MYSQL_DB"),
                Environment.GetEnvironmentVariable("DB_DATABASE"),
                Environment.GetEnvironmentVariable("MARIADB_DATABASE")) ?? string.Empty,
            UserID = FirstNonEmpty(
                Environment.GetEnvironmentVariable("MYSQLUSER"),
                Environment.GetEnvironmentVariable("MYSQL_USER"),
                Environment.GetEnvironmentVariable("MYSQL_ADDON_USER"),
                Environment.GetEnvironmentVariable("DB_USER"),
                Environment.GetEnvironmentVariable("DB_USERNAME"),
                Environment.GetEnvironmentVariable("MARIADB_USER")) ?? string.Empty,
            Password = FirstNonEmpty(
                Environment.GetEnvironmentVariable("MYSQLPASSWORD"),
                Environment.GetEnvironmentVariable("MYSQL_PASSWORD"),
                Environment.GetEnvironmentVariable("MYSQL_ADDON_PASSWORD"),
                Environment.GetEnvironmentVariable("DB_PASSWORD"),
                Environment.GetEnvironmentVariable("MARIADB_PASSWORD")) ?? string.Empty,
            CharacterSet = "utf8mb4",
            SslMode = MySqlSslMode.Preferred
        }.ConnectionString;
    }

    // 3) appsettings.json fallback, then local development default.
    return configuration.GetConnectionString("DefaultConnection")
        ?? "Server=localhost;Port=3306;Database=store_manager_db;User=root;Password=;";
}

static string? FirstNonEmpty(params string?[] values)
{
    foreach (var value in values)
    {
        if (!string.IsNullOrWhiteSpace(value))
        {
            return value.Trim();
        }
    }

    return null;
}

static void LogConnectionTarget(string connectionString, ServerVersion serverVersion)
{
    try
    {
        var target = new MySqlConnectionStringBuilder(connectionString);
        Console.WriteLine(
            $"MySQL target: {target.Server}:{target.Port}/{target.Database} " +
            $"(user: {target.UserID}, server: {serverVersion})");
    }
    catch
    {
        Console.WriteLine("MySQL target: could not parse the connection string.");
    }
}

static string NormalizeMySqlUrl(string value)
{
    if (string.IsNullOrWhiteSpace(value))
    {
        throw new InvalidOperationException("MySQL connection string is empty.");
    }

    // Hosting providers (Railway, Aiven, PlanetScale, ...) expose URIs like
    // mysql://user:password@host:port/database instead of ADO.NET key/value strings.
    if (!Uri.TryCreate(value, UriKind.Absolute, out var uri) ||
        (uri.Scheme != "mysql" && uri.Scheme != "mysql2" && uri.Scheme != "mariadb"))
    {
        return value;
    }

    var userInfo = uri.UserInfo.Split(':', 2);
    var builder = new MySqlConnectionStringBuilder
    {
        Server = uri.Host,
        Port = (uint)(uri.IsDefaultPort ? 3306 : uri.Port),
        Database = Uri.UnescapeDataString(uri.AbsolutePath.Trim('/')),
        UserID = Uri.UnescapeDataString(userInfo[0]),
        Password = userInfo.Length > 1 ? Uri.UnescapeDataString(userInfo[1]) : string.Empty,
        CharacterSet = "utf8mb4",
        SslMode = MySqlSslMode.Preferred
    };

    return builder.ConnectionString;
}

static ServerVersion ResolveServerVersion(string connectionString)
{
    // Optional override, e.g. MYSQL_SERVER_VERSION=10.4.11 (MariaDB) or 8.0.36 (MySQL).
    var configured = Environment.GetEnvironmentVariable("MYSQL_SERVER_VERSION");
    if (!string.IsNullOrWhiteSpace(configured) && Version.TryParse(configured, out var version))
    {
        return new MySqlServerVersion(version);
    }

    try
    {
        return ServerVersion.AutoDetect(connectionString);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Could not detect MySQL server version ({ex.Message}); assuming MySQL 8.0.36.");
        return new MySqlServerVersion(new Version(8, 0, 36));
    }
}

static async Task InitializeDatabaseAsync(WebApplication app)
{
    const int maxAttempts = 5;

    for (var attempt = 1; attempt <= maxAttempts; attempt++)
    {
        try
        {
            using var scope = app.Services.CreateScope();
            var factory = scope.ServiceProvider.GetRequiredService<IDbContextFactory<AppDbContext>>();
            await using var dbContext = await factory.CreateDbContextAsync();

            await dbContext.Database.MigrateAsync();
            Console.WriteLine("Database ready (MySQL).");
            return;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Database init attempt {attempt}/{maxAttempts} failed: {ex.Message}");

            if (attempt == maxAttempts)
            {
                Console.WriteLine("Application will start without a ready database. Check the MySQL connection string.");
                return;
            }

            await Task.Delay(TimeSpan.FromSeconds(3));
        }
    }
}
