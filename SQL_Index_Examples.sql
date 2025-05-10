USE AdventureWorks2019;
GO
-- uc sutunlu bir tablo olusturalim
CREATE TABLE dbo.TestTable (
    TestCol1 INT NOT NULL,
    TestCol2 NCHAR(10) NULL,
    TestCol3 NVARCHAR(50) NULL
);
GO

-- IX_TestTable_TestCol1 adinda bir clustered table olusturalim
-- TestCol1 sutun kullanarak dbo.TestTable de olusturalim
CREATE CLUSTERED INDEX IX_TestTable_TestCol1 ON dbo.TestTable (TestCol1);
GO

INSERT INTO dbo.TestTable (TestCol1, TestCol2, TestCol3)
VALUES
('89', 'EmR', 'ARS'),
('72', 'YUS', 'FSA'),
('64', 'POJ', 'PMS'),
('61', 'SOM', 'SMB'),
('35', 'SKM', 'ASF');
-- SELECT HERSEY FROM TABLE WITH INDEX DEDIK BASITCE
SELECT * FROM dbo.TestTable WITH(INDEX(IX_TestTable_TestCol1))
--1 ornek bitti
--2 ornek
CREATE TABLE Kullanicilar (
    KullaniciID INT PRIMARY KEY IDENTITY(1,1),
    Ad VARCHAR(50) NOT NULL,
    Soyad VARCHAR(50) NOT NULL,
    EpostaAdresi VARCHAR(100) NOT NULL,
    KayitTarihi DATETIME DEFAULT GETDATE()
);

CREATE UNIQUE INDEX IX_Kullanicilar_EpostaAdresi
ON Kullanicilar (EpostaAdresi);

INSERT INTO Kullanicilar (Ad, Soyad, EpostaAdresi)
VALUES 
('Ahmet', 'Y�lmaz', 'ahmet.yilmaz@example.com'),
('Emir', 'Aras', 'emr.ars@example.com'),
('Yusuf', 'Soya', 'YuYu.Soya@example.com'),
('Hamza', 'Y�ld�z', 'hamza.yildiz@example.com'),
('Ali', 'El�m', 'alis.elm@example.com'),
('Suyoh', 'Puok', 'Suy.Pu@example.com'),
('Shok', 'Somet', 'shokshok.sometter@example.com'),
('Ay�e', 'Kara', 'ayse.kara@example.com');

SELECT * FROM Kullanicilar WITH(INDEX(IX_Kullanicilar_EpostaAdresi))

UPDATE Kullanicilar
SET Ad = 'Ahos', Soyad = 'Ohum', EpostaAdresi = 'ahos.ohum@example.com'
WHERE KullaniciID = 7;

SELECT * FROM Kullanicilar WITH(INDEX(IX_Kullanicilar_EpostaAdresi))
-- 3 ornek bitti 4.ornek yapalim
-- 4. Full Text �rne�i CONTAINS and FREETEXT
CREATE FULLTEXT CATALOG ProductCatalog AS DEFAULT;
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100),
    Description NVARCHAR(350),
    Price DECIMAL(10, 2)
);
INSERT INTO Products (ProductName, Description, Price) VALUES
('Laptop', 'Powerful laptop with high performance CPU and large SSD.', 1200.00),
('Smartphone', 'Latest model smartphone with amazing camera and battery life.', 800.00),
('Tablet', 'Portable tablet, great for reading and Browse.', 300.00),
('Desktop Computer', 'High-end desktop for gaming and heavy tasks.', 1500.00),
('Smartwatch', 'Wearable technology to track your fitness and notifications.', 250.00),
('Lorem Ipsum Machine', 'This machine only writes lorem ipsum text.', 100.00);

SELECT DATABASEPROPERTYEX('AdventureWorks2019', 'IsFulltextEnabled');


CREATE FULLTEXT INDEX ON Products(
    ProductName LANGUAGE 'English',
    Description LANGUAGE 'English'
)
KEY INDEX PK__Products__B40CC6ED8B28C690 -- Tablonun benzersiz anahtar�
ON ProductCatalog; -- Kullan�lacak tam metin katalogu

