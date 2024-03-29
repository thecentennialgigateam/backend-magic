-- drop Sequences
DROP SEQUENCE COURSE_ID_SEQ;
DROP SEQUENCE DEPARTMENT_ID_SEQ;
DROP SEQUENCE ENROLLMENT_ID_SEQ;
DROP SEQUENCE PROGRAM_ID_SEQ;
DROP SEQUENCE SECTION_ID_SEQ;
DROP SEQUENCE STUDENT_ID_SEQ;
DROP SEQUENCE ENROLLMENTHISTORY_ID_SEQ;

-- Drop existing tables
DROP TABLE ENROLLMENT_HISTORY;
DROP TABLE PROGRAM_COURSE;
DROP TABLE PREREQUISITE;
DROP TABLE SECTION_ENROLLMENT;
DROP TABLE SECTION;
DROP TABLE COURSE;
DROP TABLE ENROLLMENT;
DROP TABLE PROGRAM;
DROP TABLE DEPARTMENT;
DROP TABLE STUDENT;
DROP VIEW section_enrollments_vw;

-- Drop the packages
DROP PACKAGE enrollment_pkg;

-- Drop functions
DROP FUNCTION get_fees;
DROP FUNCTION check_capacity;

-- Config for triggers
ALTER SESSION SET PLSCOPE_SETTINGS = 'IDENTIFIERS:NONE';

-- tables creation
-- Department
CREATE TABLE DEPARTMENT 
(
  DEPARTMENT_ID NUMBER(9,0) NOT NULL,
  DEPARTMENT_NAME VARCHAR2(50),  
  DEPARTMENT_HEAD VARCHAR2(50), 
  CONSTRAINT DEPARTMENT_PK  PRIMARY KEY (DEPARTMENT_ID)   
);
-- sequence for department table
CREATE SEQUENCE DEPARTMENT_ID_SEQ
INCREMENT BY 1
START WITH 10
NOCYCLE
NOCACHE;

-- Program
CREATE TABLE PROGRAM 
(
  PROGRAM_ID NUMBER NOT NULL, 
  PROGRAM_NAME VARCHAR2(100), 
  NO_OF_TERMS NUMBER(2,0), 
  FEES NUMBER(9,2), 
  DEPARTMENT_ID NUMBER(9,0),
    CONSTRAINT PROGRAM_PK PRIMARY KEY (PROGRAM_ID), 
    CONSTRAINT DEPARTMENT_FK FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENT(DEPARTMENT_ID),
    CONSTRAINT no_of_terms_chk CHECK (NO_OF_TERMS > 0),
    CONSTRAINT fees_chk CHECK (FEES >= 0)
);
-- sequence for program table
CREATE SEQUENCE PROGRAM_ID_SEQ
INCREMENT BY 1
START WITH 300
NOCYCLE
NOCACHE;

-- Student
CREATE TABLE STUDENT 
(
  STUDENT_ID NUMBER(9,0) NOT NULL,
  STUDENT_FIRST_NAME VARCHAR2(50) NOT NULL,
  STUDENT_MIDDLE_NAME VARCHAR2(50), 
  STUDENT_LAST_NAME VARCHAR2(71) NOT NULL, 
  TELEPHONE VARCHAR2(31) NOT NULL, 
  EMAIL VARCHAR2(256) NOT NULL, 
  ADDRESS VARCHAR2(100),
  PROVINCE VARCHAR2(40),
  COUNTRY VARCHAR2(60),
  CITY VARCHAR2(100),
  ZIP_CODE VARCHAR2(10),
  IS_DOMESTIC NUMBER(1,0) NOT NULL,
  IDENTITY_NO VARCHAR2(20),
  SIN NUMBER(9,0),
  DOB DATE NOT NULL,
    CONSTRAINT STUDENT_PK PRIMARY KEY (STUDENT_ID),
    CONSTRAINT email_ckp CHECK (EMAIL LIKE '%@%.%' AND EMAIL NOT LIKE '@%' AND EMAIL NOT LIKE '%@%@'),
    CONSTRAINT province_ckp CHECK (PROVINCE IN 
    ('NL', 'PE', 'NS', 'NB', 'QC', 'ON', 'MB', 'SK', 'AB', 'BC', 'YT', 'NU', 'NT'))
);
-- sequence for student table
CREATE SEQUENCE STUDENT_ID_SEQ
INCREMENT BY 5
START WITH 1000
NOCYCLE
NOCACHE;
-- Index for student table
CREATE INDEX STUDENT_IDX
ON STUDENT (STUDENT_LAST_NAME, IDENTITY_NO);

-- Enrollment
CREATE TABLE ENROLLMENT 
(
  ENROLLMENT_ID NUMBER(9) NOT NULL,
  STUDENT_ID NUMBER(9) NOT NULL,
  PROGRAM_ID NUMBER(9),
  STATUS NUMBER(1,0) DEFAULT 0,
  CURRENT_TERM NUMBER(2,0),
  ENROLL_DATE DATE,
  TOTAL_FEES NUMBER(9, 2),
    CONSTRAINT ENROLLMENT_PK PRIMARY KEY (ENROLLMENT_ID),
    CONSTRAINT STUDENT_FK FOREIGN KEY (STUDENT_ID) REFERENCES STUDENT(STUDENT_ID),
    CONSTRAINT PROGRAM_ENROLL_FK FOREIGN KEY (PROGRAM_ID) REFERENCES PROGRAM(PROGRAM_ID),
    CONSTRAINT UNIQUE_CONSTRAINT_ENROLL UNIQUE(STUDENT_ID, PROGRAM_ID),
    CONSTRAINT STATUS_CHK CHECK (STATUS IN (0, 1))
);
-- sequence for enrollment table
CREATE SEQUENCE ENROLLMENT_ID_SEQ
INCREMENT BY 3
START WITH 10000
NOCYCLE
NOCACHE;
-- Index for enrollment table
CREATE INDEX ENROLLMENT_IDX
ON ENROLLMENT (STUDENT_ID);

-- ENROLLMENT_HISTORY
CREATE TABLE ENROLLMENT_HISTORY 
(
  ENROLLMENT_HISTORY_ID NUMBER(9) NOT NULL,
  ENROLLMENT_ID NUMBER(9) NOT NULL,
  STUDENT_ID NUMBER(9) NOT NULL,
  PROGRAM_ID NUMBER(9),
  STATUS NUMBER(1,0),
  CURRENT_TERM NUMBER(2,0),
  ENROLL_DATE DATE,
  TOTAL_FEES NUMBER(9, 2),
  ACTION VARCHAR2(20),
  ACTIONDATE DATE,
  
    CONSTRAINT ENROLLMENT_HISTORY_PK PRIMARY KEY (ENROLLMENT_HISTORY_ID),
    CONSTRAINT STUDENT_ID_FK FOREIGN KEY (STUDENT_ID) REFERENCES STUDENT(STUDENT_ID),
    CONSTRAINT PROGRAM_ENROLL_ID_FK FOREIGN KEY (PROGRAM_ID) REFERENCES PROGRAM(PROGRAM_ID),
    CONSTRAINT STATUS_HISTORY_CHK CHECK (STATUS IN (0, 1)),
    CONSTRAINT ACTION_CHK CHECK (ACTION IN ('DELETE','UPDATE'))
);
-- sequence for enrollment table
CREATE SEQUENCE ENROLLMENTHISTORY_ID_SEQ
INCREMENT BY 1
START WITH 1
NOCYCLE
NOCACHE;

-- Course
CREATE TABLE COURSE 
(
  COURSE_ID NUMBER(9,0) NOT NULL,
  COURSE_NAME VARCHAR2(100),
  COURSE_CODE VARCHAR2(10),
  COURSE_DESC VARCHAR2(100),
  NO_CREDITS NUMBER(2,0),
    CONSTRAINT COURSE_PK PRIMARY KEY (COURSE_ID),
    CONSTRAINT NO_CREDITS_CHK CHECK (NO_CREDITS > 0 AND NO_CREDITS < 10)
);
-- sequence for course table
CREATE SEQUENCE COURSE_ID_SEQ
INCREMENT BY 2
START WITH 10
NOCYCLE
NOCACHE;

-- Section
CREATE TABLE SECTION 
(
  SECTION_ID NUMBER(9,0) NOT NULL,
  SECTION_TYPE VARCHAR2(20),
  PROFESSOR_NAME VARCHAR2(121),
  CAPACITY NUMBER(3,0),
  COURSE_ID NUMBER(9,0),
    CONSTRAINT SECTION_PK PRIMARY KEY (SECTION_ID),
    CONSTRAINT COURSE_FK FOREIGN KEY (COURSE_ID) REFERENCES COURSE (COURSE_ID),
    CONSTRAINT SECTION_TYPE_CHK CHECK (SECTION_TYPE IN ('ONLINE','IN PERSON','HYBRID'))
);
-- sequence for section table
CREATE SEQUENCE SECTION_ID_SEQ
INCREMENT BY 1
START WITH 1
NOCYCLE
NOCACHE;

-- Prerequisite
CREATE TABLE PREREQUISITE 
(
  PREREQ_COURSE NUMBER(9) NOT NULL,
  COURSE_ID NUMBER(9,0) NOT NULL,
    CONSTRAINT PREREQUISITE_PK PRIMARY KEY (PREREQ_COURSE, COURSE_ID),
    CONSTRAINT COURSE_ID_FK FOREIGN KEY (COURSE_ID) REFERENCES COURSE (COURSE_ID)
);

-- Program Course relationship
CREATE TABLE PROGRAM_COURSE 
(
  PROGRAM_ID NUMBER(9) NOT NULL,
  COURSE_ID NUMBER(9) NOT NULL,
    CONSTRAINT PROGRAM_COURSE_PK PRIMARY KEY (PROGRAM_ID, COURSE_ID),
    CONSTRAINT COURSE_PC_FK FOREIGN KEY (COURSE_ID) REFERENCES COURSE(COURSE_ID),
    CONSTRAINT PROGRAM_PC_FK FOREIGN KEY (PROGRAM_ID) REFERENCES PROGRAM(PROGRAM_ID)
);

CREATE TABLE SECTION_ENROLLMENT
(
    SECTION_ID NUMBER(9,0) NOT NULL,
    ENROLLMENT_ID NUMBER(9) NOT NULL,
    CONSTRAINT section_enrollment_pk
        PRIMARY KEY (SECTION_ID, ENROLLMENT_ID),
    CONSTRAINT section_id_fk
        FOREIGN KEY (SECTION_ID) REFERENCES SECTION(SECTION_ID),
    CONSTRAINT enrollment_id_fk
        FOREIGN KEY (ENROLLMENT_ID) REFERENCES ENROLLMENT(ENROLLMENT_ID)
    ON DELETE CASCADE
);

COMMIT;



--////////////////////////////PROCEDURES INSIDE PACKAGE////////////////////////////
/*
    This procedure creates a new enrollment for a new student
    By default the value of status must be 0 (pending)
*/
-- Procedure Create Enrollment_sp

CREATE OR REPLACE PACKAGE enrollment_pkg IS
    pv_enrollment VARCHAR2(20);
    
    PROCEDURE increase_program_fees;
    
    PROCEDURE create_enrollment_sp
        (   p_student_id IN ENROLLMENT.STUDENT_ID%TYPE,
            p_program_id IN ENROLLMENT.PROGRAM_ID%TYPE,
            p_status IN ENROLLMENT.STATUS%TYPE,
            p_current_term IN ENROLLMENT.CURRENT_TERM%TYPE,
            p_enrollment_date IN ENROLLMENT.ENROLL_DATE%TYPE,
            p_total_fees IN ENROLLMENT.TOTAL_FEES%TYPE
        );
        
        --ENDS PROCEDURE create_enrollment_sp
    PROCEDURE update_enrollment_sp
        ( 
            p_enrollment_id  IN ENROLLMENT.ENROLLMENT_ID%TYPE,
            p_student_id IN ENROLLMENT.STUDENT_ID%TYPE,
            p_program_id IN ENROLLMENT.PROGRAM_ID%TYPE,
            p_status IN ENROLLMENT.STATUS%TYPE,
            p_current_term IN ENROLLMENT.CURRENT_TERM%TYPE,
            p_enrollment_date IN ENROLLMENT.ENROLL_DATE%TYPE,
            p_total_fees IN ENROLLMENT.TOTAL_FEES%TYPE
        );
    PROCEDURE create_student_sp
        ( 
            p_student_first_name IN STUDENT.STUDENT_FIRST_NAME%TYPE,
            p_student_middle_name IN STUDENT.STUDENT_MIDDLE_NAME%TYPE,
            p_student_last_name IN STUDENT.STUDENT_LAST_NAME%TYPE,
            p_telephone IN STUDENT.TELEPHONE%TYPE,
            p_email IN STUDENT.EMAIL%TYPE,
            p_address IN STUDENT.ADDRESS%TYPE,
            p_province IN STUDENT.PROVINCE%TYPE,
            p_country IN STUDENT.COUNTRY%TYPE,
            p_city IN STUDENT.CITY%TYPE,
            p_zipCode IN STUDENT.ZIP_CODE%TYPE,
            p_isDomestic IN STUDENT.IS_DOMESTIC%TYPE,
            p_identityNo IN STUDENT.IDENTITY_NO%TYPE,
            p_sin IN STUDENT.SIN%TYPE,
            p_dob IN STUDENT.DOB%TYPE
        );
        PROCEDURE update_student_sp
        ( 
            p_student_id IN STUDENT.STUDENT_ID%TYPE,
            p_student_first_name IN STUDENT.STUDENT_FIRST_NAME%TYPE,
            p_student_middle_name IN STUDENT.STUDENT_MIDDLE_NAME%TYPE,
            p_student_last_name IN STUDENT.STUDENT_LAST_NAME%TYPE,
            p_telephone IN STUDENT.TELEPHONE%TYPE,
            p_email IN STUDENT.EMAIL%TYPE,
            p_sin IN STUDENT.SIN%TYPE,
            p_dob IN STUDENT.DOB%TYPE
          );

        -- functions header
        FUNCTION get_fees (student_id_prt student.student_id%TYPE, 
                            program_id_prt program.program_id%TYPE)
        RETURN NUMBER;
          
        FUNCTION check_capacity(section_id_prt  section.section_id%TYPE)
        RETURN NUMBER;
        
        END;
