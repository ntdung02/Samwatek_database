/*Tạo cơ sở dữ liệu  DB_SAMWATEK*/
CREATE DATABASE DB_SAMWATEK
USE DB_SAMWATEK


/*****************1. Tạo các bảng********************/

/*2. Tạo bảng Chi Nhánh*/------------------
create table ChiNhanh
(
	MaCN VARCHAR(6) NOT NULL PRIMARY KEY,
	TenCN NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(1000) NOT NULL,
)

ALTER TABLE ChiNhanh
ALTER COLUMN DiaChi nvarchar(1000) ;


/*2. Tạo bảng TaiKhoan*/------------------
create table TaiKhoan
(
	MaNV VARCHAR(6) NOT NULL PRIMARY KEY ,
    TaiKhoan VARCHAR(20) NOT NULL,
    MatKhau NVARCHAR(20) NOT NULL,
    HoTen NVARCHAR(100) NOT NULL,
    ChucVu NVARCHAR(100) CONSTRAINT CK_ChucVu CHECK 
	(ChucVu IN (N'Quản lý', N'Nhân viên bán hàng')) NOT NULL,
)


/*3. Tạo bảng Nhóm sản phẩm*/
create table Nhom
(
	MaNhomSP varchar (6) primary key,
	TenNhomSP nvarchar(100) NOT NULL,
)


/*4.Tạo bảng sản phẩm*/-------------[dbo].[Nhom]
create table SanPham
(
MaSP varchar (6) primary key,
TenSanPham nvarchar(100) NOT NULL,
SoLuongTon int NOT NULL,
GiaNhap float NOT NULL,
GiaBan float NOT NULL,
HinhAnh VARBINARY(MAX), 
MaNhomSP varchar (6) constraint fk_MaNhom foreign key (MaNhomSP)references Nhom(MaNhomSP)
)



/*5.Tạo bảng khách hàng*/----------------
create table KhachHang
(
MaKH varchar (6) primary key,
HoTenKH nvarchar(100) NOT NULL,
DiaChiKH nvarchar(100) NOT NULL,
SDTKH nvarchar(12) NOT NULL
)
go


/*11.Tạo bảng đơn hàng bán*/
create table DonHangBan
(
	MaDonBan VARCHAR(6) PRIMARY KEY,
    NgayLap DATETIME CONSTRAINT DF_NgayLap DEFAULT GETDATE() NOT NULL,
    TinhTrang NVARCHAR(30) CONSTRAINT CK_TinhTrang CHECK 
				(TinhTrang IN (N'CHỜ DUYỆT', N'ĐÃ DUYỆT')) NOT NULL,
    DiaChiGiao NVARCHAR(500) NOT NULL,
    NgayGiao DATETIME NOT NULL,
    MaNV VARCHAR(6) NOT NULL,
	MaKH VARCHAR(6) NOT NULL,
	MaCN VARCHAR(6) NOT NULL,
    GiamGia INT CONSTRAINT CK_GiamGia CHECK (GiamGia IN (0, 5, 10)) NOT NULL,
    CONSTRAINT FK_DH_MaNV FOREIGN KEY (MaNV) REFERENCES TaiKhoan(MaNV),
	CONSTRAINT FK_DH_MaKH FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH),
	CONSTRAINT FK_DH_MaCN FOREIGN KEY (MaCN) REFERENCES ChiNhanh(MaCN)
)


/*15.Tạo bảng chi tiết đơn hàng*/
create table CTDonHangBan
(
MaDonBan varchar (6) not null  ,
MaSP varchar (6) not null ,
SoLuongDat int NOT NULL,
CONSTRAINT FK_CTDH_MaDonBan FOREIGN KEY (MaDonBan) REFERENCES DonHangBan(MaDonBan),
CONSTRAINT FK_CTDH_MaSanPham FOREIGN KEY (MaSP) REFERENCES SanPham(MaSP)
)
/*. Tạo ràng buộc khóa chính của bảng chi tiết đơn hàng bán */
-----------------------------------------------------------
alter table CTDonHangBan
add constraint pk_ctdonhang primary key (MaDonBan,MaSP)
go




/*7.Tạo bảng hóa đơn*/
create table PhieuTinhTien
(
	MaPhieuTien varchar (6) primary key,
	NgayLap datetime ,
	TongTien bigint NOT NULL,
	GiamGia int not null,
	TongCong bigint NOT NULL,
	MaNV varchar (6) not null,
	MaDonBan varchar (6) not null ,
	constraint fk_HD_MaPTT foreign key (MaNV) 
				references TaiKhoan(MaNV),
	constraint fk_HD_MaDonBan foreign key (MaDonBan) 
				references DonHangBan(MaDonBan)
)


