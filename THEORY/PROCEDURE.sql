
-- SYNTAX CREATE PROCEDURE
DELIMITER $$
CREATE PROCEDURE procedureName()
BEGIN
		/*CODES*/
END $$
DELIMITER ;

-- SYNTAX EXECUTE PROCEDURE
call procedureName();

-- Xem danh sách Stored Procedure trong hệ thống
show procedure status;

-- SYNTAX UPDATE PROCEDURE
-- Trong Mysql không cung cấp lệnh sửa Stored nên thông thường chúng ta sẽ chạy lệnh tạo mới.
DELIMITER $$
DROP PROCEDURE IF EXISTS `GetAllProducts`;
 
CREATE PROCEDURE `GetAllProducts`()
BEGIN
	/*CODES*/
END $$
DELIMITER ;


/*
Và một lưu ý nữa là khi bạn dùng với quyền User nào thì Store đó sẽ có quyền thực hiện trong phạm vu của User đó. 
Ví dụ bạn không có quyền edit mà bạn tạo mới một Procedure Edit thì khi chạy sẽ bị báo lỗi ngay.
Chính vì vậy thông thường khi edit bạn phải thêm người định nghĩa nó như sau:

DELIMITER $$
 
DROP PROCEDURE IF EXISTS `GetAllProducts`$$
 
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllProducts`()
BEGIN
   SELECT *  FROM products;
END$$
 
DELIMITER ;
Dòng chữ DEFINER=`root`@`localhost` chính là tên người đã tạo ra nó.
*/


1. Khai báo biến trong MySql Stored Procedure
	-> DECLARE variable_name datatype(size) DEFAULT default_value
    -> Ex: DECLARE product_title VARCHAR(255) DEFAULT 'No Name';
    
2. Gán giá trị cho biến trong MySql Stored Procedure
	-> SET variable_name = 'value';
	-> Ex: DECLARE age INT(11) DEFAULT 0
			SET age = 12

	-> Ex: Gán giá trị thông qua lệnh Select 
			DECLARE total_products INT DEFAULT 0
			SELECT COUNT(*) INTO total_products
            FROM products

3. Phạm vi hoạt động của biến: Hoạt động trong phạm vi BEGIN...END
4. Các loại tham số trong Mysql Stored Procedure
	IN: Đây là chế độ mặc định (nghĩa là nếu bạn không định nghĩa loại nào thì nó sẽ hiểu là IN). 
    Khi bạn sử dụng mức này thì nó sẽ được bảo vệ an toàn, có nghĩa là sẽ không bị thay đổi nếu như trong Procedure có tác động đến
	OUT: Chế độ này nếu như trong Procedure có tác động thay đổi thì nó sẽ thay đổi theo. 
    Nhưng có điều đặc biệt là dù trước khi truyền vào mà bạn gán giá trị cho biến đó thì vẫn sẽ không nhận được 
    Vì mặc định nó luôn hiểu giá trị truyền vào là NULL.
I	INOUT: Đây là sự kết hợp giữa IN và OUT. Nghĩa là có thể gán giá trị trước và có thể bị thay đổi nếu trong Procedure có tác động tới.

/*
-- Tham số loại IN trong Mysql Stored Procedure => CALL getById(1);
-- Tham số loại OUT trong Mysql Stored Procedure => CALL changeTitle(@title); -> SELECT @title;
Như vậy ra rút ra kết luận như sau:

Khi truyền tham số dạng OUT mục đích là lấy dữ liệu trong Proedure và sử dụng ở bên ngoài.
Khi truyền tham số vào dạng OUT phải có chữ @ đằng trước biến.
Hoạt động giống tham chiếu nên biến truyền vào dạng OUT không cần định nghĩa trước, chính vì vậy khởi đầu nó có giá trị NULL.

-- Tham số dạng INOUT trong Mysql Stored Procedure
INOUT là sự kết hợp giữa IN và OUT, nghĩa là:

Nó có thể được định nghĩa trước và gán gia trị trước rồi truyền vào Procedure, điều này với dạng OUT thì không thể được nhưng IN thì được.
Sau khi thực thi xong nếu trong Procedure có tác động đến thì ảnh hưởng theo. Điêu này dạng IN không được nhưng OUT thì không được.
DELIMITER $$
 
DROP PROCEDURE IF EXISTS counter $$
 
CREATE PROCEDURE counter(INOUT number INT(11))
BEGIN
    SET number = number + 1;
END; $$
DELIMITER;

SET @counter = 1;
CALL counter(@counter);
SELECT @counter;

Và kết quả là 2.

Nhưng nếu ta dùng dạng OUT thì kết quả sẽ là NULL. 
Lý do là bên trong có tăng lên 1 nhưng nó lấy giá trị truyền vào dạng OUT là NULL nên 1 + NULL sẽ là NULL.

*/


-- Question: For every iphone 13 sale, modify the databases table acordingly
DELIMITER $$
DROP PROCEDURE IF EXISTS pr_buy_product;
 
CREATE PROCEDURE pr_buy_product()
BEGIN
	/*CODES*/
END $$
DELIMITER ;





