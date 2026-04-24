CREATE DATABASE OnlineLearningSystem;
USE OnlineLearningSystem;

CREATE TABLE Teacher (
    MaGV INT PRIMARY KEY,
    HoTen NVARCHAR(50),
    Email VARCHAR(50)
);

-- Tạo bảng Khóa học
CREATE TABLE Course (
    MaKH INT PRIMARY KEY,
    TenKH NVARCHAR(50),
    MaGV INT 
);

-- Tạo bảng Sinh viên
CREATE TABLE Student (
    MaSV INT PRIMARY KEY,
    HoTen NVARCHAR(50),
    Email VARCHAR(50)
);

-- Tạo bảng Đăng ký 
CREATE TABLE Enrollment (
    MaSV INT,
    MaKH INT,
    Diem FLOAT
);

-- Thêm thầy cô
INSERT INTO Teacher (MaGV, HoTen, Email) VALUES 
(1, N'Nguyễn Văn An', 'an.nv@school.edu.vn'),
(2, N'Trần Thị Bình', 'binh.tt@school.edu.vn'),
(3, N'Lê Hoàng Cường', 'cuong.lh@school.edu.vn'),
(4, N'Phạm Mỹ Dung', 'dung.pm@school.edu.vn'),
(5, N'Đỗ Minh Đức', 'duc.dm@school.edu.vn');

-- Thêm môn học
INSERT INTO Course (MaKH, TenKH, MaGV) VALUES 
(101, N'Cơ sở dữ liệu SQL', 1),
(102, N'Lập trình Python', 2),
(103, N'Thiết kế Web cơ bản', 3),
(104, N'C#', 4),
(105, N'An toàn thông tin', 5);

-- Thêm sinh viên
INSERT INTO Student (MaSV, HoTen, Email) VALUES 
(2021, N'Trần Bảo Nam', 'nam.tb@student.com'),
(2022, N'Nguyễn Linh Chi', 'chi.nl@student.com'),
(2023, N'Lê Minh Khôi', 'khoi.lm@student.com'),
(2024, N'Phạm Thu Hà', 'ha.pt@student.com'),
(2025, N'Vũ Hoàng Long', 'long.vh@student.com');

-- Cho sinh viên đăng ký môn học và nhập điểm
INSERT INTO Enrollment (MaSV, MaKH, Diem) VALUES 
(2021, 101, 8.5), 
(2022, 102, 9.0), 
(2023, 103, 7.5),
(2024, 104, 10.0), 
(2025, 105, 6.0);


--  Cập nhật email cho sinh viên
UPDATE Student SET Email = 'nam.new@gmail.com' WHERE MaSV = 2021;

--  Cập nhật mô tả cho một khóa học 
UPDATE Course SET TenKH = N'SQL Server Nâng Cao' WHERE MaKH = 101;

--  Cập nhật điểm cuối kỳ cho sinh viên 
UPDATE Enrollment SET Diem = 9.5 WHERE MaSV = 2022 AND MaKH = 102;

--  Xóa một lượt đăng ký học không hợp lệ 
DELETE FROM Enrollment WHERE MaSV = 2025 AND MaKH = 105;

SELECT Student.HoTen, Course.TenKH, Enrollment.Diem
FROM Student, Course, Enrollment
WHERE Student.MaSV = Enrollment.MaSV 
  AND Course.MaKH = Enrollment.MaKH;
  
  -- 1. Lấy danh sách tất cả sinh viên
SELECT * FROM Student;

-- 2. Lấy danh sách giảng viên
SELECT * FROM Teacher;

-- 3. Lấy danh sách các khóa học
SELECT * FROM Course;

-- 4. Lấy thông tin các lượt đăng ký học
SELECT Student.HoTen, Course.TenKH 
FROM Student, Course, Enrollment 
WHERE Student.MaSV = Enrollment.MaSV AND Course.MaKH = Enrollment.MaKH;

-- 5. Lấy thông tin các lần đánh giá kết quả
SELECT Student.HoTen, Course.TenKH, Enrollment.Diem 
FROM Student, Course, Enrollment 
WHERE Student.MaSV = Enrollment.MaSV AND Course.MaKH = Enrollment.MaKH;