# Cơ sở dữ liệu quản lý Đơn hàng trong quy trình bán hàng cho SamwaTek
## 1. Tổng quan 
Công ty TNHH Cơ Điện Samwa Tek là công ty hàng đầu trong lĩnh vực sản xuất sản phẩm công nghiệp phụ trợ, phục vụ các công ty đến từ Hàn Quốc, Nhật Bản và nhiều quốc gia khác.
Việc xây dựng cơ sở dữ liệu quản lý đơn hàng là một giải pháp quan trọng cho Công ty TNHH Cơ Điện Samwa Tek nhằm nâng cao hiệu quả quản lý trong hoạt động bán hàng. Hiện tại, Samwa Tek đang quản lý thông tin đơn hàng và các dữ liệu liên quan theo phương pháp thủ công, dẫn đến việc xử lý thông tin chậm trễ, dễ xảy ra sai sót, và khó khăn khi cần tra cứu hoặc báo cáo. Khi áp dụng cơ sở dữ liệu quản lý đơn hàng, Samwa Tek sẽ có thể tổ chức thông tin một cách hệ thống và khoa học hơn, giúp nhân viên dễ dàng truy cập dữ liệu, cập nhật trạng thái đơn hàng theo thời gian thực, và theo dõi tiến trình giao hàng một cách rõ ràng.
    Dự án gồm .. phần chính
  1. Mô tả bài toán
  2. Phân tích và thiết kế cơ sở dữ liệu
  3. Một số ràng buộc toàn vẹn
  4. Ứng dụng một số procedure, function, trigger vào bài toán
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

### 3.3. Phân tích, thiết hệ thống CSDL cho chức năng quản lý Đơn hàng 
- Mô hình ERD

![image](https://github.com/user-attachments/assets/06931396-7ade-43d5-8c87-d4ba76bb6d7f)

- Sơ đồ vật lý Diagram

![image](https://github.com/user-attachments/assets/9af05155-6f6b-401e-a6d1-b74d112f17b5)


- Từ mô hình thực thể kết hợp ERD ta xây dựng nên mô hình quan hệ dữ liệu như sau:

TÀI KHOẢN (MaNV, TaiKhoan, MatKhau,  HoTen, ChucVu
MaNV – Mã nhân viên là khoá chính


KHACHHANG (MaKH, HoTenKH, DiaChiKH, SDTKH)
MaKH – Mã khách hàng là khoá chính

NHOM (MaNhomSP, TenNhomSP)
MaNhomSP – Mã nhóm sản phẩm là khoá chính

SANPHAM (MaSP, TenSP, SoLuongTon, GiaBan, GiaNhap, HinhAnh, MaNhomSP (FK) )
MaSP – Mã sản phẩm là khoá chính
MaNhomSP – Mã nhóm sản phẩm là khoá ngoại tham chiếu đến bảng Nhóm sản phẩm

DONHANGBAN (MaDonBan, NgayLap, NgayGiao, TinhTrang, DiaChiGiao, GiamGia, MaKH (FK) , MaNV (FK), MaCN(FK))
	MaDonBan – Mã đơn bán là khoá chính
	MaKH – Mã khách hàng là khoá ngoại tham chiếu đến bảng Khách hàng
	MaNV – Mã nhân viên là khoá ngoại tham chiếu đến bảng Nhân viên
MaCN – Mã chi nhánh là khoá ngoại tham chiếu đến bảng Chi nhánh

CTDONHANGBAN (MaDonBan (FK), MaSP (FK), SoLuongDat)
MaDonBan – Mã đơn bán là khoá chính
MaSP – Mã sản phẩm là khoá ngoại tham chiếu đến bảng Sản phẩm

PHIEUTINHTIEN (MaPhieuTien, NgayLap, TongTien, GiamGia, TongCong, MaDonBan (FK), MaNV (FK)
	MaPhieu – Mã hoá đơn là khoá chính
	MaDonBan – Mã đơn bán là là khoá ngoại tham chiếu đến bảng Đơn hàng bán
	MaNV – Mã nhân viên là khoá ngoại tham chiếu đến bảng Nhân viên

CT PHIEUTINHTIEN (MaPhieuTien (FK), MaSP (FK), SoLuong, ThanhTien)
MaPhieuTinhTien – Mã hoá đơn là khoá chính
MaSP – Mã sản phẩm là khoá ngoại tham chiếu đến bảng Sản phẩm

## 3.4. Một số ràng buộc toàn vẹn
SanPham (MaSP, TenSanPham, SoLuongTon, GiaBan, GiaNhap, HinhAnh, MaNhomSP)
+ Mô tả: Số lượng tồn Sản phẩm phải lớn hơn hoặc bằng 0 
+) Biểu diễn: n SanPham (n.SoLuongTon >=0)
+) Bối cảnh: SanPham
![image](https://github.com/user-attachments/assets/57befc98-a123-4bac-9c96-59cfeee493be)


DonBanHang (MaDonBan, NgayLapDB, TinhTrang, DiaChiGiao, NgayGiao, TongTien, VAT, TongTienCuoi , MaNV (FK), MaKH (FK)) 
+) Mô tả: Với mọi Đơn bán hàng, Ngày Giao hàng (NgayGiao)  phải lớn hơn Ngày lập đơn đặt hàng (NgayLap)
+) Biểu diễn: n DonBanHang  (n.NgayGiao > n.NgayLapDB)
+) Bối cảnh: DonBanHang

