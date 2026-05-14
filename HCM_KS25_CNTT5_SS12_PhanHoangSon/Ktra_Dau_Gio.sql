CREATE DATABASE StudentDB;
USE StudentDB;

-- 1. Bảng Khoa
CREATE TABLE Department (
    DeptID VARCHAR(5) PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL
);

-- 2. Bảng SinhVien
CREATE TABLE Student (
    StudentID VARCHAR(6) PRIMARY KEY,
    FullName VARCHAR(50),
    Gender VARCHAR(10),
    BirthDate DATE,
    DeptID VARCHAR(5),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

-- 3. Bảng MonHoc
CREATE TABLE Course (
    CourseID VARCHAR(6) PRIMARY KEY,
    CourseName VARCHAR(50),
    Credits INT
);

-- 4. Bảng DangKy
CREATE TABLE Enrollment (
    StudentID VARCHAR(6),
    CourseID VARCHAR(6),
    Score DECIMAL(4,2), 
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

-- Chèn dữ liệu mẫu
INSERT INTO Department VALUES
('IT','Information Technology'),
('BA','Business Administration'),
('ACC','Accounting');

INSERT INTO Student VALUES
('S00001','Nguyen An','Male','2003-05-10','IT'),
('S00002','Tran Binh','Male','2003-06-15','IT'),
('S00003','Le Hoa','Female','2003-08-20','BA'),
('S00004','Pham Minh','Male','2002-12-12','ACC'),
('S00005','Vo Lan','Female','2003-03-01','IT'),
('S00006','Do Hung','Male','2002-11-11','BA'),
('S00007','Nguyen Mai','Female','2003-07-07','ACC'),
('S00008','Tran Phuc','Male','2003-09-09','IT');

INSERT INTO Course (CourseID, CourseName, Credits) VALUES 
('CS101', 'C Programming', 3), 
('CS102', 'Database Management', 4),
 ('BA201', 'Principles of Marketing', 3), 
('ACC301', 'Financial Accounting', 3),
 ('CS103', 'Java Programming', 4); 

INSERT INTO Enrollment (StudentID, CourseID, Score) VALUES
-- Sinh viên IT học lập trình và cơ sở dữ liệu
('S00001', 'CS101', 8.5),
('S00001', 'CS102', 7.0),
('S00002', 'CS101', 9.0),
('S00002', 'CS103', 8.0),
('S00005', 'CS102', 6.5),
('S00008', 'CS101', 7.5),

-- Sinh viên BA học Marketing
('S00003', 'BA201', 8.0),
('S00006', 'BA201', 7.5),

-- Sinh viên ACC học Kế toán
('S00004', 'ACC301', 9.5),
('S00007', 'ACC301', 8.0);


-- Tạo View
CREATE VIEW ViewStudentBasic AS
SELECT s.StudentID, s.FullName, d.DeptName
FROM Student s
JOIN Department d ON s.DeptID = d.DeptID;

-- Truy vấn dữ liệu từ View
SELECT * FROM ViewStudentBasic;

-- Tạo index
CREATE INDEX idxFullName ON Student(FullName);

-- Viết Stored Procedure GetStudentsIT
DELIMITER //

CREATE PROCEDURE GetStudentsIT()
BEGIN
    SELECT s.*, d.DeptName
    FROM Student s
    JOIN Department d ON s.DeptID = d.DeptID
    WHERE d.DeptName = 'Information Technology';
-- 2. Kết thúc procedure bằng //
END //

DELIMITER ;

-- Gọi Procedure để kiểm tra
CALL GetStudentsIT();

-- Câu 4
CREATE VIEW ViewStudentCountByDept AS
SELECT d.DeptName, COUNT(s.StudentID) AS TotalStudents
FROM Department d
LEFT JOIN Student s ON d.DeptID = s.DeptID
GROUP BY d.DeptID, d.DeptName;

-- Kiểm tra view
SELECT * FROM ViewStudentCountByDept;

-- Truy vấn hiển thị khoa có nhiều sinh viên nhất
SELECT * FROM ViewStudentCountByDept
WHERE TotalStudents = (SELECT MAX(TotalStudents) FROM ViewStudentCountByDept);


-- Câu 5
DELIMITER //
CREATE PROCEDURE GetTopScoreStudent(IN varCourseID VARCHAR(6))
BEGIN
    SELECT s.StudentID, s.FullName, e.Score, c.CourseName
    FROM Student s
    JOIN Enrollment e ON s.StudentID = e.StudentID
    JOIN Course c ON e.CourseID = c.CourseID
    WHERE e.CourseID = varCourseID
    AND e.Score = (SELECT MAX(Score) 
					FROM Enrollment 
					WHERE CourseID = varCourseID);
END //
DELIMITER ;

-- gọi 
CALL GetTopScoreStudent('CS102');


-- Câu 6
CREATE OR REPLACE VIEW ViewITEnrollmentDB AS
SELECT e.StudentID, e.CourseID, e.Score
FROM Enrollment e
JOIN Student s ON e.StudentID = s.StudentID
WHERE s.DeptID = 'IT' AND e.CourseID = 'CS101'
WITH CHECK OPTION;

DELIMITER //
CREATE PROCEDURE UpdateScoreITDB(
    IN varStudentID VARCHAR(6), 
    INOUT inoutNewScore DECIMAL(4,2)
)
BEGIN
    IF inoutNewScore > 10 THEN
        SET inoutNewScore = 10;
    END IF;
    
    UPDATE ViewITEnrollmentDB
    SET Score = inoutNewScore
    WHERE StudentID = varStudentID;
END //
DELIMITER ;


SET @testScore = 11.0;


CALL UpdateScoreITDB('S00001', @testScore);

SELECT @testScore AS UpdatedScore_In_Variable;

SELECT * FROM ViewITEnrollmentDB WHERE StudentID = 'S00001';
