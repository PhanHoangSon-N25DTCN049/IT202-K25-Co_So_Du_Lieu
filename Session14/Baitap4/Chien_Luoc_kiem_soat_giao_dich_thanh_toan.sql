/*
Tham số đầu vào (IN): p_patient_id (INT) - Mã bệnh nhân; p_amount (DECIMAL(18,2)) - Số tiền cần thanh toán.
Tham số đầu ra (OUT): p_status_message (VARCHAR(255)) - Thông báo trạng thái kết quả giao dịch.

Về Chiến lược 1, hệ thống sẽ chạy thẳng lệnh cập nhật và chỉ dựa vào cơ chế bắt ngoại lệ (Exception) mặc định của database để rào lỗi. Phương pháp này có ưu điểm là code ngắn gọn,
 viết nhanh và tiết kiệm được một câu lệnh truy vấn. Tuy nhiên, nhược điểm lớn là hệ thống rất khó tự động bắt các lỗi logic nghiệp vụ đặc thù, chẳng hạn như tài khoản không đủ tiền dẫn đến việc ví bị trừ âm.
Về Chiến lược 2, hệ thống sẽ truy xuất và đối chiếu dữ liệu trước, chủ động ngắt giao dịch nếu vi phạm quy tắc. Ưu điểm vượt trội của hướng này là kiểm soát tuyệt đối luồng nghiệp vụ,
 chặn đứng lỗi âm tiền trước khi ghi dữ liệu xuống ổ cứng, đảm bảo an toàn tài chính. Nhược điểm duy nhất là tốn thêm một thao tác SELECT để kiểm tra số dư trước khi thực thi.
Quyết định: Chọn Chiến lược 2 vì đáp ứng hoàn hảo yêu cầu an toàn tuyệt đối và chặn lỗi ví âm từ Giám đốc kỹ thuật.
*/

/*
Khởi tạo giao dịch bằng lệnh START TRANSACTION.
Kiểm tra số tiền đầu vào (nếu <= thì hủy bỏ và ROLLBACK).
Truy vấn số dư ví hiện tại để đối chiếu (nếu số dư < số tiền thanh toán thì hủy bỏ và ROLLBACK).
Thực hiện đồng thời 2 lệnh UPDATE: trừ tiền ví và giảm nợ hóa đơn.
Xác nhận lưu dữ liệu vĩnh viễn bằng lệnh COMMIT.
Sử dụng EXIT HANDLER làm phương án dự phòng để tự động ROLLBACK nếu hệ thống sập nguồn đột xuất.
*/

DROP PROCEDURE IF EXISTS ProcessPayment;

DELIMITER //

CREATE PROCEDURE ProcessPayment(
    IN p_patient_id INT,
    IN p_amount DECIMAL(18,2),
    OUT p_status_message VARCHAR(255)
)
BEGIN
    DECLARE v_wallet_balance DECIMAL(18,2);

    -- Tự động hoàn tác nếu hệ thống sập hoặc lỗi kết nối
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_message = 'Lỗi: Hệ thống gặp sự cố, giao dịch đã hoàn nguyên.';
    END;

    -- 1. Bắt đầu giao dịch
    START TRANSACTION;

    -- Kiểm tra số tiền đầu vào hợp lệ
    IF p_amount <= 0 THEN
        ROLLBACK;
        SET p_status_message = 'Lỗi: Số tiền thanh toán phải lớn hơn 0.';
    ELSE
        -- Lấy số dư ví hiện tại của bệnh nhân
        SELECT balance INTO v_wallet_balance 
        FROM Wallets 
        WHERE patient_id = p_patient_id;

        -- 2. Kiểm tra quy tắc chặn lỗi ví âm
        IF v_wallet_balance IS NULL OR v_wallet_balance < p_amount THEN
            ROLLBACK;
            SET p_status_message = 'Lỗi: Số dư tài khoản không đủ để thanh toán.';
        ELSE
            -- 3. Cập nhật dữ liệu đồng thời
            UPDATE Wallets 
            SET balance = balance - p_amount 
            WHERE patient_id = p_patient_id;

            UPDATE Patient_Invoices 
            SET amount_due = amount_due - p_amount 
            WHERE patient_id = p_patient_id;

            -- 4. Xác nhận giao dịch thành công
            COMMIT;
            SET p_status_message = 'Thanh toán thành công một chạm!';
        END IF;
    END IF;
END //

DELIMITER ;

