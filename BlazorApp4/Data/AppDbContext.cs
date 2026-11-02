using BlazorApp4.Models;
using Microsoft.EntityFrameworkCore;

namespace BlazorApp4.Data;

public sealed class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<InventoryItem> InventoryItems => Set<InventoryItem>();
    public DbSet<User> Users => Set<User>();
    public DbSet<Sale> Sales => Set<Sale>();
    public DbSet<SaleItem> SaleItems => Set<SaleItem>();
    public DbSet<ProductLog> ProductLogs => Set<ProductLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        var inventory = modelBuilder.Entity<InventoryItem>();

        inventory.ToTable("inventory_items");
        inventory.HasKey(x => x.Id);
        inventory.HasCharSet("utf8mb4").UseCollation("utf8mb4_unicode_ci");
        inventory.Property(x => x.Name).HasMaxLength(150).IsRequired();
        inventory.Property(x => x.Price).HasPrecision(18, 2);
        inventory.Property(x => x.TotalAmount).HasPrecision(18, 2);
        inventory.Property(x => x.MinLevel).HasDefaultValue(5);
        inventory.Property(x => x.ImageUrl).HasMaxLength(500);
        inventory.HasIndex(x => x.Name);

        var user = modelBuilder.Entity<User>();

        user.ToTable("users");
        user.HasKey(x => x.Id);
        user.HasCharSet("utf8mb4").UseCollation("utf8mb4_unicode_ci");
        user.Property(x => x.Username).HasMaxLength(100).IsRequired();
        user.Property(x => x.PasswordHash).HasMaxLength(255).IsRequired();
        user.Property(x => x.CreatedAt).HasDefaultValueSql("CURRENT_TIMESTAMP");
        user.HasIndex(x => x.Username).IsUnique();

        var sale = modelBuilder.Entity<Sale>();
        sale.ToTable("sales");
        sale.HasKey(x => x.Id);
        sale.HasCharSet("utf8mb4").UseCollation("utf8mb4_unicode_ci");
        sale.Property(x => x.SaleDate);
        sale.Property(x => x.TotalPrice).HasPrecision(18, 2);
        sale.HasIndex(x => x.SaleDate);

        var saleItem = modelBuilder.Entity<SaleItem>();
        saleItem.ToTable("sale_items");
        saleItem.HasKey(x => x.Id);
        saleItem.HasCharSet("utf8mb4").UseCollation("utf8mb4_unicode_ci");
        saleItem.Property(x => x.ProductName).HasMaxLength(150).IsRequired();
        saleItem.Property(x => x.UnitPrice).HasPrecision(18, 2);
        saleItem.Ignore(x => x.LineTotal);
        saleItem.HasIndex(x => x.SaleId);

        sale.HasMany(s => s.Items).WithOne().HasForeignKey(si => si.SaleId).OnDelete(DeleteBehavior.Cascade);

        var productLog = modelBuilder.Entity<ProductLog>();
        productLog.ToTable("product_logs");
        productLog.HasKey(x => x.Id);
        productLog.HasCharSet("utf8mb4").UseCollation("utf8mb4_unicode_ci");
        productLog.Property(x => x.ProductName).HasMaxLength(150).IsRequired();
        productLog.Property(x => x.Action).HasMaxLength(20).IsRequired();
        productLog.HasIndex(x => x.Date);
        productLog.HasIndex(x => x.ProductId);
    }
}
