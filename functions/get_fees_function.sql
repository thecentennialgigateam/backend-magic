-- function get_fees(student_id, program_id) returns total_fees of type Number
CREATE OR REPLACE FUNCTION get_fees (student_id_prt student.student_id%TYPE, 
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
END;