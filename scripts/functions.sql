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
