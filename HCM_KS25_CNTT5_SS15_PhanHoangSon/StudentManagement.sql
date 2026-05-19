-- 1. Tạo và sử dụng Cơ sở dữ liệu
CREATE DATABASE IF NOT EXISTS StudentManagement;
USE StudentManagement;

-- 2. Xóa các bảng cũ nếu đã tồn tại theo đúng thứ tự ràng buộc khóa ngoại
DROP TABLE IF EXISTS grade_log;
DROP TABLE IF EXISTS grades;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS students;

-- 3. Tạo bảng students (Thông tin sinh viên)
CREATE TABLE students (
    student_id VARCHAR(5) PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    total_debt DECIMAL(10,2) DEFAULT 0.00
);

-- 4. Tạo bảng subjects (Môn học)
CREATE TABLE subjects (
    subject_id VARCHAR(5) PRIMARY KEY,
    subject_name VARCHAR(50) NOT NULL,
    credits INT,
    CONSTRAINT chk_credits CHECK (credits > 0)
);

-- 5. Tạo bảng grades (Điểm số)
CREATE TABLE grades (
    student_id VARCHAR(5),
    subject_id VARCHAR(5),
    score DECIMAL(4,2),
    PRIMARY KEY (student_id, subject_id), -- Khóa chính phức hợp
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    CONSTRAINT chk_score CHECK (score BETWEEN 0 AND 10)
);

-- 6. Tạo bảng grade_log (Lịch sử sửa điểm)
CREATE TABLE grade_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id VARCHAR(5),
    old_score DECIMAL(4,2),
    new_score DECIMAL(4,2),
    change_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

-- ---------------------------------------------------------------------
-- CHÈN DỮ LIỆU MẪU KIỂM THỬ (TEST CASES SUITE)
-- ---------------------------------------------------------------------

-- Chèn dữ liệu mẫu cho bảng Sinh viên (students)
INSERT INTO students (student_id, full_name, total_debt) VALUES 
('SV01', 'Le Hoang Nam', 3500000.00), -- Phục vụ cho câu 4 (Đóng học phí)
('SV03', 'Tran Quoc Anh', 0.00),       -- Sinh viên sạch nợ
('SV04', 'Vu Phuong Thao', 1500000.00);

-- Chèn dữ liệu mẫu cho bảng Môn học (subjects)
INSERT INTO subjects (subject_id, subject_name, credits) VALUES 
('SUB01', 'Database Systems', 3),
('SUB02', 'Java Programming', 4),
('SUB03', 'Web Development', 3);

-- Chèn dữ liệu mẫu cho bảng Điểm số (grades)
INSERT INTO grades (student_id, subject_id, score) VALUES 
('SV01', 'SUB01', 3.50),  -- Điểm < 4.0: Phục vụ test Câu 5 (Cho phép sửa điểm vì tạch môn)
('SV01', 'SUB02', 7.50),  -- Điểm >= 4.0: Phục vụ test Câu 5 (Chặn sửa điểm vì đã qua môn)
('SV04', 'SUB01', 5.00);

-- ---------------------------------------------------------------------
-- XÁC MINH DỮ LIỆU SAU KHI KHỞI TẠO
-- ---------------------------------------------------------------------
SELECT 'students' AS Table_Name, COUNT(*) AS Total_Rows FROM students
UNION ALL
SELECT 'subjects', COUNT(*) FROM subjects
UNION ALL
SELECT 'grades', COUNT(*) FROM grades
UNION ALL
SELECT 'grade_log', COUNT(*) FROM grade_log;


-- Câu 1:
DELIMITER //
CREATE TRIGGER tg_check_score
BEFORE INSERT ON grades
FOR EACH ROW
BEGIN
    IF NEW.score < 0 THEN
        SET NEW.score = 0;
    ELSEIF NEW.score > 10 THEN
        SET NEW.score = 10;
    END IF;
END //
DELIMITER ;

INSERT INTO grades (student_id, subject_id, score) VALUES ('SV03', 'SUB01', -5.5); 

-- Câu 2
START TRANSACTION;
-- Thêm sinh viên mới
INSERT INTO students (student_id, full_name) 
VALUES ('SV02', 'Ha Bich Ngoc');
-- Cập nhật nợ học phí
UPDATE students 
SET total_debt = 5000000.00 
WHERE student_id = 'SV02';
COMMIT;


SELECT * FROM students WHERE student_id = 'SV02';

-- Phần B: Khá 
-- Câu 3:
DELIMITER //
CREATE TRIGGER tg_log_grade_update
AFTER UPDATE ON grades
FOR EACH ROW
BEGIN
    -- Chỉ ghi log nếu điểm thực sự có sự thay đổi
    IF OLD.score <> NEW.score THEN
        INSERT INTO grade_log (student_id, old_score, new_score, change_date)
        VALUES (OLD.student_id, OLD.score, NEW.score, NOW());
    END IF;
END //
DELIMITER ;

-- Câu 4:
DELIMITER //
CREATE PROCEDURE sp_pay_tuition()
BEGIN
    DECLARE v_current_debt DECIMAL(10,2);
    START TRANSACTION;
    -- Trừ 2,000,000 nợ học phí của SV01
    UPDATE students 
    SET total_debt = total_debt - 2000000 
    WHERE student_id = 'SV01';
    -- Lấy giá trị nợ học phí sau khi cập nhật để kiểm tra
    SELECT total_debt INTO v_current_debt 
    FROM students 
    WHERE student_id = 'SV01';
    
    IF v_current_debt < 0 THEN
        ROLLBACK;
    ELSE
        COMMIT;
    END IF;
END //
DELIMITER ;

CALL sp_pay_tuition();
SELECT * FROM students WHERE student_id = 'SV01';


-- Câu 5:
DELIMITER //
CREATE TRIGGER tg_prevent_pass_update
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN
    IF OLD.score >= 4.0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Lỗi: Sinh viên đã qua môn (điểm >= 4.0) nên không được phép sửa điểm nữa để đảm bảo minh bạch!';
    END IF;
END //
DELIMITER ;

-- Cập nhật điểm lớn hơn hoặc bằng 4.0 
UPDATE grades SET score = 8.0 WHERE student_id = 'SV01' AND subject_id = 'SUB02';