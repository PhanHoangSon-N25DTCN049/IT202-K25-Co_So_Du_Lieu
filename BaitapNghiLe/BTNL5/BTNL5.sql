CREATE TABLE movies (
    id INT PRIMARY KEY,
    title VARCHAR(255),
    duration_minutes INT,
    age_restriction INT DEFAULT 0
);

CREATE TABLE rooms (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    max_seats INT,
    status VARCHAR(20) DEFAULT 'active'
);

CREATE TABLE showtimes (
    id INT PRIMARY KEY,
    movie_id INT,
    room_id INT,
    show_time DATETIME,
    ticket_price DECIMAL(10, 2),
    FOREIGN KEY (movie_id) REFERENCES movies(id),
    FOREIGN KEY (room_id) REFERENCES rooms(id)
);

CREATE TABLE bookings (
    id INT PRIMARY KEY,
    showtime_id INT,
    customer_name VARCHAR(255),
    phone VARCHAR(20),
    booking_date DATETIME,
    FOREIGN KEY (showtime_id) REFERENCES showtimes(id)
);


INSERT INTO movies (id, title, duration_minutes, age_restriction) VALUES
(1, 'Avengers: Endgame', 181, 13),
(2, 'Oppenheimer', 180, 18), -- Phim giới hạn 18+
(3, 'Doraemon: Nobita và Bản giao hưởng Địa Cầu', 115, 0),
(4, 'Lật Mặt 7: Một Điều Ước', 138, 13);


INSERT INTO rooms (id, name, max_seats, status) VALUES
(1, 'Cinema 01 - IMAX', 200, 'active'),
(2, 'Cinema 02 - Standard', 120, 'active'),
(3, 'Cinema 03 - Gold Class', 50, 'maintenance'); -- Phòng đang bảo trì

INSERT INTO showtimes (id, movie_id, room_id, show_time, ticket_price) VALUES
(1, 1, 1, '2026-05-10 18:00:00', 150000),
(2, 2, 1, '2026-05-10 21:30:00', 180000),
(3, 3, 2, '2026-05-11 09:00:00', 90000),
(4, 4, 2, '2026-05-11 14:00:00', 110000),
(5, 2, 2, '2026-05-11 19:00:00', 120000);

INSERT INTO bookings (id, showtime_id, customer_name, phone, booking_date) VALUES
(1, 1, 'Nguyen Van A', '0901234567', '2026-05-01 10:00:00'),
(2, 1, 'Le Thi B', '0912345678', '2026-05-01 11:30:00'),
(3, 2, 'Tran Van C', '0923456789', '2026-05-02 08:15:00'),
(4, 2, 'Pham Thi D', '0934567890', '2026-05-02 09:45:00'),
(5, 3, 'Hoang Van E', '0945678901', '2026-05-02 14:20:00'),
(6, 4, 'Dang Thi F', '0956789012', '2026-05-03 10:10:00'),
(7, 4, 'Bui Van G', '0967890123', '2026-05-03 15:50:00'),
(8, 5, 'Ly Thi H', '0978901234', '2026-05-04 12:00:00'),
(9, 5, 'Ngo Van I', '0989012345', '2026-05-04 13:30:00'),
(10, 5, 'Do Thi K', '0990123456', '2026-05-04 14:00:00');