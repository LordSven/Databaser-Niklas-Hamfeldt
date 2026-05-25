USE Bokhandel;

DROP TABLE IF EXISTS MultiplaFörfattare;
DROP TABLE IF EXISTS OrderDetaljer;
DROP TABLE IF EXISTS Ordrar;
DROP TABLE IF EXISTS Kunder;
DROP TABLE IF EXISTS LagerSaldo;
DROP TABLE IF EXISTS Butiker;
DROP TABLE IF EXISTS Böcker;
DROP TABLE IF EXISTS Genre;
DROP TABLE IF EXISTS Förlag;
DROP TABLE IF EXISTS Författare;
DROP VIEW IF EXISTS TitlarPerFörfattare;
DROP VIEW IF EXISTS OrdrarPerKund;
DROP PROCEDURE IF EXISTS FlyttaBok;

CREATE TABLE Författare (
    FörfattarID INT IDENTITY(1,1) PRIMARY KEY,
    Förnamn NVARCHAR(50) NOT NULL,
    Andranamn NVARCHAR(50),
    Efternamn NVARCHAR(50) NOT NULL,
    Pseudonym NVARCHAR(100),
    Födelsedatum DATE,
    Dödsdatum DATE
);

CREATE TABLE Förlag (
    FörlagID INT IDENTITY(1,1) PRIMARY KEY,
    Namn NVARCHAR(100) NOT NULL UNIQUE,
    Adress NVARCHAR(200) NOT NULL
);