ALTER FULLTEXT INDEX ON Products START FULL POPULATION; -- Manuel olarak indexleme icin
-- CONTAINS FUNCTION
SELECT ProductID, ProductName, Description
FROM Products
WHERE CONTAINS((ProductName, Description), 'laptop');
-- ProductName, Description s�tununda 'high' kelimesini i�eren �r�nler
SELECT ProductID, ProductName, Description
FROM Products
WHERE CONTAINS((ProductName, Description), 'high');
-- ProductName, Description s�tununda 'amazing camera' kelimesi i�eren �r�nler
SELECT ProductID, ProductName, Description
FROM Products
WHERE CONTAINS((ProductName, Description), '"amazing camera"');
-- ProductName veya Description s�tununda 'smart' kelimesi ile ba�layan kelimeler
SELECT ProductID, ProductName, Description
FROM Products
WHERE CONTAINS((ProductName, Description), '"smart*"');

-- FREETEXT FUNCTION
SELECT ProductID, ProductName, Description
FROM Products
WHERE FREETEXT((ProductName, Description), 'powerful computer');
-- ProductName veya Description s�tununda 'fast phone' ile ilgili �r�nler
SELECT ProductID, ProductName, Description
FROM Products
WHERE FREETEXT((ProductName, Description), 'Lorem');
-- 5.Ornek Index Silme
SELECT * FROM dbo.TestTable WITH(INDEX(IX_TestTable_TestCol1))
DROP INDEX IX_TestTable_TestCol1 ON dbo.TestTable
-- Tekrar Calistir
SELECT * FROM dbo.TestTable WITH(INDEX(IX_TestTable_TestCol1))
-- 5.ornek bitti
-- 6.ornek Filtered Index
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME,
    Status VARCHAR(50),
    TotalAmount DECIMAL(10, 2)
);
INSERT INTO Orders (OrderID, CustomerID, OrderDate, Status, TotalAmount)
VALUES
(1, 101, GETDATE(), 'Tamamland�', 150.00),
(2, 102, GETDATE(), 'Beklemede', 75.50),
(3, 101, GETDATE(), '��leniyor', 200.00),
(4, 103, GETDATE(), 'Tamamland�', 50.00),
(5, 102, GETDATE(), 'Tamamland�', 120.00),
(6, 104, GETDATE(), 'Beklemede', 90.00),
(7, 103, GETDATE(), '��leniyor', 300.00),
(8, 101, GETDATE(), 'Tamamland�', 45.00),
(9, 104, GETDATE(), 'Tamamland�', 180.00),
(10, 102, GETDATE(), 'Beklemede', 60.25);

CREATE NONCLUSTERED INDEX IX_Orders_PendingProcessing
ON Orders (Status, OrderDate) -- Sorgular�m�zda kullanaca��m�z s�tunlar bunlar
WHERE Status IN ('Beklemede', '��leniyor');

SELECT OrderID, CustomerID, OrderDate, Status, TotalAmount
FROM Orders
WHERE Status IN ('Beklemede', '��leniyor')
ORDER BY OrderDate DESC;
-- 6.Ornek bitti
-- 7.Ornek Non CLustered Index
CREATE TABLE Product (
    ProductID INT PRIMARY KEY, -- Primary Key �zerinde Clustered Dizin olu�tural�m
    ProductName NVARCHAR(100) NOT NULL,
    CategoryID INT,
    Price DECIMAL(10, 2),
    StockQuantity INT,
    CreatedDate DATETIME DEFAULT GETDATE()
);

INSERT INTO Product (ProductID, ProductName, CategoryID, Price, StockQuantity)
VALUES
(1, 'Laptop', 101, 1200.00, 50),
(2, 'Mouse', 102, 25.00, 200),
(3, 'Keyboard', 102, 75.00, 150),
(4, 'Monitor', 101, 300.00, 30),
(5, 'Webcam', 102, 50.00, 100),
(6, 'Printer', 103, 250.00, 20),
(7, 'Scanner', 103, 150.00, 15),
(8, 'Tablet', 101, 400.00, 40),
(9, 'Speaker', 102, 100.00, 80),
(10, 'External Hard Drive', 104, 80.00, 60);

CREATE NONCLUSTERED INDEX IX_Products_ProductName
ON Product (ProductName);
CREATE NONCLUSTERED INDEX IX_Products_CategoryID
ON Product (CategoryID);
CREATE NONCLUSTERED INDEX IX_Products_CategoryID_Price
ON Product (CategoryID, Price);
CREATE NONCLUSTERED INDEX IX_Products_CategoryID_Covering
ON Product (CategoryID)
INCLUDE (ProductName, Price);

