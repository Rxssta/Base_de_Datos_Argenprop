-- EJERCICIO 8) --

-------------------- SP TIPOPROPIEDAD --------------------
DROP PROCEDURE IF EXISTS CrearTablaTipoPropiedad;
GO

CREATE PROCEDURE CrearTablaTipoPropiedad
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Argenprop.sys.objects WHERE object_id = OBJECT_ID(N'dbo.TIPOPROPIEDAD') AND type IN (N'U'))
    BEGIN
        CREATE TABLE Argenprop.dbo.TIPOPROPIEDAD (
            IDTipoPropiedad INT PRIMARY KEY IDENTITY(1,1),
            Descripción VARCHAR(100) NOT NULL
        );
    END
END;
GO
-------------------- SP PROVINCIA --------------------
DROP PROCEDURE IF EXISTS CrearTablaProvincia;
GO

CREATE PROCEDURE CrearTablaProvincia
AS
BEGIN
    -- Crear tabla PROVINCIA sin columna IDProvincia como identidad.
    IF NOT EXISTS (SELECT * FROM Argenprop.sys.objects WHERE object_id = OBJECT_ID(N'dbo.PROVINCIA') AND type IN (N'U'))
    BEGIN
        CREATE TABLE Argenprop.dbo.PROVINCIA (
            IDProvincia CHAR(1) PRIMARY KEY,  -- Cambiado a CHAR(1).
            Nombre NVARCHAR(100) NOT NULL
        );
    END
END;
GO

-------------------- SP MUNICIPIO --------------------
DROP PROCEDURE IF EXISTS CrearTablaMunicipio;
GO

CREATE PROCEDURE CrearTablaMunicipio
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Argenprop.sys.objects WHERE object_id = OBJECT_ID(N'dbo.MUNICIPIO') AND type IN (N'U'))
    BEGIN
        CREATE TABLE Argenprop.dbo.MUNICIPIO (
            IDMunicipio INT NOT NULL,
            Nombre NVARCHAR(100) COLLATE Latin1_General_100_CI_AS_SC_UTF8 NOT NULL,
			IDDepartamento INT NOT NULL,
			IDProvincia CHAR(1) NOT NULL,
			FOREIGN KEY (IDDepartamento,IDProvincia) REFERENCES Argenprop.dbo.DEPARTAMENTO(IDDepartamento,IDProvincia),
			PRIMARY KEY (IDMunicipio, IDDepartamento, IDProvincia)
        );
    END
END;
GO
-------------------- SP USUARIO --------------------
DROP PROCEDURE IF EXISTS CrearTablaUsuario;
GO

CREATE PROCEDURE CrearTablaUsuario
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Argenprop.sys.objects WHERE object_id = OBJECT_ID(N'dbo.USUARIO') AND type IN (N'U'))
    BEGIN
        CREATE TABLE Argenprop.dbo.USUARIO (
            IDUsuario INT PRIMARY KEY IDENTITY(1,1),
            Nombre VARCHAR(50) NOT NULL,
            Apellido VARCHAR(50) NOT NULL,
            Email VARCHAR(100) NOT NULL UNIQUE,
            Telefono VARCHAR(15) NOT NULL,
            Contraseña VARBINARY(8000) NOT NULL,
            FechaRegistro DATETIME DEFAULT GETDATE(),
			FechaBaja DATETIME DEFAULT NULL,
        );
    END
END;
GO
-------------------- SP ANUNCIANTE --------------------
DROP PROCEDURE IF EXISTS CrearTablaAnunciante;
GO

CREATE PROCEDURE CrearTablaAnunciante
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Argenprop.sys.objects WHERE object_id = OBJECT_ID(N'dbo.ANUNCIANTE') AND type IN (N'U'))
    BEGIN
        CREATE TABLE Argenprop.dbo.ANUNCIANTE (
            IDAnunciante INT PRIMARY KEY IDENTITY(1,1),
            IDUsuario INT NOT NULL,
            TipoAnunciante VARCHAR(50) NOT NULL,
            Empresa VARCHAR(100) NOT NULL,
            Reseña VARCHAR(255),
            FOREIGN KEY (IDUsuario) REFERENCES Argenprop.dbo.USUARIO(IDUsuario) ON DELETE CASCADE
        );
    END
END;
GO
-------------------- SP INTERESADO --------------------
DROP PROCEDURE IF EXISTS CrearTablaInteresado;
GO

