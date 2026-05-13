

DELIMITER //

CREATE PROCEDURE GetPatientDebt (
    IN p_ID INT,
    IN p_Phone VARCHAR(15),
    OUT p_total_debt DECIMAL(18,2),
    OUT p_message VARCHAR(255)
)
BEGIN
    -- Khởi tạo giá trị mặc định
    SET p_total_debt = 0;

    IF p_ID IS NULL AND p_Phone IS NULL THEN
        SET p_message = 'Lỗi: Vui lòng nhập ID hoặc Số điện thoại để tra cứu!';

    ELSE
        -- Thực hiện tìm kiếm (Ưu tiên ID nếu có cả hai)
        SELECT total_debt INTO p_total_debt
        FROM patient
        WHERE (p_ID IS NOT NULL AND id = p_ID)
           OR (p_ID IS NULL AND p_Phone IS NOT NULL AND phone = p_Phone)
        LIMIT 1;

        -- KỊCH BẢN 2: Kiểm tra kết quả tìm thấy
        IF p_total_debt IS NULL OR (SELECT COUNT(*) FROM patient WHERE id = p_ID OR phone = p_Phone) = 0 THEN
            SET p_total_debt = 0;
            SET p_message = 'Thông báo: Không tìm thấy thông tin bệnh nhân.';
        ELSE
            SET p_message = 'Tra cứu công nợ thành công.';
        END IF;
    END IF;
    
    SELECT p_total_debt AS TotalDebt, p_message AS StatusMessage;
END //

DELIMITER ;