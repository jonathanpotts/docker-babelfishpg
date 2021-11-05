-- Create example_db schema
CREATE SCHEMA example_db;
GO

DROP TABLE IF EXISTS example_db.books;
DROP TABLE IF EXISTS example_db.authors;

-- Create tables
CREATE TABLE example_db.authors (
	author_id INT IDENTITY PRIMARY KEY,
	[name] NVARCHAR (MAX) NOT NULL,
);

CREATE TABLE example_db.Books (
	book_id INT IDENTITY PRIMARY KEY,
	title NVARCHAR (MAX) NOT NULL,
	author_id INT NOT NULL,
	publish_date DATETIME2 NOT NULL,
	price MONEY NOT NULL,
	FOREIGN KEY (author_id) REFERENCES example_db.authors (author_id) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- Seed tables
INSERT INTO example_db.authors ([name]) VALUES
		('Kristin Hannah'),
		('Andy Weir');

INSERT INTO example_db.books (title, author_id, publish_date, price) VALUES
	('The Four Winds', 1, '02-02-2021 00:00:00', 14.99),
	('The Nightingale', 1, '02-03-2015 00:00:00', 11.99),
	('Project Hail Mary', 2, '05-04-2021 00:00:00', 14.99),
	('Artemis', 2, '11-14-2017 00:00:00', 8.99),
	('The Martian', 2, '02-11-2014 00:00:00', 8.99);
GO
