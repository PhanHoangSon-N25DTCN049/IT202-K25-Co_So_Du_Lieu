

DELIMITER //

CREATE PROCEDURE CalculateDischargeCost(
    IN p_total_cost DECIMAL(18,2), 
    IN p_patient_type VARCHAR(10),
    OUT p_final_amount DECIMAL(18,2), 
    OUT p_message VARCHAR(255)   
)
BEGIN
    -- 1. Kiểm tra tính hợp lệ của chi phí đầu vào
    IF p_total_cost < 0 THEN
        SET p_final_amount = 0;
        SET p_message = 'Lỗi: Chi phí không hợp lệ';
    ELSE
        -- 2. Tính toán dựa trên diện bệnh nhân
        CASE p_patient_type
            WHEN 'BHYT' THEN 
                SET p_final_amount = p_total_cost * 0.2; -- Hỗ trợ 80%, đóng 20%
            WHEN 'VIP' THEN 
                SET p_final_amount = p_total_cost * 0.9; -- Giảm 10%, đóng 90%
            WHEN 'THUONG' THEN 
                SET p_final_amount = p_total_cost;       -- Đóng 100%
            ELSE 
                SET p_final_amount = p_total_cost;       -- Mặc định như THUONG
        END CASE;
        
        SET p_message = 'Đã tính toán xong';
    END IF;
    
    SELECT p_final_amount AS Result_Amount, p_message AS Status_Message;
END //

DELIMITER ;

-- Trường hợp 1: Bệnh nhân BHYT (Chi phí 1.000.000 -> Phải trả 200.000)
CALL CalculateDischargeCost(1000000, 'BHYT', @amount1, @msg1);

-- Trường hợp 2: Bệnh nhân VIP (Chi phí 1.000.000 -> Phải trả 900.000)
CALL CalculateDischargeCost(1000000, 'VIP', @amount2, @msg2);

-- Trường hợp 3: Bệnh nhân THUONG (Chi phí 1.000.000 -> Phải trả 1.000.000)
CALL CalculateDischargeCost(1000000, 'THUONG', @amount3, @msg3);

-- Trường hợp 4: Lỗi nhập số âm (Chi phí -500.000 -> Trả về 0 và báo lỗi)
CALL CalculateDischargeCost(-500000, 'BHYT', @amount4, @msg4);