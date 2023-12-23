CREATE OR REPLACE VIEW usedDetailsInThisMonth
AS SELECT name, cost, number FROM repairs JOIN repairs_details
ON repairs.id = repairs_details.repair_id
JOIN details ON details.id = repairs_details.detail_id
WHERE EXTRACT(month from startDate) = EXTRACT(month from CURRENT_DATE); 

--SELECT * FROM usedDetailsInThisMonth;

CREATE OR REPLACE VIEW EquipmentOperationTimeThisMonth
AS SELECT name, SUM(EXTRACT(HOUR FROM (endTime - startTime))) as hours FROM equipments JOIN equipment_schedule
ON equipments.id = equipment_schedule.equipment_id
WHERE EXTRACT(month from startTime) = EXTRACT(month from CURRENT_DATE)
GROUP BY name;

--SELECT * FROM EquipmentOperationTimeThisMonth;

CREATE OR REPLACE VIEW RepairCostsInThisMonth
AS SELECT car_name, license_plate, SUM((cost*number)) as totalCost FROM cars JOIN repairs
ON car_id = cars.id
JOIN repairs_details ON repairs.id = repairs_details.repair_id
JOIN details ON details.id = detail_id
WHERE EXTRACT(month from startDate) = EXTRACT(month from CURRENT_DATE)
GROUP BY car_name, license_plate;

--SELECT * FROM RepairCostsInThisMonth;