CREATE DATABASE contract_management_db;
USE contract_management_db;

CREATE TABLE Customers (
customer_id VARCHAR(10) PRIMARY KEY,
full_name VARCHAR(50) NOT NULl,
phone_number VARCHAR(15) NOT NULL UNIQUE,
email VARCHAR(255) NOT NULL,
join_date DATE DEFAULT (CURRENT_DATE) NOT NULL
);

CREATE TABLE insurance_packages (
package_id VARCHAR(10) PRIMARY KEY,
package_name VARCHAR(50) NOT NULL,
max_limit DECIMAL(18,0) NOT NULL CHECK (max_limit > 0),
base_premium DECIMAL(18,0) NOT NULL CHECK (base_premium > 0)
);

CREATE TABLE policies (
policy_id VARCHAR(10) PRIMARY KEY,
customer_id VARCHAR(10) NOT NULL,
package_id VARCHAR(10) NOT NULL,
start_date DATE NOT NULL,
end_date DATE NOT NULL,
status VARCHAR(10) NOT NULL CHECK(status IN ('Active', 'Expired', 'Cancelled')),

FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON UPDATE CASCADE,
FOREIGN KEY (package_id) REFERENCES insurance_packages(package_id) ON DELETE NO ACTION
);

CREATE TABLE Claims (
claim_id VARCHAR(10) PRIMARY KEY,
policy_id VARCHAR(10) NOT NULL,
claim_date DATE NOT NULL DEFAULT (CURRENT_DATE),
claim_amount DECIMAL(18,0) CHECK (claim_amount > 0) NOT NULL,
status VARCHAR(10) NOT NULL CHECK (status IN ('Pending', 'Approved', 'Rejected')) DEFAULT 'Pending',

FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
);

CREATE TABLE Claim_Processing_Log (
log_id VARCHAR(10) PRIMARY KEY,
claim_id VARCHAR(10) NOT NULl,
action_detail TEXT NOT NULL,
recorded_at TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP),
processor VARCHAR(50) NOT NULL,

FOREIGN KEY (claim_id) REFERENCES Claims(claim_id)
);

INSERT INTO Customers(customer_id, full_name, phone_number, email, join_date)
VALUES
	('C001','Nguyen Hoang Long', '0901112223', 'long.nh@gmail.com', '2024-01-15'),
    ('C002','Tran Thi Kim Anh', '0988877766', 'anh.tk@gmail.com', '2024-03-10'),
    ('C003','Le Hoang Nam', '0903334445', 'nam.lh@gmail.com', '2025-05-20'),
    ('C004','Pham Minh Duc', '0355556667', 'duc.pm@gmail.com', '2025-08-12'),
    ('C005','Hoang Thu Thao', '0779998881', 'thao.ht@gmail.com', '2026-01-01');
    
INSERT INTO insurance_packages(package_id, package_name, max_limit, base_premium)
VALUES
	('PKG01','Bảo Hiểm Sức Khỏe Gold', 500000000, 5000000),
    ('PKG02','Bảo Hiểm Ô tô Liberty', 1000000000, 15000000),
    ('PKG03','Bảo hiểm nhân thọ An Bình', 2000000000, 25000000),
    ('PKG04','Bảo hiểm Du lịch Quốc tế', 100000000, 1000000),
    ('PKG05','Bảo hiểm Tai nạn 24/7', 200000000, 2500000);
    
INSERT INTO policies(policy_id, customer_id, package_id, start_date, end_date, status)
VALUES
	('POL101','C001', 'PKG01', '2024-01-15','2025-01-15', 'Expired' ),
    ('POL102','C002', 'PKG02', '2024-03-10', '2026-03-10', 'Active'),
    ('POL103','C003', 'PKG03', '2025-05-20', '2035-05-20', 'Active'),
    ('POL104','C004', 'PKG04', '2025-08-12', '2025-09-12', 'Expired'),
    ('POL105','C005', 'PKG01', '2026-01-01', '2027-01-01', 'Active');
    
INSERT INTO Claims(claim_id,policy_id, claim_date, claim_amount, status)
VALUES
	('CLM901','POL102', '2024-06-15',12000000, 'Approved'),
    ('CLM902','POL103', '2025-10-20', 50000000, 'Pending'),
    ('CLM903','POL101', '2024-11-05', 5500000, 'Approved'),
    ('CLM904','POL105', '2026-01-15', 2000000, 'Rejected'),
    ('CLM905','POL102', '2025-02-10', 120000000, 'Approved');
    

INSERT INTO Claim_Processing_Log(log_id, claim_id, action_detail, recorded_at, processor)
VALUES
	('L001','CLM901', 'Đã nhận hồ sơ hiện trường','2024-06-15 09:00', 'Admin_01'),
    ('L002','CLM901', 'Chấp nhận bồi thường xe tai nạn', '2024-06-20 14:30', 'Admin_01'),
    ('L003','CLM902', 'Đang thẩm định hồ sơ bệnh án', '2025-10-21 10:00', 'Admin_02'),
    ('L004','CLM904', 'Từ chối do lỗi cố ý của khách hàng', '2026-01-16 16:00', 'Admin_03'),
    ('L005','CLM905', 'Đã thanh toán qua chuyển khoản', '2025-02-15 08:30', 'Accountant_01');
    
    
-- 1.3 	Cập nhật và xóa
-- Câu 1:
SET SQL_SAFE_UPDATES = 0;
UPDATE insurance_packages 
SET base_premium = base_premium * 1.15
WHERE max_limit > 500000000;
SET SQL_SAFE_UPDATES = 1;