/        
CREATE OR REPLACE PACKAGE BODY enrollment_pkg IS

        PROCEDURE increase_program_fees
        IS
        CURSOR programs_csr
        IS
            SELECT program_id, fees
            FROM program;
            lv_older_fee program.fees%TYPE; 
            lv_new_fee program.fees%TYPE; 
    
        BEGIN
            FOR c_program in programs_csr
            LOOP
                SELECT fees
                INTO lv_older_fee
                FROM program
                WHERE program.program_id = c_program.program_id;
                --
                IF lv_older_fee <= 20000 THEN
                    lv_new_fee := lv_older_fee * 1.1;
                ELSIF lv_older_fee > 20000 THEN
                    lv_new_fee := lv_older_fee * 1.05;
                END IF;
                --
                UPDATE
                    program
                SET
                    fees = lv_new_fee
                WHERE
                    program.program_id = c_program.program_id;
                --
                DBMS_OUTPUT.PUT_LINE('Increased fees for program: ' ||
                c_program.program_id || 'from $' || lv_older_fee ||
                ' to $' || lv_new_fee);
            END LOOP;  
        END increase_program_fees;
        
        
        PROCEDURE create_enrollment_sp
        ( 
        p_student_id IN ENROLLMENT.STUDENT_ID%TYPE,
        p_program_id IN ENROLLMENT.PROGRAM_ID%TYPE,
        p_status IN ENROLLMENT.STATUS%TYPE,
        p_current_term IN ENROLLMENT.CURRENT_TERM%TYPE,
        p_enrollment_date IN ENROLLMENT.ENROLL_DATE%TYPE,
        p_total_fees IN ENROLLMENT.TOTAL_FEES%TYPE
        )
        IS
    p_ENROLLMENT_ID NUMBER;
        BEGIN
    p_ENROLLMENT_ID := ENROLLMENT_ID_SEQ.NEXTVAL;
    INSERT INTO ENROLLMENT (ENROLLMENT_ID,STUDENT_ID,PROGRAM_ID,STATUS,CURRENT_TERM,ENROLL_DATE,TOTAL_FEES)
        VALUES(p_ENROLLMENT_ID,p_student_id,p_program_id,p_status,p_current_term,p_enrollment_date,p_total_fees);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('ENROLLMENT ID: ' || p_ENROLLMENT_ID || ', STUDENT ID: ' || p_student_id 
        ||', PROGRAM ID: ' || p_program_id);
    DBMS_OUTPUT.PUT_LINE('succesfully inserted into the system. :)');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN 
        DBMS_OUTPUT.PUT_LINE('ERROR in adding new ENROLLMENT with ENROLLMENT_ID '|| p_ENROLLMENT_ID ||' there is a duplicate value on existing table');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error ' || SQLERRM);
        ROLLBACK;
    END create_ENROLLMENT_sp;
    
    PROCEDURE update_enrollment_sp
    ( 
    p_enrollment_id  IN ENROLLMENT.ENROLLMENT_ID%TYPE,
    p_student_id IN ENROLLMENT.STUDENT_ID%TYPE,
    p_program_id IN ENROLLMENT.PROGRAM_ID%TYPE,
    p_status IN ENROLLMENT.STATUS%TYPE,
    p_current_term IN ENROLLMENT.CURRENT_TERM%TYPE,
    p_enrollment_date IN ENROLLMENT.ENROLL_DATE%TYPE,
    p_total_fees IN ENROLLMENT.TOTAL_FEES%TYPE
    )
    IS
    CHECK_CONSTRAINT_VIOLATION EXCEPTION;
    PRAGMA EXCEPTION_INIT(CHECK_CONSTRAINT_VIOLATION, -2290);
    BEGIN
        UPDATE ENROLLMENT
        SET student_id = p_student_id, program_id = p_program_id, status = p_status, current_term = p_current_term,
        enroll_date = p_enrollment_date,total_fees = p_total_fees
        WHERE ENROLLMENT_ID = p_enrollment_id;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Student ID: ' || p_student_id || ' succesfully update the information on the system.');
    EXCEPTION
    WHEN CHECK_CONSTRAINT_VIOLATION THEN
    DBMS_OUTPUT.PUT_LINE('Create Enrollment failed due to check constraint violation!!!!!');
    ROLLBACK;
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error' || SQLERRM);
    ROLLBACK;
    END update_enrollment_sp;

    PROCEDURE create_student_sp
    ( 
    p_student_first_name IN STUDENT.STUDENT_FIRST_NAME%TYPE,
    p_student_middle_name IN STUDENT.STUDENT_MIDDLE_NAME%TYPE,
    p_student_last_name IN STUDENT.STUDENT_LAST_NAME%TYPE,
    p_telephone IN STUDENT.TELEPHONE%TYPE,
    p_email IN STUDENT.EMAIL%TYPE,
    p_address IN STUDENT.ADDRESS%TYPE,
    p_province IN STUDENT.PROVINCE%TYPE,
    p_country IN STUDENT.COUNTRY%TYPE,
    p_city IN STUDENT.CITY%TYPE,
    p_zipCode IN STUDENT.ZIP_CODE%TYPE,
    p_isDomestic IN STUDENT.IS_DOMESTIC%TYPE,
    p_identityNo IN STUDENT.IDENTITY_NO%TYPE,
    p_sin IN STUDENT.SIN%TYPE,
    p_dob IN STUDENT.DOB%TYPE
    )
    IS
    p_student_ID NUMBER;
    CHECK_CONSTRAINT_VIOLATION EXCEPTION;
    PRAGMA EXCEPTION_INIT(CHECK_CONSTRAINT_VIOLATION, -2290);
    BEGIN
    p_student_ID := STUDENT_ID_SEQ.NEXTVAL;
    INSERT INTO STUDENT (STUDENT_ID,STUDENT_FIRST_NAME,STUDENT_MIDDLE_NAME,STUDENT_LAST_NAME,TELEPHONE,EMAIL,
    ADDRESS,PROVINCE,COUNTRY,CITY,ZIP_CODE,IS_DOMESTIC,IDENTITY_NO,SIN,DOB)
    VALUES(p_student_ID,p_student_first_name,p_student_middle_name,p_student_last_name,p_telephone,p_email,
    p_address,p_province,p_country,p_city,p_zipCode,p_isDomestic,p_identityNo,p_sin,p_dob);
    COMMIT;
        DBMS_OUTPUT.PUT_LINE('Student ID: ' || p_student_ID || ' succesfully created to the system.');
    EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN 
        DBMS_OUTPUT.PUT_LINE('ERROR!!!!!!! CANNOT create new student there is a duplicate value on index');
    ROLLBACK;
    WHEN CHECK_CONSTRAINT_VIOLATION THEN
        DBMS_OUTPUT.PUT_LINE('Create Student failed due to check constraint violation!!!!!');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error' || SQLERRM);
        ROLLBACK;
    END create_student_sp;
    
    PROCEDURE update_student_sp
    ( 
        p_student_id IN STUDENT.STUDENT_ID%TYPE,
        p_student_first_name IN STUDENT.STUDENT_FIRST_NAME%TYPE,
        p_student_middle_name IN STUDENT.STUDENT_MIDDLE_NAME%TYPE,
        p_student_last_name IN STUDENT.STUDENT_LAST_NAME%TYPE,
        p_telephone IN STUDENT.TELEPHONE%TYPE,
        p_email IN STUDENT.EMAIL%TYPE,
        p_sin IN STUDENT.SIN%TYPE,
        p_dob IN STUDENT.DOB%TYPE
      )
      IS
      CHECK_CONSTRAINT_VIOLATION EXCEPTION;
      PRAGMA EXCEPTION_INIT(CHECK_CONSTRAINT_VIOLATION, -2290);
    BEGIN
      UPDATE STUDENT
      SET STUDENT_FIRST_NAME = p_student_first_name, STUDENT_MIDDLE_NAME = p_student_middle_name, STUDENT_LAST_NAME = p_student_last_name, TELEPHONE = p_telephone,
      EMAIL = p_email,SIN = p_sin, DOB = p_dob
      WHERE STUDENT_ID = p_student_id;
      COMMIT;
      DBMS_OUTPUT.PUT_LINE('Student ID: ' || p_student_id || ' succesfully update the information on the system.');
    EXCEPTION
      WHEN CHECK_CONSTRAINT_VIOLATION THEN
      DBMS_OUTPUT.PUT_LINE('Create Student failed due to check constraint violation!!!!!');
      ROLLBACK;
      WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error' || SQLERRM);
      ROLLBACK;
    END update_student_sp;
    
    -- function declarations

    /* 
    This function will calculate the student fees.
    It receives two parameters:
    @student_id: the student id
    @program_id: the program id
    It calculates the fees based on the student.is_domestic value
    if it is true, it will get the fee from program and return it as it is.
    if it is false, it will get the fee from program and multiply it by 3 (multiply factor)
    if the values for student_id or program_id are not valid, it will return 0
    */
    FUNCTION get_fees (student_id_prt student.student_id%TYPE, 
                                        program_id_prt program.program_id%TYPE)
        RETURN NUMBER
    IS
        lv_is_domestic              NUMBER;
        lv_program_fees             NUMBER;
        lv_total_fees               NUMBER;
        lv_multiplication_factor    NUMBER:=3;
    BEGIN
        -- get the is_domestic (true=1 or false=0)
        SELECT  is_domestic
            INTO    lv_is_domestic
            FROM    student
            WHERE   student_id=student_id_prt;
        -- get the program fees
        SELECT fees
            INTO lv_program_fees
            FROM program
            WHERE program_id = program_id_prt;
        -- calculate the total_fees according to domestic
        IF (lv_is_domestic = 0) THEN
            lv_total_fees := lv_program_fees * lv_multiplication_factor;
            DBMS_OUTPUT.PUT_LINE('calculated intl fee: ' || lv_total_fees);
            RETURN lv_total_fees;
        ELSIF (lv_is_domestic = 1) THEN
            lv_total_fees := lv_program_fees;
            DBMS_OUTPUT.PUT_LINE('calculated dmst fee: ' || lv_total_fees);
            RETURN lv_total_fees;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Incorrect student or program data specified');
            RETURN null;
        END IF;    
        exception
        when no_data_found 
        then DBMS_OUTPUT.PUT_LINE('SQL DATA NOT FOUND');
        RETURN lv_total_fees;
    END;

    
    /*
    This function verifies if there are available seats in the section.
    It receives one parameter:
    @section_id: the section id
    It returns true (1) if there are available seats, false (0) otherwise
    */


    FUNCTION check_capacity(section_id_prt  section.section_id%TYPE)
        RETURN NUMBER
    IS
        lv_capacity_available   NUMBER;
        lv_section_ocupancy     section.section_id%TYPE;
        lv_capacity             section.capacity%TYPE;
        lv_availability        NUMBER;
    BEGIN
        --get the ocupancy of a section
        SELECT      COUNT(section_id)
        INTO        lv_section_ocupancy
        FROM        section_enrollment TAB1
        WHERE       section_id=section_id_prt;
        -- get total capacity
        SELECT      capacity
        INTO        lv_capacity
        FROM        section
        WHERE       section_id=section_id_prt;
        
        IF (lv_section_ocupancy<=lv_capacity) THEN
            lv_availability:=lv_capacity-lv_section_ocupancy;
            dbms_output.put_line('There is availability '||lv_availability);
            lv_capacity_available:=1;
        RETURN lv_capacity_available;
        ELSE
            dbms_output.put_line('There is not availability '||lv_availability);
            lv_capacity_available:=0;
        RETURN lv_capacity_available;
        END IF;
        
        EXCEPTION 
            WHEN no_data_found THEN
            dbms_output.put_line('You are looking for a not available section');
            RETURN null;
    END;
END;
/

---Test package
BEGIN
enrollment_pkg.pv_enrollment := 'Sebas';
END;
/
BEGIN 
DBMS_OUTPUT.PUT_LINE(enrollment_pkg.pv_enrollment);
END;


-- CREATE OR REPLACE PROCEDURE create_enrollment_sp
--     ( 
--         p_student_id IN ENROLLMENT.STUDENT_ID%TYPE,
--         p_program_id IN ENROLLMENT.PROGRAM_ID%TYPE,
--         p_status IN ENROLLMENT.STATUS%TYPE,
--         p_current_term IN ENROLLMENT.CURRENT_TERM%TYPE,
--         p_enrollment_date IN ENROLLMENT.ENROLL_DATE%TYPE,
--         p_total_fees IN ENROLLMENT.TOTAL_FEES%TYPE
--     )
-- IS
--     p_ENROLLMENT_ID NUMBER;
-- BEGIN
--     p_ENROLLMENT_ID := ENROLLMENT_ID_SEQ.NEXTVAL;
--     INSERT INTO ENROLLMENT (ENROLLMENT_ID,STUDENT_ID,PROGRAM_ID,STATUS,CURRENT_TERM,ENROLL_DATE,TOTAL_FEES)
--         VALUES(p_ENROLLMENT_ID,p_student_id,p_program_id,p_status,p_current_term,p_enrollment_date,p_total_fees);
--     COMMIT;
--     DBMS_OUTPUT.PUT_LINE('ENROLLMENT ID: ' || p_ENROLLMENT_ID || ', STUDENT ID: ' || p_student_id 
--         ||', PROGRAM ID: ' || p_program_id);
--     DBMS_OUTPUT.PUT_LINE('succesfully inserted into the system. :)');
--     EXCEPTION
--         WHEN DUP_VAL_ON_INDEX THEN 
--         DBMS_OUTPUT.PUT_LINE('ERROR in adding new ENROLLMENT with ENROLLMENT_ID '|| p_ENROLLMENT_ID ||' there is a duplicate value on existing table');
--         ROLLBACK;
--     WHEN OTHERS THEN
--         DBMS_OUTPUT.PUT_LINE('Error ' || SQLERRM);
--         ROLLBACK;
-- END create_ENROLLMENT_sp;
-- /
-- -- Procedure update_enrollment_sp  

-- CREATE OR REPLACE PROCEDURE update_enrollment_sp
-- ( 
--   p_enrollment_id  IN ENROLLMENT.ENROLLMENT_ID%TYPE,
--   p_student_id IN ENROLLMENT.STUDENT_ID%TYPE,
--   p_program_id IN ENROLLMENT.PROGRAM_ID%TYPE,
--   p_status IN ENROLLMENT.STATUS%TYPE,
--   p_current_term IN ENROLLMENT.CURRENT_TERM%TYPE,
--   p_enrollment_date IN ENROLLMENT.ENROLL_DATE%TYPE,
--   p_total_fees IN ENROLLMENT.TOTAL_FEES%TYPE
--   )
--   IS
--   CHECK_CONSTRAINT_VIOLATION EXCEPTION;
--   PRAGMA EXCEPTION_INIT(CHECK_CONSTRAINT_VIOLATION, -2290);
-- BEGIN
--   UPDATE ENROLLMENT
--   SET student_id = p_student_id, program_id = p_program_id, status = p_status, current_term = p_current_term,
--   enroll_date = p_enrollment_date,total_fees = p_total_fees
--   WHERE ENROLLMENT_ID = p_enrollment_id;
--   COMMIT;
--   DBMS_OUTPUT.PUT_LINE('Student ID: ' || p_student_id || ' succesfully update the information on the system.');
-- EXCEPTION
--   WHEN CHECK_CONSTRAINT_VIOLATION THEN
--   DBMS_OUTPUT.PUT_LINE('Create Enrollment failed due to check constraint violation!!!!!');
--   ROLLBACK;
--   WHEN OTHERS THEN
--   DBMS_OUTPUT.PUT_LINE('Error' || SQLERRM);
--   ROLLBACK;
-- END update_enrollment_sp;
-- /
-- -- Procedure that creates a new student 

-- CREATE OR REPLACE PROCEDURE create_student_sp
-- ( 
--     p_student_first_name IN STUDENT.STUDENT_FIRST_NAME%TYPE,
--     p_student_middle_name IN STUDENT.STUDENT_MIDDLE_NAME%TYPE,
--     p_student_last_name IN STUDENT.STUDENT_LAST_NAME%TYPE,
--     p_telephone IN STUDENT.TELEPHONE%TYPE,
--     p_email IN STUDENT.EMAIL%TYPE,
--     p_address IN STUDENT.ADDRESS%TYPE,
--     p_province IN STUDENT.PROVINCE%TYPE,
--     p_country IN STUDENT.COUNTRY%TYPE,
--     p_city IN STUDENT.CITY%TYPE,
--     p_zipCode IN STUDENT.ZIP_CODE%TYPE,
--     p_isDomestic IN STUDENT.IS_DOMESTIC%TYPE,
--     p_identityNo IN STUDENT.IDENTITY_NO%TYPE,
--     p_sin IN STUDENT.SIN%TYPE,
--     p_dob IN STUDENT.DOB%TYPE
--   )
-- IS
--     p_student_ID NUMBER;
--     CHECK_CONSTRAINT_VIOLATION EXCEPTION;
--   PRAGMA EXCEPTION_INIT(CHECK_CONSTRAINT_VIOLATION, -2290);
-- BEGIN
--     p_student_ID := STUDENT_ID_SEQ.NEXTVAL;
--   INSERT INTO STUDENT (STUDENT_ID,STUDENT_FIRST_NAME,STUDENT_MIDDLE_NAME,STUDENT_LAST_NAME,TELEPHONE,EMAIL,
--   ADDRESS,PROVINCE,COUNTRY,CITY,ZIP_CODE,IS_DOMESTIC,IDENTITY_NO,SIN,DOB)
--   VALUES(p_student_ID,p_student_first_name,p_student_middle_name,p_student_last_name,p_telephone,p_email,
--   p_address,p_province,p_country,p_city,p_zipCode,p_isDomestic,p_identityNo,p_sin,p_dob);
--   COMMIT;
--     DBMS_OUTPUT.PUT_LINE('Student ID: ' || p_student_ID || ' succesfully created to the system.');
-- EXCEPTION
--   WHEN DUP_VAL_ON_INDEX THEN 
--     DBMS_OUTPUT.PUT_LINE('ERROR!!!!!!! CANNOT create new student there is a duplicate value on index');
--   ROLLBACK;
--   WHEN CHECK_CONSTRAINT_VIOLATION THEN
--     DBMS_OUTPUT.PUT_LINE('Create Student failed due to check constraint violation!!!!!');
--   ROLLBACK;
--   WHEN OTHERS THEN
--     DBMS_OUTPUT.PUT_LINE('Error' || SQLERRM);
--   ROLLBACK;
-- END create_student_sp;
-- /
-- -- Procedure update student information on student table

