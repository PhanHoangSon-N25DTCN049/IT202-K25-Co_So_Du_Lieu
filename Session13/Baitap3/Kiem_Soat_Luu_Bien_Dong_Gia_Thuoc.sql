/*
Dùng BEFORE UPDATE trên bảng Medicines vì mình cần phải kiểm tra và chặn đứng giao dịch ngay lập tức nếu nhân viên gõ nhầm giá mới $\le 0$ trước khi dữ liệu kịp lưu vào máy.
Dùng NEW.price để check xem giá mới có hợp lệ không (nếu <= thì bắn lỗi SIGNAL SQLSTATE '45000').
So sánh NEW.price và OLD.price để biết giá có bị thay đổi hay không. Nếu chỉ sửa tên thuốc hay tồn kho (NEW.price = OLD.price) -> Bỏ qua, không ghi log rác.
Nếu giá thay đổi: Lấy NEW.price - OLD.price nếu tăng giá, hoặc OLD.price - NEW.price nếu giảm giá rồi insert vào bảng Log.
*/
CREATE TABLE Price_Changes_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_id INT NOT NULL,
    old_price DECIMAL(10,2) NOT NULL,
    new_price DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    price_diff DECIMAL(10,2) NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



DELIMITER //
CREATE TRIGGER LogPriceChanges
BEFORE UPDATE ON Medicines
FOR EACH ROW
BEGIN
    -- 1. Chặn đứng nếu giá mới âm hoặc bằng 0
    IF NEW.price <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Giá thuốc mới không hợp lệ';
        
    -- 2. Chỉ xử lý khi thực sự có biến động về giá (tránh log rác)
    ELSEIF NEW.price <> OLD.price THEN
        IF NEW.price > OLD.price THEN
            -- Trường hợp TĂNG GIÁ
            INSERT INTO Price_Changes_Log (medicine_id, old_price, new_price, status, price_diff)
            VALUES (OLD.medicine_id, OLD.price, NEW.price, 'TĂNG GIÁ', NEW.price - OLD.price);
        ELSE
            -- Trường hợp GIẢM GIÁ
            INSERT INTO Price_Changes_Log (medicine_id, old_price, new_price, status, price_diff)
            VALUES (OLD.medicine_id, OLD.price, NEW.price, 'GIẢM GIÁ', OLD.price - NEW.price);
        END IF;
    END IF;
END //
DELIMITER ;

-- Case 1: Tăng giá hợp lệ (Hệ thống phải sinh log 'TĂNG GIÁ')
UPDATE Medicines SET price = 150000 WHERE medicine_id = 1;

-- Case 2: Giảm giá hợp lệ (Hệ thống phải sinh log 'GIẢM GIÁ')
UPDATE Medicines SET price = 90000 WHERE medicine_id = 1;

-- Case 3: Chỉ cập nhật tồn kho, giữ nguyên giá (Hệ thống tuyệt đối KHÔNG sinh log)
UPDATE Medicines SET stock = 120 WHERE medicine_id = 1;

-- Case 4: Nhập thử giá âm (Hệ thống phải CHẶN lại và báo lỗi "Giá thuốc mới không hợp lệ")
UPDATE Medicines SET price = -5000 WHERE medicine_id = 1;
UPDATE Medicines SET price = -5000 WHERE medicine_id = 1;