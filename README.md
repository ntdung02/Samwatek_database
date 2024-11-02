# Cơ sở dữ liệu quản lý Đơn hàng trong quy trình bán hàng cho SamwaTek
## 1. Tổng quan 
Công ty TNHH Cơ Điện Samwa Tek là công ty hàng đầu trong lĩnh vực sản xuất sản phẩm công nghiệp phụ trợ, phục vụ các công ty đến từ Hàn Quốc, Nhật Bản và nhiều quốc gia khác.
Việc xây dựng cơ sở dữ liệu quản lý đơn hàng là một giải pháp quan trọng cho Công ty TNHH Cơ Điện Samwa Tek nhằm nâng cao hiệu quả quản lý trong hoạt động bán hàng. Hiện tại, Samwa Tek đang quản lý thông tin đơn hàng và các dữ liệu liên quan theo phương pháp thủ công, dẫn đến việc xử lý thông tin chậm trễ, dễ xảy ra sai sót, và khó khăn khi cần tra cứu hoặc báo cáo. Khi áp dụng cơ sở dữ liệu quản lý đơn hàng, Samwa Tek sẽ có thể tổ chức thông tin một cách hệ thống và khoa học hơn, giúp nhân viên dễ dàng truy cập dữ liệu, cập nhật trạng thái đơn hàng theo thời gian thực, và theo dõi tiến trình giao hàng một cách rõ ràng.
    Dự án gồm .. phần chính
  1. Mô tả bài toán
  2. Phân tích và thiết kế cơ sở dữ liệu
  3. Một số ràng buộc toàn vẹn
  4. Ứng dụng một số
## 2. Mô tả bài toán
Công ty sẽ bán rất nhiều Sản phẩm khác nhau, mỗi sản phẩm sẽ được phân biệt bằng mã sản phẩm, tên sản phẩm, đơn giá, mô tả, tồn kho. Để khách hàng dễ dàng lựa chọn, tìm kiếm thì các sản phẩm sẽ được phân loại theo Nhóm sản phẩm. Khách hàng có thể tìm đến công ty mua hàng thông qua các hình thức khác nhau (đến trực tiếp, liên hệ website, điện thoại, email, …),  thông tin của khách hàng sẽ được lưu trữ lại để dễ dàng truy xuất lịch sử mua hàng, thiết lập các chính sách ưu đãi khách hàng bao gồm: mã khách hàng, tên khách hàng, địa chỉ, số điên thoại,..

Sau khi khách hàng gửi yêu cầu mua hàng của họ cho công ty, nhân viên bán hàng sẽ tiếp nhận và tiến hành tạo Đơn đơn hàng bán để lưu trên hệ thống, đơn hàng sẽ chứa thông tin về mã đơn, ngày lập, tình trạng, địa chỉ giao, ngày giao, giảm giá,. . Mỗi Đơn hàng bán sẽ có một hoặc nhiều thông tin chi tiết về đơn đặt bao gồm: mã sản phẩm, số lượng, giá bán… Và với mỗi đơn hàng bán sẽ có một Phiếu tính tiền để thu tiền từ  khách hàng, chi tiết thông tin về mã phiếu , tổng tiền, ngày lập phiếu, tiền giảm giá, tổng cộng.. và Chi tiết phiếu sẽ cho biết thông tin về mã sản phẩm, số lượng, đơn giá thanh toán, thành tiền. Trong quá trình này sẽ có nhiều Chi nhánh bán hàng tham gia vào hệ thống, mỗi chi nhánh bán hàng sẽ được cấp một mã chi nhánh và tên chi nhánh, địa chỉ,… để có thể kiểm soát được lượng đơn hàng và doanh thu thu được từ các đơn của từng chi nhánh.

Mỗi nhân viên sẽ được cấp tài khoản để đăng nhập vào hệ thống, thông tin tài khoản bao gồm: Mã nhân viên, tài khoản, mật khẩu, tên nhân viên, chức vụ.. để kiểm soát được quyền truy cập hệ thống. Chức vụ của nhân viên sẽ quyết định quyền hạn của họ khi tham gia hệ thống.
## 3. Phân tích và thiết kế cơ sở dữ liệu
### 3.1. Xác định đối tượng người dùng
Trong hệ thống quản lý đơn đặt bao gồm những đối tượng người dùng sau:
+  Nhân viên bán hàng: chịu trách nhiệm quản lý thông tin Đơn hàng bán, cũng như theo dõi thông tin Khách hàng. Họ tiếp nhận và tạo đơn bán để lưu trên hệ, sau đó tạo phiếu tính tiền. Ngoài ra, nhân viên bán hàng còn quản lý thông tin khách hàng. 
+ Quản lý: Quản lý có vai trò quan trọng trong việc duy trì và giám sát hoạt động của quy trình quản lý đơn hàng, thống kê đơn hàng bán. Họ có quyền truy cập và thực hiện tất cả các chức năng trong hệ thống.
### 3.2. Xác định các hệ thống phân quyền người dùng
Hệ thống bao gồm nhóm đối tượng chính: Nhân viên phụ trách bán bán hàng
+ Nhân viên bán hàng: được thêm (insert), xoá (delete), sửa (update), truy vấn (select) thông tin trên bảng Đơn Hàng Bán, Chi tiết Đơn hàng bán , Khách Hàng, Phiếu tính tiền, Chi tiết phiếu tính tiền 
Truy vấn thông tin trên view: vw_DonHangBan, vw_PhieuTinhTien
Truy vấn thông tin trên bảng: Chi Nhánh, Sản phẩm, Nhóm sản phẩm
+ Quản lý: được toàn quyền quyết định trên toàn bộ Cơ sở dữ liệu

Tạo nhóm người dùng theo từng bộ phận
![image](https://github.com/user-attachments/assets/7cd35fa8-82c5-44cc-afca-902aaa3011c1)

Phân quyền cho Role NhanVienBanHang
![image](https://github.com/user-attachments/assets/66136dd4-06a5-4e1f-80c1-727103b8053d)

Phân quyền cho Role QuanLy
![image](https://github.com/user-attachments/assets/7ae0379c-7ee5-426f-bc56-17afd32e495f)




