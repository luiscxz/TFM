USE TFM;
GO
-- ELimina caracteres innecesarios en texto
IF OBJECT_ID('dbo.CleanToText', 'FN') IS NULL
BEGIN
    EXEC ('CREATE FUNCTION [dbo].[CleanToText](@Data VARCHAR(100))
    RETURNS VARCHAR(100)
    AS 
    BEGIN
        DECLARE @Letter INT;
        SET @Letter = PATINDEX(''%[^A-Za-z _]%'', @Data);
        WHILE @Letter > 0
        BEGIN
            SET @Data = STUFF(@Data, @Letter, 1, '''');
            SET @Letter = PATINDEX(''%[^A-Za-z ]%'', @Data);
        END
        SET @Data = REPLACE(@Data, ''_'', '' '');
        WHILE CHARINDEX(''  '', @Data) > 0
        BEGIN
            SET @Data = REPLACE(@Data, ''  '', '' '');
        END
        
        RETURN LTRIM(RTRIM(@Data));
    END');
END
GO

UPDATE Store
SET City = dbo.CleanToText(City);
Go
-- Capitaliza los nombres de las ciudades
IF OBJECT_ID('dbo.InitCap', 'FN') IS NULL
BEGIN
    EXEC ('CREATE FUNCTION [dbo].[InitCap] (@inStr VARCHAR(100))
    RETURNS VARCHAR(100)
    AS
    BEGIN
        DECLARE @outStr VARCHAR(100) = LOWER(@inStr),
             @char CHAR(1), 
             @alphanum BIT = 0,
             @len INT = LEN(@inStr),
                     @pos INT = 1;        

        -- Iterar entre todos los caracteres en la cadena de entrada
        WHILE @pos <= @len BEGIN

          -- Obtener el siguiente caracter
          SET @char = SUBSTRING(@inStr, @pos, 1);

          -- Si la posición del caracter es la 1ª, o el caracter previo no es alfanumérico
          -- convierte el caracter actual a mayúscula
          IF @pos = 1 OR @alphanum = 0
            SET @outStr = STUFF(@outStr, @pos, 1, UPPER(@char));

          SET @pos = @pos + 1;

          -- Define si el caracter actual es  non-alfanumérico
          IF ASCII(@char) <= 47 OR (ASCII(@char) BETWEEN 58 AND 64) OR
          (ASCII(@char) BETWEEN 91 AND 96) OR (ASCII(@char) BETWEEN 123 AND 126)
          SET @alphanum = 0;
          ELSE
          SET @alphanum = 1;

        END

       RETURN @outStr;         
    END');
END
GO
UPDATE Store
SET City = dbo.InitCap(City);
GO

-- Corrige las fechas con formato inválido
UPDATE Store
SET Open_Date = CONCAT(
        LEFT(Open_Date, 4), '-',            -- Año
        SUBSTRING(Open_Date, 5, 2), '-',    -- Mes
        SUBSTRING(Open_Date, 7, 2), ' ',    -- Día
        SUBSTRING(Open_Date, 9, 2), ':',    -- Hora
        SUBSTRING(Open_Date, 11, 2), ':',   -- Minuto
        RIGHT(Open_Date, 2)                 -- Segundo
    )
WHERE ISDATE(Open_Date) = 0;

Go
-- Corrige las columnas numéricas
IF OBJECT_ID('dbo.CleanToNum', 'FN') IS NULL
BEGIN
    EXEC ('CREATE FUNCTION [dbo].[CleanToNum](@Data VARCHAR(100))
    RETURNS VARCHAR(100)
    AS 
    BEGIN
        DECLARE @posicion INT;
        SET @posicion = PATINDEX(''%[^0-9]%'', @Data);
        WHILE @posicion > 0
        BEGIN
            SET @Data = STUFF(@Data, @posicion, 1, '''');
            SET @posicion = PATINDEX(''%[^0-9]%'', @Data);
        END
        RETURN LTRIM(RTRIM(@Data));
    END');
END
GO

UPDATE Store
SET Zip_Code = dbo.CleanToNum(Zip_Code);
Go
UPDATE Store
SET Phone = dbo.CleanToNum(Phone);
Go
-- Normaliza columna Email
UPDATE Store 
Set Email = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(Email, ' at ', '@'), '#', '@'), ',', '.')));
Go
Select *from Store;