-- CREATE OR REPLACE PROCEDURE update_student_sp
-- ( 
--     p_student_id IN STUDENT.STUDENT_ID%TYPE,
--     p_student_first_name IN STUDENT.STUDENT_FIRST_NAME%TYPE,
--     p_student_middle_name IN STUDENT.STUDENT_MIDDLE_NAME%TYPE,
--     p_student_last_name IN STUDENT.STUDENT_LAST_NAME%TYPE,
--     p_telephone IN STUDENT.TELEPHONE%TYPE,
--     p_email IN STUDENT.EMAIL%TYPE,
--     p_sin IN STUDENT.SIN%TYPE,
--     p_dob IN STUDENT.DOB%TYPE
--   )
--   IS
--   CHECK_CONSTRAINT_VIOLATION EXCEPTION;
--   PRAGMA EXCEPTION_INIT(CHECK_CONSTRAINT_VIOLATION, -2290);
-- BEGIN
--   UPDATE STUDENT
--   SET STUDENT_FIRST_NAME = p_student_first_name, STUDENT_MIDDLE_NAME = p_student_middle_name, STUDENT_LAST_NAME = p_student_last_name, TELEPHONE = p_telephone,
--   EMAIL = p_email,SIN = p_sin, DOB = p_dob
--   WHERE STUDENT_ID = p_student_id;
--   COMMIT;
--   DBMS_OUTPUT.PUT_LINE('Student ID: ' || p_student_id || ' succesfully update the information on the system.');
-- EXCEPTION
--   WHEN CHECK_CONSTRAINT_VIOLATION THEN
--   DBMS_OUTPUT.PUT_LINE('Create Student failed due to check constraint violation!!!!!');
--   ROLLBACK;
--   WHEN OTHERS THEN
--   DBMS_OUTPUT.PUT_LINE('Error' || SQLERRM);
--   ROLLBACK;
-- END update_student_sp;
/  
--///////////////////////////FUNCTIONS ///////////////////////////////////

/* 
    This function will calculate the student fees.
    It receives two parameters:
    @student_id: the student id
    @program_id: the program id
    It calculates the fees based on the student.is_domestic value
    if it is true, it will get the fee from program and return it as it is.
    if it is false, it will get the fee from program and multiply it by 3 (multiply factor)
    if the values for student_id or program_id are not valid, it will return 0
*/
create or replace FUNCTION get_fees (student_id_prt student.student_id%TYPE, 
                                    program_id_prt program.program_id%TYPE)
    RETURN NUMBER
IS
    lv_is_domestic              NUMBER;
    lv_program_fees             NUMBER;
    lv_total_fees               NUMBER;
    lv_multiplication_factor    NUMBER:=3;
BEGIN
    -- get the is_domestic (true=1 or false=0)
    SELECT  is_domestic
        INTO    lv_is_domestic
        FROM    student
        WHERE   student_id=student_id_prt;
    -- get the program fees
    SELECT fees
        INTO lv_program_fees
        FROM program
        WHERE program_id = program_id_prt;
    -- calculate the total_fees according to domestic
    IF (lv_is_domestic = 0) THEN
        lv_total_fees := lv_program_fees * lv_multiplication_factor;
        DBMS_OUTPUT.PUT_LINE('calculated intl fee: ' || lv_total_fees);
        RETURN lv_total_fees;
    ELSIF (lv_is_domestic = 1) THEN
        lv_total_fees := lv_program_fees;
        DBMS_OUTPUT.PUT_LINE('calculated dmst fee: ' || lv_total_fees);
        RETURN lv_total_fees;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Incorrect student or program data specified');
        RETURN null;
    END IF;    
    exception
      when no_data_found 
      then DBMS_OUTPUT.PUT_LINE('SQL DATA NOT FOUND');
      RETURN lv_total_fees;
END;
/

/*
This function verifies if there are available seats in the section.
It receives one parameter:
@section_id: the section id
It returns true (1) if there are available seats, false (0) otherwise
*/


CREATE OR REPLACE FUNCTION check_capacity(section_id_prt  section.section_id%TYPE)
    RETURN NUMBER
IS
    lv_capacity_available   NUMBER;
    lv_section_ocupancy     section.section_id%TYPE;
    lv_capacity             section.capacity%TYPE;
    lv_availability        NUMBER;
BEGIN
    --get the ocupancy of a section
    SELECT      COUNT(section_id)
    INTO        lv_section_ocupancy
    FROM        section_enrollment TAB1
    WHERE       section_id=section_id_prt;
    -- get total capacity
    SELECT      capacity
    INTO        lv_capacity
    FROM        section
    WHERE       section_id=section_id_prt;
    
    IF (lv_section_ocupancy<=lv_capacity) THEN
        lv_availability:=lv_capacity-lv_section_ocupancy;
        dbms_output.put_line('There is availability '||lv_availability);
        lv_capacity_available:=1;
    RETURN lv_capacity_available;
    ELSE
        dbms_output.put_line('There is not availability '||lv_availability);
        lv_capacity_available:=0;
    RETURN lv_capacity_available;
    END IF;
    
    EXCEPTION 
        WHEN no_data_found THEN
        dbms_output.put_line('You are looking for a not available section');
        RETURN null;
END;
/

--///////////////////////////TRIGGERS ///////////////////////////////////

create or replace TRIGGER update_enrollment_trg
BEFORE UPDATE ON ENROLLMENT
FOR EACH ROW
BEGIN
INSERT INTO ENROLLMENT_HISTORY VALUES(ENROLLMENTHISTORY_ID_SEQ.NEXTVAL, :OLD.ENROLLMENT_ID,
:OLD.STUDENT_ID, :OLD.PROGRAM_ID, :OLD.STATUS, :OLD.CURRENT_TERM, :OLD.ENROLL_DATE, :OLD.TOTAL_FEES,
'UPDATE',SYSDATE );
END update_enrollment_trg;
/
create or replace TRIGGER delete_enrollment_trg
BEFORE DELETE ON ENROLLMENT
FOR EACH ROW
BEGIN
INSERT INTO ENROLLMENT_HISTORY VALUES(ENROLLMENTHISTORY_ID_SEQ.NEXTVAL, :OLD.ENROLLMENT_ID,
:OLD.STUDENT_ID, :OLD.PROGRAM_ID, :OLD.STATUS, :OLD.CURRENT_TERM, :OLD.ENROLL_DATE, :OLD.TOTAL_FEES,
'DELETE',SYSDATE );
END delete_enrollment_trg;
/

-- Views to see and test the database

-- this view shows the numbers of students enrolled in each course by section
CREATE VIEW section_enrollments_vw 
AS 
(
    SELECT s.section_id, c.course_name, s.section_type, s.capacity, 
        COUNT(se.enrollment_id) AS registered_students
    FROM SECTION s
    JOIN section_enrollment se
    ON s.section_id = se.section_id
    JOIN course c
    ON s.course_id = c.course_id
    GROUP BY s.section_id, c.course_name, s.section_type, s.capacity
);

commit;



























/* 
 * Inserting data into tables
 */
 
-- DEPARTMENT TABLE 
set define off;

INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Industrial Arts & Consumer Services	'	,	'	Friday Maryanne	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Arts	'	,	'	Ashish Royal	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Business	'	,	'	America Apollonia	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Computers & Mathematics	'	,	'	Ada Lovelace	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Law & Public Policy	'	,	'	Ainz Ooal Gown	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Agriculture & Natural Resources	'	,	'	Varsha Kimberleigh	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Communications & Journalism	'	,	'	Esmee Caprice	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Engineering	'	,	'	Nikola Tesla	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Social Science	'	,	'	Bria Woody	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Health	'	,	'	Mridula Sully	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Interdisciplinary	'	,	'	Luther Sima	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Physical Sciences	'	,	'	Dr. Stone	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Humanities & Liberal Arts	'	,	'	Warren Timoteo	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Psychology & Social Work	'	,	'	Ted Ulisse	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Biology & Life Science	'	,	'	Ardith Lacie	'	);
INSERT INTO DEPARTMENT 	(DEPARTMENT_ID, DEPARTMENT_NAME, DEPARTMENT_HEAD) 	VALUES (	DEPARTMENT_ID_SEQ.nextval, 	'	Education	'	,	'	Adelardo Josey	'	);

