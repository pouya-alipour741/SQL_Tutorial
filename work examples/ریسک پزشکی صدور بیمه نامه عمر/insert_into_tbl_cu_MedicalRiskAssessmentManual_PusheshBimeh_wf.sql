USE [SamanCRM]
GO
/****** Object:  StoredProcedure [dbo].[sp_cu_insert_into_tbl_cu_MedicalRiskAssessmentManual_PusheshBimeh_wf]    Script Date: 1/1/2025 5:36:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[sp_cu_insert_into_tbl_cu_MedicalRiskAssessmentManual_PusheshBimeh_wf]
@WFID nvarchar(50),
@InsuranceCoverage nvarchar(500),
@InsuranceCoverageCost nvarchar(500)

as
	begin
			insert into MedicalRiskAssessmentManual_PusheshBimeh(WFID, Pushesh, MablaghPushesh)
			values
				(@WFID,@InsuranceCoverage, @InsuranceCoverageCost)
			--delete from MedicalRiskAssessmentManual_PusheshBimeh
			--where wfid != (select max(wfid) from MedicalRiskAssessmentManual_PusheshBimeh)
	end