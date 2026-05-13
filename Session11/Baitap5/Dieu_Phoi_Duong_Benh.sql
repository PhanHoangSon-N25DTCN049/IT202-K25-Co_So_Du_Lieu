DELIMITER //

CREATE PROCEDURE FindAvailableBed(
    IN p_dept_id INT,
    OUT p_bed_id INT
)
BEGIN
    SELECT bed_id INTO p_bed_id
    FROM Beds
    WHERE dept_id = p_dept_id AND is_available = 1
    LIMIT 1
    FOR UPDATE; 
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE TransferPatientMaster(
    IN p_patient_id INT,
    IN p_target_dept_id INT,
    OUT p_new_bed_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_current_status VARCHAR(50);
    DECLARE v_old_bed_id INT;
    DECLARE v_dept_name VARCHAR(100);
    DECLARE v_found_bed_id INT;

    -- Bắt đầu giao dịch để đảm bảo an toàn tuyệt đối
    START TRANSACTION;

    -- 1. Kiểm tra trạng thái bệnh nhân
    SELECT status, current_bed_id INTO v_current_status, v_old_bed_id
    FROM Patients WHERE patient_id = p_patient_id;

    IF v_current_status = 'Completed' THEN
        SET p_message = 'Lỗi: Bệnh nhân đã xuất viện, không thể chuyển khoa.';
        SET p_new_bed_id = NULL;
        ROLLBACK;
    ELSE
        -- 2. Tìm khoa chuyển đến có tồn tại không
        SELECT dept_name INTO v_dept_name FROM Departments WHERE dept_id = p_target_dept_id;
        
        IF v_dept_name IS NULL THEN
            SET p_message = 'Lỗi: Khoa chuyển đến không tồn tại.';
            ROLLBACK;
        ELSE
            -- 3. Gọi Procedure phụ tìm giường
            CALL FindAvailableBed(p_target_dept_id, v_found_bed_id);

            IF v_found_bed_id IS NULL THEN
                SET p_message = CONCAT('Từ chối: Khoa ', v_dept_name, ' đã hết giường.');
                SET p_new_bed_id = NULL;
                ROLLBACK;
            ELSE
                -- 4. Thực hiện chuyển giường (Atomic Operations)
                -- Giải phóng giường cũ
                IF v_old_bed_id IS NOT NULL THEN
                    UPDATE Beds SET is_available = 1 WHERE bed_id = v_old_bed_id;
                END IF;

                -- Cập nhật giường mới cho bệnh nhân
                UPDATE Patients SET current_bed_id = v_found_bed_id WHERE patient_id = p_patient_id;

                -- Khóa giường mới
                UPDATE Beds SET is_available = 0 WHERE bed_id = v_found_bed_id;

                SET p_new_bed_id = v_found_bed_id;
                SET p_message = 'Thành công: Đã điều phối giường mới.';
                COMMIT; -- Hoàn tất giao dịch
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;

-- (1) Chuyển khoa thành công
CALL TransferPatientMaster(101, 5, @bed, @msg);
SELECT @bed, @msg;

-- (2) Bẫy hết giường trống (Giả sử khoa 9 đã đầy)
CALL TransferPatientMaster(102, 9, @bed, @msg);
SELECT @bed, @msg;

-- (3) Bẫy bệnh nhân đã xuất viện (Status = 'Completed')
CALL TransferPatientMaster(103, 5, @bed, @msg);
SELECT @bed, @msg;

-- (4) Chuyển vào Dept_ID không tồn tại
CALL TransferPatientMaster(101, 999, @bed, @msg);
SELECT @bed, @msg;

