

-- Add students by their college id to a section    
INSERT INTO SECTION_ENROLLMENT (SECTION_ID, ENROLLMENT_ID)
    VALUES (1, 10000);
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
    
    
    
    
    

-- check the number of students from section_enrollment and compare to capacity
SELECT se.section_id, s.section_type, count(se.SECTION_ID) AS Students, s.capacity
    FROM SECTION_ENROLLMENT se
    JOIN SECTION s
        ON se.section_id = s.section_id
    HAVING COUNT(*) < s.capacity AND se.section_id = 3
    GROUP BY se.SECTION_ID, s.section_type, s.capacity;


-- check the number of students from section_enrollment and compare to capacity
SELECT se.section_id
    FROM SECTION_ENROLLMENT se
    JOIN SECTION s
        ON se.section_id = s.section_id
    HAVING COUNT(*) < s.capacity AND se.section_id = 3
    GROUP BY se.SECTION_ID, s.section_type, s.capacity;
