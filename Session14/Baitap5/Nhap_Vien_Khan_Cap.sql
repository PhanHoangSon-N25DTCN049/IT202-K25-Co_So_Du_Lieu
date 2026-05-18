/*
Tham số đầu vào (IN): p_patient_id (Mã bệnh nhân), p_equipment_id (Mã thiết bị y tế) và p_quantity (Số lượng thiết bị cần thuê/sử dụng).

Tham số đầu ra (OUT): p_status_message (Thông báo kết quả giao dịch).

Mô tả luồng xử lý: Khi điều dưỡng thực hiện lệnh cấp phát thiết bị, hệ thống sẽ mở một giao dịch thống nhất (START TRANSACTION).
 Trước tiên, hệ thống thực hiện chốt kiểm tra số lượng tồn kho của thiết bị y tế đó. Nếu số lượng trong kho không đủ đáp ứng, hệ thống sẽ gọi lệnh ROLLBACK để hủy bỏ và xuất thông báo từ chối.
 Ngược lại, nếu đủ điều kiện, hệ thống sẽ tiến hành đồng thời ba thao tác: trừ bớt số lượng thiết bị trong kho, thêm bản ghi mới vào lịch sử sử dụng thiết bị, và tự động tính toán chi phí để cộng dồn vào tổng công nợ hóa đơn của bệnh nhân.
 Cuối cùng, lệnh COMMIT được gọi để chốt dữ liệu xuống ổ cứng. Một bộ EXIT HANDLER cũng được cấu hình sẵn để tự động hoàn tác nếu xảy ra lỗi sập mạng giữa chừng.
*/

DROP PROCEDURE IF EXISTS ProcessEquipmentTransaction;

DELIMITER //

CREATE PROCEDURE ProcessEquipmentTransaction(
    IN p_patient_id INT,
    IN p_equipment_id INT,
    IN p_quantity INT,
    OUT p_status_message VARCHAR(255)
)
BEGIN
    DECLARE v_current_stock INT;
    DECLARE v_rental_price DECIMAL(18,2);
    DECLARE v_total_cost DECIMAL(18,2);

    -- Cơ chế rào lỗi hệ thống đột xuất (sập nguồn, mất kết nối)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_message = 'Lỗi: Hệ thống gặp sự cố, giao dịch thiết bị đã hủy.';
    END;

    -- 1. Bắt đầu khối giao dịch an toàn
    START TRANSACTION;

    -- Kiểm tra tính hợp lệ của số lượng nhập vào
    IF p_quantity <= 0 THEN
        ROLLBACK;
        SET p_status_message = 'Từ chối: Số lượng thiết bị yêu cầu phải lớn hơn 0';
    ELSE
        -- Lấy thông tin tồn kho và đơn giá thuê của thiết bị
        SELECT stock_quantity, rental_price INTO v_current_stock, v_rental_price
        FROM Medical_Equipments
        WHERE equipment_id = p_equipment_id;

        -- 2. Chốt kiểm tra tồn kho thiết bị
        IF v_current_stock IS NULL OR v_current_stock < p_quantity THEN
            ROLLBACK;
            SET p_status_message = 'Từ chối: Thiết bị không tồn tại hoặc không đủ số lượng trong kho';
        ELSE
            -- Tính tổng chi phí phát sinh
            SET v_total_cost = p_quantity * v_rental_price;

            -- Thao tác 1: Trừ số lượng thiết bị trong kho
            UPDATE Medical_Equipments
            SET stock_quantity = stock_quantity - p_quantity
            WHERE equipment_id = p_equipment_id;

            -- Thao tác 2: Ghi nhận lịch sử sử dụng thiết bị y tế
            INSERT INTO Equipment_Usages (patient_id, equipment_id, quantity, usage_date)
            VALUES (p_patient_id, p_equipment_id, p_quantity, NOW());

            -- Thao tác 3: Cộng dồn chi phí vào hóa đơn viện phí của bệnh nhân
            UPDATE Patient_Invoices
            SET amount_due = amount_due + v_total_cost
            WHERE patient_id = p_patient_id;

            -- 3. Xác nhận lưu dữ liệu vĩnh viễn khi tất cả các bước thành công
            COMMIT;
            SET p_status_message = 'Giao dịch thiết bị y tế thành công!';
        END IF;
    END IF;
END //

DELIMITER ;


SET @equipment_res = '';

-- Kịch bản 1: Giao dịch cấp phát thiết bị thành công hoàn toàn
CALL ProcessEquipmentTransaction(1, 101, 2, @equipment_res);
SELECT @equipment_res AS 'Kết quả Test 1'; 
-- Mong đợi: 'Giao dịch thiết bị y tế thành công!'

-- Kịch bản 2: Bẫy lỗi khi số lượng yêu cầu vượt quá tồn kho hiện tại
CALL ProcessEquipmentTransaction(1, 102, 500, @equipment_res);
SELECT @equipment_res AS 'Kết quả Test 2'; 
-- Mong đợi: 'Từ chối: Thiết bị không tồn tại hoặc không đủ số lượng trong kho'

-- Kịch bản 3: Bẫy lỗi dữ liệu đầu vào không hợp lệ (số lượng <= 0)
CALL ProcessEquipmentTransaction(1, 101, -5, @equipment_res);
SELECT @equipment_res AS 'Kết quả Test 3'; 
-- Mong đợi: 'Từ chối: Số lượng thiết bị yêu cầu phải lớn hơn 0'

-- Kịch bản 4: Gọi mã thiết bị không tồn tại trong danh mục hệ thống
CALL ProcessEquipmentTransaction(1, 9999, 1, @equipment_res);
SELECT @equipment_res AS 'Kết quả Test 4'; 
-- Mong đợi: 'Từ chối: Thiết bị không tồn tại hoặc không đủ số lượng trong kho'