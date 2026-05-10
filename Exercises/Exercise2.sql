USE
    everyloop;

--Uppgift 2 a)
SELECT
    [Period] AS [Period],
    MIN([Number]) AS [From],
    MAX([Number]) AS [To],
    FORMAT(AVG(Stableisotopes), 'N2') AS [Average isotopes],
    STRING_AGG([Symbol], ', ') AS [Symbols]
FROM
    [Elements]
GROUP BY
    [Period];

--Uppgift 2 b)
SELECT
    Region,
    Country,
    City,
    COUNT(*) AS Customers
FROM
    Company.customers
GROUP BY
    Region,
    Country,
    City
HAVING
    COUNT(City) > 1;

--Uppgift 2 c)
DECLARE @SeasonInfo nvarchar(MAX);

SET @SeasonInfo = '';

SELECT
    @SeasonInfo = @SeasonInfo
    + 'Säsong '
    + CAST(Season AS nvarchar)
    + ' sändes från '
    + FORMAT(MIN([Original air date]), 'MMMM', 'sv')
    + ' till ' + FORMAT(MAX([Original air date]), 'MMMM yyyy', 'sv')
    + '. Totalt sändes ' + CAST(COUNT(EpisodeInSeason) AS nvarchar)
    + ' avsnitt, som i genomsnitt sågs av '
    + FORMAT(AVG([U.S. viewers(millions)]), 'N1', 'sv')
    + ' miljoner människor i USA.'
    + CHAR(13)
    + CHAR(10)
FROM
    GameOfThrones
GROUP BY Season;

PRINT @SeasonInfo;

--Uppgift 2 d)
SELECT
    FirstName + ' ' + LastName AS Namn,
    CAST(DATEDIFF(YY, LEFT(ID, 6), GETDATE()) - CASE
        WHEN CAST(FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') AS int) < RIGHT(LEFT(ID, 6), 4) THEN 1
        ELSE 0
        END AS nvarchar) + ' år' AS Ålder, 
    CASE
        WHEN RIGHT(LEFT(ID, 10), 1) % 2 = 0 THEN 'Kvinna'
        ELSE 'Man'
    END AS Kön
FROM
    Users
ORDER BY
    Namn ASC;

--Uppgift 2 e)
SELECT
    Region,
    COUNT(*) AS Countries,
    SUM(CAST([Population] AS bigint)) AS [Total Population],
    SUM([Area (sq# mi#)]) AS [Total Area],
    FORMAT(AVG(TRY_CAST(REPLACE([Pop# Density (per sq# mi#)], ',', '.') AS numeric(10,2))), 'N2') AS [Average Population Density],
    FORMAT(AVG(TRY_CAST(REPLACE([Infant mortality (per 1000 births)], ',', '.') AS numeric(10,2))), '0') AS [Average Infant Mortality]
FROM
    Countries
GROUP BY
    Region
ORDER BY
    [Total Population] DESC;

--Uppgift 2 f)
SELECT
    CASE WHEN CHARINDEX(',', [Location served]) > 0
        THEN LTRIM(TRIM('[1, 2, 7]' FROM TRIM(',' FROM REPLACE(REVERSE(LEFT(REVERSE([Location served]), CHARINDEX(',', REVERSE([Location served])))), CHAR(160), ''))))
        ELSE [Location served]
    END AS Land,
	COUNT(IATA) AS [Antal flygplatser],
	SUM(CASE WHEN ICAO IS NULL THEN 1 ELSE 0 END) AS [Antal ICAO nulls],
	format(sum(CASE WHEN ICAO IS NULL THEN 1 ELSE 0 END) / cast(count(IATA) AS numeric), 'p') AS [Andel ICAO nulls]
FROM
	Airports
GROUP BY
	CASE WHEN CHARINDEX(',', [Location served]) > 0
        THEN LTRIM(TRIM('[1, 2, 7]' FROM TRIM(',' FROM REPLACE(REVERSE(LEFT(REVERSE([Location served]), CHARINDEX(',', REVERSE([Location served])))), CHAR(160), ''))))
        ELSE [Location served]
    END
ORDER BY
    [Antal flygplatser] DESC;