CREATE DATABASE Hotel_VIP;
USE Hotel_VIP;


CREATE TABLE Users (
	UsersID INT PRIMARY KEY AUTO_INCREMENT,
    UsersName VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    total_price DECIMAL(12,0) CHECK  (total_price>0) 
);

create table Hotels (
	HotelID INT PRIMARY KEY AUTO_INCREMENT,
    NameHotel VARCHAR(100),
	Star_rating enum ('1 sao', '2 sao', '3 sao', '4 sao', '5 sao'),
    Address VARCHAR(100)
);

CREATE TABLE Bookings (
	BookingID INT PRIMARY KEY AUTO_INCREMENT,
	UsersID INT,
    HotelID INT,
    Revenue DECIMAL(12,0) CHECK (Revenue > 0),
    status ENUM ('COMPLETED', 'CANCEL', 'WAITING'),
    FOREIGN KEY (UsersID) REFERENCES Users(UsersID) ON DELETE CASCADE,
    FOREIGN KEY (HotelID) REFERENCES Hotels(HotelID) ON DELETE CASCADE
);

INSERT INTO Users (UsersName, Email, Phone, total_price) VALUES
('Nguyen Van A', 'a@gmail.com', '0901234567', 5000000),
('Tran Thi B', 'b@gmail.com', '0912345678', 7000000),
('Le Van C', 'c@gmail.com', '0923456789', 3000000),
('Pham Thi D', 'd@gmail.com', '0934567890', 9000000),
('Hoang Van E', 'e@gmail.com', '0945678901', 6000000);

INSERT INTO Hotels (NameHotel, Star_rating, Address) VALUES
('Sunshine Hotel', '3 sao', 'Ha Noi'),
('Ocean View', '5 sao', 'Da Nang'),
('Mountain Inn', '2 sao', 'Sapa'),
('City Lights', '4 sao', 'Ho Chi Minh'),
('Green Leaf', '3 sao', 'Da Lat');

INSERT INTO Bookings (UsersID, HotelID, Revenue, status) VALUES
(1, 1, 2000000, 'COMPLETED'),
(2, 2, 3000000, 'WAITING'),
(3, 3, 1500000, 'CANCEL'),
(4, 4, 4000000, 'COMPLETED'),
(5, 5, 2500000, 'WAITING');


SELECT 
    u.UsersName AS Customer_Name,
    h.Star_rating AS Hotel_Class,
    SUM(b.Revenue) AS Total_Spending
FROM Users u
INNER JOIN Bookings b ON u.UsersID = b.UsersID
INNER JOIN Hotels h ON b.HotelID = h.HotelID 
WHERE 
    b.status = 'COMPLETED'  
    AND b.Revenue > 0               
GROUP BY 
    u.UsersID,                    
    u.UsersName, 
    h.Star_rating                  
HAVING 
    SUM(b.Revenue) > 50000000       
ORDER BY 
    h.Star_rating DESC,            
    Total_Spending DESC;
    
    
-- Quy trình chống bẫy: 
-- Có những đơn hàng được hoàn tiền 1 phần nên total_price bị lưu là số âm (-2.000.000). Bạn xử lý dữ liệu rác này ở WHERE hay HAVING để tối ưu?
-- Xử lý ở WHERE để tối ưu nhất, vì HAVING là sau khi GROUP BY chạy đẫn đến các nhóm dữ liệu đã được gom nhóm khó trong việc xử lý

