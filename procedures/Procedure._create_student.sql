CREATE OR REPLACE PROCEDURE create_student_sp
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
/