CREATE PROCEDURE CrearTablaInteresado
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Argenprop.sys.objects WHERE object_id = OBJECT_ID(N'dbo.INTERESADO') AND type IN (N'U'))
    BEGIN
        CREATE TABLE Argenprop.dbo.INTERESADO (
            IDInteresado INT PRIMARY KEY IDENTITY(1,1),
            IDUsuario INT NOT NULL,
            CantContactos INT NOT NULL,
            FOREIGN KEY (IDUsuario) REFERENCES Argenprop.dbo.USUARIO(IDUsuario) ON DELETE CASCADE
        );
    END
END;
GO
-------------------- SP ADMINISTRADOR --------------------
DROP PROCEDURE IF EXISTS CrearTablaAdministrador;
GO

CREATE PROCEDURE CrearTablaAdministrador
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Argenprop.sys.objects WHERE object_id = OBJECT_ID(N'dbo.ADMINISTRADOR') AND type IN (N'U'))
    BEGIN
        CREATE TABLE Argenprop.dbo.ADMINISTRADOR (
            IDAdministrador INT PRIMARY KEY IDENTITY(1,1),
			IDUsuario INT NOT NULL,
            Nombre VARCHAR(50) NOT NULL,
            Email VARCHAR(100) NOT NULL UNIQUE,
			FOREIGN KEY (IDUsuario) REFERENCES Argenprop.dbo.USUARIO(IDUsuario)
        );
    END
END;
GO

-------------------- SP PROPIEDAD --------------------
DROP PROCEDURE IF EXISTS CrearTablaPropiedad;
GO

CREATE PROCEDURE CrearTablaPropiedad
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Argenprop.sys.objects WHERE object_id = OBJECT_ID(N'dbo.PROPIEDAD') AND type IN (N'U'))
    BEGIN
        CREATE TABLE Argenprop.dbo.PROPIEDAD (
            IDPropiedad INT PRIMARY KEY IDENTITY(1,1),
            IDAnunciante INT NOT NULL,
            Cp VARCHAR(10),
            Nro INT NOT NULL,
            Calle VARCHAR(100) NOT NULL,
            IDTipoPropiedad INT NOT NULL,
            IDMunicipio INT NOT NULL,
            CantHab INT,
            Tam DECIMAL(10, 2),
            Descripción VARCHAR(255),
            FecCrea DATETIME DEFAULT GETDATE(),
            FecPubli DATETIME,
			IDDepartamento INT NOT NULL,
			IDProvincia CHAR(1) NOT NULL,
			Estado VARCHAR(10),
            FOREIGN KEY (IDAnunciante) REFERENCES Argenprop.dbo.ANUNCIANTE(IDAnunciante) ON DELETE CASCADE,
            FOREIGN KEY (IDTipoPropiedad) REFERENCES Argenprop.dbo.TIPOPROPIEDAD(IDTipoPropiedad),
            FOREIGN KEY (IDMunicipio, IDDepartamento, IDProvincia) REFERENCES Argenprop.dbo.MUNICIPIO(IDMunicipio, IDDepartamento, IDProvincia)
        );
    END
END;
GO
-------------------- SP ALQUILER --------------------
DROP PROCEDURE IF EXISTS CrearTablaPrecioAlquiler;
GO

CREATE PROCEDURE CrearTablaPrecioAlquiler
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Argenprop.sys.objects WHERE object_id = OBJECT_ID(N'dbo.PRECIOALQUILER') AND type IN (N'U'))
    BEGIN
        CREATE TABLE Argenprop.dbo.PRECIOALQUILER (
            IDPrecioAlquiler INT PRIMARY KEY IDENTITY(1,1),
            IDPropiedad INT NOT NULL,
            Expensas DECIMAL(18, 2),
            PrecioAlquiler DECIMAL(18, 2),
            FOREIGN KEY (IDPropiedad) REFERENCES Argenprop.dbo.PROPIEDAD(IDPropiedad)
        );
    END
END;
GO

-------------------- SP VENTA --------------------
DROP PROCEDURE IF EXISTS CrearTablaPrecioVenta;
GO

CREATE PROCEDURE CrearTablaPrecioVenta
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Argenprop.sys.objects WHERE object_id = OBJECT_ID(N'dbo.PRECIOVENTA') AND type IN (N'U'))
    BEGIN
        CREATE TABLE Argenprop.dbo.PRECIOVENTA (
            IDPrecioVenta INT PRIMARY KEY IDENTITY(1,1),
            IDPropiedad INT NOT NULL,
            PrecioVenta DECIMAL(18, 2),
            FOREIGN KEY (IDPropiedad) REFERENCES Argenprop.dbo.PROPIEDAD(IDPropiedad)
        );
    END
END;
GO

