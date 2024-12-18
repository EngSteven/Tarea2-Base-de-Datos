/****** Object:  Table [dbo].[Articulo2]    Script Date: 23/9/2023 05:52:30 ******/
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
/****** Object:  Table [dbo].[ArticuloInter2]    Script Date: 23/9/2023 05:52:30 ******/
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
/****** Object:  Table [dbo].[ClaseArticulo2]    Script Date: 23/9/2023 05:52:30 ******/
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
/****** Object:  Table [dbo].[DBErrors]    Script Date: 23/9/2023 05:52:30 ******/
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
/****** Object:  Table [dbo].[EventLog2]    Script Date: 23/9/2023 05:52:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventLog2](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[LogDescription] [varchar](2000) NOT NULL,
	[PostIdUser] [int] NULL,
	[PostIP] [varchar](64) NOT NULL,
	[PostTime] [datetime] NOT NULL,
 CONSTRAINT [PK_EventLog2] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Usuario2]    Script Date: 23/9/2023 05:52:30 ******/
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
ALTER TABLE [dbo].[EventLog2]  WITH CHECK ADD  CONSTRAINT [FK_EventLog2_Usuario2] FOREIGN KEY([PostIdUser])
REFERENCES [dbo].[Usuario2] ([id])
GO
ALTER TABLE [dbo].[EventLog2] CHECK CONSTRAINT [FK_EventLog2_Usuario2]
GO
/****** Object:  StoredProcedure [dbo].[BorradoLogico]    Script Date: 23/9/2023 05:52:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BorradoLogico]
(
    @inCodigo VARCHAR(32)
	, @inUsuario VARCHAR(32)
	, @inIP VARCHAR(64)
	, @outResultCode INT OUTPUT	
)
AS

BEGIN

    SET NOCOUNT ON

    BEGIN TRY

		SET @outResultCode=0;
		--Inicia la descripcion de evento.
		DECLARE @LogDescription VARCHAR(2000)='{TipoAccion=<Borrado de articulo exitoso> Descripcion=<';

		DECLARE @idArticulo INT
		, @idArticuloClase INT
		, @Codigo VARCHAR(32)
		, @Nombre VARCHAR(256)
		, @Cantidad MONEY;

		--Si el articulo no existe, devuelva error.
		IF NOT EXISTS (SELECT 1 FROM dbo.Articulo2 A 
		WHERE (A.Codigo=@inCodigo) AND A.EsActivo = 1)
		BEGIN
			SET @outResultCode=50001;		
		END; 

		--Pase a capa logica los datos de articulo.
		SELECT @idArticulo = A.id 
		, @idArticuloClase = A.idClaseArticulo 
		, @Codigo = A.Codigo 
		, @Nombre = A.Nombre
		, @Cantidad = A.Precio 
		FROM dbo.Articulo2 A 
		WHERE (A.Codigo=@inCodigo)

		--Termine la descripcion del evento.
		SET @LogDescription = 
					@LogDescription + CAST(@idArticulo AS VARCHAR) + '>, <' 
					+ CAST(@idArticuloClase AS VARCHAR) + '>, <' 
					+ @Codigo + '>, <' 
					+ @Nombre  + '>, <' 
					+ CONVERT(VARCHAR, @Cantidad) + '>}';
	
		SELECT @outResultCode

		--Realize el borrado y registro
		BEGIN TRANSACTION tRegistroLog

			UPDATE [dbo].[Articulo2] 
			SET [EsActivo] = 0 
			WHERE [dbo].[Articulo2].Codigo=@inCodigo
			
			INSERT INTO dbo.EventLog2(
				[LogDescription]
				, [PostIdUser]
				, [PostIP]
				,[PostTime])
			SELECT 
				@LogDescription
				, A.id
				, @inIP
				, GETDATE()
			FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario)
		COMMIT TRANSACTION tRegistroLog
	END TRY
	BEGIN CATCH
		--En caso se error deshacer el TRANSACT, registrar el error y devolver el aviso a capa logica.
		IF @@TRANCOUNT>0 
		BEGIN
			ROLLBACK TRANSACTION tRegistroLog;
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
		SELECT @outResultCode AS Error;
	
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[BuscarUsuario]    Script Date: 23/9/2023 05:52:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BuscarUsuario]
(
    @inUsuario VARCHAR(32)
	, @inClave VARCHAR(32)
	, @inIP VARCHAR(64)
	, @outResultCode INT OUTPUT	
)
AS
BEGIN

    SET NOCOUNT ON

	BEGIN TRY

		DECLARE @Usuario INT = NULL

		SET @outResultCode=0;
		
		--Inicia la descripcion de evento.
		DECLARE @LogDescription VARCHAR(2000)='{TipoAccion=<'

		--Si el articulo no existe, devuelva error, sino seleccione el id del usuario. Siempre temine la descripcion del evento.
		IF NOT EXISTS (SELECT 1 FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario AND A.Clave=@inClave))
		BEGIN
			SET @outResultCode=50001;		
			SET @LogDescription = @LogDescription+'Login no exitoso> Descripcion=<null>}';
		END
		ELSE
		BEGIN
			SET @LogDescription = @LogDescription+'Login exitoso> Descripcion=<'+ @inUsuario+'>}';
			SELECT @Usuario = A.id FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario AND A.Clave=@inClave)
		END; 

		--Realize el registro
		BEGIN TRANSACTION tRegistroLog  

			INSERT INTO dbo.EventLog2(
				[LogDescription]
				, [PostIdUser]
				, [PostIP]
				,[PostTime])
			SELECT 
				@LogDescription
				, @Usuario
				, @inIP
				, GETDATE()

		COMMIT TRANSACTION tRegistroLog

		END TRY
	BEGIN CATCH
		--En caso se error deshacer el TRANSACT, registrar el error y devolver el aviso a capa logica.
		IF @@TRANCOUNT>0  
		BEGIN
			ROLLBACK TRANSACTION tRegistroLog;
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
/****** Object:  StoredProcedure [dbo].[FiltrarCantidad]    Script Date: 23/9/2023 05:52:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FiltrarCantidad]
	@inCantidad INT
	, @inUsuario VARCHAR(32)
	, @inIP VARCHAR(64)
	, @outResultCode INT OUTPUT	

AS
BEGIN

    SET NOCOUNT ON

	BEGIN TRY
		
		--Inicia la descripcion de evento.
		DECLARE @LogDescription VARCHAR(2000)='{TipoAccion=<Consulta por cantidad> Descripcion=<'+CAST(@inCantidad AS VARCHAR)+'>}';

		SET @outResultCode=0;
		SELECT @outResultCode AS Error;					
		
		--Retorne a capa logica la cantidad de articulos solicitados.
		SELECT  TOP (@inCantidad) 
		A.Codigo
		, A.Nombre
		, CA.Nombre
		, A.Precio 
		FROM dbo.Articulo2 A 
		INNER JOIN dbo.ClaseArticulo2 CA ON A.idClaseArticulo= CA.id
		WHERE A.EsActivo = 1 ORDER BY A.Nombre
		
		--Retorne la lista de clases.
		SELECT A.Nombre AS Nombre 
		FROM dbo.ClaseArticulo2 A
		ORDER BY Nombre;
		
		--Realize el registro
		BEGIN TRANSACTION tRegistroLog  

			INSERT INTO dbo.EventLog2(
				[LogDescription]
				, [PostIdUser]
				, [PostIP]
				,[PostTime])
			SELECT 
				@LogDescription
				, A.id
				, @inIP
				, GETDATE()
			FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario)

		COMMIT TRANSACTION tRegistroLog
		
	END TRY
	BEGIN CATCH										
		--En caso se error deshacer el TRANSACT, registrar el error y devolver el aviso a capa logica.
		IF @@TRANCOUNT>0  
		BEGIN
			ROLLBACK TRANSACTION tRegistroLog; 
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
		SET @outResultCode=50003;			
		SELECT @outResultCode AS Error;	
	END CATCH

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[FiltrarClase]    Script Date: 23/9/2023 05:52:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FiltrarClase]
(
    @inClase VARCHAR(128)
	, @inUsuario VARCHAR(32)
	, @inIP VARCHAR(64)
	, @outResultCode INT OUTPUT	
)
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
		--Cree la descripcion de evento.
		DECLARE @LogDescription VARCHAR(2000)='{TipoAccion=<Consulta por clase de articulo> Descripcion=<'+@inClase+'>}';
		
		SET @outResultCode=0;
		
		SELECT @outResultCode AS Error;					
		
		--Retorne los articulos en base a la clase.
		SELECT A.Codigo
		, A.Nombre
		, CA.Nombre
		, A.Precio 
		FROM dbo.Articulo2 A 
		INNER JOIN dbo.ClaseArticulo2 CA ON A.idClaseArticulo=CA.id
		WHERE A.EsActivo = 1 AND CA.Nombre=@inClase ORDER BY A.Nombre
		
		--Retorne la lista de clases.
		SELECT A.Nombre 
		FROM dbo.ClaseArticulo2 A
		ORDER BY Nombre;

		--Realize el registro
		BEGIN TRANSACTION tRegistroLog  

			INSERT INTO dbo.EventLog2(
				[LogDescription]
				, [PostIdUser]
				, [PostIP]
				,[PostTime])
			SELECT 
				@LogDescription
				, A.id
				, @inIP
				, GETDATE()
			FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario)


		COMMIT TRANSACTION tRegistroLog
	END TRY
	BEGIN CATCH									
		--En caso se error deshacer el TRANSACT, registrar el error y devolver el aviso a capa logica.
		IF @@TRANCOUNT>0 
		BEGIN
			ROLLBACK TRANSACTION tRegistroLog; 
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
		SET @outResultCode=50003;					
		SELECT @outResultCode AS Error;
	END CATCH

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[FiltrarNombre]    Script Date: 23/9/2023 05:52:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FiltrarNombre]
(
    @inNombre VARCHAR(256)
	, @inUsuario VARCHAR(32)
	, @inIP VARCHAR(64)
	, @outResultCode INT OUTPUT	
)
AS
BEGIN

    SET NOCOUNT ON

    BEGIN TRY
		
		--Cree la descripcion de evento.
		DECLARE @LogDescription VARCHAR(2000)='{TipoAccion=<Consulta por Nombre> Descripcion=<'+@inNombre+'>}';
		
		SET @outResultCode=0;
		
		SELECT @outResultCode AS Error;		
		
		--Retorne los articulos que tengan coincidencia con la entrada.
		SELECT A.Codigo
		, A.Nombre
		, CA.Nombre
		, A.Precio 
		FROM dbo.Articulo2 A 
		INNER JOIN dbo.ClaseArticulo2 CA ON A.idClaseArticulo=CA.id
		WHERE A.EsActivo = 1 AND A.Nombre LIKE ('%'+@inNombre+'%')  ORDER BY A.Nombre
		
		--Retorne la listsa de clases
		SELECT A.Nombre 
		FROM dbo.ClaseArticulo2 A
		ORDER BY Nombre;

		--Realize el registro
		BEGIN TRANSACTION tRegistroLog  

			INSERT INTO dbo.EventLog2(
				[LogDescription]
				, [PostIdUser]
				, [PostIP]
				,[PostTime])
			SELECT 
				@LogDescription
				, A.id
				, @inIP
				, GETDATE()
			FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario)

		COMMIT TRANSACTION tRegistroLog
	END TRY
	BEGIN CATCH		
		--En caso se error deshacer el TRANSACT, registrar el error y devolver el aviso a capa logica.
		IF @@TRANCOUNT>0  
		BEGIN
			ROLLBACK TRANSACTION tRegistroLog; 
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
		SET @outResultCode=50003;					
		SELECT @outResultCode AS Error;
	END CATCH

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[InsertarArticulo]    Script Date: 23/9/2023 05:52:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertarArticulo] 
	 @inClase VARCHAR(128)	
	, @inCodigo VARCHAR(32)
	, @inNombre VARCHAR(256)
	, @inPrecio MONEY	
	, @inUsuario VARCHAR(32)
	, @inIP VARCHAR(64)
	, @outResultCode INT OUTPUT			
AS
BEGIN

	SET NOCOUNT ON;

	BEGIN TRY
		
		--Comienza la descripcion del evento.
		DECLARE @ErrorDescription VARCHAR(100)
		DECLARE @LogDescription VARCHAR(2000)='{TipoAccion=<'
		DECLARE @Uid INT
		DECLARE @idClaseArticulo INT
		SELECT @idClaseArticulo = CA.id
		FROM [dbo].[ClaseArticulo2] CA
		WHERE CA.Nombre = @inClase;

		SET @outResultCode=0;  -- Por default codigo error 0 es que no hubo error

		IF EXISTS (SELECT 1 FROM dbo.Articulo2 A 
		WHERE A.Nombre=@inNombre AND A.EsActivo = 1)
		BEGIN
			 --Procesar error
			SET @outResultCode=50001;		-- Nombre del articulo ya existe
			SET @ErrorDescription ='<Descripción del error: Nombre de articulo duplicado.>}'
			SET @LogDescription =  
					@LogDescription +'Insertar articulo no exitoso> Descripcion=<';
		END; 
		ELSE IF EXISTS (SELECT 1 FROM dbo.Articulo2 A 
		WHERE A.Codigo=@inCodigo AND A.EsActivo = 1)
		BEGIN
			--procesar error
			SET @outResultCode=50002;		-- Codigo del articulo ya existe
			SET @ErrorDescription ='<Descripción del error: Código de articulo duplicado.>}'
			SET @LogDescription = 
					@LogDescription+'Insertar articulo no exitoso> Descripcion=<';
		END; 
		ELSE
		BEGIN
			SET @ErrorDescription = '<>}'
			SET @LogDescription = 
					@LogDescription+'Insertar articulo exitoso> Descripcion=<';
		END; 
		--Termina la descripcion dle evento.
		SET @LogDescription = 
				@LogDescription 
				+ CAST(@idClaseArticulo AS VARCHAR) + '>, <' 
				+ @inCodigo + '>, <' 
				+ @inNombre + '>, <' 
				+ CONVERT(VARCHAR, @inPrecio) + '>, '
				+ @ErrorDescription;

		-- siempre que vamos a actualizar tablas (y son 2 o mas tablas se inicia transaccion de BD)_
		BEGIN TRANSACTION tInsertarArticulo 
			IF @outResultCode != 50001 AND @outResultCode != 50002
			BEGIN
				DECLARE @Inicio bit = 1
				INSERT INTO [dbo].[Articulo2] (
						[idClaseArticulo]
						,[Codigo]
						,[Nombre]
						,[Precio]
						,[EsActivo])
				SELECT @idClaseArticulo
					,@inCodigo
					,@inNombre
					,@inPrecio
					,@Inicio
			END

			INSERT INTO dbo.EventLog2(
				[LogDescription]
				, [PostIdUser]
				, [PostIP]
				,[PostTime])
			SELECT 
				@LogDescription
				, A.id
				, @inIP
				, GETDATE()
			FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario);
		COMMIT TRANSACTION tInsertarArticulo
	END TRY

	BEGIN CATCH
		--En caso se error deshacer el TRANSACT, registrar el error y devolver el aviso a capa logica.
		IF @@TRANCOUNT>0  
		BEGIN
			ROLLBACK TRANSACTION tInsertarArticulo;
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
END;
GO
/****** Object:  StoredProcedure [dbo].[ListaArticulos]    Script Date: 23/9/2023 05:52:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ListaArticulos]
	  @inUsuario VARCHAR(32)
	, @inIP VARCHAR(64)
	, @outResultCode INT OUTPUT	
AS
BEGIN

    SET NOCOUNT ON

	BEGIN TRY
			
		SET @outResultCode=0;
		SELECT @outResultCode AS Error;	
		
		--Crea la descripcion de evento.
		DECLARE @LogDescription VARCHAR(2000)='{TipoAccion=<Cargar lista completa> Descripcion=<>}';
		
		--Retorna todos los articulos.
		SELECT A.Codigo
		, A.Nombre
		, CA.Nombre
		, A.Precio 
		FROM dbo.Articulo2 A 
		INNER JOIN dbo.ClaseArticulo2 CA ON A.idClaseArticulo= CA.id
		WHERE A.EsActivo = 1 ORDER BY A.Nombre
		
		--Retorna lista de clases.
		SELECT A.Nombre 
		FROM dbo.ClaseArticulo2 A
		ORDER BY Nombre;
		
		--Realiza el registro.
		BEGIN TRANSACTION tRegistroLog  

			INSERT INTO dbo.EventLog2(
				[LogDescription]
				, [PostIdUser]
				, [PostIP]
				,[PostTime])
			SELECT 
				@LogDescription
				, A.id
				, @inIP
				, GETDATE()
			FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario)

		COMMIT TRANSACTION tRegistroLog

		
	END TRY
	BEGIN CATCH										
		--En caso se error deshacer el TRANSACT, registrar el error y devolver el aviso a capa logica.
		IF @@TRANCOUNT>0  
		BEGIN
			ROLLBACK TRANSACTION tRegistroLog; 
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
		SET @outResultCode=50003;					
		SELECT @outResultCode AS Error;
	END CATCH

	SET NOCOUNT OFF;	
END
GO
/****** Object:  StoredProcedure [dbo].[ListaClaseArticulos]    Script Date: 23/9/2023 05:52:30 ******/
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
      @inUsuario VARCHAR(32)
	, @inIP VARCHAR(64)
	, @outResultCode INT OUTPUT						--Al ser un SP solo de consulta solo se tendra una variable para errores
	 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

	BEGIN TRY
		SET @outResultCode=0;
		SELECT @outResultCode AS Error;					--Primero siempre la table de errores para comprobar en capa logica.
		
		DECLARE @LogDescription VARCHAR(2000)='{TipoAccion=<Cargar lista de clases completa> Descripcion=<>}';

		SELECT A.Nombre FROM dbo.ClaseArticulo2 A
		ORDER BY A.Nombre;		--La tabla con el contenido ordenada alfabeticamente.
		
		BEGIN TRANSACTION tRegistroLog  

			INSERT INTO dbo.EventLog2(
				[LogDescription]
				, [PostIdUser]
				, [PostIP]
				,[PostTime])
			SELECT 
				@LogDescription
				, A.id
				, @inIP
				, GETDATE()
			FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario)

			-- salvamos en evento log el evento de actualizar el articulo
		COMMIT TRANSACTION tRegistroLog

	END TRY
	BEGIN CATCH										--En caso de cualquier error coloque el codigo 50003
		SET @outResultCode=50003;					--Pase por dataset el error
		SELECT @outResultCode AS Error;
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
	END CATCH

	SET NOCOUNT OFF;	
