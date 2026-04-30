CREATE DATABASE LibraryManagement;
USE LibraryManagement;
CREATE TABLE Book (
    MaSach VARCHAR(10) PRIMARY KEY,
    TenSach VARCHAR(255),
    TacGia VARCHAR(100),
    NamXuatBan INT,
    SoLuongHienCo INT
);

CREATE TABLE Reader (
    MaDocGia VARCHAR(10) PRIMARY KEY,
    HoTen VARCHAR(100),
    Email VARCHAR(100),
    SoDienThoai VARCHAR(15),
    NgaySinh DATE
);

CREATE TABLE Borrow_Card (
    MaPhieu VARCHAR(10) PRIMARY KEY,
    MaDocGia VARCHAR(10),
    NgayMuon DATE,
    NgayHenTra DATE,
    FOREIGN KEY (MaDocGia) REFERENCES Reader(MaDocGia)
);

CREATE TABLE Borrow_Detail (
    MaPhieu VARCHAR(10),
    MaSach VARCHAR(10),
    TrangThai VARCHAR(50),
    PhiMuon FLOAT,
    PRIMARY KEY (MaPhieu, MaSach),
    FOREIGN KEY (MaPhieu) REFERENCES Borrow_Card(MaPhieu),
    FOREIGN KEY (MaSach) REFERENCES Book(MaSach)
);

ALTER TABLE Reader ADD DiaChi VARCHAR(255);

ALTER TABLE Book RENAME COLUMN NamXuatBan TO NamPhatHanh;

DROP TABLE Borrow_Detail;
DROP TABLE Borrow_Card;

INSERT INTO Book (MaSach, TenSach, TacGia, NamPhatHanh, SoLuongHienCo) VALUES 
('B1', 'Lap trinh SQL can ban', 'Nguyen Nhat Anh', 2020, 10),
('B2', 'Tieng goi noi hoang da', 'Jack London', 1903, 5),
('B3', 'Cho toi xin mot ve di tuoi tho', 'Nguyen Nhat Anh', 2015, 20),
('B4', 'Mat biec', 'Nguyen Nhat Anh', 2019, 15),
('B5', 'White Fang', 'Jack London', 1906, 8);

INSERT INTO Reader (MaDocGia, HoTen, Email, SoDienThoai, NgaySinh, DiaChi) VALUES 
('R1', 'Phan Hoang Son', 'sonphan@gmail.com', '0901234567', '2007-01-01', 'Ho Chi Minh'),
('R2', 'Nguyen Van A', 'nva@gmail.com', '0900000001', '2000-05-05', 'Ha Noi'),
('R3', 'Tran Thi B', 'ttb@gmail.com', '0900000002', '1998-10-10', 'Da Nang'),
('R4', 'Le Van C', NULL, '0900000003', '2002-12-12', 'Can Tho'),
('R5', 'Pham Minh D', 'pmd@gmail.com', '0900000004', '1995-03-03', 'Hai Phong');

INSERT INTO Borrow_Card (MaPhieu, MaDocGia, NgayMuon, NgayHenTra) VALUES 
('PM001', 'R1', '2026-04-10', '2026-04-20'),
('PM002', 'R3', '2026-04-15', '2026-04-25'),
('PM003', 'R5', '2026-03-01', '2026-03-10'),
('PM004', 'R1', '2026-04-20', '2026-04-30'),
('PM005', 'R2', '2026-02-10', '2026-02-20');

INSERT INTO Borrow_Detail (MaPhieu, MaSach, TrangThai, PhiMuon) VALUES 
('PM001', 'B1', 'Moi', 5000),
('PM001', 'B2', 'Cu', 2000),
('PM002', 'B3', 'Moi', 3000),
('PM004', 'B1', 'Moi', 5000),
('PM005', 'B5', 'Moi', 4000);

UPDATE Book 
SET SoLuongHienCo = SoLuongHienCo + 5 
WHERE TacGia = 'Nguyen Nhat Anh';

DELETE FROM Reader 
WHERE Email IS NULL;

SELECT * FROM Book 
WHERE NamPhatHanh >= 2015 AND NamPhatHanh <= 2023;

SELECT Reader.HoTen, Borrow_Card.MaPhieu
FROM Reader, Borrow_Card
WHERE Reader.MaDocGia = Borrow_Card.MaDocGia
  AND Borrow_Card.NgayMuon >= '2026-04-01' 
  AND Borrow_Card.NgayMuon <= '2026-04-30';

SELECT Book.TenSach
FROM Book, Borrow_Detail
WHERE Book.MaSach = Borrow_Detail.MaSach
  AND Borrow_Detail.MaPhieu = 'PM001';

SELECT DISTINCT Reader.HoTen, Reader.SoDienThoai
FROM Reader, Borrow_Card, Borrow_Detail, Book
WHERE Reader.MaDocGia = Borrow_Card.MaDocGia
  AND Borrow_Card.MaPhieu = Borrow_Detail.MaPhieu
  AND Borrow_Detail.MaSach = Book.MaSach
  AND Book.TenSach = 'Lap trinh SQL can ban';

SELECT Borrow_Detail.MaPhieu, Book.TenSach, Borrow_Detail.TrangThai
FROM Borrow_Detail, Book
WHERE Borrow_Detail.MaSach = Book.MaSach
  AND Book.TacGia = 'Jack London';