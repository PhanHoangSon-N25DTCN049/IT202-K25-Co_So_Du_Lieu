CREATE TABLE Patients (
    Patient_ID INT PRIMARY KEY,
    Full_Name VARCHAR(100),
    Age INT,
    Room_Number INT,
    HIV_Status VARCHAR(50),
    Mental_Health_History VARCHAR(255)
);

INSERT INTO Patients (Patient_ID, Full_Name, Age, Room_Number, HIV_Status, Mental_Health_History)
VALUES
(1, 'Minh Thu', 30, 101, 'Negative', 'None'),
(2, 'Hong Van', 40, 102, 'Positive', 'Anxiety'),
(3, 'Cao Cuong', 25, 103, 'Negative', 'None');

CREATE VIEW Reception_Patient_View AS
SELECT 
    Patient_ID, 
    Full_Name, 
    Age, 
    Room_Number
FROM Patients
WHERE Age >= 0
WITH CHECK OPTION;

-- Kết quả trả về sẽ chỉ gồm 4 cột cơ bản, không có HIV_Status hay Mental_Health_History
SELECT * FROM Reception_Patient_View;

-- Câu lệnh này sẽ thực thi thành công
UPDATE Reception_Patient_View 
SET Age = 35 
WHERE Patient_ID = 1;

-- Câu lệnh này sẽ báo lỗi (CHECK OPTION failed) và bị chặn lại
UPDATE Reception_Patient_View 
SET Age = -5 
WHERE Patient_ID = 2;