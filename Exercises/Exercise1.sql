USE
    everyloop;

--Uppgift 1 a)
SELECT 
    Title,
    'S' + FORMAT(Season, '00') + 'E' + FORMAT(EpisodeInSeason, '00') AS Episode
FROM
    GameOfThrones;

--Uppgift 1 a) alternativ lösning
SELECT 
    Title,
    'S' + RIGHT('00' + CAST(Season AS nvarchar), 2) + 'E' + RIGHT('00' + CAST(EpisodeInSeason AS nvarchar), 2) AS Episode
FROM
    GameOfThrones;

--Uppgift 1 b)
DROP TABLE IF EXISTS Users2;

SELECT
    *
INTO
    Users2
FROM
    Users;


UPDATE
    Users2
SET
    UserName = lower(LEFT(CAST(FirstName as nvarchar), 2)) + lower(LEFT(CAST(LastName as nvarchar), 2));

--Uppgift 1 c)
DROP TABLE IF EXISTS Airports2;

SELECT
    *
INTO
    Airports2
FROM
    Airports;


UPDATE
    Airports2
SET
    Time = ISNULL(Time, '-'),
    DST = ISNULL(DST, '-');

--Uppgift 1 d)
DROP TABLE IF EXISTS Elements2;

SELECT
    *
INTO
    Elements2
FROM
    Elements;


DELETE FROM
    Elements2
WHERE
    Name IN ('Erbium', 'Helium', 'Nitrogen', 'Platinum', 'Selenium') OR Name LIKE '[dkmou]%';

--Uppgift 1 e)
DROP TABLE IF EXISTS Elements3;

SELECT
    Symbol,
    Name,
    CASE 
        WHEN LOWER(LEFT(Name, len(Symbol))) = LOWER(Symbol) THEN 'Yes'
        ELSE 'No'
    END AS Matching
INTO 
    Elements3
FROM 
    Elements;

--Uppgift 1 f)
DROP TABLE IF EXISTS Colors2;

SELECT
    Name,
    Red,
    Green,
    Blue
INTO
    Colors2
FROM
    Colors;


UPDATE
    Colors2
SET
    Green = ISNULL(Green, 255),
    Blue = ISNULL(Blue, 0);


ALTER TABLE
    Colors2    
ADD
    Code nvarchar(7);


UPDATE
    Colors2
SET
    Code = '#' + FORMAT(Red, 'X2') + FORMAT(Green, 'X2') + FORMAT(Blue, 'X2');

--Uppgift 1 g)
DROP TABLE IF EXISTS Types2;

SELECT
    Integer,
    String
INTO
    Types2
FROM
    Types;


SELECT
    Integer,
    Integer * 0.01 AS Float,
    String,
    CAST(DATEADD(DAY, Integer - 1, DATEADD(MINUTE, Integer, '2019-01-01 09:00:00')) AS datetime2(7)) AS DateTime,
    Integer % 2 AS Bool
FROM
    Types2;