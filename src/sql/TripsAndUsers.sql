# Write your MySQL query statement below
SELECT Request_at AS Day,  
       ROUND(SUM(CASE WHEN Status = 'completed' THEN 0 ELSE 1 END) 
       / COUNT(*),2) AS "Cancellation Rate"
  FROM Trips t 
 WHERE Request_at >= '2013-10-01'
   AND Request_at <= '2013-10-03'
   AND EXISTS (SELECT Users_Id FROM Users WHERE Banned = 'No' AND Users_Id = t.Client_Id)
 GROUP BY Request_at
 ORDER BY Request_at;