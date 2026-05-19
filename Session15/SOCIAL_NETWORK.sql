DROP DATABASE IF EXISTS mini_social_network;

CREATE DATABASE mini_social_network;

USE mini_social_network;

-- 1. taoj bảng
CREATE TABLE users (
    user_id int PRIMARY KEY AUTO_INCREMENT,
    username varchar(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email varchar(100) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
    post_id int PRIMARY KEY AUTO_INCREMENT,
    user_id int NOT NULL,
    content text NOT NULL,
    like_count int DEFAULT 0,
    comment_count int DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_posts_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE RESTRICT,
    FULLTEXT INDEX ft_posts_content (content)
);

CREATE TABLE comments (
    comment_id int PRIMARY KEY AUTO_INCREMENT,
    post_id int NOT NULL,
    user_id int NOT NULL,
    content text NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comments_post FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE,
    CONSTRAINT fk_comments_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE RESTRICT
);

CREATE TABLE likes (
    like_id int PRIMARY KEY AUTO_INCREMENT,
    user_id int NOT NULL,
    post_id int NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_likes_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_likes_post FOREIGN KEY (post_id) REFERENCES posts (post_id) ON DELETE CASCADE,
    CONSTRAINT uq_user_post_like UNIQUE (user_id, post_id)
);

CREATE TABLE friends (
    friendship_id int PRIMARY KEY AUTO_INCREMENT,
    user_id int NOT NULL,
    friend_id int NOT NULL,
    status varchar(20) NOT NULL DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_friends_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_friends_friend FOREIGN KEY (friend_id) REFERENCES users (user_id) ON DELETE RESTRICT,
    CONSTRAINT chk_friend_status CHECK (status IN ('pending', 'accepted')),
    CONSTRAINT chk_not_self_friend CHECK (user_id <> friend_id)
);

-- chawnj keest bạn qua lại: A -> B và B -> A
CREATE UNIQUE INDEX uq_friend_pair ON friends ((LEAST (user_id, friend_id)), (GREATEST (user_id, friend_id)));

CREATE TABLE post_logs (
    log_id int PRIMARY KEY AUTO_INCREMENT,
    post_id int,
    user_id int,
    content text,
    deleted_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. triggers
DELIMITER //
CREATE TRIGGER trg_likes_after_insert
    AFTER INSERT ON likes
    FOR EACH ROW
BEGIN
    UPDATE posts SET like_count = like_count + 1
WHERE
    post_id = NEW.post_id;

END //
CREATE TRIGGER trg_likes_after_delete
    AFTER DELETE ON likes
    FOR EACH ROW
BEGIN
    UPDATE posts SET like_count = GREATEST (like_count - 1, 0)
    WHERE
        post_id = OLD.post_id;

END //
CREATE TRIGGER trg_comments_after_insert
    AFTER INSERT ON comments
    FOR EACH ROW
BEGIN
    UPDATE posts SET comment_count = comment_count + 1
WHERE
    post_id = NEW.post_id;

END //
CREATE TRIGGER trg_comments_after_delete
    AFTER DELETE ON comments
    FOR EACH ROW
BEGIN
    UPDATE posts SET comment_count = GREATEST (comment_count - 1, 0)
    WHERE
        post_id = OLD.post_id;

END //