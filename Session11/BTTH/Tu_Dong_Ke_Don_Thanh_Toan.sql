/*
1. Phân tích I/O (Input/Output)
Tham số đầu vào (IN):

p_patient_id (INT): Để xác định bệnh nhân cần thanh toán.

p_medicine_id (INT): Để lấy đơn giá và trừ kho.

p_quantity (INT): Số lượng thuốc bác sĩ kê.

p_discount_code (VARCHAR): Mã giảm giá từ kế toán.

Tham số đầu ra (OUT):

p_message (VARCHAR): Trả về thông báo trạng thái.

Tại sao dùng OUT cho thông báo? Vì hệ thống Backend (như Java/NodeJS) cần một giá trị cụ thể để hiển thị thông báo Popup cho người dùng ngay lập tức mà không cần phải duyệt qua một bảng kết quả (ResultSet) phức tạp.

2. Thiết kế luồng xử lý (Workflow)
Khai báo biến cục bộ (Local Variables):

v_unit_price: Lưu giá thuốc tại thời điểm kê đơn.

v_current_stock: Lưu số lượng tồn kho hiện tại để kiểm tra.

v_final_amount: Lưu số tiền cuối cùng sau khi đã áp mã giảm giá.

Kiểm tra tồn kho: Truy vấn Medicines để lấy giá và số lượng tồn.

Logic rẽ nhánh (IF): * Nếu v_current_stock < p_quantity -> Gán thông báo lỗi và thoát.

Ngược lại -> Tính tiền, áp dụng giảm giá (CASE/IF), cập nhật kho và hóa đơn.

Transaction: Đảm bảo việc trừ kho và cộng nợ diễn ra đồng thời (không có chuyện trừ kho xong mà nợ không tăng).
*/
-- Tạo bảng thuốc
CREATE TABLE Medicines (
    medicine_id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(18,2),
    stock INT
);

-- Tạo bảng hóa đơn bệnh nhân
CREATE TABLE Patient_Invoices (
    patient_id INT PRIMARY KEY,
    total_due DECIMAL(18,2) DEFAULT 0
);

-- Chèn dữ liệu mẫu
INSERT INTO Medicines VALUES (1, 'Paracetamol', 10000, 100), (2, 'Antibiotic', 50000, 5);
INSERT INTO Patient_Invoices (patient_id, total_due) VALUES (101, 0), (102, 50000);

DELIMITER //

CREATE PROCEDURE ProcessPrescription(
    IN p_patient_id INT,
    IN p_medicine_id INT,
    IN p_quantity INT,
    IN p_discount_code VARCHAR(20),
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_unit_price DECIMAL(18,2);
    DECLARE v_current_stock INT;
    DECLARE v_total_amount DECIMAL(18,2);

    -- 1. Lấy thông giá và tồn kho
    SELECT price, stock INTO v_unit_price, v_current_stock 
    FROM Medicines WHERE medicine_id = p_medicine_id;

    -- 2. Kiểm tra Out of stock
    IF v_current_stock < p_quantity THEN
        SET p_message = 'Thất bại: Kho không đủ thuốc';
    ELSE
        -- 3. Tính toán tiền gốc
        SET v_total_amount = p_quantity * v_unit_price;

        -- 4. Áp dụng mã giảm giá (Xử lý cả mã rác/NULL)
        IF p_discount_code = 'NV-RIKKEI' THEN
            SET v_total_amount = v_total_amount * 0.5;
        END IF;

        -- 5. Thực hiện cập nhật (Dùng Transaction ngầm định)
        START TRANSACTION;
            -- Trừ kho
            UPDATE Medicines 
            SET stock = stock - p_quantity 
            WHERE medicine_id = p_medicine_id;

            -- Cộng dồn nợ cho bệnh nhân
            UPDATE Patient_Invoices 
            SET total_due = total_due + v_total_amount 
            WHERE patient_id = p_patient_id;
        COMMIT;

        SET p_message = 'Thành công: Đã xử lý đơn thuốc';
    END IF;
END //

DELIMITER ;

-- Kịch bản 1: Kê đơn bình thường, không mã giảm giá
CALL ProcessPrescription(101, 1, 2, NULL, @msg1);
SELECT @msg1 AS Status, total_due FROM Patient_Invoices WHERE patient_id = 101;

-- Kịch bản 2: Kê đơn có mã NV-RIKKEI (Giảm 50%)
CALL ProcessPrescription(101, 1, 2, 'NV-RIKKEI', @msg2);
SELECT @msg2 AS Status, total_due FROM Patient_Invoices WHERE patient_id = 101;

-- Kịch bản 3: Kê đơn vượt quá tồn kho (Bẫy lỗi)
-- Thử mua 10 vỉ Antibiotic trong khi kho chỉ còn 5
CALL ProcessPrescription(102, 2, 10, NULL, @msg3);
SELECT @msg3 AS Status;