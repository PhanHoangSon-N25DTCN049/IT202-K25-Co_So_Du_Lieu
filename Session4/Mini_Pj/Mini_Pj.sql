
CREATE DATABASE IF NOT EXISTS OnlineLearningSystem;
USE OnlineLearningSystem;

-- 2. Bảng Giảng viên (Instructor) - Tạo trước để Course có thể tham chiếu
CREATE TABLE Instructor (
    instructor_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- 3. Bảng Sinh viên (Student)
CREATE TABLE Student (
    student_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    birthday DATE,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- 4. Bảng Khóa học (Course)
CREATE TABLE Course (
    course_id VARCHAR(20) PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    description TEXT,
    duration INT NOT NULL, -- Số buổi học
    instructor_id VARCHAR(20),
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
);

-- 5. Bảng Đăng ký học (Enrollment)
CREATE TABLE Enrollment (
    student_id VARCHAR(20),
    course_id VARCHAR(20),
    enrollment_date DATE,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

-- 6. Bảng Kết quả học tập (Score)
CREATE TABLE Result (
    student_id VARCHAR(20),
    course_id VARCHAR(20),
    midterm_score DECIMAL(4,2) CHECK (midterm_score BETWEEN 0 AND 10),
    final_score DECIMAL(4,2) CHECK (final_score BETWEEN 0 AND 10),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);



-- Thêm Giảng viên
INSERT INTO Instructor VALUES 
('T001', 'Nguyen Khac Hung', 'hungnk@rikkeiedu.vn'),
('T002', 'Le Van Tam', 'tamlv@rikkeiedu.vn'),
('T003', 'Phan Anh Tuan', 'tuanpa@rikkeiedu.vn'),
('T004', 'Hoang Thi Hoa', 'hoaht@rikkeiedu.vn'),
('T005', 'Tran Duc Linh', 'linhtd@rikkeiedu.vn');

-- Thêm Sinh viên
INSERT INTO Student VALUES 
('S001', 'Tran Van An', '2004-05-15', 'antv@gmail.com'),
('S002', 'Le Thi Binh', '2005-08-20', 'binhlt@gmail.com'),
('S003', 'Hoang Duc Canh', '2003-12-10', 'canhhd@gmail.com'),
('S004', 'Pham Minh Dung', '2004-02-28', 'dungpm@gmail.com'),
('S005', 'Do Kim Yen', '2005-11-03', 'yendk@gmail.com');

-- Thêm Khóa học
INSERT INTO Course VALUES 
('C001', 'Java Basic', 'Lap trinh Java co ban', 12, 'T001'),
('C002', 'SQL Server', 'Quan tri CSDL SQL', 10, 'T002'),
('C003', 'ReactJS', 'Xay dung giao dien voi React', 15, 'T003'),
('C004', 'Python Fundamentals', 'Ngon ngu Python cho moi nguoi', 8, 'T004'),
('C005', 'Data Structure', 'Cau truc du lieu va giai thuat', 20, 'T005');

-- Thêm Đăng ký học
INSERT INTO Enrollment (student_id, course_id) VALUES 
('S001', 'C001'), ('S001', 'C002'),
('S002', 'C001'), ('S003', 'C003'),
('S004', 'C004'), ('S005', 'C005');

-- Thêm Kết quả học tập
INSERT INTO Result VALUES 
('S001', 'C001', 8.5, 9.0),
('S002', 'C001', 7.0, 8.0),
('S003', 'C003', 9.0, 8.5),
('S004', 'C004', 6.5, 7.5),
('S005', 'C005', 10.0, 9.5);



-- 1. Cập nhật email cho một sinh viên
UPDATE Student SET email = 'an_new_2026@gmail.com' WHERE student_id = 'S001';

-- 2. Cập nhật mô tả cho một khóa học
UPDATE Course SET description = 'Hoc SQL tu co ban den nang cao 2026' WHERE course_id = 'C002';

-- 3. Cập nhật điểm cuối kỳ cho một sinh viên
UPDATE Result SET final_score = 10.0 WHERE student_id = 'S001' AND course_id = 'C001';



-- Xóa lượt đăng ký học không hợp lệ (Ví dụ: S001 hủy khóa C002)
-- Lưu ý: Nếu có dữ liệu trong bảng Result liên quan, cần xóa ở Result trước
DELETE FROM Result WHERE student_id = 'S001' AND course_id = 'C002';
DELETE FROM Enrollment WHERE student_id = 'S001' AND course_id = 'C002';



-- 1. Lấy danh sách tất cả sinh viên
SELECT * FROM Student;

-- 2. Lấy danh sách giảng viên
SELECT * FROM Instructor;

-- 3. Lấy danh sách các khóa học
SELECT * FROM Course;


SELECT 
    Student.full_name AS 'Tên Sinh Viên', 
    Course.course_name AS 'Tên Khóa Học', 
    Enrollment.enrollment_date AS 'Ngày Đăng Ký'
FROM Student, Course, Enrollment
WHERE Student.student_id = Enrollment.student_id 
  AND Course.course_id = Enrollment.course_id;