-- PROGRAM TABLE
set define off;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	CONSTRUCTION SERVICES	'	,	8	,	11679	,	10	)	; 
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COSMETOLOGY SERVICES AND CULINARY ARTS	'	,	7	,	7218	,	10	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ELECTRICAL, MECHANICAL, AND PRECISION TECHNOLOGIES AND PRODUCTION	'	,	7	,	12816	,	10	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	TRANSPORTATION SCIENCES AND TECHNOLOGIES	'	,	4	,	6230	,	10	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	FAMILY AND CONSUMER SCIENCES	'	,	8	,	10803	,	10	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	PHYSICAL FITNESS PARKS RECREATION AND LEISURE	'	,	8	,	3859	,	10	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MILITARY TECHNOLOGIES	'	,	8	,	7735	,	10	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COMMERCIAL ART AND GRAPHIC DESIGN	'	,	5	,	10291	,	11	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	FILM VIDEO AND PHOTOGRAPHIC ARTS	'	,	5	,	7680	,	11	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MISCELLANEOUS FINE ARTS	'	,	5	,	5727	,	11	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	FINE ARTS	'	,	6	,	8626	,	11	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	VISUAL AND PERFORMING ARTS	'	,	7	,	9375	,	11	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	STUDIO ARTS	'	,	8	,	14067	,	11	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	DRAMA AND THEATER ARTS	'	,	7	,	2839	,	11	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MUSIC	'	,	5	,	13569	,	11	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	HOSPITALITY MANAGEMENT	'	,	6	,	1758	,	12	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MARKETING AND MARKETING RESEARCH	'	,	7	,	13237	,	12	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MISCELLANEOUS BUSINESS & MEDICAL ADMINISTRATION	'	,	7	,	9799	,	12	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	BUSINESS MANAGEMENT AND ADMINISTRATION	'	,	2	,	11805	,	12	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MANAGEMENT INFORMATION SYSTEMS AND STATISTICS	'	,	5	,	7237	,	12	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	OPERATIONS LOGISTICS AND E-COMMERCE	'	,	2	,	1275	,	12	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	GENERAL BUSINESS	'	,	6	,	3712	,	12	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ACTUARIAL SCIENCE	'	,	5	,	2632	,	12	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ACCOUNTING	'	,	3	,	14617	,	12	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	FINANCE	'	,	3	,	6446	,	12	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	HUMAN RESOURCES AND PERSONNEL MANAGEMENT	'	,	5	,	5029	,	12	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	INTERNATIONAL BUSINESS	'	,	7	,	9408	,	12	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	BUSINESS ECONOMICS	'	,	3	,	10327	,	12	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COMMUNICATION TECHNOLOGIES	'	,	5	,	12911	,	13	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COMPUTER PROGRAMMING AND DATA PROCESSING	'	,	4	,	4186	,	13	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COMPUTER NETWORKING AND TELECOMMUNICATIONS	'	,	5	,	2386	,	13	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COMPUTER ADMINISTRATION MANAGEMENT AND SECURITY	'	,	2	,	10410	,	13	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COMPUTER AND INFORMATION SYSTEMS	'	,	7	,	13913	,	13	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	INFORMATION SCIENCES	'	,	3	,	12484	,	13	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COMPUTER SCIENCE	'	,	6	,	9250	,	13	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MATHEMATICS AND COMPUTER SCIENCE	'	,	8	,	10140	,	13	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	APPLIED MATHEMATICS	'	,	5	,	8427	,	13	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	STATISTICS AND DECISION SCIENCE	'	,	5	,	5554	,	13	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MATHEMATICS	'	,	7	,	13652	,	13	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COURT REPORTING	'	,	7	,	8389	,	14	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	CRIMINAL JUSTICE AND FIRE PROTECTION	'	,	8	,	6850	,	14	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	PRE-LAW AND LEGAL STUDIES	'	,	7	,	5133	,	14	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	PUBLIC ADMINISTRATION	'	,	3	,	1174	,	14	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	PUBLIC POLICY	'	,	5	,	11600	,	14	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	AGRICULTURE PRODUCTION AND MANAGEMENT	'	,	3	,	1016	,	15	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	GENERAL AGRICULTURE	'	,	4	,	12188	,	15	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	FORESTRY	'	,	4	,	3910	,	15	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	NATURAL RESOURCES MANAGEMENT	'	,	6	,	13672	,	15	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	PLANT SCIENCE AND AGRONOMY	'	,	6	,	12772	,	15	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	AGRICULTURAL ECONOMICS	'	,	5	,	11046	,	15	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	SOIL SCIENCE	'	,	2	,	11635	,	15	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ANIMAL SCIENCES	'	,	6	,	10880	,	15	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MISCELLANEOUS AGRICULTURE	'	,	6	,	4100	,	15	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	FOOD SCIENCE	'	,	3	,	5489	,	15	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ADVERTISING AND PUBLIC RELATIONS	'	,	8	,	2549	,	16	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MASS MEDIA	'	,	8	,	12357	,	16	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COMMUNICATIONS	'	,	4	,	6219	,	16	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	JOURNALISM	'	,	2	,	13489	,	16	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MECHANICAL ENGINEERING RELATED TECHNOLOGIES	'	,	7	,	9652	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MISCELLANEOUS ENGINEERING TECHNOLOGIES	'	,	6	,	14650	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	INDUSTRIAL PRODUCTION TECHNOLOGIES	'	,	8	,	7850	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ELECTRICAL ENGINEERING TECHNOLOGY	'	,	4	,	9129	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ENGINEERING TECHNOLOGIES	'	,	6	,	6891	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ARCHITECTURAL ENGINEERING	'	,	8	,	2573	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	PETROLEUM ENGINEERING	'	,	2	,	1611	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ENGINEERING AND INDUSTRIAL MANAGEMENT	'	,	3	,	12517	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MISCELLANEOUS ENGINEERING	'	,	5	,	10808	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ARCHITECTURE	'	,	5	,	5366	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	GENERAL ENGINEERING	'	,	4	,	6093	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	CIVIL ENGINEERING	'	,	6	,	11292	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COMPUTER ENGINEERING	'	,	3	,	4853	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MINING AND MINERAL ENGINEERING	'	,	3	,	2112	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MECHANICAL ENGINEERING	'	,	3	,	12537	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	INDUSTRIAL AND MANUFACTURING ENGINEERING	'	,	5	,	11246	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	GEOLOGICAL AND GEOPHYSICAL ENGINEERING	'	,	8	,	11414	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	NAVAL ARCHITECTURE AND MARINE ENGINEERING	'	,	2	,	9914	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ELECTRICAL ENGINEERING	'	,	2	,	10999	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	BIOLOGICAL ENGINEERING	'	,	8	,	13950	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MATERIALS ENGINEERING AND MATERIALS SCIENCE	'	,	6	,	10280	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	CHEMICAL ENGINEERING	'	,	6	,	12454	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	AEROSPACE ENGINEERING	'	,	6	,	13569	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ENVIRONMENTAL ENGINEERING	'	,	3	,	11876	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	METALLURGICAL ENGINEERING	'	,	4	,	5786	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ENGINEERING MECHANICS PHYSICS AND SCIENCE	'	,	2	,	10493	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	NUCLEAR ENGINEERING	'	,	8	,	6538	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	BIOMEDICAL ENGINEERING	'	,	3	,	4158	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MATERIALS SCIENCE	'	,	4	,	9866	,	17	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	CRIMINOLOGY	'	,	4	,	14397	,	18	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	GEOGRAPHY	'	,	6	,	12678	,	18	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	INTERDISCIPLINARY SOCIAL SCIENCES	'	,	5	,	10763	,	18	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	SOCIOLOGY	'	,	3	,	8000	,	18	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	GENERAL SOCIAL SCIENCES	'	,	8	,	14449	,	18	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ECONOMICS	'	,	6	,	10004	,	18	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MISCELLANEOUS SOCIAL SCIENCES	'	,	5	,	4025	,	18	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	POLITICAL SCIENCE AND GOVERNMENT	'	,	6	,	13100	,	18	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	INTERNATIONAL RELATIONS	'	,	2	,	5347	,	18	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MEDICAL TECHNOLOGIES TECHNICIANS	'	,	6	,	1693	,	19	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MEDICAL ASSISTING SERVICES	'	,	8	,	10902	,	19	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	NURSING	'	,	8	,	5067	,	19	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	HEALTH AND MEDICAL ADMINISTRATIVE SERVICES	'	,	6	,	1993	,	19	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	TREATMENT THERAPY PROFESSIONS	'	,	8	,	10946	,	19	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MISCELLANEOUS HEALTH MEDICAL PROFESSIONS	'	,	3	,	14317	,	19	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	GENERAL MEDICAL AND HEALTH SERVICES	'	,	6	,	4519	,	19	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	NUTRITION SCIENCES	'	,	3	,	8889	,	19	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COMMUNITY AND PUBLIC HEALTH	'	,	4	,	10392	,	19	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	PHARMACY PHARMACEUTICAL SCIENCES AND ADMINISTRATION	'	,	6	,	13493	,	19	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COMMUNICATION DISORDERS SCIENCES AND SERVICES	'	,	8	,	12746	,	19	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	HEALTH AND MEDICAL PREPARATORY PROGRAMS	'	,	5	,	9766	,	19	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MULTI/INTERDISCIPLINARY STUDIES	'	,	7	,	4399	,	20	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	NUCLEAR, INDUSTRIAL RADIOLOGY, AND BIOLOGICAL TECHNOLOGIES	'	,	8	,	9039	,	21	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MULTI-DISCIPLINARY OR GENERAL SCIENCE	'	,	5	,	2132	,	21	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	OCEANOGRAPHY	'	,	3	,	4793	,	21	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	GEOLOGY AND EARTH SCIENCE	'	,	7	,	3872	,	21	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	PHYSICAL SCIENCES	'	,	3	,	8894	,	21	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ATMOSPHERIC SCIENCES AND METEOROLOGY	'	,	5	,	5066	,	21	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	GEOSCIENCES	'	,	2	,	12574	,	21	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ASTRONOMY AND ASTROPHYSICS	'	,	4	,	8578	,	21	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	CHEMISTRY	'	,	6	,	2068	,	21	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	PHYSICS	'	,	2	,	1745	,	21	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	LIBERAL ARTS	'	,	6	,	3420	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COMPOSITION AND RHETORIC	'	,	7	,	7826	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	HUMANITIES	'	,	3	,	14148	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ART HISTORY AND CRITICISM	'	,	3	,	9621	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	INTERCULTURAL AND INTERNATIONAL STUDIES	'	,	7	,	10193	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	THEOLOGY AND RELIGIOUS VOCATIONS	'	,	7	,	14034	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	LINGUISTICS AND COMPARATIVE LANGUAGE AND LITERATURE	'	,	4	,	7888	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ANTHROPOLOGY AND ARCHEOLOGY	'	,	4	,	5957	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ENGLISH LANGUAGE AND LITERATURE	'	,	7	,	11079	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	OTHER FOREIGN LANGUAGES	'	,	3	,	1011	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	AREA ETHNIC AND CIVILIZATION STUDIES	'	,	7	,	4109	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	HISTORY	'	,	5	,	3671	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	FRENCH GERMAN LATIN AND OTHER COMMON FOREIGN LANGUAGE STUDIES	'	,	2	,	13456	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	UNITED STATES HISTORY	'	,	4	,	1786	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	PHILOSOPHY AND RELIGIOUS STUDIES	'	,	4	,	12835	,	22	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	HUMAN SERVICES AND COMMUNITY ORGANIZATION	'	,	6	,	5206	,	23	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	SOCIAL PSYCHOLOGY	'	,	5	,	9469	,	23	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	INDUSTRIAL AND ORGANIZATIONAL PSYCHOLOGY	'	,	3	,	9077	,	23	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	SOCIAL WORK	'	,	5	,	11941	,	23	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	PSYCHOLOGY	'	,	8	,	3049	,	23	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MISCELLANEOUS PSYCHOLOGY	'	,	7	,	2501	,	23	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	EDUCATIONAL PSYCHOLOGY	'	,	3	,	7499	,	23	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COUNSELING PSYCHOLOGY	'	,	8	,	1728	,	23	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	CLINICAL PSYCHOLOGY	'	,	6	,	4230	,	23	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ENVIRONMENTAL SCIENCE	'	,	4	,	3532	,	24	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ECOLOGY	'	,	6	,	6496	,	24	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MISCELLANEOUS BIOLOGY	'	,	5	,	13600	,	24	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	COGNITIVE SCIENCE AND BIOPSYCHOLOGY	'	,	4	,	12067	,	24	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MICROBIOLOGY	'	,	4	,	8237	,	24	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	BOTANY	'	,	5	,	10627	,	24	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	BIOLOGY	'	,	3	,	2009	,	24	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	PHYSIOLOGY	'	,	8	,	13139	,	24	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MOLECULAR BIOLOGY	'	,	6	,	12405	,	24	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	PHARMACOLOGY	'	,	3	,	13671	,	24	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ZOOLOGY	'	,	5	,	14091	,	24	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	NEUROSCIENCE	'	,	5	,	3316	,	24	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	BIOCHEMICAL SCIENCES	'	,	5	,	2350	,	24	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	GENETICS	'	,	2	,	1612	,	24	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	EARLY CHILDHOOD EDUCATION	'	,	6	,	13565	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	PHYSICAL AND HEALTH EDUCATION TEACHING	'	,	6	,	1409	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MISCELLANEOUS EDUCATION	'	,	8	,	7391	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ELEMENTARY EDUCATION	'	,	8	,	4537	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	GENERAL EDUCATION	'	,	5	,	6303	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	ART AND MUSIC EDUCATION	'	,	4	,	5968	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	TEACHER EDUCATION: MULTIPLE LEVELS	'	,	2	,	6597	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	SOCIAL SCIENCE OR HISTORY TEACHER EDUCATION	'	,	4	,	1059	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	SECONDARY TEACHER EDUCATION	'	,	8	,	9320	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	LANGUAGE AND DRAMA EDUCATION	'	,	8	,	12817	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	MATHEMATICS TEACHER EDUCATION	'	,	7	,	5020	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	SCIENCE AND COMPUTER TEACHER EDUCATION	'	,	4	,	5300	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	SPECIAL NEEDS EDUCATION	'	,	2	,	4032	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	LIBRARY SCIENCE	'	,	4	,	3363	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	SCHOOL STUDENT COUNSELING	'	,	6	,	8334	,	25	)	;
INSERT INTO PROGRAM 	(PROGRAM_ID, PROGRAM_NAME, NO_OF_TERMS, FEES, DEPARTMENT_ID) 	VALUES (	PROGRAM_ID_SEQ.nextval, 	'	EDUCATIONAL ADMINISTRATION AND SUPERVISION	'	,	8	,	13834	,	25	)	;

-- credits for the original database:
-- https://github.com/fivethirtyeight/data/blob/master/college-majors/majors-list.csv#L12

