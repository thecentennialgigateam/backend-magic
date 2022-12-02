/*
This function verifies if there are available seats in the section.
It receives one parameter:
@section_id: the section id
It returns true (1) if there are available seats, false (0) otherwise
*/
*/

CREATE OR REPLACE FUNCTION check_capacity(section_id_prt  section.section_id%TYPE)
    RETURN NUMBER
IS
    lv_capacity_available   NUMBER;
    lv_section_ocupancy     section.section_id%TYPE;
    lv_capacity             section.capacity%TYPE;
    lv_availability        NUMBER;
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
        lv_availability:=lv_capacity-lv_section_ocupancy;
        dbms_output.put_line('There is availability '||lv_availability);
        lv_capacity_available:=1;
    RETURN lv_capacity_available;
    ELSE
        dbms_output.put_line('There is not availability '||lv_availability);
        lv_capacity_available:=0;
    RETURN lv_capacity_available;
    END IF;
    
    EXCEPTION 
        WHEN no_data_found THEN
        dbms_output.put_line('You are looking for a not available section');
        RETURN null;
END;