END
GO
/****** Object:  StoredProcedure [dbo].[LogOut]    Script Date: 23/9/2023 05:52:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[LogOut]
	  @inUsuario VARCHAR(32)
	, @inIP VARCHAR(64)
	, @outResultCode INT OUTPUT	
AS
BEGIN

    SET NOCOUNT ON

    BEGIN TRY

		SET @outResultCode=0;

		--Crea el registro de eventos.
		DECLARE @LogDescription VARCHAR(2000)='{TipoAccion=<Logout> Descripcion=<>}';

		--Realiza el registro.
		BEGIN TRANSACTION tRegistroLog  

			INSERT INTO dbo.EventLog2(
				[LogDescription]
				, [PostIdUser]
				, [PostIP]
				,[PostTime])
			SELECT 
				@LogDescription
				, A.id
				, @inIP
				, GETDATE()
			FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario)

		COMMIT TRANSACTION tRegistroLog

	END TRY
	BEGIN CATCH
		--En caso se error deshacer el TRANSACT, registrar el error y devolver el aviso a capa logica.
		IF @@TRANCOUNT>0  
		BEGIN
			ROLLBACK TRANSACTION tRegistroLog;
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
		SET @outResultCode=50003;		
	END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[ModificarArticulo]    Script Date: 23/9/2023 05:52:30 ******/
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
	, @inUsuario VARCHAR(32)
	, @inIP VARCHAR(64) 
	, @outResultCode INT OUTPUT			-- Codigo de resultado del SP
