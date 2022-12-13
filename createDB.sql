CREATE TABLE gender (
	id SERIAL PRIMARY KEY
	meaning VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE profession (
	id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE country (
	id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL UNIQUE,
	population INT,
	ppp DOUBLE 
);

CREATE TABLE town (
	id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL,
	countryid INT REFERENCES country(id)
);

CREATE TABLE hotel (
	id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL,
	capacity INT NOT NULL,
	townid INT REFERENCES town(id)
);

CREATE TABLE accelerator (
	id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE project (
	id SERIAL PRIMARY KEY,
	name VARCHAR(30),
	acceleratorid INT REFERENCES accelerator(id)
);

CREATE TABLE scientist (
	id SERIAL PRIMARY KEY,
	firstname VARCHAR(30) NOT NULL,
	lastname VARCHAR(30) NOT NULL,
	genderid INT REFERENCES gender(id),
	professionid INT REFERENCES profession(id),
	countryid INT REFERENCES country(id),
	hotelid INT REFERENCES hotel(id)
);

CREATE TABLE scientificwork (
	id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL,
	projectid INT REFERENCES project(id),
	timescited INT NOT NULL,
	publishdate TIMESTAMP NOT NULL
);

CREATE TABLE scientistwork (
	scientificworkid INT REFERENCES scientificwork(id),
	scientistid INT REFERENCES scientist(id),
	PRIMARY KEY(scientificworkid, scientistid)
);








