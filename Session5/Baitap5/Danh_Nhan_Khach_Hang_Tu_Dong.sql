-- dùng CASE để rẽ nhánh logic và tự tạo ra cột ảo 

SELECT user_name AS Ten_Khach_Hang, 
CASE 
WHEN total_orders > 500 THEN 'Kim Cương'
WHEN total_orders >= 100 AND total_orders <= 500 THEN 'Vàng'
WHEN total_orders < 100 OR total_orders IS NULL THEN 'Bạc' 
END AS Xep_Hang
FROM Users;

/* Khi cột total_orders là null sẽ được xếp vào hạng bạc vì case sẽ kiểm tra null tại dòng OR: total_orders IS NULL */