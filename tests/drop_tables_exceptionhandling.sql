BEGIN
     EXECUTE IMMEDIATE 'DROP TABLE tablename';
EXCEPTION
     WHEN OTHERS THEN
            IF SQLCODE != -942 THEN
                 --RAISE;
                DBMS_OUTPUT.PUT_LINE('HELLO');
            ELSE
                DBMS_OUTPUT.PUT_LINE('ELSE');
            END IF;
            
END;