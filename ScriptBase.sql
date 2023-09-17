/****** Object:  Table [dbo].[Articulo2]    Script Date: 16/9/2023 21:09:32 ******/
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
/****** Object:  Table [dbo].[ArticuloInter2]    Script Date: 16/9/2023 21:09:32 ******/
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
/****** Object:  Table [dbo].[ClaseArticulo2]    Script Date: 16/9/2023 21:09:32 ******/
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
/****** Object:  Table [dbo].[DBErrors]    Script Date: 16/9/2023 21:09:32 ******/
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
/****** Object:  Table [dbo].[EventLog1]    Script Date: 16/9/2023 21:09:32 ******/
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
/****** Object:  Table [dbo].[Usuario2]    Script Date: 16/9/2023 21:09:32 ******/
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
/****** Object:  StoredProcedure [dbo].[BorradoLogico]    Script Date: 16/9/2023 21:09:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[BorradoLogico]
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

    -- Insert statements for procedure here
    BEGIN TRY
		-- Inicia codigo en el cual se captura errores

		DECLARE @LogDescription VARCHAR(2000)='Insertando en tabla Articulo: {Nombre="'
		
		SET @outResultCode=0;  -- Por default codigo error 0 es que no hubo error

		IF NOT EXISTS (SELECT 1 FROM dbo.Articulo2 A 
		WHERE (A.Codigo=@inCodigo))
		BEGIN
			 --procesar error
			SET @outResultCode=50001;		-- Articulo no exist
			SELECT @outResultCode
			RETURN;
		END; 

		UPDATE [dbo].[Articulo2] SET [EsActivo] = 0 WHERE [dbo].[Articulo2].Codigo=@inCodigo
		SELECT @outResultCode
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
END
GO
/****** Object:  StoredProcedure [dbo].[BuscarUsuario]    Script Date: 16/9/2023 21:09:32 ******/
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
	, @inIP VARCHAR(64)
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
		DECLARE @LogDescription VARCHAR(2000)='{TipoAccion=<'
		SET @outResultCode=0;  -- Por default codigo error 0 es que no hubo error
		DECLARE @Uid INT
		IF NOT EXISTS (SELECT 1 FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario AND A.Clave=@inClave))
		BEGIN
			SET @outResultCode=50001;		-- Articulo no existe
			--SET @Uid = A.id FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario AND A.Clave=@inClave--Consultar al profesor
			SET @LogDescription = 
					@LogDescription+'Login no exitoso> Descripcion=<No usuario>';--CONSULTAR CON EL PROFESRO
		END
		ELSE
		BEGIN
			SET @LogDescription = 
					@LogDescription+'Login exitoso> Descripcion=<'+ @inUsuario+'>';
		END; 
		-- Se hacen otras validaciones ....

		-- se preprocesa lo que luego se actualiza, si es necesario se guarda informacion en variables o en tablas variable

		BEGIN TRANSACTION tRegistroLog  --Consultar IF en

			INSERT INTO dbo.EventLog1(
				[LogDescription]
				, [PostIdUser]
				, [PostIP]
				,[PostTime])
			SELECT 
				@LogDescription
				, A.id
				, @inIP
				, GETDATE()
			FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario AND A.Clave=@inClave)

			-- salvamos en evento log el evento de actualizar el articulo
		COMMIT TRANSACTION tRegistroLog

		END TRY
	BEGIN CATCH

		IF @@TRANCOUNT>0  -- error sucedio dentro de la transaccion
		BEGIN
			ROLLBACK TRANSACTION tRegistroLog; -- se deshacen los cambios realizados
		END;
		INSERT INTO dbo.DBErrors	VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
		);
		SET @outResultCode=50005;
	
	END CATCH

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[FiltrarCantidad]    Script Date: 16/9/2023 21:09:32 ******/
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
	@inCantidad int
	, @outResultCode INT OUTPUT	

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

	DECLARE @medio INT;

	BEGIN TRY
		SET @outResultCode=0;
		SELECT @outResultCode AS Error;					--Primero siempre la table de errores para comprobar en capa logica.
		SELECT  TOP (@inCantidad) A.Codigo, A.Nombre, CA.Nombre, A.Precio FROM dbo.Articulo2 A 
		INNER JOIN dbo.ClaseArticulo2 CA on A.idClaseArticulo= CA.id
		WHERE A.EsActivo = 1 ORDER BY A.Nombre
		SELECT A.Nombre AS Nombre FROM dbo.ClaseArticulo2 A
		ORDER BY Nombre;
		
		
	END TRY
	BEGIN CATCH										--En caso de cualquier error coloque el codigo 50003
		SET @outResultCode=50003;					--Pase por dataset el error
		SELECT @outResultCode AS Error;
	END CATCH

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[FiltrarClase]    Script Date: 16/9/2023 21:09:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[FiltrarClase]
(
-----------------------------------Sin Terminar-----------------------------------
    -- Add the parameters for the stored procedure here
    @inClase VARCHAR(128)
	, @outResultCode INT OUTPUT	
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
    BEGIN TRY
		SET @outResultCode=0;
		SELECT @outResultCode AS Error;					--Primero siempre la table de errores para comprobar en capa logica.
		SELECT A.Codigo, A.Nombre, CA.Nombre, A.Precio FROM dbo.Articulo2 A 
		INNER JOIN dbo.ClaseArticulo2 CA on A.idClaseArticulo=CA.id
		WHERE A.EsActivo = 1 AND CA.Nombre=@inClase ORDER BY A.Nombre
		SELECT A.Nombre FROM dbo.ClaseArticulo2 A
		ORDER BY Nombre;
	END TRY
	BEGIN CATCH										--En caso de cualquier error coloque el codigo 50003
		SET @outResultCode=50003;					--Pase por dataset el error
		SELECT @outResultCode AS Error;
	END CATCH

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[FiltrarNombre]    Script Date: 16/9/2023 21:09:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[FiltrarNombre]
(
-----------------------------------Sin Terminar-----------------------------------
    -- Add the parameters for the stored procedure here
    @inNombre VARCHAR(256)
	, @outResultCode INT OUTPUT	
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
    BEGIN TRY
		SET @outResultCode=0;
		SELECT @outResultCode AS Error;					--Primero siempre la table de errores para comprobar en capa logica.
		SELECT A.Codigo, A.Nombre, CA.Nombre, A.Precio FROM dbo.Articulo2 A 
		INNER JOIN dbo.ClaseArticulo2 CA on A.idClaseArticulo=CA.id
		WHERE A.EsActivo = 1 AND A.Nombre LIKE ('%'+@inNombre+'%')  ORDER BY A.Nombre
		SELECT A.Nombre FROM dbo.ClaseArticulo2 A
		ORDER BY Nombre;
	END TRY
	BEGIN CATCH										--En caso de cualquier error coloque el codigo 50003
		SET @outResultCode=50003;					--Pase por dataset el error
		SELECT @outResultCode AS Error;
	END CATCH

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[InsertarArticulo]    Script Date: 16/9/2023 21:09:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertarArticulo] 
	 @inClase VARCHAR(128)		-- Nuevo Nombre de articulo
	, @inCodigo VARCHAR(32)
	, @inNombre VARCHAR(256)
	, @inPrecio MONEY				-- Nuevo Precion
	, @outResultCode INT OUTPUT			-- Codigo de resultado del SP
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Se validan los datos de entrada, pues no estamos seguros que se validaron en capa logica.
	-- Validar que articulo exista.

	BEGIN TRY
		-- Inicia codigo en el cual se captura errores

		DECLARE @LogDescription VARCHAR(2000)='Insertando en tabla Articulo: {Nombre="'
		
		SET @outResultCode=0;  -- Por default codigo error 0 es que no hubo error

		IF EXISTS (SELECT 1 FROM dbo.Articulo2 A 
		WHERE A.Nombre=@inNombre)
		BEGIN
			 --procesar error
			SET @outResultCode=50001;		-- Nombre del articulo ya existe
			RETURN;
		END; 

		IF EXISTS (SELECT 1 FROM dbo.Articulo2 A 
		WHERE A.Codigo=@inCodigo)
		BEGIN
			 --procesar error
			SET @outResultCode=50002;		-- Codigo del articulo ya existe
			RETURN;
		END; 
		-- Se hacen otras validaciones ....

		-- se preprocesa lo que luego se actualiza, si es necesario se guarda informacion en variables o en tablas variable

		SET @LogDescription = 
					@LogDescription+@inNombre
					+'", Precio="'
					+CONVERT(VARCHAR, @inPrecio)+'}';


		-- siempre que vamos a actualizar tablas (y son 2 o mas tablas se inicia transaccion de BD)_
		BEGIN TRANSACTION tInsertarArticulo 
			DECLARE @Inicio bit = 1
			INSERT INTO [dbo].[Articulo2] (
				 [idClaseArticulo]
				 ,[Codigo]
				 ,[Nombre]
				 ,[Precio]
				 ,[EsActivo])
			SELECT CA.id
				,@inCodigo
				,@inNombre
				,@inPrecio
				,@Inicio
			FROM dbo.ClaseArticulo2 CA
			WHERE @inClase=CA.Nombre

		COMMIT TRANSACTION tInsertarArticulo

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT>0  -- error sucedio dentro de la transaccion
		BEGIN
			ROLLBACK TRANSACTION tInsertarArticulo; -- se deshacen los cambios realizados
		END;

		SET @outResultCode=50005;
	
	END CATCH

	SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[ListaArticulos]    Script Date: 16/9/2023 21:09:32 ******/
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
		SELECT A.Nombre FROM dbo.ClaseArticulo2 A
		ORDER BY Nombre;
		
		
	END TRY
	BEGIN CATCH										--En caso de cualquier error coloque el codigo 50003
		SET @outResultCode=50003;					--Pase por dataset el error
		SELECT @outResultCode AS Error;
	END CATCH

	SET NOCOUNT OFF;	
END
GO
/****** Object:  StoredProcedure [dbo].[ListaClaseArticulos]    Script Date: 16/9/2023 21:09:32 ******/
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
/****** Object:  StoredProcedure [dbo].[ModificarArticulo]    Script Date: 16/9/2023 21:09:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ModificarArticulo] 
	  @inID INT
	, @inClase VARCHAR(128)		-- Nuevo Nombre de articulo
	, @inCodigo VARCHAR(32)
	, @inNombre VARCHAR(256)
	, @inPrecio MONEY				-- Nuevo Precion
	, @outResultCode INT OUTPUT			-- Codigo de resultado del SP
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Se validan los datos de entrada, pues no estamos seguros que se validaron en capa logica.
	-- Validar que articulo exista.

	BEGIN TRY
		-- Inicia codigo en el cual se captura errores

		DECLARE @LogDescription VARCHAR(2000)='Insertando en tabla Articulo: {Nombre="'
		
		SET @outResultCode=0;  -- Por default codigo error 0 es que no hubo error

		IF EXISTS (SELECT 1 FROM dbo.Articulo2 A 
		WHERE A.Nombre=@inNombre AND A.id != @inID)
		BEGIN
			 --procesar error
			SET @outResultCode=50001;		-- Nombre del articulo ya existe
			RETURN;
		END; 

		IF EXISTS (SELECT 1 FROM dbo.Articulo2 A 
		WHERE A.Codigo=@inCodigo AND A.id != @inID)
		BEGIN
			 --procesar error
			SET @outResultCode=50002;		-- Codigo del articulo ya existe
			RETURN;
		END;
		-- Se hacen otras validaciones ....

		-- se preprocesa lo que luego se actualiza, si es necesario se guarda informacion en variables o en tablas variable

		--SET @LogDescription = 
		--			@LogDescription+@inNombre
		--			+'", Precio="'
		--			+CONVERT(VARCHAR, @inPrecio)+'}';


		-- siempre que vamos a actualizar tablas (y son 2 o mas tablas se inicia transaccion de BD)_
		BEGIN TRANSACTION tModificarArticulo
			DECLARE @nuevaIDClase INT
			SELECT @nuevaIDClase = CA.id
			FROM [dbo].[ClaseArticulo2] CA
			WHERE CA.Nombre = @inClase;

			UPDATE [dbo].[Articulo2] 
			SET 
				[idClaseArticulo] = @nuevaIDClase
				,[Codigo] = @inCodigo
				,[Nombre] = @inNombre
				,[Precio] = @inPrecio

			WHERE [dbo].[Articulo2].id = @inID

		COMMIT TRANSACTION tModificarArticulo

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT>0  -- error sucedio dentro de la transaccion
		BEGIN
			ROLLBACK TRANSACTION tModificarArticulo; -- se deshacen los cambios realizados
		END;

		SET @outResultCode=50005;
	
	END CATCH

	SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[ObtenerArticuloPorClase]    Script Date: 16/9/2023 21:09:32 ******/
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
		
		SET @outResultCode=0;  -- Por default codigo error 0 es que no hubo error
		SELECT @outResultCode AS Error;
		SELECT CA.Nombre, A.Nombre, A.Precio, A.id FROM dbo.Articulo2 A 
		INNER JOIN dbo.ClaseArticulo2 CA ON A.idClaseArticulo = CA.id
		WHERE A.Codigo = @inCodigo;
		
	END TRY
	BEGIN CATCH										--En caso de cualquier error coloque el codigo 50003
		SET @outResultCode=50003;					--Pase por dataset el error
		SELECT @outResultCode AS Error;
	END CATCH

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[PruebaXML]    Script Date: 16/9/2023 21:09:32 ******/
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
/****** Object:  StoredProcedure [dbo].[ValidarCodigoArticulo]    Script Date: 16/9/2023 21:09:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [dbo].[ValidarCodigoArticulo]
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

		IF NOT EXISTS (SELECT 1 FROM dbo.Articulo2 A 
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
