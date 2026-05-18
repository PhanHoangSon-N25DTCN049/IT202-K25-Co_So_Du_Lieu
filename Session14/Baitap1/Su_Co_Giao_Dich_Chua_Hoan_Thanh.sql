-- Gọi thủ tục thanh toán để tái hiện lỗi
CALL PayHospitalFee(1, 500000);

-- Kiểm tra: Tiền trong ví đã trừ nhưng nợ chưa giảm
SELECT * FROM Wallets WHERE patient_id = 1;
SELECT * FROM Patient_Invoices WHERE patient_id = 1;

/*
Sự cố trên vi phạm tính Atomicity (Tính nguyên tử). Theo nguyên tắc này, giao dịch phải được thực hiện theo kiểu "Tất cả hoặc không có gì" (All or Nothing).
Việc hệ thống chỉ chạy lệnh trừ tiền mà bỏ qua lệnh giảm nợ đã làm mất tính toàn vẹn của database.
*/

DROP PROCEDURE IF EXISTS PayHospitalFee;

DELIMITER //

CREATE PROCEDURE PayHospitalFee(
    IN p_patient_id INT, 
    IN p_amount DECIMAL(18,2)
)
BEGIN
    -- Nếu gặp lỗi hệ thống hoặc lỗi mạng, tự động ROLLBACK
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi! Giao dịch thất bại và đã hoàn tác.';
    END;

    -- Bắt đầu giao dịch
    START TRANSACTION;

    -- 1. Trừ tiền ví bệnh nhân
    UPDATE Wallets 
    SET balance = balance - p_amount 
    WHERE patient_id = p_patient_id;

    -- 2. Giảm công nợ viện phí
    UPDATE Patient_Invoices 
    SET amount_due = amount_due - p_amount 
    WHERE patient_id = p_patient_id;

    -- Xác nhận hoàn thành khi cả 2 lệnh trên đều chạy tốt
    COMMIT;
END //
DELIMITER ;