SELECT * FROM Product WHERE ProductName LIKE 'M%';
SELECT * FROM Product WHERE CategoryID = 102;
SELECT ProductID, ProductName, Price FROM Product WHERE CategoryID = 101 ORDER BY Price DESC;
SELECT ProductName, Price FROM Product WHERE CategoryID = 102;
-- 7.ornek bitti
-- 8.ornek Unique NonClustered Index ile Ara� Markas�
CREATE TABLE CarModels (
    ModelID INT PRIMARY KEY IDENTITY(1,1), -- benzersiz ID
    Make NVARCHAR(50) NOT NULL,       -- Ara� Markas� 
    Model NVARCHAR(50) NOT NULL,      -- Ara� Modeli
    Year INT,                        -- Model Y�l�
    Segment NVARCHAR(50)             -- Ara� Segmenti
);

INSERT INTO CarModels (Make, Model, Year, Segment)
VALUES
('Ford', 'Focus', 2022, 'Hatchback'),
('Ford', 'Fiesta', 2023, 'Hatchback'), -- Ayn� marka, farkl� model ekledik
('Toyota', 'Corolla', 2023, 'Sedan'),
('Honda', 'Civic', 2024, 'Sedan');

CREATE UNIQUE NONCLUSTERED INDEX UQ_CarModels_Make_Model
ON CarModels (Make, Model);

-- Verileri kontrol edelim
SELECT * FROM CarModels;

-- Bu ekleme hataya neden olacakt�r ��nk� 'Ford Focus' zaten var
INSERT INTO CarModels (Make, Model, Year, Segment)
VALUES ('Ford', 'Focus', 2024, 'Sedan');
-- 8.ornek bitti

-- 9.Ornek Universite Index Ornegi
CREATE TABLE Universities (
    UniversityID INT PRIMARY KEY IDENTITY(1,1), -- unique ID
    UniversityName NVARCHAR(200) NOT NULL,    -- �niversite Ad�
    City NVARCHAR(100),                       -- bulundugu sehir
    Country NVARCHAR(100),                    -- bulundugu ulke
    EstablishmentYear INT                    -- kurulus yili
);

INSERT INTO Universities (UniversityName, City, Country, EstablishmentYear)
VALUES
('Orta Do�u Teknik �niversitesi', 'Ankara', 'T�rkiye', 1956),
('�stanbul Teknik �niversitesi', '�stanbul', 'T�rkiye', 1773),
('Hacettepe �niversitesi', 'Ankara', 'T�rkiye', 1967),
('Biruni �niversitesi', '�stanbul', 'T�rkiye', 2014),
('Ege �niversitesi', '�zmir', 'T�rkiye', 1955),
('Stanford University', 'Stanford', 'USA', 1885),
('Massachusetts Institute of Technology (MIT)', 'Cambridge', 'USA', 1861),
('University of Oxford', 'Oxford', 'UK', 1096);

CREATE NONCLUSTERED INDEX IX_Universities_UniversityName
ON Universities (UniversityName);

SELECT UniversityID, UniversityName, City, Country
FROM Universities
WHERE UniversityName = 'Biruni �niversitesi';

SELECT UniversityID, UniversityName, City, Country
FROM Universities
WHERE UniversityName LIKE 'B%';  -- adi B ile baslayan universite

SELECT UniversityID, UniversityName, City, Country
FROM Universities
ORDER BY UniversityName;  -- uni adina gore siralama
--9.Ornek bitti...
--10.ornek Adresler ile Index
CREATE TABLE Addresses (
    AddressId INT PRIMARY KEY IDENTITY(1,1), -- Otomatik artan benzersiz ID
    StreetName NVARCHAR(255),             -- Sokak adlar� i�in NVARCHAR
    City NVARCHAR(100)                    -- �ehir bilgisi (iste�e ba�l�)
);
INSERT INTO Addresses (StreetName, City) VALUES
('Papatya Soka��', '�stanbul'),
('Menek�e Caddesi', 'Ankara'),
('Lale Soka��', '�zmir'),
('G�l Soka��', '�stanbul'),
('Zambak Soka��', 'Ankara');

CREATE INDEX IX_Addresses_StreetName
ON Addresses (StreetName);

SELECT * FROM Addresses WITH(INDEX(IX_Addresses_StreetName))