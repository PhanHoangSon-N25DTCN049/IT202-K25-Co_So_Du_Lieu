/*
Dùng BEFORE INSERT trên bảng Service_Usages.
Vì sao: Mình cần phải lấy giá dịch vụ điền vào ô actual_price và kiểm tra ví của bệnh nhân trước khi dòng chỉ định dịch vụ thực sự được lưu vào database. Nếu có lỗi (ví khóa, thiếu tiền) thì chặn đứng luôn.

Các biến cục bộ cần dùng (DECLARE):
v_price: Để hứng đơn giá của dịch vụ tra cứu từ bảng Services.
v_balance: Để hứng số dư tài khoản hiện tại của bệnh nhân trong bảng Wallets.
v_status: Để hứng trạng thái hoạt động của ví (Active hay Inactive).
*/

DELIMITER //

CREATE TRIGGER AutoDeductWallet
BEFORE INSERT ON Service_Usages
FOR EACH ROW
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_balance DECIMAL(10,2);
    DECLARE v_status VARCHAR(20);

    -- Bước 1: Tra cứu đơn giá dịch vụ và gán tự động vào cột actual_price
    SELECT price INTO v_price FROM Services WHERE service_id = NEW.service_id;
    SET NEW.actual_price = v_price;

    -- Bước 2: Lấy thông tin số dư và trạng thái ví của bệnh nhân
    SELECT balance, status INTO v_balance, v_status FROM Wallets WHERE patient_id = NEW.patient_id;

    -- Bước 3: Kiểm tra các ràng buộc hệ thống
    IF v_status = 'Inactive' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Thất bại: Ví trả trước đang bị khóa';
        
    ELSEIF v_balance < v_price THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Thất bại: Số dư ví không đủ để thanh toán';
        
    ELSE
        -- Bước 4: Hợp lệ thì tự động trừ tiền trong ví
        UPDATE Wallets 
        SET balance = balance - v_price 
        WHERE patient_id = NEW.patient_id;
    END IF;
END //

DELIMITER ;

-- Kịch bản 1: Giao dịch hợp lệ (Ví dụ: Bệnh nhân ID = 1 khám dịch vụ ID = 10)
-- Hệ thống phải tự điền giá, trừ tiền ví thành công và cho phép insert.
INSERT INTO Service_Usages (patient_id, service_id) VALUES (1, 10);

-- Lệnh SELECT chứng minh ví đã bị trừ tiền:
SELECT * FROM Wallets WHERE patient_id = 1;


-- Kịch bản 2: Thẻ bị khóa (Ví dụ: Bệnh nhân ID = 2 có ví trạng thái 'Inactive')
-- Hệ thống phải chặn lại và báo lỗi: "Thất bại: Ví trả trước đang bị khóa"
INSERT INTO Service_Usages (patient_id, service_id) VALUES (2, 10);


-- Kịch bản 3: Cháy ví (Ví dụ: Bệnh nhân ID = 3 chỉ còn 50k nhưng đòi dùng dịch vụ 200k)
-- Hệ thống phải chặn lại và báo lỗi: "Thất bại: Số dư ví không đủ để thanh toán"
INSERT INTO Service_Usages (patient_id, service_id) VALUES (3, 15);