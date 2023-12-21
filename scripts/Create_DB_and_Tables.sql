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

DROP TABLE IF EXISTS employees CASCADE;
CREATE TABLE IF NOT EXISTS employees(
	id int GENERATED ALWAYS AS IDENTITY,
	fullname varchar(100) NOT NULL,
	phone varchar(15) NOT NULL,
	yearsOfEperience int NOT NULL DEFAULT 0,
	qualification text,
	CONSTRAINT pk_employee_id PRIMARY KEY(id)
);


DROP TABLE IF EXISTS professions CASCADE;
CREATE TABLE IF NOT EXISTS professions(
	id int GENERATED ALWAYS AS IDENTITY,
	name varchar(30) NOT NULL,
	
	CONSTRAINT pk_profession_id PRIMARY KEY(id)
);




DROP TABLE IF EXISTS equipments CASCADE;
CREATE TABLE IF NOT EXISTS equipments(
	id int GENERATED ALWAYS AS IDENTITY,
	name varchar(100) NOT NULL,
	CONSTRAINT pk_equipment_id PRIMARY KEY(id)
);

DROP TABLE IF EXISTS details CASCADE;
CREATE TABLE IF NOT EXISTS details(
	id int GENERATED ALWAYS AS IDENTITY,
	name varchar(100) NOT NULL,
	cost int NOT NULL,
	CONSTRAINT pk_detail_id PRIMARY KEY(id)
);

DROP TABLE IF EXISTS services CASCADE;
CREATE TABLE IF NOT EXISTS services(
	id int GENERATED ALWAYS AS IDENTITY,
	name varchar(50) NOT NULL,
	CONSTRAINT pk_service_id PRIMARY KEY(id)
);

DROP TABLE IF EXISTS inspections;
CREATE TABLE IF NOT EXISTS inspections(
	id int GENERATED ALWAYS AS IDENTITY,
	results text NOT NULL,
	kilometrage int NOT NULL,
	inspection_date date NOT NULL DEFAULT CURRENT_DATE,
	
	CONSTRAINT pk_inspection_id PRIMARY KEY(id)
);

DROP TABLE IF EXISTS cars CASCADE;
CREATE TABLE IF NOT EXISTS cars(
	id int GENERATED ALWAYS AS IDENTITY,
	car_name varchar(50) NOT NULL,
	license_plate varchar(8) NOT NULL,
	yearOfManufacture int NOT NULL,
	CONSTRAINT pk_car_id PRIMARY KEY(id)
);


DROP TABLE IF EXISTS repairs CASCADE;
CREATE TABLE IF NOT EXISTS repairs(
	id int GENERATED ALWAYS AS IDENTITY,
	problem text,
	startDate date NOT NULL,
	endDate date,
	CONSTRAINT pk_repair_id PRIMARY KEY(id)
);


DROP TABLE IF EXISTS equipment_schedule CASCADE;
CREATE TABLE IF NOT EXISTS equipment_schedule(
	id int GENERATED ALWAYS AS IDENTITY,
	startTime timestamp NOT NULL,
	endTime timestamp NOT NULL,
	CONSTRAINT pk_equipment_schedule_id PRIMARY KEY(id)
);


DROP TABLE IF EXISTS work_schedule CASCADE;
CREATE TABLE IF NOT EXISTS work_schedule(
	id int GENERATED ALWAYS AS IDENTITY,
	startTime timestamp NOT NULL,
	endTime timestamp NOT NULL,
	CONSTRAINT pk_work_schedule_id PRIMARY KEY(id)
);

DROP TABLE IF EXISTS repairs_details CASCADE;
CREATE TABLE IF NOT EXISTS repairs_details(
	id int GENERATED ALWAYS AS IDENTITY,
	repair_id int NOT NULL REFERENCES repairs(id),
	detail_id int NOT NULL REFERENCES details(id),
	CONSTRAINT pk_repairs_details_id PRIMARY KEY(id)
);


DROP TABLE IF EXISTS repairs_services CASCADE;
CREATE TABLE IF NOT EXISTS repairs_services(
	id int GENERATED ALWAYS AS IDENTITY,
	repair_id int NOT NULL REFERENCES repairs(id),
	service_id int NOT NULL REFERENCES services(id),
	CONSTRAINT pk_repairs_services_id PRIMARY KEY(id)
);


ALTER TABLE employees
ADD COLUMN profession_id int NOT NULL REFERENCES professions(id); 

ALTER TABLE inspections
ADD COLUMN car_id int NOT NULL REFERENCES cars(id); 

ALTER TABLE equipment_schedule
ADD COLUMN equipment_id int NOT NULL REFERENCES equipments(id);

ALTER TABLE equipment_schedule
ADD COLUMN repair_id int NOT NULL REFERENCES repairs(id);

ALTER TABLE work_schedule
ADD COLUMN repair_id int NOT NULL REFERENCES repairs(id);

ALTER TABLE work_schedule
ADD COLUMN employee_id int NOT NULL REFERENCES employees(id);

ALTER TABLE repairs
ADD COLUMN car_id int NOT NULL REFERENCES cars(id);
