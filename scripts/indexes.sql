EXPLAIN ANALYZE SELECT * FROM equipment_schedule
JOIN repairs ON repair_id = repairs.id
JOIN cars ON car_id = cars.id
WHERE startTime BETWEEN '2023-10-24 8:30' AND '2023-10-24 20:00';

CREATE INDEX startDate_index ON equipment_schedule(startTime);
DROP INDEX startDate_index

EXPLAIN ANALYZE WITH kilometrages AS(
	SELECT car_id, MAX(kilometrage) as kilometrage FROM inspections
	GROUP By car_id
)


CREATE INDEX kilometrage_index ON inspections(kilometrage);

