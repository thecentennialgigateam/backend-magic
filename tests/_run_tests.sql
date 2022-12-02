-- Test Create student 
DECLARE
    lv_student_first_name STUDENT.STUDENT_FIRST_NAME%TYPE := 'SORADA';
    lv_student_middle_name STUDENT.STUDENT_MIDDLE_NAME%TYPE := '';
    lv_student_last_name STUDENT.STUDENT_LAST_NAME%TYPE := 'PRATHAN';
    lv_telephone STUDENT.TELEPHONE%TYPE :='4326576492';
    lv_email STUDENT.EMAIL%TYPE := 'id@@a111@gmail.com';
    lv_address STUDENT.ADDRESS%TYPE := '164 Madison Avenue';
    lv_province STUDENT.PROVINCE%TYPE := 'AN';
    lv_country STUDENT.COUNTRY%TYPE := 'CANADA';
    lv_city STUDENT.CITY%TYPE := 'Toronto';
    lv_zipCode STUDENT.ZIP_CODE%TYPE := 'M4B 1K7';
    lv_isDomestic STUDENT.IS_DOMESTIC%TYPE := 1;
    lv_identityNo STUDENT.IDENTITY_NO%TYPE := 'AA123456789';
    lv_sin STUDENT.SIN%TYPE := 123456789;
    lv_dob STUDENT.DOB%TYPE := '18-AUG-98';
    BEGIN
    create_student_sp(lv_student_first_name,lv_student_middle_name,lv_student_last_name,lv_telephone,lv_email,lv_address,
    lv_province,lv_country,lv_city,lv_zipCode,lv_isDomestic,lv_identityNo,lv_sin,lv_dob);
    END;
/

-- Test update student   
DECLARE
    lv_student_id STUDENT.STUDENT_ID%TYPE:= 1000;
    lv_student_first_name STUDENT.STUDENT_FIRST_NAME%TYPE := 'NANA';
    lv_student_middle_name STUDENT.STUDENT_MIDDLE_NAME%TYPE := '';
    lv_student_last_name STUDENT.STUDENT_LAST_NAME%TYPE := 'LULU';
    lv_telephone STUDENT.TELEPHONE%TYPE :='8888888888888';
    lv_email STUDENT.EMAIL%TYPE := 'NANALULU@gmail.com';
    lv_sin STUDENT.SIN%TYPE := 9999;
    lv_dob STUDENT.DOB%TYPE := '25-AUG-89';
BEGIN
    update_student_sp(lv_student_id,lv_student_first_name,lv_student_middle_name,lv_student_last_name
    ,lv_telephone,lv_email,lv_sin,lv_dob);
  END;


select count(*) 
    from STUDENT where STUDENT_ID = 70000000;



-- TESTING
DECLARE
    --lv_something NUMBER;
BEGIN
    create_enrollment_sp(1105, 311, 0, 1, '1-Sep-2022', get_fees(1105, 311) );
    create_enrollment_sp(1060, 334, 0, 1, '2-Sep-2022', get_fees(1060, 334) );
    create_enrollment_sp(1185, 340, 0, 1, '29-Oct-2022', get_fees(1185, 340) );
    create_enrollment_sp(1695, 326, 0, 1, '15-Nov-2022', get_fees(1695, 326) );
END;

-- Test function

SELECT get_fees(1310, 451) FROM DUAL;
SELECT check_capacity(1) FROM DUAL;

-- view data from tables and view

SELECT * from enrollment;

SELECT * FROM student;

-- view with the section enrollments
SELECT * FROM section_enrollments_vw;