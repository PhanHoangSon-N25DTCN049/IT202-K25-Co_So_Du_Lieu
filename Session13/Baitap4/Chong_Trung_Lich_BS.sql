/*
Appointments. Phải dùng BEFORE để chặn câu lệnh lại và bắn lỗi trước khi dữ liệu bị ghi đè vào database.
Mệnh đề WHERE để xử lý ngoại lệ:
Ngoại lệ 1 (Bỏ qua lịch bị hủy): Thêm điều kiện status <> 'Cancelled' để hệ thống không tính các ca đã hủy là ca bị trùng.
Ngoại lệ 2 (Không tự trùng với chính mình khi UPDATE): Ở trigger UPDATE, thêm điều kiện appointment_id <> NEW.appointment_id để hệ thống bỏ qua chính ca khám đang được chỉnh sửa.
*/

DELIMITER //
CREATE TRIGGER PreventDoubleBooking_Insert
BEFORE INSERT ON Appointments
FOR EACH ROW
BEGIN
    -- Kiểm tra xem bác sĩ đã có lịch nào ở khung giờ này mà chưa bị hủy không
    IF EXISTS (
        SELECT 1 FROM Appointments
        WHERE doctor_id = NEW.doctor_id
          AND appointment_date = NEW.appointment_date
          AND status <> 'Cancelled'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Bác sĩ đã có lịch hẹn vào khung giờ này';
    END IF;
END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER PreventDoubleBooking_Update
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
    -- Check trùng lịch nhưng phải né chính ID của ca khám đang sửa ra
    IF EXISTS (
        SELECT 1 FROM Appointments
        WHERE doctor_id = NEW.doctor_id
          AND appointment_date = NEW.appointment_date
          AND status <> 'Cancelled'
          AND appointment_id <> NEW.appointment_id -- Vượt qua ngoại lệ 2
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi: Bác sĩ đã có lịch hẹn vào khung giờ này';
    END IF;
END //
DELIMITER ;

-- Kịch bản 1: Thêm lịch vào khung giờ trống hoàn toàn -> THÀNH CÔNG
INSERT INTO Appointments (appointment_id, doctor_id, appointment_date, status) 
VALUES (901, 5, '2026-06-20 09:00:00', 'Pending');

-- Kịch bản 2: Thêm lịch trùng vào khung giờ đang 'Pending' của bác sĩ đó -> BỊ CHẶN & BÁO LỖI
INSERT INTO Appointments (appointment_id, doctor_id, appointment_date, status) 
VALUES (902, 5, '2026-06-20 09:00:00', 'Pending');

-- Kịch bản 3: Chuyển lịch cũ thành 'Cancelled', sau đó thêm lịch mới cùng giờ -> THÀNH CÔNG
UPDATE Appointments SET status = 'Cancelled' WHERE appointment_id = 901;

INSERT INTO Appointments (appointment_id, doctor_id, appointment_date, status) 
VALUES (903, 5, '2026-06-20 09:00:00', 'Pending');

-- Kịch bản 4: Cập nhật trạng thái ca 903 từ 'Pending' sang 'Completed' -> THÀNH CÔNG (Không tự trùng)
UPDATE Appointments SET status = 'Completed' WHERE appointment_id = 903;