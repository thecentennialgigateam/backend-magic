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
    update_enrollment_sp(10003,1105, 334, 0, 1, '30-Sep-2022', get_fees(1105, 334) );
    
END;


DECLARE
BEGIN
<<<<<<< HEAD
DELETE FROM ENROLLMENT WHERE ENROLLMENT_ID=10000;
END;
=======
DELETE FROM ENROLLMENT WHERE ENROLLMENT_ID=10021;
END;
>>>>>>> c9f6051b628955fd9e55ef15ab407d8245ab9d51
