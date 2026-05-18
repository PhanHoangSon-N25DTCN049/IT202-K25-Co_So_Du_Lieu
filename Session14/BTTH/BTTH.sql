/*
Tham số đầu vào (IN): p_patient_id (INT - Mã bệnh nhân), p_product_id (INT - Mã sản phẩm), p_quantity (INT - Số lượng mua).
Tham số đầu ra (OUT): p_status_message (VARCHAR(255) - Thông báo trạng thái).
Giải thích lý do dùng OUT: Chúng ta sử dụng tham số loại OUT vì hệ thống chỉ cần nhận chuỗi thông báo kết quả trả về sau khi thủ tục xử lý xong, hoàn toàn không cần truyền giá trị ban đầu từ ngoài vào cho biến này.

Thiết kế luồng xử lý
Khai báo các biến cục bộ cần thiết gồm: v_stock (tồn kho hiện tại), v_price (đơn giá sản phẩm), v_balance (số dư ví), v_wallet_status (trạng thái ví), và v_total_cost (thành tiền).
Đặt bộ xử lý ngoại lệ DECLARE EXIT HANDLER FOR SQLEXCEPTION ở ngay đầu thân thủ tục để tự động ROLLBACK nếu hệ thống gặp sự cố bất ngờ.
Kích hoạt giao dịch bằng lệnh START TRANSACTION.
Bước 1: Lấy thông tin tồn kho và đơn giá từ bảng Products. Nếu v_stock < p_quantity, thực hiện ROLLBACK và trả về "Thất bại: Kho không đủ sản phẩm".
Bước 2: Lấy số dư và trạng thái ví từ bảng Wallets. Nếu v_wallet_status = 'Inactive', thực hiện ROLLBACK và trả về "Thất bại: Ví đang bị khóa".
Bước 3: Tính toán v_total_cost = p_quantity * v_price. Nếu v_balance < v_total_cost, thực hiện ROLLBACK và trả về "Thất bại: Số dư ví không đủ".
Bước 4: Thực thi trừ tồn kho trong bảng Products và trừ tiền trong bảng Wallets.
Bước 5: Gọi lệnh COMMIT để chốt dữ liệu và trả về "Thành công: Đã xử lý đơn hàng".
*/

DROP PROCEDURE IF EXISTS ProcessEquipmentPurchase;

DELIMITER //

CREATE PROCEDURE ProcessEquipmentPurchase(
    IN p_patient_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_status_message VARCHAR(255)
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(18,2);
    DECLARE v_balance DECIMAL(18,2);
    DECLARE v_wallet_status VARCHAR(50);
    DECLARE v_total_cost DECIMAL(18,2);

    -- Tự động rollback khi sập nguồn hoặc lỗi SQL
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_message = 'Thất bại: Hệ thống gặp sự cố đột xuất.';
    END;

    -- Bắt đầu giao dịch
    START TRANSACTION;

    -- 1. Lấy thông tin sản phẩm
    SELECT stock_quantity, price INTO v_stock, v_price
    FROM Products
    WHERE product_id = p_product_id;

    -- Ràng buộc 1: Kiểm tra Out of stock
    IF v_stock IS NULL OR v_stock < p_quantity THEN
        ROLLBACK;
        SET p_status_message = 'Thất bại: Kho không đủ sản phẩm';
    ELSE
        -- 2. Lấy thông tin ví của bệnh nhân
        SELECT balance, status INTO v_balance, v_wallet_status
        FROM Wallets
        WHERE patient_id = p_patient_id;

        -- Ràng buộc 2: Kiểm tra Locked Account
        IF v_wallet_status = 'Inactive' THEN
            ROLLBACK;
            SET p_status_message = 'Thất bại: Ví đang bị khóa';
        ELSE
            -- Tính thành tiền
            SET v_total_cost = p_quantity * v_price;

            -- Ràng buộc 3: Kiểm tra Insufficient funds
            IF v_balance IS NULL OR v_balance < v_total_cost THEN
                ROLLBACK;
                SET p_status_message = 'Thất bại: Số dư ví không đủ';
            ELSE
                -- Bước 3: Cập nhật trừ kho sản phẩm
                UPDATE Products
                SET stock_quantity = stock_quantity - p_quantity
                WHERE product_id = p_product_id;

                -- Bước 4: Cập nhật trừ tiền ví bệnh nhân
                UPDATE Wallets
                SET balance = balance - v_total_cost
                WHERE patient_id = p_patient_id;

                -- Xác nhận lưu thay đổi
                COMMIT;
                SET p_status_message = 'Thành công: Đã xử lý đơn hàng';
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;

-- Tạo biến chứa thông báo kết quả
SET @purchase_res = '';

-- Kịch bản 1: Mua hàng hợp lệ (Kho đủ, ví đủ, ví active)
CALL ProcessEquipmentPurchase(1, 101, 1, @purchase_res);
SELECT @purchase_res AS 'Kết quả Test 1'; 
-- Mong đợi: 'Thành công: Đã xử lý đơn hàng'

-- Kịch bản 2: Lỗi Out of stock (Mua số lượng vượt quá tồn kho)
CALL ProcessEquipmentPurchase(1, 101, 9999, @purchase_res);
SELECT @purchase_res AS 'Kết quả Test 2'; 
-- Mong đợi: 'Thất bại: Kho không đủ sản phẩm'

-- Kịch bản 3: Lỗi Insufficient funds (Mua sản phẩm đắt tiền vượt số dư ví)
-- Giả sử sản phẩm 102 có giá rất cao so với ví bệnh nhân 2
CALL ProcessEquipmentPurchase(2, 102, 10, @purchase_res);
SELECT @purchase_res AS 'Kết quả Test 3'; 
-- Mong đợi: 'Thất bại: Số dư ví không đủ'

-- Kịch bản 4: Lỗi Locked Account (Bệnh nhân có ví trạng thái 'Inactive')
-- Giả sử bệnh nhân số 3 đang bị khóa ví
CALL ProcessEquipmentPurchase(3, 101, 1, @purchase_res);
SELECT @purchase_res AS 'Kết quả Test 4'; 
-- Mong đợi: 'Thất bại: Ví đang bị khóa'

