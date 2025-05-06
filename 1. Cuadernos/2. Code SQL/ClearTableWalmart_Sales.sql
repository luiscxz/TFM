USE TFM;
GO

-- Verificar y convertir columna Temperature a VARCHAR(6)
IF EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Walmart_Sales' AND COLUMN_NAME = 'Temperature' AND DATA_TYPE <> 'varchar')
BEGIN
    ALTER TABLE Walmart_Sales ALTER COLUMN Temperature VARCHAR(6);
END

-- Convertir columna Temperature a FLOAT
IF EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Walmart_Sales' AND COLUMN_NAME = 'Temperature' AND DATA_TYPE <> 'float')
BEGIN
    ALTER TABLE Walmart_Sales ALTER COLUMN Temperature FLOAT;
END

-- Verificar y convertir columna Fuel_Price a VARCHAR(5)
IF EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Walmart_Sales' AND COLUMN_NAME = 'Fuel_Price' AND DATA_TYPE <> 'varchar')
BEGIN
    ALTER TABLE Walmart_Sales ALTER COLUMN Fuel_Price VARCHAR(5);
END

-- Convertir columna Fuel_Price a FLOAT
IF EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Walmart_Sales' AND COLUMN_NAME = 'Fuel_Price' AND DATA_TYPE <> 'float')
BEGIN
    ALTER TABLE Walmart_Sales ALTER COLUMN Fuel_Price FLOAT;
END

-- Verificar y convertir columna Unemployment a VARCHAR(6)
IF EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Walmart_Sales' AND COLUMN_NAME = 'Unemployment' AND DATA_TYPE <> 'varchar')
BEGIN
    ALTER TABLE Walmart_Sales ALTER COLUMN Unemployment VARCHAR(6);
END

-- Convertir columna Unemployment a FLOAT
IF EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Walmart_Sales' AND COLUMN_NAME = 'Unemployment' AND DATA_TYPE <> 'float')
BEGIN
    ALTER TABLE Walmart_Sales ALTER COLUMN Unemployment FLOAT;
END

-- Verificar y convertir columna Store a INT
IF EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Walmart_Sales' AND COLUMN_NAME = 'Store' AND DATA_TYPE <> 'int')
BEGIN
    ALTER TABLE Walmart_Sales ALTER COLUMN Store INT;
END

-- Verificar y convertir columna Holiday_Flag a INT
IF EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Walmart_Sales' AND COLUMN_NAME = 'Holiday_Flag' AND DATA_TYPE <> 'int')
BEGIN
    ALTER TABLE Walmart_Sales ALTER COLUMN Holiday_Flag INT;
END

-- Verificar y convertir columna [Date] a NVARCHAR(10)
IF EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.COLUMNS 
           WHERE TABLE_NAME = 'Walmart_Sales' AND COLUMN_NAME = 'Date' AND DATA_TYPE <> 'nvarchar')
BEGIN
    ALTER TABLE Walmart_Sales ALTER COLUMN [Date] NVARCHAR(10);
END
GO

-- Convertir las fechas al formato DD-MM-YYYY si no tienen guiones

UPDATE Walmart_Sales
SET [Date] = CONVERT(NVARCHAR(10), CONVERT(DATE, [Date], 120), 105)
WHERE ISDATE([Date]) = 1 
  AND (LEN([Date]) <> 10 OR CHARINDEX('-', [Date]) <> 3);
GO

-- Crear columna Holiday_Events si no existe
IF NOT EXISTS (
    SELECT * 
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Walmart_Sales' 
    AND COLUMN_NAME = 'Holiday_Events'
)
BEGIN
    ALTER TABLE Walmart_Sales ADD Holiday_Events NVARCHAR(14);
END;
GO

-- Actualizar valores de Holiday_Events
UPDATE Walmart_Sales
SET Holiday_Events = 
  CASE 
    WHEN [Date] IN ('12-02-2010', '11-02-2011', '10-02-2012') THEN 'Super Bowl'
    WHEN [Date] IN ('10-09-2010', '09-09-2011', '07-09-2012') THEN 'Labour Day'
    WHEN [Date] IN ('26-11-2010', '25-11-2011', '23-11-2012') THEN 'Thanksgiving'
    WHEN [Date] IN ('31-12-2010', '30-12-2011', '28-12-2012') THEN 'Christmas'
    ELSE COALESCE(Holiday_Events, 'No aplica')
  END;
GO

-- Formatear columna CPI
UPDATE Walmart_Sales
SET CPI = STUFF(TRIM(STR(CPI, 20)), 4, 0, '.')
WHERE CPI = FLOOR(CPI) AND CPI IS NOT NULL AND CPI <> '';
GO
Select *from Walmart_Sales;