USE [SAODB]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Cu_SearchQuestionAnswer]    Script Date: 07/11/1403 09:50:55 ق.ظ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,bahreyni>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
--exec Sp_Cu_SearchQuestionAnswer @MainSubject=N'-1',@UserId=N'-1',@FromDate=N'1402/01/12',@ToDate=N'1402/02/11',@Status=N'1',@WFNumber=N'',@FollowUpCode=N'',@ExpertUserID=N'6',@WFStatus=N'-1'
-- =============================================
ALTER PROCEDURE [dbo].[Sp_Cu_SearchQuestionAnswer] --1,174,'1397/05/01','1397/06/10',2,0,''
    @MainSubject AS INT,
    @UserId AS BIGINT,
    @FromDate AS NVARCHAR(10),
    @ToDate AS NVARCHAR(10),
    @Status AS INT,
    @WFNumber AS BIGINT,
    @FollowUpCode AS NVARCHAR(50),
    @ExpertUserID AS BIGINT,
    @WFStatus AS BIGINT
AS
BEGIN
    IF @FromDate = N''
       AND @ToDate = N''
    BEGIN
        SET @FromDate =
        (
            SELECT [dbo].[fn_CU_MiladiToShamsi](GETDATE())
        );
        SET @ToDate =
        (
            SELECT [dbo].[fn_CU_MiladiToShamsi](GETDATE())
        );
    END;
    DECLARE @CountWFDoing AS INT;
    DECLARE @CountWFDone AS INT;
    IF @ExpertUserID <> -1
    BEGIN
        SET @CountWFDoing =
        (
            SELECT COUNT(*)
            FROM
            (
                SELECT
                    --(
                    --    SELECT TOP 1
                    --           Task.TblTask.UserID
                    --    FROM Task.TblTask
                    --        INNER JOIN Task.TblWorkflowActivityInstance
                    --            ON Task.TblTask.WorkflowActivityInstaceID = Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                    --    WHERE WokflowInstanceID = WFID
                    --          AND UserID = @ExpertUserID
                    --          AND TaskStatusID IN ( 1, 6 )
                    --          AND ActivityID IN ( 5215090122552527259, 5325114414053339885 )
                    --) ExpertUserID,
                    Q.sajadExpertUserID,
                    StatusID
                FROM dbo.Tbl_CU_QuestionAnswer Q
                    INNER JOIN Task.TblWorkflowInstance B
                        ON Q.WFID = B.WorkflowInstanceID
                WHERE (Q.StatusID IN ( 1500, 1501, 1502, 1510, 1571 ))
                      AND
                      (
                          @MainSubject = -1
                          OR Q.MainSubjectID = @MainSubject
                      )
                      AND Q.RegDate >= @FromDate
                      AND Q.RegDate <= @ToDate
                      AND
                      (
                          Q.WFID = @WFNumber
                          OR @WFNumber <= 0
                      )
                      AND
                      (
                          Q.FollowUpCode = @FollowUpCode
                          OR @FollowUpCode LIKE ''
                      )

                      -- AND (Q.IsAutomat = 1)
                      AND ISNULL(WFID, 0) <> 0
                      AND StatusID <> 1021
                      AND
                      (
                          @Status = -1
                          OR B.WorkflowInstanceStatusID = @Status
                      )
            ) t
            WHERE (
                      @ExpertUserID = -1
                      OR t.sajadExpertUserID = @ExpertUserID
                  )
                  AND
                  (
                      @WFStatus = -1
                      OR t.StatusID = @WFStatus
                  )
        );
        SET @CountWFDone =
        (
            SELECT COUNT(*)
            FROM
            (
                SELECT
                    --(
                    --    SELECT TOP 1
                    --           Task.TblTask.UserID
                    --    FROM Task.TblTask
                    --        INNER JOIN Task.TblWorkflowActivityInstance
                    --            ON Task.TblTask.WorkflowActivityInstaceID =Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                    --    WHERE WokflowInstanceID = WFID
                    --          AND UserID = @ExpertUserID
                    --          AND TaskStatusID = 2
                    --          AND ActivityID IN ( 5215090122552527259, 5325114414053339885 )
                    --) ExpertUserID,
                    Q.sajadExpertUserID,
                    StatusID
                FROM dbo.Tbl_CU_QuestionAnswer Q
                    INNER JOIN Task.TblWorkflowInstance B
                        ON Q.WFID = B.WorkflowInstanceID
                WHERE (Q.StatusID IN ( 1507, 1560 ))
                      AND
                      (
                          @MainSubject = -1
                          OR Q.MainSubjectID = @MainSubject
                      )
                      AND Q.RegDate >= @FromDate
                      AND Q.RegDate <= @ToDate
                      AND
                      (
                          Q.WFID = @WFNumber
                          OR @WFNumber <= 0
                      )
                      AND
                      (
                          Q.FollowUpCode = @FollowUpCode
                          OR @FollowUpCode LIKE ''
                      )

                      --   AND (Q.IsAutomat = 1)
                      AND ISNULL(WFID, 0) <> 0
                      AND StatusID <> 1021
                      AND
                      (
                          @Status = -1
                          OR B.WorkflowInstanceStatusID = @Status
                      )
            ) t
            WHERE (
                      @ExpertUserID = -1
                      OR t.sajadExpertUserID = @ExpertUserID
                  )
                  AND
                  (
                      @WFStatus = -1
                      OR t.StatusID = @WFStatus
                  )
        );
    END;
    IF @ExpertUserID <> -1
    BEGIN
        SELECT ROW_NUMBER() OVER (ORDER BY t.WfID DESC) AS NumRow,
               (
                   SELECT TOP 1
                          FullName
                   FROM Users.TblProfiles
                   WHERE Users.TblProfiles.UserId = t.sajadExpertUserID
               ) FullName,
               *,
               @CountWFDoing AS CountWFDoing,
               @CountWFDone AS CountWFDone
        FROM
        (
            SELECT Q.Id AS id,
                   Q.WFID AS WfID,
                   CASE
                       WHEN Q.MainSubjectID <> 0 THEN
                       (
                           SELECT TOP 1
                                  c.Name
                           FROM Workflow.TblWorkflow c
                           WHERE c.WorkflowId = Q.MainSubjectID
                       )
                       ELSE
                           'فراموشی رمز عبور'
                   END AS MainSubject,
                   Q.RegDate AS RegDate,
                   Q.RegTime AS RegTime,
                   CASE
                       WHEN Q.IsAutomat = 1 THEN
                       (
                           SELECT TOP 1
                                  Name + ' ' + LastName
                           FROM dbo.Tbl_Cu_ApplierProfile x
                           WHERE x.UserPortalID = Q.PortalUserID
                                 AND Q.PortalUserID != 0
                       )
                       ELSE
                   (
                       SELECT TOP 1
                              UserName
                       FROM Users.TblUsers z
                       WHERE z.UserId = Q.RegisteredUserId
                   )
                   END AS Name,
                   NationalCode,
                   Mobile,
                   Email,
                   Descript,
                   FinalDesc,
                   (CASE
                        WHEN WorkflowInstanceStatusID = 1 THEN
                     
       'درحال انجام'
                        WHEN WorkflowInstanceStatusID = 2 THEN
                            'انجام شده'
                        ELSE
                            'ابطال شده'
                    END
                   ) WorkflowInstanceStatusName,
                   (
                       SELECT TOP 1
                              Attachment
                       FROM Tbl_CU_QuestionAnswer_Attachment a
                       WHERE a.WFID = Q.WFID
                   ) Attachment,
                   (
                       SELECT TOP 1
                              LogStatusTitle
                       FROM Tbl_CU_LogStatus a
                       WHERE a.LogStatusID = Q.StatusID
                   ) LogStatusTitle,
                   (
                       SELECT TOP 1
                              CASE
                                  WHEN CHARINDEX('#', FileAttach) > 0 THEN
                                      SUBSTRING(FileAttach, 1, CHARINDEX('#', FileAttach, 1) - 1)
                                  ELSE
                                      FileAttach
                              END
                       FROM Tbl_CU_Attachments a
                       WHERE a.[Guid] = Q.GUID
                   ) fileID,
                   --(
                   --    SELECT TOP 1
                   --           Task.TblTask.UserID
                   --    FROM Task.TblTask
                   --        INNER JOIN Task.TblWorkflowActivityInstance
                   --            ON Task.TblTask.WorkflowActivityInstaceID = Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                   --    WHERE WokflowInstanceID = WFID
                   --          AND UserID = @ExpertUserID
                   --          AND ActivityID IN ( 5215090122552527259, 5325114414053339885 )
                   --) ExpertUserID,
                   Q.sajadExpertUserID,
                   'لینک پیوست' AS Link,
                   Q.StatusID,
                   (
                       SELECT TOP 1 S.WFID FROM Tbl_Cu_TazarvSupport_Log S WHERE S.WFRID = Q.WFID
                   ) AS TazarvSupport
            FROM dbo.Tbl_CU_QuestionAnswer Q
                INNER JOIN Task.TblWorkflowInstance B
                    ON Q.WFID = B.WorkflowInstanceID
            WHERE (
                      @MainSubject = -1
                      OR Q.MainSubjectID = @MainSubject
                  )
                  AND Q.RegDate >= @FromDate
                  AND Q.RegDate <= @ToDate
                  AND
                  (
                      Q.WFID = @WFNumber
                      OR @WFNumber <= 0
                  )
                  AND
                  (
                      Q.FollowUpCode = @FollowUpCode
                      OR @FollowUpCode LIKE ''
                  )

                  -- AND (Q.IsAutomat = 1)
                  AND ISNULL(WfID, 0) <> 0
                  AND StatusID <> 1021
                  AND
                  (
                      @Status = -1
                      OR B.WorkflowInstanceStatusID = @Status
                  )
        ) t
        WHERE (
                  @ExpertUserID = -1
                  OR t.sajadExpertUserID = @ExpertUserID
              )
              AND
              (
                  @WFStatus = -1
                  OR t.StatusID = @WFStatus
              )
        ORDER BY t.WfID DESC;

    END;

    ---------- کاربر پورتال
    ELSE IF (@UserId = 1)
    BEGIN
        IF (@Status = -1)
        BEGIN
            PRINT 1;
            SELECT
                (
                    SELECT TOP 1
                           FullName
                    FROM Users.TblProfiles
                    WHERE Users.TblProfiles.UserId = t.sajadExpertUserID
                ) FullName,
                *,
                @CountWFDoing AS CountWFDoing,
                @CountWFDone AS CountWFDone
            FROM
            (
                SELECT ROW_NUMBER() OVER (ORDER BY Q.Id DESC) AS NumRow,
                       Q.Id AS id,
                       Q.WFID AS WfID,
                       CASE
                           WHEN Q.MainSubjectID <> 0 THEN
                           (
                               SELECT TOP 1
                                      c.Name
                               FROM Workflow.TblWorkflow c
                               WHERE c.WorkflowId = Q.MainSubjectID
                           )
                           ELSE
                               'فراموشی رمز عبور'
                       END AS MainSubject,
                       Q.RegDate AS RegDate,
                       Q.RegTime AS RegTime,
                       CASE
                           WHEN Q.IsAutomat = 1 THEN
                           (
                               SELECT TOP 1
                                      Name + ' ' + LastName
                               FROM dbo.Tbl_Cu_ApplierProfile x
                               WHERE x.UserPortalID = Q.PortalUserID
                                     AND Q.PortalUserID != 0
                           )
                           ELSE
                       (
                           SELECT TOP 1
                                  UserName
                           FROM Users.TblUsers z
                           WHERE z.UserId = Q.RegisteredUserId
                       )
                       END AS Name,
                       NationalCode,
                       Mobile,
                       Email,
                       Descript,
                       FinalDesc,
                       (
                           SELECT TOP 1
                                  WorkflowInstanceStatusName
                           FROM Task.TblWorkflowInstanceStatus
                           WHERE Task.TblWorkflowInstanceStatus.WorkflowInstanceStatusID = B.WorkflowInstanceStatusID
                       ) WorkflowInstanceStatusName,
                       (
                           SELECT TOP 1
                                  Attachment
                           FROM Tbl_CU_QuestionAnswer_Attachment a
                           WHERE a.WFID = Q.WFID
                       ) Attachment,
                       (
                           SELECT TOP 1
                                  LogStatusTitle
                           FROM Tbl_CU_LogStatus a
                           WHERE a.LogStatusID = Q.StatusID
                       ) LogStatusTitle,
                       (
                           SELECT TOP 1
                                  CASE
                                      WHEN CHARINDEX('#', FileAttach) > 0 THEN
                                          SUBSTRING(FileAttach, 1, CHARINDEX('#', FileAttach, 1) - 1)
                                      ELSE
                                          FileAttach
                                  END
                           FROM Tbl_CU_Attachments a
                           WHERE a.[Guid] = Q.GUID
                       ) fileID,
                       --(
                       --    SELECT TOP 1
                       --           Task.TblTask.UserID
                       --    FROM Task.TblTask
                       --        INNER JOIN Task.TblWorkflowActivityInstance
                       --            ON Task.TblTask.WorkflowActivityInstaceID = Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                       --    WHERE WokflowInstanceID = WFID
                       --          AND ActivityID = 5215090122552527259
                       --) ExpertUserID,
                       Q.sajadExpertUserID,
                       'لینک پیوست' AS Link,
                       Q.StatusID,
                       (
                           SELECT TOP 1 S.WFID FROM Tbl_Cu_TazarvSupport_Log S WHERE S.WFRID = Q.WFID
                       ) AS TazarvSupport
                FROM dbo.Tbl_CU_QuestionAnswer Q
                    INNER JOIN Task.TblWorkflowInstance B
                        ON Q.WFID = B.WorkflowInstanceID
                WHERE (
                          @MainSubject = -1
                          OR Q.MainSubjectID = @MainSubject
                      )
                      AND Q.RegDate >= @FromDate
                      AND Q.RegDate <= @ToDate
                      AND
                      (
                          Q.WFID = @WFNumber
                          OR @WFNumber <= 0
                      )
                      AND
                      (
                          Q.FollowUpCode = @FollowUpCode
                          OR @FollowUpCode LIKE ''
                      )
                      AND (@Status = -1)
                      AND (Q.IsAutomat = 1)
                      AND ISNULL(WfID, 0) <> 0
                      AND StatusID <> 1021
            ) t
            WHERE (
                      @ExpertUserID = -1
                      OR t.sajadExpertUserID = @ExpertUserID
                  )
                  AND
                  (
                      @WFStatus = -1
                      OR t.StatusID = @WFStatus
                  )
            ORDER BY t.id DESC;
        END;


        --------------
        ELSE IF (@Status = 1) --در حال بررسی
        BEGIN
            PRINT 'در حال بررسی';
            SELECT
                (
                    SELECT TOP 1
                           FullName
                    FROM Users.TblProfiles
                    WHERE Users.TblProfiles.UserId = t.sajadExpertUserID
                ) FullName,
                *,
                @CountWFDoing AS CountWFDoing,
                @CountWFDone AS CountWFDone
            FROM
            (
                SELECT ROW_NUMBER() OVER (ORDER BY Q.Id DESC) AS NumRow,
                       Q.Id AS id,
                       Q.WFID AS WfID,
                       CASE
                           WHEN Q.MainSubjectID <> 0 THEN
                           (
                               SELECT TOP 1
                                      c.Name
                               FROM Workflow.TblWorkflow c
                               WHERE c.WorkflowId = Q.MainSubjectID
                           )
                           ELSE
                               'فراموشی رمز عبور'
                       END AS MainSubject,
                       Q.RegDate AS RegDate,
                       Q.RegTime AS RegTime,
                       CASE
                           WHEN Q.IsAutomat = 1 THEN
                           (
                               SELECT TOP 1
                                      Name + ' ' + LastName
                               FROM dbo.Tbl_Cu_ApplierProfile x
                               WHERE x.UserPortalID = Q.PortalUserID
                                     AND Q.PortalUserID != 0
                           )
                           ELSE
                       (
                           SELECT TOP 1
                                  UserName
                           FROM Users.TblUsers z
                           WHERE z.UserId = Q.RegisteredUserId
                       )
                       END AS Name,
                       NationalCode,
                       Mobile,
                       Email,
                       Descript,
                       FinalDesc,
                       (
                           SELECT TOP 1
                                  WorkflowInstanceStatusName
                           FROM Task.TblWorkflowInstanceStatus
                           WHERE Task.TblWorkflowInstanceStatus.WorkflowInstanceStatusID = B.WorkflowInstanceStatusID
                       ) WorkflowInstanceStatusName,
                       (
                           SELECT TOP 1
                                  Attachment
                           FROM Tbl_CU_QuestionAnswer_Attachment a
                           WHERE a.WFID = Q.WFID
                       ) Attachment,
                       (
                           SELECT TOP 1
                                  LogStatusTitle
                           FROM Tbl_CU_LogStatus a
                           WHERE a.LogStatusID = Q.StatusID
                       ) LogStatusTitle,
                       (
                           SELECT TOP 1
                                  CASE
                                      WHEN CHARINDEX('#', FileAttach) > 0 THEN
                                          SUBSTRING(FileAttach, 1, CHARINDEX('#', FileAttach, 1) - 1)
                                      ELSE
                                          FileAttach
                                  END
                           FROM Tbl_CU_Attachments a
                           WHERE a.[Guid] = Q.GUID
                       ) fileID,
                       --(
                       --    SELECT TOP 1
                       --           Task.TblTask.UserID
                       --    FROM Task.TblTask
                       --        INNER JOIN Task.TblWorkflowActivityInstance
                       --            ON Task.TblTask.WorkflowActivityInstaceID = Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                       --    WHERE WokflowInstanceID = WFID
                       --          AND ActivityID = 5215090122552527259
                       --) ExpertUserID,
                       Q.sajadExpertUserID,
                       'لینک پیوست' AS Link,
                       Q.StatusID,
                       (
                           SELECT TOP 1 S.WFID FROM Tbl_Cu_TazarvSupport_Log S WHERE S.WFRID = Q.WFID
                       ) AS TazarvSupport
                FROM dbo.Tbl_CU_QuestionAnswer Q
                    INNER JOIN Task.TblWorkflowInstance B
                        ON Q.WFID = B.WorkflowInstanceID
                WHERE (
                          @MainSubject = -1
                          OR Q.MainSubjectID = @MainSubject
                      )
                      AND Q.RegDate >= @FromDate
                      AND Q.RegDate <= @ToDate
                      AND
                      (
                          Q.WFID = @WFNumber
                          OR @WFNumber <= 0
                      )
                      AND
                      (
                          Q.FollowUpCode = @FollowUpCode
                          OR @FollowUpCode LIKE ''
                      )
                      AND (Q.StatusID NOT IN ( 998, 1507, 1560, 1021 ))
                      -- AND (Q.IsAutomat = 1)
                      AND (B.WorkflowInstanceStatusID = 1)
                      AND ISNULL(WfID, 0) <> 0
                      AND WfID NOT IN
                          (
                              SELECT WFID FROM [dbo].[Tbl_Cu_SajadDoneTaskLog]
                          )
            ) t
            WHERE (
                      @ExpertUserID = -1
                      OR t.sajadExpertUserID = @ExpertUserID
                  )
                  AND
                  (
                      @WFStatus = -1
                      OR t.StatusID = @WFStatus
                  )
            ORDER BY t.id DESC;
        END;
        -------------
        ELSE IF (@Status = 2) --خاتمه یافته
        BEGIN
            PRINT 2;
            SELECT
                (
                    SELECT TOP 1
                           FullName
                    FROM Users.TblProfiles
                    WHERE Users.TblProfiles.UserId = t.sajadExpertUserID
                ) FullName,
                *,
                @CountWFDoing AS CountWFDoing,
                @CountWFDone AS CountWFDone
            FROM
            (
                SELECT ROW_NUMBER() OVER (ORDER BY Q.Id DESC) AS NumRow,
                       Q.Id AS id,
                       Q.WFID AS WfID,
                       CASE
                           WHEN Q.MainSubjectID <> 0 THEN
                           (
                               SELECT TOP 1
                                      c.Name
                               FROM Workflow.TblWorkflow c
                               WHERE c.WorkflowId = Q.MainSubjectID
                           )
                           ELSE
                               'فراموشی رمز عبور'
                       END AS MainSubject,
                       Q.RegDate AS RegDate,
                       Q.RegTime AS RegTime,
                       CASE
                           WHEN Q.IsAutomat = 1 THEN
                           (
                               SELECT TOP 1
                                      Name + ' ' + LastName
                               FROM dbo.Tbl_Cu_ApplierProfile x
                               WHERE x.UserPortalID = Q.PortalUserID
                                     AND Q.PortalUserID != 0
                           )
                           ELSE
                       (
                           SELECT TOP 1
                                  UserName
                           FROM Users.TblUsers z
                           WHERE z.UserId = Q.RegisteredUserId
                       )
                       END AS Name,
                       NationalCode,
                       Mobile,
                       Email,
                       Descript,
                       FinalDesc,
                       (
                           SELECT TOP 1
                                  WorkflowInstanceStatusName
                           FROM Task.TblWorkflowInstanceStatus
                           WHERE Task.TblWorkflowInstanceStatus.WorkflowInstanceStatusID = B.WorkflowInstanceStatusID
                       ) WorkflowInstanceStatusName,
                       (
                           SELECT TOP 1
                                  Attachment
                           FROM Tbl_CU_QuestionAnswer_Attachment a
                           WHERE a.WFID = Q.WFID
                       ) Attachment,
                       (
                           SELECT TOP 1
                                  LogStatusTitle
                           FROM Tbl_CU_LogStatus a
                           WHERE a.LogStatusID = Q.StatusID
                       ) LogStatusTitle,
                       (
                           SELECT TOP 1
                                  CASE
                                      WHEN CHARINDEX('#', FileAttach) > 0 THEN
                                          SUBSTRING(FileAttach, 1, CHARINDEX('#', FileAttach, 1) - 1)
                                      ELSE
                                          FileAttach
                                  END
                           FROM Tbl_CU_Attachments a
                           WHERE a.[Guid] = Q.GUID
                       ) fileID,
                       --(
                       --    SELECT TOP 1
                       --           Task.TblTask.UserID
                       --    FROM Task.TblTask
                       --        INNER JOIN Task.TblWorkflowActivityInstance
                       --            ON Task.TblTask.WorkflowActivityInstaceID = Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                       --    WHERE WokflowInstanceID = WFID
                       --          AND ActivityID = 5215090122552527259
                       --) ExpertUserID,
                       Q.sajadExpertUserID,
                       'لینک پیوست' AS Link,
                       Q.StatusID,
                       (
                           SELECT TOP 1 S.WFID FROM Tbl_Cu_TazarvSupport_Log S WHERE S.WFRID = Q.WFID
                       ) AS TazarvSupport
           
     FROM dbo.Tbl_CU_QuestionAnswer Q
                    INNER JOIN Task.TblWorkflowInstance B
                        ON Q.WFID = B.WorkflowInstanceID
                WHERE (
                          @MainSubject = -1
                          OR Q.MainSubjectID = @MainSubject
                      )
                      AND Q.RegDate >= @FromDate
                      AND Q.RegDate <= @ToDate
                      AND
                      (
                          Q.WFID = @WFNumber
                          OR @WFNumber <= 0
                      )
                      AND
                      (
                          Q.FollowUpCode = @FollowUpCode
                          OR @FollowUpCode LIKE ''
                      )
                      AND (Q.StatusID IN ( 998, 1507, 1560, 1021 ))
                      --AND (Q.IsAutomat = 1)
                      AND (B.WorkflowInstanceStatusID = 2)
                      AND ISNULL(WfID, 0) <> 0
            ) t
            WHERE (
                      @ExpertUserID = -1
                      OR t.sajadExpertUserID = @ExpertUserID
                  )
                  AND
                  (
                      @WFStatus = -1
                      OR t.StatusID = @WFStatus
                  )
            ORDER BY t.id DESC;
        END;
        -------------
        ELSE IF (@Status = 3) --خاتمه یافته
        BEGIN
            PRINT 3;
            SELECT
                (
                    SELECT TOP 1
                           FullName
                    FROM Users.TblProfiles
                    WHERE Users.TblProfiles.UserId = t.sajadExpertUserID
                ) FullName,
                *,
                @CountWFDoing AS CountWFDoing,
                @CountWFDone AS CountWFDone
            FROM
            (
                SELECT ROW_NUMBER() OVER (ORDER BY Q.Id DESC) AS NumRow,
                       Q.Id AS id,
                       Q.WFID AS WfID,
                       CASE
                           WHEN Q.MainSubjectID <> 0 THEN
                           (
                               SELECT TOP 1
                                      c.Name
                               FROM Workflow.TblWorkflow c
                               WHERE c.WorkflowId = Q.MainSubjectID
                           )
                           ELSE
                               'فراموشی رمز عبور'
                       END AS MainSubject,
                       Q.RegDate AS RegDate,
                       Q.RegTime AS RegTime,
                       CASE
                           WHEN Q.IsAutomat = 1 THEN
                           (
                               SELECT TOP 1
                                      Name + ' ' + LastName
                               FROM dbo.Tbl_Cu_ApplierProfile x
                               WHERE x.UserPortalID = Q.PortalUserID
                                     AND Q.PortalUserID != 0
                           )
                           ELSE
                       (
                           SELECT TOP 1
                                  UserName
                           FROM Users.TblUsers z
                           WHERE z.UserId = Q.RegisteredUserId
                       )
                       END AS Name,
                       NationalCode,
                       Mobile,
                       Email,
                       Descript,
                       FinalDesc,
                       (
                           SELECT TOP 1
                                  WorkflowInstanceStatusName
                           FROM Task.TblWorkflowInstanceStatus
                           WHERE Task.TblWorkflowInstanceStatus.WorkflowInstanceStatusID = B.WorkflowInstanceStatusID
                       ) WorkflowInstanceStatusName,
                       (
                           SELECT TOP 1
                                 
 Attachment
                           FROM Tbl_CU_QuestionAnswer_Attachment a
                           WHERE a.WFID = Q.WFID
                       ) Attachment,
                       (
                           SELECT TOP 1
                                  LogStatusTitle
                           FROM Tbl_CU_LogStatus a
                           WHERE a.LogStatusID = Q.StatusID
                       ) LogStatusTitle,
                       (
                           SELECT TOP 1
                                  CASE
                                      WHEN CHARINDEX('#', FileAttach) > 0 THEN
                                          SUBSTRING(FileAttach, 1, CHARINDEX('#', FileAttach, 1) - 1)
                                      ELSE
                                          FileAttach
                                  END
                           FROM Tbl_CU_Attachments a
                           WHERE a.[Guid] = Q.GUID
                       ) fileID,
                       --(
                       --    SELECT TOP 1
                       --           Task.TblTask.UserID
                       --    FROM Task.TblTask
                       --        INNER JOIN Task.TblWorkflowActivityInstance
                       --            ON Task.TblTask.WorkflowActivityInstaceID = Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                       --    WHERE WokflowInstanceID = WFID
                       --          AND ActivityID = 5215090122552527259
                       --) ExpertUserID,
                       Q.sajadExpertUserID,
                       'لینک پیوست' AS Link,
                       Q.StatusID,
                       (
                           SELECT TOP 1 S.WFID FROM Tbl_Cu_TazarvSupport_Log S WHERE S.WFRID = Q.WFID
                       ) AS TazarvSupport
                FROM dbo.Tbl_CU_QuestionAnswer Q
                    INNER JOIN Task.TblWorkflowInstance B
                        ON Q.WFID = B.WorkflowInstanceID
                WHERE (
                          @MainSubject = -1
                          OR Q.MainSubjectID = @MainSubject
                      )
                      AND Q.RegDate >= @FromDate
                      AND Q.RegDate <= @ToDate
                      AND
                      (
                          Q.WFID = @WFNumber
                          OR @WFNumber <= 0
                      )
                      AND
                      (
                          Q.FollowUpCode = @FollowUpCode
                          OR @FollowUpCode LIKE ''
                      )
                      AND (B.WorkflowInstanceStatusID = 3)
                      --- AND (Q.IsAutomat = 1)
                      AND ISNULL(WfID, 0) <> 0
            ) t
            WHERE (
                      @ExpertUserID = -1
                      OR t.sajadExpertUserID = @ExpertUserID
                  )
                  AND
                  (
                      @WFStatus = -1
                      OR t.StatusID = @WFStatus
                  )
            ORDER BY t.id DESC;
        END;
    END;
    ---------- کاربر سامانه
    ELSE IF (@UserId = 2)
    BEGIN
        IF (@Status = -1)
        BEGIN
            PRINT 4;
            SELECT
                (
                    SELECT TOP 1
                           FullName
                    FROM Users.TblProfiles
                    WHERE Users.TblProfiles.UserId = t.sajadExpertUserID
                ) FullName,
                *,
                @CountWFDoing AS CountWFDoing,
                @CountWFDone AS CountWFDone
            FROM
            (
                SELECT ROW_NUMBER() OVER (ORDER BY Q.Id DESC) AS NumRow,
                       Q.Id AS id,
                       Q.WFID AS WfID,
                       CASE
                           WHEN Q.MainSubjectID <> 0 THEN
                           (
              
                 SELECT TOP 1
                                      c.Name
                               FROM Workflow.TblWorkflow c
                               WHERE c.WorkflowId = Q.MainSubjectID
                           )
                           ELSE
                               'فراموشی رمز عبور'
                       END AS MainSubject,
                       Q.RegDate AS RegDate,
                       Q.RegTime AS RegTime,
                       CASE
                           WHEN Q.IsAutomat = 1 THEN
                           (
                               SELECT TOP 1
                                      Name + ' ' + LastName
                               FROM dbo.Tbl_Cu_ApplierProfile x
                               WHERE x.UserPortalID = Q.PortalUserID
                                     AND Q.PortalUserID != 0
                           )
                           ELSE
                       (
                           SELECT TOP 1
                                  UserName
                           FROM Users.TblUsers z
                           WHERE z.UserId = Q.RegisteredUserId
                       )
                       END AS Name,
                       NationalCode,
                       Mobile,
                       Email,
                       Descript,
                       FinalDesc,
                       (
                           SELECT TOP 1
                                  WorkflowInstanceStatusName
                           FROM Task.TblWorkflowInstanceStatus
                           WHERE Task.TblWorkflowInstanceStatus.WorkflowInstanceStatusID = B.WorkflowInstanceStatusID
                       ) WorkflowInstanceStatusName,
                       (
                           SELECT TOP 1
                                  Attachment
                           FROM Tbl_CU_QuestionAnswer_Attachment a
                           WHERE a.WFID = Q.WFID
                       ) Attachment,
                       (
                           SELECT TOP 1
                                  LogStatusTitle
                           FROM Tbl_CU_LogStatus a
                           WHERE a.LogStatusID = Q.StatusID
                       ) LogStatusTitle,
                       (
                           SELECT TOP 1
                                  CASE
                                      WHEN CHARINDEX('#', FileAttach) > 0 THEN
                                          SUBSTRING(FileAttach, 1, CHARINDEX('#', FileAttach, 1) - 1)
                                      ELSE
                                          FileAttach
                                  END
                           FROM Tbl_CU_Attachments a
                           WHERE a.[Guid] = Q.GUID
                       ) fileID,
                       --(
                       --    SELECT TOP 1
                       --           Task.TblTask.UserID
                       --    FROM Task.TblTask
                       --        INNER JOIN Task.TblWorkflowActivityInstance
                       --            ON Task.TblTask.WorkflowActivityInstaceID = Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                       --    WHERE WokflowInstanceID = WFID
                       --          AND ActivityID = 5215090122552527259
                       --) ExpertUserID,
                       Q.sajadExpertUserID,
                       'لینک پیوست' AS Link,
                       Q.StatusID,
                       (
                           SELECT TOP 1 S.WFID FROM Tbl_Cu_TazarvSupport_Log S WHERE S.WFRID = Q.WFID
                       ) AS TazarvSupport
                FROM dbo.Tbl_CU_QuestionAnswer Q
                    INNER JOIN Task.TblWorkflowInstance B
                        ON Q.WFID = B.WorkflowInstanceID
                WHERE (
                          @MainSubject = -1
                         
 OR Q.MainSubjectID = @MainSubject
                      )
                      AND Q.RegDate >= @FromDate
                      AND Q.RegDate <= @ToDate
                      AND
                      (
                          Q.WFID = @WFNumber
                          OR @WFNumber <= 0
                      )
                      AND
                      (
                          Q.FollowUpCode = @FollowUpCode
                          OR @FollowUpCode LIKE ''
                      )
                      AND (@Status = -1)
                      AND (Q.IsAutomat IS NULL)
                      AND ISNULL(WfID, 0) <> 0
                      AND StatusID <> 1021
            ) t
            WHERE (
                      @ExpertUserID = -1
                      OR t.sajadExpertUserID = @ExpertUserID
                  )
                  AND
                  (
                      @WFStatus = -1
                      OR t.StatusID = @WFStatus
                  )
            ORDER BY t.id DESC;
        END;


        --------------
        ELSE IF (@Status = 1) --در حال بررسی
        BEGIN
            PRINT 5;
            SELECT
                (
                    SELECT TOP 1
                           FullName
                    FROM Users.TblProfiles
                    WHERE Users.TblProfiles.UserId = t.sajadExpertUserID
                ) FullName,
                *
            FROM
            (
                SELECT ROW_NUMBER() OVER (ORDER BY Q.Id DESC) AS NumRow,
                       Q.Id AS id,
                       Q.WFID AS WfID,
                       CASE
                           WHEN Q.MainSubjectID <> 0 THEN
                           (
                               SELECT TOP 1
                                      c.Name
                               FROM Workflow.TblWorkflow c
                               WHERE c.WorkflowId = Q.MainSubjectID
                           )
                           ELSE
                               'فراموشی رمز عبور'
                       END AS MainSubject,
                       Q.RegDate AS RegDate,
                       Q.RegTime AS RegTime,
                       CASE
                           WHEN Q.IsAutomat = 1 THEN
                           (
                               SELECT TOP 1
                                      Name + ' ' + LastName
                               FROM dbo.Tbl_Cu_ApplierProfile x
                               WHERE x.UserPortalID = Q.PortalUserID
                                     AND Q.PortalUserID != 0
                           )
                           ELSE
                       (
                           SELECT TOP 1
                                  UserName
                           FROM Users.TblUsers z
                           WHERE z.UserId = Q.RegisteredUserId
                       )
                       END AS Name,
                       NationalCode,
                       Mobile,
                       Email,
                       Descript,
                       FinalDesc,
                       (
                           SELECT TOP 1
                                  WorkflowInstanceStatusName
                           FROM Task.TblWorkflowInstanceStatus
                           WHERE Task.TblWorkflowInstanceStatus.WorkflowInstanceStatusID = B.WorkflowInstanceStatusID
                       ) WorkflowInstanceStatusName,
                       (
                           SELECT TOP 1
                                  Attachment
                           FROM Tbl_CU_QuestionAnswer_Attachment a
                           WHERE a.WFID = Q.WFID
                       ) Attachment,
                       (
                           SELECT TOP 1
                                  LogStatusTitle
                           FROM Tbl_CU_LogStatus a
                           WHERE a.LogStatusID = Q.StatusID
                       ) LogStatusTitle,
                       (
                           SELECT TOP 1
                                  CASE
                                      WHEN CHARINDEX('#', FileAttach) > 0 THEN
                                          SUBSTRING(FileAttach, 1, CHARINDEX('#', FileAttach, 1) - 1)
                                      ELSE
                                          FileAttach
                                  END
                           FROM Tbl_CU_Attachments a
                           WHERE a.[Guid] = Q.GUID
                       ) fileID,
                       --(
                       --    SELECT Task.TblTask.UserID
                       --    FROM Task.TblTask
                       --        INNER JOIN Task.TblWorkflowActivityInstance
                       --            ON Task.TblTask.WorkflowActivityInstaceID = Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                       --    WHERE WokflowInstanceID = WFID
                       --          AND ActivityID = 5215090122552527259
                       --) ExpertUserID,
                       Q.sajadExpertUserID,
                       'لینک پیوست' AS Link,
                       Q.StatusID,
                       (
                           SELECT TOP 1 S.WFID FROM Tbl_Cu_TazarvSupport_Log S WHERE S.WFRID = Q.WFID
                       ) AS TazarvSupport
                FROM dbo.Tbl_CU_QuestionAnswer Q
                    INNER JOIN Task.TblWorkflowInstance B
                        ON Q.WFID = B.WorkflowInstanceID
                WHERE (
                          @MainSubject = -1
                          OR Q.MainSubjectID = @MainSubject
                      )
                      AND Q.RegDate >= @FromDate
                      AND Q.RegDate <= @ToDate
                      AND
                      (
                          Q.WFID = @WFNumber
                          OR @WFNumber <= 0
                      )
                      AND
                      (
                          Q.FollowUpCode = @FollowUpCode
                          OR @FollowUpCode LIKE ''
                      )
                      AND (Q.StatusID NOT IN ( 998, 1507, 1560, 1021 ))
                      AND (B.WorkflowInstanceStatusID = 1)
                      AND (Q.IsAutomat IS NULL)
                      AND ISNULL(WfID, 0) <> 0
                      AND WfID NOT IN
                          (
                              SELECT WFID FROM [dbo].[Tbl_Cu_SajadDoneTaskLog]
                          )
            ) t
            WHERE (
                      @ExpertUserID = -1
                      OR t.sajadExpertUserID = @ExpertUserID
                  )
                  AND
                  (
                      @WFStatus = -1
                      OR t.StatusID = @WFStatus
                  )
            ORDER BY t.id DESC;
        END;
        -------------
        ELSE IF (@Status = 2) --خاتمه یافته
        BEGIN
            SELECT
                (
                    SELECT TOP 1
                           FullName
                    FROM Users.TblProfiles
                    WHERE Users.TblProfiles.UserId = t.sajadExpertUserID
                ) FullName,
                *
            FROM
            (
                SELECT ROW_NUMBER() OVER (ORDER BY Q.Id DESC) AS NumRow,
                       Q.Id AS id,
                       Q.WFID AS WfID,
                       CASE
                           WHEN Q.MainSubjectID <> 0 THEN
                           (
                               SELECT TOP 1
                                      c.Name
                               FROM Workflow.TblWorkflow c
                               WHERE c.WorkflowId = Q.MainSubjectID
                           )
                           ELSE
                               'فراموشی رمز عبور'
     
                  END AS MainSubject,
                       Q.RegDate AS RegDate,
                       Q.RegTime AS RegTime,
                       CASE
                           WHEN Q.IsAutomat = 1 THEN
                           (
                               SELECT TOP 1
                                      Name + ' ' + LastName
                               FROM dbo.Tbl_Cu_ApplierProfile x
                               WHERE x.UserPortalID = Q.PortalUserID
                                     AND Q.PortalUserID != 0
                           )
                           ELSE
                       (
                           SELECT TOP 1
                                  UserName
                           FROM Users.TblUsers z
                           WHERE z.UserId = Q.RegisteredUserId
                       )
                       END AS Name,
                       NationalCode,
                       Mobile,
                       Email,
                       Descript,
                       FinalDesc,
                       (
                           SELECT TOP 1
                                  WorkflowInstanceStatusName
                           FROM Task.TblWorkflowInstanceStatus
                           WHERE Task.TblWorkflowInstanceStatus.WorkflowInstanceStatusID = B.WorkflowInstanceStatusID
                       ) WorkflowInstanceStatusName,
                       (
                           SELECT TOP 1
                                  Attachment
                           FROM Tbl_CU_QuestionAnswer_Attachment a
                           WHERE a.WFID = Q.WFID
                       ) Attachment,
                       (
                           SELECT TOP 1
                                  LogStatusTitle
                           FROM Tbl_CU_LogStatus a
                           WHERE a.LogStatusID = Q.StatusID
                       ) LogStatusTitle,
                       (
                           SELECT TOP 1
                                  CASE
                                      WHEN CHARINDEX('#', FileAttach) > 0 THEN
                                          SUBSTRING(FileAttach, 1, CHARINDEX('#', FileAttach, 1) - 1)
                                      ELSE
                                          FileAttach
                                  END
                           FROM Tbl_CU_Attachments a
                           WHERE a.[Guid] = Q.GUID
                       ) fileID,
                       --(
                       --    SELECT TOP 1
                       --           Task.TblTask.UserID
                       --    FROM Task.TblTask
                       --        INNER JOIN Task.TblWorkflowActivityInstance
                       --            ON Task.TblTask.WorkflowActivityInstaceID = Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                       --    WHERE WokflowInstanceID = WFID
                       --          AND ActivityID = 5215090122552527259
                       --) ExpertUserID,
                       Q.sajadExpertUserID,
                       'لینک پیوست' AS Link,
                       Q.StatusID,
                       (
                           SELECT TOP 1 S.WFID FROM Tbl_Cu_TazarvSupport_Log S WHERE S.WFRID = Q.WFID
                       ) AS TazarvSupport
                FROM dbo.Tbl_CU_QuestionAnswer Q
                    INNER JOIN Task.TblWorkflowInstance B
                        ON Q.WFID = B.WorkflowInstanceID
                WHERE (
                          @MainSubject = -1
                          OR Q.MainSubjectID = @MainSubject
                      )
                      AND Q.RegDate >= @FromDate
                      AND Q.RegDate <= @ToDate
                      AND
                      (
                          Q.WFID = @WFNumber
                          OR @WFNumber <= 0
                      )

                      AND
                      (
                          Q.FollowUpCode = @FollowUpCode
                          OR @FollowUpCode LIKE ''
                      )
                      AND (Q.StatusID IN ( 998, 1507, 1560 ))
                      AND (Q.IsAutomat IS NULL)
                      AND (B.WorkflowInstanceStatusID = 2)
                      AND ISNULL(WfID, 0) <> 0
            ) t
            WHERE (
                      @ExpertUserID = -1
                      OR t.sajadExpertUserID = @ExpertUserID
                  )
                  AND
                  (
                      @WFStatus = -1
                      OR t.StatusID = @WFStatus
                  )
            ORDER BY t.id DESC;
        END;
        -------------
        ELSE IF (@Status = 3) --خاتمه یافته
        BEGIN
            SELECT
                (
                    SELECT TOP 1
                           FullName
                    FROM Users.TblProfiles
                    WHERE Users.TblProfiles.UserId = sajadExpertUserID
                ) FullName,
                *
            FROM
            (
                SELECT ROW_NUMBER() OVER (ORDER BY Q.Id DESC) AS NumRow,
                       Q.Id AS id,
                       Q.WFID AS WfID,
                       CASE
                           WHEN Q.MainSubjectID <> 0 THEN
                           (
                               SELECT TOP 1
                                      c.Name
                               FROM Workflow.TblWorkflow c
                               WHERE c.WorkflowId = Q.MainSubjectID
                           )
                           ELSE
                               'فراموشی رمز عبور'
                       END AS MainSubject,
                       Q.RegDate AS RegDate,
                       Q.RegTime AS RegTime,
                       CASE
                           WHEN Q.IsAutomat = 1 THEN
                           (
                               SELECT TOP 1
                                      Name + ' ' + LastName
                               FROM dbo.Tbl_Cu_ApplierProfile x
                               WHERE x.UserPortalID = Q.PortalUserID
                                     AND Q.PortalUserID != 0
                           )
                           ELSE
                       (
                           SELECT TOP 1
                                  UserName
                           FROM Users.TblUsers z
                           WHERE z.UserId = Q.RegisteredUserId
                       )
                       END AS Name,
                       NationalCode,
                       Mobile,
                       Email,
                       Descript,
                       FinalDesc,
                       (
                           SELECT TOP 1
                                  WorkflowInstanceStatusName
                           FROM Task.TblWorkflowInstanceStatus
                           WHERE Task.TblWorkflowInstanceStatus.WorkflowInstanceStatusID = B.WorkflowInstanceStatusID
                       ) WorkflowInstanceStatusName,
                       (
                           SELECT TOP 1
                                  Attachment
                           FROM Tbl_CU_QuestionAnswer_Attachment a
                           WHERE a.WFID = Q.WFID
                       ) Attachment,
                       (
                           SELECT TOP 1
                                  LogStatusTitle
                           FROM Tbl_CU_LogStatus a
                           WHERE a.LogStatusID = Q.StatusID
                       ) LogStatusTitle,
                       (
                           SELECT TOP 1
                                  CASE
                                      WHEN CHARINDEX('#', FileAttach) > 0 THEN
                                          SUBSTRING(FileAttach, 1, CHARINDEX('#', FileAttach, 1) - 1)
                                      ELSE
                                          FileAttach
                                  END
                           FROM Tbl_CU_Attachments a
                           WHERE a.[Guid] = Q.GUID
                       ) fileID,
                       --(
                       --    SELECT TOP 1
                       --           Task.TblTask.UserID
                       --    FROM Task.TblTask
                       --        INNER JOIN Task.TblWorkflowActivityInstance
                       --            ON Task.TblTask.WorkflowActivityInstaceID = Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                       --    WHERE WokflowInstanceID = WFID
                       --          AND ActivityID = 5215090122552527259
                       --) ExpertUserID,
                       Q.sajadExpertUserID,
                       'لینک پیوست' AS Link,
                       Q.StatusID,
                       (
                           SELECT TOP 1 S.WFID FROM Tbl_Cu_TazarvSupport_Log S WHERE S.WFRID = Q.WFID
                       ) AS TazarvSupport
                FROM dbo.Tbl_CU_QuestionAnswer Q
                    INNER JOIN Task.TblWorkflowInstance B
                        ON Q.WFID = B.WorkflowInstanceID
                WHERE (
                          @MainSubject = -1
                          OR Q.MainSubjectID = @MainSubject
                      )
                      AND Q.RegDate >= @FromDate
                      AND Q.RegDate <= @ToDate
                      AND
                      (
                          Q.WFID = @WFNumber
                          OR @WFNumber <= 0
                      )
                      AND
                      (
                          Q.FollowUpCode = @FollowUpCode
                          OR @FollowUpCode LIKE ''
                      )
                      AND (B.WorkflowInstanceStatusID = 3)
                      AND (Q.IsAutomat = 1)
                      AND ISNULL(WfID, 0) <> 0
            ) t
            WHERE (
                      @ExpertUserID = -1
                      OR t.sajadExpertUserID = @ExpertUserID
                  )
                  AND
                  (
                      @WFStatus = -1
                      OR t.StatusID = @WFStatus
                  )
            ORDER BY t.id DESC;
        END;
    END;
    ---------- هردو
    IF (@UserId = -1)
       AND @ExpertUserID = -1
    BEGIN
        IF (@Status = -1)
        BEGIN
            SELECT
                (
                    SELECT TOP 1
                           FullName
                    FROM Users.TblProfiles
                    WHERE Users.TblProfiles.UserId = sajadExpertUserID
                ) FullName,
                *,
                @CountWFDoing AS CountWFDoing,
                @CountWFDone AS CountWFDone
            FROM
            (
                SELECT ROW_NUMBER() OVER (ORDER BY Q.Id DESC) AS NumRow,
                       Q.Id AS id,
                       Q.WFID AS WfID,
                       CASE
                           WHEN Q.MainSubjectID <> 0 THEN
                           (
                               SELECT TOP 1
                                      c.Name
                               FROM Workflow.TblWorkflow c
                               WHERE c.WorkflowId = Q.MainSubjectID
                           )
                           ELSE
                               'فراموشی رمز عبور'
                       END AS MainSubject,
                       Q.RegDate AS RegDate,
                       Q.RegTime AS RegTime,
                       CASE
                           WHEN Q.IsAutomat = 1 THEN
                           (
                               SELECT TOP 1
                                      Name + ' ' + LastName
                               FROM dbo.Tbl_Cu_ApplierProfile x
                               WHERE x.UserPortalID = Q.PortalUserID
                                     AND Q.PortalUserID != 0
                           )
                           ELSE
                       (
                           SELECT TOP 1
                                  UserName
                           FROM Users.TblUsers z
                           WHERE z.UserId = Q.RegisteredUserId
                       )
                       END AS Name,
                       NationalCode,
                       Mobile,
                       Email,
                       Descript,
                       FinalDesc,
                       (
                           SELECT TOP 1
                                  WorkflowInstanceStatusName
                           FROM Task.TblWorkflowInstanceStatus
                           WHERE Task.TblWorkflowInstanceStatus.WorkflowInstanceStatusID = B.WorkflowInstanceStatusID
                       ) WorkflowInstanceStatusName,
                       (
                           SELECT TOP 1
                                  Attachment
                           FROM Tbl_CU_QuestionAnswer_Attachment a
                           WHERE a.WFID = Q.WFID
                       ) Attachment,
                       (
                           SELECT TOP 1
                                  LogStatusTitle
                           FROM Tbl_CU_LogStatus a
                           WHERE a.LogStatusID = Q.StatusID
                       ) LogStatusTitle,
                       (
                           SELECT TOP 1
                                  CASE
                                      WHEN CHARINDEX('#', FileAttach) > 0 THEN
                                          SUBSTRING(FileAttach, 1, CHARINDEX('#', FileAttach, 1) - 1)
                                      ELSE
                                          FileAttach
                                  END
                           FROM Tbl_CU_Attachments a
                           WHERE a.[Guid] = Q.GUID
                       ) fileID,
                       --(
                       --    SELECT TOP 1
                       --           Task.TblTask.UserID
                       --    FROM Task.TblTask
                       --        INNER JOIN Task.TblWorkflowActivityInstance
                       --            ON Task.TblTask.WorkflowActivityInstaceID = Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                       --    WHERE WokflowInstanceID = WFID
                       --          AND ActivityID = 5215090122552527259
                       --) ExpertUserID,
                       Q.sajadExpertUserID,
                       'لینک پیوست' AS Link,
                       Q.StatusID,
                       (
                           SELECT TOP 1 S.WFID FROM Tbl_Cu_TazarvSupport_Log S WHERE S.WFRID = Q.WFID
                       ) AS TazarvSupport
                FROM dbo.Tbl_CU_QuestionAnswer Q
                    INNER JOIN Task.TblWorkflowInstance B
                        ON Q.WFID = B.WorkflowInstanceID
                WHERE (
                          @MainSubject = -1
                          OR Q.MainSubjectID = @MainSubject
                      )
                      AND Q.RegDate >= @FromDate
                      AND Q.RegDate <= @ToDate
                      AND
                      (
                          Q.WFID = @WFNumber
                          OR @WFNumber <= 0
                      )
                      AND
                      (
                          Q.FollowUpCode = @FollowUpCode
                          OR @FollowUpCode LIKE ''
                      )
                      AND (@Status = -1)
                      AND ISNULL(WfID, 0) <> 0
                      AND StatusID <> 1021
            ) t
            WHERE (
                     
 @ExpertUserID = -1
                      OR t.sajadExpertUserID = @ExpertUserID
                  )
                  AND
                  (
                      @WFStatus = -1
                      OR t.StatusID = @WFStatus
                  )
            ORDER BY t.id DESC;
        END;


        --------------
        ELSE IF (@Status = 1) --در حال بررسی
        BEGIN
            SELECT
                (
                    SELECT TOP 1
                           FullName
                    FROM Users.TblProfiles
                    WHERE Users.TblProfiles.UserId = sajadExpertUserID
                ) FullName,
                *
            FROM
            (
                SELECT ROW_NUMBER() OVER (ORDER BY Q.Id DESC) AS NumRow,
                       Q.Id AS id,
                       Q.WFID AS WfID,
                       CASE
                           WHEN Q.MainSubjectID <> 0 THEN
                           (
                               SELECT TOP 1
                                      c.Name
                               FROM Workflow.TblWorkflow c
                               WHERE c.WorkflowId = Q.MainSubjectID
                           )
                           ELSE
                               'فراموشی رمز عبور'
                       END AS MainSubject,
                       Q.RegDate AS RegDate,
                       Q.RegTime AS RegTime,
                       CASE
                           WHEN Q.IsAutomat = 1 THEN
                           (
                               SELECT TOP 1
                                      Name + ' ' + LastName
                               FROM dbo.Tbl_Cu_ApplierProfile x
                               WHERE x.UserPortalID = Q.PortalUserID
                                     AND Q.PortalUserID != 0
                           )
                           ELSE
                       (
                           SELECT TOP 1
                                  UserName
                           FROM Users.TblUsers z
                           WHERE z.UserId = Q.RegisteredUserId
                       )
                       END AS Name,
                       NationalCode,
                       Mobile,
                       Email,
                       Descript,
                       FinalDesc,
                       (
                           SELECT TOP 1
                                  WorkflowInstanceStatusName
                           FROM Task.TblWorkflowInstanceStatus
                           WHERE Task.TblWorkflowInstanceStatus.WorkflowInstanceStatusID = B.WorkflowInstanceStatusID
                       ) WorkflowInstanceStatusName,
                       (
                           SELECT TOP 1
                                  Attachment
                           FROM Tbl_CU_QuestionAnswer_Attachment a
                           WHERE a.WFID = Q.WFID
                       ) Attachment,
                       (
                           SELECT TOP 1
                                  LogStatusTitle
                           FROM Tbl_CU_LogStatus a
                           WHERE a.LogStatusID = Q.StatusID
                       ) LogStatusTitle,
                       (
                           SELECT TOP 1
                                  CASE
                                      WHEN CHARINDEX('#', FileAttach) > 0 THEN
                                          SUBSTRING(FileAttach, 1, CHARINDEX('#', FileAttach, 1) - 1)
                                      ELSE
                                          FileAttach
                                  END
                           FROM Tbl_CU_Attachments a
                           WHERE a.[Guid] = Q.GUID
                       ) fileID,
                       --(
                       --    SELECT TOP 1
                       --           Task.TblTask.UserID
                       --    FROM Task.TblTask
                       --        INNER JOIN Task.TblWorkflowActivityInstance
                       --            ON Task.TblTask.WorkflowActivityInstaceID = Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                       --    WHERE WokflowInstanceID = WFID
                       --          AND ActivityID = 5215090122552527259
                       --) ExpertUserID,
                       Q.sajadExpertUserID,
                       'لینک پیوست' AS Link,
                       Q.StatusID,
                       (
                           SELECT TOP 1 S.WFID FROM Tbl_Cu_TazarvSupport_Log S WHERE S.WFRID = Q.WFID
                       ) AS TazarvSupport
                FROM dbo.Tbl_CU_QuestionAnswer Q
                    INNER JOIN Task.TblWorkflowInstance B
                        ON Q.WFID = B.WorkflowInstanceID
                WHERE (
                          @MainSubject = -1
                          OR Q.MainSubjectID = @MainSubject
                      )
                      AND Q.RegDate >= @FromDate
                      AND Q.RegDate <= @ToDate
                      AND
                      (
                          Q.WFID = @WFNumber
                          OR @WFNumber <= 0
                      )
                      AND
                      (
                          Q.FollowUpCode = @FollowUpCode
                          OR @FollowUpCode LIKE ''
                      )
                      AND (Q.StatusID NOT IN ( 998, 1507, 1560, 1021 ))
                      AND (B.WorkflowInstanceStatusID = 1)
                      AND WfID NOT IN
                          (
                              SELECT WFID FROM [dbo].[Tbl_Cu_SajadDoneTaskLog]
                          )
                      AND ISNULL(WfID, 0) <> 0
            ) t
            WHERE (
                      @ExpertUserID = -1
                      OR t.sajadExpertUserID = @ExpertUserID
                  )
                  AND
                  (
                      @WFStatus = -1
                      OR t.StatusID = @WFStatus
                  )
            ORDER BY t.id DESC;
        END;
        -------------
        ELSE IF (@Status = 2) --خاتمه یافته
        BEGIN
            SELECT
                (
                    SELECT TOP 1
                           FullName
                    FROM Users.TblProfiles
                    WHERE Users.TblProfiles.UserId = sajadExpertUserID
                ) FullName,
                *
            FROM
            (
                SELECT ROW_NUMBER() OVER (ORDER BY Q.Id DESC) AS NumRow,
                       Q.Id AS id,
                       Q.WFID AS WfID,
                       CASE
                           WHEN Q.MainSubjectID <> 0 THEN
                           (
                               SELECT TOP 1
                                      c.Name
                               FROM Workflow.TblWorkflow c
                               WHERE c.WorkflowId = Q.MainSubjectID
                           )
                           ELSE
                               'فراموشی رمز عبور'
                       END AS MainSubject,
                       Q.RegDate AS RegDate,
                       Q.RegTime AS RegTime,
                       CASE
                           WHEN Q.IsAutomat = 1 THEN
                           (
                               SELECT TOP 1
                                      Name + ' ' + LastName
                               FROM dbo.Tbl_Cu_ApplierProfile x
                               WHERE x.UserPortalID = Q.PortalUserID
                                     AND Q.PortalUserID != 0
                           )
                           ELSE
                       (
                           SELECT TOP 1
                                  UserName
                           FROM Users.TblUsers z
                 
          WHERE z.UserId = Q.RegisteredUserId
                       )
                       END AS Name,
                       NationalCode,
                       Mobile,
                       Email,
                       Descript,
                       FinalDesc,
                       (
                           SELECT TOP 1
                                  WorkflowInstanceStatusName
                           FROM Task.TblWorkflowInstanceStatus
                           WHERE Task.TblWorkflowInstanceStatus.WorkflowInstanceStatusID = B.WorkflowInstanceStatusID
                       ) WorkflowInstanceStatusName,
                       (
                           SELECT TOP 1
                                  Attachment
                           FROM Tbl_CU_QuestionAnswer_Attachment a
                           WHERE a.WFID = Q.WFID
                       ) Attachment,
                       (
                           SELECT TOP 1
                                  LogStatusTitle
                           FROM Tbl_CU_LogStatus a
                           WHERE a.LogStatusID = Q.StatusID
                       ) LogStatusTitle,
                       (
                           SELECT TOP 1
                                  CASE
                                      WHEN CHARINDEX('#', FileAttach) > 0 THEN
                                          SUBSTRING(FileAttach, 1, CHARINDEX('#', FileAttach, 1) - 1)
                                      ELSE
                                          FileAttach
                                  END
                           FROM Tbl_CU_Attachments a
                           WHERE a.[Guid] = Q.GUID
                       ) fileID,
                       --(
                       --    SELECT TOP 1
                       --           Task.TblTask.UserID
                       --    FROM Task.TblTask
                       --        INNER JOIN Task.TblWorkflowActivityInstance
                       --            ON Task.TblTask.WorkflowActivityInstaceID = Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                       --    WHERE WokflowInstanceID = WFID
                       --          AND ActivityID = 5215090122552527259
                       --) ExpertUserID,
                       Q.sajadExpertUserID,
                       'لینک پیوست' AS Link,
                       Q.StatusID,
                       (
                           SELECT TOP 1 S.WFID FROM Tbl_Cu_TazarvSupport_Log S WHERE S.WFRID = Q.WFID
                       ) AS TazarvSupport
                FROM dbo.Tbl_CU_QuestionAnswer Q
                    INNER JOIN Task.TblWorkflowInstance B
                        ON Q.WFID = B.WorkflowInstanceID
                WHERE (
                          @MainSubject = -1
                          OR Q.MainSubjectID = @MainSubject
                      )
                      AND Q.RegDate >= @FromDate
                      AND Q.RegDate <= @ToDate
                      AND
                      (
                          Q.WFID = @WFNumber
                          OR @WFNumber <= 0
                      )
                      AND
                      (
                          Q.FollowUpCode = @FollowUpCode
                          OR @FollowUpCode LIKE ''
                      )
                      AND (Q.StatusID IN ( 998, 1507, 1560, 1021 ))
                      AND (B.WorkflowInstanceStatusID = 2)
                      AND ISNULL(WfID, 0) <> 0
                      AND (B.WorkflowInstanceStatusID = 2)
            ) t
            WHERE (
                      @ExpertUserID = -1
                      OR t.sajadExpertUserID = @ExpertUserID
                  )
                  AND
                  (
                      @WFStatus = -1
                      OR t.StatusID = @WFStatus
                  )
            ORDER BY t.id DESC;
        END;
        -------------
        ELSE IF (@Status = 3) --خاتمه یافته
        BEGIN

            SELECT
                (
                    SELECT TOP 1
                           FullName
                    FROM Users.TblProfiles
                    WHERE Users.TblProfiles.UserId = sajadExpertUserID
                ) FullName,
                *
            FROM
            (
                SELECT ROW_NUMBER() OVER (ORDER BY Q.Id DESC) AS NumRow,
                       Q.Id AS id,
                       Q.WFID AS WfID,
                       CASE
                           WHEN Q.MainSubjectID <> 0 THEN
                           (
                               SELECT TOP 1
                                      c.Name
                               FROM Workflow.TblWorkflow c
                               WHERE c.WorkflowId = Q.MainSubjectID
                           )
                           ELSE
                               'فراموشی رمز عبور'
                       END AS MainSubject,
                       Q.RegDate AS RegDate,
                       Q.RegTime AS RegTime,
                       CASE
                           WHEN Q.IsAutomat = 1 THEN
                           (
                               SELECT TOP 1
                                      Name + ' ' + LastName
                               FROM dbo.Tbl_Cu_ApplierProfile x
                               WHERE x.UserPortalID = Q.PortalUserID
                                     AND Q.PortalUserID != 0
                           )
                           ELSE
                       (
                           SELECT TOP 1
                                  UserName
                           FROM Users.TblUsers z
                           WHERE z.UserId = Q.RegisteredUserId
                       )
                       END AS Name,
                       NationalCode,
                       Mobile,
                       Email,
                       Descript,
                       FinalDesc,
                       (
                           SELECT TOP 1
                                  WorkflowInstanceStatusName
                           FROM Task.TblWorkflowInstanceStatus
                           WHERE Task.TblWorkflowInstanceStatus.WorkflowInstanceStatusID = B.WorkflowInstanceStatusID
                       ) WorkflowInstanceStatusName,
                       (
                           SELECT TOP 1
                                  Attachment
                           FROM Tbl_CU_QuestionAnswer_Attachment a
                           WHERE a.WFID = Q.WFID
                       ) Attachment,
                       (
                           SELECT TOP 1
                                  LogStatusTitle
                           FROM Tbl_CU_LogStatus a
                           WHERE a.LogStatusID = Q.StatusID
                       ) LogStatusTitle,
                       (
                           SELECT TOP 1
                                  CASE
                                      WHEN CHARINDEX('#', FileAttach) > 0 THEN
                                          SUBSTRING(FileAttach, 1, CHARINDEX('#', FileAttach, 1) - 1)
                                      ELSE
                                          FileAttach
                                  END
                           FROM Tbl_CU_Attachments a
                           WHERE a.[Guid] = Q.GUID
                       ) fileID,
                       --(
                       --    SELECT TOP 1
                       --           Task.TblTask.UserID
                       --    FROM Task.TblTask
                       --        INNER JOIN Task.TblWorkflowActivityInstance
                       --            ON Task.TblTask.WorkflowActivityInstaceID = Task.TblWorkflowActivityInstance.WorkflowActivityInstanceID
                       --    WHERE WokflowInstanceID = WFID
  
                     --          AND ActivityID = 5215090122552527259
                       --) ExpertUserID,
                       Q.sajadExpertUserID,
                       'لینک پیوست' AS Link,
                       Q.StatusID,
                       (
                           SELECT TOP 1 S.WFID FROM Tbl_Cu_TazarvSupport_Log S WHERE S.WFRID = Q.WFID
                       ) AS TazarvSupport
                FROM dbo.Tbl_CU_QuestionAnswer Q
                    INNER JOIN Task.TblWorkflowInstance B
                        ON Q.WFID = B.WorkflowInstanceID
                WHERE (
                          @MainSubject = -1
                          OR Q.MainSubjectID = @MainSubject
                      )
                      AND Q.RegDate >= @FromDate
                      AND Q.RegDate <= @ToDate
                      AND
                      (
                          Q.WFID = @WFNumber
                          OR @WFNumber <= 0
                      )
                      AND
                      (
                          Q.FollowUpCode = @FollowUpCode
                          OR @FollowUpCode LIKE ''
                      )
                      AND (B.WorkflowInstanceStatusID = 3)
                      AND (Q.IsAutomat = 1)
                      AND ISNULL(WfID, 0) <> 0
            ) t
            WHERE (
                      @ExpertUserID = -1
                      OR t.sajadExpertUserID = @ExpertUserID
                  )
                  AND
                  (
                      @WFStatus = -1
                      OR t.StatusID = @WFStatus
                  )
            ORDER BY t.id DESC;
        END;
    END;
END;

