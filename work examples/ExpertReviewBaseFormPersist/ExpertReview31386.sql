﻿--drop table if exists Tbl_Cu_Base_ExpertDes_StudentGetCertificateCode
--go
--create table Tbl_Cu_Base_ExpertDes_StudentGetCertificateCode
--(
--	ID int primary key identity(1,1),
--	Description nvarchar(1000),
--	IsActive bit,
--	RegUser nvarchar(20),
--	RegDate nvarchar(10),
--	RegTime nvarchar(5)
--)


--select * from Tbl_Cu_Base_ExpertDes_StudentGetCertificateCode



alter proc sp_cu_select_expert_frm31386
as
	begin
		select 
			ROW_NUMBER() over(order by ID) row_number,
			[ID], [Description],
			(case when [IsActive] = 1 then 'فعال' when isactive = 0 then 'غیر فعال' end) as isactive
			,[RegUser], [RegDate], [RegTime]
		from
			Tbl_Cu_Base_ExpertDes_StudentGetCertificateCode
	end


--test
--drop table if exists Tbl_Cu_Base_ExpertDes_StudentGetCertificateCodeTest
--go
--create table Tbl_Cu_Base_ExpertDes_StudentGetCertificateCodeTest
--(
--	ID int primary key identity(1,1),
--	Description nvarchar(1000),
--	IsActive bit,
--	RegUser nvarchar(20),
--	RegDate nvarchar(10),
--	RegTime nvarchar(5),
--	Test_col nvarchar(20)
--)

--select top 100 * from Tbl_Cu_Base_ExpertDes_StudentGetCertificateCodeTest


create proc sp_cu_select_expert_frm31386Test
as
	begin
		select 
			[ID], [Description], [IsActive], [RegUser], [RegDate], [RegTime], [Test_col]
		from
			Tbl_Cu_Base_ExpertDes_StudentGetCertificateCodeTest
	end

