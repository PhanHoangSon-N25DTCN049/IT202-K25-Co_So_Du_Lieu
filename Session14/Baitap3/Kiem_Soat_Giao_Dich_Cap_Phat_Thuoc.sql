/*
Dữ liệu đầu vào (IN): p_patient_id (Mã bệnh nhân), p_medicine_id (Mã thuốc), p_quantity (Số lượng cấp phát).
Dữ liệu đầu ra (OUT): p_status_message (Thông báo trạng thái hệ thống).
Giải pháp kiểm soát giao dịch: Sử dụng START TRANSACTION. Trước khi trừ kho, dùng câu lệnh SELECT để kiểm tra số lượng tồn kho thực tế. Nếu không đủ,
 chủ động gọi ROLLBACK và trả về thông báo lỗi. Nếu đủ, tiến hành trừ kho, cộng công nợ và COMMIT. Đồng thời cấu hình EXIT HANDLER đề phòng lỗi hệ thống đột xuất.
*/

DROP PROCEDURE IF EXISTS DispenseMedicine;

DELIMITER //

CREATE PROCEDURE DispenseMedicine(
    IN p_patient_id INT,
    IN p_medicine_id INT,
    IN p_quantity INT,
    OUT p_status_message VARCHAR(255)
)
BEGIN
    -- Khai báo biến cục bộ để lưu tồn kho và đơn giá thuốc
    DECLARE v_current_stock INT;
    DECLARE v_medicine_price DECIMAL(18,2);

    -- Bộ xử lý ngoại lệ hệ thống (lỗi crash, lỗi kết nối...)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_message = 'Lỗi: Hệ thống gặp sự cố ngoài ý muốn.';
    END;

    -- Bắt đầu giao dịch
    START TRANSACTION;

    -- Lấy thông tin tồn kho và đơn giá của thuốc
    SELECT stock_quantity, price 
    INTO v_current_stock, v_medicine_price
    FROM Medicines 
    WHERE medicine_id = p_medicine_id;

    -- KIỂM TRA NGHIỆP VỤ: Nếu thiếu hàng hoặc thuốc không tồn tại
    IF v_current_stock IS NULL OR v_current_stock < p_quantity THEN
        ROLLBACK; -- Hoàn tác mọi thứ (nếu có)
        SET p_status_message = 'Lỗi: Số lượng tồn kho không đủ';
    ELSE
        -- Thao tác 1: Trừ đi số lượng cấp phát trong kho thuốc
        UPDATE Medicines 
        SET stock_quantity = stock_quantity - p_quantity
        WHERE medicine_id = p_medicine_id;

        -- Thao tác 2: Cộng dồn tiền thuốc vào tổng công nợ của bệnh nhân
        UPDATE Patient_Invoices 
        SET amount_due = amount_due + (p_quantity * v_medicine_price)
        WHERE patient_id = p_patient_id;

        -- Xác nhận giao dịch thành công hoàn toàn
        COMMIT;
        SET p_status_message = 'Đã cấp phát thành công';
    END IF;
    
END //

DELIMITER ;

-- CHUẨN BỊ: Khai báo biến nhận thông báo
SET @msg = '';

-- Giả sử thuốc ID = 1 còn tồn 50 hộp, bệnh nhân ID = 1 mua 2 hộp
CALL DispenseMedicine(1, 1, 2, @msg);
SELECT @msg AS 'Kết quả Test 1'; 
-- Mong đợi: Hiển thị "Đã cấp phát thành công"

-- Giả sử thuốc ID = 2 chỉ còn tồn 5 hộp, nhưng nhân viên nhập hẳn 100 hộp
CALL DispenseMedicine(1, 2, 100, @msg);
SELECT @msg AS 'Kết quả Test 2'; 
-- Mong đợi: Hiển thị "Lỗi: Số lượng tồn kho không đủ" (Kho và nợ không bị thay đổi)