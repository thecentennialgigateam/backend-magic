-- testing tables
SELECT country, COUNT(*) AS students
    FROM student
    GROUP BY country
    ORDER BY students DESC;

SELECT EXTRACT(YEAR from DOB) AS birth_year, 2022 - EXTRACT(YEAR from DOB) AS age,
COUNT(*) AS students
    FROM student
    GROUP BY EXTRACT(YEAR from DOB)
    ORDER BY EXTRACT(YEAR from DOB) ASC;

-- testing program and department tables
SELECT p.program_name, d.department_id, d.department_name, d.department_head
FROM program p
JOIN department d
ON p.department_id = d.department_id
where ROWNUM <= 20;