/*8.Tạo bảng chi tiết hóa đơn*/
create table CTPhieuTinhTien
(
	MaPhieuTien varchar (6) not null,
	MaSP varchar (6)  NOT NULL ,
	SoLuong int not null,
	ThanhTien float not null,
	constraint fk_ctHD_MaPhieuTien foreign key (MaPhieuTien) references PhieuTinhTien(MaPhieuTien),
	constraint fk_ctHD_MaSP foreign key (MaSP) references SanPham(MaSP),
	constraint pk_cthoadon primary key (MaPhieuTien, MaSP)
)


/*TẠO FUNCITION VÀ TRIGGER - TẠO ID TỰ ĐỘNG CHO */


---------- AUTO EMPLOYEE ID----------------
CREATE FUNCTION func_nextid
(
    @lastuserID VARCHAR(6),
    @prefix VARCHAR(3),
    @size INT
)
RETURNS VARCHAR(6)
AS
BEGIN
    IF (@lastuserID = '')
        SET @lastuserID = @prefix + REPLICATE('0', @size - LEN(@prefix));
    
    DECLARE @num_nextuserID INT, @nextuserID VARCHAR(6);
    
    SET @lastuserID = LTRIM(RTRIM(@lastuserID));
    SET @num_nextuserID = CAST(REPLACE(@lastuserID, @prefix, '') AS INT) + 1;
    SET @size = @size - LEN(@prefix);
    SET @nextuserID = @prefix + RIGHT('0000' + CAST(@num_nextuserID AS VARCHAR(6)), @size);
    
    RETURN @nextuserID;
END;
GO


------TÀI KHOẢN---------

CREATE TRIGGER tr_nextspID ON [TaiKhoan]
FOR INSERT
AS
BEGIN
    DECLARE @lastuserID VARCHAR(6), @nextuserID VARCHAR(6);

    SELECT TOP 1 @lastuserID = MaNV
    FROM [TaiKhoan]
    ORDER BY MaNV DESC;

    SET @lastuserID = ISNULL(@lastuserID, ''); -- Chắc chắn rằng @lastuserID không null

    -- Tạo mã người dùng tiếp theo
    SET @nextuserID = dbo.func_nextid(@lastuserID, 'NV', 6);

    -- Cập nhật mã người dùng mới trong bảng
    UPDATE [TaiKhoan]
    SET MaNV = @nextuserID
    WHERE MaNV = '';
END;
GO

--------- NHÓM SẢN PHẨM ---------------------
CREATE TRIGGER tr_nextnhomID ON [Nhom]
FOR INSERT
AS
BEGIN
    DECLARE @lastuserID VARCHAR(6), @nextuserID VARCHAR(6);

    SELECT TOP 1 @lastuserID = MaNhomSP
    FROM [Nhom]
    ORDER BY MaNhomSP DESC;

    SET @lastuserID = ISNULL(@lastuserID, ''); 

    -- Tạo mã người dùng tiếp theo
    SET @nextuserID = dbo.func_nextid(@lastuserID, 'gr', 6);

    -- Cập nhật mã người dùng mới trong bảng
    UPDATE [Nhom]
    SET MaNhomSP = @nextuserID
    WHERE MaNhomSP = '';
END;
GO

--------- SẢN PHẨM---------------------
CREATE TRIGGER tr_nextsanphamID ON [SanPham]
FOR INSERT
AS
BEGIN
    DECLARE @lastuserID VARCHAR(6), @nextuserID VARCHAR(6);

    SELECT TOP 1 @lastuserID = MaSP
    FROM [SanPham]
    ORDER BY MaSP DESC;

    SET @lastuserID = ISNULL(@lastuserID, ''); 

    -- Tạo mã người dùng tiếp theo
    SET @nextuserID = dbo.func_nextid(@lastuserID, 'sp', 6);

    -- Cập nhật mã người dùng mới trong bảng
    UPDATE [SanPham]
    SET MaSP = @nextuserID
    WHERE MaSP = '';
END;
GO

