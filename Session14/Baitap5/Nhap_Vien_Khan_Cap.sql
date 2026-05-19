/*
Procedure Master và Procedure phụ giao tiếp với nhau thông qua tham số OUT.
 Cụ thể, Procedure Master sẽ truyền tham số dạng IN chứa mã khoa cần tìm vào Procedure phụ.
 Procedure phụ sau khi chạy truy vấn sẽ dùng một tham số dạng OUT để hứng mã giường trống đầu tiên tìm thấy,
 sau đó trả ngược giá trị này về cho Master để hoàn thiện chuỗi giao dịch.
*/

DELIMITER $$

CREATE PROCEDURE sp_FindEmptyBed(
    IN p_department_id VARCHAR(50),
    OUT p_bed_id VARCHAR(50)
)
BEGIN
    -- Lấy mã giường trống đầu tiên của khoa được yêu cầu
    SELECT bed_id INTO p_bed_id
    FROM beds
    WHERE department_id = p_department_id AND status = 'Available'
    LIMIT 1;
END $$

CREATE PROCEDURE sp_AdmitPatient(
    IN p_patient_id VARCHAR(50),
    IN p_doctor_id VARCHAR(50),
    IN p_time DATETIME,
    IN p_department_id VARCHAR(50)
)
BEGIN
    DECLARE v_bed_id VARCHAR(50) DEFAULT NULL;
    DECLARE v_is_admitted INT DEFAULT 0;
    DECLARE v_dept_exists INT DEFAULT 0;

    -- Bẫy lỗi SQL bất ngờ: Tự động Rollback nếu có lỗi xảy ra trong quá trình Insert/Update
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi hệ thống: Giao dịch đã bị hủy và hoàn tác.';
    END;

    -- Bệnh nhân có đang lưu trú không?
    SELECT COUNT(*) INTO v_is_admitted
    FROM admissions
    WHERE patient_id = p_patient_id AND status = 'Admitted';

    IF v_is_admitted > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Từ chối: Bệnh nhân đang lưu trú';
    END IF;

    -- [BƯỚC KIỂM TRA 2] Mã khoa có tồn tại không?
    SELECT COUNT(*) INTO v_dept_exists
    FROM departments
    WHERE department_id = p_department_id;

    IF v_dept_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Từ chối: Khoa không tồn tại';
    END IF;

    --  Tìm giường trống trong khoa
    CALL sp_FindEmptyBed(p_department_id, v_bed_id);

    --  Khoa còn giường không?
    IF v_bed_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Từ chối: Khoa hiện đã hết giường';
    END IF;

    START TRANSACTION;

        -- Hành động 1: Tạo Lịch khám mới
        INSERT INTO appointments (patient_id, doctor_id, appointment_time, department_id)
        VALUES (p_patient_id, p_doctor_id, p_time, p_department_id);

        -- Hành động 2: Cập nhật trạng thái Giường bệnh thành đã sử dụng
        UPDATE beds
        SET status = 'Occupied'
        WHERE bed_id = v_bed_id;

        -- Hành động 3: Tạo Hồ sơ nội trú (gán giường cho bệnh nhân)
        INSERT INTO admissions (patient_id, bed_id, admission_time, status)
        VALUES (p_patient_id, v_bed_id, p_time, 'Admitted');

    -- Lưu lại toàn bộ thay đổi nếu không có lỗi
    COMMIT;

END $$

DELIMITER ;

-- Kịch bản 1: Nhập viện thành công (Giả định thông tin hợp lệ và K01 còn giường)
CALL sp_AdmitPatient('PAT001', 'DOC015', '2026-05-19 08:30:00', 'K01');

-- Kịch bản 2: Bẫy hết giường trống (Giả định khoa K02 đã sử dụng hết giường)
CALL sp_AdmitPatient('PAT002', 'DOC015', '2026-05-19 09:00:00', 'K02');

-- Kịch bản 3: Bẫy bệnh nhân đang nội trú (Giả định PAT003 đang có status 'Admitted')
CALL sp_AdmitPatient('PAT003', 'DOC008', '2026-05-19 09:15:00', 'K01');

-- Kịch bản 4: Chuyển vào Khoa không tồn tại (Mã K99 không có trong bảng departments)
CALL sp_AdmitPatient('PAT004', 'DOC008', '2026-05-19 09:30:00', 'K99');