-------------------- SP DEPARTAMENTO --------------------
DROP PROCEDURE IF EXISTS CrearTablaDepartamento;
GO

CREATE PROCEDURE CrearTablaDepartamento
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Argenprop.sys.objects WHERE object_id = OBJECT_ID(N'dbo.DEPARTAMENTO') AND type IN (N'U'))
    BEGIN
        CREATE TABLE Argenprop.dbo.DEPARTAMENTO (
            IDDepartamento INT NOT NULL,
            Nombre NVARCHAR(100) COLLATE Latin1_General_100_CI_AS_SC_UTF8 NOT NULL,
			IDProvincia CHAR(1) NOT NULL,
			FOREIGN KEY (IDProvincia) REFERENCES Argenprop.dbo.PROVINCIA(IDProvincia),
			PRIMARY KEY (IDDepartamento,IDProvincia)
        );
    END
END;
GO

-------------------- SP ACCION --------------------
DROP PROCEDURE IF EXISTS CrearTablaAccion;
GO

CREATE PROCEDURE CrearTablaAccion
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM Argenprop.sys.objects WHERE object_id = OBJECT_ID(N'dbo.ACCION') AND type IN (N'U'))
	BEGIN
		CREATE TABLE Argenprop.dbo.ACCION (
			IDAccion INT PRIMARY KEY IDENTITY(1,1),
			Tipo VARCHAR(50)
		);
	END
END;
GO

-------------------- SP HISTORIALPROPIEDAD --------------------
DROP PROCEDURE IF EXISTS CrearTablaHistorialPropiedad;
GO

CREATE PROCEDURE CrearTablaHistorialPropiedad
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Argenprop.sys.objects WHERE object_id = OBJECT_ID(N'dbo.HISTORIALPROPIEDAD') AND type IN (N'U'))
    BEGIN
        CREATE TABLE Argenprop.dbo.HISTORIALPROPIEDAD (
            IDHistorial INT PRIMARY KEY IDENTITY(1,1),
            IDPropiedad INT NOT NULL,
            FecCambio DATETIME DEFAULT GETDATE(),
            PrecioAntiguo DECIMAL(18, 2),
			Usuario VARCHAR(50),
			Accion INT NOT NULL,
            FOREIGN KEY (IDPropiedad) REFERENCES Argenprop.dbo.PROPIEDAD(IDPropiedad),
			FOREIGN KEY (Accion) REFERENCES Argenprop.dbo.ACCION(IDAccion)
        );
    END
END;
GO

-------------------- SP CONTACTO --------------------
DROP PROCEDURE IF EXISTS CrearTablaContacto;
GO

CREATE PROCEDURE CrearTablaContacto
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Argenprop.sys.objects WHERE object_id = OBJECT_ID(N'dbo.CONTACTO') AND type IN (N'U'))
    BEGIN
        CREATE TABLE Argenprop.dbo.CONTACTO (
            IDContacto INT PRIMARY KEY IDENTITY(1,1),
            IDInteresado INT NOT NULL,
            IDAnunciante INT NOT NULL,
			IDPropiedad INT NOT NULL,
            FecContac DATETIME DEFAULT GETDATE(),
            Mensaje VARCHAR(255),
            FOREIGN KEY (IDInteresado) REFERENCES Argenprop.dbo.INTERESADO(IDInteresado),
			FOREIGN KEY (IDPropiedad) REFERENCES Argenprop.dbo.PROPIEDAD(IDPropiedad),
            FOREIGN KEY (IDAnunciante) REFERENCES Argenprop.dbo.ANUNCIANTE(IDAnunciante)
        );
    END
END;
GO

-------------------- SP CREAR DB --------------------
DROP PROCEDURE IF EXISTS p_CrearDB;
GO

CREATE PROCEDURE p_CrearDB
    @borrar_si_existe BIT
AS
BEGIN
    IF @borrar_si_existe = 1
    BEGIN
        -- Borrar DB si existe
        IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Argenprop')
        BEGIN
            ALTER DATABASE Argenprop SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
            DROP DATABASE Argenprop;
        END
    END

    CREATE DATABASE Argenprop;

    EXEC CrearTablaTipoPropiedad;
    EXEC CrearTablaProvincia;
	EXEC CrearTablaDepartamento;
    EXEC CrearTablaMunicipio;
    EXEC CrearTablaUsuario;
    EXEC CrearTablaAnunciante;
    EXEC CrearTablaInteresado;
    EXEC CrearTablaPropiedad;
    EXEC CrearTablaPrecioAlquiler;  
    EXEC CrearTablaPrecioVenta;
	EXEC CrearTablaAccion;
    EXEC CrearTablaHistorialPropiedad;
    EXEC CrearTablaAdministrador;
    EXEC CrearTablaContacto;