-- STUDENT table
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Fancy', null, 'Kydde', '124-172-9226', 'wkydde0@blogger.com', '50 Armistice Terrace', 'Philippines', null, '6216', 0, '4965074475', '', '30-Dec-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Irwin', 'Salomi', 'Fairrie', '580-428-0653', 'sfairrie1@spotify.com', '76 Nova Place', 'China', null, null, 0, '0223934186', '', '13-Jun-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Stormie', 'Ealasaid', 'Barthelme', '732-891-8061', 'ebarthelme2@sohu.com', '3 Coleman Lane', 'Mexico', null, '97714', 0, '6352219152', '', '15-Mar-2004');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Doe', 'Lilian', 'Flounders', '426-255-5988', 'lflounders3@businessinsider.com', '3994 Main Pass', 'China', null, null, 0, '4030868002', '', '14-Jul-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Gallard', null, 'Perrot', '419-912-3573', 'rperrot4@howstuffworks.com', '27 Iowa Parkway', 'Indonesia', null, null, 0, '3625463431', '', '12-Jun-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Izzy', null, 'Garrioch', '615-357-1530', 'zgarrioch5@auda.org.au', '2 Pennsylvania Drive', 'China', null, null, 0, '4966328705', '', '30-Nov-1982');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Leelah', null, 'Einchcombe', '982-611-8760', 'weinchcombe6@hp.com', '9868 Golf View Way', 'Indonesia', null, null, 0, '1616250933', '', '31-Oct-2004');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Amelie', null, 'Ramalhete', '343-578-8860', 'vramalhete7@pagesperso-orange.fr', '9 Hoffman Hill', 'Brazil', null, '32900-000', 0, '4523620369', '', '29-Jul-1995');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Lotty', 'Cheston', 'O''Fallowne', '710-634-3587', 'cofallowne8@macromedia.com', '35607 Northport Street', 'Morocco', null, null, 0, '0745291686', '', '09-May-2000');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Vaughn', null, 'Tiernan', '735-418-8722', 'otiernan9@archive.org', '85767 Farmco Court', 'Indonesia', null, null, 0, '3975218150', '', '28-Aug-1983');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Yorke', null, 'Worsall', '497-884-2267', 'aworsalla@noaa.gov', '39 Pawling Place', 'China', null, null, 0, '2281094391', '', '07-Apr-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Tine', null, 'Snelson', '798-996-7286', 'hsnelsonb@w3.org', '05 Merry Point', 'China', null, null, 0, '2303464625', '', '09-Aug-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Irena', 'Teressa', 'Kivelle', '881-976-3245', 'tkivellec@dailymotion.com', '84 Parkside Street', 'Philippines', null, '2422', 0, '0555242048', '', '13-Feb-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Benjie', null, 'Chape', '920-433-8287', 'tchaped@narod.ru', '1120 Ridge Oak Parkway', 'Morocco', null, null, 0, '5978575630', '', '06-Sep-2004');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Demetria', null, 'Jedrzejkiewicz', '494-931-8227', 'ajedrzejkiewicze@ezinearticles.com', '52680 Nelson Avenue', 'China', null, null, 0, '9784330709', '', '09-Oct-1982');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Tedd', null, 'Galier', '637-882-4344', 'mgalierf@harvard.edu', '280 Thompson Parkway', 'Thailand', null, '11130', 0, '1462162568', '', '05-Mar-1982');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Christean', null, 'Boot', '692-684-7446', 'pbootg@networkadvertising.org', '0559 7th Crossing', 'Indonesia', null, null, 0, '7704237675', '', '29-Aug-1993');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Andros', 'Darill', 'Hawking', '476-951-2642', 'dhawkingh@ifeng.com', '43722 Burning Wood Drive', 'China', null, null, 0, '0790848015', '', '28-Feb-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Aundrea', null, 'Shillaker', '428-610-6304', 'hshillakeri@zdnet.com', '15 Montana Circle', 'Philippines', null, '6711', 0, '5383992944', '', '28-May-1995');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Ruthann', null, 'Privost', '807-301-0680', 'jprivostj@tumblr.com', '93 Esker Circle', 'China', null, null, 0, '2280109905', '', '16-Feb-1997');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Rosalynd', null, 'Lownds', '409-453-7426', 'blowndsk@about.com', '08793 Artisan Plaza', 'Philippines', null, '2446', 0, '5585522078', '', '21-Mar-1994');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Lora', null, 'Churching', '546-675-6842', 'echurchingl@virginia.edu', '8 Messerschmidt Pass', 'Philippines', null, '8305', 0, '0305475126', '', '12-Jan-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Benjy', null, 'Oldroyd', '317-883-8031', 'joldroydm@omniture.com', '8 Bunker Hill Terrace', 'Indonesia', null, null, 0, '3499902621', '', '03-Oct-2004');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Broderick', null, 'Jillis', '503-816-0114', 'kjillisn@vinaora.com', '6 Eagle Crest Hill', 'Brazil', null, '35650-000', 0, '6207429788', '', '01-Jun-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Matteo', null, 'Khalid', '478-606-1758', 'akhalido@mtv.com', '71833 Sullivan Parkway', 'China', null, null, 0, '2570555479', '', '19-Jun-1989');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Benn', null, 'Peperell', '442-564-4168', 'npeperellp@indiegogo.com', '30 Harper Plaza', 'Indonesia', null, null, 0, '0231060823', '', '10-Dec-1996');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Kirsteni', 'Kelcy', 'Griffith', '498-842-9474', 'kgriffithq@histats.com', '456 Park Meadow Street', 'China', null, null, 0, '9614735384', '', '19-Jun-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Alaric', null, 'Umfrey', '863-953-8207', 'tumfreyr@vistaprint.com', '9 Kinsman Point', 'China', null, null, 0, '0653129807', '', '08-Feb-1995');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Xylina', null, 'Lynn', '967-466-6849', 'clynns@phoca.cz', '79463 Waxwing Avenue', 'Brazil', null, null, 0, '0129690430', '', '10-May-1996');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Kendricks', null, 'Frensche', '100-624-2129', 'pfrenschet@uol.com.br', '74310 Truax Court', 'China', null, null, 0, '4616659885', '', '16-Jun-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Hurley', 'Effie', 'Leate', '870-352-6374', 'eleateu@google.ca', '7 Harbort Center', 'China', null, null, 0, '9483367298', '', '07-Nov-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Lizzy', null, 'Astley', '256-281-6847', 'fastleyv@comcast.net', '11900 Londonderry Lane', 'Indonesia', null, null, 0, '2329596480', '', '26-Oct-1995');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Jaime', null, 'Fishly', '324-952-7460', 'sfishlyw@theguardian.com', '7 Dixon Trail', 'Brazil', null, '44700-000', 0, '7648779323', '', '25-Mar-1989');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Gaye', null, 'Bedboro', '660-220-9117', 'lbedborox@cbslocal.com', '36055 Lakewood Lane', 'China', null, null, 0, '4273198630', '', '13-Jun-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Cosimo', null, 'Arundell', '436-560-3876', 'rarundelly@pcworld.com', '0 Homewood Road', 'Indonesia', null, null, 0, '1185703314', '', '14-May-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Jessie', null, 'Ferebee', '281-617-9826', 'bferebeez@shop-pro.jp', '3 Old Gate Place', 'Peru', null, null, 0, '9413128006', '', '20-Jan-1981');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Delora', null, 'Clingoe', '879-647-9983', 'oclingoe10@scientificamerican.com', '51 Welch Drive', 'Brazil', null, '95590-000', 0, '0127608699', '', '12-Aug-1993');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Wolf', null, 'Beeble', '261-831-1497', 'mbeeble11@bizjournals.com', '451 Anhalt Way', 'Peru', null, null, 0, '9447010318', '', '01-Apr-2001');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Merle', null, 'Bakey', '943-463-3090', 'bbakey12@pcworld.com', '2666 Heffernan Avenue', 'Indonesia', null, null, 0, '1915655668', '', '16-Nov-2004');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Sascha', null, 'Hounsham', '518-255-1000', 'ahounsham13@booking.com', '39683 Columbus Pass', 'Philippines', null, '4025', 0, '9915715404', '', '01-Oct-2000');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Lorianne', null, 'Nassau', '145-361-2754', 'mnassau14@washington.edu', '3 Brentwood Hill', 'China', null, null, 0, '0719777828', '', '30-Mar-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Renie', null, 'Crichten', '454-612-2457', 'kcrichten15@so-net.ne.jp', '3785 Luster Way', 'Brazil', null, '85900-000', 0, '7799667001', '', '29-Sep-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Hildegarde', null, 'Bofield', '424-831-3001', 'lbofield16@upenn.edu', '3 Shopko Point', 'Brazil', null, '14900-000', 0, '7781087666', '', '18-May-1997');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Trip', null, 'Mathew', '826-756-0350', 'bmathew17@dyndns.org', '04 Pierstorff Trail', 'Indonesia', null, null, 0, '6546582244', '', '05-Dec-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Aylmer', 'Robenia', 'MacKaig', '230-548-1265', 'rmackaig18@zdnet.com', '3957 Armistice Court', 'Philippines', null, '7210', 0, '4284088688', '', '18-Sep-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Maryl', null, 'Fuentes', '864-327-6230', 'ifuentes19@wikipedia.org', '88179 Barnett Street', 'Indonesia', null, null, 0, '2013080395', '', '05-Jun-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Maurie', null, 'Sargerson', '226-224-9411', 'msargerson1a@ovh.net', '0484 Memorial Junction', 'Philippines', null, null, 0, '2505707928', '', '01-Dec-1994');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Jimmy', null, 'Arundale', '139-276-4249', 'aarundale1b@bbb.org', '73644 Welch Crossing', 'China', null, null, 0, '7146659755', '', '15-Sep-1989');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Codie', 'Stanfield', 'Hebblethwaite', '544-750-3060', 'shebblethwaite1c@wikipedia.org', '1 Hoard Place', 'Indonesia', null, null, 0, '5992946365', '', '23-Mar-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Gretta', null, 'Whitely', '399-486-3272', 'swhitely1d@techcrunch.com', '939 Myrtle Avenue', 'China', null, null, 0, '0203126734', '', '16-Sep-1996');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Nessa', null, 'Ronchetti', '551-610-6214', 'tronchetti1e@mysql.com', '2976 Mendota Crossing', 'Thailand', null, null, 0, '7786442081', '', '28-Dec-1987');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Jeanie', null, 'Matyashev', '544-535-9851', 'jmatyashev1f@linkedin.com', '588 Melby Road', 'Indonesia', null, null, 0, '1309921768', '', '24-Dec-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Channa', null, 'Heggie', '542-638-1129', 'pheggie1g@myspace.com', '3 Basil Road', 'China', null, null, 0, '6531710098', '', '16-Apr-1987');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Obadias', null, 'Rolfi', '775-332-5712', 'frolfi1h@gravatar.com', '64 Parkside Pass', 'United States', null, '89519', 0, '5892262502', '', '04-Nov-1989');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Roth', null, 'Roxbee', '902-757-4720', 'yroxbee1i@noaa.gov', '4 Linden Crossing', 'China', null, null, 0, '0255797060', '', '18-Jul-1987');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Bryana', null, 'Kemell', '561-475-8169', 'dkemell1j@reference.com', '113 La Follette Crossing', 'Indonesia', null, null, 0, '3029169413', '', '03-Feb-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Julissa', null, 'Martinec', '209-988-6001', 'amartinec1k@sogou.com', '3104 Village Green Terrace', 'United States', null, '93715', 0, '1005294011', '', '10-Aug-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Lia', null, 'Rawstorn', '705-957-9620', 'trawstorn1l@joomla.org', '6461 Blaine Way', 'Indonesia', null, null, 0, '8569067879', '', '06-Mar-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Bibbye', 'Leta', 'Slowcock', '478-290-1080', 'lslowcock1m@tinyurl.com', '0 Westerfield Hill', 'Indonesia', null, null, 0, '5018497351', '', '10-Nov-2003');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Kellby', null, 'Wedon', '646-978-9460', 'iwedon1n@mapy.cz', '2 Londonderry Alley', 'United States', null, null, 0, '8528389448', '', '14-Feb-2003');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Bayard', 'Desi', 'Lacase', '405-305-0410', 'dlacase1o@yellowbook.com', '9 Grover Alley', 'United States', null, '73167', 0, '3463610248', '', '15-Jul-1987');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Raimund', 'Tiebout', 'Service', '916-501-0079', 'tservice1p@tmall.com', '3 Darwin Court', 'Canada', 'MB', 'J7X', 1, '4243951179', '999999999', '07-Jan-1997');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Arluene', null, 'Thonger', '917-984-0064', 'kthonger1q@telegraph.co.uk', '5542 Dottie Street', 'China', null, null, 0, '7773630259', '', '05-Jul-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Elnora', 'Rebecca', 'Osbourne', '400-403-6530', 'rosbourne1r@google.ca', '51 Fuller Place', 'Indonesia', null, null, 0, '9718327088', '', '20-Oct-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Bank', null, 'McKinnon', '728-114-9681', 'gmckinnon1s@java.com', '2 Maple Avenue', 'Brazil', null, '13480-000', 0, '2882130201', '', '28-Aug-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Humfried', null, 'Graeme', '713-249-1051', 'sgraeme1t@about.com', '28600 Birchwood Court', 'United States', null, '77085', 0, '0686862724', '', '25-Dec-1995');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Tommie', null, 'Collibear', '973-567-4229', 'ccollibear1u@themeforest.net', '32715 Sycamore Drive', 'Indonesia', null, null, 0, '1061187764', '', '27-Mar-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Irvin', null, 'Tumelty', '891-902-3145', 'jtumelty1v@mysql.com', '782 Forster Trail', 'Indonesia', null, null, 0, '9136953474', '', '25-Mar-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Maddalena', null, 'Osgar', '813-805-0015', 'rosgar1w@mozilla.org', '2 Grim Crossing', 'Mexico', null, null, 0, '5930415382', '', '14-Oct-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Bren', 'Jesselyn', 'Ghidini', '322-858-8335', 'jghidini1x@shinystat.com', '55287 Lerdahl Junction', 'Mexico', null, '45310', 0, '4296694383', '', '06-Oct-1987');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Lisetta', null, 'Ortelt', '129-528-2399', 'cortelt1y@canalblog.com', '76 Doe Crossing Street', 'China', null, null, 0, '8046796948', '', '22-May-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Tiphany', null, 'Houseley', '962-202-9148', 'khouseley1z@123-reg.co.uk', '94709 Ryan Trail', 'China', null, null, 0, '9501355292', '', '24-Apr-2004');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Teena', 'Rae', 'Camsey', '236-450-9325', 'rcamsey20@walmart.com', '6410 Charing Cross Terrace', 'Peru', null, null, 0, '9739114091', '', '28-Oct-1987');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Blanche', null, 'Ladel', '418-372-4656', 'pladel21@java.com', '8 Parkside Pass', 'China', null, null, 0, '4659604837', '', '03-Nov-2001');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Tabatha', null, 'Gandey', '804-869-3616', 'cgandey22@ucoz.com', '26 Saint Paul Place', 'Indonesia', null, null, 0, '3887973976', '', '15-Sep-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Adella', null, 'Tointon', '866-465-5728', 'ttointon23@printfriendly.com', '74 Myrtle Alley', 'Brazil', null, '07000-000', 0, '1810172209', '', '13-Oct-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Vernon', null, 'Zavattero', '733-998-5678', 'czavattero24@theatlantic.com', '70 Dottie Court', 'China', null, null, 0, '3458297324', '', '11-Nov-2004');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Janka', null, 'Trouncer', '937-284-0965', 'dtrouncer25@netlog.com', '6 Sherman Point', 'China', null, null, 0, '4816472541', '', '27-Apr-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Ara', 'Levin', 'Brussell', '747-861-4146', 'lbrussell26@pbs.org', '9 Maple Wood Pass', 'Palestinian Territory', null, null, 0, '3688754964', '', '05-Mar-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Giavani', 'Neddie', 'Lamberti', '327-903-9662', 'nlamberti27@g.co', '872 Dahle Alley', 'Indonesia', null, null, 0, '3966767546', '', '31-Mar-2001');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Aubrette', 'Elbertina', 'McClelland', '277-481-8252', 'emcclelland28@themeforest.net', '41778 International Trail', 'Indonesia', null, null, 0, '9780584722', '', '17-Aug-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Mikaela', 'Bettine', 'Aronoff', '755-891-3952', 'baronoff29@lycos.com', '015 Buhler Junction', 'China', null, null, 0, '0596589018', '', '05-Feb-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Randi', 'Jarib', 'Guile', '265-979-3064', 'jguile2a@slideshare.net', '3239 Blaine Trail', 'Philippines', null, '8301', 0, '2552449433', '', '15-Aug-1982');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Garrick', null, 'Posthill', '453-655-0733', 'lposthill2b@independent.co.uk', '1230 Sutherland Crossing', 'Indonesia', null, null, 0, '1993698795', '', '21-Sep-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Karlotta', null, 'Pepye', '134-586-6435', 'tpepye2c@hc360.com', '76881 Banding Avenue', 'Philippines', null, '8302', 0, '5881558219', '', '23-Apr-1995');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Emelia', 'Pate', 'Candish', '517-132-6827', 'pcandish2d@usatoday.com', '8467 Debra Crossing', 'Indonesia', null, null, 0, '3171717379', '', '17-Nov-1987');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Tiphany', null, 'Siverns', '259-111-2442', 'bsiverns2e@oakley.com', '7 Rusk Pass', 'China', null, null, 0, '5553234034', '', '11-Oct-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Raimund', null, 'Shrimplin', '396-565-0540', 'wshrimplin2f@hp.com', '18 Knutson Junction', 'Canada', 'YT', 'N2R', 1, '5058924021', '999999999', '10-Jul-2004');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Tamma', null, 'Hamman', '340-747-6004', 'chamman2g@acquirethisname.com', '433 Lukken Alley', 'Brazil', null, '13710-000', 0, '1885434308', '', '31-Jul-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Brendon', 'Shamus', 'Gillanders', '477-369-3000', 'sgillanders2h@photobucket.com', '32 Loomis Terrace', 'China', null, null, 0, '5138741411', '', '28-Jul-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Rab', null, 'Absolom', '963-491-6659', 'babsolom2i@tripod.com', '89 Pankratz Parkway', 'China', null, null, 0, '4755470080', '', '17-Nov-2000');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Nicolai', 'Emmalyn', 'Axe', '124-693-4621', 'eaxe2j@blogtalkradio.com', '1791 Roth Street', 'Philippines', null, '6521', 0, '3195986043', '', '28-Jul-1989');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Osbourn', null, 'Lill', '494-285-3321', 'glill2k@g.co', '817 Forest Junction', 'China', null, null, 0, '1590884159', '', '27-Dec-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Doloritas', null, 'Scobbie', '727-370-2880', 'oscobbie2l@facebook.com', '1 Claremont Street', 'Mexico', null, '42082', 0, '0505340631', '', '09-Oct-1985');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Micah', null, 'Friatt', '771-910-8610', 'lfriatt2m@xing.com', '48 Springs Court', 'China', null, null, 0, '9651192356', '', '24-Oct-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Alvan', 'Valdemar', 'Rosenau', '505-120-4573', 'vrosenau2n@goodreads.com', '5 Service Circle', 'Thailand', null, '67110', 0, '4703382881', '', '11-Jun-1987');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Mandie', null, 'Yelland', '779-254-1699', 'syelland2o@ucsd.edu', '44089 Towne Junction', 'China', null, null, 0, '2390844952', '', '28-Dec-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Haze', null, 'Beane', '348-404-6327', 'vbeane2p@skyrock.com', '31 Delaware Terrace', 'Indonesia', null, null, 0, '4347218923', '', '29-Jan-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Sheffie', null, 'Morde', '327-901-2112', 'emorde2q@dyndns.org', '551 Jay Way', 'Philippines', null, '8715', 0, '9117510945', '', '04-Apr-1987');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Walker', null, 'Collcott', '550-126-7365', 'ccollcott2r@blogs.com', '3 Grover Junction', 'Philippines', null, '6525', 0, '3671720301', '', '16-Mar-2001');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Cherise', null, 'Kohter', '378-935-6725', 'lkohter2s@upenn.edu', '3247 Dottie Avenue', 'Philippines', null, '8305', 0, '4041387299', '', '04-Apr-1990');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Erminie', 'Matthus', 'Bastock', '675-875-3629', 'mbastock2t@studiopress.com', '84078 Cascade Street', 'Indonesia', null, null, 0, '3592027026', '', '11-Mar-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Carmel', null, 'Wareham', '128-921-0604', 'swareham2u@privacy.gov.au', '9 Forster Parkway', 'Indonesia', null, null, 0, '6928555459', '', '01-May-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Virgina', null, 'Delleschi', '355-481-5771', 'bdelleschi2v@nifty.com', '624 Bunker Hill Parkway', 'Indonesia', null, null, 0, '0924528532', '', '10-Mar-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Heidie', null, 'Daspar', '711-558-9344', 'gdaspar2w@tmall.com', '8266 Eggendart Alley', 'Morocco', null, null, 0, '3409052402', '', '02-May-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Ramsey', 'Konrad', 'Fitzmaurice', '265-403-6066', 'kfitzmaurice2x@google.nl', '02 Ronald Regan Park', 'China', null, null, 0, '6103941237', '', '18-Jan-1989');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Dominica', null, 'Bettis', '735-365-3960', 'vbettis2y@dot.gov', '35 Claremont Road', 'China', null, null, 0, '5967539565', '', '17-Dec-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Abey', null, 'Atwater', '205-545-3511', 'satwater2z@economist.com', '8 Graceland Pass', 'China', null, null, 0, '2710536137', '', '18-Jan-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Larine', null, 'Petersen', '518-108-8645', 'lpetersen30@huffingtonpost.com', '3540 8th Avenue', 'Philippines', null, '7033', 0, '7825533011', '', '16-Apr-1985');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Yehudi', null, 'Josskoviz', '369-656-9909', 'cjosskoviz31@quantcast.com', '2202 Hooker Trail', 'Indonesia', null, null, 0, '9563569326', '', '29-May-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Elwood', null, 'Parrott', '922-987-9652', 'iparrott32@yellowbook.com', '14 Fairview Terrace', 'Philippines', null, '5615', 0, '8533334397', '', '10-Jun-1989');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Estrella', null, 'Farn', '993-990-2983', 'dfarn33@indiatimes.com', '9217 Lake View Trail', 'Brazil', null, '59990-000', 0, '7756737075', '', '30-Sep-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Angeli', null, 'Weedon', '560-863-7686', 'aweedon34@barnesandnoble.com', '96729 Petterle Drive', 'Canada', 'YT', 'T3S', 1, '1605303860', '999999999', '24-Mar-2001');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Imogene', null, 'Pridie', '770-968-2421', 'spridie35@gov.uk', '85734 Mockingbird Street', 'Brazil', null, '45860-000', 0, '9338256529', '', '29-Apr-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Cari', 'Juditha', 'Dafydd', '395-655-2537', 'jdafydd36@soundcloud.com', '445 Lukken Terrace', 'Philippines', null, '5514', 0, '9939470479', '', '24-Jun-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Alaric', 'Glennie', 'Poulsum', '640-549-1762', 'gpoulsum37@ox.ac.uk', '5 Lunder Pass', 'China', null, null, 0, '5001254760', '', '08-Jul-2000');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Charlot', null, 'Brayley', '288-468-0860', 'bbrayley38@who.int', '4 Lillian Park', 'China', null, null, 0, '0941244059', '', '08-Jul-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Coralie', null, 'Hulle', '414-171-6540', 'bhulle39@virginia.edu', '97 Petterle Street', 'China', null, null, 0, '5731480613', '', '13-Dec-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Jaquelin', null, 'Kleinsmuntz', '653-427-8344', 'akleinsmuntz3a@amazon.de', '1 Westerfield Avenue', 'Philippines', null, '3332', 0, '8912601318', '', '01-Mar-1989');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Way', null, 'Fredi', '534-944-4709', 'dfredi3b@nifty.com', '71868 Tennyson Center', 'China', null, null, 0, '8284695189', '', '17-Mar-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Ardenia', null, 'Beaument', '735-904-5214', 'bbeaument3c@ca.gov', '7017 Sunnyside Trail', 'China', null, null, 0, '4216297420', '', '02-Jun-1987');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Ellsworth', null, 'Stedall', '623-968-2871', 'rstedall3d@psu.edu', '2 Dahle Alley', 'United States', null, '85025', 0, '8012302942', '', '02-Feb-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Nettle', 'Lazarus', 'Arstingall', '548-571-5127', 'larstingall3e@seattletimes.com', '77 Anthes Way', 'China', null, null, 0, '8619200771', '', '12-Dec-1997');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Gilbertina', null, 'Pennetta', '475-219-4320', 'lpennetta3f@craigslist.org', '97861 Alpine Circle', 'China', null, null, 0, '9305312233', '', '28-Dec-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Rebecka', 'Barbie', 'Hancill', '266-514-5858', 'bhancill3g@eventbrite.com', '3337 Novick Road', 'Philippines', null, '3501', 0, '3924878404', '', '12-Nov-1981');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Reinhold', 'Laureen', 'Gawthorpe', '871-108-1908', 'lgawthorpe3h@timesonline.co.uk', '71 Bonner Avenue', 'Brazil', null, '86730-000', 0, '7720053842', '', '04-Jan-2004');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Hadlee', null, 'Calderon', '288-193-2379', 'rcalderon3i@statcounter.com', '2371 Hollow Ridge Point', 'Thailand', null, '33270', 0, '4559584281', '', '25-Mar-2003');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Ward', 'Renell', 'Rosenbush', '654-919-9841', 'rrosenbush3j@wunderground.com', '7385 Ohio Point', 'Indonesia', null, null, 0, '0284732249', '', '25-Dec-1997');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Charla', null, 'Norley', '132-242-3088', 'jnorley3k@mozilla.com', '2 Loeprich Center', 'Indonesia', null, null, 0, '3787332901', '', '23-Aug-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Yorgo', null, 'Brackstone', '217-879-7474', 'ibrackstone3l@a8.net', '9354 Drewry Center', 'United States', null, '62756', 0, '9911769283', '', '21-Nov-1995');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Karin', null, 'Ewert', '645-161-0439', 'tewert3m@google.cn', '3192 Meadow Ridge Lane', 'Philippines', null, '2612', 0, '6921476618', '', '29-Apr-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Cher', 'Susanetta', 'Stacey', '517-872-4847', 'sstacey3n@bbb.org', '2930 David Center', 'Brazil', null, '13990-000', 0, '9768211962', '', '17-May-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Gaylord', null, 'Marquis', '335-302-8941', 'kmarquis3o@flickr.com', '10 Huxley Parkway', 'China', null, null, 0, '9214056560', '', '31-Mar-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Jannel', 'Drew', 'Hastwell', '623-496-4313', 'dhastwell3p@moonfruit.com', '1 Springview Way', 'Brazil', null, '89665-000', 0, '1412409454', '', '19-Nov-1996');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Cathrin', null, 'Duckerin', '707-985-8788', 'sduckerin3q@163.com', '955 Canary Lane', 'Indonesia', null, null, 0, '9902924093', '', '28-Mar-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Roseline', null, 'Brophy', '467-655-7180', 'sbrophy3r@businessweek.com', '32010 Darwin Park', 'Indonesia', null, null, 0, '5798644111', '', '25-Apr-2000');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Elva', null, 'Chalfont', '891-937-7708', 'kchalfont3s@friendfeed.com', '8220 Hollow Ridge Avenue', 'China', null, null, 0, '6495798490', '', '18-Mar-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Dawna', 'Mata', 'Semrad', '372-895-9935', 'msemrad3t@cnn.com', '8257 American Ash Alley', 'China', null, null, 0, '7742231425', '', '29-Oct-1999');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Benjamin', null, 'Harding', '861-615-3093', 'jharding3u@fotki.com', '5938 Lukken Parkway', 'Brazil', null, '68650-000', 0, '6267309487', '', '24-Mar-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Collete', 'Fremont', 'Gasquoine', '415-532-4128', 'fgasquoine3v@joomla.org', '3 Ohio Point', 'Philippines', null, '6417', 0, '8798850768', '', '13-Dec-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Orelee', 'Gerrard', 'Bleesing', '491-443-0807', 'gbleesing3w@adobe.com', '23 Elgar Street', 'Brazil', null, '38280-000', 0, '7797478090', '', '17-Jul-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Garrik', 'Merrie', 'Sygroves', '377-431-0200', 'msygroves3x@gnu.org', '31581 Lakeland Alley', 'Philippines', null, null, 0, '8372859485', '', '01-Apr-1985');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Karole', 'Merrill', 'Tissell', '927-445-7574', 'mtissell3y@stumbleupon.com', '9 Harbort Terrace', 'China', null, null, 0, '2681426103', '', '13-Jul-1999');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Gwendolen', null, 'Pennings', '514-255-8393', 'gpennings3z@simplemachines.org', '78 Carioca Point', 'China', null, null, 0, '2805300521', '', '30-Jan-1989');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Celina', null, 'Markwick', '958-271-0354', 'emarkwick40@icio.us', '5 Welch Circle', 'Mexico', null, null, 0, '6518154349', '', '29-Sep-1996');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Zelig', null, 'Spiteri', '984-588-3582', 'pspiteri41@ow.ly', '8502 Mosinee Lane', 'China', null, null, 0, '1542328101', '', '15-Jul-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Nelly', null, 'Grotty', '185-797-0438', 'ogrotty42@fotki.com', '558 Namekagon Point', 'China', null, null, 0, '6780201731', '', '05-Dec-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Stearne', null, 'Leathers', '179-706-1202', 'rleathers43@gnu.org', '9 Westend Road', 'China', null, null, 0, '4896491084', '', '08-Sep-1996');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Forster', null, 'Manass', '717-191-1739', 'jmanass44@example.com', '48 Glendale Way', 'United States', null, '17110', 0, '9767663320', '', '31-Jan-1983');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Charlean', 'Bernard', 'Nan Carrow', '611-763-3732', 'bnancarrow45@tripadvisor.com', '287 Hansons Street', 'China', null, null, 0, '5842880822', '', '19-Oct-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Kary', null, 'Worwood', '811-892-9885', 'aworwood46@fotki.com', '593 Mesta Court', 'China', null, null, 0, '2443438236', '', '07-Sep-1983');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Asher', null, 'Lyburn', '336-442-3329', 'mlyburn47@ning.com', '36761 Monterey Point', 'United States', null, null, 0, '7647908820', '', '20-Jun-2004');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Cristin', null, 'Swainsbury', '228-907-2166', 'cswainsbury48@purevolume.com', '27 Little Fleur Parkway', 'Indonesia', null, null, 0, '8759675845', '', '13-Jun-2000');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Yelena', null, 'Steger', '751-179-9776', 'nsteger49@printfriendly.com', '32 Mifflin Lane', 'Peru', null, null, 0, '1794267808', '', '19-Nov-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Sharia', null, 'Ockenden', '406-803-5040', 'lockenden4a@elegantthemes.com', '59 Bunting Street', 'China', null, null, 0, '9614000015', '', '24-May-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Verene', null, 'Battrick', '874-680-5154', 'ebattrick4b@cam.ac.uk', '45 Columbus Plaza', 'Indonesia', null, null, 0, '1668519518', '', '19-May-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Anallese', null, 'Bellwood', '566-963-0310', 'abellwood4c@rediff.com', '7434 Everett Avenue', 'China', null, null, 0, '5064174667', '', '07-Nov-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Evy', null, 'Dobble', '547-550-5707', 'sdobble4d@unblog.fr', '47 Laurel Hill', 'China', null, null, 0, '7936646817', '', '15-May-2001');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Alasdair', null, 'Giblin', '186-422-9111', 'cgiblin4e@twitpic.com', '6 Eggendart Drive', 'Philippines', null, '5409', 0, '1892169398', '', '29-Jan-2003');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Dulcinea', null, 'Reisk', '271-878-0240', 'areisk4f@yolasite.com', '1 Barby Plaza', 'Mexico', null, '88600', 0, '9121812918', '', '11-Feb-1985');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Antonie', null, 'Siemon', '527-985-8147', 'bsiemon4g@vk.com', '78602 Gulseth Terrace', 'Canada', 'YT', 'L9H', 1, '0350373450', '999999999', '21-Jan-1999');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Findley', null, 'Fishbourn', '812-325-4144', 'gfishbourn4h@geocities.jp', '78 Mitchell Court', 'China', null, null, 0, '6991795623', '', '05-Nov-1982');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Trina', null, 'Kersley', '546-244-5782', 'lkersley4i@mlb.com', '721 Dakota Court', 'China', null, null, 0, '4457142689', '', '13-May-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Kellie', null, 'Gallie', '774-845-8230', 'wgallie4j@edublogs.org', '123 Everett Circle', 'Indonesia', null, null, 0, '1635294789', '', '22-Mar-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Opal', null, 'Ordelt', '238-868-4988', 'aordelt4k@microsoft.com', '7195 Gateway Alley', 'Indonesia', null, null, 0, '4170706064', '', '19-Jan-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Stephan', null, 'Junes', '144-923-1593', 'hjunes4l@yahoo.co.jp', '0 Rusk Circle', 'Indonesia', null, null, 0, '4130342452', '', '03-Mar-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Tobe', null, 'Peron', '348-742-8293', 'gperon4m@google.it', '274 Sachtjen Park', 'Brazil', null, '88780-000', 0, '5023533387', '', '06-Sep-1983');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Cyndy', null, 'Gasker', '518-318-4379', 'pgasker4n@techcrunch.com', '6104 Blackbird Road', 'Philippines', null, '3103', 0, '2422841732', '', '24-Jan-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Vernor', null, 'Schust', '402-945-7813', 'rschust4o@meetup.com', '6786 Doe Crossing Pass', 'Canada', 'BC', null, 1, '5671119561', '999999999', '26-Nov-1983');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Berny', 'Kim', 'Lorand', '251-237-2397', 'klorand4p@fotki.com', '1 Eagan Parkway', 'Indonesia', null, null, 0, '1031401695', '', '22-May-1995');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Trudie', 'Mindy', 'Sprey', '537-446-0783', 'msprey4q@vinaora.com', '66172 Esch Point', 'Palestinian Territory', null, null, 0, '5607926036', '', '21-Jan-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Biron', 'Horten', 'Stoppe', '348-615-9690', 'hstoppe4r@rediff.com', '60681 Morning Avenue', 'China', null, null, 0, '2241215880', '', '26-Apr-1995');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Aubry', null, 'Dressel', '236-223-6788', 'jdressel4s@wufoo.com', '5 Steensland Center', 'Peru', null, null, 0, '5941713754', '', '29-Oct-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Neill', null, 'Stoppe', '932-428-3851', 'kstoppe4t@army.mil', '211 Anhalt Lane', 'Indonesia', null, null, 0, '5053199647', '', '18-Oct-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Rowe', null, 'Matous', '569-573-1260', 'bmatous4u@ebay.co.uk', '8 Starling Pass', 'Indonesia', null, null, 0, '1676250107', '', '23-Oct-2001');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Cornelius', 'Darb', 'McCafferky', '571-149-9883', 'dmccafferky4v@bloglines.com', '38 Northfield Road', 'Indonesia', null, null, 0, '5396227397', '', '28-Mar-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Leann', 'Fremont', 'Pierucci', '349-559-0908', 'fpierucci4w@hexun.com', '6005 Spohn Road', 'Brazil', null, '75690-000', 0, '9157015740', '', '29-Jun-1997');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Anna', null, 'Alabaster', '424-529-9366', 'walabaster4x@histats.com', '3251 Packers Court', 'Indonesia', null, null, 0, '8048072270', '', '28-Jun-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Maude', null, 'Quartly', '144-503-3134', 'mquartly4y@posterous.com', '7 Anderson Center', 'Indonesia', null, null, 0, '8664845492', '', '22-Jan-1983');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Patti', null, 'Riccioppo', '850-414-7273', 'hriccioppo4z@cam.ac.uk', '27264 Union Alley', 'China', null, null, 0, '6014053883', '', '05-Nov-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Andris', null, 'Ketchen', '733-119-1033', 'sketchen50@freewebs.com', '7 Bay Pass', 'Brazil', null, '29100-000', 0, '8699655282', '', '05-Apr-2004');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Viva', null, 'Van Niekerk', '858-465-6507', 'pvanniekerk51@ask.com', '367 Jana Place', 'Brazil', null, '57615-000', 0, '3297523506', '', '15-Jun-1983');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Jacynth', 'Merlina', 'Pock', '348-368-3316', 'mpock52@newyorker.com', '8088 Union Lane', 'Brazil', null, '45300-000', 0, '2657329764', '', '26-Jan-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Marthe', 'Doyle', 'Clyde', '340-269-0046', 'dclyde53@diigo.com', '81429 Coolidge Alley', 'Philippines', null, '6542', 0, '5692998394', '', '29-Aug-2003');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Bernie', null, 'Le Barr', '769-155-2446', 'olebarr54@weibo.com', '871 Starling Drive', 'China', null, null, 0, '1568361742', '', '21-Jan-2003');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Frieda', null, 'Gocher', '536-690-8276', 'ggocher55@shinystat.com', '526 Dakota Road', 'Thailand', null, '47140', 0, '7499131920', '', '26-Nov-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Delcine', null, 'Pie', '886-787-3262', 'gpie56@webeden.co.uk', '95 Grover Street', 'Thailand', null, '66210', 0, '2969771675', '', '06-Dec-1990');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Paloma', null, 'Mahon', '827-571-6683', 'emahon57@sitemeter.com', '96186 Bashford Avenue', 'China', null, null, 0, '1808212223', '', '14-Jun-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Erick', null, 'Eton', '134-636-3226', 'deton58@aboutads.info', '9900 Blackbird Junction', 'China', null, null, 0, '9383726407', '', '04-Nov-1983');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Althea', 'Benny', 'Cromblehome', '555-168-7315', 'bcromblehome59@hao123.com', '2634 Novick Crossing', 'China', null, null, 0, '4582293468', '', '29-Mar-2001');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Rick', null, 'Yurikov', '452-371-1999', 'kyurikov5a@yellowpages.com', '95 Westend Place', 'Indonesia', null, null, 0, '1652965084', '', '15-Dec-2000');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Andy', null, 'Whitewood', '450-598-4164', 'bwhitewood5b@ehow.com', '6 Ryan Junction', 'China', null, null, 0, '4284059262', '', '06-Jan-1999');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Dyann', null, 'Vertey', '125-782-4287', 'svertey5c@uol.com.br', '1879 Mayfield Circle', 'Indonesia', null, null, 0, '0561105715', '', '16-Aug-1993');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Elly', 'Martelle', 'Aggett', '637-391-7794', 'maggett5d@vkontakte.ru', '5743 Packers Hill', 'China', null, null, 0, '5720731628', '', '06-Sep-1987');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Byram', null, 'Ritch', '641-534-4707', 'jritch5e@networkadvertising.org', '7752 Pleasure Point', 'China', null, null, 0, '0517281139', '', '09-Oct-2000');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Dahlia', null, 'Hayesman', '476-865-4355', 'ehayesman5f@4shared.com', '3 Homewood Road', 'Indonesia', null, null, 0, '3364289670', '', '27-Jun-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Phylys', 'Darcie', 'Somers', '414-897-4840', 'dsomers5g@tiny.cc', '22 Sullivan Street', 'Indonesia', null, null, 0, '5189552527', '', '27-Sep-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Harwilll', null, 'Challin', '538-445-1407', 'rchallin5h@sakura.ne.jp', '33829 Fulton Crossing', 'Indonesia', null, null, 0, '4139605294', '', '02-Jul-1981');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Peyter', null, 'Yankeev', '826-735-7074', 'byankeev5i@hp.com', '253 Harper Lane', 'China', null, null, 0, '7800818780', '', '25-Dec-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Matteo', null, 'Tew', '858-486-2555', 'mtew5j@mediafire.com', '254 Havey Center', 'Indonesia', null, null, 0, '7038579657', '', '24-Jan-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Ophelie', 'Lotte', 'Searjeant', '188-992-5713', 'lsearjeant5k@merriam-webster.com', '290 Melrose Lane', 'China', null, null, 0, '7050750492', '', '18-Jul-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Franky', null, 'Straw', '276-445-2882', 'rstraw5l@i2i.jp', '0866 Dixon Court', 'Canada', 'NT', 'S4A', 1, '9660952406', '999999999', '29-Aug-2001');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Darlleen', null, 'Aspland', '820-201-5642', 'maspland5m@chicagotribune.com', '75890 Northwestern Circle', 'Philippines', null, '4805', 0, '2417568160', '', '09-Sep-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Bernarr', 'Cathryn', 'Wannan', '170-825-9856', 'cwannan5n@vk.com', '05307 Charing Cross Point', 'China', null, null, 0, '2311672541', '', '23-Jul-1999');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Jolynn', null, 'Konrad', '436-422-9345', 'kkonrad5o@tamu.edu', '3 Autumn Leaf Lane', 'China', null, null, 0, '0240244729', '', '02-Apr-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Kahaleel', null, 'Andersen', '645-620-6389', 'mandersen5p@narod.ru', '6 Riverside Lane', 'Indonesia', null, null, 0, '1855029375', '', '18-Oct-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Dusty', 'Aylmer', 'Seymer', '118-771-6602', 'aseymer5q@livejournal.com', '62468 Monument Point', 'China', null, null, 0, '0544393783', '', '07-Apr-2004');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Elvina', null, 'Alyukin', '314-342-6199', 'palyukin5r@desdev.cn', '0 Dayton Point', 'United States', null, '63150', 0, '8362106700', '', '16-Mar-2003');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Elroy', null, 'McGeagh', '333-155-8627', 'dmcgeagh5s@t.co', '482 Mariners Cove Road', 'Mexico', null, '40230', 0, '4171785499', '', '27-Jul-1997');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Teador', null, 'Troutbeck', '367-312-9160', 'wtroutbeck5t@mlb.com', '251 Tomscot Lane', 'China', null, null, 0, '3960320930', '', '03-Jun-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Geoffrey', null, 'De Leek', '249-713-3265', 'sdeleek5u@freewebs.com', '6698 Oakridge Plaza', 'Indonesia', null, null, 0, '0318156342', '', '14-Jun-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Travus', null, 'Sirey', '563-226-6077', 'asirey5v@dropbox.com', '4450 Golden Leaf Junction', 'China', null, null, 0, '1770856757', '', '18-Aug-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Bryn', null, 'Buggs', '272-299-4365', 'fbuggs5w@themeforest.net', '3 Village Park', 'Indonesia', null, null, 0, '3671299150', '', '12-Sep-1994');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Mamie', 'Rina', 'Bourdas', '304-289-8740', 'rbourdas5x@gmpg.org', '92417 Linden Crossing', 'United States', null, '25389', 0, '6102213882', '', '15-Mar-1995');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Daryle', null, 'Haygreen', '941-939-4955', 'mhaygreen5y@friendfeed.com', '57342 Gina Circle', 'China', null, null, 0, '2031456946', '', '28-Sep-2004');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Willard', null, 'Dowman', '288-213-3664', 'sdowman5z@pcworld.com', '2 Lukken Road', 'Philippines', null, '1659', 0, '1766566456', '', '14-Mar-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Fraze', null, 'Goudman', '145-252-6691', 'sgoudman60@archive.org', '3687 Menomonie Drive', 'Peru', null, null, 0, '1302875396', '', '28-Nov-2003');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Sandra', 'Justis', 'Ragbourne', '752-887-2590', 'jragbourne61@youtube.com', '269 Sullivan Way', 'Mexico', null, null, 0, '0259001805', '', '02-Feb-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Denna', 'Rickard', 'Cantillon', '925-972-8062', 'rcantillon62@nih.gov', '9996 Sunfield Court', 'Indonesia', null, null, 0, '7918256409', '', '22-Feb-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Juana', null, 'Twizell', '601-957-6057', 'atwizell63@yelp.com', '552 Wayridge Crossing', 'China', null, null, 0, '9801422084', '', '08-Mar-1989');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Abigale', null, 'Rhodes', '490-554-5251', 'nrhodes64@amazon.de', '83395 Jackson Junction', 'China', null, null, 0, '2245172248', '', '04-Jul-1989');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Helli', null, 'Ledgerton', '555-579-1389', 'cledgerton65@qq.com', '1350 Oneill Trail', 'China', null, null, 0, '9759067730', '', '21-Jul-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Daria', null, 'Hyndley', '941-568-2775', 'bhyndley66@prlog.org', '76766 Melby Plaza', 'China', null, null, 0, '9678564165', '', '12-Feb-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Raquel', null, 'Keyser', '591-314-7732', 'bkeyser67@earthlink.net', '9778 Bashford Trail', 'Thailand', null, '20170', 0, '6564285418', '', '11-Jan-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Josefina', null, 'Stampe', '585-400-8376', 'hstampe68@cnn.com', '579 Colorado Lane', 'China', null, null, 0, '7777659057', '', '03-Oct-1993');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Rudie', 'Werner', 'Leebetter', '785-898-3107', 'wleebetter69@nature.com', '57575 Packers Junction', 'United States', null, '66622', 0, '5841849077', '', '15-Feb-1999');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Anissa', 'Kris', 'Diben', '336-846-2544', 'kdiben6a@shareasale.com', '66185 Butterfield Hill', 'Indonesia', null, null, 0, '8620564080', '', '04-Jan-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Win', null, 'Farloe', '403-235-9553', 'afarloe6b@epa.gov', '742 Mcbride Parkway', 'China', null, null, 0, '1645681955', '', '25-Aug-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Isabella', 'Gretta', 'Oleszczak', '731-417-3541', 'goleszczak6c@1688.com', '35 Cody Point', 'Philippines', null, '7000', 0, '3999150750', '', '03-Sep-1987');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Andie', 'Bryanty', 'Lanktree', '765-373-2842', 'blanktree6d@state.tx.us', '0832 Knutson Lane', 'Indonesia', null, null, 0, '9296189470', '', '27-Nov-2003');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Mitchel', null, 'Wileman', '236-650-3938', 'kwileman6e@multiply.com', '844 Moulton Avenue', 'Thailand', null, '90140', 0, '3290094650', '', '20-May-1981');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Dulcinea', null, 'Jakuszewski', '442-433-1282', 'cjakuszewski6f@about.com', '3763 Brown Park', 'China', null, null, 0, '1140009990', '', '09-Dec-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Chelsae', null, 'Verrill', '470-921-5261', 'cverrill6g@reuters.com', '25 Columbus Avenue', 'Philippines', null, '9300', 0, '5111756817', '', '12-Jan-1995');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Susanna', null, 'MacScherie', '473-654-0948', 'mmacscherie6h@indiatimes.com', '3313 Forest Run Point', 'Indonesia', null, null, 0, '6707931466', '', '12-Sep-1983');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Tricia', null, 'Scullion', '526-716-5787', 'fscullion6i@cargocollective.com', '1 Warbler Parkway', 'Philippines', null, null, 0, '1242325824', '', '22-Dec-1993');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Valeria', null, 'Ravenshear', '855-941-2724', 'nravenshear6j@hao123.com', '8395 Petterle Hill', 'China', null, null, 0, '5035695638', '', '26-Feb-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Donnell', null, 'Ings', '459-505-2563', 'yings6k@jigsy.com', '990 1st Crossing', 'Indonesia', null, null, 0, '1313219010', '', '22-Apr-1996');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Craggy', null, 'Alliberton', '921-712-6463', 'lalliberton6l@disqus.com', '7 Fairview Center', 'Indonesia', null, null, 0, '4061314734', '', '05-May-1997');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Amelia', 'Lindy', 'Mildmott', '673-484-4963', 'lmildmott6m@clickbank.net', '56256 Everett Place', 'Indonesia', null, null, 0, '0389252468', '', '17-Aug-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Aila', null, 'Alejo', '440-699-6912', 'calejo6n@utexas.edu', '0100 Scofield Circle', 'China', null, null, 0, '7812950905', '', '25-Sep-2000');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Phoebe', 'Stefa', 'Kosiada', '920-546-2102', 'skosiada6o@gmpg.org', '2 Havey Park', 'Indonesia', null, null, 0, '2947038495', '', '07-Aug-1994');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Nelson', null, 'Martschik', '588-521-1795', 'pmartschik6p@ted.com', '05 Bellgrove Avenue', 'China', null, null, 0, '5239449422', '', '14-Jul-1999');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Brianna', 'Giffard', 'Burbank', '755-502-6729', 'gburbank6q@usnews.com', '60 Mccormick Avenue', 'Indonesia', null, null, 0, '5896212615', '', '19-Nov-1995');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Whitney', null, 'Brumwell', '966-478-5523', 'pbrumwell6r@shinystat.com', '2408 Forster Road', 'China', null, null, 0, '7867838082', '', '16-Jan-1981');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Victoir', 'Fayre', 'Garwill', '728-411-2229', 'fgarwill6s@senate.gov', '99 Tennessee Parkway', 'Indonesia', null, null, 0, '1042079846', '', '02-Jan-2000');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Ola', 'Javier', 'Wadforth', '597-854-3533', 'jwadforth6t@redcross.org', '05 Village Pass', 'Indonesia', null, null, 0, '8967639961', '', '15-Jul-1990');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Abramo', null, 'Delf', '505-745-1613', 'cdelf6u@liveinternet.ru', '241 Coleman Terrace', 'Philippines', null, '1950', 0, '1982820276', '', '25-Feb-1982');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Renaud', null, 'Padefield', '198-912-3784', 'gpadefield6v@reverbnation.com', '4 Farragut Place', 'Indonesia', null, null, 0, '2173486330', '', '15-Mar-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Adela', null, 'Ciardo', '565-915-0831', 'aciardo6w@bbc.co.uk', '150 Golden Leaf Road', 'Philippines', null, '3110', 0, '4850760309', '', '07-Aug-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Geoff', 'Ludovico', 'Shay', '214-718-4952', 'lshay6x@gov.uk', '1053 Little Fleur Terrace', 'United States', null, '75397', 0, '4051250288', '', '14-Jun-1994');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Shelby', null, 'Behnecke', '925-661-1497', 'sbehnecke6y@wordpress.com', '964 Bellgrove Junction', 'Philippines', null, null, 0, '9264657134', '', '19-May-1997');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Gustaf', null, 'Osboldstone', '798-215-2844', 'cosboldstone6z@google.com', '8 Lake View Point', 'China', null, null, 0, '0774191279', '', '21-Apr-1990');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Rhea', 'Charline', 'Immer', '288-749-4102', 'cimmer70@bravesites.com', '7916 Starling Crossing', 'Indonesia', null, null, 0, '9304018234', '', '26-Oct-1995');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Justine', 'Mart', 'Dreghorn', '330-868-7170', 'mdreghorn71@wordpress.com', '79373 Boyd Plaza', 'Indonesia', null, null, 0, '0135498945', '', '22-Dec-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Clerissa', null, 'Greenwood', '131-746-2823', 'cgreenwood72@gravatar.com', '94 Darwin Hill', 'China', null, null, 0, '1990062288', '', '21-Oct-1985');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Opaline', null, 'Tettersell', '777-565-1991', 'ttettersell73@google.es', '7405 Gale Court', 'China', null, null, 0, '8001758540', '', '25-Apr-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Inglebert', null, 'Skirling', '756-885-5617', 'oskirling74@discovery.com', '1257 Melrose Crossing', 'Brazil', null, '97500-000', 0, '0817956174', '', '04-Jul-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Debee', null, 'Cumbes', '685-625-0846', 'mcumbes75@ovh.net', '36 Warrior Court', 'China', null, null, 0, '1649607385', '', '02-Oct-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Martyn', 'Mae', 'Satford', '523-697-0074', 'msatford76@ning.com', '77210 Linden Point', 'Philippines', null, '8303', 0, '4271742570', '', '05-Feb-1996');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Anabal', null, 'Dosdill', '261-204-8539', 'ldosdill77@mit.edu', '9 Prentice Lane', 'China', null, null, 0, '4835082540', '', '17-Oct-1999');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Molly', null, 'Foort', '948-994-1104', 'cfoort78@sciencedirect.com', '0 Linden Court', 'Peru', null, null, 0, '6952757066', '', '13-May-1999');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Domenico', null, 'Marc', '251-973-1651', 'mmarc79@reuters.com', '26 Lake View Crossing', 'Indonesia', null, null, 0, '0840527624', '', '05-Nov-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Cross', null, 'Churly', '634-377-0888', 'schurly7a@e-recht24.de', '438 Crownhardt Way', 'China', null, null, 0, '3782563573', '', '17-Jun-1997');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Sarene', null, 'Derwin', '459-965-1424', 'aderwin7b@wikimedia.org', '952 Bay Drive', 'Indonesia', null, null, 0, '3975253924', '', '30-May-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Skipper', null, 'Mallatratt', '673-658-4137', 'rmallatratt7c@1und1.de', '02658 Blue Bill Park Lane', 'Thailand', null, '21130', 0, '1270875795', '', '25-Sep-1981');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Lorette', null, 'Fathers', '302-293-6487', 'gfathers7d@weibo.com', '01179 Dennis Center', 'United States', null, '19810', 0, '5107125077', '', '11-Apr-1995');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Heath', null, 'Whitwood', '710-112-8363', 'rwhitwood7e@cloudflare.com', '7 Brentwood Plaza', 'Canada', 'ON', 'M2J', 1, '2262034532', '999999999', '18-Apr-2001');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Florence', 'Harlene', 'Domico', '277-881-3385', 'hdomico7f@nasa.gov', '25 Eagan Court', 'Indonesia', null, null, 0, '4034669209', '', '15-Feb-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Andrew', null, 'Borge', '757-416-0023', 'gborge7g@de.vu', '8337 Eastwood Avenue', 'United States', null, '23324', 0, '7742070995', '', '24-Jul-1989');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Idalina', null, 'Gino', '572-464-6257', 'rgino7h@elegantthemes.com', '81404 Dunning Drive', 'China', null, null, 0, '4165160016', '', '15-Jan-1993');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Chevalier', null, 'Jeal', '176-168-6821', 'jjeal7i@imgur.com', '694 Hoepker Plaza', 'Thailand', null, '67110', 0, '0570085829', '', '22-Aug-2002');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Lonee', 'Pooh', 'Dalligan', '832-810-2593', 'pdalligan7j@china.com.cn', '8 Eggendart Plaza', 'Philippines', null, '5419', 0, '2073267114', '', '15-Dec-2001');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Igor', null, 'Habbin', '244-749-5471', 'mhabbin7k@jigsy.com', '64 Elgar Park', 'Philippines', null, '6128', 0, '8642649860', '', '11-Jul-1982');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Bord', null, 'Spondley', '617-507-1343', 'mspondley7l@hud.gov', '6 Dryden Way', 'Indonesia', null, null, 0, '7993380081', '', '13-Oct-1983');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Sonnnie', null, 'Switsur', '785-901-4205', 'dswitsur7m@geocities.jp', '894 Canary Drive', 'China', null, null, 0, '3312613876', '', '20-May-1981');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Giana', null, 'Kneeshaw', '992-943-6869', 'wkneeshaw7n@google.co.jp', '62905 Jay Pass', 'Indonesia', null, null, 0, '7696429019', '', '07-Feb-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Lucretia', null, 'Foddy', '396-138-9293', 'afoddy7o@independent.co.uk', '32 Carey Terrace', 'Brazil', null, '38900-000', 0, '5467803786', '', '10-Jun-1988');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Caryn', null, 'Carlucci', '266-679-2796', 'hcarlucci7p@berkeley.edu', '478 Loeprich Junction', 'China', null, null, 0, '9884254672', '', '28-Nov-1992');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Sherie', 'Kienan', 'Stephenson', '700-566-9229', 'kstephenson7q@biglobe.ne.jp', '41565 Mallard Trail', 'Philippines', null, '9406', 0, '7596959822', '', '27-Feb-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Leopold', null, 'Djurkovic', '592-800-7501', 'jdjurkovic7r@lycos.com', '11925 Carpenter Pass', 'China', null, null, 0, '5637735441', '', '23-May-2001');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Virgie', null, 'Keling', '425-954-5318', 'ekeling7s@pbs.org', '08 Welch Street', 'China', null, null, 0, '8572635106', '', '05-May-1990');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Evonne', null, 'Kernan', '333-571-5221', 'okernan7t@house.gov', '7 Fremont Hill', 'China', null, null, 0, '2181339856', '', '15-Jun-1990');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Jordan', null, 'Skerm', '746-408-1341', 'fskerm7u@zdnet.com', '12 Sunfield Way', 'China', null, null, 0, '1533957878', '', '09-Sep-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Juliane', 'Isador', 'Anders', '583-700-0130', 'ianders7v@i2i.jp', '102 Muir Circle', 'Brazil', null, '62430-000', 0, '6221089107', '', '10-Jul-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Juan', 'Titos', 'Le Fleming', '232-347-3037', 'tlefleming7w@discovery.com', '5077 Jana Junction', 'Indonesia', null, null, 0, '0633182044', '', '16-Dec-2001');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Courtnay', null, 'Morton', '288-357-4763', 'cmorton7x@bluehost.com', '991 Kingsford Hill', 'China', null, null, 0, '9989396337', '', '09-Jun-1999');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Josephina', null, 'Gain', '634-535-3271', 'ggain7y@blogs.com', '798 Hooker Lane', 'China', null, null, 0, '4986959840', '', '29-Dec-1986');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Lilith', 'Frank', 'Vickarman', '808-889-3294', 'fvickarman7z@sfgate.com', '6936 Northport Drive', 'Canada', 'YT', 'H3Z', 1, '4862576702', '999999999', '22-Mar-1998');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Cory', null, 'Seabright', '658-113-4800', 'fseabright80@latimes.com', '79 Village Parkway', 'China', null, null, 0, '7757266440', '', '25-May-2000');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Far', null, 'Fowells', '183-302-6566', 'dfowells81@creativecommons.org', '20200 Evergreen Center', 'Philippines', null, '5409', 0, '7974633115', '', '10-Nov-1989');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Vitoria', null, 'Caslin', '937-940-5891', 'kcaslin82@wix.com', '899 Riverside Crossing', 'Brazil', null, '88540-000', 0, '0860549291', '', '02-Dec-1984');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Camel', null, 'Bosence', '831-952-0814', 'cbosence83@wix.com', '90 Village Lane', 'Philippines', null, '4323', 0, '5473316409', '', '13-Dec-1987');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Jenilee', null, 'Babidge', '470-973-3138', 'ebabidge84@hostgator.com', '0356 Elka Place', 'China', null, null, 0, '5598948109', '', '18-Jun-1980');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Elberta', null, 'Allchorn', '787-833-3693', 'mallchorn85@netscape.com', '4137 Northview Terrace', 'Philippines', null, '8313', 0, '8524697938', '', '04-Jun-1996');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Tasia', null, 'Anstis', '463-183-6712', 'eanstis86@yahoo.com', '8 Thierer Street', 'China', null, null, 0, '8719495641', '', '10-Jun-1997');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Tan', null, 'Everit', '577-797-8960', 'keverit87@hubpages.com', '7 Garrison Drive', 'China', null, null, 0, '9677017446', '', '02-Apr-2001');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Hallsy', null, 'Toping', '416-379-3589', 'atoping88@tinypic.com', '61 Cardinal Park', 'Indonesia', null, null, 0, '9399224759', '', '10-Feb-1996');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Worthy', 'Hersch', 'Booy', '964-132-9971', 'hbooy89@home.pl', '00 Cody Point', 'Indonesia', null, null, 0, '6744327496', '', '01-Aug-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Josie', null, 'Friel', '499-724-7337', 'efriel8a@sina.com.cn', '0 Pearson Point', 'China', null, null, 0, '6104209599', '', '18-Feb-1991');
insert into student (student_id, student_first_name, student_middle_name, student_last_name, telephone, email, address, country, province, zip_code, is_domestic, identity_no, SIN, DOB) values (STUDENT_ID_SEQ.nextval, 'Lulita', null, 'Rands', '634-442-2225', 'crands8b@cyberchimps.com', '19 Waywood Crossing', 'China', null, null, 0, '6240895024', '', '10-Sep-2004');

