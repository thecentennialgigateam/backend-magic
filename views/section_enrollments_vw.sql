-- this view shows the numbers of students enrolled in each course by section
CREATE VIEW section_enrollments_vw 
AS 
(
    SELECT s.section_id, c.course_name, s.section_type, s.capacity, 
        COUNT(se.enrollment_id) AS registered_students
    FROM SECTION s
    JOIN section_enrollment se
    ON s.section_id = se.section_id
    JOIN course c
    ON s.course_id = c.course_id
    GROUP BY s.section_id, c.course_name, s.section_type, s.capacity
);