USE [JRM]
GO
/****** Object:  UserDefinedFunction [dbo].[MiladiToShamsi]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE FUNCTION [dbo].[MiladiToShamsi](@pMldDate DateTime) RETURNS NVARCHAR(10) AS BEGIN DECLARE @Sh_Y INT, 
  @Sh_M INT, 
  @Sh_D INT, 
  @TmpY INT, 
  @Leap INT, 
  @Result INT, 
  @stSD char(2), 
  @stSM char(2), 
  @Final nchar(10) if @pMldDate IS NULL RETURN '' 
Set 
  @Result = convert(
    INT, 
    convert(float, @pMldDate)
  ) if @Result <= 78 BEGIN 
Set 
  @Sh_Y = 1278 
Set 
  @Sh_M = (@Result + 10) / 30 + 10 
Set 
  @Sh_D = (@Result + 10) % 30 + 1 END ELSE BEGIN 
Set 
  @Result = @Result -78 
Set 
  @Sh_Y = 1279 while 1 = 1 BEGIN 
Set 
  @TmpY = @Sh_Y + 11 
Set 
  @TmpY = @TmpY - (@TmpY / 33) * 33 IF (@TmpY <> 32) 
  and (
    (@TmpY / 4) * 4 = @TmpY
  ) 
Set 
  @Leap = 1 ELSE 
Set 
  @Leap = 0 IF @Result <= (365 + @Leap) break 
Set 
  @Result = @Result - (365 + @Leap) 
Set 
  @Sh_Y = @Sh_Y + 1 END IF @Result <= 31 * 6 BEGIN 
Set 
  @Sh_M = (@Result -1) / 31 + 1 
Set 
  @Sh_D = (@Result -1) % 31 + 1 END ELSE BEGIN 
Set 
  @Sh_M = (
    (@Result -1) -31 * 6
  ) / 30 + 7 
Set 
  @Sh_D = (
    (@Result -1) -31 * 6
  ) % 30 + 1 END END 
Set 
  @stSM = ltrim(
    str(@Sh_M)
  ) 
Set 
  @stSD = ltrim(
    str(@Sh_D)
  ) if Len(@stSD) < 2 
Set 
  @stSD = '0' + @stSD if Len(@stSM) < 2 
Set 
  @stSM = '0' + @stSM 
Set 
  @Final = ltrim(
    str(@SH_Y)
  )+ '/' + @stSM + '/' + @stSD RETURN @Final END

GO
/****** Object:  Table [dbo].[BarnameInfo]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BarnameInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[field1] [int] NULL,
	[field2] [nvarchar](20) NULL,
	[field3] [nvarchar](50) NULL,
	[field4] [date] NULL,
	[field5] [int] NULL,
	[field6] [date] NULL,
	[field7] [date] NULL,
	[field8] [date] NULL,
	[field9] [float] NULL,
	[field10] [float] NULL,
	[field11] [int] NULL,
	[field12] [date] NULL,
	[field13] [date] NULL,
	[field14] [date] NULL,
	[field15] [date] NULL,
	[field16] [date] NULL,
	[field17] [int] NULL,
	[field18] [int] NULL,
	[field19] [nvarchar](100) NULL,
	[Deleted] [bit] NULL,
	[UserDelete] [nvarchar](50) NULL,
	[DateInsert] [datetime] NULL,
	[UserUpdate] [nvarchar](max) NULL,
	[UserCreate] [nvarchar](50) NULL,
 CONSTRAINT [PK_BarnameInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ContainerInfo]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContainerInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[field1] [int] NULL,
	[field2] [int] NULL,
	[field3] [int] NULL,
	[field4] [float] NULL,
	[field5] [float] NULL,
	[field6] [int] NULL,
	[field7] [nvarchar](20) NULL,
	[field8] [date] NULL,
	[field9] [float] NULL,
	[field10] [float] NULL,
	[field11] [float] NULL,
	[field12] [float] NULL,
	[field13] [int] NULL,
	[field14] [float] NULL,
	[field15] [int] NULL,
	[field16] [float] NULL,
	[field17] [int] NULL,
	[Deleted] [bit] NULL,
	[UserDelete] [nvarchar](50) NULL,
	[Confirmer] [nvarchar](50) NULL,
	[DateConfirm] [datetime] NULL,
	[DateInsert] [datetime] NULL,
	[UserUpdate] [nvarchar](max) NULL,
	[UserCreate] [nvarchar](50) NULL,
 CONSTRAINT [PK_ContainerInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnumParams]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnumParams](
	[Code] [int] NOT NULL,
	[CodeParent] [int] NULL,
	[Name] [nvarchar](200) NULL,
	[State] [bit] NULL,
	[OtherInfo1] [nvarchar](100) NULL,
	[OtherInfo2] [nvarchar](100) NULL,
	[OtherInfo3] [nvarchar](100) NULL,
	[OtherInfo4] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnumUsers]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnumUsers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Userid] [int] NULL,
	[CodeEnum] [int] NULL,
 CONSTRAINT [PK_EnumUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FormS]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FormS](
	[ID] [int] NOT NULL,
	[En_Name] [nvarchar](50) NULL,
	[Fa_Name] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LastNum]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LastNum](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LastID] [int] NULL,
	[TypeDoc] [int] NULL,
 CONSTRAINT [PK_LastNum] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentInfo]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[field1] [int] NULL,
	[field2] [int] NULL,
	[field3] [nvarchar](40) NULL,
	[field4] [date] NULL,
	[field5] [nvarchar](40) NULL,
	[field6] [date] NULL,
	[field7] [date] NULL,
	[field8] [float] NULL,
	[field9] [int] NULL,
	[field10] [int] NULL,
	[field11] [int] NULL,
	[field12] [int] NULL,
	[field13] [float] NULL,
	[field14] [date] NULL,
	[field15] [date] NULL,
	[field16] [int] NULL,
	[Deleted] [bit] NULL,
	[UserDelete] [nvarchar](50) NULL,
	[Confirmer] [nvarchar](50) NULL,
	[DateConfirm] [datetime] NULL,
	[DateInsert] [datetime] NULL,
	[UserUpdate] [nvarchar](max) NULL,
	[UserCreate] [nvarchar](50) NULL,
 CONSTRAINT [PK_PaymentInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PermissonUser]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PermissonUser](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FormSid] [int] NULL,
	[UserId] [int] NULL,
	[BtnDelete] [tinyint] NULL,
	[BtnEdit] [tinyint] NULL,
	[BtnExcel] [tinyint] NULL,
	[BtnPrint] [tinyint] NULL,
	[BtnNew] [tinyint] NULL,
	[BtnView] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProformaDetail]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProformaDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[HeaderId] [int] NULL,
	[field5] [int] NULL,
	[field6] [int] NULL,
	[field7] [int] NULL,
	[field8] [decimal](18, 4) NULL,
	[field9] [decimal](18, 4) NULL,
	[UserCreate] [nvarchar](50) NULL,
	[UserUpdate] [nvarchar](500) NULL,
	[Deleted] [bit] NULL,
	[UserDelete] [nvarchar](50) NULL,
	[DateInsert] [datetime] NULL,
 CONSTRAINT [PK_ProformaDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProformaHeader]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProformaHeader](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[field1] [int] NULL,
	[field2] [int] NOT NULL,
	[field3] [nvarchar](20) NULL,
	[field4] [int] NULL,
	[UserCreate] [nvarchar](50) NULL,
	[UserUpdate] [nvarchar](500) NULL,
	[Deleted] [bit] NULL,
	[UserDelete] [nvarchar](50) NULL,
	[DateInsert] [datetime] NULL,
 CONSTRAINT [PK_Proforma] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProformaOtherInfo]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProformaOtherInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[field1] [int] NULL,
	[field2] [int] NULL,
	[field3] [date] NULL,
	[field4] [date] NULL,
	[field5] [int] NULL,
	[field6] [int] NULL,
	[field7] [int] NULL,
	[field8] [int] NULL,
	[field9] [nvarchar](50) NULL,
	[field10] [date] NULL,
	[field11] [date] NULL,
	[field12] [nvarchar](50) NULL,
	[field13] [int] NULL,
	[field14] [date] NULL,
	[field15] [date] NULL,
	[field16] [int] NULL,
	[field17] [int] NULL,
	[field18] [float] NULL,
	[field19] [int] NULL,
	[field20] [nvarchar](50) NULL,
	[field21] [date] NULL,
	[field22] [nvarchar](50) NULL,
	[field23] [nvarchar](150) NULL,
	[StateProform] [int] NULL,
	[Confirmer] [nvarchar](max) NULL,
	[DateConfirm] [nvarchar](max) NULL,
	[Deleted] [bit] NULL,
	[UserDelete] [nvarchar](50) NULL,
	[DateInsert] [datetime] NULL,
	[UserUpdate] [nvarchar](max) NULL,
	[UserCreate] [nvarchar](50) NULL,
 CONSTRAINT [PK_ProformaOtherInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Rule]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rule](
	[Id] [int] NULL,
	[Name] [nvarchar](50) NULL,
	[TypeDocId] [int] NULL,
	[State] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RuleUser]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RuleUser](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[RuleId] [int] NOT NULL,
 CONSTRAINT [PK_RuleUser] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TransitInfo]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TransitInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[field1] [int] NULL,
	[field2] [int] NULL,
	[field3] [int] NULL,
	[field4] [float] NULL,
	[field5] [date] NULL,
	[field6] [date] NULL,
	[field7] [date] NULL,
	[field8] [date] NULL,
	[field9] [date] NULL,
	[field10] [nvarchar](20) NULL,
	[field11] [int] NULL,
	[field12] [date] NULL,
	[field13] [nvarchar](30) NULL,
	[field14] [nvarchar](150) NULL,
	[field15] [int] NULL,
	[field16] [int] NULL,
	[field17] [date] NULL,
	[field18] [date] NULL,
	[field19] [date] NULL,
	[field20] [date] NULL,
	[field21] [int] NULL,
	[Deleted] [bit] NULL,
	[UserDelete] [nvarchar](50) NULL,
	[Confirmer] [nvarchar](50) NULL,
	[DateConfirm] [datetime] NULL,
	[DateInsert] [datetime] NULL,
	[UserUpdate] [nvarchar](max) NULL,
	[UserCreate] [nvarchar](50) NULL,
 CONSTRAINT [PK_TransitInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 01/25/2025 2:40:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsAdmin] [bit] NOT NULL
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[BarnameInfo] ON 
GO
INSERT [dbo].[BarnameInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [field17], [field18], [field19], [Deleted], [UserDelete], [DateInsert], [UserUpdate], [UserCreate]) VALUES (1, 27002, N'123', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 21001, 22001, N'jsj', 0, NULL, CAST(N'2025-01-18T01:00:16.930' AS DateTime), N'/Admin/Admin', N'Admin')
GO
INSERT [dbo].[BarnameInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [field17], [field18], [field19], [Deleted], [UserDelete], [DateInsert], [UserUpdate], [UserCreate]) VALUES (2, 27001, N'65494', NULL, CAST(N'2025-01-21' AS Date), NULL, NULL, CAST(N'2025-01-21' AS Date), CAST(N'2025-01-21' AS Date), 6, 5, 1, CAST(N'2025-01-21' AS Date), CAST(N'2025-01-21' AS Date), CAST(N'2025-01-21' AS Date), CAST(N'2025-01-21' AS Date), NULL, 21001, 22001, N'تست محمد', 0, NULL, CAST(N'2025-01-18T01:03:27.563' AS DateTime), N'/Admin/Admin/Admin/Admin/Admin/Admin', N'Admin')
GO
INSERT [dbo].[BarnameInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [field17], [field18], [field19], [Deleted], [UserDelete], [DateInsert], [UserUpdate], [UserCreate]) VALUES (3, 27003, N'855', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, CAST(N'2025-01-25T00:29:44.010' AS DateTime), NULL, N'Admin')
GO
SET IDENTITY_INSERT [dbo].[BarnameInfo] OFF
GO
SET IDENTITY_INSERT [dbo].[ContainerInfo] ON 
GO
INSERT [dbo].[ContainerInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [field17], [Deleted], [UserDelete], [Confirmer], [DateConfirm], [DateInsert], [UserUpdate], [UserCreate]) VALUES (1, 27001, NULL, 23001, NULL, NULL, NULL, NULL, CAST(N'2025-01-24' AS Date), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, N'Admin', NULL, NULL, CAST(N'2025-01-23T01:16:39.140' AS DateTime), N'/Admin', N'Admin')
GO
INSERT [dbo].[ContainerInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [field17], [Deleted], [UserDelete], [Confirmer], [DateConfirm], [DateInsert], [UserUpdate], [UserCreate]) VALUES (2, 27001, 65494, 23001, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, CAST(N'2025-01-23T01:31:19.137' AS DateTime), NULL, N'Admin')
GO
INSERT [dbo].[ContainerInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [field17], [Deleted], [UserDelete], [Confirmer], [DateConfirm], [DateInsert], [UserUpdate], [UserCreate]) VALUES (3, 27001, 65494, 23001, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, CAST(N'2025-01-23T01:53:48.553' AS DateTime), N'/Admin', N'Admin')
GO
INSERT [dbo].[ContainerInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [field17], [Deleted], [UserDelete], [Confirmer], [DateConfirm], [DateInsert], [UserUpdate], [UserCreate]) VALUES (4, 27002, 123, 23001, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, CAST(N'2025-01-23T01:56:27.820' AS DateTime), NULL, N'Admin')
GO
INSERT [dbo].[ContainerInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [field17], [Deleted], [UserDelete], [Confirmer], [DateConfirm], [DateInsert], [UserUpdate], [UserCreate]) VALUES (5, 27002, 123, 23001, 1, 2, 3, N'5', CAST(N'2025-01-22' AS Date), 6, 7, 8, 9, 10, 11, 12, 13, 14, 0, NULL, NULL, NULL, CAST(N'2025-01-23T02:02:41.767' AS DateTime), N'/Admin/Admin/Admin/Admin', N'Admin')
GO
INSERT [dbo].[ContainerInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [field17], [Deleted], [UserDelete], [Confirmer], [DateConfirm], [DateInsert], [UserUpdate], [UserCreate]) VALUES (6, 27003, 855, 23001, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, CAST(N'2025-01-25T00:29:57.560' AS DateTime), NULL, N'Admin')
GO
SET IDENTITY_INSERT [dbo].[ContainerInfo] OFF
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (10, 0, N'نام شرکت داخلی', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (11, 0, N'نام کالا', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (12, 0, N'طرف حساب خارجی', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (13, 0, N'واحد اندازه گیری', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (14, 0, N'نوع ارز', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (15, 0, N'نوع حمل', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (16, 0, N'اینکوترمز', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (17, 0, N'کشور', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (18, 0, N'گروه کالا', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (19, 0, N'شرکت بیمه', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (20, 0, N'بانک عامل ', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (21, 0, N'ترخیص کار', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (22, 0, N'شرکت کشتیرانی ', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (23, 0, N'نوع کانیتنر', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (24, 0, N'وسیله نقلیه', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (25, 0, N'انبار', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (26, 0, N'شرکت حمل و نقل', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (27, 0, N'شماره پروژه (پرفرما)', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (28, 0, N'منبع تامین ارز ', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (11001, 11, N'کاغذ فلان', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (12001, 12, N'طرف خارجی', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (13001, 13, N'کیلوگرم', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (13002, 13, N'عدد', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (13003, 13, N'متر', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (14001, 14, N'دلار', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (14002, 14, N'یورو', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (14003, 14, N'یوان', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (15001, 15, N'نوع حمل', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (16001, 16, N'اینکومترز', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (17001, 17, N'دبی', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (17002, 17, N'ایران', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (18001, 18, N'گروه گوشت', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (18002, 18, N'گروه کاغذ', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (19001, 19, N'شرکت بیمه', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (27002, 27, N'4002', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (29, 0, N'وضعیت پروژه ها', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (30, 0, N'شهر مقصد حمل
', 1, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (10003, 10, N'تستس', 0, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (10001, 10, N'شرکت مبین', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (30001, 30, N'شهر مقصد', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (20001, 20, N'بانک سامان', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (10002, 10, N'نگین', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (27003, 27, N'4003', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (29001, 29, N'پیش نویس', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (29002, 29, N'تایید کارشناس', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (21001, 21, N'ترخیص کار', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (22001, 22, N'کشتیرانی', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (23001, 23, N'کانتینر 10 فوت', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (24001, 24, N'کامیون', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (25001, 25, N'انبار وحدت', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (26001, 26, N'شرکت حمل ممد', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (27001, 27, N'4001', 1, N'', N'', N'', N'')
GO
INSERT [dbo].[EnumParams] ([Code], [CodeParent], [Name], [State], [OtherInfo1], [OtherInfo2], [OtherInfo3], [OtherInfo4]) VALUES (28001, 28, N'هالک', 1, N'', N'', N'', N'')
GO
SET IDENTITY_INSERT [dbo].[EnumUsers] ON 
GO
INSERT [dbo].[EnumUsers] ([Id], [Userid], [CodeEnum]) VALUES (6, 1, 10001)
GO
INSERT [dbo].[EnumUsers] ([Id], [Userid], [CodeEnum]) VALUES (7, 1, 10002)
GO
INSERT [dbo].[EnumUsers] ([Id], [Userid], [CodeEnum]) VALUES (8, 1, 27002)
GO
INSERT [dbo].[EnumUsers] ([Id], [Userid], [CodeEnum]) VALUES (9, 1, 27003)
GO
INSERT [dbo].[EnumUsers] ([Id], [Userid], [CodeEnum]) VALUES (10, 1, 27001)
GO
SET IDENTITY_INSERT [dbo].[EnumUsers] OFF
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (10, N'FormBasicData', N'نام شرکت داخلی')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (11, N'FormBasicData', N'نام کالا')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (12, N'FormBasicData', N'طرف حساب خارجی')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (13, N'FormBasicData', N'واحد اندازه گیری')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (14, N'FormBasicData', N'نوع ارز')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (15, N'FormBasicData', N'نوع حمل')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (16, N'FormBasicData', N'اینکوترمز')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (17, N'FormBasicData', N'کشور')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (18, N'FormBasicData', N'گروه کالا')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (19, N'FormBasicData', N'شرکت بیمه')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (20, N'FormBasicData', N'بانک عامل ')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (21, N'FormBasicData', N'ترخیص کار')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (22, N'FormBasicData', N'شرکت کشتیرانی ')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (23, N'FormBasicData', N'نوع کانیتنر')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (24, N'FormBasicData', N'وسیله نقلیه')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (25, N'FormBasicData', N'انبار')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (26, N'FormBasicData', N'شرکت حمل و نقل')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (27, N'FormBasicData', N'شماره پروژه (پرفرما)')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (28, N'FormBasicData', N'منبع تامین ارز ')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (29, N'FormBasicData', N'وضعیت پروژه')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (100, N'Formproformainfo', N'ایجاد پروژه جدید')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (101, N'FormProformaOtherInfo', N'اطلاعات تکمیلی پروژه')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (102, N'FormBarnameInfo', N'بارنامه وکوتاژ')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (103, N'FormContainerInfo', N'مشخصات کانتینرها')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (104, N'FormTransitInfo', N'اطلاعات حمل')
GO
INSERT [dbo].[FormS] ([ID], [En_Name], [Fa_Name]) VALUES (105, N'FormPaymentInfo', N'اطلاعات پرداخت')
GO
SET IDENTITY_INSERT [dbo].[PaymentInfo] ON 
GO
INSERT [dbo].[PaymentInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [Deleted], [UserDelete], [Confirmer], [DateConfirm], [DateInsert], [UserUpdate], [UserCreate]) VALUES (1, 27002, 123, N'6546huh76', CAST(N'2025-01-20' AS Date), N'98', CAST(N'2025-01-21' AS Date), CAST(N'2025-01-20' AS Date), 251100.25, 14001, 14001, 28001, 20001, 65646464, CAST(N'2025-01-21' AS Date), CAST(N'2025-01-20' AS Date), 12001, 0, NULL, NULL, NULL, CAST(N'2025-01-20T21:10:12.760' AS DateTime), N'/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin', N'Admin')
GO
INSERT [dbo].[PaymentInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [Deleted], [UserDelete], [Confirmer], [DateConfirm], [DateInsert], [UserUpdate], [UserCreate]) VALUES (2, 27002, NULL, N'5466', CAST(N'2025-01-22' AS Date), NULL, CAST(N'2025-01-22' AS Date), CAST(N'2025-01-22' AS Date), 1000, 14002, 14002, 28001, 20001, NULL, CAST(N'2025-01-22' AS Date), CAST(N'2025-01-22' AS Date), 12001, 0, NULL, NULL, NULL, CAST(N'2025-01-23T01:20:40.037' AS DateTime), N'/Admin/Admin/Admin/Admin', N'Admin')
GO
SET IDENTITY_INSERT [dbo].[PaymentInfo] OFF
GO
SET IDENTITY_INSERT [dbo].[PermissonUser] ON 
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (1, 10, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (2, 11, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (3, 12, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (4, 13, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (5, 14, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (6, 15, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (7, 16, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (20, 29, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (21, 29, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (22, 30, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (23, 100, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (24, 101, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (8, 17, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (9, 18, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (10, 19, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (11, 20, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (12, 21, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (13, 22, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (14, 23, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (15, 24, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (16, 25, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (17, 26, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (18, 27, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (19, 28, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (25, 102, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (26, 103, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (27, 104, 1, 1, 1, 1, 1, 1, 1)
GO
INSERT [dbo].[PermissonUser] ([Id], [FormSid], [UserId], [BtnDelete], [BtnEdit], [BtnExcel], [BtnPrint], [BtnNew], [BtnView]) VALUES (28, 105, 1, 1, 1, 1, 1, 1, 1)
GO
SET IDENTITY_INSERT [dbo].[PermissonUser] OFF
GO
SET IDENTITY_INSERT [dbo].[ProformaDetail] ON 
GO
INSERT [dbo].[ProformaDetail] ([Id], [HeaderId], [field5], [field6], [field7], [field8], [field9], [UserCreate], [UserUpdate], [Deleted], [UserDelete], [DateInsert]) VALUES (1, 3, 11001, 13002, 14001, CAST(60000.0000 AS Decimal(18, 4)), CAST(50.0000 AS Decimal(18, 4)), N'Admin', N'/Admin/Admin/Admin/Admin/Admin/Admin', 1, N'Admin', CAST(N'2025-01-16T17:52:40.177' AS DateTime))
GO
INSERT [dbo].[ProformaDetail] ([Id], [HeaderId], [field5], [field6], [field7], [field8], [field9], [UserCreate], [UserUpdate], [Deleted], [UserDelete], [DateInsert]) VALUES (2, 3, 11001, 13001, 14002, CAST(20.0000 AS Decimal(18, 4)), CAST(100.0000 AS Decimal(18, 4)), N'Admin', N'/Admin/Admin/Admin', 1, N'Admin', CAST(N'2025-01-16T17:57:26.580' AS DateTime))
GO
INSERT [dbo].[ProformaDetail] ([Id], [HeaderId], [field5], [field6], [field7], [field8], [field9], [UserCreate], [UserUpdate], [Deleted], [UserDelete], [DateInsert]) VALUES (3, 5, 11001, 13002, 14002, CAST(2.0000 AS Decimal(18, 4)), CAST(3.0000 AS Decimal(18, 4)), N'Admin', N'/Admin/Admin', 0, NULL, CAST(N'2025-01-17T10:05:30.333' AS DateTime))
GO
INSERT [dbo].[ProformaDetail] ([Id], [HeaderId], [field5], [field6], [field7], [field8], [field9], [UserCreate], [UserUpdate], [Deleted], [UserDelete], [DateInsert]) VALUES (4, 10, 11001, 13002, 14001, CAST(100.0000 AS Decimal(18, 4)), CAST(65000.0000 AS Decimal(18, 4)), N'Admin', N'/Admin', 0, NULL, CAST(N'2025-01-20T21:38:47.313' AS DateTime))
GO
INSERT [dbo].[ProformaDetail] ([Id], [HeaderId], [field5], [field6], [field7], [field8], [field9], [UserCreate], [UserUpdate], [Deleted], [UserDelete], [DateInsert]) VALUES (5, 3, 11001, 13001, 14001, CAST(1.0000 AS Decimal(18, 4)), CAST(2.0000 AS Decimal(18, 4)), N'Admin', NULL, 1, N'Admin', CAST(N'2025-01-20T23:00:25.523' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[ProformaDetail] OFF
GO
SET IDENTITY_INSERT [dbo].[ProformaHeader] ON 
GO
INSERT [dbo].[ProformaHeader] ([Id], [field1], [field2], [field3], [field4], [UserCreate], [UserUpdate], [Deleted], [UserDelete], [DateInsert]) VALUES (3, 10001, 27001, N'5464505', 12001, N'Admin', N'/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin', 1, N'Admin', CAST(N'2025-01-16T17:52:28.947' AS DateTime))
GO
INSERT [dbo].[ProformaHeader] ([Id], [field1], [field2], [field3], [field4], [UserCreate], [UserUpdate], [Deleted], [UserDelete], [DateInsert]) VALUES (5, 10001, 27003, N'568650', 12001, N'Admin', N'/Admin', 0, NULL, CAST(N'2025-01-17T10:05:08.553' AS DateTime))
GO
INSERT [dbo].[ProformaHeader] ([Id], [field1], [field2], [field3], [field4], [UserCreate], [UserUpdate], [Deleted], [UserDelete], [DateInsert]) VALUES (10, 10002, 27002, N'', 12001, N'Admin', N'/Admin', 0, NULL, CAST(N'2025-01-20T21:38:32.753' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[ProformaHeader] OFF
GO
SET IDENTITY_INSERT [dbo].[ProformaOtherInfo] ON 
GO
INSERT [dbo].[ProformaOtherInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [field17], [field18], [field19], [field20], [field21], [field22], [field23], [StateProform], [Confirmer], [DateConfirm], [Deleted], [UserDelete], [DateInsert], [UserUpdate], [UserCreate]) VALUES (1, 27001, 15001, NULL, NULL, 16001, 17002, 17002, 18002, NULL, NULL, NULL, NULL, 19001, NULL, NULL, 20001, 17002, NULL, 14002, N'564', NULL, NULL, NULL, 29001, NULL, NULL, 0, NULL, CAST(N'2025-01-17T14:15:17.857' AS DateTime), N'/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin/Admin', N'/Admin')
GO
INSERT [dbo].[ProformaOtherInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [field17], [field18], [field19], [field20], [field21], [field22], [field23], [StateProform], [Confirmer], [DateConfirm], [Deleted], [UserDelete], [DateInsert], [UserUpdate], [UserCreate]) VALUES (2, 27002, 15001, NULL, NULL, NULL, 17001, 17002, 18001, N'32121020', NULL, NULL, N'6546', 19001, NULL, NULL, 20001, 17001, 3654123, 14002, N'86', NULL, NULL, NULL, 29002, NULL, NULL, 0, NULL, CAST(N'2025-01-17T14:15:39.897' AS DateTime), N'/Admin/Admin/Admin/Admin', N'/Admin')
GO
INSERT [dbo].[ProformaOtherInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [field17], [field18], [field19], [field20], [field21], [field22], [field23], [StateProform], [Confirmer], [DateConfirm], [Deleted], [UserDelete], [DateInsert], [UserUpdate], [UserCreate]) VALUES (14, 27003, 15001, CAST(N'2025-01-21' AS Date), CAST(N'2025-01-21' AS Date), 16001, 17002, 17001, 18002, NULL, CAST(N'2025-01-21' AS Date), CAST(N'2025-01-21' AS Date), NULL, NULL, CAST(N'2025-01-21' AS Date), CAST(N'2025-01-21' AS Date), NULL, NULL, NULL, NULL, NULL, CAST(N'2025-01-21' AS Date), N'1403/11/02', N'1403/11/02', 29001, NULL, NULL, 0, NULL, CAST(N'2025-01-22T23:57:54.597' AS DateTime), N'/Admin/Admin/Admin/Admin', N'Admin')
GO
SET IDENTITY_INSERT [dbo].[ProformaOtherInfo] OFF
GO
SET IDENTITY_INSERT [dbo].[TransitInfo] ON 
GO
INSERT [dbo].[TransitInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [field17], [field18], [field19], [field20], [field21], [Deleted], [UserDelete], [Confirmer], [DateConfirm], [DateInsert], [UserUpdate], [UserCreate]) VALUES (3, 27002, 123, 5, NULL, CAST(N'2025-01-22' AS Date), CAST(N'2025-01-22' AS Date), CAST(N'2025-01-22' AS Date), CAST(N'2025-01-22' AS Date), CAST(N'2025-01-22' AS Date), N'46564ببذ646', 30001, CAST(N'2025-01-22' AS Date), N'09123649986', N'علي', 24001, 25001, CAST(N'2025-01-22' AS Date), CAST(N'2025-01-24' AS Date), CAST(N'2025-01-24' AS Date), CAST(N'2025-01-24' AS Date), 25001, 0, NULL, NULL, NULL, CAST(N'2025-01-23T01:19:58.357' AS DateTime), N'/Admin/Admin/Admin/Admin/Admin/Admin/Admin', N'Admin')
GO
INSERT [dbo].[TransitInfo] ([Id], [field1], [field2], [field3], [field4], [field5], [field6], [field7], [field8], [field9], [field10], [field11], [field12], [field13], [field14], [field15], [field16], [field17], [field18], [field19], [field20], [field21], [Deleted], [UserDelete], [Confirmer], [DateConfirm], [DateInsert], [UserUpdate], [UserCreate]) VALUES (4, 27002, 123, 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, CAST(N'2025-01-25T00:46:13.217' AS DateTime), NULL, N'Admin')
GO
SET IDENTITY_INSERT [dbo].[TransitInfo] OFF
GO
SET IDENTITY_INSERT [dbo].[Users] ON 
GO
INSERT [dbo].[Users] ([UserID], [UserName], [Password], [IsActive], [IsAdmin]) VALUES (1, N'Admin', N'1', 1, 1)
GO
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
ALTER TABLE [dbo].[BarnameInfo] ADD  CONSTRAINT [DF_BarnameInfo_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[BarnameInfo] ADD  CONSTRAINT [DF_BarnameInfo_DateInsert]  DEFAULT (getdate()) FOR [DateInsert]
GO
ALTER TABLE [dbo].[ContainerInfo] ADD  CONSTRAINT [DF_ContainerInfo_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[ContainerInfo] ADD  CONSTRAINT [DF_ContainerInfo_DateInsert]  DEFAULT (getdate()) FOR [DateInsert]
GO
ALTER TABLE [dbo].[EnumParams] ADD  CONSTRAINT [DF_EnumParams_State]  DEFAULT ((1)) FOR [State]
GO
ALTER TABLE [dbo].[PaymentInfo] ADD  CONSTRAINT [DF_PaymentInfo_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[PaymentInfo] ADD  CONSTRAINT [DF_PaymentInfo_DateInsert]  DEFAULT (getdate()) FOR [DateInsert]
GO
ALTER TABLE [dbo].[ProformaDetail] ADD  CONSTRAINT [DF_ProformaDetail_DateInsert]  DEFAULT (getdate()) FOR [DateInsert]
GO
ALTER TABLE [dbo].[ProformaHeader] ADD  CONSTRAINT [DF_ProformaHeader_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[ProformaHeader] ADD  CONSTRAINT [DF_ProformaHeader_DateInsert]  DEFAULT (getdate()) FOR [DateInsert]
GO
ALTER TABLE [dbo].[ProformaOtherInfo] ADD  CONSTRAINT [DF_ProformaOtherInfo_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[ProformaOtherInfo] ADD  CONSTRAINT [DF_ProformaOtherInfo_DateInsert]  DEFAULT (getdate()) FOR [DateInsert]
GO
ALTER TABLE [dbo].[TransitInfo] ADD  CONSTRAINT [DF_TransitInfo_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[TransitInfo] ADD  CONSTRAINT [DF_TransitInfo_DateInsert]  DEFAULT (getdate()) FOR [DateInsert]
GO
ALTER TABLE [dbo].[ProformaDetail]  WITH CHECK ADD  CONSTRAINT [FK_ProformaDetail_ProformaHeader] FOREIGN KEY([HeaderId])
REFERENCES [dbo].[ProformaHeader] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ProformaDetail] CHECK CONSTRAINT [FK_ProformaDetail_ProformaHeader]
GO
/****** Object:  StoredProcedure [dbo].[Delete_BarnameInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 

 

-- Procedure for Delete (Soft Delete)
CREATE PROCEDURE [dbo].[Delete_BarnameInfo]
    @Id INT,
    @UserDelete NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[BarnameInfo]
    SET 
        Deleted = 1,
        UserDelete = @UserDelete
    WHERE Id = @Id;
END
GO
/****** Object:  StoredProcedure [dbo].[Delete_ContainerInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 

 

-- Procedure for Delete (Soft Delete)
CREATE PROCEDURE [dbo].[Delete_ContainerInfo]
    @Id INT,
    @UserDelete NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[ContainerInfo]
    SET 
        Deleted = 1,
        UserDelete = @UserDelete
    WHERE Id = @Id;
END
GO
/****** Object:  StoredProcedure [dbo].[Delete_EnumParams]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Delete_EnumParams]
@Code  int
AS
BEGIN

	SET NOCOUNT ON;

update [dbo].[EnumParams] set  [State]=0 where [Code]=@Code 

END
GO
/****** Object:  StoredProcedure [dbo].[Delete_EnumUser]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Delete_EnumUser]
@id  int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

delete [dbo].[EnumUsers] where id= @id 
END
GO
/****** Object:  StoredProcedure [dbo].[Delete_PaymentInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



 

 

-- Procedure for Delete (Soft Delete)
CREATE PROCEDURE [dbo].[Delete_PaymentInfo]
    @Id INT,
    @UserDelete NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[PaymentInfo]
    SET 
        Deleted = 1,
        UserDelete = @UserDelete
    WHERE Id = @Id;
END
GO
/****** Object:  StoredProcedure [dbo].[Delete_PermissonUser]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Alter date: <Alter Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[Delete_PermissonUser] 
@id int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

delete [dbo].[PermissonUser] where id=@id
END
 


GO
/****** Object:  StoredProcedure [dbo].[Delete_Proforma]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Delete_Proforma]
@Id int, 
@UserDelete nvarchar(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

update [dbo].[ProformaHeader]
set  
 [UserDelete]=@UserDelete,
 [Deleted]=1
where field2 = @Id

update D 
set  
 [UserDelete]=@UserDelete,
 [Deleted]=1
 FROM [dbo].[ProformaHeader] H
 INNER JOIN [dbo].[ProformaDetail] D ON D.HeaderId =H.ID 
where field2 = @Id AND  H.[Deleted]=1


END
GO
/****** Object:  StoredProcedure [dbo].[Delete_ProformaDetail]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Delete_ProformaDetail]
@Id int, 
@UserDelete nvarchar(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

update [dbo].[ProformaDetail]
set  
 [UserDelete]=@UserDelete,
 [Deleted]=1
where id= @Id

END
GO
/****** Object:  StoredProcedure [dbo].[Delete_ProformaOtherInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

 

-- Procedure for Delete (Soft Delete)
CREATE PROCEDURE [dbo].[Delete_ProformaOtherInfo]
    @Id INT,
    @UserDelete NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[ProformaOtherInfo]
    SET 
        Deleted = 1,
        UserDelete = @UserDelete
    WHERE Id = @Id;
END
GO
/****** Object:  StoredProcedure [dbo].[Delete_RuleUser]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Alter date: <Alter Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[Delete_RuleUser] 
@id int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

delete [dbo].[RuleUser] 
where id=@id
END
 


GO
/****** Object:  StoredProcedure [dbo].[Delete_TransitInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



 

 

-- Procedure for Delete (Soft Delete)
CREATE PROCEDURE [dbo].[Delete_TransitInfo]
    @Id INT,
    @UserDelete NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[TransitInfo]
    SET 
        Deleted = 1,
        UserDelete = @UserDelete
    WHERE Id = @Id;
END
GO
/****** Object:  StoredProcedure [dbo].[Delete_Users]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Alter date: <Alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Delete_Users] 
@id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
update [dbo].[Users] set IsActive=0 WHERE UserID=@id  

END
 


GO
/****** Object:  StoredProcedure [dbo].[Insert_BarnameInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedure for Insert
CREATE PROCEDURE [dbo].[Insert_BarnameInfo]
    @Field1 INT,
    @Field2 nvarchar(20),
    @Field3 NVARCHAR(50),
    @Field4 VARCHAR(10),
    @Field5 INT,
    @Field6 VARCHAR(10),
    @Field7 VARCHAR(10),
    @Field8 VARCHAR(10),
    @Field9 float,
    @Field10 float,
    @Field11 int,
    @Field12 VARCHAR(10),
    @Field13 VARCHAR(10),
    @Field14 VARCHAR(10),
    @Field15 VARCHAR(10),
    @Field16 VARCHAR(10),
    @Field17 INT,
    @Field18 INT,
    @Field19 NVARCHAR(1000),
	@UserCreate NVARCHAR(50)
 


AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[BarnameInfo] 
    (
        Field1, Field2, Field3, Field4, Field5, Field6, Field7, Field8, Field9,
        Field10, Field11, Field12, Field13, Field14, Field15, Field16, Field17, Field18, Field19,UserCreate
    )
    VALUES 
    (
        @Field1,
		case when @Field2='' then Null else @Field2 end, 
		case when @Field3='' then Null else @Field3 end,
		case when len(@Field4)<10 or @Field4=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field4,'/','')) end, 
		case when @Field5='' then Null else @Field5 end, 
		case when len(@Field6)<10 or @Field6=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field6,'/','')) end, 
		case when len(@Field7)<10 or @Field7=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field7,'/','')) end,
		case when len(@Field8)<10 or @Field8=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field8,'/','')) end,
		case when @Field9='' then Null else @Field9 end,
		case when @Field10='' then Null else @Field10 end, 
		case when @Field11='' then Null else @Field11 end, 
		case when len(@Field12)<10 or @Field12=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field12,'/','')) end, 
		case when len(@Field13)<10 or @Field13=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field13,'/','')) end, 
		case when len(@Field14)<10 or @Field14=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field14,'/','')) end, 
		case when len(@Field15)<10 or @Field15=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field15,'/','')) end,
		case when len(@Field16)<10 or @Field16=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field16,'/','')) end, 
		case when @Field17='' then Null else @Field17 end,
		case when @Field18='' then Null else @Field18 end, 
		case when @Field19='' then Null else @Field19 end,
		@UserCreate
    );
END
GO
/****** Object:  StoredProcedure [dbo].[Insert_ContainerInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Procedure for Insert
CREATE PROCEDURE [dbo].[Insert_ContainerInfo]
@field1 [int],
@field2 [int],
@field3 [int],
@field4 [float],
@field5 [float],
@field6 [int],
@field7 nvarchar(20),
@field8 varchar(10),
@field9 [float],
@field10 [float],
@field11 [float],
@field12 [float],
@field13 int,
@field14 [float],
@field15 int,
@field16 [float],
@field17 int,
@UserCreate [nvarchar](50)


AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[ContainerInfo] 
    (
        Field1, Field2, Field3, Field4, Field5, Field6, Field7, Field8, Field9,
        Field10, Field11, Field12, Field13, Field14, Field15, Field16,Field17,UserCreate
    )
    VALUES 
    (
        @Field1,
		case when @Field2='' then Null else @Field2 end, 
		case when @Field3='' then Null else @Field3 end,
		case when @Field4='' then Null else @Field4 end, 
		case when @Field5='' then Null else @Field5 end, 
		case when @Field6='' then Null else @Field6 end, 
		case when @Field7='' then Null else @Field7 end,
		case when len(@Field8)<10 or @Field8=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field8,'/','')) end,
		case when @Field9='' then Null else @Field9 end,
		case when @Field10='' then Null else @Field10 end, 
		case when @Field11='' then Null else @Field11 end, 
		case when @Field12='' then Null else @Field12 end, 
		case when @Field13='' then Null else @Field13 end, 
		case when @Field14='' then Null else @Field14 end, 
		case when @Field15='' then Null else @Field15 end,
		case when @Field16='' then Null else @Field16 end,
		case when @Field17='' then Null else @Field17 end,
		@UserCreate
    );
END
GO
/****** Object:  StoredProcedure [dbo].[Insert_EnumParams]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Insert_EnumParams]
@Code int,@CodeParent int,@Name  nvarchar(200),@OtherInfo1 nvarchar(100),@OtherInfo2 nvarchar(100),@OtherInfo3 nvarchar(100),@OtherInfo4 nvarchar(100)
AS
BEGIN

	SET NOCOUNT ON;

INSERT INTO [dbo].[EnumParams] ([Code],[CodeParent],[Name],[OtherInfo1],[OtherInfo2],[OtherInfo3],[OtherInfo4]) 
select @Code ,@CodeParent,@Name,@OtherInfo1 ,@OtherInfo2,@OtherInfo3,@OtherInfo4

END
GO
/****** Object:  StoredProcedure [dbo].[INSERT_EnumUser]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[INSERT_EnumUser]
@Userid  int,
@CodeEnum  int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

INSERT INTO [dbo].[EnumUsers]
([Userid],[CodeEnum])
 
select @Userid,@CodeEnum 
END
GO
/****** Object:  StoredProcedure [dbo].[Insert_LastNum]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Insert_LastNum] 
@LastID int,
@TypeDoc int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
delete [dbo].[LastNum] where [TypeDoc]=@TypeDoc and [LastNum].LastID<>0
INSERT INTO [dbo].[LastNum]([LastID],[TypeDoc])
select @LastID,@TypeDoc

END
 


GO
/****** Object:  StoredProcedure [dbo].[Insert_PaymentInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- Procedure for Insert
CREATE PROCEDURE [dbo].[Insert_PaymentInfo]
@field1 [int],
@field2 [int],
@field3 [nvarchar](40),
@field4 VARCHAR(10),
@field5 [nvarchar](40),
@field6 VARCHAR(10),
@field7 VARCHAR(10),
@field8 [float],
@field9 [int],
@field10 [int],
@field11 [int],
@field12 [int],
@field13 [float],
@field14 VARCHAR(10),
@field15 VARCHAR(10),
@field16 [int],
@UserCreate [nvarchar](50)

AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[PaymentInfo] 
    (
        Field1, Field2, Field3, Field4, Field5, Field6, Field7, Field8, Field9,
        Field10, Field11, Field12, Field13, Field14, Field15, Field16,UserCreate
    )
    VALUES 
    (
        @Field1,
		case when @Field2='' then Null else @Field2 end, 
		case when @Field3='' then Null else @Field3 end,
		case when len(@Field4)<10 or @Field4=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field4,'/','')) end, 
		case when @Field5='' then Null else @Field5 end, 
		case when len(@Field6)<10 or @Field6=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field6,'/','')) end, 
		case when len(@Field7)<10 or @Field7=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field7,'/','')) end, 
		case when @Field8='' then Null else @Field8 end,
		case when @Field9='' then Null else @Field9 end,
		case when @Field10='' then Null else @Field10 end, 
		case when @Field11='' then Null else @Field11 end, 
		case when @Field12='' then Null else @Field12 end, 
		case when @Field13='' then Null else @Field13 end, 
		case when len(@Field14)<10 or @Field14=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field14,'/','')) end, 
		case when len(@Field15)<10 or @Field15=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field15,'/','')) end, 
		case when @Field16='' then Null else @Field16 end,
		@UserCreate
    );
END
GO
/****** Object:  StoredProcedure [dbo].[Insert_PermissonUser]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Alter date: <Alter Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[Insert_PermissonUser] 
@FormName INT,@UserName INT,@BtnDelete int,@BtnEdit int,@BtnExcel int,@BtnPrint int,@BtnNew int,@BtnView int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

INSERT INTO [dbo].[PermissonUser]
([FormSid],[UserID],[BtnDelete],[BtnEdit],[BtnExcel],[BtnPrint],[BtnNew],[BtnView])
 
select @FormName,@UserName,abs(@BtnDelete),abs(@BtnEdit),abs(@BtnExcel),abs(@BtnPrint),abs(@BtnNew),abs(@BtnView)

END
 


GO
/****** Object:  StoredProcedure [dbo].[Insert_ProformaDetail]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Insert_ProformaDetail]
@HeaderId int, 
@field5 int,
@field6 int,
@field7 int,
@field8 decimal(18, 4),
@field9 decimal(18, 4),
@UserCreate nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

INSERT INTO [dbo].[ProformaDetail]
([HeaderId],
 [field5]
,[field6]
,[field7]
,[field8]
,[field9]
,[Deleted]
,[UserCreate]

)
select
(select id from [dbo].[ProformaHeader] where [field2]= @HeaderId) , 
@field5 ,
@field6 ,
@field7 ,
@field8 ,
@field9 ,
0,
@UserCreate 

END
GO
/****** Object:  StoredProcedure [dbo].[Insert_ProformaHeader]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Insert_ProformaHeader]
@field1 int,
@field2 int,
@field3 nvarchar(20),
@field4 int,
@UserCreate nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

INSERT INTO [dbo].[ProformaHeader]
([field1]
,[field2]
,[field3]
,[field4]
,[Deleted]
,[UserCreate]

)
select
@field1,
@field2,
@field3,
@field4,
0,
@UserCreate

END
GO
/****** Object:  StoredProcedure [dbo].[Insert_ProformaOtherInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Procedure for Insert
CREATE PROCEDURE [dbo].[Insert_ProformaOtherInfo]
    @Field1 INT,
    @Field2 INT,
    @Field3 VARCHAR(10),
    @Field4 VARCHAR(10),
    @Field5 INT,
    @Field6 INT,
    @Field7 INT,
    @Field8 INT,
    @Field9 NVARCHAR(50),
    @Field10 VARCHAR(10),
    @Field11 VARCHAR(10),
    @Field12 NVARCHAR(50),
    @Field13 INT,
    @Field14 VARCHAR(10),
    @Field15 VARCHAR(10),
    @Field16 INT,
    @Field17 INT,
    @Field18 FLOAT,
    @Field19 INT,
    @Field20 NVARCHAR(50),
    @Field21 VARCHAR(10),
    @Field22 NVARCHAR(50),
    @Field23 NVARCHAR(150),
	@UserCreate NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[ProformaOtherInfo] 
    (
        Field1, Field2, Field3, Field4, Field5, Field6, Field7, Field8, Field9,
        Field10, Field11, Field12, Field13, Field14, Field15, Field16, Field17, Field18, Field19,
        Field20, Field21, Field22,Field23, StateProform,UserCreate
    )
    VALUES 
    (
        @Field1,
		case when @Field2='' then Null else @Field2 end, 
		case when len(@Field3)<10 or @Field3='' then Null else 
		(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field3,'/',''))
		end,
		case when len(@Field4)<10 or @Field4=''then Null else 
		(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field4,'/',''))
		end, 
		case when @Field5='' then Null else @Field5 end, 
		case when @Field6='' then Null else @Field6 end, 
		case when @Field7='' then Null else @Field7 end, 
		case when @Field8='' then Null else @Field8 end, 
		case when @Field9='' then Null else @Field9 end,
		case when len(@Field10)<10 or @Field10=''then Null else 
		(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field10,'/',''))
		end, 
		case when len(@Field11)<10 or @Field11=''then Null else 
		(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field11,'/',''))
		end,
		case when @Field12='' then Null else @Field12 end, 
		case when @Field13='' then Null else @Field13 end,
		case when len(@Field14)<10 or @Field14=''then Null else 
		(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field14,'/',''))
		end, 
		case when len(@Field15)<10 or @Field15=''then Null else 
		(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field15,'/',''))
		end,
		case when @Field16='' then Null else @Field16 end, 
		case when @Field17='' then Null else @Field17 end,
		case when @Field18='' then Null else @Field18 end, 
		case when @Field19='' then Null else @Field19 end,
		case when @Field20='' then Null else @Field20 end,
		case when len(@Field21)<10 or @Field21=''then Null else 
		(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field21,'/',''))
		end, 
		case when @Field22='' then Null else @Field22 end,
		case when @Field23='' then Null else @Field23 end,
		29001,@UserCreate
    );
END
GO
/****** Object:  StoredProcedure [dbo].[Insert_RuleUser]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Alter date: <Alter Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[Insert_RuleUser] 
@UserId int,@RuleId int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

INSERT INTO [dbo].[RuleUser]
([UserId],[RuleId])
select @UserId,@RuleId 

END
 


GO
/****** Object:  StoredProcedure [dbo].[Insert_TransitInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- Procedure for Insert
CREATE PROCEDURE [dbo].[Insert_TransitInfo]
@field1 [int],
@field2 [int],
@field3 [int],
@field4 [float],
@field5 VARCHAR(10),
@field6 VARCHAR(10),
@field7 VARCHAR(10),
@field8 VARCHAR(10),
@field9 VARCHAR(10),
@field10 [nvarchar](20),
@field11 [int],
@field12 VARCHAR(10),
@field13 [nvarchar](30),
@field14 [nvarchar](150),
@field15 int,
@field16 [int],
@field17 VARCHAR(10),
@field18 VARCHAR(10),
@field19 VARCHAR(10),
@field20 VARCHAR(10),
@field21 [int],
@UserCreate [nvarchar](50)
  
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[TransitInfo] 
    (
        Field1, Field2, Field3, Field4, Field5, Field6, Field7, Field8, Field9,
        Field10, Field11, Field12, Field13, Field14, Field15, Field16,Field17,Field18, Field19,Field20,Field21,UserCreate
    )
    VALUES 
    (
        @Field1,
		case when @Field2='' then Null else @Field2 end, 
		case when @Field3='' then Null else @Field3 end,
		case when @Field4='' then Null else @Field4 end, 
		case when len(@Field5)<10 or @Field5=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field5,'/','')) end, 
		case when len(@Field6)<10 or @Field6=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field6,'/','')) end, 
		case when len(@Field7)<10 or @Field7=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field7,'/','')) end, 
		case when len(@Field8)<10 or @Field8=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field8,'/','')) end, 
		case when len(@Field9)<10 or @Field9=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field9,'/','')) end, 
		case when @Field10='' then Null else @Field10 end, 
		case when @Field11='' then Null else @Field11 end, 
		case when len(@Field12)<10 or @Field12=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field12,'/','')) end, 
		case when @Field13='' then Null else @Field13 end, 
		case when @Field14='' then Null else @Field14 end, 
		case when @Field15='' then Null else @Field15 end,
		case when @Field16='' then Null else @Field16 end,
		case when len(@Field17)<10 or @Field17=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field17,'/','')) end, 
		case when len(@Field18)<10 or @Field18=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field18,'/','')) end, 
		case when len(@Field19)<10 or @Field19=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field19,'/','')) end, 
		case when len(@Field20)<10 or @Field20=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field20,'/','')) end, 
		case when @Field21='' then Null else @Field21 end,
		@UserCreate
    );
END
GO
/****** Object:  StoredProcedure [dbo].[Insert_Users]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Alter date: <Alter Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[Insert_Users] 
@user nvarchar(50),@pass  nvarchar(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

INSERT INTO [dbo].[Users]
([UserName],[Password],[IsActive],[IsAdmin])

select @user,@pass,1,0

END
 


GO
/****** Object:  StoredProcedure [dbo].[Select_AllBarnameInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_AllBarnameInfo]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT [Id]
      ,[field1]
      ,[field2]
      ,[field3]
      ,[dbo].[MiladiToShamsi]([field4])[field4]
      ,[field5]
      ,[dbo].[MiladiToShamsi]([field6])[field6]
      ,[dbo].[MiladiToShamsi]([field7])[field7]
      ,[dbo].[MiladiToShamsi]([field8])[field8]
      ,[field9]
      ,[field10]
      ,[field11]
      ,[dbo].[MiladiToShamsi]([field12])[field12]
      ,[dbo].[MiladiToShamsi]([field13])[field13]
      ,[dbo].[MiladiToShamsi]([field14])[field14]
      ,[dbo].[MiladiToShamsi]([field15])[field15]
      ,[dbo].[MiladiToShamsi]([field16])[field16]
      ,[field17]
      ,[field18]
      ,[field19]
      ,[Deleted]
      ,[UserDelete]
      ,[DateInsert]
      ,[UserUpdate]
      ,[UserCreate]
  FROM [dbo].[BarnameInfo]
END
GO
/****** Object:  StoredProcedure [dbo].[Select_AllContainerInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_AllContainerInfo]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT [Id]
      ,[field1]
      ,[field2]
      ,[field3]
      ,[field4]
      ,[field5]
      ,[field6]
      ,[field7]
      ,[dbo].[MiladiToShamsi]([field8])[field8]
      ,[field9]
      ,[field10]
      ,[field11]
      ,[field12]
      ,[field13]
      ,[field14]
      ,[field15]
      ,[field16]
      ,[field17]
      ,[Deleted]
      ,[UserDelete]
      ,[DateInsert]
      ,[UserUpdate]
      ,[UserCreate]
  FROM [dbo].[ContainerInfo]
END
GO
/****** Object:  StoredProcedure [dbo].[Select_AllEnumUser]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_AllEnumUser]
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

select E.*,EP.CodeParent from [dbo].[EnumUsers] E
inner join [dbo].[EnumParams] EP on E.CodeEnum=EP.Code

END
GO
/****** Object:  StoredProcedure [dbo].[Select_AllPaymentInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_AllPaymentInfo]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT [Id]
      ,[field1]
      ,[field2]
      ,[field3]
      ,[dbo].[MiladiToShamsi]([field4])[field4]
      ,[field5]
      ,[dbo].[MiladiToShamsi]([field6])[field6]
      ,[dbo].[MiladiToShamsi]([field7])[field7]
      ,[field8]
      ,[field9]
      ,[field10]
      ,[field11]
      ,[field12]
      ,[field13]
      ,[dbo].[MiladiToShamsi]([field14])[field14]
      ,[dbo].[MiladiToShamsi]([field15])[field15]
      ,[field16]
      ,[Deleted]
      ,[UserDelete]
      ,[DateInsert]
      ,[UserUpdate]
      ,[UserCreate]
  FROM [dbo].[PaymentInfo]
END
GO
/****** Object:  StoredProcedure [dbo].[Select_AllProformaDetail]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_AllProformaDetail]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

select * from [dbo].[ProformaDetail]
END
GO
/****** Object:  StoredProcedure [dbo].[Select_AllProformaOtherInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_AllProformaOtherInfo]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT [Id]
      ,[field1]
      ,[field2]
      ,[dbo].[MiladiToShamsi]([field3])[field3]
      ,[dbo].[MiladiToShamsi]([field4])[field4]
      ,[field5]
      ,[field6]
      ,[field7]
      ,[field8]
      ,[field9]
      ,[dbo].[MiladiToShamsi]([field10])[field10]
      ,[dbo].[MiladiToShamsi]([field11])[field11]
      ,[field12]
      ,[field13]
      ,[dbo].[MiladiToShamsi]([field14])[field14]
      ,[dbo].[MiladiToShamsi]([field15])[field15]
      ,[field16]
      ,[field17]
      ,[field18]
      ,[field19]
      ,[field20]
      ,[dbo].[MiladiToShamsi]([field21])[field21]
      ,[field22]
      ,[field23]
      ,[StateProform]
      ,[Confirmer]
      ,[DateConfirm]
      ,[Deleted]
      ,[UserDelete]
      ,[DateInsert]
      ,[UserUpdate]
      ,[UserCreate]
  FROM [dbo].[ProformaOtherInfo]
END
GO
/****** Object:  StoredProcedure [dbo].[Select_AllTransitInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_AllTransitInfo]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT [Id]
      ,[field1]
      ,[field2]
      ,[field3]
      ,[field4]
      ,[dbo].[MiladiToShamsi]([field5])[field5]
      ,[dbo].[MiladiToShamsi]([field6])[field6]
      ,[dbo].[MiladiToShamsi]([field7])[field7]
      ,[dbo].[MiladiToShamsi]([field8])[field8]
      ,[dbo].[MiladiToShamsi]([field9])[field9]
      ,[field10]
      ,[field11]
      ,[dbo].[MiladiToShamsi]([field12])[field12]
      ,[field13]
      ,[field14]
      ,[field15]
      ,[field16]
      ,[dbo].[MiladiToShamsi]([field17])[field17]
      ,[dbo].[MiladiToShamsi]([field18])[field18]
      ,[dbo].[MiladiToShamsi]([field19])[field19]
      ,[dbo].[MiladiToShamsi]([field20])[field20]
      ,[field21]
      ,[Deleted]
      ,[UserDelete]
      ,[DateInsert]
      ,[UserUpdate]
      ,[UserCreate]
  FROM [dbo].[TransitInfo]
END
GO
/****** Object:  StoredProcedure [dbo].[Select_BarnameInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_BarnameInfo]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT [Id]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field1]) AS [پروفرما]
      ,[field2] AS [شماره بارنامه]
      ,[field3] AS [شماره کوتاژ]
      ,[dbo].[MiladiToShamsi]([field4]) AS [تاریخ اظهار]
      ,[field5] AS [پارت]
      ,[dbo].[MiladiToShamsi]([field6]) AS [تاریخ حمل از کشور مبدا]
      ,[dbo].[MiladiToShamsi]([field7]) AS [تاریخ رسیدن به جبلعلی]
      ,[dbo].[MiladiToShamsi]([field8]) AS [تاریخ حمل از جبلعلی]
      ,[field9] AS [مقدار( ناخالص ) بارنامه]
      ,[field10] AS [مقدار خالص بارنامه]
      ,[field11] AS [تعداد کارتن بارنامه]
      ,[dbo].[MiladiToShamsi]([field12]) AS [تاریخ ورود به بندر ایران]
      ,[dbo].[MiladiToShamsi]([field13]) AS [دریافت فرم بازرسی ]
      ,[dbo].[MiladiToShamsi]([field14]) AS [ترخیصیه کشتیرانی]
      ,[dbo].[MiladiToShamsi]([field15]) AS [دریافت اصل اسناد]
      ,[dbo].[MiladiToShamsi]([field16]) AS [ارسال اسناد جهت ترخیص]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field17]) AS [ترخیص کار]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field18]) AS [شرکت کشتیرانی ]
      ,[field19] AS [نام کشتی]
      ,[UserUpdate] AS [کاربر ویرایش کننده]
      ,[UserCreate] AS [کاربر ثبت کننده]
  FROM [dbo].[BarnameInfo]  where isnull(Deleted,0) =0
END
GO
/****** Object:  StoredProcedure [dbo].[Select_ContainerInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_ContainerInfo]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT [Id]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field1]) AS [پروفرما]
      ,[field2] AS [شماره بارنامه]
      ,[field3] AS [نوع کانیتنر]
      ,[field4] AS [مقدار کانتینر(خالص)]
      ,[field5] AS [مقدار ناخالص کانتینر]
      ,[field6] AS [تعداد کارتن کانتینر]
      ,[field7] AS [شماره کانتینر / کشتی]
      ,[dbo].[MiladiToShamsi]([field8]) AS [تاریخ تلکس ریلیز]
      ,[field9] AS [مقدار ناخالص گل دست]
      ,[field10] AS [مقدار ناخالص سر دست]
      ,[field11] AS [مقدار ناخالص گردن]
      ,[field12] AS [مقدار خالص گل دست]
      ,[field13] AS [تعداد کارتن گل دست]
      ,[field14] AS [مقدار خالص سر دست]
      ,[field15] AS [تعداد کارتن سر دست]
      ,[field16] AS [مقدار خالص گردن]
	  ,[field17] AS [تعداد کارتن گردن]
      ,[UserUpdate] AS [کاربر ویرایش کننده]
      ,[UserCreate] AS [کاربر ثبت کننده]
  FROM [dbo].[ContainerInfo] where isnull(Deleted,0) =0
END
GO
/****** Object:  StoredProcedure [dbo].[Select_EnumParams]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_EnumParams] 
@CodeParent int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT [Code]as [کد],[Name] as[عنوان],[OtherInfo1]as[سایر اطلاعات1],[OtherInfo2]as[سایر اطلاعات2],[OtherInfo3]as[سایر اطلاعات3],[OtherInfo4]as[سایر اطلاعات4]
  FROM [dbo].[EnumParams]
where [CodeParent]=@CodeParent and [State]=1


end
GO
/****** Object:  StoredProcedure [dbo].[Select_EnumUser]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_EnumUser]
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

select Id,
U.UserName AS [کاربر], 
EPP.Name [نوع اطلاعات پایه],
EP.Name AS [اطلاعات پایه]
from [dbo].[EnumUsers] E
inner join [dbo].[Users] U on U.UserID=E.Userid  
inner join [dbo].[EnumParams] EP on EP.Code=E.CodeEnum  
inner join [dbo].[EnumParams] EPP on EPP.Code=EP.CodeParent
order by E.Userid,EPP.Code

END
GO
/****** Object:  StoredProcedure [dbo].[Select_EnumUsers]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_EnumUsers]
@UserId int
AS
BEGIN
 
	SET NOCOUNT ON;
 
 select Id, Userid, CodeEnum from [dbo].[EnumUsers] where Userid=@UserId
END
GO
/****** Object:  StoredProcedure [dbo].[Select_FormName]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_FormName] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT  ID,Fa_Name
FROM  [dbo].[FormS]
END
 


GO
/****** Object:  StoredProcedure [dbo].[Select_ListForLoad]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_ListForLoad]
 @Type int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
if @Type =1

SELECT 
H.[Id],
(select [Name] from [dbo].[EnumParams] where [Code]= [field1] and [State]=1) AS [Column1],
(select [Name] from [dbo].[EnumParams] where [Code]= [field2] and [State]=1) AS [Column2],
[field1],
[field2],
[field3],
[field4],
''[field5],
''[field6],
''[field7],
''[field8],
''[field9],
''[field10]
FROM [dbo].[ProformaHeader] H
inner join [dbo].[EnumUsers] on [EnumUsers].CodeEnum =[field2]
where isnull(H.Deleted,0)=0 

END


GO
/****** Object:  StoredProcedure [dbo].[Select_MaxID]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_MaxID]
@TypeDoc int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
select isnull(max(LastID),0)+1 MaxID from [dbo].[LastNum] where TypeDoc =@TypeDoc
END


GO
/****** Object:  StoredProcedure [dbo].[Select_NextCode_EnumParams]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_NextCode_EnumParams]  
@CodeParent int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @NextCode INT

set @NextCode= (SELECT max([Code])+1 as NextCode  FROM [dbo].[EnumParams] where [CodeParent]=@CodeParent)

IF @NextCode IS NOT NULL
BEGIN
    SELECT @NextCode AS NextCode
END
ELSE
BEGIN
    SELECT CAST(@CodeParent AS VARCHAR) + '001' AS NextCode
END

end
GO
/****** Object:  StoredProcedure [dbo].[Select_PaymentInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_PaymentInfo]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT [Id]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field1]) AS [پروفرما]
      ,[field2] AS [شماره بارنامه]
      ,[field3] AS [شماره ابزار پرداخت]
      ,[dbo].[MiladiToShamsi]([field4]) AS [تاریخ رفع تعهد]
      ,[field5] AS [شماره کد ساتا (مختومه)]
      ,[dbo].[MiladiToShamsi]([field6]) AS [تاریخ تشکیل گواهی آماری]
      ,[dbo].[MiladiToShamsi]([field7]) AS [تاریخ نامه نظر دستگاه]
      ,[field8] AS [مبلغ کارمزد خرید ارز]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field9]) AS [نوع ارز کارمزد خرید ارز]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field10]) AS [نوع ارز گواهی آماری]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field11]) AS [منبع تامین ارز]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field12]) AS [بانک عامل]
      ,[field13] AS [مبلغ تشکیل گواهی آماری]
      ,[dbo].[MiladiToShamsi]([field14]) AS [تاریخ تخصیص ارز]
      ,[dbo].[MiladiToShamsi]([field15]) AS [انقضای تخصیص ارز]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field16]) AS [شرکت خارجی(گیرنده ارز)]
      ,[UserUpdate] AS [کاربر ویرایش کننده]
      ,[UserCreate] AS [کاربر ثبت کننده]
  FROM [dbo].[PaymentInfo] where isnull(Deleted,0) =0 
END
GO
/****** Object:  StoredProcedure [dbo].[Select_PermissonUser]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_PermissonUser] 
@FormsID int,
@UserId  int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT BtnDelete, BtnEdit, BtnExcel, BtnPrint, BtnNew,BtnView
FROM PermissonUser where FormsId=@FormsID and UserId= @UserId
END
 


GO
/****** Object:  StoredProcedure [dbo].[Select_PermissonUserS]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_PermissonUserS] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT    PermissonUser.Id , [FormS].[Fa_Name][فرم],[Users].UserID UserID, [Users].[UserName] [کاربر], BtnDelete [حذف], BtnEdit[ویرایش], BtnExcel[اکسل], BtnPrint[پرینت], BtnNew[جدید], BtnView[مشاهده]
FROM PermissonUser
inner join [jrm].[dbo].[Users] on PermissonUser.userid= [Users].UserID 
inner join [jrm].[dbo].[FormS] on [FormS].id=PermissonUser.formsid
--where [Users].UserID <>1
END
 


GO
/****** Object:  StoredProcedure [dbo].[Select_ProformaDetail]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[Select_ProformaDetail]
@Hid int
AS
BEGIN
	SET NOCOUNT ON;
SELECT D.[Id]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field5]) AS [نام کالا]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field6]) AS [واحد اندازه گیری]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field7]) AS [نوع ارز]
      ,[field8] AS [مقدار کالا]
      ,[field9] AS [قیمت واحد]
      ,D.[UserCreate] AS [کاربر ثبت کننده]
      ,D.[UserUpdate] AS [کاربر ویرایش کننده]
  FROM [dbo].[ProformaDetail] D with(nolock)
  inner join [dbo].[ProformaHeader] H with(nolock) on D.HeaderId =H.Id
  where D.Deleted=0 and H.Deleted=0 and H.field2=@Hid
END
GO
/****** Object:  StoredProcedure [dbo].[Select_ProformaOtherInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_ProformaOtherInfo]
@Userid INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT [ProformaOtherInfo].[Id]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field1]) AS [پروفرما]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field2]) AS [نوع حمل]
      ,[dbo].[MiladiToShamsi]([field3]) AS [تاریخ ثبت سفارش]
      ,[dbo].[MiladiToShamsi]([field4]) AS [تاریخ اعتبار ثبت سفارش]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field5]) AS [اینکوترمز]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field6]) AS [کشور مبدا]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field7]) AS [مقصد]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field8]) AS [گروه کالا]
      ,[field9] AS [تعرفه جهانی کالا]
      ,[dbo].[MiladiToShamsi]([field10]) AS [تاریخ PI]
      ,[dbo].[MiladiToShamsi]([field11]) AS [اعتبار PI]
      ,[field12] AS [شماره بیمه نامه]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field13]) AS [شرکت بیمه]
      ,[dbo].[MiladiToShamsi]([field14]) AS [تاریخ بیمه]
      ,[dbo].[MiladiToShamsi]([field15]) AS [اعتبار بیمه]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field16]) AS [بانک عامل ]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field17]) AS [کشور ذینفع]
      ,[field18] AS [هزینه حمل]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field19]) AS [واحد پول هزینه حمل]
      ,[field20] AS [IRC / IVCشماره ]
      ,[dbo].[MiladiToShamsi]([field21]) AS [تاریخ مجوز واردات / VIP ]
      ,[field22] AS [شماره مجوز واردات / VIP ]
      ,[field23] AS [مسئول فنی / ناظر شرعی/ناظر بهداشتی]
      ,[StateProform] AS [وضعیت]
      ,[Confirmer] AS [کاربر تایید کننده]
      ,[DateInsert] AS [تاریخ ثبت]
      ,[UserUpdate] AS [کاربر ویرایش کننده]
      ,[UserCreate] AS [کاربر ثبت کننده]
  FROM [dbo].[ProformaOtherInfo]
  INNER JOIN [dbo].[EnumUsers] ON [EnumUsers].CodeEnum=[ProformaOtherInfo].[field1]
  where isnull([Deleted],0)=0 AND [EnumUsers].Userid=@Userid
END

GO
/****** Object:  StoredProcedure [dbo].[Select_Rule]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_Rule] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT [Rule].id,[Rule].Name [نقش],[TypeDoc].Name [نوع سند],[Rule].State [مرحله]
FROM [jrm].[dbo].[Rule]
inner join [dbo].[TypeDoc] on [TypeDoc].Id=[Rule].TypeDocId
END
 


GO
/****** Object:  StoredProcedure [dbo].[Select_RuleUser]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_RuleUser] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT [RuleUser].id,[Users].[UserName] ,[Rule].Name [نقش],[TypeDoc].Name [نوع سند],[Rule].State [مرحله]
FROM [jrm].[dbo].[RuleUser]
inner join [dbo].[Rule] on [RuleUser].RuleId=[Rule].Id
inner join [dbo].[Users] on [RuleUser].UserId=[Users].UserID
inner join [dbo].[TypeDoc] on [TypeDoc].Id=[Rule].TypeDocId
END
 


GO
/****** Object:  StoredProcedure [dbo].[Select_TransitInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Select_TransitInfo]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT [Id]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field1]) AS [پروفرما]
      ,[field2] AS [شماره بارنامه]
      ,(SELECT  [field7] FROM ContainerInfo WHERE id=[field3]) AS [کانیتنر]
      ,[field4] AS [وزن باسکول درب خروج]
      ,[dbo].[MiladiToShamsi]([field5]) AS [تاریخ مجوز خروج / انجمن ]
      ,[dbo].[MiladiToShamsi]([field6]) AS [تاریخ مجوز راهداری]
      ,[dbo].[MiladiToShamsi]([field7]) AS [تاریخ مجوز استاندارد]
      ,[dbo].[MiladiToShamsi]([field8]) AS [تاریخ ترخیص]
      ,[dbo].[MiladiToShamsi]([field9]) AS [تاریخ ارزیابی درب خروج]
      ,[field10] AS [شماره بارنامه ماشین]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field11]) AS [شهر مقصد حمل]
      ,[dbo].[MiladiToShamsi]([field12]) AS [تاریخ  اعلام بار]
      ,[field13] AS [شماره موبایل راننده]
      ,[field14] AS [نام راننده]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field15]) AS [وسیله نقلیه]
      ,(SELECT  Name FROM EnumParams WHERE Code=[field16]) AS [انبار مقصد]
	  ,[dbo].[MiladiToShamsi]([field17]) AS [تاریخ تحویل به انبار]
      ,[dbo].[MiladiToShamsi]([field18]) AS [تاریخ عودت کانتینر]
      ,[dbo].[MiladiToShamsi]([field19]) AS [تاریخ شروع قرارداد انبار]
      ,[dbo].[MiladiToShamsi]([field20]) AS [تاریخ پایان قرارداد انبار]
	  ,(SELECT  Name FROM EnumParams WHERE Code=[field21]) AS [شرکت حمل و نقل]
      ,[UserUpdate] AS [کاربر ویرایش کننده]
      ,[UserCreate] AS [کاربر ثبت کننده]
  FROM [dbo].[TransitInfo] where isnull(Deleted,0) =0
END
GO
/****** Object:  StoredProcedure [dbo].[Update_ArabicCharacter]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Update_ArabicCharacter]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @Table NVARCHAR(MAX),  
        @Col NVARCHAR(MAX)  
   
 DECLARE Table_Cursor CURSOR   
 FOR  
    --پيدا كردن تمام فيلدهاي متني تمام جداول ديتابيس جاري  
    SELECT a.name, --table  
           b.name --col  
    FROM   sysobjects a,  
           syscolumns b  
    WHERE  a.id = b.id  
           AND a.xtype = 'u' --User table  
           AND (  
                   b.xtype = 99 --ntext  
                   OR b.xtype = 35 -- text  
                   OR b.xtype = 231 --nvarchar  
                   OR b.xtype = 167 --varchar  
                   OR b.xtype = 175 --char  
                   OR b.xtype = 239 --nchar  
               )  
   
 OPEN Table_Cursor FETCH NEXT FROM  Table_Cursor INTO @Table,@Col  
 WHILE (@@FETCH_STATUS = 0)  
 BEGIN  
   EXEC (  
            'update [' + @Table + '] set [' + @Col +  
            ']= REPLACE(REPLACE(CAST([' + @Col +  
            '] as nvarchar(max)) , NCHAR(1610), NCHAR(1740)),NCHAR(1603),NCHAR(1705)) '  
        )   
    PRINT 'Table: ' + @Table +' Col: '+ @Col;
    FETCH NEXT FROM Table_Cursor INTO @Table,@Col  
 END CLOSE Table_Cursor DEALLOCATE Table_Cursor 
END


GO
/****** Object:  StoredProcedure [dbo].[Update_BarnameInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedure for Update
CREATE PROCEDURE [dbo].[Update_BarnameInfo]
    @Id INT,
    @Field1 INT,
    @Field2 nvarchar(20),
    @Field3 NVARCHAR(50),
    @Field4 VARCHAR(10),
    @Field5 INT,
    @Field6 VARCHAR(10),
    @Field7 VARCHAR(10),
    @Field8 VARCHAR(10),
    @Field9 float,
    @Field10 float,
    @Field11 int,
    @Field12 VARCHAR(10),
    @Field13 VARCHAR(10),
    @Field14 VARCHAR(10),
    @Field15 VARCHAR(10),
    @Field16 VARCHAR(10),
    @Field17 INT,
    @Field18 INT,
    @Field19 NVARCHAR(1000),
    @UserUpdate NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[BarnameInfo]
    SET 				 
        Field1  =@Field1  ,
        Field2  =case when @Field2='' then Null else @Field2 end ,
        Field3  =case when @Field3='' then Null else @Field3 end ,
        Field4  =case when len(@Field4)<10 or @Field4=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field4,'/','')) end, 
        Field5  =case when @Field5='' then Null else @Field5 end,
        Field6  =case when len(@Field6)<10 or @Field6=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field6,'/','')) end, 
        Field7  =case when len(@Field7)<10 or @Field7=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field7,'/','')) end, 
        Field8  =case when len(@Field8)<10 or @Field8=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field8,'/','')) end, 
        Field9  =case when @Field9='' then Null else @Field9 end,
        Field10 =case when @Field10='' then Null else @Field10 end, 
        Field11 =case when @Field11='' then Null else @Field11 end,
        Field12 =case when len(@Field12)<10 or @Field12=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field12,'/','')) end, 
        Field13 =case when len(@Field13)<10 or @Field13=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field13,'/','')) end,
        Field14 =case when len(@Field14)<10 or @Field14=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field14,'/','')) end, 
        Field15 =case when len(@Field15)<10 or @Field15=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field15,'/','')) end,
        Field16 =case when len(@Field16)<10 or @Field16=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field16,'/','')) end,
        Field17 =case when @Field17='' then Null else @Field17 end,
        Field18 =case when @Field18='' then Null else @Field18 end,
        Field19 =case when @Field19='' then Null else @Field19 end,
		UserUpdate =isnull([UserUpdate],'')+'/'+@UserUpdate
    WHERE Id = @Id;
END
GO
/****** Object:  StoredProcedure [dbo].[Update_ContainerInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Procedure for Update
CREATE PROCEDURE [dbo].[Update_ContainerInfo]
@Id INT,
@field1 [int],
@field2 [int],
@field3 [int],
@field4 [float],
@field5 [float],
@field6 [int],
@field7 nvarchar(20),
@field8 varchar(10),
@field9 [float],
@field10 [float],
@field11 [float],
@field12 [float],
@field13 int,
@field14 [float],
@field15 int,
@field16 [float],
@field17 int,
@UserUpdate NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[ContainerInfo]
    SET 				 
        Field1  =@Field1  ,
        Field2  =case when @Field2='' then Null else @Field2 end ,
        Field3  =case when @Field3='' then Null else @Field3 end ,
        Field4  =case when @Field4='' then Null else @Field4 end, 
        Field5  =case when @Field5='' then Null else @Field5 end,
        Field6  =case when @Field6='' then Null else @Field6 end, 
        Field7  =case when @Field7='' then Null else @Field7 end, 
        Field8  =case when len(@Field8)<10 or @Field8=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field8,'/','')) end, 
        Field9  =case when @Field9='' then Null else @Field9 end,
        Field10 =case when @Field10='' then Null else @Field10 end, 
        Field11 =case when @Field11='' then Null else @Field11 end,
        Field12 =case when @Field12='' then Null else @Field12 end, 
        Field13 =case when @Field13='' then Null else @Field13 end,
        Field14 =case when @Field14='' then Null else @Field14 end, 
        Field15 =case when @Field15='' then Null else @Field15 end,
        Field16 =case when @Field16='' then Null else @Field16 end,
		Field17 =case when @Field17='' then Null else @Field17 end,
		UserUpdate =isnull([UserUpdate],'')+'/'+@UserUpdate
    WHERE Id = @Id;
 
END
GO
/****** Object:  StoredProcedure [dbo].[Update_EnumParams]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Update_EnumParams]
@Code int,@Name  nvarchar(200),@OtherInfo1 nvarchar(100),@OtherInfo2 nvarchar(100),@OtherInfo3 nvarchar(100),@OtherInfo4 nvarchar(100)
AS
 
BEGIN

	SET NOCOUNT ON;
	update [dbo].[EnumParams] set [Name]=@Name,[OtherInfo1]=@OtherInfo1,[OtherInfo2]=@OtherInfo2,[OtherInfo3]=@OtherInfo3,[OtherInfo4]=@OtherInfo4
where [Code]=@Code 

END
GO
/****** Object:  StoredProcedure [dbo].[Update_EnumUser]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Update_EnumUser]
@id int,
@Userid  int,
@CodeEnum  int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

update [dbo].[EnumUsers] set [Userid]=@Userid,[CodeEnum]=@CodeEnum
where id =@id

END
GO
/****** Object:  StoredProcedure [dbo].[Update_PassUser]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Update_PassUser] 
@id int ,@pass nvarchar(20)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
UPDATE [dbo].[Users] SET [Password] =@pass WHERE  UserID=@id
END
 


GO
/****** Object:  StoredProcedure [dbo].[Update_PaymentInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- Procedure for Update
CREATE PROCEDURE [dbo].[Update_PaymentInfo]
@Id INT,
@field1 [int],
@field2 [int],
@field3 [nvarchar](40),
@field4 VARCHAR(10),
@field5 [nvarchar](40),
@field6 VARCHAR(10),
@field7 VARCHAR(10),
@field8 [float],
@field9 [int],
@field10 [int],
@field11 [int],
@field12 [int],
@field13 [float],
@field14 VARCHAR(10),
@field15 VARCHAR(10),
@field16 [int],
@UserUpdate NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[PaymentInfo]
    SET 				 
        Field1  =@Field1  ,
        Field2  =case when @Field2='' then Null else @Field2 end ,
        Field3  =case when @Field3='' then Null else @Field3 end ,
        Field4  =case when len(@Field4)<10 or @Field4=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field4,'/','')) end, 
        Field5  =case when @Field5='' then Null else @Field5 end,
        Field6  =case when len(@Field6)<10 or @Field6=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field6,'/','')) end, 
        Field7  =case when len(@Field7)<10 or @Field7=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field7,'/','')) end, 
        Field8  =case when @Field8='' then Null else @Field8 end, 
        Field9  =case when @Field9='' then Null else @Field9 end,
        Field10 =case when @Field10='' then Null else @Field10 end, 
        Field11 =case when @Field11='' then Null else @Field11 end,
        Field12 =case when @Field12='' then Null else @Field12 end, 
        Field13 =case when @Field13='' then Null else @Field13 end,
        Field14 =case when len(@Field14)<10 or @Field14=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field14,'/','')) end, 
        Field15 =case when len(@Field15)<10 or @Field15=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field15,'/','')) end,
        Field16 =case when @Field16='' then Null else @Field16 end,
		UserUpdate =isnull([UserUpdate],'')+'/'+@UserUpdate
    WHERE Id = @Id;
 
END
GO
/****** Object:  StoredProcedure [dbo].[Update_PermissonUser]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Alter date: <Alter Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[Update_PermissonUser] 
@id int ,@FormName int,@UserName int,@BtnDelete int,@BtnEdit int,@BtnExcel int,@BtnPrint int,@BtnNew int,@BtnView int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

update  [dbo].[PermissonUser]
set [Formsid]=@FormName,[Userid]=@UserName
,[BtnDelete]= abs(@BtnDelete),[BtnEdit]=abs(@BtnEdit)
,[BtnExcel]=abs(@BtnExcel),[BtnPrint]=abs(@BtnPrint),[BtnNew]=abs(@BtnNew),[BtnView]=abs(@BtnView)
where id=@id

END
 


GO
/****** Object:  StoredProcedure [dbo].[Update_ProformaDetail]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Update_ProformaDetail]
@Id int, 
@field5 int,
@field6 int,
@field7 int,
@field8 decimal(18, 4),
@field9 decimal(18, 4),
@UserUpdate nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

update [dbo].[ProformaDetail]
set  
 [field5]=@field5
,[field6]=@field6
,[field7]=@field7
,[field8]=@field8
,[field9]=@field9
,[UserUpdate]=isnull([UserUpdate],'')+'/'+@UserUpdate
where id= @Id

END
GO
/****** Object:  StoredProcedure [dbo].[Update_ProformaHeader]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Update_ProformaHeader]
@field1 int,
@field2 int,
@field3 nvarchar(20),
@field4 int,
@UserUpdate nvarchar(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

UPDATE [dbo].[ProformaHeader]
   SET [field1] = @field1,
       [field3] = @field3,
       [field4] = @field4, 
       [UserUpdate] = isnull([UserUpdate],'')+'/'+@UserUpdate
 WHERE  [field2]=@field2


END
GO
/****** Object:  StoredProcedure [dbo].[Update_ProformaOtherInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Procedure for Update
CREATE PROCEDURE [dbo].[Update_ProformaOtherInfo]
    @Id INT,
    @Field1 INT,
    @Field2 INT,
    @Field3 VARCHAR(10),
    @Field4 VARCHAR(10),
    @Field5 INT,
    @Field6 INT,
    @Field7 INT,
    @Field8 INT,
    @Field9 NVARCHAR(50),
    @Field10 VARCHAR(10),
    @Field11 VARCHAR(10),
    @Field12 NVARCHAR(50),
    @Field13 INT,
    @Field14 VARCHAR(10),
    @Field15 VARCHAR(10),
    @Field16 INT,
    @Field17 INT,
    @Field18 FLOAT,
    @Field19 INT,
    @Field20 NVARCHAR(50),
    @Field21 VARCHAR(10),
    @Field22 NVARCHAR(50),
    @Field23 NVARCHAR(150),
    @UserUpdate NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[ProformaOtherInfo]
    SET 				 
        Field1  =@Field1  ,
        Field2  =case when @Field2='' then Null else @Field2 end  ,
        Field3  =case when len(@Field3)<10 or @Field3='' then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field3,'/',''))	end  ,
        Field4  =case when len(@Field4)<10 or @Field4=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field4,'/','')) end, 
        Field5  =case when @Field5='' then Null else @Field5 end,
        Field6  =case when @Field6='' then Null else @Field6 end, 
        Field7  =case when @Field7='' then Null else @Field7 end, 
        Field8  =case when @Field8='' then Null else @Field8 end, 
        Field9  =case when @Field9='' then Null else @Field9 end,
        Field10 =case when len(@Field10)<10 or @Field10=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field10,'/','')) end, 
        Field11 =case when len(@Field11)<10 or @Field11=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field11,'/','')) end,
        Field12 =case when @Field12='' then Null else @Field12 end, 
        Field13 =case when @Field13='' then Null else @Field13 end,
        Field14 =case when len(@Field14)<10 or @Field14=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field14,'/','')) end, 
        Field15 =case when len(@Field15)<10 or @Field15=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field15,'/','')) end,
        Field16 =case when @Field16='' then Null else @Field16 end,
        Field17 =case when @Field17='' then Null else @Field17 end,
        Field18 =case when @Field18='' then Null else @Field18 end,
        Field19 =case when @Field19='' then Null else @Field19 end,
        Field20 =case when @Field20='' then Null else @Field20 end,
        Field21 =case when len(@Field21)<10 or @Field21=''then Null else (SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field21,'/','')) end, 
        Field22 =case when @Field22='' then Null else @Field22 end,
        Field23 =case when @Field23='' then Null else @Field23 end,
		UserUpdate =isnull([UserUpdate],'')+'/'+@UserUpdate

    WHERE Id = @Id;
END
GO
/****** Object:  StoredProcedure [dbo].[Update_RuleUser]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Alter date: <Alter Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[Update_RuleUser] 
@id int,@UserId int,@RuleId int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

update [dbo].[RuleUser] set [UserId]=@UserId,[RuleId]=@RuleId 
where id=@id
END
 


GO
/****** Object:  StoredProcedure [dbo].[Update_TransitInfo]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- Procedure for Update
CREATE PROCEDURE [dbo].[Update_TransitInfo]
@Id INT,
@field1 [int],
@field2 [int],
@field3 [int],
@field4 [float],
@field5 VARCHAR(10),
@field6 VARCHAR(10),
@field7 VARCHAR(10),
@field8 VARCHAR(10),
@field9 VARCHAR(10),
@field10 [nvarchar](20),
@field11 [int],
@field12 VARCHAR(10),
@field13 [nvarchar](30),
@field14 [nvarchar](150),
@field15 int,
@field16 [int],
@field17 VARCHAR(10),
@field18 VARCHAR(10),
@field19 VARCHAR(10),
@field20 VARCHAR(10),
@field21 [int],
@UserUpdate NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[TransitInfo]
    SET 				 
        Field1  =@Field1  ,
        Field2  =case when @Field2='' then Null else @Field2 end ,
        Field3  =case when @Field3='' then Null else @Field3 end ,
        Field4  =case when @Field4='' then Null else @Field4 end, 
        Field5  =case when len(@Field5)<10 or @Field5=''then Null else(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field5,'/','')) end, 
        Field6  =case when len(@Field6)<10 or @Field6=''then Null else(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field6,'/','')) end, 
        Field7  =case when len(@Field7)<10 or @Field7=''then Null else(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field7,'/','')) end, 
        Field8  =case when len(@Field8)<10 or @Field8=''then Null else(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field8,'/','')) end, 
        Field9  =case when len(@Field9)<10 or @Field9=''then Null else(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field9,'/','')) end, 
        Field10 =case when @Field10='' then Null else @Field10 end, 
        Field11 =case when @Field11='' then Null else @Field11 end,
        Field12 =case when len(@Field12)<10 or @Field12=''then Null else(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field12,'/','')) end, 
        Field13 =case when @Field13='' then Null else @Field13 end,
        Field14 =case when @Field14='' then Null else @Field14 end, 
        Field15 =case when @Field15='' then Null else @Field15 end,
        Field16 =case when @Field16='' then Null else @Field16 end,
		Field17 =case when len(@Field17)<10 or @Field17=''then Null else(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field17,'/','')) end, 
		Field18 =case when len(@Field18)<10 or @Field18=''then Null else(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field18,'/','')) end, 
		Field19 =case when len(@Field19)<10 or @Field19=''then Null else(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field19,'/','')) end, 
		Field20 =case when len(@Field20)<10 or @Field20=''then Null else(SELECT  [GregorianDate] FROM [dbo].[DimDate] where [PersianInt]=replace(@Field20,'/','')) end, 
        Field21 =case when @Field16='' then Null else @Field16 end,
		UserUpdate =isnull([UserUpdate],'')+'/'+@UserUpdate
    WHERE Id = @Id;

END
GO
/****** Object:  StoredProcedure [dbo].[Update_Users]    Script Date: 01/25/2025 2:40:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- alter date: <alter Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Update_Users] 
@id int,
@user nvarchar(50),
@pass nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
update [dbo].[Users] set [UserName] =@user , [Password]=@pass where UserID=@id

END
 


GO
