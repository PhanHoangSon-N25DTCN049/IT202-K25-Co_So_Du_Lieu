-- Phần backend chưa được học 


-- câu lệnh xắp xếp đa tầng
SELECT * FROM Drivers WHERE status = 'AVAILABLE' AND trust_score >= 80 ORDER BY distance_km ASC, trust_score DESC;