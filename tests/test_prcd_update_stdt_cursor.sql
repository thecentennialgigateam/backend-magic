--TEST
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