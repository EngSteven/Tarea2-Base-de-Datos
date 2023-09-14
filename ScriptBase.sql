/****** Object:  Table [dbo].[Articulo2]    Script Date: 13/9/2023 20:55:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Articulo2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idClaseArticulo] [int] NOT NULL,
	[Codigo] [varchar](32) NOT NULL,
	[Nombre] [varchar](256) NOT NULL,
	[Precio] [money] NOT NULL,
	[EsActivo] [bit] NOT NULL,
 CONSTRAINT [PK_Articulo2] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ArticuloInter2]    Script Date: 13/9/2023 20:55:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ArticuloInter2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[codigo] [varchar](32) NOT NULL,
	[nombre] [varchar](256) NOT NULL,
	[clase] [varchar](128) NOT NULL,
	[precio] [money] NOT NULL,
 CONSTRAINT [PK_ArticuloInter2] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ClaseArticulo2]    Script Date: 13/9/2023 20:55:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClaseArticulo2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](128) NOT NULL,
 CONSTRAINT [PK_ClaseArticulo2] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DBErrors]    Script Date: 13/9/2023 20:55:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DBErrors](
	[ErrorID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](100) NULL,
	[ErrorNumber] [int] NULL,
	[ErrorState] [int] NULL,
	[ErrorSeverity] [int] NULL,
	[ErrorLine] [int] NULL,
	[ErrorProcedure] [varchar](max) NULL,
	[ErrorMessage] [varchar](max) NULL,
	[ErrorDateTime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EventLog1]    Script Date: 13/9/2023 20:55:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventLog1](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[LogDescription] [varchar](2000) NOT NULL,
	[PostIdUser] [int] NOT NULL,
	[PostIP] [varchar](64) NOT NULL,
	[PostTime] [datetime] NOT NULL,
 CONSTRAINT [PK_EventLog1] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Usuario2]    Script Date: 13/9/2023 20:55:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usuario2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](32) NOT NULL,
	[Clave] [varchar](32) NOT NULL,
 CONSTRAINT [PK_Usuario2] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Articulo2]  WITH CHECK ADD  CONSTRAINT [FK_Articulo2_ClaseArticulo2] FOREIGN KEY([idClaseArticulo])
REFERENCES [dbo].[ClaseArticulo2] ([id])
GO
ALTER TABLE [dbo].[Articulo2] CHECK CONSTRAINT [FK_Articulo2_ClaseArticulo2]
GO
ALTER TABLE [dbo].[EventLog1]  WITH CHECK ADD  CONSTRAINT [FK_EventLog1_Usuario2] FOREIGN KEY([PostIdUser])
REFERENCES [dbo].[Usuario2] ([id])
GO
ALTER TABLE [dbo].[EventLog1] CHECK CONSTRAINT [FK_EventLog1_Usuario2]
GO
/****** Object:  StoredProcedure [dbo].[BuscarUsuario]    Script Date: 13/9/2023 20:55:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[BuscarUsuario]
(
-----------------------------------Sin Terminar-----------------------------------
    -- Add the parameters for the stored procedure here
    @inUsuario VARCHAR(32)
	, @inClave VARCHAR(32)
	, @outResultCode INT OUTPUT	
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
	-- Se validan los datos de entrada, pues no estamos seguros que se validaron en capa logica.
	-- Validar que articulo exista.

	BEGIN TRY
		-- Inicia codigo en el cual se captura errores

		DECLARE @LogDescription VARCHAR(2000)='Insertando en tabla Articulo: {Nombre="'
		
		SET @outResultCode=0;  -- Por default codigo error 0 es que no hubo error

		IF NOT EXISTS (SELECT 1 FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario AND A.Clave=@inClave))
		BEGIN
			 --procesar error
			SET @outResultCode=50001;		-- Articulo no exist
			RETURN;
		END; 
		-- Se hacen otras validaciones ....

		-- se preprocesa lo que luego se actualiza, si es necesario se guarda informacion en variables o en tablas variable

		--SET @LogDescription = 
					--@LogDescription+@inNombre
					--+'", Precio="'
					--+CONVERT(VARCHAR, @inPrecio)+'}';
		END TRY
	BEGIN CATCH

		IF @@TRANCOUNT>0  -- error sucedio dentro de la transaccion
		BEGIN
			ROLLBACK TRANSACTION tCrearArticulo; -- se deshacen los cambios realizados
		END;

		SET @outResultCode=50005;
	
	END CATCH

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[FiltrarCantidad]    Script Date: 13/9/2023 20:55:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[FiltrarCantidad]
	@inCatidad INT
	, @outResultCode INT OUTPUT	

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

	BEGIN TRY
		SET @outResultCode=0;
		SELECT @outResultCode AS Error;					--Primero siempre la table de errores para comprobar en capa logica.
		SELECT (@inCatidad) [A.Codigo], A.Nombre, CA.Nombre, A.Precio FROM dbo.Articulo2 A 
		INNER JOIN dbo.ClaseArticulo2 CA on A.idClaseArticulo= CA.id
		WHERE A.EsActivo = 1 ORDER BY A.Nombre
		
		
	END TRY
	BEGIN CATCH										--En caso de cualquier error coloque el codigo 50003
		SET @outResultCode=50003;					--Pase por dataset el error
		SELECT @outResultCode AS Error;
	END CATCH

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[ListaArticulos]    Script Date: 13/9/2023 20:55:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[ListaArticulos]
	 @outResultCode INT OUTPUT	
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

	BEGIN TRY
		SET @outResultCode=0;
		SELECT @outResultCode AS Error;					--Primero siempre la table de errores para comprobar en capa logica.
		SELECT A.Codigo, A.Nombre, CA.Nombre, A.Precio FROM dbo.Articulo2 A 
		INNER JOIN dbo.ClaseArticulo2 CA on A.idClaseArticulo= CA.id
		WHERE A.EsActivo = 1 ORDER BY A.Nombre
		
		
	END TRY
	BEGIN CATCH										--En caso de cualquier error coloque el codigo 50003
		SET @outResultCode=50003;					--Pase por dataset el error
		SELECT @outResultCode AS Error;
	END CATCH

	SET NOCOUNT OFF;	
END
GO
/****** Object:  StoredProcedure [dbo].[ListaClaseArticulos]    Script Date: 13/9/2023 20:55:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[ListaClaseArticulos]
	 @outResultCode INT OUTPUT						--Al ser un SP solo de consulta solo se tendra una variable para errores
	 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

	BEGIN TRY
		SET @outResultCode=0;
		SELECT @outResultCode AS Error;					--Primero siempre la table de errores para comprobar en capa logica.
		SELECT Nombre FROM dbo.ClaseArticulo2 
		ORDER BY Nombre;		--La tabla con el contenido ordenada alfabeticamente.
		
	END TRY
	BEGIN CATCH										--En caso de cualquier error coloque el codigo 50003
		SET @outResultCode=50003;					--Pase por dataset el error
		SELECT @outResultCode AS Error;
	END CATCH

	SET NOCOUNT OFF;	
END
GO
/****** Object:  StoredProcedure [dbo].[ObtenerArticuloPorClase]    Script Date: 13/9/2023 20:55:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[ObtenerArticuloPorClase]
(
-----------------------------------Sin Terminar-----------------------------------
    -- Add the parameters for the stored procedure here
    @inCodigo VARCHAR(32)
	, @outResultCode INT OUTPUT	
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
	-- Se validan los datos de entrada, pues no estamos seguros que se validaron en capa logica.
	-- Validar que articulo exista.

	BEGIN TRY
		-- Inicia codigo en el cual se captura errores

		DECLARE @LogDescription VARCHAR(2000)='Insertando en tabla Articulo: {Nombre="'
		
		SET @outResultCode=0;  -- Por default codigo error 0 es que no hubo error

		IF EXISTS (SELECT idClaseArticulo, Nombre, Precio FROM dbo.Articulo2 A 
		WHERE (A.Codigo=@inCodigo))

		BEGIN
			 --procesar error
			SET @outResultCode=50001;		-- Articulo no exist
			RETURN;
		END; 
		-- Se hacen otras validaciones ....

		-- se preprocesa lo que luego se actualiza, si es necesario se guarda informacion en variables o en tablas variable

		--SET @LogDescription = 
					--@LogDescription+@inNombre
					--+'", Precio="'
					--+CONVERT(VARCHAR, @inPrecio)+'}';
		END TRY
	BEGIN CATCH

		IF @@TRANCOUNT>0  -- error sucedio dentro de la transaccion
		BEGIN
			ROLLBACK TRANSACTION tCrearArticulo; -- se deshacen los cambios realizados
		END;

		SET @outResultCode=50005;
	
	END CATCH

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[PruebaXML]    Script Date: 13/9/2023 20:55:38 ******/
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
	BEGIN TRY
	DECLARE @Inicio bit = 1
	BEGIN TRANSACTION COPIARTABLA
	INSERT INTO [dbo].[Articulo2] ([idClaseArticulo]
      ,[Codigo]
      ,[Nombre]
      ,[Precio]
      ,[EsActivo])
	SELECT CA.id
	,A.codigo
	,A.nombre
	,A.precio
	,@Inicio
	FROM dbo.ArticuloInter2 A
	INNER JOIN dbo.ClaseArticulo2 CA on A.clase=CA.Nombre

	COMMIT TRANSACTION COPIARTABLA 
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0  -- error sucedio dentro de la transaccion
		BEGIN
			ROLLBACK TRANSACTION COPIARTABLA; -- se deshacen los cambios realizados
		END;
	END CATCH
END
GO
