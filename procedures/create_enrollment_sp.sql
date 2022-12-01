/*
    This procedure creates a new enrollment for a new student
    By default the value of status must be 0 (pending)
*/

CREATE OR REPLACE PROCEDURE create_enrollment_sp
( p_student_id IN ENROLLMENT.STUDENT_ID%TYPE,
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
    DBMS_OUTPUT.PUT_LINE('ERROR!!!!!!! CANNOT create new enrollment there is a duplicate value on index');
  ROLLBACK;
  WHEN CHECK_CONSTRAINT_VIOLATION THEN
    DBMS_OUTPUT.PUT_LINE('Create enrollment failed due to check constraint violation!!!!!');
  ROLLBACK;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error' || SQLERRM);
 ROLLBACK;
END create_ENROLLMENT_sp;


