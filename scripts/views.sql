DROP VIEW usedDetailsInThisMonth;
CREATE OR REPLACE VIEW usedDetailsInThisMonth
AS SELECT name, cost, SUM(number) as number FROM repairs JOIN repairs_details
ON repairs.id = repairs_details.repair_id
JOIN details ON details.id = repairs_details.detail_id
WHERE EXTRACT(month from startDate) = EXTRACT(month from CURRENT_DATE)
GROUP BY name, cost;
SELECT * FROM usedDetailsInThisMonth;

CREATE OR REPLACE VIEW EquipmentOperationTimeThisMonth
AS SELECT name, SUM(EXTRACT(HOUR FROM (endTime - startTime))) as hours FROM equipment JOIN equipment_schedule
ON equipment.id = equipment_schedule.equipment_id
WHERE EXTRACT(month from startTime) = EXTRACT(month from CURRENT_DATE)
GROUP BY name
ORDER BY hours DESC;

SELECT * FROM EquipmentOperationTimeThisMonth;

CREATE OR REPLACE VIEW RepairCostsInThisMonth
AS SELECT car_name, license_plate, SUM((cost*number)) as totalCost FROM cars JOIN repairs
ON car_id = cars.id
JOIN repairs_details ON repairs.id = repairs_details.repair_id
JOIN details ON details.id = detail_id
WHERE EXTRACT(month from startDate) = EXTRACT(month from CURRENT_DATE)
GROUP BY car_name, license_plate
ORDER BY totalCost DESC;

--SELECT * FROM RepairCostsInThisMonth;