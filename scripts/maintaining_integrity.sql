ALTER TABLE inspections
ADD CONSTRAINT date_check CHECK(inspection_date <= CURRENT_DATE);

ALTER TABLE cars
ADD CONSTRAINT year_check CHECK(year_of_manufacture <= date_part('year', CURRENT_DATE));

ALTER TABLE cars
ADD CONSTRAINT unique_license_plate UNIQUE(license_plate)

ALTER TABLE details
ADD CONSTRAINT cost_check CHECK(cost > 0);

ALTER TABLE employees
ADD CONSTRAINT years_of_experience_check CHECK(years_of_experience >= 0);

ALTER TABLE repairs
ADD CONSTRAINT date_check CHECK(startDate <= endDate);