-- course table samples
INSERT INTO COURSE (COURSE_ID, COURSE_NAME, COURSE_CODE, COURSE_DESC, NO_CREDITS)
    VALUES (COURSE_ID_SEQ.nextval,'College Communication 2','COMM-170','English Communication Skills', 3);
INSERT INTO COURSE (COURSE_ID, COURSE_NAME, COURSE_CODE, COURSE_DESC, NO_CREDITS)
    VALUES (COURSE_ID_SEQ.nextval,'Java Programming','COMP-228','Building OOP', 4);
INSERT INTO COURSE (COURSE_ID, COURSE_NAME, COURSE_CODE, COURSE_DESC, NO_CREDITS)
    VALUES (COURSE_ID_SEQ.nextval,'Neural Networks','COMP-258','ANN and MLP', 4);
INSERT INTO COURSE (COURSE_ID, COURSE_NAME, COURSE_CODE, COURSE_DESC, NO_CREDITS)
    VALUES (COURSE_ID_SEQ.nextval,'Advanced Data Base','COMP-214','SQL and PLSQL', 4);
INSERT INTO COURSE (COURSE_ID, COURSE_NAME, COURSE_CODE, COURSE_DESC, NO_CREDITS)
    VALUES (COURSE_ID_SEQ.nextval,'Software Security','CBER-711','Cybersecurity', 4);
