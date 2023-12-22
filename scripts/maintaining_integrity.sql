ALTER TABLE inspections
ADD CONSTRAINT date_check CHECK(inspection_date <= CURRENT_DATE);

ALTER TABLE inspections
ADD CONSTRAINT kilometrage_check CHECK(kilometrage >= ActualCarKilometrage(car_id));

ALTER TABLE cars
ADD CONSTRAINT year_check CHECK(year_of_manufacture <= date_part('year', CURRENT_DATE));

ALTER TABLE details
ADD CONSTRAINT cost_check CHECK(cost > 0);

ALTER TABLE employees
ADD CONSTRAINT years_of_experience_check CHECK(years_of_experience >= 0);

ALTER TABLE repairs
ADD CONSTRAINT date_check CHECK(startDate <= endDate);

ALTER TABLE equipment_schedule
ADD CONSTRAINT time_check CHECK(startTime < endTime);

ALTER TABLE work_schedule
ADD CONSTRAINT time_check CHECK(startTime < endTime);
