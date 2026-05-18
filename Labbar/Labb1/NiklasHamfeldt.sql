USE
    everyloop;

GO

--MoonMissions

DROP TABLE IF EXISTS
    SuccessfulMissions;

GO

SELECT
    Spacecraft,
    [Launch date],
    [Carrier Rocket],
    Operator,
    [Mission type]
INTO
    SuccessfulMissions
FROM
    MoonMissions
WHERE
    Outcome = 'Successful';

GO

UPDATE
    SuccessfulMissions
SET
    Operator = LTRIM(Operator);

GO

UPDATE
    SuccessfulMissions
SET
    Spacecraft = CASE WHEN CHARINDEX('(', Spacecraft) > 0 
                     THEN LEFT(Spacecraft, CHARINDEX('(', Spacecraft) - 1)
                     ELSE Spacecraft
                 END;

GO

SELECT
    Operator,
    [Mission type],
    COUNT(*) AS [Mission count]
FROM
    SuccessfulMissions
GROUP BY
    Operator,
    [Mission type]
HAVING
    COUNT(*) > 1
ORDER BY
    Operator,
    [Mission type];

GO

--Users

DROP TABLE IF EXISTS
    NewUsers;

SELECT
    ID,
    UserName,
    [Password],
    FirstName + ' ' + LastName AS [Name],
    FirstName,
    LastName,
    CASE
        WHEN RIGHT(LEFT(ID, 10), 1) % 2 = 0 THEN 'Female'
        ELSE 'Male'
    END AS Gender,
    Email,
    Phone
INTO
    NewUsers
FROM
    Users;

GO

DROP TABLE IF EXISTS
    DuplicateUserNames;

SELECT
    UserName,
    COUNT(*) AS [Occurances]
INTO
    DuplicateUserNames
FROM
    NewUsers
GROUP BY
    UserName
HAVING
    COUNT(*) > 1;

GO

ALTER TABLE NewUsers
ALTER COLUMN UserName nvarchar(8);

WITH CTE AS (
    SELECT 
        ID,
        UserName,
        ROW_NUMBER() OVER (PARTITION BY UserName ORDER BY ID) AS Mod,
        COUNT(*) OVER (PARTITION BY UserName) AS Duplicates
    FROM
        NewUsers
)
UPDATE
    NewUsers
SET
    UserName = CTE.UserName + CAST(CTE.Mod AS nvarchar(10))
FROM
    NewUsers
JOIN
    CTE
ON
    NewUsers.ID = CTE.ID
WHERE
    CTE.Duplicates > 1;

GO

DELETE FROM
    NewUsers
WHERE
    Gender = 'Female' AND CAST(LEFT(ID, 2) AS int) < 70;

GO

INSERT INTO
    NewUsers (ID, UserName, [Password], [Name], FirstName, LastName, Gender, Email, Phone)
VALUES
    ('950228-7130', 'nikham', 'qwerty', 'Niklas Hamfeldt', 'Niklas', 'Hamfeldt', 'Male', 'bussbilen@hotmail.com', '073-5361247');

GO

SELECT
    Gender,
    CAST(AVG(DATEDIFF(YY, LEFT(ID, 6), GETDATE()) - CASE
        WHEN CAST(FORMAT(GETDATE(), 'MM') + FORMAT(GETDATE(), 'dd') AS int) < RIGHT(LEFT(ID, 6), 4) THEN 1
        ELSE 0
    END) AS nvarchar) + ' years'AS [Average age]
FROM
    NewUsers
GROUP BY
    Gender;

GO

--Company (Joins)

SELECT
    products.Id AS Id,
    ProductName AS Product,
    CompanyName AS Supplier,
    CategoryName AS Category
FROM
    company.products
JOIN
    company.suppliers ON products.SupplierID = suppliers.ID
JOIN
    company.categories ON products.CategoryID = categories.ID;

GO

SELECT
    RegionDescription AS Region,
    COUNT(DISTINCT employees.ID) AS Employees
FROM
    company.regions
JOIN
    company.territories ON regions.ID = territories.RegionID
JOIN
    company.employee_territory ON territories.ID = employee_territory.TerritoryID
JOIN
    company.employees ON employee_territory.EmployeeID = employees.ID
GROUP BY RegionDescription;

GO

SELECT
    e.Id AS Id,
    e.TitleOfCourtesy + ' ' + e.FirstName + ' ' + e.LastName AS [Name],
    CASE WHEN e.ReportsTo IS NULL
        THEN 'Nobody!'
        ELSE m.TitleOfCourtesy + ' ' + m.FirstName + ' ' + m.LastName
    END AS [Reports to]
FROM
    company.employees e
LEFT JOIN
    company.employees m ON e.ReportsTo = m.ID

GO