END;
GO

-- Ejecutar SP CrearDB
EXEC p_CrearDB @borrar_si_existe = 1;
GO

-- EJERCICIO 9) --

USE Argenprop

DROP PROCEDURE IF EXISTS p_LimpiarDatos;
GO

CREATE PROCEDURE p_LimpiarDatos
AS
BEGIN
    DELETE FROM Argenprop.dbo.CONTACTO;              -- Depende de USUARIO y ANUNCIANTE
    DELETE FROM Argenprop.dbo.HISTORIALPROPIEDAD;    -- Depende de PROPIEDAD

    DELETE FROM Argenprop.dbo.PRECIOALQUILER;              -- Depende de ESTADOPROPIEDAD
    DELETE FROM Argenprop.dbo.PRECIOVENTA;                 -- Depende de ESTADOPROPIEDAD
    DELETE FROM Argenprop.dbo.PROPIEDAD;             -- Depende de ANUNCIANTE
    DELETE FROM Argenprop.dbo.ANUNCIANTE;            -- Depende de USUARIO
    DELETE FROM Argenprop.dbo.ADMINISTRADOR;         -- Depende de USUARIO
    DELETE FROM Argenprop.dbo.INTERESADO;            -- Depende de USUARIO

    DELETE FROM Argenprop.dbo.MUNICIPIO;             -- Depende de PROVINCIA
    DELETE FROM Argenprop.dbo.DEPARTAMENTO;          -- Depende de MUNICIPIO

    DELETE FROM Argenprop.dbo.TIPOPROPIEDAD;
    DELETE FROM Argenprop.dbo.PROVINCIA;
    DELETE FROM Argenprop.dbo.USUARIO;
	DELETE FROM Argenprop.dbo.ACCION;
END;

EXEC p_LimpiarDatos;

-- EJERCICIO 10) --

-- SP CARGAR MUNICIPIOS
DROP PROCEDURE IF EXISTS p_CargarMunicipios;
GO

CREATE PROCEDURE p_CargarMunicipios
    @filePath NVARCHAR(255)
