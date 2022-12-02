-- increase prices of programs
CREATE OR REPLACE PROCEDURE increase_program_fees
IS
    CURSOR programs_csr
    IS
    SELECT program_id, fees
    FROM program;
    lv_older_fee program.fees%TYPE; 
    lv_new_fee program.fees%TYPE; 

BEGIN
    FOR c_program in programs_csr
    LOOP
        SELECT fees
        INTO lv_older_fee
        FROM program
        WHERE program.program_id = c_program.program_id;
        --
        IF lv_older_fee <= 20000 THEN
            lv_new_fee := lv_older_fee * 1.1;
        ELSIF lv_older_fee > 20000 THEN
            lv_new_fee := lv_older_fee * 1.05;
        END IF;
        --
        UPDATE
            program
        SET
            fees = lv_new_fee
        WHERE
            program.program_id = c_program.program_id;
        --
        DBMS_OUTPUT.PUT_LINE('Increased fees for program: ' ||
        c_program.program_id || 'from $' || lv_older_fee ||
        ' to $' || lv_new_fee);
    END LOOP;  

END increase_program_fees;