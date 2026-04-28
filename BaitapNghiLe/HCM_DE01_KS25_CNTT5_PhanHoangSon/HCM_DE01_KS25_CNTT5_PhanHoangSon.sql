DROP DATABASE IF EXISTS SalesManagement;
CREATE DATABASE SalesManagement;
USE SalesManagement;

CREATE TABLE SanPham (
    MaSP VARCHAR(20) PRIMARY KEY,
    TenSP NVARCHAR(100) NOT NULL,
    HangSanXuat NVARCHAR(50),
    DonGia DECIMAL(15, 2) CHECK (DonGia >= 0),
    SoLuongTon INT CHECK (SoLuongTon >= 0)
);

CREATE TABLE KhachHang (
    MaKH VARCHAR(20) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    SoDienThoai VARCHAR(15),
    DiaChi NVARCHAR(255)
);

CREATE TABLE DonHang (
    MaDH VARCHAR(20) PRIMARY KEY,
    NgayDatHang DATETIME DEFAULT CURRENT_TIMESTAMP,
    TongTien DECIMAL(15, 2) DEFAULT 0,
    MaKH VARCHAR(20),
    CONSTRAINT FK_DonHang_KhachHang FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
);


ALTER TABLE DonHang ADD GhiChu TEXT;

ALTER TABLE SanPham 
CHANGE HangSanXuat NhaSanXuat NVARCHAR(50);

DROP TABLE ChiTietDonHang;

DROP TABLE DonHang;

CREATE TABLE ChiTietDonHang (
    MaCTDH INT AUTO_INCREMENT PRIMARY KEY,
    MaDH VARCHAR(20),
    MaSP VARCHAR(20),
    SoLuongMua INT NOT NULL CHECK (SoLuongMua > 0),
    GiaBanThoiDiemDo DECIMAL(15, 2) NOT NULL,
    CONSTRAINT FK_CTDH_DonHang FOREIGN KEY (MaDH) REFERENCES DonHang(MaDH),
    CONSTRAINT FK_CTDH_SanPham FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
);

INSERT INTO SanPham (MaSP, TenSP, HangSanXuat, DonGia, SoLuongTon) VALUES
('SP001', 'MacBook Air M2', 'Apple', 26000000, 15),
('SP002', 'iPhone 15 Pro', 'Apple', 28000000, 20),
('SP003', 'Samsung Galaxy S23', 'Samsung', 18000000, 10),
('SP004', 'Chuột Logitech G502', 'Logitech', 1200000, 50),
('SP005', 'Bàn phím cơ Akko', 'Akko', 1500000, 30);

INSERT INTO KhachHang (MaKH, HoTen, Email, SoDienThoai, DiaChi) VALUES
('KH001', 'Nguyen Van A', 'anguyen@gmail.com', '0901234567', 'TP. Hồ Chí Minh'),
('KH002', 'Tran Thi B', 'btran@gmail.com', '0912345678', 'Hà Nội'),
('KH003', 'Le Van C', 'cle@gmail.com', NULL, 'Đà Nẵng'), 
('KH004', 'Pham Minh D', 'dpham@gmail.com', '0933445566', 'Cần Thơ'),
('KH005', 'Hoang Thi E', 'ehoang@gmail.com', '0944556677', 'Hải Phòng');

INSERT INTO DonHang (MaDH, NgayDatHang, TongTien, MaKH) VALUES
('DH001', '2024-03-01 10:00:00', 27200000, 'KH001'),
('DH002', '2024-03-02 11:30:00', 28000000, 'KH002'),
('DH003', '2024-03-03 14:00:00', 18000000, 'KH003'),
('DH004', '2024-03-04 16:20:00', 1200000, 'KH004'),
('DH005', '2024-03-05 09:15:00', 1500000, 'KH005');

INSERT INTO ChiTietDonHang (MaDH, MaSP, SoLuongMua, GiaBanThoiDiemDo) VALUES
('DH001', 'SP001', 1, 26000000), 
('DH001', 'SP004', 1, 1200000),  
('DH002', 'SP002', 1, 28000000),
('DH003', 'SP003', 1, 18000000),
('DH004', 'SP004', 1, 1200000),
('DH005', 'SP005', 1, 1500000);

UPDATE SanPham SET DonGia = DonGia * 1.1 WHERE HangSanXuat = 'Apple';

DELETE FROM KhachHang WHERE SoDienThoai IS NULL;

SELECT * FROM SanPham WHERE DonGia >= 10000000 AND DonGia <= 20000000;

