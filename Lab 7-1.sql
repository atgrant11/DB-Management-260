--Andrew Grant Lab 7-1
--#6 Included

/*1. Using the ERD shown on page 1, create a script that creates the tables in 
your default tablespace. DO NOT specify a schema to keep this generic so it 
can be run in any tablespace. Make sure to consider dependencies, 
the create statements need to be in order of execution. Be sure to pay 
attention to data types and relationships, all keys need to be created. For 
primary keys, always generate them internally to the table 
(do not use an external sequence). Replace any spaces in column or 
table names with undersores.*/
CREATE TABLE Age_Groups (
    Age_Group NUMBER GENERATED AS IDENTITY PRIMARY KEY,
    Low_Age NUMBER,
    High_Age NUMBER
);

CREATE TABLE Part_Types (
    Type_Id NUMBER GENERATED AS IDENTITY PRIMARY KEY,
    Type_Name VARCHAR(12) UNIQUE
);

CREATE TABLE Colors (
    Color_Id NUMBER GENERATED AS IDENTITY PRIMARY KEY,
    Color_NAme VARCHAR(12) UNIQUE,
    HexCode CHAR(6)
);

CREATE TABLE PARTS (
    Part_Id NUMBER GENERATED AS IDENTITY PRIMARY KEY,
    Type_Id NUMBER NOT NULL,
    Color_Id NUMBER NOT NULL,
    Length NUMBER,
    Width NUMBER,
    Depth NUMBER,
    CONSTRAINT fk_parts_type
        FOREIGN KEY (Type_Id)
        REFERENCES Part_Types(Type_Id),
    CONSTRAINT fk_parts_color
        FOREIGN KEY (Color_Id)
        REFERENCES Colors(Color_Id)
);

CREATE TABLE Models (
    Model_Id NUMBER GENERATED AS IDENTITY PRIMARY KEY,
    SKU CHAR(10) UNIQUE,
    Name VARCHAR(30) UNIQUE,
    Age_Group NUMBER,
    CONSTRAINT fk_models_age
        FOREIGN KEY (Age_Group)
        REFERENCES Age_Groups(Age_Group)
);

CREATE TABLE Build_List (
    Model_Id NUMBER,
    Part_Id NUMBER,
    Quantity NUMBER,
    CONSTRAINT pk_build_list
        PRIMARY KEY (Model_Id, Part_Id),
    CONSTRAINT fk_bl_model
        FOREIGN KEY (Model_Id)
        REFERENCES Models(Model_Id),
    CONSTRAINT fk_bl_part
        FOREIGN KEY (Part_Id)
        REFERENCES Parts(Part_Id)
);
/*2. Create indexes for all foreign keys.*/
CREATE INDEX parts_part_types_ix
    ON PARTS (Type_Id);

CREATE INDEX parts_parts_color_ix
    ON PARTS (Color_Id);
    
CREATE INDEX models_models_age_ix
    ON MODELS (Age_Group);
    
CREATE INDEX build_list_model_id_ix
    ON BUILD_LIST (Model_Id);

CREATE INDEX build_list_part_id_ix
    ON BUILD_LIST (Part_Id);
/*3. Why should you add indexes for foreign keys but not for primary keys?
    Foreign keys should be indexed and primary keys shouldn't because foreign
    keys are used in joins and indexed foreign keys make the join process
    faster. They also help with updating and deleting rows. Instead of
    scanning whole tables, it will use indexes to speed up the process of
    validating the changes being made.*/
    
/*4. Is there any benefit to adding an index for the color name in the 
colors table? Why or why not?
    No because the color_id is already used as an index and it's not necessary
    to have two different indexes referencing the same thing. It's also best
    practice to not have unnecessary indexes. While this column does 
    meet the requirements for adding an index, it is redundant to include
    an index for something that already has an index.*/
    
/*5. Create insert statements to populate the tables based on the data provided 
on the next page. These statements must be in order of execution. You will 
notice there are not any primary keys, and therefore foreign keys, listed in 
the data. Primary keys will be automatically generated if you have 
created the tables correctly. To create the foreign keys, simply use a 
subquery in the insert statement to determine the key.*/
INSERT INTO age_groups (low_age, high_age) VALUES (4, 7);
INSERT INTO age_groups (low_age, high_age) VALUES (6, 12);
INSERT INTO age_groups (low_age, high_age) VALUES (10, 15);
INSERT INTO age_groups (low_age, high_age) VALUES (10, 108);

