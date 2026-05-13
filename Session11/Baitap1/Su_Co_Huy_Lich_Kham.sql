CALL CancelAppointment(2); 
-- Kết quả: Lịch khám ID 2 bị đổi sang 'Cancelled' dù đã khám xong.

/*
lịch khám đã hoàn tất vẫn bị hệ thống cho phép hủy do khi cập nhật chỉ dựa vào id mà không kiểm tra status có phải là 'Pending' hay không
từ đó hệ thống sẽ hủy tất cả id được truyền vào 
*/

DROP PROCEDURE IF EXISTS CancelAppointment;

DELIMITER //
CREATE PROCEDURE CancelAppointment(IN p_appointment_id INT)
BEGIN
    UPDATE Appointments 
    SET status = 'Cancelled'
    WHERE appointment_id = p_appointment_id 
      AND status = 'Pending'; 
END //
DELIMITER ;