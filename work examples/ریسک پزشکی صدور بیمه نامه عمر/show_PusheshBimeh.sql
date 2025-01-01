USE [SamanCRM]
GO
/****** Object:  StoredProcedure [dbo].[sp_cu_show_PusheshBimeh]    Script Date: 1/1/2025 5:38:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[sp_cu_show_PusheshBimeh]
@wfid bigint
as begin
	begin try
		select pushesh,mablaghpushesh,guid,wfid
		from MedicalRiskAssessmentManual_PusheshBimeh
		where isnull(wfid,-1) = @WFID
	end try
	begin catch
		select 1
	end catch
end