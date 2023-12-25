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

CREATE OR REPLACE TRIGGER addRepair
BEFORE INSERT ON repairs
FOR EACH ROW EXECUTE FUNCTION checkRepair();

INSERT INTO repairs(problem, startdate, car_id) VALUES('big problem', '2023-12-05', 93)
SELECT * FROM repairs WHERE car_id = 93;

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

CREATE OR REPLACE TRIGGER addCar
BEFORE INSERT ON cars
FOR EACH ROW EXECUTE FUNCTION checkLicensePlate();



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

CREATE OR REPLACE TRIGGER updateKilometrage
BEFORE UPDATE ON inspections
FOR EACH ROW EXECUTE FUNCTION checkKilometrage();



CREATE OR REPLACE FUNCTION CanReservateEquipment(newStartTime IN timestamp, newEndTime IN timestamp, equipmentID in integer)
RETURNS bool
AS $$
DECLARE
	reservationDate date;
	reservation record;
	canReservate bool := true;
BEGIN
	reservationDate := CAST(newStartTime AS date);
	for reservation in (
		SELECT equipment_schedule.startTime, equipment_schedule.endTime FROM equipment_schedule 
		WHERE CAST(startTime AS date) = reservationDate AND equipment_id = equipmentID
	) LOOP
		if (reservation.startTime, reservation.endTime) OVERLAPS (newStartTime, newEndTime) THEN
			canReservate := false;
		END IF;
	END LOOP;
	RETURN canReservate;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION CanReservateEmployee(newStartTime IN timestamp, newEndTime IN timestamp, employeeID in integer)
RETURNS bool
AS $$
DECLARE
	reservationDate date;
	reservation record;
	canReservate bool := true;
BEGIN
	reservationDate := CAST(newStartTime AS date);
	for reservation in (
		SELECT work_schedule.startTime, work_schedule.endTime FROM work_schedule 
		WHERE CAST(startTime AS date) = reservationDate AND employee_id = employeeID
	) LOOP
		if (reservation.startTime, reservation.endTime) OVERLAPS (newStartTime, newEndTime) THEN
			canReservate := false;
		END IF;
	END LOOP;
	RETURN canReservate;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION TryReservateEquipment()
RETURNS trigger
AS $$
BEGIN
	IF (new.startTime < new.endTime) AND CanReservateEquipment(new.startTime, new.endTime, new.equipment_id) THEN
		RETURN new;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER reservateEquipment
BEFORE INSERT ON equipment_schedule
FOR EACH ROW EXECUTE FUNCTION TryReservateEquipment();

CREATE OR REPLACE TRIGGER UpdateReservationEquipment
BEFORE UPDATE ON equipment_schedule
FOR EACH ROW EXECUTE FUNCTION TryReservateEquipment();


CREATE OR REPLACE FUNCTION TryReservateEmployee()
RETURNS trigger
AS $$
BEGIN
	IF (new.startTime < new.endTime) AND CanReservateEmployee(new.startTime, new.endTime, new.employee_id) THEN
		RETURN new;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER reservateEmployee
BEFORE INSERT ON work_schedule
FOR EACH ROW EXECUTE FUNCTION TryReservateEmployee();

CREATE OR REPLACE TRIGGER UpdateReservationEmployee
BEFORE UPDATE ON work_schedule
FOR EACH ROW EXECUTE FUNCTION TryReservateEmployee();


