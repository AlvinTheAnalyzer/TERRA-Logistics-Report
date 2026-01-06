-- *** SCHEMA AND TABLE CREATION ***

/
-- Step 1: Drop tables in dependency order
-- TROUBLE SHOOTING DATABASE

IF OBJECT_ID('dbo.Shipping', 'U') IS NOT NULL DROP TABLE dbo.Shipping;
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Customers', 'U') IS NOT NULL DROP TABLE dbo.Customers;
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.TransportInfo', 'U') IS NOT NULL DROP TABLE dbo.TransportInfo;
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID('dbo.Product_Parts', 'U') IS NOT NULL DROP TABLE dbo.Product_Parts;
IF OBJECT_ID('dbo.Trucking_Companies', 'U') IS NOT NULL DROP TABLE dbo.Trucking_Companies;


-- Step 2: Re-create all tables with IDENTITY columns where appropriate
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    City VARCHAR(30)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(50),
    ProductDescription VARCHAR(255),
    CII VARCHAR(3)
);

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE TransportInfo (
    TransportID INT PRIMARY KEY IDENTITY(1,1),
    CompanyName VARCHAR(50),
    VehicleType VARCHAR(50),
    StartLocation VARCHAR(100)
);

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Position VARCHAR(50)
);

CREATE TABLE Shipping (
    ShippingID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    EmployeeID INT,
    TransportID INT,
    ShippingDate DATE,
    OrderSent BIT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (TransportID) REFERENCES TransportInfo(TransportID)
);

-- Step 3: Re-create permanent source tables for realistic data
-- Step 3: Create permanent source tables for realistic data

IF OBJECT_ID('dbo.FirstNames', 'U') IS NOT NULL DROP TABLE dbo.FirstNames;
CREATE TABLE dbo.FirstNames (Name VARCHAR(50));
INSERT INTO dbo.FirstNames (Name) VALUES
('Liam'), ('Olivia'), ('Noah'), ('Emma'), ('Oliver'), ('Charlotte'), ('Elijah'), ('Amelia'), ('James'), ('Ava'), ('Benjamin'), ('Sophia'), ('Lucas'), ('Isabella'), ('Mason'), ('Mia'), ('Ethan'), ('Alexander'), ('Harper'), ('Evelyn');

IF OBJECT_ID('dbo.LastNames', 'U') IS NOT NULL DROP TABLE dbo.LastNames;
CREATE TABLE dbo.LastNames (Name VARCHAR(50));
INSERT INTO dbo.LastNames (Name) VALUES
('Smith'), ('Johnson'), ('Williams'), ('Jones'), ('Brown'), ('Davis'), ('Miller'), ('Wilson'), ('Moore'), ('Taylor'), ('Anderson'), ('Thomas'), ('Jackson'), ('White'), ('Harris'), ('Martin'), ('Thompson'), ('Garcia'), ('Martinez'), ('Robinson');

IF OBJECT_ID('dbo.Cities', 'U') IS NOT NULL DROP TABLE dbo.Cities;
CREATE TABLE dbo.Cities (Name VARCHAR(50));
INSERT INTO dbo.Cities (Name) VALUES
('New York'), ('Los Angeles'), ('Chicago'), ('Houston'), ('Phoenix'), ('Philadelphia'), ('San Antonio'), ('San Diego'), ('Dallas'), ('San Jose'), ('Austin'), ('Jacksonville'), ('Fort Worth'), ('Columbus'), ('Indianapolis'), ('Charlotte'), ('San Francisco'), ('Seattle'), ('Denver'), ('Washington');

IF OBJECT_ID('dbo.Product_Parts', 'U') IS NOT NULL DROP TABLE dbo.Product_Parts;
CREATE TABLE dbo.Product_Parts (Name VARCHAR(50));
INSERT INTO dbo.Product_Parts (Name) VALUES
('Water Heater'), ('Stove'), ('Refrigerator'), ('Dishwasher'), ('Ice Maker'), ('Fryer'), ('Oven'), ('Mixer'), ('Grill'), ('Ventilation Hood');

IF OBJECT_ID('dbo.Trucking_Companies', 'U') IS NOT NULL DROP TABLE dbo.Trucking_Companies;
CREATE TABLE dbo.Trucking_Companies (Name VARCHAR(50));
INSERT INTO dbo.Trucking_Companies (Name) VALUES
('J.B. Hunt'), ('Schneider'), ('Landstar'), ('Swift Transportation'), ('Werner Enterprises'), ('Ryder System'), ('Penske Corporation'), ('CRST'), ('Old Dominion Freight Line'), ('Knight-Swift Transportation'), ('FedEx Freight'), ('Estes Express Lines'), ('ArcBest'), ('Covenant Transport'), ('Heartland Express'), ('Stevens Transport'), ('Crete Carrier Corporation'), ('XPO Logistics'), ('USA Truck'), ('Prime Inc.');

-- *** DATA POPULATION ***

-- Populate Customers with realistic, random data (200 rows)

WITH RandomizedCustomerData AS (
    SELECT TOP 200
        fn.Name AS FirstName,
        ln.Name AS LastName,
        c.Name AS City
    FROM dbo.FirstNames fn
    CROSS JOIN dbo.LastNames ln
    CROSS JOIN dbo.Cities c
    ORDER BY NEWID()
)
INSERT INTO Customers (FirstName, LastName, City)
SELECT FirstName, LastName, City FROM RandomizedCustomerData;