-- Câu 2:
SET SQL_SAFE_UPDATES = 0;
DELETE FROM Claim_Processing_Log 
WHERE recorded_at < '2025-06-20';
SET SQL_SAFE_UPDATES = 1;

-- Truy vấn
-- Câu 1:
SELECT * FROM policies
WHERE status = 'Active' AND end_date < '2027-01-01';

-- Câu 2
SELECT full_name, email
FROM Customers c
JOIN policies p ON (c.customer_id = p.customer_id)
WHERE c.full_name LIKE '%Hoang%' AND p.start_date >= '2025-01-01';

-- Câu 3:
SELECT * FROM Claims
ORDER BY claim_amount DESC
LIMIT 5 OFFSET 1;

-- Cú pháp JOIN
-- Câu 1:
 SELECT c.full_name, i.package_name, p.start_date, cl.claim_amount
 FROM  policies p
 LEFT JOIN insurance_packages i ON (i.package_id = p.package_id)
 LEFT JOIN Customers c ON (c.customer_id = p.customer_id)
 LEFT JOIN Claims cl ON (cl.policy_id = p.policy_id);
 
 -- Câu 2:
 SELECT c.full_name, SUM(cl.claim_amount) AS total_payment
 FROM Claims cl
 JOIN policies p ON (cl.policy_id = p.policy_id)
 JOIN Customers c ON (c.customer_id = p.customer_id)
 WHERE cl.status = 'Approved'
 GROUP BY c.full_name
 HAVING SUM(cl.claim_amount) > 50000000;
 
 -- Câu 3:
SELECT i.package_name, COUNT(p.policy_id)
FROM policies p 
JOIN insurance_packages i ON (i.package_id = p.package_id)
GROUP BY i.package_name
ORDER BY COUNT(p.policy_id) DESC
LIMIT 1;

-- View và INDEX
-- Câu 1:
CREATE INDEX idx_policy_status_date ON policies(status, start_date);

-- Câu 2:
CREATE VIEW vw_customer_summary AS
SELECT c.full_name, COUNT(p.customer_id) AS total_contracts, SUM(i.base_premium) AS total_recurring_fees
FROM Customers c
JOIN policies p ON (c.customer_id = p.customer_id)
JOIN insurance_packages i ON (i.package_id = p.package_id)
GROUP BY c.full_name;

SELECT * FROM vw_customer_summary;

-- Trigger
-- Câu 1:
DELIMITER //
CREATE TRIGGER trg_after_claim_approved
AFTER INSERT ON Claims
FOR EACH ROW
BEGIN
	DECLARE count_log INT;
	IF NEW.status = Approved THEN 
		SELECT COUNT(log_id) INTO count_log FROM Claim_Processing_Log;
		INSERT INTO Claim_Processing_Log(log_id, claim_id, action_detail, processor) 
        VALUES
			(CONCAT('L00',count_log + 1), NEW.claim_id, 'Payment processed to customer', 'Admin');
	END IF;
END //
DELIMITER ;

-- Câu 2:
DELIMITER //
CREATE TRIGGER Block_active_editing 
BEFORE DELETE ON policies
FOR EACH ROW
BEGIN
    IF OLD.status = 'active' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không thể xóa hợp đồng nếu trạng thái là active';
	END IF;
END //
DELIMITER ;


-- procedure
-- Câu 1:
DELIMITER //
CREATE PROCEDURE sp_check_claim_limit (
	IN p_claim_id VARCHAR(10),
	OUT message VARCHAR(10))
BEGIN
	DECLARE p_claim_amount DECIMAL(18,0);
    DECLARE p_max_limit DECIMAL(18,0);
    
    SELECT claim_amount INTO p_claim_amount 
    FROM Claims WHERE claim_id = p_claim_id;
    
    SELECT i.max_limit INTO p_max_limit 
    FROM policies p 
    JOIN insurance_packages i ON (i.package_id = p.package_id)
    JOIN Claims cl ON  (cl.policy_id = p.policy_id)
    WHERE c.claim_id = p_claim_id;
    
    IF p_claim_amount > p_max_limit THEN
    SET message = 'Exceeded';
    ELSE SET message = 'Valid';
    END IF;
END //
DELIMITER ;

-- Câu 2:
DELIMITER //
CREATE PROCEDURE sp_cancel_policy (
	IN p_policy_id VARCHAR(10),
	IN p_claim_id VARCHAR(10),
    OUT message VARCHAR(50))
BEGIN
	DECLARE count_log INT;
    
	START TRANSACTION;
    IF (SELECT policy_id FROM policies WHERE policy_id = p_policy_id) IS NULL THEN
		SET message = 'Policy not found';
		ROLLBACK;
        
	ELSEIF (SELECT c.claim_id FROM Claims c JOIN policies p ON (c.policy_id = p.policy_id) WHERE c.claim_id = p_claim_id) IS NULL THEN
		SET message = 'Invalid claim for policy';
		ROLLBACK;
	END IF;
    
    UPDATE policies SET status = 'Cancelled' WHERE policy_id = p_policy_id AND claim_id = p_claim_id;
    
    SELECT COUNT(log_id) INTO count_log FROM Claim_Processing_Log;
    INSERT INTO Claim_Processing_Log(log_id, claim_id, action_detail, processor) 
        VALUES
			(CONCAT('L00',count_log + 1), p_claim_id, 'Customer requested cancellation', 'Admin');
    COMMIT;
    SET message = 'Cancelled successfully';
END //
DELIMITER ;