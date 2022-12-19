CREATE TABLE genders (
	id SERIAL PRIMARY KEY,
	meaning VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE professions (
	id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE countries (
	id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL UNIQUE,
	population INT,
	ppp INT 
);

CREATE TABLE towns (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	countryid INT REFERENCES countries(id)
);

CREATE TABLE hotels (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	capacity INT NOT NULL,
	townid INT REFERENCES towns(id)
); -- constriction za kapacitet

CREATE TABLE accelerators (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE projects (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) UNIQUE NOT NULL,
	acceleratorid INT REFERENCES accelerators(id)
);

CREATE TABLE scientists (
	id SERIAL PRIMARY KEY,
	firstname VARCHAR(50) NOT NULL,
	lastname VARCHAR(50) NOT NULL,
	birthdate TIMESTAMP NOT NULL,
	genderid INT REFERENCES genders(id),
	professionid INT REFERENCES professions(id),
	countryid INT REFERENCES countries(id),
	hotelid INT REFERENCES hotels(id)
);

CREATE TABLE scientificworks (
	id SERIAL PRIMARY KEY,
	name VARCHAR(100) UNIQUE NOT NULL,
	projectid INT REFERENCES projects(id),
	timescited INT NOT NULL,
	publishdate TIMESTAMP NOT NULL
);

CREATE TABLE scientistworks (
	scientificworkid INT REFERENCES scientificworks(id),
	scientistid INT REFERENCES scientists(id),
	PRIMARY KEY(scientificworkid, scientistid)
);


drop table scientistworks
drop table scientificworks
drop table scientists
drop table projects
drop table accelerators
drop table hotels
drop table towns
drop table countries
drop table professions 
drop table genders





