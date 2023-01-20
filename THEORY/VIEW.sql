
/*VIEW IN SQL -> View is a Data Object 
View cho phép chúng ta có thể tổng hợp kết quả từ nhiều bảng, tùy theo tiêu chí mong muốn. 
Bản chất của view chỉ là 1 đoạn mã sql được lưu vào server cơ sở dữ liệu.

Cú pháp tạo thì như sau:
CREATE [OR REPLACE] VIEW [db_name.]view_name [(column_list)]
AS
  select-statement;
  
Trong đó :
OR REPLACE - thêm vào để ghi đè lên view cũ trùng tên nếu có.
db_name. - tên cơ sở dữ liệu
(column_list) - mặc định các column của view sẽ được lấy luôn bằng result set của select-statement, dùng khi muốn rename chúng.

Lưu ý là tên view cũng được nhìn nhận như tên table nên không thể tạo giống nhau.
Vì nó được sử dụng giống như 1 bảng bình thường nên lấy dữ liệu ra cũng rất bình thường như SELECT * FROM view_name;

*/
create view new_view
as 
	select s.store_name, s.product_name, s.emp_id, e.emp_name, d.dept_name
	from sales s
	join employee e on s.emp_id = e.emp_id
	join department d on e.dept_id = e.dept_id;

select * from new_view;
