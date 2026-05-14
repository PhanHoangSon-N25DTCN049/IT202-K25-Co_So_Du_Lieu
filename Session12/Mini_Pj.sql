-- 1. KHỞI TẠO CẤU TRÚC BẢNG (TABLES) & RÀNG BUỘC (CONSTRAINTS)
-- Triển khai REQ-07 (Cascade Delete) và REQ-08 (Security)

CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL, -- Lưu mật khẩu đã băm (REQ-08)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- REQ-07: Xóa user thì tự động xóa bài viết liên quan
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- REQ-06: Tối ưu hóa truy vấn Newsfeed dựa trên thời gian
CREATE INDEX idx_post_created_at ON Posts(created_at);

CREATE TABLE Comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    user_id INT,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

CREATE TABLE Likes (
    user_id INT,
    post_id INT,
    PRIMARY KEY (user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id) ON DELETE CASCADE
);

CREATE TABLE Friends (
    user_id_1 INT,
    user_id_2 INT,
    status ENUM('pending', 'accepted') DEFAULT 'pending',
    PRIMARY KEY (user_id_1, user_id_2),
    FOREIGN KEY (user_id_1) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id_2) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 2. CÁC KHUNG NHÌN TRUY XUẤT (VIEWS)
-- Triển khai REQ-01 (Profile) và REQ-02 (Statistics)

-- REQ-01: Hiển thị thông tin người dùng (Bảo mật: ẩn password)
CREATE VIEW vw_UserInfo AS
SELECT user_id, username, email, created_at
FROM Users;

-- REQ-02: Thống kê tương tác bài viết
CREATE VIEW vw_PostStatistics AS
SELECT 
    p.post_id, 
    p.content, 
    u.username AS author,
    COUNT(DISTINCT l.user_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments
FROM Posts p
JOIN Users u ON p.user_id = u.user_id
LEFT JOIN Likes l ON p.post_id = l.post_id
LEFT JOIN Comments c ON p.post_id = c.post_id
GROUP BY p.post_id;

-- 3. CÁC THỦ TỤC XỬ LÝ NGHIỆP VỤ (STORED PROCEDURES)
-- Triển khai REQ-03, REQ-04 và REQ-05

DELIMITER //

-- REQ-03: Đăng ký người dùng mới (Kiểm tra trùng email)
CREATE PROCEDURE sp_RegisterUser(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255),
    IN p_email VARCHAR(100)
)
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email đã được sử dụng';
    ELSE
        INSERT INTO Users (username, password_hash, email)
        VALUES (p_username, p_password, p_email);
    END IF;
END //

-- REQ-04: Đăng bài viết mới (Trả về post_id vừa tạo)
CREATE PROCEDURE sp_CreatePost(
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    INSERT INTO Posts (user_id, content)
    VALUES (p_user_id, p_content);
    
    SELECT LAST_INSERT_ID() AS post_id;
END //

-- REQ-05: Lấy danh sách bạn bè có phân trang
CREATE PROCEDURE sp_GetFriendsList(
    IN p_user_id INT,
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    SELECT u.username, u.email
    FROM Friends f
    JOIN Users u ON (f.user_id_1 = u.user_id OR f.user_id_2 = u.user_id)
    WHERE (f.user_id_1 = p_user_id OR f.user_id_2 = p_user_id)
      AND f.status = 'accepted'
      AND u.user_id != p_user_id -- Không lấy chính mình
    LIMIT p_limit OFFSET p_offset;
END //

DELIMITER ;