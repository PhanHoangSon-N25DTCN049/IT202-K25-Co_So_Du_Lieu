CREATE DATABASE khachhang;

USE orders; 

CREATE TABLE KhachHang (
    ID_KhachHang INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL
);

CREATE TABLE ORDERS (
    ID_Orders INT PRIMARY KEY,
    date_orders DATETIME DEFAULT CURRENT_TIMESTAMP,
    totalPrice DECIMAL(18,4) NOT NULL,
    ID_Khachhang INT,
    FOREIGN KEY (ID_KhachHang) REFERENCES KhachHang (ID_KhachHang)
);
