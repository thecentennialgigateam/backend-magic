CREATE OR REPLACE PROCEDURE update_enrollment_sp
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
  SET STUDENT_ID = p_student_id, PROGRAM_ID = p_program_id, status = p_status, current_term = p_current_term,
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


-- insert data into Enrollment table
DECLARE
    --lv_something NUMBER;
BEGIN
    create_enrollment_sp(1105, 311, 0, 1, '1-Sep-2022', get_fees(1105, 311) );
    create_enrollment_sp(1060, 334, 0, 1, '2-Sep-2022', get_fees(1060, 334) );
    create_enrollment_sp(1185, 340, 0, 1, '29-Oct-2022', get_fees(1185, 340) );
    create_enrollment_sp(1695, 326, 0, 1, '15-Nov-2022', get_fees(1695, 326) );
END;

--OLD data

--create_enrollment_sp(1105, 311, 0, 1, '1-Sep-2022', get_fees(1105, 311) );


DECLARE
    --lv_something NUMBER;
BEGIN
    update_enrollment_sp(10000,1105, 334, 0, 1, '29-Sep-2022', get_fees(1105, 334) );
    
END;