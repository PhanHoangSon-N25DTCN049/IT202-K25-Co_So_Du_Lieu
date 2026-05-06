/* Theo thứ tự thực thi cú pháp Where sẽ được thực hiện trước nhưng khi đọc tới SUM(total_price) > 0 hệ thống sẽ không hiểu được và báo lỗi*/

-- Sủa lại cho đúng:
SELECT city, SUM( total_price ) AS revenue
FROM Bookings
WHERE status = 'COMPELETED'
GROUP BY city
HAVING SUM( total_price ) > 0;
