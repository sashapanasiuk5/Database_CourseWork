DROP USER planner_1;
DROP USER analyst_1;
DROP USER repair_manager_1;
DROP USER inspector_1;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM analyst;
DROP ROLE IF EXISTS analyst;
CREATE ROLE analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyst;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM repair_manager;
DROP ROLE IF EXISTS repair_manager;
CREATE ROLE repair_manager;
GRANT ALL ON repairs TO repair_manager;
GRANT SELECT ON cars TO repair_manager;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM inspector;
DROP ROLE IF EXISTS inspector;
CREATE ROLE inspector;
GRANT ALL ON inspections TO inspector;
GRANT SELECT ON cars TO inspector;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM planner;
DROP ROLE IF EXISTS planner;
CREATE ROLE planner;
GRANT ALL ON work_schedule, equipment_schedule TO planner;
GRANT SELECT ON equipment, employees, repairs TO planner;

CREATE USER analyst_1 WITH PASSWORD '1111';
GRANT analyst TO analyst_1;

CREATE USER repair_manager_1 WITH PASSWORD '2222';
GRANT repair_manager TO repair_manager_1;

CREATE USER inspector_1 WITH PASSWORD '4444';
GRANT inspector TO inspector_1;

CREATE USER planner_1 WITH PASSWORD '5555';
GRANT planner TO planner_1;