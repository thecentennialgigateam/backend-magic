-- drop DEMO tables from OracleXE (run twice) this is optional
/* 
DROP TABLE demo_customers;
DROP TABLE demo_order_items;
DROP TABLE demo_orders;
DROP TABLE demo_product_info;
DROP TABLE demo_states;
DROP TABLE demo_users;
DROP TABLE dept;
DROP TABLE emp;
*/

-- Drop existing tables
DROP TABLE PROGRAMCOURSE;
DROP TABLE PREREQUISITE;
DROP TABLE SECTION;
DROP TABLE COURSE;
DROP TABLE ENROLLMENT;
DROP TABLE PROGRAM;
DROP TABLE DEPARTMENT;
DROP TABLE STUDENT;

-- tables creation

CREATE TABLE DEPARTMENT 
(
  DEPARTMENT_ID NUMBER(9,0) NOT NULL,
  DEPARTMENT_NAME VARCHAR2(20),  
  DEPARTMENT_HEAD VARCHAR2(20), 
  CONSTRAINT DEPARTMENT_PK  PRIMARY KEY (DEPARTMENT_ID)   
);

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
  ZIP_CODE VARCHAR2(100),
  IS_DOMESTIC NUMBER(1,0) NOT NULL,
  IDENTITY_NO VARCHAR2(20),
  SIN NUMBER(9,0),
  DOB DATE NOT NULL,
    CONSTRAINT STUDENT_PK PRIMARY KEY (STUDENT_ID),
    CONSTRAINT email_ckp CHECK (EMAIL LIKE '%@%.%' AND EMAIL NOT LIKE '@%' AND EMAIL NOT LIKE '%@%@'),
    CONSTRAINT province_ckp CHECK (PROVINCE IN ('NL', 'PE', 'NS', 'NB', 'QC', 'ON', 'MB', 'SK', 'AB', 'BC', 'YT', 'NU', 'NT'))
    --CONSTRAINT zip_code_ckp CHECK (SIZE )
);

CREATE TABLE ENROLLMENT 
(
  ENROLLMENT_ID NUMBER(9) NOT NULL,
  STUDENT_ID NUMBER(9) NOT NULL,
  PROGRAM_ID NUMBER(9),
  STATUS NUMBER(1,0),
  CURRENT_TERM NUMBER(2,0),
  ENROLL_DATE DATE,
  TOTAL_FEES NUMBER(9, 2),
    CONSTRAINT ENROLLMENT_PK PRIMARY KEY (ENROLLMENT_ID),
    CONSTRAINT STUDENT_FK FOREIGN KEY (STUDENT_ID) REFERENCES STUDENT(STUDENT_ID),
    CONSTRAINT PROGRAM_ENROLL_FK FOREIGN KEY (PROGRAM_ID) REFERENCES PROGRAM(PROGRAM_ID),
    CONSTRAINT STATUS_CHK CHECK (STATUS IN (0, 1))
);

CREATE TABLE COURSE 
(
  COURSE_ID NUMBER(9,0) NOT NULL,
  COURSE_NAME VARCHAR2(100),
  COURSE_CODE VARCHAR2(10),
  COURSE_DESC VARCHAR2(100),
  NO_CREDITS NUMBER(2,0),

  SECTION_ID NUMBER(9,0),
    CONSTRAINT COURSE_PK PRIMARY KEY (COURSE_ID),
    CONSTRAINT NO_CREDITS_CHK CHECK (0< NO_CREDITS AND NO_CREDITS >10)
);

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

CREATE TABLE PREREQUISITE 
(
  PREREQ_COURSE NUMBER(9) NOT NULL,
  COURSE_ID NUMBER(9,0),
    CONSTRAINT PREREQUISITE_PK PRIMARY KEY (PREREQ_COURSE, COURSE_ID),
    CONSTRAINT COURSE_ID_FK FOREIGN KEY (COURSE_ID) REFERENCES COURSE (COURSE_ID)
);

CREATE TABLE PROGRAMCOURSE 
(
  PROGRAM_ID NUMBER(9),
  COURSE_ID NUMBER(9) CONSTRAINT COURSE_PC_FK REFERENCES COURSE(COURSE_ID),
    CONSTRAINT PROGRAMCOURSE_PK PRIMARY KEY (PROGRAM_ID, COURSE_ID),
    CONSTRAINT PROGRAM_PC_FK FOREIGN KEY (PROGRAM_ID) REFERENCES PROGRAM(PROGRAM_ID)
);