CREATE TABLE Genre (
    GenreID INT IDENTITY(1,1) PRIMARY KEY,
    Namn NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Böcker (
    ISBN13 NVARCHAR(13) PRIMARY KEY
        CHECK (LEN(ISBN13) = 13 AND (ISBN13 NOT LIKE '%[^0-9]%')),
    Titel NVARCHAR(300) NOT NULL,
    Språk NVARCHAR(50) NOT NULL,
    FörfattarID INT NOT NULL,
    Utgivningsdatum DATE,
    Pris NUMERIC(10, 2) NOT NULL
        CHECK (Pris >= 0),
    FörlagID INT NOT NULL,
    GenreID INT NOT NULL,
    CONSTRAINT FK_Böcker_Författare FOREIGN KEY (FörfattarID) REFERENCES Författare(FörfattarID),
    FOREIGN KEY (FörlagID) REFERENCES Förlag(FörlagID),
    FOREIGN KEY (GenreID) REFERENCES Genre(GenreID)
);

CREATE TABLE Butiker (
    ButikID INT IDENTITY(1,1) PRIMARY KEY,
    Namn NVARCHAR(100) NOT NULL,
    Adress NVARCHAR(200) NOT NULL
);

CREATE TABLE LagerSaldo (
    ButikID INT NOT NULL,
    ISBN13 NVARCHAR(13) NOT NULL,
    Antal INT NOT NULL
        CHECK (Antal >= 0),
    PRIMARY KEY (ButikID, ISBN13),
    FOREIGN KEY (ButikID) REFERENCES Butiker(ButikID),
    FOREIGN KEY (ISBN13) REFERENCES Böcker(ISBN13)
);

CREATE TABLE Kunder (
    KundID INT IDENTITY(1,1) PRIMARY KEY,
    Förnamn NVARCHAR(50) NOT NULL,
    Efternamn NVARCHAR(50) NOT NULL,
    Epost NVARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Ordrar (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    KundID INT NOT NULL,
    ButikID INT NOT NULL,
    Beställningsdatum DATE NOT NULL,
    FOREIGN KEY (KundID) REFERENCES Kunder(KundID),
    FOREIGN KEY (ButikID) REFERENCES Butiker(ButikID)
);

CREATE TABLE OrderDetaljer (
    OrderID INT NOT NULL,
    ISBN13 NVARCHAR(13) NOT NULL,
    Antal INT NOT NULL
        CHECK (Antal >= 0),
    Pris NUMERIC(10, 2) NOT NULL
        CHECK (Pris >= 0),
    Kostnad AS (Antal * Pris) PERSISTED,
    PRIMARY KEY (OrderID, ISBN13),
    FOREIGN KEY (OrderID) REFERENCES Ordrar(OrderID),
    FOREIGN KEY (ISBN13) REFERENCES Böcker(ISBN13)
);

INSERT INTO
    Författare (Förnamn, Andranamn, Efternamn, Pseudonym, Födelsedatum, Dödsdatum)
VALUES
    ('John', 'Ronald Reuel', 'Tolkien', 'J.R.R. Tolkien', '1892-01-03', '1973-09-02'),
    ('George', 'Raymond Richard', 'Martin', 'George R.R. Martin', '1948-09-20', NULL),
    ('Joanne', 'Kathleen', 'Rowling', 'J.K. Rowling', '1965-07-31', NULL),
    ('Christopher', 'James', 'Paolini', NULL, '1983-11-17', NULL),
    ('Ursula', 'Kroeber', 'Le Guin', 'U.K. Le Guin', '1929-10-21', '2018-01-22'),
    ('Eric', 'Arthur', 'Blair', 'George Orwell', '1903-06-25', '1950-01-21'),
    ('Jane', NULL, 'Austen', NULL, '1775-12-16', '1817-07-18'),
    ('Lev', 'Nikolayevich', 'Tolstoy', 'Leo Tolstoy', '1828-09-09', '1910-11-20'),
    ('Agatha', 'Mary Clarissa', 'Mallowan', 'Agatha Christie', '1890-09-15', '1976-01-12'),
    ('Stephen', 'Edwin', 'King', NULL, '1947-09-21', NULL),
    ('Isaak', 'Yudovich', 'Osimov', 'Isaac Asimov', '1920-01-02', '1992-04-06'),
    ('Arthur', 'Charles', 'Clarke', 'Arthur C. Clarke', '1917-12-16', '2008-03-19'),
    ('Howard', 'Phillips', 'Lovecraft', 'H.P. Lovecraft', '1890-08-20', '1937-03-15'),
    ('Mary', NULL, 'Wollstonecraft Shelley', 'Mary Shelley', '1797-08-30', '1851-02-01'),
    ('Edgar', 'Allan', 'Poe', 'Edgar Allan Poe', '1809-01-19', '1849-10-07'),
    ('Scott', 'Francis Key', 'Fitzgerald', 'F. Scott Fitzgerald', '1896-09-24', '1940-12-21'),
    ('Ernest', 'Miller', 'Hemingway', NULL, '1899-07-21', '1961-07-02'),
    ('Samuel', 'Langhorne', 'Clemens', 'Mark Twain', '1835-11-30', '1910-04-21'),
    ('Neil', 'Richard', 'MacKinnon Gaiman', 'Neil Gaiman', '1960-11-10', NULL),
    ('Terence', 'David John', 'Pratchett', 'Terry Pratchett', '1948-04-28', '2015-03-12');

INSERT INTO
    Förlag (Namn, Adress)
VALUES
    ('Bonnier', 'Sveavägen 56, 111 34, Stockholm'),
    ('Forum', 'Sveavägen 56, 111 34, Stockholm'),
    ('Bazar', 'Sveavägen 56, 111 34, Stockholm'),
    ('Wahlström & Widstrand', 'Sveavägen 56, 111 34, Stockholm'),
    ('Albert Bonniers Förlag', 'Sveavägen 56, 111 34, Stockholm'),
    ('Norstedts', 'Tryckerigatan 4, 111 28, Stockholm'),
    ('Piratförlaget', 'Kaptensgatan 6, 114 57, Stockholm'),
    ('Natur & Kultur', 'Karlavägen 31, 114 31 Stockholm'),
    ('Weyler', 'Karlavägen 31, 114 31 Stockholm'),
    ('Modernista', 'Kvarngatan 10, 118 47, Stockholm');

INSERT INTO
    Genre (Namn)
VALUES
    ('Fantasy'),
    ('Science Fiction'),
    ('Skräck'),
    ('Klassiker'),
    ('Deckare'),
    ('Romantik'),
    ('Äventyr'),
    ('Historisk'),
    ('Satir'),
    ('Filosofi'),
    ('Poesi'),
    ('Noveller'),
    ('Biografi'),
    ('Självbiografi'),
    ('Facklitteratur'),
    ('Barnlitteratur'),
    ('Ungdomslitteratur'),
    ('Dystopi'),
    ('Utopi'),
    ('Magisk realism');

INSERT INTO
    Butiker (Namn, Adress)
VALUES
    ('Akademibokhandeln', 'Sergelgången 6, 111 57, Stockholm'),
    ('Akademibokhandeln', 'Mäster Samuelsgatan 28, 111 44, Stockholm'),
    ('Hedengrens Bokhandel', 'Grev Turegatan 13, 114 46, Stockholm'),
    ('Science Fiction Bokhandeln', 'Västerlånggatan 48, 111 29, Stockholm'),
    ('Adlibris Pocket', 'Götgatan 40, 118 26, Stockholm'),
    ('Science Fiction Bokhandeln', 'Kungsgatan 19, 411 19, Göteborg'),
    ('Akademibokhandeln', 'Norra Hamngatan 26, 411 06, Göteborg'),
    ('Adlibris', 'Kungsgatan 34, 411 19, Göteborg'),
    ('Science Fiction Bokhandeln', 'Södra Förstadsgatan 2, 211 43, Malmö'),
    ('Akademibokhandeln', 'Stora Nygatan, 211 38, Malmö'),
    ('Adlibris', 'Lokgatan 1, 211 20, Malmö');

INSERT INTO
    Böcker (ISBN13, Titel, Språk, FörfattarID, Utgivningsdatum, Pris, FörlagID, GenreID)
VALUES
    ('9780358380238', 'The Fellowship of the Ring', 'Engelska', 1, '1954-07-29', 299.00, 1, 1),
    ('9780358380245', 'The Two Towers', 'Engelska', 1, '1954-11-11', 299.00, 1, 1),
    ('9780358380252', 'The Return of the King', 'Engelska', 1, '1955-10-20', 299.00, 1, 1),
    ('9780553103540', 'A Game of Thrones', 'Engelska', 2, '1996-08-01', 199.00, 2, 1),
    ('9780553108033', 'A Clash of Kings', 'Engelska', 2, '1998-11-16', 199.00, 2, 1),
    ('9780553106633', 'A Storm of Swords', 'Engelska', 2, '2000-08-08', 199.00, 2, 1),
    ('9780553801507', 'A Feast for Crows', 'Engelska', 2, '2005-10-17', 199.00, 2, 1),
    ('9780553801477', 'A Dance with Dragons', 'Engelska', 2, '2011-07-12', 199.00, 2, 1),
    ('9780747532743', 'Harry Potter and the Philosophers Stone', 'Engelska', 3, '1997-06-26', 149.00, 3, 1),
    ('9780747538493', 'Harry Potter and the Chamber of Secrets', 'Engelska', 3, '1998-07-02', 149.00, 3, 1),
    ('9780747542155', 'Harry Potter and the Prisoner of Azkaban', 'Engelska', 3, '1999-07-08', 149.00, 3, 1),
    ('9781551925158', 'Harry Potter and the Goblet of Fire', 'Engelska', 3, '2000-07-08', 129.00, 3, 1),
    ('9780747551003', 'Harry Potter and the Order of the Phoenix', 'Engelska', 3, '2003-06-21', 149.00, 3, 1),
    ('9781338878974', 'Harry Potter and the Half-Blood Prince', 'Engelska', 3, '2005-07-16', 149.00, 3, 1),
    ('9781338878981', 'Harry Potter and the Deathly Hallows', 'Engelska', 3, '2007-07-21', 149.00, 3, 1),
    ('9780375826689', 'Eragon', 'Engelska', 4, '2002-06-26', 179.00, 4, 1),
    ('9780375840401', 'Eldest', 'Engelska', 4, '2007-03-13', 189.00, 4, 1),
    ('9780375826740', 'Brisingr', 'Engelska', 4, '2010-04-13', 199.00, 4, 1),
    ('9780375846311', 'Inheritance', 'Engelska', 4, '2012-10-23', 209.00, 4, 1),
    ('9780143111580', 'The Left Hand of Darkness', 'Engelska', 5, '1969-03-01', 129.00, 5, 2),
    ('9780451524935', '1984', 'Engelska', 6, '1949-06-08', 99.00, 6, 17),
    ('9780141439518', 'Pride and Prejudice', 'Engelska', 7, '1813-01-28', 89.00, 7, 4),
    ('9780140447934', 'War and Peace', 'Ryska', 8, '1869-01-01', 249.00, 8, 8),
    ('9780573707735', 'Murder on the Orient Express', 'Engelska', 9, '1934-01-01', 109.00, 9, 5),
    ('9780345806789', 'The Shining', 'Engelska', 10, '1977-01-28', 129.00, 10, 3),
    ('9780553293357', 'Foundation', 'Engelska', 11, '1951-06-01', 119.00, 1, 2),
    ('9780451457998', '2001: A Space Odyssey', 'Engelska', 12, '1968-07-01', 139.00, 2, 2),
    ('9780143129455', 'The Call of Cthulhu and Other Weird Stories', 'Engelska', 3, '1928-02-01', 79.00, 9, 3),
    ('9780141439471', 'Frankenstein', 'Engelska', 14, '1818-01-01', 89.00, 4, 3),
    ('9781435171374', 'The Raven and Other Poems', 'Engelska', 15, '1845-01-29', 69.00, 5, 11),
    ('9780743273565', 'The Great Gatsby', 'Engelska', 16, '1925-04-10', 99.00, 6, 4),
    ('9780684801223', 'The Old Man and the Sea', 'Engelska', 17, '1952-09-01', 109.00, 7, 4),
    ('9780143107323', 'The Adventures of Huckleberry Finn', 'Engelska', 18, '1884-12-10', 89.00, 8, 4),
    ('9781473214712', 'Good Omens', 'Engelska', 19, '1989-09-01', 129.00, 10, 3);

INSERT INTO
    LagerSaldo (ButikID, ISBN13, Antal)
VALUES
    (1, '9780358380238', 10),
    (1, '9780358380245', 15),
    (1, '9780358380252', 20),
    (1, '9780553103540', 12),
    (1, '9780553108033', 18),
    (1, '9780553106633', 25),
    (1, '9780553801507', 14),
    (1, '9780553801477', 22),
    (1, '9780747532743', 30),
    (1, '9780747538493', 28),
    (1, '9780747542155', 35),
    (1, '9781551925158', 12),
    (1, '9780747551003', 18),
    (1, '9781338878974', 25),
    (1, '9781338878981', 15),
    (1, '9780375826689', 10),
    (1, '9780375840401', 12),
    (1, '9780375826740', 8),
    (1, '9780375846311', 5),
    (1, '9781473214712', 20),
    (2, '9780143111580', 20),
    (2, '9780451524935', 25),
    (2, '9780358380238', 10),
    (2, '9780358380245', 15),
    (2, '9780358380252', 20),
    (2, '9780345806789', 12),
    (2, '9780684801223', 18),
    (2, '9780143129455', 25),
    (2, '9780553801507', 14),
    (2, '9780553801477', 22),
    (2, '9780747532743', 30),
    (2, '9780747538493', 28),
    (2, '9780747542155', 35),
    (2, '9780553103540', 12),
    (2, '9780553108033', 18),
    (2, '9780553106633', 25),
    (3, '9780553801507', 14),
    (3, '9780553801477', 22),
    (4, '9780747532743', 30),
    (4, '9780747538493', 28),
    (4, '9780747542155', 35),
    (5, '9781551925158', 20),
    (5, '9780747551003', 25),
    (5, '9781338878974', 18),
    (5, '9781338878981', 15),
    (6, '9780375826689', 10),
    (6, '9780375840401', 12),
    (6, '9780375826740', 8),
    (6, '9780375846311', 5),
    (7, '9780143111580', 20),
    (7, '9780451524935', 25),
    (8, '9780141439518', 30),
    (8, '9780140447934', 10),
    (9, '9780573707735', 18),
    (9, '9780345806789', 22),
    (10, '9780553293357', 15),
    (10, '9780451457998', 20),
    (10, '9780143129455', 12),
    (10, '9780141439471', 18),
    (10, '9781435171374', 25),
    (10, '9780743273565', 30),
    (10, '9780684801223', 28),
    (10, '9780143107323', 35);

INSERT INTO
    Kunder (Förnamn, Efternamn, Epost)
VALUES
    ('Anna', 'Andersson', 'anna.andersson@email.com'),
    ('Björn', 'Bergström', 'bjorn.bergstrom@email.com'),
    ('Carina', 'Carlsson', 'carina.carlsson@email.com'),
    ('David', 'Dahl', 'david.dahl@email.com'),
    ('Eva', 'Eriksson', 'eva.eriksson@email.com'),
    ('Fredrik', 'Fransson', 'fredrik.fransson@email.com'),
    ('Gustav', 'Gustafsson', 'gustav.gustafsson@email.com'),
    ('Hanna', 'Hansson', 'hanna.hansson@email.com'),
    ('Isabella', 'Isaksson', 'isabella.isaksson@email.com'),
    ('Johan', 'Johansson', 'johan.johansson@email.com');

INSERT INTO
    Ordrar (KundID, ButikID, Beställningsdatum)
VALUES
    (1, 1, '2024-01-15'),
    (1, 1, '2024-01-17'),
    (1, 3, '2026-04-15'),
    (1, 5, '2025-09-05'),
    (2, 7, '2024-01-20'),
    (2, 7, '2024-03-20'),
    (2, 6, '2025-10-10'),
    (2, 6, '2026-01-20'),
    (2, 6, '2024-01-20'),
    (2, 8, '2025-01-20'),
    (2, 6, '2024-01-20'),
    (3, 10, '2025-01-25'),
    (3, 9, '2024-01-25'),
    (3, 9, '2024-01-25'),
    (3, 9, '2025-10-21'),
    (3, 10, '2026-03-25'),
    (3, 11, '2025-10-21'),
    (3, 11, '2026-03-25'),
    (4, 4, '2024-02-01'),
    (4, 6, '2023-02-01'),
    (4, 4, '2022-02-01'),
    (4, 4, '2024-02-01'),
    (4, 4, '2025-02-01'),
    (5, 6, '2024-02-05'),
    (5, 8, '2024-02-05'),
    (5, 5, '2024-02-05'),
    (5, 6, '2022-02-05'),
    (5, 7, '2024-02-05'),
    (6, 6, '2019-02-10'),
    (6, 6, '2024-02-10'),
    (6, 6, '2024-02-10'),
    (6, 6, '2022-02-10'),
    (6, 6, '2024-02-10'),
    (7, 9, '2023-02-15'),
    (7, 2, '2024-02-15'),
    (7, 1, '2024-02-15'),
    (7, 7, '2024-02-15'),
    (7, 5, '2012-02-15'),
    (8, 9, '2022-02-20'),
    (8, 11, '2024-02-20'),
    (8, 9, '2024-02-20'),
    (8, 9, '2021-02-20'),
    (8, 10, '2017-02-20'),
    (9, 1, '2024-02-25'),
    (9, 2, '2015-02-25'),
    (9, 3, '2024-02-25'),
    (9, 4, '2021-02-25'),
    (9, 5, '2022-02-25'),
    (10, 10, '2023-03-01'),
    (10, 10, '2025-03-01'),
    (10, 10, '2021-03-01'),
    (10, 10, '2023-03-01'),
    (10, 10, '2024-03-01');

INSERT INTO
    OrderDetaljer (OrderID, ISBN13, Antal, Pris)
VALUES
    (1, '9780358380238', 1, 299.00),
    (1, '9780358380245', 1, 299.00),
    (2, '9780358380252', 1, 299.00),
    (2, '9780553103540', 1, 199.00),
    (3, '9780553108033', 1, 199.00),
    (3, '9780553106633', 1, 199.00),
    (4, '9780553801507', 1, 199.00),
    (4, '9780553801477', 1, 199.00),
    (5, '9780747532743', 1, 149.00),
    (5, '9780747538493', 1, 149.00),
    (6, '9780747542155', 1, 149.00),
    (6, '9781551925158', 2, 129.00),
    (7, '9780747551003', 1, 149.00),
    (7, '9781338878974', 1, 149.00),
    (8, '9781338878981', 1, 149.00),
    (8, '9780375826689', 3, 179.00),
    (9, '9780375840401', 1, 189.00),
    (9, '9780375826740', 1, 199.00),
    (10, '9780375846311', 2, 209.00),
    (10, '9781473214712', 1, 129.00),
    (11, '9780143111580', 1, 129.00),
    (11, '9780451524935', 1, 99.00),
    (12, '9780141439518', 1, 89.00),
    (12, '9780140447934', 1, 249.00),
    (13, '9780573707735', 1, 109.00),
    (13, '9780345806789', 2, 129.00),
    (14, '9780553293357', 1, 119.00),
    (14, '9780451457998', 1, 139.00),
    (15, '9780143129455', 1, 79.00),
    (15, '9780141439471', 1, 89.00),
    (16, '9780743273565', 5, 99.00),
    (16, '9780684801223', 1, 109.00),
    (17, '9780143107323', 1, 89.00),
    (17, '9781473214712', 2, 129.00),
    (18, '9780358380238', 1, 299.00),
    (18, '9780358380245', 1, 299.00),
    (18, '9780358380252', 1, 299.00),
    (19, '9780553801507', 2, 199.00),
    (19, '9780553801477', 1, 199.00),
    (20, '9780747532743', 1, 149.00),
    (21, '9780747538493', 1, 149.00),
    (21, '9780747542155', 1, 149.00),
    (22, '9781551925158', 1, 129.00),
    (23, '9780747551003', 1, 149.00),
    (24, '9781338878974', 10, 149.00),
    (25, '9781338878981', 1, 149.00),
    (25, '9780375826689', 1, 179.00),
    (26, '9780375840401', 1, 189.00),
    (27, '9780375826740', 1, 199.00),
    (28, '9780375846311', 1, 209.00),
    (29, '9781473214712', 1, 129.00),
    (30, '9780143111580', 3, 129.00),
    (30, '9780451524935', 1, 99.00),
    (30, '9780141439518', 1, 89.00),
    (31, '9780140447934', 1, 249.00),
    (32, '9780573707735', 1, 109.00),
    (33, '9780345806789', 1, 129.00),
    (34, '9780553293357', 1, 119.00),
    (35, '9780451457998', 1, 139.00),
    (36, '9780143129455', 1, 79.00),
    (37, '9780141439471', 1, 89.00),
    (38, '9780743273565', 1, 99.00),
    (39, '9780684801223', 1, 109.00),
    (39, '9780143107323', 1, 89.00),
    (40, '9781473214712', 2, 129.00),
    (41, '9780358380238', 1, 299.00),
    (42, '9780358380245', 1, 299.00),
    (43, '9780358380252', 1, 299.00),
    (44, '9780553103540', 1, 199.00),
    (45, '9780553108033', 1, 199.00),
    (46, '9780553106633', 1, 199.00),
    (47, '9780553801507', 1, 199.00),
    (48, '9780553801477', 1, 199.00),
    (49, '9780747532743', 4, 149.00),
    (50, '9780747538493', 1, 149.00),
    (50, '9781473214712', 2, 129.00),
    (50, '9780358380238', 1, 299.00),
    (50, '9780358380245', 1, 299.00),
    (50, '9780358380252', 1, 299.00),
    (50, '9780553801507', 1, 199.00),
    (50, '9780553801477', 1, 199.00),
    (50, '9780747532743', 1, 149.00),
    (50, '9780747542155', 1, 149.00),
    (50, '9780747551003', 1, 149.00),
    (50, '9781338878974', 1, 149.00),
    (50, '9781338878981', 1, 149.00),
    (50, '9780375826689', 1, 179.00),
    (50, '9780375840401', 1, 189.00),
    (50, '9780375826740', 1, 199.00),
    (50, '9780375846311', 1, 209.00),
    (50, '9780143111580', 1, 129.00),
    (50, '9780451524935', 1, 99.00),
    (50, '9780141439518', 1, 89.00),
    (50, '9780140447934', 1, 249.00),
    (50, '9780573707735', 1, 109.00),
    (51, '9780747542155', 1, 149.00),
    (51, '9780743273565', 1, 99.00),
    (51, '9780684801223', 1, 109.00),
    (51, '9780143107323', 1, 89.00),
    (51, '9780345806789', 1, 129.00),
    (51, '9780553293357', 1, 119.00),
    (52, '9781551925158', 1, 129.00),
    (52, '9780747551003', 1, 149.00),
    (52, '9781338878974', 1, 149.00),
    (52, '9781338878981', 1, 149.00),
    (52, '9780141439471', 1, 89.00),
    (52, '9780451457998', 3, 139.00),
    (52, '9780143129455', 1, 79.00),
    (53, '9780553293357', 1, 119.00),
    (53, '9780451457998', 1, 139.00),
    (53, '9780375826689', 1, 179.00),
    (53, '9780375840401', 2, 189.00),
    (53, '9780375826740', 1, 199.00),
    (53, '9780375846311', 1, 209.00),
    (53, '9780143111580', 1, 129.00),
    (53, '9780451524935', 1, 99.00),
    (53, '9780141439518', 1, 89.00),
    (53, '9780140447934', 1, 249.00),
    (53, '9780573707735', 1, 109.00),
    (53, '9780345806789', 1, 129.00);

CREATE TABLE MultiplaFörfattare (
    ISBN13 NVARCHAR(13) NOT NULL,
    FörfattarID INT NOT NULL,
    PRIMARY KEY (ISBN13, FörfattarID),
    FOREIGN KEY (ISBN13) REFERENCES Böcker(ISBN13),
    FOREIGN KEY (FörfattarID) REFERENCES Författare(FörfattarID)
);

INSERT INTO
    MultiplaFörfattare (ISBN13, FörfattarID)
SELECT
    ISBN13, FörfattarID
FROM
    Böcker;

INSERT INTO
    MultiplaFörfattare (ISBN13, FörfattarID)
VALUES
    ('9781473214712', 20);

ALTER TABLE
    Böcker
DROP CONSTRAINT
    FK_Böcker_Författare;

ALTER TABLE
    Böcker
DROP
    COLUMN FörfattarID;

GO

CREATE VIEW TitlarPerFörfattare AS
SELECT
    f.Förnamn + ' ' + f.Efternamn AS Namn,
    f.Pseudonym,
    CASE WHEN Dödsdatum IS NULL
        THEN CAST(DATEDIFF(YEAR, Födelsedatum, GETDATE()) AS NVARCHAR) + ' år'

        ELSE 'Dog ' + CAST(DATEPART(YEAR, Dödsdatum) AS NVARCHAR) + ' vid ' + CAST(DATEDIFF(YEAR, Födelsedatum, Dödsdatum) AS NVARCHAR) + ' års ålder'
    END AS Ålder,
    COUNT(DISTINCT mf.ISBN13) AS Titlar,
    SUM(ls.Antal * b.Pris) AS Lagervärde
FROM
    Författare f
JOIN
    MultiplaFörfattare mf ON f.FörfattarID = mf.FörfattarID
JOIN
    Böcker b ON mf.ISBN13 = b.ISBN13
JOIN
    LagerSaldo ls ON b.ISBN13 = ls.ISBN13
GROUP BY
    f.FörfattarID,
    f.Förnamn,
    f.Efternamn,
    f.Pseudonym,
    f.Födelsedatum,
    f.Dödsdatum;

GO

CREATE VIEW OrdrarPerKund AS
SELECT
    k.Förnamn + ' ' + k.Efternamn AS Namn,
    k.Epost,
    COUNT(DISTINCT o.OrderID) AS AntalOrdrar,
    SUM(od.Kostnad) AS TotalKostnad,
    DATEDIFF(DAY, MAX(o.Beställningsdatum), GETDATE()) AS DagarSedanSenasteOrder
FROM
    Kunder k
JOIN
    Ordrar o ON k.KundID = o.KundID
JOIN
    OrderDetaljer od ON o.OrderID = od.OrderID
GROUP BY
    k.KundID,
    k.Förnamn,
    k.Efternamn,
    k.Epost;

GO

CREATE PROCEDURE FlyttaBok
    @FrånButikID INT,
    @TillButikID INT,
    @ISBN13 NVARCHAR(13),
    @Antal INT = 1
AS
BEGIN

SET NOCOUNT ON;

IF NOT EXISTS (
    SELECT *
    FROM LagerSaldo
    WHERE ButikID = @FrånButikID
    AND ISBN13 = @ISBN13
)
BEGIN
    RAISERROR('Boken finns inte i källbutiken.', 16, 1);
    RETURN;
END;

IF (
    SELECT
        Antal
    FROM
        LagerSaldo
    WHERE
        ButikID = @FrånButikID
    AND
        ISBN13 = @ISBN13
) < @Antal
BEGIN
    RAISERROR('Inte tillräckligt antal böcker i lager.', 16, 2);
    RETURN;
END;

UPDATE
    LagerSaldo
SET
    Antal = Antal - @Antal
WHERE
    ButikID = @FrånButikID
AND
    ISBN13 = @ISBN13;

IF EXISTS (
    SELECT
        *
    FROM
        LagerSaldo
    WHERE
        ButikID = @TillButikID
    AND
        ISBN13 = @ISBN13
)
BEGIN
    UPDATE
        LagerSaldo
    SET
        Antal = Antal + @Antal
    WHERE
        ButikID = @TillButikID
    AND
        ISBN13 = @ISBN13;
END
ELSE
    BEGIN
        INSERT INTO LagerSaldo (ButikID, ISBN13, Antal)
        VALUES (@TillButikID, @ISBN13, @Antal);
    END;

END;

GO