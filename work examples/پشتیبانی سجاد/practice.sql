select top 10 *  from Tbl_Cu_CommitmentCancellation_LOG
order by WFID desc

select name from Workflow.TblWorkflow
where WorkflowId = 154 

select top 100 * from Tbl_CU_FollowUpCode
where (select WorkflowID from task.TblWorkflowInstance where WorkflowInstanceID=WFID) = 154

012140210

select (select WorkflowID from task.TblWorkflowInstance where WorkflowInstanceID=  WFID) WorkflowID from Tbl_CU_FollowUpCode
where FollowUpCode='012140816';

select WorkflowID 
from Tbl_CU_FollowUpCode f
join task.TblWorkflowInstance i on f.WFID = i.WorkflowInstanceID
where FollowUpCode='012140210'


select top 100 * from Tbl_CU_FollowUpCode
where FollowUpCode='012140210'


select WFID from Tbl_CU_FollowUpCode-- order by WFID desc
where FollowUpCode='012140141'

select top 100 * from Tbl_CU_QuestionAnswer

--alter table Tbl_CU_QuestionAnswer
--add UserChosenFollowUpCode nvarchar(10)

 SELECT TOP 1000
	MainSubjectID,*
FROM dbo.Tbl_CU_QuestionAnswer
WHERE WFID = @WFID
ORDER BY Id DESC


SELECT top 1000 *
FROM dbo.Tbl_Cu_Base_ExpertWF_SaoSupport
WHERE WFID = 60 and isnull(GroupID, 0)<>0


alter table Tbl_CU_QuestionAnswer add ReferralToUni bit
alter table Tbl_CU_QuestionAnswer add Institude int
alter table Tbl_CU_QuestionAnswer add University int


select * from Tbl_CU_QuestionAnswer



select
	top 1000 *
	,(select WorkflowID from task.TblWorkflowInstance i where i.WorkflowInstanceID = f.WFID) WorkflowID
from
	Tbl_CU_FollowUpCode f
where
	FollowUpCode = '974823061'