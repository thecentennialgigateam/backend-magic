-- TESTING
DECLARE
    --lv_something NUMBER;
BEGIN
    create_enrollment_sp(1105, 311, 0, 1, '1-Sep-2022', get_fees(1105, 311) );
    create_enrollment_sp(1060, 334, 0, 1, '2-Sep-2022', get_fees(1060, 334) );
    create_enrollment_sp(1185, 340, 0, 1, '29-Oct-2022', get_fees(1185, 340) );
    create_enrollment_sp(1695, 326, 0, 1, '15-Nov-2022', get_fees(1695, 326) );
END;
