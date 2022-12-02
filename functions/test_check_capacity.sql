
--//////////////////TESTING///////////////////
DECLARE
    lv_something NUMBER;
BEGIN
    lv_something:=check_capacity(5);
    --dbms_output.put_line(lv_something);
END;
--///////////////TESTING ERRORS///////////////////
DECLARE
    lv_something NUMBER;
BEGIN
    lv_something:=check_capacity(20);
    --dbms_output.put_line(lv_something);
END;
