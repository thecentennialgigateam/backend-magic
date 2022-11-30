CREATE OR REPLACE PROCEDURE update_student_sp
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
/  