INSERT INTO part_types (type_name) VALUES ('Brick');
INSERT INTO part_types (type_name) VALUES ('Slope');
INSERT INTO part_types (type_name) VALUES ('Plate');
INSERT INTO part_types (type_name) VALUES ('Wheel');
INSERT INTO part_types (type_name) VALUES ('Stud');
INSERT INTO part_types (type_name) VALUES ('Other');

INSERT INTO colors (color_name, hexcode) VALUES ('Blue', '0000FF');
INSERT INTO colors (color_name, hexcode) VALUES ('Yellow', 'FFFF00');
INSERT INTO colors (color_name, hexcode) VALUES ('White', 'FFFFFF');
INSERT INTO colors (color_name, hexcode) VALUES ('Clear', 'F4FAFC');
INSERT INTO colors (color_name, hexcode) VALUES ('Red', 'FF0000');
INSERT INTO colors (color_name, hexcode) VALUES ('Gray', '808080');
INSERT INTO colors (color_name, hexcode) VALUES ('Black', '000000');
INSERT INTO colors (color_name, hexcode) VALUES ('Green', '00FF00');

INSERT INTO parts (type_id, color_id, length, width, depth)
    VALUES((SELECT type_id FROM part_types WHERE type_name = 'Wheel'),
        (SELECT color_id FROM colors WHERE color_name = 'Black'),
        4, NULL, NULL);
INSERT INTO parts (type_id, color_id, length, width, depth)
    VALUES((SELECT type_id FROM part_types WHERE type_name = 'Brick'),
        (SELECT color_id FROM colors WHERE color_name = 'Yellow'),
        4, 5, 3);
INSERT INTO parts (type_id, color_id, length, width, depth)
    VALUES ((SELECT type_id FROM part_types WHERE type_name = 'Plate'),
        (SELECT color_id FROM colors WHERE color_name = 'Blue'),
        5, 8, NULL);
INSERT INTO parts (type_id, color_id, length, width, depth)
    VALUES ((SELECT type_id FROM part_types WHERE type_name = 'Brick'),
        (SELECT color_id FROM colors WHERE color_name = 'Red'),
        2, 3, 1);
INSERT INTO parts (type_id, color_id, length, width, depth)
    VALUES((SELECT type_id FROM part_types WHERE type_name = 'Stud'),
        (SELECT color_id FROM colors WHERE color_name = 'Clear'),
        NULL, NULL, NULL);
INSERT INTO parts (type_id, color_id, length, width, depth)
    VALUES((SELECT type_id FROM part_types WHERE type_name = 'Brick'),
        (SELECT color_id FROM colors WHERE color_name = 'Blue'),
        1, 1, 1);
        
INSERT INTO models (sku, name, age_group)
    VALUES('SDK1234123', 'Simple Car',
        (SELECT age_group FROM age_groups WHERE low_age = 4 AND high_age = 7));
INSERT INTO models (sku, name, age_group)
    VALUES('ADK4680123', 'Light House',
        (SELECT age_group FROM age_groups WHERE low_age = 6 AND high_age = 12));
INSERT INTO models (sku, name, age_group)
    VALUES('CDF0008883', 'Boat',
        (SELECT age_group FROM age_groups WHERE low_age = 10 AND high_age = 15));
        
INSERT INTO build_list (model_id, part_id, quantity)
    VALUES((SELECT model_id FROM models WHERE sku = 'SDK1234123'),
        (SELECT p.part_id
        FROM parts p
            JOIN part_types pt
                On p.type_id = pt.type_id
            JOIN colors c
                ON p.color_id = c.color_id
        WHERE pt.type_name = 'Wheel' AND c.color_name = 'Black'), 4);
        
INSERT INTO build_list (model_id, part_id, quantity)
    VALUES((SELECT model_id FROM models WHERE sku = 'SDK1234123'),
        (SELECT p.part_id
        FROM parts p
            JOIN part_types pt
                On p.type_id = pt.type_id
            JOIN colors c
                ON p.color_id = c.color_id
        WHERE pt.type_name = 'Plate' AND c.color_name = 'Blue'), 1);
        
INSERT INTO build_list (model_id, part_id, quantity)
    VALUES((SELECT model_id FROM models WHERE sku = 'SDK1234123'),
        (SELECT p.part_id
        FROM parts p
            JOIN part_types pt
                On p.type_id = pt.type_id
            JOIN colors c
                ON p.color_id = c.color_id
        WHERE pt.type_name = 'Brick' AND c.color_name = 'Yellow'), 1);
        
