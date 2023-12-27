CREATE ROLE analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyst;

CREATE ROLE repair_manager;
GRANT ALL ON repairs TO repair_manager;
GRANT SELECT ON cars TO repair_manager;

CREATE ROLE car_manager;
GRANT ALL ON cars TO car_manager;

CREATE ROLE inspector;
GRANT ALL ON inspections TO inspector;
GRANT SELECT ON cars TO inspector;

CREATE ROLE planner;
GRANT ALL ON work_schedule, equipment_schedule TO planner;
GRANT SELECT ON equipments, employees, repairs TO planner;

CREATE USER analyst_1 WITH PASSWORD '1111';
GRANT analyst TO analyst_1;

CREATE USER repair_manager_1 WITH PASSWORD '2222';
GRANT repair_manager TO repair_manager_1;

CREATE USER car_manager_1 WITH PASSWORD '3333';
GRANT car_manager TO car_manager_1;

CREATE USER inspector_1 WITH PASSWORD '4444';
GRANT inspector TO inspector_1;

CREATE USER planner_1 WITH PASSWORD '5555';
GRANT planner TO planner_1;