CREATE OR REPLACE FUNCTION ActualCarKilometrage(carID IN integer)
RETURNS int
AS $$
DECLARE
	actualKilometrage int;
BEGIN
	SELECT kilometrage
	FROM inspections WHERE car_id = carID
	ORDER BY inspection_date DESC LIMIT 1
	INTO actualKilometrage;
	RETURN actualKilometrage;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION GetLastCarInspectionDate(carID IN integer)
RETURNS date
AS $$
DECLARE
	lastInspectionDate date;
BEGIN
	SELECT inspection_date FROM inspections
	WHERE car_id = carID ORDER BY inspection_date DESC
	LIMIT 1 INTO lastInspectionDate;
	RETURN lastInspectionDate;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetCarsThatNeedInspection(timeSpan IN interval)
RETURNS TABLE(
	car_name varchar(50),
	license_plate varchar(8),
	time_since_last_inspection interval
)
AS $$
DECLARE
	carRecord record;
	last_inspection_date timestamp;
	
BEGIN
	for carRecord in (SELECT id,cars.car_name, cars.license_plate FROM cars) LOOP
		last_inspection_date := GetLastCarInspectionDate(carRecord.id);
		time_since_last_inspection := age(CURRENT_DATE, last_inspection_date);
		if  time_since_last_inspection >= timeSpan THEN
			car_name := carRecord.car_name;
			license_plate := carRecord.license_plate;
			RETURN NEXT;
		END IF;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT car_name,license_plate,time_since_last_inspection FROM  GetCarsThatNeedInspection('3 month');


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