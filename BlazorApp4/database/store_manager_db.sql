-- Store Manager database (MySQL / MariaDB)
-- Generated from the SQLite database (store.db).
--
-- How to use:
--   phpMyAdmin -> Import -> choose this file, or:
--   mysql -u USER -p < store_manager_db.sql
--
-- If your hosting gives you a fixed database name, remove the CREATE DATABASE / USE
-- lines below and import into your existing database instead.

CREATE DATABASE IF NOT EXISTS store_manager_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE store_manager_db;

-- ---------------------------------------------------------------------------
-- Schema (must match the EF Core migration InitialMySql)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `__EFMigrationsHistory` (
    `MigrationId` varchar(150) NOT NULL,
    `ProductVersion` varchar(32) NOT NULL,
    PRIMARY KEY (`MigrationId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `inventory_items` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `Name` varchar(150) NOT NULL,
    `ImageUrl` varchar(500) NOT NULL,
    `Quantity` int NOT NULL,
    `Price` decimal(18,2) NOT NULL,
    `TotalAmount` decimal(18,2) NOT NULL,
    `Date` datetime(6) NOT NULL,
    `MinLevel` int NOT NULL DEFAULT 5,
    PRIMARY KEY (`Id`),
    KEY `IX_inventory_items_Name` (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `users` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `Username` varchar(100) NOT NULL,
    `PasswordHash` varchar(255) NOT NULL,
    `CreatedAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`Id`),
    UNIQUE KEY `IX_users_Username` (`Username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sales` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `SaleDate` datetime(6) NOT NULL,
    `TotalPrice` decimal(18,2) NOT NULL,
    PRIMARY KEY (`Id`),
    KEY `IX_sales_SaleDate` (`SaleDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sale_items` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `SaleId` int NOT NULL,
    `ProductId` int NOT NULL,
    `ProductName` varchar(150) NOT NULL,
    `Quantity` int NOT NULL,
    `UnitPrice` decimal(18,2) NOT NULL,
    PRIMARY KEY (`Id`),
    KEY `IX_sale_items_SaleId` (`SaleId`),
    CONSTRAINT `FK_sale_items_sales_SaleId`
        FOREIGN KEY (`SaleId`) REFERENCES `sales` (`Id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `product_logs` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `ProductName` varchar(150) NOT NULL,
    `ProductId` int NOT NULL,
    `Action` varchar(20) NOT NULL,
    `PreviousQty` int NOT NULL,
    `ChangeQty` int NOT NULL,
    `NewQty` int NOT NULL,
    `Date` datetime(6) NOT NULL,
    PRIMARY KEY (`Id`),
    KEY `IX_product_logs_Date` (`Date`),
    KEY `IX_product_logs_ProductId` (`ProductId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------------
-- Data from SQLite
-- ---------------------------------------------------------------------------
INSERT IGNORE INTO `__EFMigrationsHistory` (`MigrationId`, `ProductVersion`) VALUES ('20261029103516_InitialMySql', '9.0.4');

-- users
INSERT IGNORE INTO `users` (`Id`, `Username`, `PasswordHash`, `CreatedAt`) VALUES (1, 'rafa', 'cY97DDfvsltBDQmzO2Y5Yg==:QZj1Uzsh+O7FnathFtCTUg8iCmaKq1/Z8zULy7HjJSk=', '2026-05-22 10:18:51.181981');
INSERT IGNORE INTO `users` (`Id`, `Username`, `PasswordHash`, `CreatedAt`) VALUES (2, 'raufjon', 'fbqvb3FG2rQ2CMAN0jJc2Q==:iQ6FcQm1THwzgQwZLT03tu/44Lzo3TDqgXsu9XtHsPc=', '2026-05-29 17:40:16.339160');
INSERT IGNORE INTO `users` (`Id`, `Username`, `PasswordHash`, `CreatedAt`) VALUES (3, 'rauf', 'jtfYRstvt6ed5K61PuIrlg==:tGcJgSPfKR1p5CqLZ41selwqSQfuF5z3njdeBatmHHE=', '2026-09-07 17:43:10.121772');

-- inventory_items
INSERT IGNORE INTO `inventory_items` (`Id`, `Name`, `ImageUrl`, `Quantity`, `Price`, `TotalAmount`, `Date`, `MinLevel`) VALUES (1, 'colla', '', 1000, 8.0, 8000.0, '2026-05-29 18:36:57.997165', 5);
INSERT IGNORE INTO `inventory_items` (`Id`, `Name`, `ImageUrl`, `Quantity`, `Price`, `TotalAmount`, `Date`, `MinLevel`) VALUES (2, 'apple', '', 99, 5.0, 495.0, '2026-05-29 18:37:10.275375', 5);
INSERT IGNORE INTO `inventory_items` (`Id`, `Name`, `ImageUrl`, `Quantity`, `Price`, `TotalAmount`, `Date`, `MinLevel`) VALUES (3, 'pizza', '', 97, 60.0, 5820.0, '2026-05-29 18:37:20.179023', 5);
INSERT IGNORE INTO `inventory_items` (`Id`, `Name`, `ImageUrl`, `Quantity`, `Price`, `TotalAmount`, `Date`, `MinLevel`) VALUES (4, 'fanta', '', 992, 10.0, 9920.0, '2026-05-29 18:37:30.890017', 5);
INSERT IGNORE INTO `inventory_items` (`Id`, `Name`, `ImageUrl`, `Quantity`, `Price`, `TotalAmount`, `Date`, `MinLevel`) VALUES (5, 'pepsi', '', 999, 10.0, 9990.0, '2026-05-29 18:37:43.427280', 5);
INSERT IGNORE INTO `inventory_items` (`Id`, `Name`, `ImageUrl`, `Quantity`, `Price`, `TotalAmount`, `Date`, `MinLevel`) VALUES (6, 'alpen gold', '', 9999, 10.0, 99990.0, '2026-05-29 18:37:56.008102', 5);
INSERT IGNORE INTO `inventory_items` (`Id`, `Name`, `ImageUrl`, `Quantity`, `Price`, `TotalAmount`, `Date`, `MinLevel`) VALUES (7, 'non', '', 9999, 10.0, 99990.0, '2026-05-29 18:38:04.679674', 5);
INSERT IGNORE INTO `inventory_items` (`Id`, `Name`, `ImageUrl`, `Quantity`, `Price`, `TotalAmount`, `Date`, `MinLevel`) VALUES (8, 'hleb', '', 99, 3.0, 297.0, '2026-05-29 18:38:14.039177', 5);
INSERT IGNORE INTO `inventory_items` (`Id`, `Name`, `ImageUrl`, `Quantity`, `Price`, `TotalAmount`, `Date`, `MinLevel`) VALUES (9, 'Rc', '', 100, 11.0, 1100.0, '2026-05-29 18:38:42.494963', 5);

-- sales
INSERT IGNORE INTO `sales` (`Id`, `SaleDate`, `TotalPrice`) VALUES (1, '2026-05-29 18:39:13.138475', 20.0);
INSERT IGNORE INTO `sales` (`Id`, `SaleDate`, `TotalPrice`) VALUES (2, '2026-09-07 17:43:52.252973', 108.0);
INSERT IGNORE INTO `sales` (`Id`, `SaleDate`, `TotalPrice`) VALUES (3, '2026-09-07 17:44:00.504125', 170.0);

-- sale_items
INSERT IGNORE INTO `sale_items` (`Id`, `SaleId`, `ProductId`, `ProductName`, `Quantity`, `UnitPrice`) VALUES (1, 1, 4, 'fanta', 2, 10.0);
INSERT IGNORE INTO `sale_items` (`Id`, `SaleId`, `ProductId`, `ProductName`, `Quantity`, `UnitPrice`) VALUES (2, 2, 8, 'hleb', 1, 3.0);
INSERT IGNORE INTO `sale_items` (`Id`, `SaleId`, `ProductId`, `ProductName`, `Quantity`, `UnitPrice`) VALUES (3, 2, 7, 'non', 1, 10.0);
INSERT IGNORE INTO `sale_items` (`Id`, `SaleId`, `ProductId`, `ProductName`, `Quantity`, `UnitPrice`) VALUES (4, 2, 6, 'alpen gold', 1, 10.0);
INSERT IGNORE INTO `sale_items` (`Id`, `SaleId`, `ProductId`, `ProductName`, `Quantity`, `UnitPrice`) VALUES (5, 2, 2, 'apple', 1, 5.0);
INSERT IGNORE INTO `sale_items` (`Id`, `SaleId`, `ProductId`, `ProductName`, `Quantity`, `UnitPrice`) VALUES (6, 2, 3, 'pizza', 1, 60.0);
INSERT IGNORE INTO `sale_items` (`Id`, `SaleId`, `ProductId`, `ProductName`, `Quantity`, `UnitPrice`) VALUES (7, 2, 4, 'fanta', 1, 10.0);
INSERT IGNORE INTO `sale_items` (`Id`, `SaleId`, `ProductId`, `ProductName`, `Quantity`, `UnitPrice`) VALUES (8, 2, 5, 'pepsi', 1, 10.0);
INSERT IGNORE INTO `sale_items` (`Id`, `SaleId`, `ProductId`, `ProductName`, `Quantity`, `UnitPrice`) VALUES (9, 3, 3, 'pizza', 2, 60.0);
INSERT IGNORE INTO `sale_items` (`Id`, `SaleId`, `ProductId`, `ProductName`, `Quantity`, `UnitPrice`) VALUES (10, 3, 4, 'fanta', 5, 10.0);

-- product_logs
INSERT IGNORE INTO `product_logs` (`Id`, `ProductName`, `ProductId`, `Action`, `PreviousQty`, `ChangeQty`, `NewQty`, `Date`) VALUES (1, 'fanta', 4, 'Sold', 1000, 2, 998, '2026-05-29 18:39:13.288495');
INSERT IGNORE INTO `product_logs` (`Id`, `ProductName`, `ProductId`, `Action`, `PreviousQty`, `ChangeQty`, `NewQty`, `Date`) VALUES (2, 'hleb', 8, 'Sold', 100, 1, 99, '2026-09-07 17:43:52.431046');
INSERT IGNORE INTO `product_logs` (`Id`, `ProductName`, `ProductId`, `Action`, `PreviousQty`, `ChangeQty`, `NewQty`, `Date`) VALUES (3, 'non', 7, 'Sold', 10000, 1, 9999, '2026-09-07 17:43:52.434423');
INSERT IGNORE INTO `product_logs` (`Id`, `ProductName`, `ProductId`, `Action`, `PreviousQty`, `ChangeQty`, `NewQty`, `Date`) VALUES (4, 'alpen gold', 6, 'Sold', 10000, 1, 9999, '2026-09-07 17:43:52.434536');
INSERT IGNORE INTO `product_logs` (`Id`, `ProductName`, `ProductId`, `Action`, `PreviousQty`, `ChangeQty`, `NewQty`, `Date`) VALUES (5, 'apple', 2, 'Sold', 100, 1, 99, '2026-09-07 17:43:52.434618');
INSERT IGNORE INTO `product_logs` (`Id`, `ProductName`, `ProductId`, `Action`, `PreviousQty`, `ChangeQty`, `NewQty`, `Date`) VALUES (6, 'pizza', 3, 'Sold', 100, 1, 99, '2026-09-07 17:43:52.434684');
INSERT IGNORE INTO `product_logs` (`Id`, `ProductName`, `ProductId`, `Action`, `PreviousQty`, `ChangeQty`, `NewQty`, `Date`) VALUES (7, 'fanta', 4, 'Sold', 998, 1, 997, '2026-09-07 17:43:52.434753');
INSERT IGNORE INTO `product_logs` (`Id`, `ProductName`, `ProductId`, `Action`, `PreviousQty`, `ChangeQty`, `NewQty`, `Date`) VALUES (8, 'pepsi', 5, 'Sold', 1000, 1, 999, '2026-09-07 17:43:52.434813');
INSERT IGNORE INTO `product_logs` (`Id`, `ProductName`, `ProductId`, `Action`, `PreviousQty`, `ChangeQty`, `NewQty`, `Date`) VALUES (9, 'pizza', 3, 'Sold', 99, 2, 97, '2026-09-07 17:44:00.509891');
INSERT IGNORE INTO `product_logs` (`Id`, `ProductName`, `ProductId`, `Action`, `PreviousQty`, `ChangeQty`, `NewQty`, `Date`) VALUES (10, 'fanta', 4, 'Sold', 997, 5, 992, '2026-09-07 17:44:00.509957');
