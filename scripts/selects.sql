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

