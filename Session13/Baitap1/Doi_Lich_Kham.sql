UPDATE Appointments 
SET appointment_date = '2025-01-15 08:00:00' 
WHERE appointment_id = 104;

/*
OLD.appointment_date là lịch khám cũ đang lưu trong database, còn NEW.appointment_date là lịch khám mới tinh mà tiếp tân vừa nhập vào để thay đổi.

dev cũ viết nhầm điều kiện check sang OLD.appointment_date < NOW(). Thay vì kiểm tra xem lịch mới (NEW) có bị dời về quá khứ không, trigger lại đi check cái lịch cũ .
 Do lịch cũ không nhỏ hơn thời gian hiện tại nên trigger bỏ qua, không chặn lại làm hệ thống bị lỗi dữ liệu.
*/

DROP TRIGGER IF EXISTS PreventPastAppointments;

DELIMITER //

CREATE TRIGGER PreventPastAppointments
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
    -- Đổi từ OLD sang NEW để check lịch mới nhập vào
    IF NEW.appointment_date < NOW() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Không được phép dời lịch khám về quá khứ!';
    END IF;
END //

DELIMITER ;