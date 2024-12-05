-- CRUD operations to test the streaming pipeline

INSERT INTO db_1.user_1 VALUES (111,"user_111","Shanghai","123567891234","user_111@foo.com");

UPDATE db_1.user_2 SET address='Beijing' WHERE id=120;

DELETE FROM db_2.user_2 WHERE id=220;

-- Command to test schema change evolution
ALTER TABLE db_1.user_2 ADD mobile_number INTEGER;
UPDATE db_1.user_2 SET mobile_number=9876 WHERE id=120;

ALTER TABLE db_1.user_2 MODIFY COLUMN mobile_number BIGINT;
ALTER TABLE db_1.user_2 MODIFY COLUMN email TEXT;

ALTER TABLE db_1.user_2 RENAME COLUMN mobile_number TO alternate_phone;
ALTER TABLE db_1.user_2 RENAME COLUMN email TO mail;

ALTER TABLE db_1.user_2 DROP alternate_phone;