--------- KHÁCH HÀNG ---------------------
CREATE TRIGGER tr_nextkhID ON [KhachHang]
FOR INSERT
AS
BEGIN
    DECLARE @lastuserID VARCHAR(6), @nextuserID VARCHAR(6);

    SELECT TOP 1 @lastuserID = MaKH
    FROM [KhachHang]
    ORDER BY MaKH DESC;

    SET @lastuserID = ISNULL(@lastuserID, ''); -- Chắc chắn rằng @lastuserID không null

    -- Tạo mã người dùng tiếp theo
    SET @nextuserID = dbo.func_nextid(@lastuserID, 'KH', 6);

    -- Cập nhật mã người dùng mới trong bảng
    UPDATE [KhachHang]
    SET MaKH = @nextuserID
    WHERE MaKH = '';
END;
GO


--------- ĐƠN HÀNG BÁN ---------------------
CREATE TRIGGER tr_nextddID ON [DonHangBan]
FOR INSERT
AS
BEGIN
    DECLARE @lastuserID VARCHAR(6), @nextuserID VARCHAR(6);

    SELECT TOP 1 @lastuserID = MaDonBan
    FROM [DonHangBan]
    ORDER BY MaDonBan DESC;

    SET @lastuserID = ISNULL(@lastuserID, ''); -- Chắc chắn rằng @lastuserID không null

    -- Tạo mã người dùng tiếp theo
    SET @nextuserID = dbo.func_nextid(@lastuserID, 'DD', 6);

    -- Cập nhật mã người dùng mới trong bảng
    UPDATE [DonHangBan]
    SET MaDonBan = @nextuserID
    WHERE MaDonBan = '';
END;
GO


--------- PHIẾU TÍNH TIỀN ---------------------
CREATE TRIGGER tr_nextID_Nhom ON [PhieuTinhTien]
FOR INSERT
AS
BEGIN
    DECLARE @lastuserID VARCHAR(3), @nextuserID VARCHAR(3);

    SELECT TOP 1 @lastuserID = MaPhieuTien
    FROM [PhieuTinhTien]
    ORDER BY MaPhieuTien DESC;

    SET @lastuserID = ISNULL(@lastuserID, ''); -- Chắc chắn rằng @lastuserID không null

    -- Tạo mã người dùng tiếp theo
    SET @nextuserID = dbo.func_nextid(@lastuserID, 'PTT', 3);

    -- Cập nhật mã nhóm mới trong bảng
    UPDATE [PhieuTinhTien]
    SET MaPhieuTien = @nextuserID
    WHERE MaPhieuTien = '';
END;
GO



--------- CHI NHÁNH ---------------------
CREATE TRIGGER tr_nextID_CN ON [CHINHANH]
FOR INSERT
AS
BEGIN
    DECLARE @lastuserID VARCHAR(3), @nextuserID VARCHAR(3);

    SELECT TOP 1 @lastuserID = MaCN
    FROM [CHINHANH]
    ORDER BY MaCN DESC;

    SET @lastuserID = ISNULL(@lastuserID, ''); -- Chắc chắn rằng @lastuserID không null

    -- Tạo mã người dùng tiếp theo
    SET @nextuserID = dbo.func_nextid(@lastuserID, 'CN', 3);

    -- Cập nhật mã nhóm mới trong bảng
    UPDATE [CHINHANH]
    SET MaCN= @nextuserID
    WHERE MaCN= '';
END;
GO


	/*********************VIEW******************************/

	create view vw_DonHangBan
	as
		select MaDonBan, NgayLap, HoTenKH, HoTen, TinhTrang, 
					DiaChiGiao, NgayGiao, TenCN, GiamGia
		from DonHangBan ddh join TaiKhoan nv on ddh.MaNV = nv.MaNV
			join KhachHang kh on kh.MaKH=ddh.MaKH
			join ChiNhanh cn on cn.MaCN =  ddh.MaCN

	select * from vw_DonHangBan


	/*------------------*/
	create view vw_PhieuTinhTien
	as		
		select MaPhieuTien, PhieuTinhTien.NgayLap,TongTien,PhieuTinhTien.GiamGia,
											TongCong, DonHangBan.MaDonBan, HoTen
		from PhieuTinhTien join DonHangBan on PhieuTinhTien.MaDonBan = DonHangBan.MaDonBan
			join TaiKhoan on TaiKhoan.MaNV = PhieuTinhTien.MaNV

	select * from vw_PhieuTinhTien

/*************----------------INSERT DATA-----------------***************/
GO

