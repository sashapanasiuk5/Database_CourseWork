/*EATE DATABASE "CarService"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;*/
	
DROP TABLE IF EXISTS professions;
CREATE TABLE IF NOT EXISTS professions(
	id int GENERATED ALWAYS AS IDENTITY,
	name varchar(30),
	
	CONSTRAINT pk_profession_id PRIMARY KEY(id)
);


DROP TABLE IF EXISTS employees;
CREATE TABLE IF NOT EXISTS employees(
	id int GENERATED ALWAYS AS IDENTITY,
	fullname varchar(100),
	phone varchar(15),
	yearsOfEperience int,
	qualification text,
	CONSTRAINT pk_employee_id PRIMARY KEY(id)
);

DROP TABLE IF EXISTS equipments;
CREATE TABLE IF NOT EXISTS equipments(
	id int GENERATED ALWAYS AS IDENTITY,
	name varchar(100),
	CONSTRAINT pk_equipment_id PRIMARY KEY(id)
);

DROP TABLE IF EXISTS details;
CREATE TABLE IF NOT EXISTS details(
	id int GENERATED ALWAYS AS IDENTITY,
	name varchar(100),
	cost int,
	CONSTRAINT pk_detail_id PRIMARY KEY(id)
);

DROP TABLE IF EXISTS services;
CREATE TABLE IF NOT EXISTS services(
	id int GENERATED ALWAYS AS IDENTITY,
	name varchar(50),
	CONSTRAINT pk_service_id PRIMARY KEY(id)
);

DROP TABLE IF EXISTS inspections;
CREATE TABLE IF NOT EXISTS inspections(
	id int GENERATED ALWAYS AS IDENTITY,
	results text,
	kilometrage int,
	inspection_date date,
	
	CONSTRAINT pk_inspection_id PRIMARY KEY(id)
);

DROP TABLE IF EXISTS cars;
CREATE TABLE IF NOT EXISTS cars(
	id int GENERATED ALWAYS AS IDENTITY,
	car_name varchar(50),
	license_plate varchar(8),
	yearOfManufacture int,
	CONSTRAINT pk_car_id PRIMARY KEY(id)
);


DROP TABLE IF EXISTS repairs;
CREATE TABLE IF NOT EXISTS repairs(
	id int GENERATED ALWAYS AS IDENTITY,
	problem text,
	startDate date,
	endDate date,
	CONSTRAINT pk_repair_id PRIMARY KEY(id)
);


DROP TABLE IF EXISTS equipment_schedule;
CREATE TABLE IF NOT EXISTS equipment_schedule(
	id int GENERATED ALWAYS AS IDENTITY,
	startTime timestamp NOT NULL,
	endTime timestamp NOT NULL,
	CONSTRAINT pk_equipment_schedule_id PRIMARY KEY(id)
);


DROP TABLE IF EXISTS work_schedule;
CREATE TABLE IF NOT EXISTS work_schedule(
	id int GENERATED ALWAYS AS IDENTITY,
	startTime timestamp NOT NULL,
	endTime timestamp NOT NULL,
	CONSTRAINT pk_work_schedule_id PRIMARY KEY(id)
);