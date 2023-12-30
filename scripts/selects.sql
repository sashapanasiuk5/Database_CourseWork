-- Машини, що найчастіше ремонтувались
WITH numberOfRepairs AS(
	SELECT car_name, license_plate, COUNT(*) as num
	FROM cars JOIN repairs ON cars.id =car_id
	GROUP BY car_name, license_plate
)
SELECT car_name, license_plate, num FROM numberOfRepairs WHERE num = (SELECT MAX(num)FROM numberOfRepairs);

--Машини, що в данний момент ремонтуються
SELECT car_name, license_plate FROM cars, (SELECT car_id FROM repairs WHERE endDate IS NULL)
WHERE cars.id = car_id;

-- Деталі, що були замінені у автомобілях 
SELECT car_name, license_plate, details.name, startDate as date FROM cars
JOIN repairs ON car_id = cars.id
JOIN repairs_details ON repair_id = repairs.id
JOIN details ON detail_id = details.id
ORDER BY license_plate;

--Обслуговування, що було зроблене для автомобіля
SELECT car_name, license_plate, services.name,  startDate as date FROM cars
JOIN repairs ON car_id = cars.id
JOIN repairs_services ON repair_id = repairs.id
JOIN services ON service_id = services.id
ORDER BY license_plate;

--План роботи працівників на сьогодні
SELECT fullname,car_name, license_plate, problem, startTime, endTime  FROM work_schedule
JOIN employees ON employee_id = employees.id
JOIN repairs ON repair_id = repairs.id
JOIN cars ON car_id = cars.id
WHERE DATE(startTime) = CURRENT_DATE
ORDER BY startTime;

--Розклад роботи обладнання на сьогодні
SELECT name, car_name, license_plate, startTime, endTime  FROM equipment_schedule
JOIN equipment ON equipment_id = equipment.id
JOIN repairs ON repair_id = repairs.id
JOIN cars ON car_id = cars.id
WHERE DATE(startTime) = CURRENT_DATE
ORDER BY startTime;

--Автомобіль з найбільшим пробігом
SELECT car_name, license_plate, kilometrage FROM cars JOIN inspections
ON car_id = cars.id
WHERE kilometrage = (
	SELECT MAX(kilometrage) FROM cars JOIN inspections
	ON car_id = cars.id
);

-- Працівники та їх спеціальності
SELECT fullname, professions.name FROM employees
JOIN professions ON profession_id = professions.id;

-- Працівники та ремонти, які вони робили
SELECT car_name, problem, fullname, startTime, endTime FROM employees
JOIN work_schedule ON employee_id = employees.id
JOIN repairs ON repair_id = repairs.id
JOIN cars ON car_id = cars.id;

-- Тип обладнання, що найчастіше використовувався
WITH numberOfEquipmentUsage AS(
	SELECT equipment_types.name, COUNT(*) FROM equipment_types
	JOIN equipments ON type_id = equipment_types.id
	JOIN equipment_schedule ON equipment_id = equipments.id
	GROUP BY equipment_types.name
)
SELECT name, count FROM numberOfEquipmentUsage WHERE count = (SELECT MAX(count) FROM numberOfEquipmentUsage);


-- Cередня ціна деталей для ремонту
WITH detailsCost AS (
	SELECT problem, SUM(cost*number) as cost FROM repairs
	JOIN repairs_details ON repair_id = repairs.id
	JOIN details ON detail_id = details.id
	GROUP BY problem
)
SELECT AVG(cost) as AverageCost FROM detailsCost;

-- Середній інтервал між технічними оглядами
SELECT avg(interval) as averageInterval FROM (
	SELECT age(f.inspection_date, s.inspection_date) as interval 
	FROM inspections f, inspections s WHERE f.car_id = s.car_id
	AND f.inspection_date > s.inspection_date
);

--Тех огляди автомобіля що має найбільший пробіг.
SELECT car_name, results, kilometrage, inspection_date
FROM inspections JOIN cars ON car_id = cars.id
WHERE car_id =(
SELECT car_id FROM inspections
	WHERE kilometrage = (
		SELECT MAX(kilometrage) FROM inspections
	)
) 

-- робітник, що відпрацював найбільше годин в цьому місяці
SELECT fullname, EXTRACT(hour FROM SUM(endTime - startTime)) as hours FROM employees
JOIN work_schedule ON employee_id = employees.id
WHERE EXTRACT(month from startTime) = EXTRACT(month from CURRENT_DATE)
GROUP BY fullname
ORDER BY hours DESC LIMIT 1;


-- Запит, що виводить день тижня в який найчастіше реєструвались нові ремонти
WITH countOfRepairsByDay AS (
	SELECT to_char(startDate::date, 'Day') as dow, COUNT(to_char(startDate::date, 'Day')) as count FROM repairs
	GROUP BY dow
)
SELECT * FROM countOfRepairsByDay WHERE count = (SELECT MAX(count) FROM countOfRepairsByDay)

-- Середня тривалість ремонту машини
SELECT car_name, license_plate, ROUND(AVG(EXTRACT(day FROM age(endDate, startDate))),3) as Duration FROM cars 
JOIN repairs ON car_id = cars.id
GROUP BY car_name,license_plate ORDER BY Duration

--Машини у яких  були проблеми з двигуном
SELECT car_name, license_plate, problem FROM cars
JOIN repairs ON car_id = cars.id
WHERE problem ilike '%engine%';


-- Середній пробіг машин за роками випуску
WITH kilometrages AS(
	SELECT car_id, MAX(kilometrage) as kilometrage FROM inspections
	GROUP By car_id
)
SELECT year_of_manufacture, ROUND(AVG(kilometrages.kilometrage),3) as kilometrage FROM cars
JOIN kilometrages ON car_id = cars.id
GROUP BY year_of_manufacture
ORDER BY year_of_manufacture


-- Витрати на деталі по місяцях
SELECT EXTRACT(MONTH FROM startDate) AS monthNum, to_char(startDate, 'Month'), SUM(cost*number) FROM repairs
JOIN repairs_details ON repair_id = repairs.id
JOIN details ON detail_id = details.id
GROUP BY to_char(startDate, 'Month'), monthNum
ORDER BY monthNum

-- Обслуговування, що робилося найчастіше в цьому місяці

SELECT name, COUNT(*) FROM repairs
JOIN repairs_services ON repair_id = repairs.id
JOIN services ON service_id = services.id
WHERE EXTRACT(month from startDate) = EXTRACT(month from current_date)
GROUP BY name ORDER BY count DESC
LIMIT 1;