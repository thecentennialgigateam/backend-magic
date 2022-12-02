CREATE OR REPLACE PACKAGE enrollment_pkg IS
    pv_enrollment VARCHAR2(20);
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
          FUNCTION get_fees (student_id_prt student.student_id%TYPE, 
                             program_id_prt program.program_id%TYPE)
          RETURN NUMBER;
          
          FUNCTION check_capacity(section_id_prt  section.section_id%TYPE)
          RETURN NUMBER;
          
        END;
/        
CREATE OR REPLACE PACKAGE BODY enrollment_pkg IS

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
        ELSE
            lv_total_fees := lv_program_fees;
        END IF;
        RETURN lv_total_fees;
    END get_fees;
    FUNCTION check_capacity(section_id_prt  section.section_id%TYPE)
    RETURN NUMBER
IS
    lv_capacity_available   NUMBER;
    lv_section_ocupancy     section.section_id%TYPE;
    lv_capacity             section.capacity%TYPE;
    lv_disponibility        NUMBER;
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
    lv_disponibility:=lv_capacity-lv_section_ocupancy;
    dbms_output.put_line('There is disponibility '||lv_disponibility);
    lv_capacity_available:=1;
    RETURN lv_capacity_available;
    ELSE
    dbms_output.put_line('There is not disponibility '||lv_disponibility);
    lv_capacity_available:=0;
    RETURN lv_capacity_available;
    END IF;
    END check_capacity;
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