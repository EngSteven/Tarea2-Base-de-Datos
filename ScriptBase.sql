/****** Object:  Table [dbo].[Articulo1]    Script Date: 6/9/2023 05:30:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Articulo1](
	[id] [int] NOT NULL,
	[idClaseArticulo] [int] NOT NULL,
	[Codigo] [varchar](32) NOT NULL,
	[Nombre] [varchar](256) NOT NULL,
	[Precio] [money] NOT NULL,
	[EsActivo] [bit] NOT NULL,
 CONSTRAINT [PK_Articulo1] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ClaseArticulo]    Script Date: 6/9/2023 05:30:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClaseArticulo](
	[id] [int] NOT NULL,
	[Nombre] [varchar](128) NOT NULL,
 CONSTRAINT [PK_ClaseArticulo] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EventLog]    Script Date: 6/9/2023 05:30:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventLog](
	[id] [int] NOT NULL,
	[LogDescription] [varchar](2000) NOT NULL,
	[PostIdUser] [int] NOT NULL,
	[PostIP] [varchar](64) NOT NULL,
	[PostTime] [datetime] NOT NULL,
 CONSTRAINT [PK_EventLog] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Prueba2]    Script Date: 6/9/2023 05:30:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Prueba2](
	[id] [int] NOT NULL,
	[Usuario] [varchar](50) NOT NULL,
	[Contra] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Prueba2] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Usuario]    Script Date: 6/9/2023 05:30:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usuario](
	[id] [int] NOT NULL,
	[Nombre] [varchar](32) NOT NULL,
	[Clave] [varchar](32) NOT NULL,
 CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Articulo1] ADD  CONSTRAINT [DF_Articulo1_EsActivo]  DEFAULT ((1)) FOR [EsActivo]
GO
ALTER TABLE [dbo].[Articulo1]  WITH CHECK ADD  CONSTRAINT [FK_Articulo1_ClaseArticulo] FOREIGN KEY([idClaseArticulo])
REFERENCES [dbo].[ClaseArticulo] ([id])
GO
ALTER TABLE [dbo].[Articulo1] CHECK CONSTRAINT [FK_Articulo1_ClaseArticulo]
GO
ALTER TABLE [dbo].[EventLog]  WITH CHECK ADD  CONSTRAINT [FK_EventLog_Usuario] FOREIGN KEY([PostIdUser])
REFERENCES [dbo].[Usuario] ([id])
GO
ALTER TABLE [dbo].[EventLog] CHECK CONSTRAINT [FK_EventLog_Usuario]
GO
/****** Object:  StoredProcedure [dbo].[PruebaXML]    Script Date: 6/9/2023 05:30:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[PruebaXML]
--(
	--@inRutaXML NVARCHAR(500)
--)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

	DECLARE @Datos XML
	DECLARE @Comando NVARCHAR(500)= 'SELECT @Datos = D FROM OPENROWSET (BULK' + CHAR(39) +'C:\Users\Usuario\Documents\Cuarto Semestre\Bases I\Proyectos\Prueba.xml' + CHAR(39)+', SINGLE_BLOB) AS Dato(D)'
    -- Insert statements for procedure here
	DECLARE @Parametros NVARCHAR(500)
	SET @Parametros = N'@Datos xml OUTPUT'

	EXECUTE sp_executesql @Comando, @Parametros, @Datos OUTPUT
	DECLARE @hdoc int 
	EXECUTE sp_xml_preparedocument @hdoc OUTPUT, @Datos

	INSERT INTO [dbo].[Prueba2]
	(
	[Usuario]
	,[Contra]
	)
	SELECT * FROM OPENXML (@hdoc, '/Usuarios/usuario', 1)
	WITH (
	Usuario VARCHAR(50),
	Contra VARCHAR(50)
	)
END
GO
