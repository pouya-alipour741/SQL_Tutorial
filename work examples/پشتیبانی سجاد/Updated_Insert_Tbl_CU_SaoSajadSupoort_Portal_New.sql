USE [SAODB]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Insert_Tbl_CU_SaoSajadSupoort_Portal_New]    Script Date: 08/11/1403 11:25:00 ق.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Sp_Insert_Tbl_CU_SaoSajadSupoort_Portal_New] 
    @WFID AS BIGINT ,
    @StatusID AS BIGINT 

AS
    BEGIN
        SET NOCOUNT ON;
        --DECLARE @FollowUpCode AS NVARCHAR(50)= ( SELECT TOP 1
        --                                                FollowUpCode
        --                                         FROM   dbo.Tbl_CU_FollowUpCode
        --                                         WHERE  WFID = @WFID
        --                                       ) 

        DECLARE @PkFrm31548ID bigint,
		        @PortalUserID AS BIGINT ,
				@RegDate nvarchar(10),
				@RegTime nvarchar(10),
				@MainSubjectID bigint,
				@Mobile bigint,
				@Email nvarchar(100),
				@ProblemType bigint,
				@Descript nvarchar(2000),
				@NationalCode nvarchar(10),
				@ApplierUserID bigint,
				@UserChosenFollowUpCode nvarchar(10)    --update
        
		  SELECT TOP 1
                @PkFrm31548ID = frm31548Id ,
                @PortalUserID = Col_5580294098464216683 ,
                @RegDate = Col_5659690905747023735 ,
                @RegTime = Col_4622391479516633008 ,
                @MainSubjectID = Col_5591268675506701146 ,
                @Mobile = Col_5195032388036176829 ,
                @Email = Col_5072203725658548127 ,
                @ProblemType = Col_4685558585417077630 ,
                @Descript = Col_5338322824532072097 ,
                @NationalCode = col_5143704890239982122,
				@UserChosenFollowUpCode = col_5744797132753413952    --update
               
        FROM    dbo.Tbl_frm31548
        WHERE   frm31548Id IN ( SELECT top 1  PKFormID
                                FROM    Task.TblFormInstance
                                WHERE   WorkflowInstanceId = @WFID
                                        AND FormID = 31548 )
        
		set @ApplierUserID=(select ExternalUserId from users.TblMemebrShips where UserId=@PortalUserID)

        if not exists(select top 1 1 from Tbl_CU_QuestionAnswer where WFIDPortal = WFID)
		begin
        INSERT  INTO [dbo].[Tbl_CU_QuestionAnswer]
                ( RegDate ,
                  RegTime ,
                  PortalUserID ,
                  FollowUpCode ,
                  WFIDPortal ,
                  [MainSubjectID] ,
                  [Mobile] ,
                  [Email] ,
                  ProblemType ,
                  [Descript] ,
                  [StatusID] ,
                  IsAutomat ,
                  RegisteredUserId ,
                  NationalCode,
				  PriorityID,
				  PkFrm31548ID,
				  UserChosenFollowUpCode     --update
                  
		        )
                values (@RegDate,
                        @RegTime ,
                        @ApplierUserID ,
                        @WFID ,
                        @WFID ,
                        @MainSubjectID ,
                        @Mobile ,
                        @Email ,
                        @ProblemType ,
                        @Descript ,
                        @StatusID ,
                        5 ,                     
                        ( SELECT TOP 1
                                    UserID
                          FROM      Task.TblWorkflowActivityInstance
                                    INNER JOIN Task.TblTask ON TblTask.WorkflowActivityInstaceID = TblWorkflowActivityInstance.WorkflowActivityInstanceID
                          WHERE     ActivityID = 5566011793824984477
                                    AND WokflowInstanceID = @WFID
                          ORDER BY  TaskID DESC
                        ) ,
                        @NationalCode,
						5,
						@PkFrm31548ID,
						@UserChosenFollowUpCode --update
						)  
            end
			select top 1 id from Tbl_CU_QuestionAnswer where WFIDPortal=@WFID
			order by id desc
    END
