/* 
    This function will calculate the student fees.
    It receives two parameters:
    @student_id: the student id
    @program_id: the program id
    It calculates the fees based on the student.is_domestic value
    if it is true, it will get the fee from program and return it as it is.
    if it is false, it will get the fee from program and multiply it by 3 (multiply factor)
    if the values for student_id or program_id are not valid, it will return 0
*/
create or replace FUNCTION get_fees (student_id_prt student.student_id%TYPE, 
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
        DBMS_OUTPUT.PUT_LINE('calculated intl fee: ' || lv_total_fees);
        RETURN lv_total_fees;
    ELSIF (lv_is_domestic = 1) THEN
        lv_total_fees := lv_program_fees;
        DBMS_OUTPUT.PUT_LINE('calculated dmst fee: ' || lv_total_fees);
        RETURN lv_total_fees;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Incorrect student or program data specified');
        RETURN null;
    END IF;    
    exception
      when no_data_found 
      then DBMS_OUTPUT.PUT_LINE('SQL DATA NOT FOUND');
      RETURN lv_total_fees;
END;