INSERT INTO COURSE (COURSE_ID, COURSE_NAME, COURSE_CODE, COURSE_DESC, NO_CREDITS)
    VALUES (COURSE_ID_SEQ.nextval,'Introduction for Pharmacology','PHAR-129','Introduction of pharmacology medications', 3);
INSERT INTO COURSE (COURSE_ID, COURSE_NAME, COURSE_CODE, COURSE_DESC, NO_CREDITS)
    VALUES (COURSE_ID_SEQ.nextval,'Taxation 1','ACCT-226','Canada Income Tax Act and regulations', 4);
INSERT INTO COURSE (COURSE_ID, COURSE_NAME, COURSE_CODE, COURSE_DESC, NO_CREDITS)
    VALUES (COURSE_ID_SEQ.nextval,'Avionic Systems','ATAC-203','Aircrafts', 3);
INSERT INTO COURSE (COURSE_ID, COURSE_NAME, COURSE_CODE, COURSE_DESC, NO_CREDITS)
    VALUES (COURSE_ID_SEQ.nextval,'Dance History and Theory','DANC-205','History the roots of dance', 3);
INSERT INTO COURSE (COURSE_ID, COURSE_NAME, COURSE_CODE, COURSE_DESC, NO_CREDITS)
    VALUES (COURSE_ID_SEQ.nextval,'Acrobatis 2','DANC-410','Circus skills', 4);

