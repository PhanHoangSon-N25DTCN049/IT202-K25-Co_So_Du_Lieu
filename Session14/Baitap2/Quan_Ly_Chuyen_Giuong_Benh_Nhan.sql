/*
Sự cố bệnh nhân bị "mất tích" do hệ thống chỉ chạy xong lệnh giải phóng giường cũ rồi ngắt kết nối đang vi phạm nghiêm trọng tính Atomicity (Tính nguyên tử) trong nguyên lý ACID.
Đặc tính này yêu cầu một giao dịch phải được thực hiện trọn vẹn theo nguyên tắc "Tất cả hoặc không có gì" (All or Nothing), không được phép dừng lại ở trạng thái nửa vời.
*/
-- Xóa thủ tục cũ nếu đã tồn tại
DROP PROCEDURE IF EXISTS TransferBed;

DELIMITER //

CREATE PROCEDURE TransferBed(
    IN p_patient_id INT,
    IN p_old_bed_id INT,
    IN p_new_bed_id INT
)
BEGIN
    -- Cơ chế tự động hoàn tác (ROLLBACK) nếu xảy ra lỗi hệ thống hoặc sập mạng
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    -- Bắt đầu khối giao dịch thống nhất
    START TRANSACTION;

    -- Bước 1: Giải phóng giường cũ (chuyển trạng thái về trống và xóa mã bệnh nhân)
    UPDATE Beds 
    SET is_available = 1, patient_id = NULL 
    WHERE bed_id = p_old_bed_id;

    -- Bước 2: Gán bệnh nhân vào giường mới (chuyển trạng thái về đã có người)
    UPDATE Beds 
    SET is_available = 0, patient_id = p_patient_id 
    WHERE bed_id = p_new_bed_id;

    -- Xác nhận lưu thay đổi vĩnh viễn khi cả 2 bước trên đều thành công
    COMMIT;
    
END //

DELIMITER ;