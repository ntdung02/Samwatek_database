-------------------******************--------------------------------------------
--- Tự dộng cập nhật Tổng tiền, tổng cộng và Giảm giá cho Phiếu tính tiền
create trigger tg_CapNhatSoTienVaGiamGia_PhieuTinhTien
on PhieuTinhTien
AFTER insert, UPDATE
as
begin
  -- Cập nhật tổng tiền trong bảng PhieuTinhTien
    UPDATE PhieuTinhTien
    SET 
		TongTien = ctt.TongTien1 , 
		TongCong = ctt.TongTien1 - ctt.TongTien1 * ctt.GiamGia / 100,
		GiamGia = ctt.GiamGia
    FROM 
        PhieuTinhTien
        JOIN (
            SELECT 
                PhieuTinhTien.MaPhieuTien, 
                SUM(CTPhieuTinhTien.ThanhTien) AS TongTien1, 
                DonHangBan.GiamGia 
            FROM 
                PhieuTinhTien 
                JOIN CTPhieuTinhTien ON PhieuTinhTien.MaPhieuTien = CTPhieuTinhTien.MaPhieuTien
                JOIN DonHangBan ON DonHangBan.MaDonBan = PhieuTinhTien.MaDonBan
            GROUP BY 
                PhieuTinhTien.MaPhieuTien, 
                DonHangBan.GiamGia
        ) ctt ON PhieuTinhTien.MaPhieuTien = ctt.MaPhieuTien;
END;


-- Tự động Cập nhật  CTPhieuTinhTien sau khi thêm Phiếu tính tiền
CREATE TRIGGER tg_GiatrichoSanPhamvaSoLuongTrongCTPhieuTinhTien
ON PhieuTinhTien
AFTER INSERT
AS
BEGIN
    -- Thêm dữ liệu vào bảng CTPhieuTinhTien
    INSERT INTO CTPhieuTinhTien (MaPhieuTien, MaSP, SoLuong, ThanhTien)
    SELECT 
        inserted.MaPhieuTien, 
        CTDonHangBan.MaSP, 
        CTDonHangBan.SoLuongDat, 
        CTDonHangBan.SoLuongDat * SanPham.GiaBan
    FROM 
        inserted 
        JOIN CTDonHangBan ON CTDonHangBan.MaDonBan = inserted.MaDonBan
        JOIN SanPham ON SanPham.MaSP = CTDonHangBan.MaSP;

END;


			
--------cập nhật số lượng tồn --------------------
	CREATE TRIGGER tg_CapNhatSTL_CTDonBan
	ON CTDonHangBan
	AFTER INSERT, DELETE, UPDATE
	AS
	BEGIN
		-- Cập nhật số lượng tồn kho khi thêm chi tiết đơn hàng bán
		IF EXISTS (SELECT * FROM inserted)
		BEGIN
			-- Thêm chi tiết đơn hàng bán
			UPDATE SanPham
			SET SoLuongTon = SoLuongTon - inserted.SoLuongDat
			FROM SanPham
			JOIN inserted ON SanPham.MaSP = inserted.MaSP;
		END

		-- Cập nhật số lượng tồn kho khi xóa chi tiết đơn hàng bán
		IF EXISTS (SELECT * FROM deleted)
		BEGIN
			-- Xóa chi tiết đơn hàng bán
			UPDATE SanPham
			SET SoLuongTon = SoLuongTon + deleted.SoLuongDat
			FROM SanPham
			JOIN deleted ON SanPham.MaSP = deleted.MaSP;
		END

		-- Cập nhật số lượng tồn kho khi sửa chi tiết đơn hàng bán
		IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
		BEGIN
			-- Sửa chi tiết đơn hàng bán
			UPDATE SanPham
			SET SoLuongTon = SoLuongTon + deleted.SoLuongDat -- Trở về số lượng cũ
			FROM SanPham
			JOIN deleted ON SanPham.MaSP = deleted.MaSP;

			UPDATE SanPham
			SET SoLuongTon = SoLuongTon - inserted.SoLuongDat -- Cập nhật số lượng mới
			FROM SanPham
			JOIN inserted ON SanPham.MaSP = inserted.MaSP;
		END
	END;
	GO


	--Tạo thủ tục và sử dụng cursor cho biết  Tên sản phẩm, Số lượng, đơn giá bán có trong Hoá đơn bán hàng
--tham số truyền vào là mã hóa đơn  và in ra kết quả bên trong thủ tục.*/

create proc sp_hienthiHD @mahoadon varchar(10)
	as
		declare   @tensp nvarchar(100), @soluong int, @dongia  int
		--khai báo con trỏ
		declare hienthiHD_cursor cursor
		for
			select  TeSanPham, SoLuongSP, DonGia
			from SanPham join CTHoaDon on SanPham.MaSP=CTHoaDon.MaSP
			where MaHoaDon =@mahoadon
		--mở con trỏ
		open hienthiHD_cursor
		print N' ********DANH SÁCH CÁC SẢN PHẨM ĐƯỢC MUA TRONG HOÁ ĐƠN ********'
		--duyệt từng dòng
		fetch next from hienthiHD_cursor into  @tensp , @soluong , @dongia  

		--kiểm tra
		while @@fetch_status =0
		begin
			print N'Tên sản phẩm: '+ @tensp 
			print N'Số lượng: '+ CONVERT(VARCHAR(20), @soluong )
			print N'Đơn giá bán: '+ CONVERT(VARCHAR(20), @dongia )
			print '********-----------------**************'
			

			fetch next from hienthiHD_cursor into   @tensp , @soluong , @dongia  
		end
		close hienthiHD_cursor

		--giải phóng vùng nhớ con trỏ
		deallocate hienthiHD_cursor

		--kiểm thử
		exec sp_hienthiHD 'HD001'

		--xoá proc
		drop proc sp_hienthiHD


	/*Tạo hàm cho biết tổng số lượng tồn theo từng loại hàng (gồm thông tin Mã loại
hàng, Tên loại hàng, Tổng số lượng tồn)*/

create function f_SLTTheoLoaiHang ()
returns table
as
	return (
	select MH.MaLoaiHang,TenLoaiHang,sum(SoLuongTon) as TongSLT
	from MatHang MH join LoaiHang LH on MH.MaLoaiHang=LH.MaLoaiHang
	group by MH.MaLoaiHang,TenLoaiHang)

--Kiểm thử