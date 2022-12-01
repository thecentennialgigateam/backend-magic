CREATE OR REPLACE PROCEDURE update_enrollment_sp
( 
  p_enrollment_id  IN ENROLLMENT.ENROLLMENT_ID%TYPE,
  student_id IN ENROLLMENT.STUDENT_ID%TYPE,
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
