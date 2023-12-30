

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

SELECT ActualCarKilometrage(15);

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

SELECT GetLastCarInspectionDate(12)

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

SELECT * FROM  GetCarsThatNeedInspection('3 month');


CREATE OR REPLACE FUNCTION GetTimeForEquipmentReservation
(
	workDayStart time,
	workDayEnd time,
	reservationDate date,
	equipmentID int
)
RETURNS TABLE(
	startTime time,
	endTime time
)
AS $$
DECLARE
	reservation record;
	previousTime time;
BEGIN
	previousTime := workDayStart;
	for reservation in (
		SELECT CAST(equipment_schedule.startTime AS time), CAST(equipment_schedule.endTime AS time)
		FROM equipment_schedule WHERE CAST(equipment_schedule.startTime AS date) = reservationDate 
		AND equipment_id = equipmentID) LOOP
		if reservation.startTime::time != previousTime THEN
			startTime := previousTime;
			endTime := reservation.startTime;
			RETURN NEXT;
		END IF;
		previousTime := reservation.endTime;
	END LOOP;
	
	if workDayEnd != previousTime THEN
		startTime := previousTime;
		endTime := workDayEnd;
		RETURN NEXT;
	END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION GetTimeForEmployeeReservation
(
	workDayStart time,
	workDayEnd time,
	reservationDate date,
	employeeID int
)
RETURNS TABLE(
	startTime time,
	endTime time
)
AS $$
DECLARE
	reservation record;
	previousTime time;
BEGIN
	previousTime := workDayStart;
	for reservation in (
		SELECT CAST(work_schedule.startTime AS time), CAST(work_schedule.endTime AS time)
		FROM work_schedule WHERE CAST(work_schedule.startTime AS date) = reservationDate 
		AND employee_id = employeeID) LOOP
		if reservation.startTime::time != previousTime THEN
			startTime := previousTime;
			endTime := reservation.startTime;
			RETURN NEXT;
		END IF;
		previousTime := reservation.endTime;
	END LOOP;
	
	if workDayEnd != previousTime THEN
		startTime := previousTime;
		endTime := workDayEnd;
		RETURN NEXT;
	END IF;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION GetEmployeeWorkHours
(
	fromDate date,
	toDate date,
	employeeID int
)
RETURNS int
AS $$
DECLARE
	workhours int;
BEGIN
	SELECT EXTRACT(hour FROM SUM(endTime-startTime)) as hours FROM employees 
	JOIN work_schedule ON work_schedule.employee_id = employees.id
	WHERE CAST(startTime AS date) BETWEEN fromDate AND toDate
	AND employee_id = employeeID
	INTO workhours;
	RETURN workhours;
END;
$$ LANGUAGE plpgsql;

--SELECT * FROM GetEmployeeWorkHours('2023-12-01', '2023-12-22', 15);

CREATE OR REPLACE FUNCTION CalculateEmpolyeesWorkLoad
(
	workDayStart time,
	workDayEnd time,
	fromDate date,
	toDate date
)
RETURNS TABLE(
	fullname  varchar(100),
	workload varchar(5)
)
AS $$
DECLARE
	scheduleRecord record;
	maxHours decimal;
BEGIN
	maxHours:= EXTRACT(hour FROM (toDate - fromDate) * (workDayEnd - workDayStart))/2;
	for scheduleRecord in (SELECT employees.fullname, SUM(endTime-startTime) as hours FROM employees 
						   JOIN work_schedule ON work_schedule.employee_id = employees.id
						   WHERE CAST(startTime AS date) BETWEEN fromDate AND toDate
						   GROUP BY employees.fullname
						  ) LOOP
		fullname := scheduleRecord.fullname;
		workload := CAST(ROUND((EXTRACT(hour FROM scheduleRecord.hours) / maxHours)*100, 1) AS varchar(5)) || '%';
		RETURN NEXT;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

--SELECT * FROM CalculateEmpolyeesWorkLoad('8:30', '20:00','2023-12-01', '2023-12-22');

CREATE OR REPLACE FUNCTION CountCarsByMake(brand IN varchar(25))
RETURNS int
AS $$
DECLARE
	resultCount int;
BEGIN
	SELECT COUNT(*) FROM (SELECT car_name FROM cars
	WHERE car_name like brand||'%') INTO resultCount;
	RETURN resultCount;
END;
$$ LANGUAGE plpgsql;

--SELECT CountCarsByMake('Volkswagen');


CREATE OR REPLACE PROCEDURE AddSpecificDetailToRepair(repairID IN int, detailName IN varchar(100), detailCost IN int, detailNumber IN int)
AS $$
DECLARE
	detailID int;
BEGIN
	INSERT INTO details(name, cost) VALUES(detailName, detailCost) RETURNING id INTO detailID;
	INSERT INTO repairs_details(repair_id, detail_id, number) VALUES (repairID, detailID, detailNumber);
END;
$$ LANGUAGE plpgsql;

CALL AddSpecificDetailToRepair(8, 'Dynamic TurboBoost Module', 50000, 1);

SELECT details.name FROM repairs 
JOIN repairs_details ON repair_id = repairs.id
JOIN details ON detail_id = details.id
WHERE repair_id = 8;


CREATE OR REPLACE PROCEDURE MakeReportAboutCar(carID IN int)
AS $$
DECLARE
	report text :='';
	repairRecord record;
	serviceRecord record;
	detailRecord record;
BEGIN
	FOR repairRecord IN (
		SELECT problem, repairs.id, startDate FROM repairs
		WHERE car_id = carID ORDER BY startDate DESC) LOOP
		RAISE NOTICE 'REPAIR %', repairRecord.startDate;
		RAISE NOTICE 'PROBLEM: %', repairRecord.problem;
		RAISE NOTICE 'SERVICE: ';
		for serviceRecord in (SELECT name FROM repairs_services
							  JOIN services ON service_id = services.id
							  WHERE repair_id = repairRecord.id) LOOP
			RAISE NOTICE ' %', serviceRecord.name;
		END LOOP;
		
		RAISE NOTICE 'REPLACED DETAILS:';
		for detailRecord in (SELECT name FROM repairs_details
							  JOIN details ON detail_id = details.id
							  WHERE repair_id = repairRecord.id) LOOP
			RAISE NOTICE ' %', detailRecord.name;
		END LOOP;
		RAISE NOTICE '';
	END LOOP;
	
END;
$$ LANGUAGE plpgsql;

--SELECT * FROM repairs;
--CALL MakeReportAboutCar(28);


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
--SELECT MakeReportAboutCar(8);