INSERT [dbo].[Nhom]  VALUES ('', N'Thiết bị khí nén')
INSERT [dbo].[Nhom]  VALUES ('', N'Cảm biến, camera')
INSERT [dbo].[Nhom]  VALUES ('', N'Linh kiện robot')
INSERT [dbo].[Nhom]  VALUES ('', N'Thiết bị điều khiển')
INSERT [dbo].[Nhom]  VALUES ('', N'Dầu mỡ bôi trơn')


INSERT [dbo].[TAIKHOAN]  VALUES ('','admin','123456', N'Nguyễn Thuy Dung',N'Quản lý')
INSERT [dbo].[TAIKHOAN]  VALUES ('','lan123','123456', N'Nguyễn Ngọc Lan',N'Nhân viên bán hàng') 
INSERT [dbo].[TAIKHOAN] VALUES ('', 'bich123', '123456', N'Trần Thị Bích', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'duong123', '123456', N'Trần Thuỳ Dương', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'liem123', '123456', N'Trần Thanh Liêm', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'thuy123', '123456', N'Trần Thanh Thuý', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'lanh123', '123456', N'Trương Mỹ Lanh', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'ngoc123', '123456', N'Trương Tấn Ngọc', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'hoa123', '123456', N'Lưu Thị Mai Hoa', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'mai123', '123456', N'Lê Ngọc Mai', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'sang123', '123456', N'Lê Văn Sang', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'tinh123', '123456', N'Lê Văn Tính', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'tho123', '123456', N'Mai Thị Văn Thơ', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'manh123', '123456', N'Đào Xuân Mạnh', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'nam123', '123456', N'Võ Thu Ngọc Nam', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'tan123', '123456', N'Võ Duy Tân', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'thuong123', '123456', N'Võ Đức Thưởng', N'Nhân viên bán hàng');
INSERT [dbo].[TAIKHOAN] VALUES ('', 'phuong123', '123456', N'Võ Thị Như Phương', N'Nhân viên bán hàng');

go
GO


