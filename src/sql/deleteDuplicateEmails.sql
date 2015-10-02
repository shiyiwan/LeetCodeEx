DELETE p1 
  FROM Person p1 
 INNER JOIN Person p2 
 WHERE p1.Email = p2.Email 
   AND p1.Id > p2.Id; 
   
# Write your MySQL query statement below
SELECT distinct p1.Email 
  FROM Person p1 
 INNER JOIN Person p2 
 WHERE p1.Email = p2.Email 
   AND p1.id <> p2.id;