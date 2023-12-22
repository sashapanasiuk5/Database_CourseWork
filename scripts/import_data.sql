TRUNCATE employees RESTART IDENTITY CASCADE;
TRUNCATE professions RESTART IDENTITY CASCADE;
TRUNCATE equipment_types RESTART IDENTITY CASCADE;
TRUNCATE equipments RESTART IDENTITY CASCADE;
TRUNCATE cars RESTART IDENTITY CASCADE;
TRUNCATE services RESTART IDENTITY CASCADE;
TRUNCATE details RESTART IDENTITY CASCADE;
TRUNCATE repairs RESTART IDENTITY CASCADE;
TRUNCATE inspections RESTART IDENTITY CASCADE;
TRUNCATE equipment_schedule RESTART IDENTITY CASCADE;

COPY professions(name) FROM 'C:\Users\hitec\OneDrive\Documents\Database_CourseWork\import_data\professions.csv' (
	FORMAT CSV,
	DELIMITER ';',
	ENCODING 'UTF-8'
);

COPY employees(fullname, phone, yearsOfExperience,profession_id) FROM 'C:\Users\hitec\OneDrive\Documents\Database_CourseWork\import_data\employees.csv' (
	FORMAT CSV,
	DELIMITER ',',
	ENCODING 'UTF-8'
);


COPY equipment_types(name) FROM 'C:\Users\hitec\OneDrive\Documents\Database_CourseWork\import_data\equipment_types.csv' (
	FORMAT CSV,
	DELIMITER ',',
	ENCODING 'UTF-8'
);

COPY equipments(name, type_id) FROM 'C:\Users\hitec\OneDrive\Documents\Database_CourseWork\import_data\equipments.csv' (
	FORMAT CSV,
	DELIMITER ',',
	ENCODING 'UTF-8'
);

COPY cars(car_name, license_plate, yearOfManufacture) FROM 'C:\Users\hitec\OneDrive\Documents\Database_CourseWork\import_data\cars.csv'(
	FORMAT CSV,
	DELIMITER ',',
	ENCODING 'UTF-8'
);

COPY services(name) FROM 'C:\Users\hitec\OneDrive\Documents\Database_CourseWork\import_data\services.csv'(
	FORMAT CSV,
	DELIMITER ',',
	ENCODING 'UTF-8'
);

COPY repairs(problem, startdate, enddate, car_id) FROM 'C:\Users\hitec\OneDrive\Documents\Database_CourseWork\import_data\repairs.csv'(
	FORMAT CSV,
	DELIMITER ';',
	ENCODING 'UTF-8'
);

COPY details(name, cost) FROM 'C:\Users\hitec\OneDrive\Documents\Database_CourseWork\import_data\details.csv'(
	FORMAT CSV,
	DELIMITER ',',
	ENCODING 'UTF-8'
);


INSERT INTO inspections(results, kilometrage, inspection_date, car_id) VALUES
('Engine: Ok, Tires: Normal, Transmission: Ok, Test-drive: Passed', 150250, '2023-09-03', 5),
('Engine: Ok, Tires: worn left rear tire, Transmission: Normal, Test-drive: didn`t pass', 121345, '2022-11-14', 10),
('Engine: Ok, Tires: Good, Transmission: Clutch slips, Test-drive: didn`t pass', 521000, '2022-10-03', 5),
('Engine: Unstable work, Tires: All tires worn, Transmission: Good, Test-drive: didn`t pass', 150250, '2022-10-21', 45),
('Engine: Ok, Tires: normal, Transmission: Ok, Test-drive: Passed', 134950, '2022-09-09', 12),
('Engine: Ok, Tires: normal, Transmission: Ok, Test-drive: Passed', 105678, '2022-10-15', 15),
('Engine: Ok, Tires: normal, Transmission: Reverse gear does not work, Test-drive: didn`t pass', 200356, '2022-09-20', 7),
('Engine: Unstable work, Tires: Good, Transmission: Ok, Test-drive: didn`t pass', 199526, '2023-09-03', 56),
('Engine: Ok, Tires: normal, Transmission: Ok, Test-drive: Passed', 82366, '2022-11-07', 12),
('Engine: Ok, Tires: All tires worn, Transmission: Ok, Test-drive: didn`t pass', 100856, '2022-10-09', 10),
('Engine: Unstable work, Tires: normal, Transmission: Ok, Test-drive: Passed', 163345, '2022-09-12', 45),
('Engine: Ok, Tires: normal, Transmission: Ok, Test-drive: Passed', 124567, '2022-08-26', 75),
('Engine: high fuel consumption, Tires: Good, Transmission: Ok, Test-drive: didn`t pass', 77569, '2023-11-30', 123),
('Engine: Ok, Tires: normal, Transmission: Ok, Test-drive: Passed', 82361, '2022-11-02', 7),
('Engine: Ok, Tires: worn right rear tire, Transmission: Ok, Test-drive: didn`t pass', 95360, '2023-11-25', 41),
('Engine: Ok, Tires: Good, Transmission: Ok, Test-drive: Passed', 117260, '2022-09-05', 26),
('Engine: Ok, Tires: Good, Transmission: second gear does not work, Test-drive: didn`t pass', 146890, '2022-09-17', 13),
('Engine: Unstable work, Tires: normal, Transmission: Ok, Test-drive: didn`t pass', 137269, '2022-09-01', 75),
('Engine: Ok, Tires: Good, Transmission: Gear shifting issues, Test-drive: didn`t pass', 120000, '2023-02-28', 2),
('Engine: Ok, Tires: Good, Transmission: Leaks observed, Test-drive: didn`t pass', 142000, '2023-04-20', 75);


COPY repairs_details(detail_id, repair_id) FROM 'C:\Users\hitec\OneDrive\Documents\Database_CourseWork\import_data\repairs_details.csv'(
	FORMAT CSV,
	DELIMITER ',',
	ENCODING 'UTF-8'
);

COPY repairs_services(service_id, repair_id) FROM 'C:\Users\hitec\OneDrive\Documents\Database_CourseWork\import_data\repairs_services.csv'(
	FORMAT CSV,
	DELIMITER ',',
	ENCODING 'UTF-8'
);


COPY equipment_schedule(starttime, endtime, equipment_id, repair_id) FROM 'C:\Users\hitec\OneDrive\Documents\Database_CourseWork\import_data\equipment_schedule.csv'(
	FORMAT CSV,
	DELIMITER ',',
	ENCODING 'UTF-8'
);

COPY work_schedule(starttime, endtime, employee_id, repair_id) FROM 'C:\Users\hitec\OneDrive\Documents\Database_CourseWork\import_data\work_schedule.csv'(
	FORMAT CSV,
	DELIMITER ',',
	ENCODING 'UTF-8'
);
