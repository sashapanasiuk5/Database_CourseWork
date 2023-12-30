CREATE OR REPLACE TRIGGER deleteCar
BEFORE DELETE On cars
FOR EACH ROW EXECUTE FUNCTION deleteCar();


CREATE OR REPLACE FUNCTION deleteCar()
RETURNS trigger
AS $$
BEGIN
	DELETE FROM repairs WHERE car_id = OLD.id;
	DELETE FROM inspections WHERE car_id = OLD.id;
	RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DELETE FROM cars WHERE id = 15;

SELECT * FROM cars;
SELECT * FROM repairs WHERE car_id = 15;
SELECT * FROM inspections WHERE car_id = 15;

CREATE OR REPLACE FUNCTION checkRepair()
RETURNS trigger
AS $$
DECLARE
	carID integer;
BEGIN
	carID := NEW.car_id;
	IF EXISTS( SELECT * FROM repairs WHERE car_id = carID AND endDate IS NULL) THEN
		RETURN NULL;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE TRIGGER checkRepair
BEFORE INSERT ON repairs
FOR EACH ROW EXECUTE FUNCTION checkRepair();

INSERT INTO repairs(problem, startdate, car_id) VALUES('Engine overheating', '2023-12-05', 113);
SELECT * FROM repairs WHERE endDate IS NULL;

CREATE OR REPLACE FUNCTION checkLicensePlate() RETURNS trigger
AS $$
DECLARE
	regionCode char(2);
	series char(2);
	numbers int;
BEGIN
	regionCode := substring(new.license_plate, 1,2);
	series := substring(new.license_plate, 7, 2);
	BEGIN
		numbers := substring(new.license_plate, 3,4)::int;
		EXCEPTION WHEN invalid_text_representation THEN RETURN NULL;
	END;
	
	IF regionCode IN ('AA', 'AB', 'AC', 'AE', 'AH', 'AI' ,'AM', 'AO', 'AP', 'АT',
					 'AX', 'BA', 'BB', 'BC', 'BE', 'BH', 'BI', 'BM', 'BO', 'BP', 'BT', 'BX',
					 'CA', 'CB', 'CE') THEN
		IF series ~ '[A-Z]{2}' THEN RETURN NEW;
		END IF;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE TRIGGER checkLicensePlateBeforeAddition
BEFORE INSERT ON cars
FOR EACH ROW EXECUTE FUNCTION checkLicensePlate();

INSERT INTO cars(car_name, license_plate, year_of_manufacture)
VALUES ('Volkswagen Passat', 'GF54d5GD', 2009);

CREATE OR REPLACE TRIGGER checkLicensePlateBeforeUpdating
BEFORE UPDATE ON cars
FOR EACH ROW EXECUTE FUNCTION checkLicensePlate();

UPDATE cars SET license_plate = '34АААА45' WHERE id = 15;
VALUES ('Volkswagen Passat', 'GF54d5GD', 2009);

CREATE OR REPLACE FUNCTION checkKilometrage()
RETURNS trigger
AS $$
DECLARE
	lowerBound int;
	upperBound int;
BEGIN
	SELECT kilometrage FROM inspections
	WHERE car_id = new.car_id AND inspection_date < new.inspection_date
	ORDER BY inspection_date DESC LIMIT 1 INTO lowerBound;
	
	SELECT kilometrage FROM inspections
	WHERE car_id = new.car_id AND inspection_date > new.inspection_date
	ORDER BY inspection_date DESC LIMIT 1 INTO upperBound;

	IF lowerBound IS NULL THEN
		IF new.kilometrage <= upperBound THEN
			RETURN new;
		END IF;
	ELSEIF upperBound IS NULL THEN
		IF new.kilometrage >= lowerBound THEN
			RETURN new;
		END IF;
	ELSE
		IF new.kilometrage >= lowerBound AND new.kilometrage <= upperBound THEN
			RETURN new;
		END IF;
	END IF;
	
	RETURN null;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER checkKilometrageBeforeUpdating
BEFORE UPDATE ON inspections
FOR EACH ROW EXECUTE FUNCTION checkKilometrage();

--SELECT * FROM inspections WHERE car_id = 75;
--UPDATE inspections SET kilometrage = 200000 WHERE id = 13;

CREATE OR REPLACE TRIGGER checkKilometrageBeforeInserting
BEFORE INSERT ON inspections
FOR EACH ROW EXECUTE FUNCTION checkKilometrage();

INSERT INTO inspections(results, kilometrage, inspection_date, car_id)
VALUES('Test', 100000, '2023-12-15', 75);

CREATE OR REPLACE FUNCTION СheckReservationTimeForEquipment()
RETURNS trigger
AS $$
BEGIN
	IF (new.startTime < new.endTime) AND CanReservateEquipment(new.startTime, new.endTime, new.equipment_id) THEN
		RETURN new;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TryReservateEquipment
BEFORE INSERT ON equipment_schedule
FOR EACH ROW EXECUTE FUNCTION СheckReservationTimeForEquipment();


SELECT * FROM equipment_schedule WHERE equipment_id = 7;
INSERT INTO equipment_schedule(startTime, endTime, equipment_id, repair_id)
VALUES('2023-09-01 12:00', '2023-09-01 14:30', 7, 23);


CREATE OR REPLACE TRIGGER UpdateReservationTimeForEquipment
BEFORE UPDATE ON equipment_schedule
FOR EACH ROW EXECUTE FUNCTION СheckReservationTimeForEquipment();

UPDATE equipment_schedule SET endTime = '2023-09-01 20:00' WHERE id = 10;

CREATE OR REPLACE FUNCTION СheckReservationTimeForEmployee()
RETURNS trigger
AS $$
BEGIN
	IF (new.startTime < new.endTime) AND CanReservateEmployee(new.startTime, new.endTime, new.employee_id) THEN
		RETURN new;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER TryReservateEmployee
BEFORE INSERT ON work_schedule
FOR EACH ROW EXECUTE FUNCTION СheckReservationTimeForEmployee();

SELECT * FROM work_schedule;
INSERT INTO work_schedule(startTime, endTime, repair_id, employee_id)
VALUES('2023-12-07 15:00', '2023-12-07 18:00', 25, 5);

CREATE OR REPLACE TRIGGER UpdateReservationTimeForEmployee
BEFORE UPDATE ON work_schedule
FOR EACH ROW EXECUTE FUNCTION СheckReservationTimeForEmployee();


UPDATE work_schedule SET endTime = '2023-12-07 15:00' WHERE id = 5;