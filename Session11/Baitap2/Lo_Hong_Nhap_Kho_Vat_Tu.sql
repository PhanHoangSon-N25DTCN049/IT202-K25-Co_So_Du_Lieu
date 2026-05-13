CALL AddInventory(10, -500);

/*
khi nhân viên nhập -500 hệ thống sẽ trừ đi vì trong toán học + với số âm nghĩa là trừ,
vì trong procedure không có kiểm tra điều kiện này nên sẽ làm lỗi hệ thống
*/


DROP PROCEDURE IF EXISTS AddInventory;


DELIMITER //

CREATE PROCEDURE AddInventory(IN p_item_id INT, IN p_quantity INT)
BEGIN
    IF p_quantity > 0 THEN
        UPDATE Inventory
        SET stock_quantity = stock_quantity + p_quantity
        WHERE item_id = p_item_id;

    ELSE
        SELECT 'Lỗi: Số lượng vật tư nhập kho phải lớn hơn 0!' AS Message;
    END IF;
END //

DELIMITER ;