CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
DECLARE M INT;
SET M = N - 1;
  RETURN (
     select distinct Salary from Employee order by Salary desc limit M, 1
  );
END
