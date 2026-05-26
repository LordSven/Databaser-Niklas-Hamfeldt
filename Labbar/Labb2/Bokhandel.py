from sqlalchemy import create_engine, text

connection_string = (
    "mssql+pyodbc://app_user:qwerty@localhost/Bokhandel?"
    "driver=ODBC+Driver+18+for+SQL+Server"
    "&TrustServerCertificate=yes"
)

engine = create_engine(connection_string)

search = input('Kontrollera lagerstatus med ISBN13 eller del av titel: ')

query = text('''
WITH FörfattareAgg AS (
    SELECT
        mf.ISBN13,
        STRING_AGG(
            CASE 
                WHEN f.Pseudonym IS NOT NULL THEN f.Pseudonym
                ELSE f.Förnamn + ' ' + f.Efternamn
            END,
            ', '
        ) AS Författare
    FROM MultiplaFörfattare mf
    JOIN Författare f ON mf.FörfattarID = f.FörfattarID
    GROUP BY mf.ISBN13
),
LagerAgg AS (
    SELECT
        ls.ISBN13,
        STRING_AGG(
            bu.Namn + ' (' + bu.Adress + ') - ' + CAST(ls.Antal AS NVARCHAR) + ' st',
            ' | '
        ) AS Lagerinfo
    FROM LagerSaldo ls
    JOIN Butiker bu ON ls.ButikID = bu.ButikID
    GROUP BY ls.ISBN13
)
SELECT
    b.Titel,
    f.Författare,
    g.Namn AS Genre,
    b.Pris,
    l.Lagerinfo
FROM Böcker b
JOIN Genre g ON b.GenreID = g.GenreID
LEFT JOIN FörfattareAgg f ON b.ISBN13 = f.ISBN13
LEFT JOIN LagerAgg l ON b.ISBN13 = l.ISBN13
WHERE b.Titel LIKE :titel
   OR b.ISBN13 = :isbn
ORDER BY b.Titel;
''')

with engine.connect() as conn:

    result = conn.execute(
        query,
        {'titel': f'%{search}%', 'isbn': search}
    )

    for row in result:
        print(
            f'Titel: {row.Titel}\n',
            f'Författare: {row.Författare}\n',
            f'Pris: {row.Pris} kr\n',
            f'Genre: {row.Genre}\n',
            f'Lagerinfo: {row.Lagerinfo}\n'
            )