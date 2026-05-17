UPDATE Appointments 
SET status = 'Completed' 
WHERE appointment_id = 104;

/*
Để kiểm tra một lịch khám đã hoàn thành hay chưa, mình bắt buộc phải dùng đối tượng OLD.
Vì sao: OLD giữ trạng thái cũ đang lưu trong database. 
Quy định là lịch đã Completed thì không được sửa nữa, nên phải check xem OLD.status = 'Completed' hay không để chặn lại.
 dev cũ dùng NEW (trạng thái mới định đổi sang) nên hệ thống hiểu lầm là đang muốn đổi lịch sang Completed -> chặn luôn cả tác vụ hợp lệ.
*/

DROP TRIGGER IF EXISTS PreventStatusRevert;

DELIMITER //
CREATE TRIGGER PreventStatusRevert
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
    -- Đổi từ NEW sang OLD để check trạng thái gốc trong database
    IF OLD.status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Lịch khám đã hoàn thành (Completed), không được phép chỉnh sửa!';
    END IF;
END //
DELIMITER ;