-- sections table samples
INSERT INTO SECTION (SECTION_ID, SECTION_TYPE, PROFESSOR_NAME, CAPACITY, COURSE_ID)
    VALUES (section_id_seq.nextval, 'ONLINE', 'Dwain Growgane', 20, 10);
INSERT INTO SECTION (SECTION_ID, SECTION_TYPE, PROFESSOR_NAME, CAPACITY, COURSE_ID)
    VALUES (section_id_seq.nextval, 'IN PERSON', 'Ida Sensei', 20, 12);
INSERT INTO SECTION (SECTION_ID, SECTION_TYPE, PROFESSOR_NAME, CAPACITY, COURSE_ID)
    VALUES (section_id_seq.nextval, 'HYBRID', 'Sebas Butler', 20, 14);
INSERT INTO SECTION (SECTION_ID, SECTION_TYPE, PROFESSOR_NAME, CAPACITY, COURSE_ID)
    VALUES (section_id_seq.nextval, 'HYBRID', 'Johnny Leworthy', 20, 16);
INSERT INTO SECTION (SECTION_ID, SECTION_TYPE, PROFESSOR_NAME, CAPACITY, COURSE_ID)
    VALUES (section_id_seq.nextval, 'ONLINE', 'Monica Casado', 20, 18);
INSERT INTO SECTION (SECTION_ID, SECTION_TYPE, PROFESSOR_NAME, CAPACITY, COURSE_ID)
    VALUES (section_id_seq.nextval, 'IN PERSON', 'Colly Gamlen', 20, 20);
INSERT INTO SECTION (SECTION_ID, SECTION_TYPE, PROFESSOR_NAME, CAPACITY, COURSE_ID)
    VALUES (section_id_seq.nextval, 'HYBRID', 'Johnny Leworthy', 20, 22);
INSERT INTO SECTION (SECTION_ID, SECTION_TYPE, PROFESSOR_NAME, CAPACITY, COURSE_ID)
    VALUES (section_id_seq.nextval, 'ONLINE', 'Monica Casado', 20, 24);
INSERT INTO SECTION (SECTION_ID, SECTION_TYPE, PROFESSOR_NAME, CAPACITY, COURSE_ID)
    VALUES (section_id_seq.nextval, 'IN PERSON', 'Colly Gamlen', 20, 26);
INSERT INTO SECTION (SECTION_ID, SECTION_TYPE, PROFESSOR_NAME, CAPACITY, COURSE_ID)
    VALUES (section_id_seq.nextval, 'HYBRID', 'Johnny Leworthy', 20, 28);

-- Enrollment table 
INSERT INTO ENROLLMENT (ENROLLMENT_ID, STUDENT_ID, PROGRAM_ID, STATUS, CURRENT_TERM, ENROLL_DATE, TOTAL_FEES)
    VALUES(enrollment_id_seq.nextval, 1310, 451, 0, 1, '01-Sep-2022', get_fees(1310, 451));
INSERT INTO ENROLLMENT (ENROLLMENT_ID, STUDENT_ID, PROGRAM_ID, STATUS, CURRENT_TERM, ENROLL_DATE, TOTAL_FEES)
    VALUES(enrollment_id_seq.nextval, 1315, 452, 0, 1, '05-Sep-2022', get_fees(1315, 452) );
INSERT INTO ENROLLMENT (ENROLLMENT_ID, STUDENT_ID, PROGRAM_ID, STATUS, CURRENT_TERM, ENROLL_DATE, TOTAL_FEES)
    VALUES(enrollment_id_seq.nextval, 1320, 452, 0, 1, '06-Sep-2022', get_fees(1320, 452) );
INSERT INTO ENROLLMENT (ENROLLMENT_ID, STUDENT_ID, PROGRAM_ID, STATUS, CURRENT_TERM, ENROLL_DATE, TOTAL_FEES)
    VALUES(enrollment_id_seq.nextval, 1325, 453, 0, 1, '30-Sep-2022', get_fees(1325, 453) );
INSERT INTO ENROLLMENT (ENROLLMENT_ID, STUDENT_ID, PROGRAM_ID, STATUS, CURRENT_TERM, ENROLL_DATE, TOTAL_FEES)
    VALUES(enrollment_id_seq.nextval, 1330, 456, 0, 1, '30-Sep-2022', get_fees(1330, 456) );
INSERT INTO ENROLLMENT (ENROLLMENT_ID, STUDENT_ID, PROGRAM_ID, STATUS, CURRENT_TERM, ENROLL_DATE, TOTAL_FEES)
    VALUES(enrollment_id_seq.nextval, 1335, 456, 0, 1, '01-Oct-2022', get_fees(1335, 456) );
INSERT INTO ENROLLMENT (ENROLLMENT_ID, STUDENT_ID, PROGRAM_ID, STATUS, CURRENT_TERM, ENROLL_DATE, TOTAL_FEES)
    VALUES(enrollment_id_seq.nextval, 1340, 453, 0, 1, '01-Oct-2022', get_fees(1340, 453) );
INSERT INTO ENROLLMENT (ENROLLMENT_ID, STUDENT_ID, PROGRAM_ID, STATUS, CURRENT_TERM, ENROLL_DATE, TOTAL_FEES)
    VALUES(enrollment_id_seq.nextval, 1345, 452, 0, 1, '11-Nov-2022', get_fees(1345, 452) );
INSERT INTO ENROLLMENT (ENROLLMENT_ID, STUDENT_ID, PROGRAM_ID, STATUS, CURRENT_TERM, ENROLL_DATE, TOTAL_FEES)
    VALUES(enrollment_id_seq.nextval, 1350, 466, 0, 1, '13-Nov-2022', get_fees(1350, 466) );
INSERT INTO ENROLLMENT (ENROLLMENT_ID, STUDENT_ID, PROGRAM_ID, STATUS, CURRENT_TERM, ENROLL_DATE, TOTAL_FEES)
    VALUES(enrollment_id_seq.nextval, 1355, 452, 0, 1, '13-Nov-2022', get_fees(1355, 452) );
INSERT INTO ENROLLMENT (ENROLLMENT_ID, STUDENT_ID, PROGRAM_ID, STATUS, CURRENT_TERM, ENROLL_DATE, TOTAL_FEES)
    VALUES(enrollment_id_seq.nextval, 1360, 456, 0, 1, '19-Nov-2022', get_fees(1360, 456) );
-- SECTION_ENROLLMENT 

INSERT INTO SECTION_ENROLLMENT(section_id, enrollment_id)
    VALUES (1,10000);
INSERT INTO SECTION_ENROLLMENT(section_id, enrollment_id)
    VALUES (3,10003);
INSERT INTO SECTION_ENROLLMENT(section_id, enrollment_id)
    VALUES (3,10006);
INSERT INTO SECTION_ENROLLMENT(section_id, enrollment_id)
    VALUES (3,10009);
INSERT INTO SECTION_ENROLLMENT(section_id, enrollment_id)
    VALUES (3,10012);
INSERT INTO SECTION_ENROLLMENT(section_id, enrollment_id)
    VALUES (3,10015);
INSERT INTO SECTION_ENROLLMENT(section_id, enrollment_id)
    VALUES (3,10018);
INSERT INTO SECTION_ENROLLMENT(section_id, enrollment_id)
    VALUES (3,10021);
INSERT INTO SECTION_ENROLLMENT(section_id, enrollment_id)
    VALUES (3,10024);
INSERT INTO SECTION_ENROLLMENT(section_id, enrollment_id)
    VALUES (3,10027);
INSERT INTO SECTION_ENROLLMENT(section_id, enrollment_id)
    VALUES (3,10030);

COMMIT;