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