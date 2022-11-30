CREATE OR REPLACE FUNCTION get_fees (student_id_prt student.student_id%TYPE)
RETURN NUMBER
IS
lv_is_domestic              NUMBER;
lv_total_fees               NUMBER:=4000;
lv_multiplication_factor    NUMBER:=3;
BEGIN
    SELECT  is_domestic
    INTO    lv_is_domestic
    FROM    student
    WHERE   student_id=student_id_prt;
    
    
    IF (lv_is_domestic = 0) THEN
    lv_total_fees:=lv_total_fees*lv_multiplication_factor;
    END IF;
    RETURN lv_total_fees;
END;
    
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
    