AS
BEGIN
    -- Crear tabla temporal para cargar los municipios
    CREATE TABLE #TempMunicipios (
        OBJECTID INT,
        Entidad INT,
        Objeto NVARCHAR(100),
        FNA NVARCHAR(200),
        GNA NVARCHAR(100),
        NAM NVARCHAR(100),
        SAG NVARCHAR(100),
        FDC NVARCHAR(100),
        IN1 INT,
        SHAPE_STAr NVARCHAR(50),
        SHAPE_STLe NVARCHAR(50)
    );

    -- Cargar datos desde el archivo CSV
    DECLARE @bulkInsert NVARCHAR(MAX);
    SET @bulkInsert = 'BULK INSERT #TempMunicipios 
                       FROM ''' + @filePath + ''' 
                       WITH (FIELDTERMINATOR = '';'', 
                             ROWTERMINATOR = ''\n'', 
                             FIRSTROW = 2, 
                             CODEPAGE = ''65001'')';  -- Usar CODEPAGE 65001 para UTF-8
    EXEC sp_executesql @bulkInsert;

    -- Crear tablas temporales para departamentos y provincias
    CREATE TABLE #Departamentos (
        IDDepartamento INT,
        IDProvincia CHAR(1)
    );

    -- Cargar departamentos y sus provincias
    INSERT INTO #Departamentos (IDDepartamento, IDProvincia)
    SELECT IDDepartamento, IDProvincia FROM Argenprop.dbo.DEPARTAMENTO;

    -- Asignar IDDepartamento e IDProvincia a cada municipio
    INSERT INTO Argenprop.dbo.MUNICIPIO (IDMunicipio, Nombre, IDDepartamento, IDProvincia)
        SELECT 
            td.OBJECTID AS IDMunicipio,  
            td.NAM,
            d.IDDepartamento,
            d.IDProvincia
        FROM #TempMunicipios td
        JOIN (
            SELECT IDDepartamento, IDProvincia,
                   ROW_NUMBER() OVER (ORDER BY IDDepartamento) AS rn
            FROM #Departamentos
        ) d ON td.OBJECTID % (SELECT COUNT(*) FROM #Departamentos) = d.rn - 1;

    -- Eliminar las tablas temporales
    DROP TABLE #TempMunicipios;
    DROP TABLE #Departamentos;
END;
GO
-------------------- SP CARGAR DEPARTAMENTOS --------------------
DROP PROCEDURE IF EXISTS p_CargarDepartamentos;
GO

CREATE PROCEDURE p_CargarDepartamentos
    @filePath NVARCHAR(255)
AS
BEGIN
    -- Crear tabla temporal para cargar los departamentos
    CREATE TABLE #TempDepartamentos (
        OBJECTID INT,  
        Entidad INT,
        Objeto NVARCHAR(100),
        FNA NVARCHAR(200),
        GNA NVARCHAR(100),
        NAM NVARCHAR(100),
        SAG NVARCHAR(100),
        FDC NVARCHAR(100),
        IN1 INT,
        SHAPE_STAr NVARCHAR(50),
        SHAPE_STLe NVARCHAR(50)
    );

    -- Cargar datos desde el archivo CSV
    DECLARE @bulkInsert NVARCHAR(MAX);
    SET @bulkInsert = 'BULK INSERT #TempDepartamentos 
                       FROM ''' + @filePath + ''' 
                       WITH (FIELDTERMINATOR = '';'', 
                             ROWTERMINATOR = ''\n'', 
                             FIRSTROW = 2, 
                             CODEPAGE = ''65001'')';  -- Usar CODEPAGE 65001 para UTF-8
    EXEC sp_executesql @bulkInsert;
    
    -- Crear tabla temporal para las provincias
    CREATE TABLE #Provincias (
        IDProvincia CHAR(1)
    );

    -- Cargar provincias
    INSERT INTO #Provincias (IDProvincia)
    SELECT IDProvincia FROM Argenprop.dbo.PROVINCIA;

    -- Asignar IDProvincia a cada departamento de manera única
    INSERT INTO Argenprop.dbo.DEPARTAMENTO (IDDepartamento, Nombre, IDProvincia)
    SELECT 
        td.OBJECTID AS IDDepartamento,  
        td.NAM AS Nombre,
        p.IDProvincia
    FROM #TempDepartamentos td
    JOIN (
        SELECT IDProvincia, ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn
        FROM #Provincias
    ) p ON td.OBJECTID % (SELECT COUNT(*) FROM #Provincias) = p.rn - 1;

    -- Eliminar las tablas temporales
    DROP TABLE #TempDepartamentos;
    DROP TABLE #Provincias;
END;
GO

-------------------- SP CARGAR PROVINCIAS --------------------
DROP PROCEDURE IF EXISTS p_CargarProvincias;
GO

CREATE PROCEDURE p_CargarProvincias
    @filePath NVARCHAR(255)
AS
BEGIN
    -- Crear tabla temporal
    CREATE TABLE #TempProvincias (Codigo CHAR(1), Nombre NVARCHAR(100));
    
    -- Cargar datos desde el archivo CSV con la opción de CODEPAGE para UTF-8
    DECLARE @bulkInsert NVARCHAR(MAX);
    SET @bulkInsert = 'BULK INSERT #TempProvincias 
                       FROM ''' + @filePath + ''' 
                       WITH (FIELDTERMINATOR = '';'', 
                             ROWTERMINATOR = ''\n'', 
                             FIRSTROW = 2, 
                             CODEPAGE = ''65001'')';  -- Usar CODEPAGE 65001 para UTF-8
    EXEC sp_executesql @bulkInsert;
	  
    -- Insertar los datos en la tabla final
    INSERT INTO Argenprop.dbo.PROVINCIA (IDProvincia, Nombre)
    SELECT DISTINCT 
        Codigo,  
        Nombre
    FROM #TempProvincias
    WHERE Codigo NOT IN (SELECT IDProvincia FROM Argenprop.dbo.PROVINCIA);

    -- Eliminar la tabla temporal
    DROP TABLE #TempProvincias;
END;
GO

-------------------- SP CARGAR DATASET --------------------
DROP PROCEDURE IF EXISTS p_CargarDataset;
GO

CREATE PROCEDURE p_CargarDataset
    @tipo NVARCHAR(50),
    @filePath NVARCHAR(255)
AS
BEGIN
    -- Verificar el tipo de dataset y llamar al procedimiento correspondiente
    IF @tipo = 'Provincias'
    BEGIN
        EXEC p_CargarProvincias @filePath;
    END
    ELSE IF @tipo = 'Departamentos'
    BEGIN
        EXEC p_CargarDepartamentos @filePath;
    END
    ELSE IF @tipo = 'Municipios'
    BEGIN
        EXEC p_CargarMunicipios @filePath;
    END
    ELSE
    BEGIN
        PRINT 'Tipo de dataset no reconocido. Por favor, use "Provincias", "Departamentos" o "Municipios".';
    END
END;
GO

-- Cargar provincias
EXEC p_CargarDataset 'Provincias', '..\TP_03-Argenprop-Provincias.csv';
 -- Listar datos de PROVINCIA
SELECT * FROM Argenprop.dbo.PROVINCIA; 

-- Cargar departamentos
EXEC p_CargarDataset 'Departamentos', '..\TP_03-Argenprop-Departamento.csv';
-- Listar datos de DEPARTAMENTO
SELECT * FROM Argenprop.dbo.DEPARTAMENTO;

-- Cargar municipios
EXEC p_CargarDataset 'Municipios', '..\TP_03-Argenprop-municipio.csv';
-- Listar datos de MUNICIPIO
SELECT * FROM Argenprop.dbo.MUNICIPIO;
 
GO

-- EJERCICIO 11) --

