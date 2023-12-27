

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

--SELECT * FROM CalculateEmpolyeesWorkLoad('8:00', '20:00','2023-12-01', '2023-12-22');

CREATE OR REPLACE FUNCTION CountCarsByBrand(brand IN varchar(25))
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

--SELECT CountCarsByBrand('Mercedes-Benz');


CREATE OR REPLACE PROCEDURE AddSpecificDetailToRepair(repairID IN int, detailName IN varchar(100), detailCost IN int)
AS $$
DECLARE
	detailID int;
BEGIN
	INSERT INTO details(name, cost) VALUES(detailName, detailCost) RETURNING id INTO detailID;
	INSERT INTO repairs_details(repair_id, detail_id) VALUES (repairID, detailID);
END;
$$ LANGUAGE plpgsql;

--CALL AddSpecificDetailToRepair(5, 'Super charged twin turbo 5.0 engine RATATTATA', 200000);

CREATE OR REPLACE FUNCTION MakeReportAboutCar(carID IN int)
RETURNS text
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
		report := report || 'REPAIR ' || repairRecord.startDate ||E'\n' || 'PROBLEM: ' || repairRecord.problem;
		report := report || E'\n\nSERVICE:\n';
		for serviceRecord in (SELECT name FROM repairs_services
							  JOIN services ON service_id = services.id
							  WHERE repair_id = repairRecord.id) LOOP
			report := report || '  ' || serviceRecord.name || E'\n';
		END LOOP;
		
		report := report || E'\nREPLACED DETAILS:\n';
		for detailRecord in (SELECT name FROM repairs_details
							  JOIN details ON detail_id = details.id
							  WHERE repair_id = repairRecord.id) LOOP
			report := report || '  ' || detailRecord.name || E'\n';
		END LOOP;
		report := report || E'\n';
	END LOOP;
	RETURN report;
END;
$$ LANGUAGE plpgsql;

--SELECT MakeReportAboutCar(41);