AS
BEGIN

	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @nuevaIDClase INT

		SELECT @nuevaIDClase = CA.id
		FROM [dbo].[ClaseArticulo2] CA
		WHERE CA.Nombre = @inClase;
		
		--obtener el id clase articulo, codigo, nombre y precio anterior
		DECLARE @idClaseAnterior INT
		DECLARE @codigoAnterior VARCHAR(32)
		DECLARE @nombreAnterior VARCHAR(256)
		DECLARE @precioAnterior MONEY

		SELECT @idClaseAnterior = A.idClaseArticulo  
			   ,@codigoAnterior = A.Codigo
			   ,@nombreAnterior = A.Nombre
			   ,@precioAnterior = A.Precio
		FROM [dbo].[Articulo2] A 
		WHERE A.id = @inID 

		DECLARE @ErrorDescription VARCHAR(100)
		DECLARE @LogDescription VARCHAR(2000)='{TipoAccion=<'
		
		SET @outResultCode=0;  -- Por default codigo error 0 es que no hubo error

		--Caso en el que el nombre ingresado ya exista
		IF EXISTS (SELECT 1 FROM dbo.Articulo2 A 
		WHERE A.Nombre=@inNombre AND A.id != @inID AND A.EsActivo = 1)
		BEGIN
			 --procesar error
			SET @outResultCode=50001;		-- Nombre del articulo ya existe
			SET @ErrorDescription ='<Descripción del error: Nombre de articulo duplicado.>}'
			SET @LogDescription =  
					@LogDescription +'Modificación de articulo no exitoso> Descripcion=<';
		END; 

		--Caso en el que el codigo ingresado ya exista
		ELSE IF EXISTS (SELECT 1 FROM dbo.Articulo2 A 
		WHERE A.Codigo=@inCodigo AND A.id != @inID AND A.EsActivo = 1)
		BEGIN
			 --procesar error
			SET @outResultCode=50002;		-- Codigo del articulo ya existe
			SET @ErrorDescription ='<Descripción del error: Código de articulo duplicado>}'
			SET @LogDescription =  
					@LogDescription +'Modificación de articulo no exitoso> Descripcion=<';
		
		END;
		ELSE
		--Caso en el que los datos ingresados sean validos
		BEGIN
			SET @ErrorDescription = '<>}'
			SET @LogDescription =  
					@LogDescription +'Modificación de articulo exitoso> Descripcion=<';
					
		END; 

		SET @LogDescription = 
				@LogDescription 
				+ CAST(@inID AS VARCHAR) + '>, <' 
				+ CAST(@idClaseAnterior AS VARCHAR) + '>, <'
				+ @codigoAnterior + '>, <'
				+ @nombreAnterior + '>, <'
				+ CONVERT(VARCHAR, @precioAnterior) + '>, <'
				+ CAST(@nuevaIDClase AS VARCHAR) + '>, <'
				+ @inCodigo + '>, <' 
				+ @inNombre + '>, <' 
				+ CONVERT(VARCHAR, @inPrecio) + '>, '
				+ @ErrorDescription;
	
		-- siempre que vamos a actualizar tablas (y son 2 o mas tablas se inicia transaccion de BD)_
		BEGIN TRANSACTION tModificarArticulo
			INSERT INTO dbo.EventLog2(
				[LogDescription]
				, [PostIdUser]
				, [PostIP]
				,[PostTime])
			SELECT 
				@LogDescription
				, A.id
				, @inIP
				, GETDATE()
			FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario);

			IF @outResultCode != 50001 AND @outResultCode != 50002
			BEGIN
				UPDATE [dbo].[Articulo2] 
				SET 
					[idClaseArticulo] = @nuevaIDClase
					,[Codigo] = @inCodigo
					,[Nombre] = @inNombre
					,[Precio] = @inPrecio

				WHERE [dbo].[Articulo2].id = @inID
			END

		COMMIT TRANSACTION tModificarArticulo

	END TRY
	BEGIN CATCH
		--En caso se error deshacer el TRANSACT, registrar el error y devolver el aviso a capa logica.
		IF @@TRANCOUNT>0 
		BEGIN
			ROLLBACK TRANSACTION tModificarArticulo; 
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
END;
GO
/****** Object:  StoredProcedure [dbo].[ObtenerArticuloPorClase]    Script Date: 23/9/2023 05:52:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ObtenerArticuloPorClase]
(
    @inCodigo VARCHAR(32)
	, @inUsuario VARCHAR(32)
	, @inIP VARCHAR(64)
	, @outResultCode INT OUTPUT	
)
AS
BEGIN
    SET NOCOUNT ON

	BEGIN TRY
		
		--Inicia el registro de evento.
		DECLARE @LogDescription VARCHAR(2000)='{TipoAccion=<Carga de articulos por codigo> Descripcion=<';

		SET @outResultCode=0;  -- Por default codigo error 0 es que no hubo error
		SELECT @outResultCode AS Error;
		
		--Retorna el articulo cuyo codigo coincida.
		SELECT CA.Nombre
		, A.Nombre
		, A.Precio
		, A.id 
		FROM dbo.Articulo2 A 
		INNER JOIN dbo.ClaseArticulo2 CA ON A.idClaseArticulo = CA.id
		WHERE A.Codigo = @inCodigo AND A.EsActivo = 1;
		
		--Termina el registro de evento.
		SET @LogDescription = 
							@LogDescription +@inCodigo+'>}'

		--Realiza el registro
		BEGIN TRANSACTION tRegistroLog  

			INSERT INTO dbo.EventLog2(
				[LogDescription]
				, [PostIdUser]
				, [PostIP]
				,[PostTime])
			SELECT 
				@LogDescription
				, A.id
				, @inIP
				, GETDATE()
			FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario)

		COMMIT TRANSACTION tRegistroLog

	END TRY
	BEGIN CATCH				
		--En caso se error deshacer el TRANSACT, registrar el error y devolver el aviso a capa logica.
		IF @@TRANCOUNT>0  
		BEGIN
			ROLLBACK TRANSACTION tRegistroLog; 
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
		
		SET @outResultCode=50003;					
		SELECT @outResultCode AS Error;
	END CATCH

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[ValidarCodigoArticulo]    Script Date: 23/9/2023 05:52:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ValidarCodigoArticulo]
(
    @inCodigo VARCHAR(32)
	, @inTipoAccion VARCHAR(16)
	, @inUsuario VARCHAR(32)
	, @inIP VARCHAR(64)
	, @outResultCode INT OUTPUT	
)
AS
BEGIN

    SET NOCOUNT ON

	BEGIN TRY
		--Inicia el registro de eventos.
		DECLARE @LogDescription VARCHAR(2000)='{TipoAccion=<';
		
		SET @outResultCode=0;  

		--Se selecciona el caso.
		IF (@inTipoAccion = '3')
		BEGIN
			SET @LogDescription = @LogDescription + 'Intento de borrar articulo> Descripcion=<'+@inCodigo+'>,<Usuario no confirmo borrado>'
		END;
		IF (@inTipoAccion = '2')
		BEGIN
			SET @LogDescription = @LogDescription + 'Intento de borrar articulo> Descripcion=<'+@inCodigo+'>,<'
		END;
		IF (@inTipoAccion = '1')
		BEGIN
			SET @LogDescription = @LogDescription + 'Intento de modificar articulo> Descripcion=<'+@inCodigo+'>,<'
		END;

		--Se termina el registro de eventos bajo la condicion.
		IF NOT EXISTS (SELECT 1 FROM dbo.Articulo2 A 
		WHERE (A.Codigo=@inCodigo) AND A.EsActivo = 1)
		BEGIN
			SET @LogDescription = @LogDescription + 'Articulo no existe>}'
			SET @outResultCode=50001;		-- Articulo no existe
		END; 
		ELSE IF(@inTipoAccion != '3')
		BEGIN
			SET @LogDescription = @LogDescription + 'Articulo existe>}'
		END; 

		--Se realiza el registro.
		BEGIN TRANSACTION tRegistroLog  

			INSERT INTO dbo.EventLog2(
				[LogDescription]
				, [PostIdUser]
				, [PostIP]
				,[PostTime])
			SELECT 
				@LogDescription
				, A.id
				, @inIP
				, GETDATE()
			FROM dbo.Usuario2 A WHERE (A.Nombre=@inUsuario)

		COMMIT TRANSACTION tRegistroLog
	END TRY
	BEGIN CATCH
		--En caso se error deshacer el TRANSACT, registrar el error y devolver el aviso a capa logica.
		IF @@TRANCOUNT>0 
		BEGIN
			ROLLBACK TRANSACTION tRegistroLog;
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
		SET @outResultCode=50003;					
		SELECT @outResultCode AS Error;
	
	END CATCH

	SET NOCOUNT OFF;
END

GO
