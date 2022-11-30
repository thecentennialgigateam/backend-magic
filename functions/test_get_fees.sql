--////////////////CHECKING THE FUNCTION
DECLARE
    specific_student_id NUMBER:=1435;
    total_fees  NUMBER;
BEGIN
    total_fees:=get_fees( specific_student_id);
    dbms_output.put_line('The total fees is: '||total_fees);
END;
--////////////////CHECKING THE FUNCTION
DECLARE
    specific_student_id NUMBER:=1310;
    total_fees  NUMBER;
BEGIN
    total_fees:=get_fees( specific_student_id);
    dbms_output.put_line('The total fees is: '||total_fees);
END;
    