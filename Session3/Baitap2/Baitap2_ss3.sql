-- Lỗi 1: Thiếu dấu nháy đơn ' sau chữ Giao hàng nhanh gây lỗi Syntax Error
-- Lỗi 2: không ghi rõ cột cần thêm làm hệ thống không hiểu cần thêm vào cột nào gây lỗi
-- trong trường hợp này cột phone sẽ bị null vì không gán giá trị cho phone
insert into shippers (ShipperName) values ('viettel post');