DROP PROCEDURE IF EXISTS p_CargarTipoPropiedad
GO
--------------------------------------------------
CREATE PROCEDURE p_CargarTipoPropiedad
AS
BEGIN
	INSERT INTO Argenprop.dbo.TIPOPROPIEDAD(Descripción) VALUES
	('Casa'),
	('Departamento'),
	('Terreno'),
	('Oficina');
END;
GO

-------------------------------------------------------
DROP PROCEDURE IF EXISTS p_CargarAccion
GO

CREATE PROCEDURE p_CargarAccion
AS
BEGIN
    INSERT INTO Argenprop.dbo.ACCION (Tipo) VALUES
	('Insert'),
	('Delete'),
	('Update');
END;
GO
----------------------------------------------------------------
DROP PROCEDURE IF EXISTS p_CargaAleatoria;
GO
CREATE PROCEDURE p_CargaAleatoria
	@numUsuarios INT,
	@numPropiedades INT,
	@numContactos INT
AS
BEGIN
	-- Cargar datos aleatorios en la tabla USUARIO
		DECLARE @i INT = 1;
		
		DECLARE @nombre NVARCHAR(50);
		DECLARE @apellido NVARCHAR(50);
		DECLARE @email NVARCHAR(100);
		DECLARE @telefono NVARCHAR(15);
		DECLARE @contraseña NVARCHAR(100);
		DECLARE @idUsuario INT;
		DECLARE @idAnunciante INT;
		DECLARE @idInteresado INT;
		DECLARE @idPropiedad INT;
		DECLARE @idMunicipio INT;
		DECLARE @idDepartamento INT;
		DECLARE @idProvincia CHAR(1);
		DECLARE @idAdministrador INT;
		DECLARE @idTipoPropiedad INT;
		DECLARE @fecha DATE;
		DECLARE @estado VARCHAR(10);
		DECLARE @FecCrea DATETIME;
		DECLARE @FecPubli DATETIME;

	EXEC p_CargarTipoPropiedad 
	EXEC p_CargarAccion
	
	WHILE @i <= @numUsuarios
	BEGIN
		SET @nombre = CONCAT('Nombre', @i);
		SET @apellido = CONCAT('Apellido', @i);
		SET @telefono = CONCAT('12345', CAST(@i AS NVARCHAR(5)));
		SET @contraseña = 'Contraseña123';
		SET @email = CONCAT('usuario', @i, '@example.com');
		SET @fecha = GETDATE() - @i;
    
		INSERT INTO Argenprop.dbo.USUARIO (Nombre, Apellido, Email, Telefono, Contraseña, FechaRegistro)
		VALUES (@nombre, @apellido, @email, @telefono, ENCRYPTBYPASSPHRASE('password', @contraseña), @fecha);
    
		SET @i = @i + 1;
	END;

	-- Cargar datos aleatorios en la tabla ANUNCIANTE
	SET @i = 1;
	DECLARE @idUsuarioAnunciante INT;
	DECLARE @usedUsers TABLE (IDUsuario INT);

	WHILE @i <= @numUsuarios / 2
	BEGIN
		SELECT TOP 1 @idUsuarioAnunciante = IDUsuario 
		FROM Argenprop.dbo.USUARIO 
		WHERE IDUsuario NOT IN (SELECT IDUsuario FROM @usedUsers)
		ORDER BY NEWID();  

		INSERT INTO Argenprop.dbo.ANUNCIANTE (IDUsuario, TipoAnunciante, Empresa, Reseña)
		VALUES (@idUsuarioAnunciante, 
				CASE WHEN RAND() < 0.5 THEN 'Propietario' ELSE 'Inmobiliaria' END, 
				'Empresa' + CAST(@i AS NVARCHAR(5)), 
				'Reseña de empresa' + CAST(@i AS NVARCHAR(5)));

		INSERT INTO @usedUsers (IDUsuario) VALUES (@idUsuarioAnunciante);
		SET @i = @i + 1;
	END

	-- Cargar datos aleatorios en la tabla INTERESADOS
	DECLARE @idUsuarioInteresado INT;
	SET @i = 1;

	WHILE @i <= (@numUsuarios / 2)-1
	BEGIN
		SELECT TOP 1 @idUsuarioInteresado = IDUsuario 
		FROM Argenprop.dbo.USUARIO 
		WHERE IDUsuario NOT IN (SELECT IDUsuario FROM @usedUsers)
		ORDER BY NEWID();  

		INSERT INTO Argenprop.dbo.INTERESADO (IDUsuario, CantContactos)
		VALUES (@idUsuarioInteresado, CAST(RAND() * 100 AS INT));

		INSERT INTO @usedUsers (IDUsuario) VALUES (@idUsuarioInteresado);
		SET @i = @i + 1;
	END

	-- Cargar datos aleatorios en la tabla ADMINISTRADOR
	-- Obtener IDs no utilizados
	DECLARE @idUsuarioAdministrador INT;
	SET @i = 1;

	-- Seleccionar y crear administradores para cada ID no utilizado
	WHILE @i <= (SELECT COUNT(*) FROM Argenprop.dbo.USUARIO WHERE IDUsuario NOT IN (SELECT IDUsuario FROM @usedUsers))
	BEGIN
		SELECT TOP 1 @idUsuarioAdministrador = IDUsuario 
		FROM Argenprop.dbo.USUARIO 
		WHERE IDUsuario NOT IN (SELECT IDUsuario FROM @usedUsers)
		ORDER BY NEWID();

		-- Insertar nuevo administrador
		INSERT INTO Argenprop.dbo.ADMINISTRADOR (Nombre, Email, IDUsuario)
		SELECT 
			Nombre,
			Email,
			IDUsuario
		FROM 
			Argenprop.dbo.USUARIO
		WHERE 
			IDUsuario = @idUsuarioAdministrador;

		INSERT INTO @usedUsers (IDUsuario) VALUES (@idUsuarioAdministrador);

		SET @i = @i + 1;
	END


	-- Cargar datos aleatorios en la tabla PROPIEDAD
	SET @i = 1;

	WHILE @i <= @numPropiedades
	BEGIN
		SELECT TOP 1 @idAnunciante = IDAnunciante FROM Argenprop.dbo.ANUNCIANTE ORDER BY NEWID();
		SELECT TOP 1 @idAdministrador = IDAdministrador FROM Argenprop.dbo.ADMINISTRADOR ORDER BY NEWID();
		SELECT TOP 1 @idMunicipio = IDMunicipio, @idDepartamento = IDDepartamento, @idProvincia = IDProvincia FROM Argenprop.dbo.MUNICIPIO ORDER BY NEWID();
		SET @estado = CASE WHEN CAST(RAND() * 2 AS INT) = 0 THEN 'Alquiler' ELSE 'Venta' END;

		 -- Generar fecha de creación entre hace un mes y cinco años
		SET @FecCrea = DATEADD(DAY, -1 * (RAND() * (365 - 30) + 30), GETDATE()); -- Entre 30 días y 5 años

		-- Generar fecha de publicación dentro del último mes
		SET @FecPubli = DATEADD(DAY, -1 * (RAND() * 30), GETDATE()); -- Últimos 30 días

        
		SELECT TOP 1 @idTipoPropiedad = IDTipoPropiedad FROM Argenprop.dbo.TIPOPROPIEDAD ORDER BY NEWID();

		INSERT INTO Argenprop.dbo.PROPIEDAD (IDAnunciante, Cp, Nro, Calle, IDTipoPropiedad, IDMunicipio, IDDepartamento, IDProvincia, CantHab, Tam, Descripción, Estado, FecCrea, FecPubli)
		VALUES (
			@idAnunciante,
			CONCAT('C', CAST((RAND() * 10000) AS INT)),
			CAST((RAND() * 1000) AS INT),
			CONCAT('Calle ', CAST(FLOOR(RAND() * 10) AS NVARCHAR(5))),
			@idTipoPropiedad,
			@idMunicipio,
			@idDepartamento,
			@idProvincia,
			CAST((RAND() * 5+1) AS INT),
			CAST((RAND() * 500) AS DECIMAL(10, 2)),
			CONCAT('Descripción de la propiedad ', CAST(@i AS NVARCHAR(5))),
			@estado,
			@FecCrea,
			@FecPubli
		);

		SET @i = @i + 1;
	END
	DECLARE @usedPropiedadAlquiler TABLE (IDPropiedad INT);
	SET @i = 1;

		-- Cargar datos aleatorios en la tabla PRECIOALQUILER
		WHILE @i <= (SELECT COUNT(*) FROM Argenprop.dbo.PROPIEDAD WHERE Estado LIKE 'Alquiler')
		BEGIN
			SELECT TOP 1 @idPropiedad = IDPropiedad 
			FROM Argenprop.dbo.PROPIEDAD 
			WHERE Estado LIKE 'Alquiler' AND IDPropiedad NOT IN (SELECT IDPropiedad FROM @usedPropiedadAlquiler)
			ORDER BY NEWID();
        
			INSERT INTO Argenprop.dbo.PRECIOALQUILER(IDPropiedad,PrecioAlquiler,Expensas)
			VALUES (
				@idPropiedad,
				CAST((RAND() * 1000) AS DECIMAL(18, 2)),
				CAST((RAND() * 200) AS DECIMAL(18, 2))
			);

			INSERT INTO @usedPropiedadAlquiler (IDPropiedad) VALUES (@idPropiedad);

			SET @i = @i + 1;
		END

	SET @i = 1;
	DECLARE @usedPropiedadVenta TABLE (IDPropiedad INT);
	-- Cargar datos aleatorios en la tabla PRECIOVENTA
	WHILE @i <= (SELECT COUNT(*) FROM Argenprop.dbo.PROPIEDAD WHERE Estado LIKE 'Venta')
	BEGIN
		SELECT TOP 1 @idPropiedad = IDPropiedad 
		FROM Argenprop.dbo.PROPIEDAD 
		WHERE Estado LIKE 'Venta' AND IDPropiedad NOT IN (SELECT IDPropiedad FROM @usedPropiedadVenta)
		ORDER BY NEWID();
        
		INSERT INTO Argenprop.dbo.PRECIOVENTA(IDPropiedad,PrecioVenta)
		VALUES (
			@idPropiedad,
			CAST((RAND() * 50000) AS DECIMAL(18, 2))
		);

		INSERT INTO @usedPropiedadVenta (IDPropiedad) VALUES (@idPropiedad);
		
		SET @i = @i + 1;
	END

	SET @i = 1;


	-- Cargar datos aleatorios en la tabla CONTACTO

	WHILE @i <= @numContactos
	BEGIN
		SELECT TOP 1 @idInteresado = IDInteresado FROM Argenprop.dbo.INTERESADO ORDER BY NEWID();
		SELECT TOP 1 @idAnunciante = IDAnunciante FROM Argenprop.dbo.ANUNCIANTE ORDER BY NEWID();
		SELECT TOP 1 @idPropiedad = IDPropiedad FROM Argenprop.dbo.PROPIEDAD ORDER BY NEWID();
        SELECT TOP 1 @FecPubli = FecPubli FROM Argenprop.dbo.PROPIEDAD WHERE @IDPropiedad = IDPropiedad;

		INSERT INTO Argenprop.dbo.CONTACTO (IDInteresado, IDAnunciante, IDPropiedad, FecContac, Mensaje)
		VALUES (
			@idInteresado,
			@idAnunciante,
			@idPropiedad,
			@FecPubli,
			CONCAT('Mensaje de contacto ', CAST(@i AS NVARCHAR(5)))
		);

		SET @i = @i + 1;
	END
END;
GO

-- CASO DE PRUEBA -- 

EXEC p_CargaAleatoria 20, 100, 20;
GO 

SELECT * FROM Argenprop.dbo.DEPARTAMENTO
SELECT * FROM Argenprop.dbo.MUNICIPIO
SELECT * FROM Argenprop.dbo.PROVINCIA
SELECT * FROM Argenprop.dbo.ACCION

SELECT * FROM Argenprop.dbo.CONTACTO

SELECT * FROM Argenprop.dbo.PRECIOALQUILER
SELECT * FROM Argenprop.dbo.PRECIOVENTA
SELECT * FROM Argenprop.dbo.TIPOPROPIEDAD
SELECT * FROM Argenprop.dbo.PROPIEDAD

SELECT * FROM Argenprop.dbo.USUARIO
SELECT * FROM Argenprop.dbo.ANUNCIANTE
SELECT * FROM Argenprop.dbo.INTERESADO
SELECT * FROM Argenprop.dbo.ADMINISTRADOR

