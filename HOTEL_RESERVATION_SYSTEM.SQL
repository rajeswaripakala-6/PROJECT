-- creating a database name HOTEL_RESERVATION_SYSTEM --
CREATE DATABASE HOTEL_RESERVATION_SYSTEM;
USE HOTEL_RESERVATION_SYSTEM;
-- creating a table hotel_reservations --
CREATE TABLE hotel_reservations (
    reservation_id INT PRIMARY KEY,
    guest_name VARCHAR(100),
    room_number INT,
    check_in_date DATE,
    check_out_date DATE,
    number_of_guests INT
);
-- adding payment_status column to table --
ALTER TABLE hotel_reservations
ADD payment_status VARCHAR(20);
-- inserting values into table -- 
INSERT INTO hotel_reservations (reservation_id, guest_name, room_number, check_in_date, check_out_date, number_of_guests, payment_status)
VALUES
(101, 'Rajeswari', 408, '2025-08-22', '2025-08-26', 2, 'Paid'),
(102, 'Bavagnya', 115, '2025-08-20', '2025-08-22', 1, 'Pending'),
(103, 'Sesi', 312, '2025-08-21', '2025-08-24', 4, 'Paid'),
(104, 'Dharani', 207, '2025-08-23', '2025-08-27', 2, 'Cancelled'),
(105, 'Abinaya', 101, '2025-08-19', '2025-08-21', 1, 'Paid'),
(106, 'Ram', 410, '2025-08-22', '2025-08-26', 2, 'Paid'),
(107, 'Nani', 235, '2025-08-20', '2025-08-22', 1, 'Pending'),
(108, 'Sam', 352, '2025-08-21', '2025-08-24', 4, 'Paid'),
(109, 'Durga', 307, '2025-08-23', '2025-08-27', 2, 'Cancelled'),
(110, 'Varshini', 201, '2025-08-23', '2025-08-21', 1, 'Paid');
SELECT * FROM hotel_reservations;
-- updating payment_status of guest--
UPDATE hotel_reservations SET payment_status = 'Pending' WHERE reservation_id = 103;
SELECT * FROM hotel_reservations;
-- deleting guest whose id is 107 --
DELETE FROM hotel_reservations WHERE reservation_id = 107;
SELECT * FROM hotel_reservations;
SELECT * FROM hotel_reservations WHERE payment_status = 'Paid';
-- aggregate founctions --
SELECT COUNT(*) AS total_reservations FROM hotel_reservations;
SELECT SUM(number_of_guests) AS total_guests FROM hotel_reservations;
SELECT AVG(number_of_guests) AS avg_guests_per_booking FROM hotel_reservations;
SELECT 
  MIN(check_in_date) AS earliest_check_in,
  MAX(check_in_date) AS latest_check_in
FROM hotel_reservations;
-- group by clause --
SELECT payment_status, COUNT(*) AS total_bookings FROM hotel_reservations GROUP BY payment_status;
-- having clause --
SELECT check_in_date, AVG(number_of_guests) FROM hotel_reservations GROUP BY check_in_date HAVING AVG(number_of_guests) > 3;
SELECT * FROM hotel_reservations;
-- like keyword --
SELECT * FROM hotel_reservations WHERE guest_name LIKE 'D%';
-- using sub queries --
SELECT guest_name FROM hotel_reservations WHERE reservation_id IN (SELECT reservation_id FROM hotel_reservations WHERE payment_status = 'Paid');
-- creating a stored procedure for adding reservations --
DELIMITER //
CREATE PROCEDURE AddHotelReservation (
    IN p_reservation_id INT,
    IN p_guest_name VARCHAR(100),
    IN p_room_number INT,
    IN p_check_in_date DATE,
    IN p_check_out_date DATE,
    IN p_number_of_guests INT
)
BEGIN
    INSERT INTO hotel_reservations (
        reservation_id,
        guest_name,
        room_number,
        check_in_date,
        check_out_date,
        number_of_guests
    )
    VALUES (
        p_reservation_id,
        p_guest_name,
        p_room_number,
        p_check_in_date,
        p_check_out_date,
        p_number_of_guests
    );
END;
CALL AddHotelReservation(
    111,
    'NANI',
    204,
    '2025-08-21',
    '2025-08-24',
    2
);
DELIMITER //
CREATE TRIGGER prevent_double_booking
BEFORE INSERT ON hotel_reservations
FOR EACH ROW
BEGIN
    DECLARE room_conflict INT;

    SELECT COUNT(*) INTO room_conflict
    FROM hotel_reservations
    WHERE room_number = NEW.room_number
      AND (
          (NEW.check_in_date BETWEEN check_in_date AND check_out_date)
          OR
          (NEW.check_out_date BETWEEN check_in_date AND check_out_date)
          OR
          (check_in_date BETWEEN NEW.check_in_date AND NEW.check_out_date)
      );

    IF room_conflict > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Room is already booked for the selected dates';
    END IF;
END;
//

DELIMITER ;