-- Populate Products with 200 rows of realistic appliances

WITH RandomizedProductData AS (
    SELECT TOP 200
        pp.Name + ' (' + SUBSTRING(REPLACE(CONVERT(VARCHAR(40), NEWID()), '-', ''), 1, 8) + ')' AS ProductName,
        'Commercial grade ' + pp.Name + ' with SKU: ' + SUBSTRING(REPLACE(CONVERT(VARCHAR(40), NEWID()), '-', ''), 1, 8) + ' and color: ' + CASE ABS(CHECKSUM(NEWID())) % 3 WHEN 0 THEN 'Black' WHEN 1 THEN 'Stainless Steel' ELSE 'White' END AS ProductDescription,
        CASE WHEN ROW_NUMBER() OVER (ORDER BY NEWID()) % 2 = 0 THEN 'CII' ELSE 'NCI' END AS CII
    FROM dbo.Product_Parts pp
    CROSS JOIN sys.objects a
    ORDER BY NEWID()
)
INSERT INTO Products (ProductName, ProductDescription, CII)
SELECT ProductName, ProductDescription, CII FROM RandomizedProductData;

-- Populate TransportInfo (20 rows) with specific company and vehicle types

WITH RandomizedTransportData AS (
    SELECT TOP 20
        tc.Name AS CompanyName,
        CASE ABS(CHECKSUM(NEWID())) % 3
            WHEN 0 THEN 'Truck'
            WHEN 1 THEN 'SUV'
            ELSE 'Air'
        END AS VehicleType,
        c.Name AS StartLocation
    FROM dbo.Trucking_Companies tc
    CROSS JOIN dbo.Cities c
    ORDER BY NEWID()
)
INSERT INTO TransportInfo (CompanyName, VehicleType, StartLocation)
SELECT CompanyName, VehicleType, StartLocation FROM RandomizedTransportData;

-- Populate Employees (50 rows)

WITH RandomizedEmployeeData AS (
    SELECT TOP 50
        fn.Name AS FirstName,
        ln.Name AS LastName,
        CASE ABS(CHECKSUM(NEWID())) % 4
            WHEN 0 THEN 'Manager'
            WHEN 1 THEN 'Front-end'
            WHEN 2 THEN 'Associate'
            ELSE 'Clerk'
        END AS Position
    FROM dbo.FirstNames fn
    CROSS JOIN dbo.LastNames ln
    ORDER BY NEWID()
)
INSERT INTO Employees (FirstName, LastName, Position)
SELECT FirstName, LastName, Position FROM RandomizedEmployeeData;

-- Populate Orders (200 rows)

WITH RandomizedCustomerID AS (
    SELECT TOP 200 CustomerID FROM Customers ORDER BY NEWID()
)
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
SELECT
    rc.CustomerID,
    DATEADD(day, ABS(CHECKSUM(NEWID())) % 365, GETDATE() - 365),
    CAST(ABS(CHECKSUM(NEWID())) % 1000 + 1 AS DECIMAL(10, 2))
FROM RandomizedCustomerID rc
ORDER BY NEWID();

-- Populate OrderDetails (variable rows per order)

DECLARE @OrderDetailLoop INT = 1;
WHILE @OrderDetailLoop <= 600
BEGIN
    INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
    VALUES (
        (SELECT TOP 1 OrderID FROM Orders ORDER BY NEWID()),
        (SELECT TOP 1 ProductID FROM Products ORDER BY NEWID()),
        (ABS(CHECKSUM(NEWID())) % 10) + 1
    );
    SET @OrderDetailLoop = @OrderDetailLoop + 1;
END;

-- Populate Shipping (200 rows)

WITH RandomOrderIDs AS (
    SELECT TOP 200 OrderID FROM Orders ORDER BY NEWID()
),
RandomEmployeeIDs AS (
    SELECT TOP 200 EmployeeID FROM Employees ORDER BY NEWID()
),
RandomTransportIDs AS (
    SELECT TOP 200 TransportID FROM TransportInfo ORDER BY NEWID()
)
INSERT INTO Shipping (OrderID, EmployeeID, TransportID, ShippingDate, OrderSent)
SELECT
    o.OrderID,
    e.EmployeeID,
    t.TransportID,
    DATEADD(day, (ABS(CHECKSUM(NEWID())) % 10), GETDATE()),
    1 AS OrderSent
FROM RandomOrderIDs o
CROSS JOIN RandomEmployeeIDs e
CROSS JOIN RandomTransportIDs t
ORDER BY NEWID()
OFFSET 0 ROWS
FETCH NEXT 200 ROWS ONLY;


-- Update Customer Emails from example.com to gmail.com 

UPDATE Customers
SET Email = LOWER(REPLACE(FirstName, ' ', '') + '.' + REPLACE(LastName, ' ', '') + CAST(CustomerID AS VARCHAR(10)) + '@example.com')
WHERE Email IS NULL;
UPDATE Customers
SET Email = REPLACE(Email, '@example.com', '@gmail.com');

*/

