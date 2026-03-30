--Andrew Grant Lab 7

/*1. Using the ERD shown on page 1, create a script that creates the tables in 
your default tablespace. DO NOT specify a schema to keep this generic so it 
can be run in any tablespace. Make sure to consider dependencies, 
the create statements need to be in order of execution. Be sure to pay 
attention to data types and relationships, all keys need to be created. For 
primary keys, always generate them internally to the table 
(do not use an external sequence). Replace any spaces in column or 
table names with undersores.*/
CREATE TABLE Age_Groups (
    Age_Group NUMBER PRIMARY KEY,
    Low_Age NUMBER,
    High_Age NUMBER
);

CREATE TABLE Part_Types (
    Type_Id NUMBER PRIMARY KEY,
    Type_Name VARCHAR(12) UNIQUE
);

CREATE TABLE Colors (
    Color_Id NUMBER PRIMARY KEY,
    Color_NAme VARCHAR(12) UNIQUE,
    HexCode CHAR(6)
);

CREATE TABLE PARTS (
    Part_Id NUMBER PRIMARY KEY,
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
    Model_Id NUMBER PRIMARY KEY,
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
    practice to not have unnecessary indexes.*/
    
/*5. Create insert statements to populate the tables based on the data provided 
on the next page. These statements must be in order of execution. You will 
notice there are not any primary keys, and therefore foreign keys, listed in 
the data. Primary keys will be automatically generated if you have 
created the tables correctly. To create the foreign keys, simply use a 
subquery in the insert statement to determine the key.*/
INSERT INTO Age_Groups (age_group, low_age, high_age)
    SELECT 1, 4, 7 FROM dual
        UNION ALL
    SELECT 2, 6, 12 FROM dual
        UNION ALL
    SELECT 3, 10, 15 FROM dual
        UNION ALL
    SELECT 4, 10, 108 FROM dual;
    
INSERT INTO Part_Types (type_id, type_name)
    SELECT 1, 'Brick' FROM dual
        UNION ALL
    SELECT 2, 'Slope' FROM dual
        UNION ALL
    SELECT 3, 'Plate' FROM dual
        UNION ALL
    SELECT 4, 'Wheel' FROM dual
        UNION ALL
    SELECT 5, 'Stud' FROM dual
        UNION ALL
    SELECT 6, 'Other' FROM dual;

INSERT INTO Colors (color_id, color_name, hexcode)
    SELECT 1, 'Blue', '0000FF' FROM dual
        UNION ALL
    SELECT 2, 'Yellow', 'FFFF00' FROM dual
        UNION ALL
    SELECT 3, 'White', 'FFFFFF' FROM dual
        UNION ALL
    SELECT 4, 'Clear', 'F4FAFC' FROM dual
        UNION ALL
    SELECT 5, 'Red', 'FF0000' FROM dual
        UNION ALL
    SELECT 6, 'Gray', '808080' FROM dual
        UNION ALL
    SELECT 7, 'Black', '000000' FROM dual
        UNION ALL
    SELECT 8, 'Green', '00FF00' FROM dual;
    
INSERT INTO Parts (part_id, type_id, color_id, length, width, depth)
    SELECT 1, 
        (SELECT type_id FROM part_types WHERE type_name = 'Wheel'),
        (SELECT color_id FROM colors WHERE color_name = 'Black'),
        4, NULL, NULL
    FROM dual
        UNION ALL
    SELECT 2, 
        (SELECT type_id FROM part_types WHERE type_name = 'Brick'),
        (SELECT color_id FROM colors WHERE color_name = 'Yellow'),
        4, 5, 3
    FROM dual
        UNION ALL
    SELECT 3, 
        (SELECT type_id FROM part_types WHERE type_name = 'Plate'),
        (SELECT color_id FROM colors WHERE color_name = 'Blue'),
        5, 8, NULL
    FROM dual
        UNION ALL
    SELECT 4, 
        (SELECT type_id FROM part_types WHERE type_name = 'Brick'),
        (SELECT color_id FROM colors WHERE color_name = 'Red'),
        2, 3, 1
    FROM dual
        UNION ALL
    SELECT 5, 
        (SELECT type_id FROM part_types WHERE type_name = 'Stud'),
        (SELECT color_id FROM colors WHERE color_name = 'Clear'),
        NULL, NULL, NULL
    FROM dual
        UNION ALL
    SELECT 6, 
        (SELECT type_id FROM part_types WHERE type_name = 'Brick'),
        (SELECT color_id FROM colors WHERE color_name = 'Blue'),
        1, 1, 1
    FROM dual;
    
INSERT INTO Models (model_id, sku, name, age_group)
    SELECT 1, 'SDK1234123', 'Simple Car',
        (SELECT age_group FROM age_groups WHERE low_age = 4 AND high_age = 7)
    FROM dual
        UNION ALL
    SELECT 2, 'ADK4680123', 'Light House',
        (SELECT age_group FROM age_groups WHERE low_age = 6 AND high_age = 12)
    FROM dual
        UNION ALL
    SELECT 3, 'CDF0008883', 'Boat',
        (SELECT age_group FROM age_groups WHERE low_age = 10 AND high_age = 15)
    FROM dual;
    
INSERT INTO Build_List (model_id, part_id, quantity)
   VALUES (
    (SELECT model_id FROM models WHERE sku = 'SDK1234123'),
    (SELECT p.part_id
    FROM parts p
        JOIN part_types pt
            On p.type_id = pt.type_id
        JOIN colors c
            ON p.color_id = c.color_id
    WHERE pt.type_name = 'Wheel' AND c.color_name = 'Black'),
    4);
        
INSERT INTO Build_List (model_id, part_id, quantity)
   VALUES (
    (SELECT model_id FROM models WHERE sku = 'SDK1234123'),
    (SELECT p.part_id
    FROM parts p
        JOIN part_types pt
            On p.type_id = pt.type_id
        JOIN colors c
            ON p.color_id = c.color_id
    WHERE pt.type_name = 'Plate' AND c.color_name = 'Blue'),
    1);

INSERT INTO Build_List (model_id, part_id, quantity)
   VALUES (
    (SELECT model_id FROM models WHERE sku = 'SDK1234123'),
    (SELECT p.part_id
    FROM parts p
        JOIN part_types pt
            On p.type_id = pt.type_id
        JOIN colors c
            ON p.color_id = c.color_id
    WHERE pt.type_name = 'Brick' AND c.color_name = 'Yellow'),
    1);

INSERT INTO Build_List (model_id, part_id, quantity)
   VALUES (
    (SELECT model_id FROM models WHERE sku = 'ADK4680123'),
    (SELECT p.part_id
    FROM parts p
        JOIN part_types pt
            On p.type_id = pt.type_id
        JOIN colors c
            ON p.color_id = c.color_id
    WHERE pt.type_name = 'Stud' AND c.color_name = 'Clear'),
    4);

INSERT INTO Build_List (model_id, part_id, quantity)
   VALUES (
    (SELECT model_id FROM models WHERE sku = 'ADK4680123'),
    (SELECT p.part_id
    FROM parts p
        JOIN part_types pt
            On p.type_id = pt.type_id
        JOIN colors c
            ON p.color_id = c.color_id
    WHERE pt.type_name = 'Brick' AND c.color_name = 'Red'),
    5);

INSERT INTO Build_List (model_id, part_id, quantity)
   VALUES (
    (SELECT model_id FROM models WHERE sku = 'CDF0008883'),
    (SELECT p.part_id
    FROM parts p
        JOIN part_types pt
            On p.type_id = pt.type_id
        JOIN colors c
            ON p.color_id = c.color_id
    WHERE pt.type_name = 'Plate' AND c.color_name = 'Blue'),
    2);
   
INSERT INTO Build_List (model_id, part_id, quantity)
   VALUES (
    (SELECT model_id FROM models WHERE sku = 'CDF0008883'),
    (SELECT p.part_id
    FROM parts p
        JOIN part_types pt
            On p.type_id = pt.type_id
        JOIN colors c
            ON p.color_id = c.color_id
    WHERE pt.type_name = 'Brick' AND c.color_name = 'Red'),
    6);
 
INSERT INTO Build_List (model_id, part_id, quantity)
   VALUES (
    (SELECT model_id FROM models WHERE sku = 'CDF0008883'),
    (SELECT p.part_id
    FROM parts p
        JOIN part_types pt
            On p.type_id = pt.type_id
        JOIN colors c
            ON p.color_id = c.color_id
    WHERE pt.type_name = 'Stud' AND c.color_name = 'Clear'),
    1);
    
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