INSERT INTO build_list (model_id, part_id, quantity)
    VALUES((SELECT model_id FROM models WHERE sku = 'ADK4680123'),
        (SELECT p.part_id
        FROM parts p
            JOIN part_types pt
                On p.type_id = pt.type_id
            JOIN colors c
                ON p.color_id = c.color_id
        WHERE pt.type_name = 'Stud' AND c.color_name = 'Clear'), 4);
        
INSERT INTO build_list (model_id, part_id, quantity)
   VALUES ((SELECT model_id FROM models WHERE sku = 'ADK4680123'),
        (SELECT p.part_id
        FROM parts p
            JOIN part_types pt
                On p.type_id = pt.type_id
            JOIN colors c
                ON p.color_id = c.color_id
        WHERE pt.type_name = 'Brick' AND c.color_name = 'Red'), 5);
        
INSERT INTO build_list (model_id, part_id, quantity)
    VALUES ((SELECT model_id FROM models WHERE sku = 'CDF0008883'),
        (SELECT p.part_id
        FROM parts p
            JOIN part_types pt
                On p.type_id = pt.type_id
            JOIN colors c
                ON p.color_id = c.color_id
        WHERE pt.type_name = 'Plate' AND c.color_name = 'Blue'), 2);
        
INSERT INTO build_list (model_id, part_id, quantity)
   VALUES ((SELECT model_id FROM models WHERE sku = 'CDF0008883'),
        (SELECT p.part_id
        FROM parts p
            JOIN part_types pt
                On p.type_id = pt.type_id
            JOIN colors c
                ON p.color_id = c.color_id
        WHERE pt.type_name = 'Brick' AND c.color_name = 'Red'), 6);
        
INSERT INTO build_list (model_id, part_id, quantity)
   VALUES ((SELECT model_id FROM models WHERE sku = 'CDF0008883'),
        (SELECT p.part_id
        FROM parts p
            JOIN part_types pt
                On p.type_id = pt.type_id
            JOIN colors c
                ON p.color_id = c.color_id
        WHERE pt.type_name = 'Stud' AND c.color_name = 'Clear'), 1);

/*6. Create a view that only shows the name of the models, age groups 
(formatted: low, dash, high; it should look something like this: 6 - 10), and 
the total number of parts needed for that model. Make sure that anyone who has 
access to the view, cannot change data via the view. Add aliases of your 
choosing, but make them appropriate and readable.*/
CREATE VIEW simple_car AS
    SELECT DISTINCT m.name AS "Name",
        a.low_age || '-' || a.high_age AS "Age Group",
        SUM(b.quantity) OVER (PARTITION BY b.model_id) AS "Total Parts"
    FROM models m
        JOIN age_groups a
            ON m.age_group = a.age_group
        JOIN build_list b
            ON m.model_id = b.model_id
    WHERE m.model_id = 1;

CREATE VIEW light_house AS
    SELECT DISTINCT m.name AS "Name",
        a.low_age || '-' || a.high_age AS "Age Group",
        SUM(b.quantity) OVER (PARTITION BY b.model_id) AS "Total Parts"
    FROM models m
        JOIN age_groups a
            ON m.age_group = a.age_group
        JOIN build_list b
            ON m.model_id = b.model_id
    WHERE m.model_id = 2;
    
CREATE VIEW boat AS
    SELECT DISTINCT m.name AS "Name",
        a.low_age || '-' || a.high_age AS "Age Group",
        SUM(b.quantity) OVER (PARTITION BY b.model_id) AS "Total Parts"
    FROM models m
        JOIN age_groups a
            ON m.age_group = a.age_group
        JOIN build_list b
            ON m.model_id = b.model_id
    WHERE m.model_id = 3;
/*7. In a comment block, write statements to delete all tables and indexes 
that you have created. They need to be in order of execution.*/
/*DROP INDEX build_list_part_id_ix;

DROP INDEX build_list_model_id_ix;

DROP INDEX models_models_age_ix;

DROP INDEX parts_parts_color_ix;

DROP INDEX parts_part_types_ix;

DROP TABLE build_list;

DROP TABLE models;

DROP TABLE parts;

DROP TABLE colors;

DROP TABLE part_types;

DROP TABLE age_groups;*/