INSERT [dbo].[SanPham]   VALUES (N'', N'Cơ cấu và bộ điều khiển Robot CKD', 100, 32000000, 40000000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp1.png', single_blob) as image), 'gr0001')
INSERT [dbo].[SanPham]   VALUES (N'', N'Cơ cấu và bộ điều khiển Robot CKD', 104, 23000000, 30000000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp2.png', single_blob) as image), 'gr0001')
INSERT [dbo].[SanPham]   VALUES (N'',  N' Xilanh điện Robot CKD', 56, 17000000,25000000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp3.png', single_blob) as image), 'gr0001')
INSERT [dbo].[SanPham]   VALUES (N'',  N' Cơ cấu và bộ điều khiển Robot CKD', 200, 14300000,20300000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp4.png', single_blob) as image), 'gr0001')
INSERT [dbo].[SanPham]   VALUES (N'',  N' Cơ cấu và bộ điều khiển Robot CKD', 240, 13300000, 19300000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp5.png', single_blob) as image), 'gr0001')
INSERT [dbo].[SanPham]   VALUES (N'',  N' Tay Kẹp Robot', 60, 38300000, 45300000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp6.png', single_blob) as image), 'gr0001')
INSERT [dbo].[SanPham]   VALUES (N'',  N' Tay Kẹp Robot', 160, 40000000,47000000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp7.png', single_blob) as image), 'gr0002')
INSERT [dbo].[SanPham]   VALUES (N'',  N' Tay Kẹp Robot', 72, 65700000, 69700000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp8.png', single_blob) as image), 'gr0002')
INSERT [dbo].[SanPham]   VALUES (N'',  N' Tay Kẹp Song Song Robot', 69, 73400000,80400000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp9.png', single_blob) as image), 'gr0002')
INSERT [dbo].[SanPham]   VALUES (N'',  N' Mâm Cặp Robot CKD', 345, 26300000,30300000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp10.png', single_blob) as image), 'gr0002')
INSERT [dbo].[SanPham]   VALUES (N'',  N' Mâm Cặp Robot CKD', 42, 29000000, 34000000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp11.png', single_blob) as image), 'gr0002')
INSERT [dbo].[SanPham]   VALUES (N'',  N' Mâm Cặp Robot CKD', 49, 24000000, 32000000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp12.png', single_blob) as image), 'gr0002')
INSERT [dbo].[SanPham]   VALUES (N'', N' Tay Kẹp Xoay Robot CKD', 70, 38900000,44900000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp13.png', single_blob) as image), 'gr0003')
INSERT [dbo].[SanPham]   VALUES (N'',  N' Tay Kẹp Song Song Robot', 120, 44300000, 50300000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp14.png', single_blob) as image), 'gr0003')
INSERT [dbo].[SanPham]   VALUES (N'',  N'  Tay Kẹp Có Sensor Đo Khoảng Cách', 167, 69400000,73400000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp15.png', single_blob) as image), 'gr0003')
INSERT [dbo].[SanPham]   VALUES (N'', N' Tay Kẹp Song Song', 38, 59400000, 65400000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp1.png', single_blob) as image), 'gr0003')
INSERT [dbo].[SanPham]   VALUES (N'', N' Bộ điều khiển Robot ABB IRC5 – 3HAC028357-001', 58, 94300000,99300000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp2.png', single_blob) as image), 'gr0003')
INSERT [dbo].[SanPham]   VALUES (N'',  N'Bộ điều khiển Robot Fanuc R-30iA – A05B-2518-C200 ', 79, 96000000,99000000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp3.png', single_blob) as image), 'gr0003')
INSERT [dbo].[SanPham]   VALUES (N'',  N'Bộ điều khiển Robot Fanuc R-30iA – A05B-2518-C202 ', 45, 94000000,99000000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp4.png', single_blob) as image), 'gr0004')
INSERT [dbo].[SanPham]   VALUES (N'', N'Bộ điều khiển Robot Fanuc R-30iA – A05B-2518-C3042 ', 89, 93000000,99000000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp5.png', single_blob) as image), 'gr0004')
INSERT [dbo].[SanPham]   VALUES (N'', N'Bộ điều khiển Robot Kuka KRC4 – KCP4 00-168-334', 32, 91000000,97000000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp6.png', single_blob) as image), 'gr0004')
INSERT [dbo].[SanPham]   VALUES (N'', N' Bộ Nguồn Robot ABB 3HAC12928-1', 240, 2600000,3000000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp7.png', single_blob) as image), 'gr0004')
INSERT [dbo].[SanPham]   VALUES (N'', N' Bộ Pin Robot ABB 3HAC16831-1', 140, 1300000,1800000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp8.png', single_blob) as image), 'gr0004')
INSERT [dbo].[SanPham]   VALUES (N'', N' Bo Máy Tính Robot ABB 3HAC12815-11', 90, 1900000,2400000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp9.png', single_blob) as image), 'gr0004')
INSERT [dbo].[SanPham]   VALUES (N'', N' Bo Mạch Tín Hiệu Robot ABB 3HAC044168-001', 50, 2600000,3300000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp10.png', single_blob) as image), 'gr0005')
INSERT [dbo].[SanPham]   VALUES (N'',  N'Dầu máy cánh tay robot, bôi trơn và bảo trì robot FANUC.', 360, 14600000,19600000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp11.png', single_blob) as image), 'gr0005')
INSERT [dbo].[SanPham]   VALUES (N'', N' Dầu mỡ Robot ABB Kyodo Yushi TMO 150', 260, 15400000,21400000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp12.png', single_blob) as image), 'gr0005')
INSERT [dbo].[SanPham]   VALUES (N'', N' Dầu bôi trơn Robot Mobil Gear 600 XP320', 68, 15300000,22300000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp13.png', single_blob) as image), 'gr0005')
INSERT [dbo].[SanPham]   VALUES (N'', N' Robot ABB IRB 1200-5/0.9', 13, 3600000,3900000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp14.png', single_blob) as image), 'gr0005')
INSERT [dbo].[SanPham]   VALUES (N'', N' Dầu Mỡ Robot ABB 3HAC037302-001', 125, 2600000,3300000,(select* from Openrowset (bulk 'D:\01.2021010122NTDung_20DTH.TTCK\01.2021010122NTDung_20DTH.TTCK\G01NTDUNG_eSale_SamwaTek\Image\sp15.png', single_blob) as image), 'gr0005')

go


GO
INSERT INTO [dbo].[KHACHHANG]  VALUES ('', N'Lê Văn Mỹ', N'41 đường số 19, khu Phú Mỹ Hưng, P.Tân Phú, Q.7, TP.HCM', N'0838414567')
INSERT INTO[dbo].[KHACHHANG] VALUES ('', N'Phạm Việt Anh', N'1765A Đại Lộ Bình Dương, P.Hiệp An-Thủ Dầu 1, Tỉnh Bình Dương', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Bùi Thị Quỳnh Anh', N'18 Lam Sơn, P.2, Q.Tân Bình, TP.HCM', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Vũ Đức Anh', N'G4-22/1 Nguyễn Thái Học, P.7, TP.Vũng Tàu', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Nguyễn Phùng Linh Chi',  N'68 Hồ Xuân Hương, Q.Ngũ Hành Sơn.TP.Đà Nẵng', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Dương Mỹ Dung', N'Đảo Hòn Tre, Vĩnh Nguyên, Nha Trang, tình Khánh Hòa', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Nguyễn Mạnh Duy', N'23 Lê Lợi, Q.1, TP.HCM', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Phạm Phương Duy', N'Biên Hòa, Đồng Nai', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Nguyễn Thùy Dương', N'96 Võ Thị Sáu, P.Tân Định, Q.1, TP.HCM', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Lưu Minh Hằng', N'25 Nguyễn Văn Linh, khu Phú Mỹ Hưng, Q.7, TP.HCM', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Nguyễn Hữu Minh Hoàng', N'41 đường số 19, khu Phú Mỹ Hưng, P.Tân Phú, Q.7, TP.HCM', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Nguyễn Đức Huy',  N'92 Nguyễn Hữu Cảnh, P.22, Q.Bình Tân', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Vũ Đức Huy', N'P.Hòa Hải, Q.Ngũ Hành Sơn, TP.Đà Nẵng', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Nguyễn Minh Khuê', N'23 Lê Lợi, Q.1,TP.HCM', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Nguyễn Phúc Lộc', N' đường số 2, Tăng Nhơn Phú B,TP.Thủ Đức', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Trịnh Xuân Minh', N'đường số 19, Tăng Nhơn Phú B,TP.Thủ Đức', N'0838414567')
INSERT INTO[dbo].[KHACHHANG]  VALUES ('', N'Hoàng Kim Ngân', N'120 Lê Văn Việt, TP.Thủ Đức', N'0838414567')




-----Chi nhánh - CHINHANH------
INSERT INTO[dbo].[ChiNhanh]  VALUES ('', N'SamwaTek - Khánh Hoà' ,N'Đảo Hòn Tre, Vĩnh Nguyên, Nha Trang, tình Khánh Hòa' );
INSERT INTO[dbo].[ChiNhanh]  VALUES ('', N'SamwaTek - Bình Dương' , N'1765A Đại Lộ Bình Dương, P.Hiệp An-Thủ Dầu 1, Tỉnh Bình Dương' );
INSERT INTO[dbo].[ChiNhanh]  VALUES ('', N'SamwaTek - HCM' ,N'23 Lê Lợi, Q.1,TP.HCM' );
INSERT INTO[dbo].[ChiNhanh]  VALUES ('', N'SamwaTek - Đà Nẵng' ,N'68 Hồ Xuân Hương, Q.Ngũ Hành Sơn.TP.Đà Nẵng' );


/******Hoa don - cthoadon- **/

INSERT [dbo].[DonHangBan] VALUES ('',CAST(N'2023-10-05' AS Date), N'Đã duyệt',N'51/3 đường Trần Hưng Tạo -Dĩ An-Bình Dương',CAST(N'2023-10-10' AS Date),'NV0012',N'KH0002','CN1', 0);
INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2023-10-28' AS Date), N'Đã duyệt', N'123 Phan Đăng Lưu - Thành phố Hồ Chí Minh', CAST(N'2023-11-02' AS Date), 'NV0005', N'KH0008', 'CN2', 5);

INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2023-11-21' AS Date), N'Đã duyệt', N'456 Lê Văn Sỹ - Quận 3 - Thành phố Hồ Chí Minh', CAST(N'2023-11-26' AS Date), 'NV0011', N'KH0007', 'CN3', 10);
INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2023-11-28' AS Date), N'Đã duyệt', N'789 Nguyễn Thị Minh Khai - Quận 1 - Thành phố Hồ Chí Minh', CAST(N'2023-12-03' AS Date), 'NV0015', N'KH0006', 'CN4', 10);

INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2023-12-07' AS Date), N'Đã duyệt', N'321 Trường Chinh - Quận Tân Bình - Thành phố Hồ Chí Minh', CAST(N'2023-12-12' AS Date), 'NV0004', N'KH0005', 'CN1', 5);

INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-01-01' AS Date), N'Đã duyệt', N'234 Nguyễn Trãi - Quận 5 - Thành phố Hồ Chí Minh', CAST(N'2024-01-06' AS Date), 'NV0003', N'KH0001', 'CN1', 10);
INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-01-05' AS Date), N'Đã duyệt', N'51/3 đường Trần Hưng Tạo - Dĩ An - Bình Dương', CAST(N'2024-01-10' AS Date), 'NV0002', N'KH0002', 'CN2', 0);
INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-01-03' AS Date), N'Đã duyệt', N'76 Lý Tự Trọng - Quận 1 - Thành phố Hồ Chí Minh', CAST(N'2024-01-08' AS Date), 'NV0010', N'KH0016', 'CN4', 0);

INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-03-11' AS Date), N'Đã duyệt', N'123 Phan Đăng Lưu - Thành phố Hồ Chí Minh', CAST(N'2024-03-16' AS Date), 'NV0010', N'KH0008', 'CN3', 10);
INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-03-21' AS Date), N'Đã duyệt', N'456 Lê Văn Sỹ - Quận 3 - Thành phố Hồ Chí Minh', CAST(N'2024-03-26' AS Date), 'NV0006', N'KH0007', 'CN4', 5);
INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-04-14' AS Date), N'Đã duyệt', N'789 Nguyễn Thị Minh Khai - Quận 1 - Thành phố Hồ Chí Minh', CAST(N'2024-04-19' AS Date), 'NV0005', N'KH0006', 'CN4', 0);
INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-05-07' AS Date), N'Đã duyệt', N'321 Trường Chinh - Quận Tân Bình - Thành phố Hồ Chí Minh', CAST(N'2024-05-12' AS Date), 'NV0016', N'KH0005', 'CN2', 5);
INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-05-12' AS Date), N'Đã duyệt', N'234 Nguyễn Trãi - Quận 5 - Thành phố Hồ Chí Minh', CAST(N'2024-05-17' AS Date), 'NV0003', N'KH0001', 'CN3', 0);

INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-06-04' AS Date), N'Đã duyệt', N'89 Võ Thị Sáu - Quận 3 - Thành phố Hồ Chí Minh', CAST(N'2024-06-09' AS Date), 'NV0011', N'KH0012', 'CN1', 0);
INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-06-11' AS Date), N'Đã duyệt', N'120 Trần Hưng Đạo - Quận 1 - Thành phố Hồ Chí Minh', CAST(N'2024-06-16' AS Date), 'NV0008', N'KH0013', 'CN2', 5);
INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-06-18' AS Date), N'Đã duyệt', N'77 Nam Kỳ Khởi Nghĩa - Quận 1 - Thành phố Hồ Chí Minh', CAST(N'2024-06-23' AS Date), 'NV0013', N'KH0014', 'CN3', 5);
INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-06-25' AS Date), N'Đã duyệt', N'45 Lê Văn Sỹ - Quận Phú Nhuận - Thành phố Hồ Chí Minh', CAST(N'2024-06-30' AS Date), 'NV0006', N'KH0015', 'CN4', 10);

INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-07-02' AS Date), N'Đã duyệt', N'101 Nguyễn Đình Chiểu - Quận 3 - Thành phố Hồ Chí Minh', CAST(N'2024-07-07' AS Date), 'NV0014', N'KH0016', 'CN2', 0);
INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-07-09' AS Date), N'Đã duyệt', N'34 Hai Bà Trưng - Quận 1 - Thành phố Hồ Chí Minh', CAST(N'2024-07-14' AS Date), 'NV0012', N'KH0017', 'CN1', 0);
INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-07-16' AS Date), N'Đã duyệt', N'55 Điện Biên Phủ - Quận Bình Thạnh - Thành phố Hồ Chí Minh', CAST(N'2024-07-21' AS Date), 'NV0007', N'KH0007', 'CN3', 5);
INSERT [dbo].[DonHangBan] VALUES ('', CAST(N'2024-07-23' AS Date), N'Đã duyệt', N'123 Bùi Thị Xuân - Quận 1 - Thành phố Hồ Chí Minh', CAST(N'2024-07-28' AS Date), 'NV0016', N'KH0011', 'CN4', 10);


GO
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0001',N'sp0003',10)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0001',N'sp0002',9)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0002',N'sp0006',7)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0002',N'sp0004',11)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0003',N'sp0010',15)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0003',N'sp0006',5)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0004',N'sp0007',9)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0004',N'sp0003',12)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0005',N'sp0009',7)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0005',N'sp0010',5)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0006',N'sp0002',3)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0006',N'sp0008',4)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0007',N'sp0003',1)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0007',N'sp0007',2)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0008',N'sp0015',3)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0008',N'sp0022',4)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0009',N'sp0010',5)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0009',N'sp0027',5)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0010',N'sp0007',4)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0010',N'sp0003',3)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0011',N'sp0009',2)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0011',N'sp0029',1)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0012',N'sp0017',3)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0012',N'sp0013',4)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0013',N'sp0003',10)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0013',N'sp0002',9)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0013',N'sp0006',7)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0014',N'sp0004',11)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0014',N'sp0010',15)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0014',N'sp0006',5)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0014',N'sp0007',9)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0015',N'sp0003',12)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0015',N'sp0009',7)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0015',N'sp0010',5)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0015',N'sp0002',3)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0016',N'sp0008',4)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0016',N'sp0003',1)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0016',N'sp0007',2)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0017',N'sp0015',3)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0017',N'sp0022',4)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0017',N'sp0010',5)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0018',N'sp0027',5)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0018',N'sp0007',4)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0019',N'sp0003',3)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0019',N'sp0009',2)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0020',N'sp0002',3)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0020',N'sp0008',4)
INSERT [dbo].[CTDonHangBan] VALUES (N'DD0020',N'sp0003',1)

go

INSERT [dbo].[PhieuTinhTien] VALUES ('PTT001',CAST(N'2023-10-07' AS Date),'', '','',N'NV0003','DD0001');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT002',CAST(N'2023-10-29' AS Date),'','','',N'NV0003','DD0002');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT003',CAST(N'2023-11-23' AS Date),'','','',N'NV0007','DD0003');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT004',CAST(N'2023-11-29' AS Date),'','','',N'NV0005','DD0004');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT005',CAST(N'2023-12-09' AS Date),'','','',N'NV0004','DD0005');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT006',CAST(N'2024-1-03' AS Date),'','','',N'NV0003','DD0006');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT007',CAST(N'2024-1-07' AS Date),'','','',N'NV0003','DD0007');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT008',CAST(N'2024-3-13' AS Date),'','','',N'NV0007','DD0008');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT009',CAST(N'2024-3-23' AS Date),'','','',N'NV0005','DD0009');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT010',CAST(N'2024-4-16' AS Date),'','','',N'NV0004','DD0010');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT011',CAST(N'2024-5-09' AS Date),'','','',N'NV0003','DD0011');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT012',CAST(N'2024-5-14' AS Date),'','','',N'NV0003','DD0012');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT013',CAST(N'2024-6-09' AS Date),'','','',N'NV0003','DD0013');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT014',CAST(N'2024-6-16' AS Date),'','','',N'NV0003','DD0014');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT015',CAST(N'2024-6-23' AS Date),'','','',N'NV0003','DD0015');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT016',CAST(N'2024-6-30' AS Date),'','','',N'NV0003','DD0016');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT017',CAST(N'2024-7-7' AS Date),'','','',N'NV0003','DD0017');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT018',CAST(N'2024-7-14' AS Date),'','','',N'NV0003','DD0018');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT019',CAST(N'2024-7-21' AS Date),'','','',N'NV0003','DD0019');
INSERT [dbo].[PHIEUTINHTIEN] VALUES ('PTT020',CAST(N'2024-7-21' AS Date),'','','',N'NV0003','DD0020');
go



-----phân quyền---------
---	Tạo nhóm người dùng  theo chuyên môn
Create role NhanVienBanHang
Create role QuanLy

--- Cấp quyền cho nhóm người dùng 
---Nhóm người dùng là nhân viên bán hàng

grant select, insert, update, delete on DonHangBan to NhanVienBanHang
grant select, insert, update, delete  on CTDonHangBan to NhanVienBanHang
grant select, insert, update, delete on KhachHang to NhanVienBanHang
grant select, insert, update, delete on PhieuTinhTien to NhanVienBanHang
grant select, insert, update, delete on CTPhieuTinhTien to NhanVienBanHang
grant select on vw_DonHangBan to NhanVienBanHang
grant select on vw_PhieuTinhTien to NhanVienBanHang
grant select on SanPham to NhanVienBanHang
grant select on Nhom to NhanVienBanHang
grant select on ChiNhanh to NhanVienBanHang

EXEC sp_helprotect @username = 'NhanVienBanHang';


---Nhóm người dùng là quản lý
grant all to QuanLy with grant option