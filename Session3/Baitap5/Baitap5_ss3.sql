-- dùng check để giới hạn dữ liệu nhập vào > 0
-- khách hàng bấm add to cart đúng mặt hàng đã có sẵn trong giỏ thì cộng dồn bằng update

INSERT INTO CART_ITEMS (CartID, ProductID, Quantity, AddedDate)
VALUES (101, 2002, 1, NOW())
ON DUPLICATE KEY UPDATE 
    Quantity = Quantity + 1,
    AddedDate = NOW();
    
SELECT ProductID, Quantity, AddedDate
FROM CART_ITEMS
WHERE CartID = 101;

UPDATE CART_ITEMS
SET Quantity = 5 -- Giả sử khách đổi thành 5 lốc sữa
WHERE CartID = 101 
  AND ProductID = 2002 
  AND 5 > 0; -- Chốt chặn bẫy số âm
  
DELETE FROM CART_ITEMS
WHERE CartID = 101 
  AND ProductID = 2002;