![image](https://github.com/user-attachments/assets/53937c21-b64b-4d61-9d7b-d3585cd99bfe)

## 3.5. Ứng dụng một số procedure, function, trigger vào bài toán

- Sau khi thêm mới hoặc update Phiếu tính tiền, giá trị của Tổng tiền, VAT và tổng cộng sẽ được cập nhật theo Đơn hàng bán

![image](https://github.com/user-attachments/assets/8970254d-cfdc-45dd-916d-2f1354aeb931)

Trình tự 
1. Kích hoạt Trigger: Mỗi khi có dòng mới được thêm vào hoặc thay đổi trong bảng PhieuTinhTien, trigger này sẽ tự động chạy.
2. Tạo bảng tạm tính toán: Trigger tạo một bảng tạm để tính tổng tiền của mỗi phiếu tính tiền (lấy từ chi tiết phiếu CTPhieuTinhTien) và lấy mức giảm giá (từ bảng DonHangBan).
3. Cập nhật TongTien: Dùng tổng tiền vừa tính được, trigger cập nhật trường TongTien trong bảng PhieuTinhTien.
4. Tính và cập nhật TongCong: Trigger tính TongCong bằng cách áp dụng giảm giá cho TongTien và cập nhật giá trị này vào cột TongCong.
5. Cập nhật GiamGia: Trigger cập nhật trường GiamGia trong bảng PhieuTinhTien theo thông tin từ DonHangBan.
6. Kết thúc: Sau khi các giá trị được cập nhật, trigger hoàn thành và dừng lại.


- Cập nhật số lượng tồn kho sau khi thêm, xoá, sửa thông tin đối tượng Đơn hàng bán

![image](https://github.com/user-attachments/assets/6b3f2785-959b-43b0-9d15-a4bc26b19e0e)

Trình tự
1. Trigger kích hoạt: Trigger này sẽ chạy sau khi có thao tác INSERT, DELETE, hoặc UPDATE trên bảng CTDonHangBan.
2. Thêm chi tiết đơn hàng bán (INSERT): Nếu có dữ liệu trong inserted (bảng ảo chứa dữ liệu mới thêm), trigger sẽ giảm số lượng tồn (SoLuongTon) của sản phẩm trong bảng SanPham bằng cách trừ đi SoLuongDat (số lượng đặt hàng) của sản phẩm mới thêm.
3. Xóa chi tiết đơn hàng bán (DELETE): Nếu có dữ liệu trong deleted (bảng ảo chứa dữ liệu bị xóa), trigger sẽ tăng số lượng tồn (SoLuongTon) của sản phẩm trong bảng SanPham bằng cách cộng lại SoLuongDat của sản phẩm đã bị xóa.
4. Sửa chi tiết đơn hàng bán (UPDATE): Khi có dữ liệu trong cả inserted và deleted, nghĩa là có thao tác UPDATE. Trigger sẽ thực hiện hai bước:
Trở về số lượng cũ: Tăng SoLuongTon bằng SoLuongDat của sản phẩm trước khi chỉnh sửa (dữ liệu từ deleted).
Cập nhật số lượng mới: Giảm SoLuongTon theo SoLuongDat mới (dữ liệu từ inserted).
5. Kết thúc: Sau khi các giá trị được cập nhật, trigger hoàn thành và dừng lại.

- Tạo thủ tục và sử dụng cursor, với tham số truyền vào là Mã Hoá Đơn, in ra kết quả cho biết Tên sản phẩm, Số lượng, đơn giá bán có trong Hoá đơn bán hàng

![image](https://github.com/user-attachments/assets/31ab5c68-50e3-44a8-932d-1cfd346c40cf)


- Tạo hàm cho biết tổng số lượng tồn theo từng loại hàng (gồm thông tin Mã loại hàng, Tên loại hàng, Tổng số lượng tồn)

![image](https://github.com/user-attachments/assets/85c09ec7-821d-4f7d-921a-0b2b2fac2717)









