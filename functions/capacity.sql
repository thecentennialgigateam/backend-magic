
--/////////////////////////////////////////////////////////////////////

CREATE OR REPLACE FUNCTION confirm_capacity(section_id_prt  section.section_id%TYPE, 
                                            capacity_prt    section.capacity%TYPE)
    RETURN NUMBER
IS
    lv_capacity_available   NUMBER;
    lv_section_ocupancy     section.section_id%TYPE;
    lv_capacity             section.capacity%TYPE;
    lv_disponibilitie       NUMBER;
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
    lv_disponibilitie:=lv_capacity-lv_section_ocupancy;
    dbms_output.put_line('There is disponibility '||lv_disponibilitie);
    lv_capacity_available:=1;
    RETURN lv_capacity_available;
    ELSE
    dbms_output.put_line('There is not disponibility '||lv_disponibilitie);
    lv_capacity_available:=0;
    RETURN lv_capacity_available;
    END IF;
END;

DECLARE
    lv_something NUMBER;
BEGIN
    lv_something:=confirm_capacity(1,10);
    --dbms_output.put_line(lv_something);
END;
commit;

--/////////////////////////////////////////////////////////


-- Add students by their college id to a section    
INSERT INTO SECTION_ENROLLMENT (SECTION_ID, ENROLLMENT_ID)
    VALUES (1, 10012);
INSERT INTO SECTION_ENROLLMENT (SECTION_ID, ENROLLMENT_ID)
    VALUES (1, 10003);
INSERT INTO SECTION_ENROLLMENT (SECTION_ID, ENROLLMENT_ID)
    VALUES (1, 10006);

INSERT INTO SECTION_ENROLLMENT (SECTION_ID, ENROLLMENT_ID)
    VALUES (2, 10009);
INSERT INTO SECTION_ENROLLMENT (SECTION_ID, ENROLLMENT_ID)
    VALUES (2, 10003);

INSERT INTO SECTION_ENROLLMENT (SECTION_ID, ENROLLMENT_ID)
    VALUES (3, 10009);



DECLARE
    --lv_something NUMBER;
BEGIN
    create_enrollment_sp(1105, 311, 0, 1, '1-Sep-2022', get_fees(1105, 311) );
    
END;






