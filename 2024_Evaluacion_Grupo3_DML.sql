-- EJERCICIO 12) --

USE Argenprop

------- TRIGGER: AUDITAR PRECIOS -------

DROP TRIGGER IF EXISTS tg_auditar
GO

CREATE TRIGGER tg_auditar
ON Argenprop.dbo.PRECIOVENTA
AFTER INSERT,UPDATE,DELETE
AS
BEGIN

	IF EXISTS(SELECT * FROM deleted) AND EXISTS (SELECT * FROM inserted)
	BEGIN
		INSERT INTO Argenprop.dbo.HISTORIALPROPIEDAD (IDPropiedad, PrecioAntiguo, Usuario, Accion)
		SELECT 
			D.IDPropiedad, 
			D.Precioventa,
			SYSTEM_USER,
			'UPDATE'
		FROM 
			deleted D
		INNER JOIN 
			inserted I ON D.IDPropiedad = I.IDPropiedad
		WHERE 
			D.PrecioVenta <> I.PrecioVenta;
		RETURN;
	END

	IF EXISTS(SELECT * FROM inserted)
		BEGIN
		INSERT INTO Argenprop.dbo.HISTORIALPROPIEDAD (IDPropiedad, PrecioAntiguo, Usuario, Accion)
		SELECT 
			I.IDPropiedad, 
			I.PrecioVenta,
			SYSTEM_USER,
			'INSERT'
		FROM 
			inserted I
		RETURN;
	END

	IF EXISTS(SELECT * FROM deleted D)
	BEGIN
		INSERT INTO Argenprop.dbo.HISTORIALPROPIEDAD (IDPropiedad, PrecioAntiguo, Usuario, Accion)
		SELECT 
			D.IDPropiedad, 
			D.PrecioVenta,
			SYSTEM_USER,
			'DELETE'
		FROM 
			deleted D
		RETURN;
	END

END;

-- EJERCICIO 13) --

DROP FUNCTION IF EXISTS dbo.f_funcion1;
GO

------- FUNCIÓN I: CONVERSIÓN DE DIVISAS ------
CREATE FUNCTION dbo.f_funcion1 (@precioVenta FLOAT, @tasaCambio FLOAT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @precioARS FLOAT;

    -- Convertir el precio a ARS
    SET @precioARS = @precioVenta * @tasaCambio;

    -- Formato
    RETURN FORMAT(@precioARS, 'N2') + ' ARS';
END;
GO

-- CASO DE PRUEBA --

SELECT 
    P.IDPropiedad,
    PV.PrecioVenta AS PrecioVentaUSD,
    dbo.f_funcion1(PV.PrecioVenta,1200) AS PrecioVentaARS
FROM 
    PROPIEDAD P
INNER JOIN 
    PRECIOVENTA PV ON P.IDPropiedad = PV.IDPropiedad;

-- EJERCICIO 14) --

------- FUNCIÓN II: CONTROLAR CONTRASEÑA ------
DROP FUNCTION IF EXISTS f_funcion2;
GO

CREATE FUNCTION dbo.f_funcion2(@contraseña varchar(13))
RETURNS BIT
AS
BEGIN
	DECLARE @valid BIT
	SET @valid = 1

	-- Verifica un mínimo de 8 caracteres

	IF(LEN(@contraseña) < 8)
		SET @valid = 0

	-- Verifica que haya al menos una minúscula.
	-- Como no es case-sensitive, use convert y lo pasé a varbinary que es
	-- la string con sus valores ASCII a binario.

	IF(CONVERT(VARBINARY(13),UPPER(@contraseña)) = CONVERT(VARBINARY(13),@contraseña))
		SET @valid = 0

	-- Verifica que haya al menos una máyúscula.

	IF(CONVERT(VARBINARY(13),LOWER(@contraseña)) = CONVERT(VARBINARY(13),@contraseña))
		SET @valid = 0

	-- Verifica que haya números.
	-- Use una funcion que verifica si un patrón pasado como parámetro
	-- y como expresión regular se encuentra en la cadena.

	IF(PATINDEX('%[0-9]%',@contraseña) = 0)
		SET @valid = 0

	-- Verifica que haya símbolos especiales.

	IF(PATINDEX('%[^a-zA-Z0-9]%',@contraseña) = 0)
		SET @valid = 0

	RETURN @valid
END;
GO

-- CASO DE PRUEBA --

SELECT dbo.f_funcion2('P@ssw0rd1'); -- Debe devolver 1

-- Prueba 2: Contraseña demasiado corta
SELECT dbo.f_funcion2('P@1a'); -- Debe devolver 0

-- Prueba 3: Sin caracteres especiales
SELECT dbo.f_funcion2('Password1'); -- Debe devolver 0

-- Prueba 4: Sin números
SELECT dbo.f_funcion2('P@ssword'); -- Debe devolver 0

-- Prueba 5: Sin mayúsculas
SELECT dbo.f_funcion2('p@ssw0rd'); -- Debe devolver 0

-- Prueba 6: Sin minúsculas
SELECT dbo.f_funcion2('P@SSWORD1'); -- Debe devolver 0

-- EJERCICIO 15) --

USE Argenprop

------- VISTA I: TOP 10 CASAS MÁS CARAS -------

DROP VIEW IF EXISTS v_vista1;
GO

CREATE VIEW v_vista1 AS
SELECT TOP 10 
    P.IDPropiedad AS IDPropiedadesMasCaras, 
    PV.PrecioVenta AS PrecioUSD, 
    --dbo.f_funcion1(PV.PrecioVenta, 1200) AS PrecioARS,  -- funcion conversion de divisas
    P.Calle, 
    P.Nro
FROM 
    Argenprop.dbo.PROPIEDAD P
INNER JOIN 
     Argenprop.dbo.TIPOPROPIEDAD T ON P.IDTipoPropiedad = T.IDTipoPropiedad
INNER JOIN 
     Argenprop.dbo.PRECIOVENTA PV ON P.IDPropiedad = PV.IDPropiedad
WHERE 
    T.Descripción LIKE 'Casa'
ORDER BY 
    PV.PrecioVenta DESC;
GO

-- CASO DE PRUEBA --

SELECT * FROM v_vista1;

------- VISTA II: ANÁLISIS ANUAL DE CANTIDAD DE CONTACTOS -------

DROP VIEW IF EXISTS v_vista2;
GO

CREATE VIEW v_vista2 AS
SELECT 
    P.IDPropiedad,
    P.Calle,
    P.Nro,
    T.Descripción,
    COUNT(C.IDPropiedad) AS TotalContactosAnuales
FROM Argenprop.dbo.PROPIEDAD AS P
LEFT JOIN 
    Argenprop.dbo.CONTACTO AS C ON P.IDPropiedad = C.IDPropiedad 
JOIN 
    Argenprop.dbo.TIPOPROPIEDAD AS T ON T.IDTipoPropiedad = P.IDTipoPropiedad
WHERE YEAR(C.FecContac) = YEAR(GETDATE())
GROUP BY P.IDPropiedad, P.Calle, P.Nro, T.Descripción
GO

-- CASO DE PRUEBA --

SELECT * FROM v_vista2;

SELECT COUNT(*) FROM Argenprop.dbo.CONTACTO WHERE YEAR(FecContac) = YEAR(GETDATE())


------- VISTA III: RECURSIVIDAD DE JERARQUIAS CON PROPIEDADES -------

DROP VIEW IF EXISTS v_vista3;
GO

CREATE VIEW v_vista3
AS
	WITH Jerarquia AS(
    -- NIVEL 0
    SELECT 
        P.IDPropiedad,
		T.Descripción,
		P.Calle,
		P.Nro,
		P.Tam,
		Pr.PrecioVenta,
		0 AS Expensas,
        P.Estado
    FROM 
        Argenprop.dbo.PROPIEDAD P
	INNER JOIN 
        Argenprop.dbo.PRECIOVENTA Pr ON P.IDPropiedad = Pr.IDPropiedad
	INNER JOIN 
        Argenprop.dbo.TIPOPROPIEDAD T ON P.IDTipoPropiedad = T.IDTipoPropiedad
    WHERE 
        P.Estado = 'Venta'

    UNION ALL
    
   SELECT 
        P.IDPropiedad,
		T.Descripción,
		P.Calle,
		P.Nro,
		P.Tam,
		Pr.PrecioAlquiler,
		Pr.Expensas,
        P.Estado
    FROM 
        Argenprop.dbo.PROPIEDAD P
	INNER JOIN 
        Argenprop.dbo.PRECIOALQUILER Pr ON P.IDPropiedad = Pr.IDPropiedad
	INNER JOIN 
        Argenprop.dbo.TIPOPROPIEDAD T ON P.IDTipoPropiedad = T.IDTipoPropiedad
    WHERE 
        P.Estado = 'Alquiler'
	 )

	SELECT * FROM Jerarquia
GO

-- CASO DE PRUEBA --
SELECT * FROM v_vista3

-- EJERCICIO 16) --

------- REPORTE 1: MUESTRA CANTIDAD DE CONTACTOS EN UN PERIODO Y POR ANUNCIANTE -------

DROP PROCEDURE IF EXISTS p_reporte1 
GO

CREATE PROCEDURE p_reporte1
				@fechaIni DATE,
				@fechaFin DATE,
				@anunciante INT
AS
BEGIN
	IF @fechaIni IS NULL OR @fechaFin IS NULL
    BEGIN
        RAISERROR('Las fechas no pueden ser nulas.', 16, 1);
        RETURN;
    END

	IF @fechaIni >= @fechaFin
    BEGIN
        RAISERROR('La fecha de inicio debe ser anterior a la fecha de fin.', 16, 1);
        RETURN;
    END

	IF @anunciante IN (SELECT IDAnunciante FROM Argenprop.dbo.ANUNCIANTE WHERE IDUsuario NOT IN (SELECT IDUsuario FROM Argenprop.dbo.USUARIO WHERE FechaBaja IS NULL))
    BEGIN
        RAISERROR('El anunciante ingresado está dado de baja.', 16, 1);
        RETURN;
    END

	SELECT C.IDContacto,
		   U.Nombre 'NombreInteresado',
		   U.Apellido 'ApellidoInteresado',
		   U.Email 'EmailInteresado',
		   U.Telefono 'TelInteresado',
		   C.Mensaje
	FROM Argenprop.dbo.CONTACTO C
	JOIN Argenprop.dbo.INTERESADO I on I.IDInteresado = C.IDInteresado
	JOIN Argenprop.dbo.USUARIO U ON U.IDUsuario = I.IDUsuario
	WHERE C.FecContac BETWEEN @fechaIni AND @fechaFin 
	AND C.IDAnunciante = ANY (SELECT IDAnunciante FROM Argenprop.dbo.ANUNCIANTE WHERE IDAnunciante = @anunciante)
END

-- CASO DE PRUEBA --

EXEC p_reporte1 @fechaIni = '05-09-2022',@fechaFin = '12-12-2024',@anunciante = 31
SELECT * FROM Argenprop.dbo.CONTACTO

------- REPORTE 2: PROPIEDADES EN VENTA DENTRO DE UN RANGO DE PRECIOS -------

DROP PROCEDURE IF EXISTS p_reporte2;
GO

CREATE PROCEDURE p_reporte2
    @precioMin DECIMAL(18, 2),
    @precioMax DECIMAL(18, 2)
AS
BEGIN
    -- Validación de los parámetros de entrada
    IF @precioMin < 0 OR @precioMax < 0
    BEGIN
        RAISERROR('Los precios no pueden ser negativos.', 16, 1); --- ENTRADA, SUBCONSULTAS, JOINS
        RETURN;
    END

    IF @precioMin >= @precioMax
    BEGIN
        RAISERROR('El precio mínimo debe ser menor que el precio máximo.', 16, 1);
        RETURN;
    END

    -- Consulta que devuelve propiedades dentro del rango de precios
    SELECT P.IDPropiedad, P.Calle, P.Nro, P.CantHab, P.Tam, PV.PrecioVenta
    FROM Argenprop.dbo.PROPIEDAD P
    INNER JOIN Argenprop.dbo.PRECIOVENTA PV ON P.IDPropiedad = PV.IDPropiedad
	INNER JOIN Argenprop.dbo.ANUNCIANTE A ON A.IDAnunciante = P.IDAnunciante
	INNER JOIN Argenprop.dbo.USUARIO U ON U.IDUsuario = A.IDUsuario
    WHERE PV.PrecioVenta BETWEEN @precioMin AND @precioMax AND U.FechaBaja IS NULL;
END;
GO

-- CASO DE PRUEBA --

EXEC p_reporte2 @precioMin = 50, @precioMax = 200000;
SELECT * FROM Argenprop.dbo.PRECIOVENTA

------- REPORTE 3: PROPIEDADES POR TIPO, ESTADO O PROVINCIA -------

DROP PROCEDURE IF EXISTS  p_reporte3
GO

CREATE PROCEDURE p_reporte3
    @Tipo VARCHAR(10),
    @Estado VARCHAR(20),
    @Provincia VARCHAR(20)
AS
BEGIN
    WITH PropiedadesPorEstado AS (
        SELECT P.IDPropiedad, P.Estado, T.Descripción AS TipoPropiedad, Pr.Nombre AS Provincia
        FROM Argenprop.dbo.PROPIEDAD P
        INNER JOIN Argenprop.dbo.TIPOPROPIEDAD T ON P.IDTipoPropiedad = T.IDTipoPropiedad
		INNER JOIN Argenprop.dbo.PROVINCIA Pr ON Pr.IDProvincia = P.IDProvincia
		INNER JOIN Argenprop.dbo.ANUNCIANTE A ON A.IDAnunciante = P.IDAnunciante
		INNER JOIN Argenprop.dbo.USUARIO U ON U.IDUsuario = A.IDUsuario
        WHERE T.Descripción = @Tipo AND U.FechaBaja IS NULL
        GROUP BY P.IDPropiedad,P.Estado, T.Descripción, Pr.Nombre
        
        UNION

        SELECT P.IDPropiedad, P.Estado, T.Descripción AS TipoPropiedad, Pr.Nombre AS Provincia
        FROM Argenprop.dbo.PROPIEDAD P
        INNER JOIN Argenprop.dbo.TIPOPROPIEDAD T ON P.IDTipoPropiedad = T.IDTipoPropiedad
		INNER JOIN Argenprop.dbo.PROVINCIA Pr ON Pr.IDProvincia = P.IDProvincia
		INNER JOIN Argenprop.dbo.ANUNCIANTE A ON A.IDAnunciante = P.IDAnunciante
		INNER JOIN Argenprop.dbo.USUARIO U ON U.IDUsuario = A.IDUsuario
        WHERE P.Estado = CASE WHEN @Estado = 'Alquiler' THEN 'Alquiler' ELSE 'Venta' END AND U.FechaBaja IS NULL
        GROUP BY P.IDPropiedad,P.Estado, T.Descripción, Pr.Nombre
        
        UNION

        SELECT P.IDPropiedad, P.Estado, T.Descripción AS TipoPropiedad,Pr.Nombre AS Provincia
        FROM Argenprop.dbo.PROPIEDAD P
        INNER JOIN Argenprop.dbo.TIPOPROPIEDAD T ON P.IDTipoPropiedad = T.IDTipoPropiedad
		INNER JOIN Argenprop.dbo.PROVINCIA Pr ON Pr.IDProvincia = P.IDProvincia
		INNER JOIN Argenprop.dbo.ANUNCIANTE A ON A.IDAnunciante = P.IDAnunciante
		INNER JOIN Argenprop.dbo.USUARIO U ON U.IDUsuario = A.IDUsuario
        WHERE Pr.Nombre = @Provincia AND U.FechaBaja IS NULL
        GROUP BY P.IDPropiedad,P.Estado, T.Descripción, Pr.Nombre
    )

    SELECT * FROM PropiedadesPorEstado;
END

-- CASO DE PRUEBA --
EXEC p_reporte3 @Tipo = 'Casa', @Estado = 'Alquiler', @Provincia = 'Salta'

------- REPORTE 4: RETORNA SI EXISTE UNA PROPIEDAD EN UN MUNICIPIO Y UN PRECIO MENOR AL DADO -------

DROP PROCEDURE IF EXISTS p_reporte4
GO

CREATE PROCEDURE p_reporte4
	@Municipio NVARCHAR(50),
    @PrecioEnUSD DECIMAL(18, 2),
    @ExistePropiedad BIT OUTPUT
AS
BEGIN

    -- Validar el precio de entrada
    IF @PrecioEnUSD IS NULL OR @PrecioEnUSD <= 0
    BEGIN
        PRINT'El precio debe ser un valor positivo';
        RETURN;
    END

	-- Validar que exista el municipio
	IF NOT EXISTS (SELECT 1 FROM Argenprop.dbo.MUNICIPIO WHERE Nombre = @Municipio) ---ENTRADA, SUBCONSULTAS, JOINS, RETORNO, EXIST
	BEGIN	
		PRINT'No se encuentra el Municipio ingresado';
        RETURN;
    END

    -- Comprobar si existe al menos una propiedad que cumpla con el criterio
    IF EXISTS (
        SELECT 1
        FROM Argenprop.dbo.PROPIEDAD P
        INNER JOIN Argenprop.dbo.PRECIOALQUILER PA ON P.IDPropiedad = PA.IDPropiedad
		INNER JOIN Argenprop.dbo.MUNICIPIO MU ON P.IDMunicipio = MU.IDMunicipio
		INNER JOIN Argenprop.dbo.ANUNCIANTE A ON A.IDAnunciante = P.IDAnunciante
		INNER JOIN Argenprop.dbo.USUARIO U ON U.IDUsuario = A.IDUsuario
        WHERE P.Estado = 'Alquiler' AND PA.PrecioAlquiler < @PrecioEnUSD AND MU.IDMunicipio = (SELECT IDMunicipio FROM Argenprop.DBO.MUNICIPIO WHERE Nombre = @Municipio)
		AND U.FechaBaja IS NULL
    )
    BEGIN
        SET @ExistePropiedad = 1;  -- Verdadero
		SELECT P.IDPropiedad, P.Calle, P.Nro, PA.PrecioAlquiler AS PrecioAlquiler, PA.Expensas AS PrecioExpensas, MU.Nombre AS Municipio 
        FROM Argenprop.dbo.PROPIEDAD P
        INNER JOIN Argenprop.dbo.PRECIOALQUILER PA ON P.IDPropiedad = PA.IDPropiedad
		INNER JOIN Argenprop.dbo.MUNICIPIO MU ON P.IDMunicipio = MU.IDMunicipio
		INNER JOIN Argenprop.dbo.ANUNCIANTE A ON A.IDAnunciante = P.IDAnunciante
		INNER JOIN Argenprop.dbo.USUARIO U ON U.IDUsuario = A.IDUsuario
        WHERE P.Estado = 'Alquiler' AND PA.PrecioAlquiler < @PrecioEnUSD AND MU.IDMunicipio = (SELECT IDMunicipio FROM Argenprop.DBO.MUNICIPIO WHERE Nombre = @Municipio)
		AND U.FechaBaja IS NULL
	END
    ELSE
    BEGIN
        SET @ExistePropiedad = 0;  -- Falso
    END
END

-- CASO DE PRUEBA --

DECLARE @Existe BIT;

EXEC p_reporte4 @PrecioEnUSD = 100000, @Municipio = 'Inriville', @ExistePropiedad = @Existe OUTPUT;

IF @Existe = 1
    PRINT 'Existen propiedades en alquiler con un precio mayor al ingresado.';
ELSE
    PRINT 'No existen propiedades en alquiler con un precio mayor al ingresado.';

------- REPORTE 5: RETORNA CANTIDAD DE PROPIEDADES EN ALGUN ESTADO -------

DROP PROCEDURE IF EXISTS p_reporte5
GO

CREATE PROCEDURE p_reporte5
    @Estado NVARCHAR(10),
    @Cantidad INT OUTPUT
AS
BEGIN

    -- Validar el parámetro de entrada
    IF @Estado IS NULL OR (@Estado NOT IN ('Alquiler', 'Venta')) ---ENTRADA, RETORNO, SUBCONSULTA
    BEGIN
        PRINT'El parámetro @Estado debe ser "Alquiler" o "Venta"';
        RETURN;
    END

    -- Contar las propiedades en el estado especificado
    SELECT @Cantidad = COUNT(*)
    FROM Argenprop.dbo.PROPIEDAD P
	INNER JOIN Argenprop.dbo.ANUNCIANTE A On A.IDAnunciante = P.IDAnunciante
	INNER JOIN Argenprop.dbo.USUARIO U ON A.IDUsuario = U.IDUsuario
    WHERE P.Estado = @Estado AND U.FechaBaja IS NULL;
END

-- CASO DE PRUEBA --

DECLARE @CantidadPropiedades INT;

EXEC p_reporte5 @Estado = 'Alquiler', @Cantidad = @CantidadPropiedades OUTPUT;

PRINT 'Total de propiedades en estado Alquiler: ' + CAST(@CantidadPropiedades AS NVARCHAR(10));

SELECT COUNT(*) FROM Argenprop.dbo.PRECIOALQUILER

-- EJERCICIO 17) --

DROP PROCEDURE p_proceso1
GO

CREATE PROCEDURE p_proceso1
    @Accion NVARCHAR(12),
    @Email VARCHAR(100) = NULL,  -- Correo electrónico en lugar de ID
    @Nombre VARCHAR(50) = NULL,   -- Opcional
    @Apellido VARCHAR(50) = NULL, -- Opcional
    @Telefono VARCHAR(15) = NULL, -- Opcional
    @Contraseña NVARCHAR(100) = NULL, -- Opcional
    @TipoUsuario VARCHAR(50) = NULL,  -- Nuevo tipo de usuario
    @Empresa VARCHAR(100) = NULL,  -- Solo para ANUNCIANTE
    @Reseña VARCHAR(255) = NULL,   -- Solo para ANUNCIANTE
	@TipoAnunciante VARCHAR(50) = NULL, -- Solo para ANUNCIANTE
    @CantContactos INT = NULL,      -- Cantidad de contactos a sumar/restar para INTERESADO
    @ModificarContactos INT = 0      -- Si es positivo, suma; si es negativo, resta
AS
BEGIN
	DECLARE @valid BIT;
    DECLARE @IDUsuario INT;

    -- Obtener ID del usuario usando el correo electrónico.
    SELECT @IDUsuario = IDUsuario FROM Argenprop.dbo.USUARIO WHERE Email = @Email;

    IF @Accion = 'ALTA'
    BEGIN

        IF @IDUsuario IS NOT NULL
        BEGIN
			IF @IDUsuario IN (SELECT IDUsuario FROM Argenprop.dbo.USUARIO WHERE FechaBaja IS NOT NULL)
			BEGIN
				UPDATE Argenprop.dbo.USUARIO
				SET FechaBaja = NULL
				WHERE IDUsuario = @IDUsuario
				RETURN;
			END
			ELSE
			BEGIN
				RAISERROR('El usuario con este email ya existe.', 16, 1);
				RETURN;
			END
        END

        -- Valida la contraseña.
        SET @valid = dbo.f_funcion2(@Contraseña);
        IF @valid = 0
        BEGIN
            RAISERROR('La contraseña no cumple con los requisitos.', 16, 1);
            RETURN;
        END

        INSERT INTO Argenprop.dbo.USUARIO (Nombre, Apellido, Email, Telefono, Contraseña)
        VALUES (@Nombre, @Apellido, @Email, @Telefono, ENCRYPTBYPASSPHRASE('password', @contraseña));
        
        SET @IDUsuario = SCOPE_IDENTITY();  -- Obtener el ID del nuevo usuario.

        -- Insertar en la tabla correspondiente según el tipo de usuario.
        IF @TipoUsuario = 'ANUNCIANTE'
        BEGIN
            INSERT INTO Argenprop.dbo.ANUNCIANTE (IDUsuario, TipoAnunciante, Empresa, Reseña)
            VALUES (@IDUsuario, @TipoAnunciante, @Empresa, @Reseña);
        END
        ELSE IF @TipoUsuario = 'INTERESADO'
        BEGIN
            INSERT INTO Argenprop.dbo.INTERESADO (IDUsuario, CantContactos)
            VALUES (@IDUsuario, @CantContactos);
        END
        ELSE IF @TipoUsuario = 'ADMINISTRADOR'
        BEGIN
            INSERT INTO Argenprop.dbo.ADMINISTRADOR (IDUsuario, Nombre, Email)
            VALUES (@IDUsuario, @Nombre, @Email);
        END
        ELSE
        BEGIN
            RAISERROR('Tipo de usuario no válido. Use ANUNCIANTE, INTERESADO o ADMINISTRADOR.', 16, 1);
            RETURN;
        END
    END
    ELSE IF @Accion = 'BAJA'
    BEGIN
        -- Validar que el usuario exista
        IF @IDUsuario IS NULL
        BEGIN
			IF @IDUsuario IN (SELECT IDUsuario FROM Argenprop.dbo.USUARIO WHERE FechaBaja IS NOT NULL)
			BEGIN
				RAISERROR('El usuario ya fue dado de baja.', 16, 1);
				RETURN;
			END
			ELSE
			BEGIN
				RAISERROR('El usuario no existe.', 16, 1);
				RETURN;
			END
        END

        -- Eliminar de la tabla correspondiente según el tipo de usuario
        IF EXISTS (SELECT 1 FROM Argenprop.dbo.USUARIO WHERE IDUsuario = @IDUsuario)
        BEGIN
            UPDATE Argenprop.dbo.USUARIO 
			SET FechaBaja = CURRENT_TIMESTAMP
			WHERE IDUsuario = @IDUsuario;
        END

    END
    ELSE IF @Accion = 'MODIFICACION'
    BEGIN
        -- Validar que el usuario exista
        IF @IDUsuario IS NULL
        BEGIN
			IF @IDUsuario IN (SELECT IDUsuario FROM Argenprop.dbo.USUARIO WHERE FechaBaja IS NOT NULL)
			BEGIN
				RAISERROR('El usuario ya fue dado de baja.', 16, 1);
				RETURN;
			END
			ELSE
			BEGIN
				RAISERROR('El usuario no existe.', 16, 1);
				RETURN;
			END
        END

        -- Validar la nueva contraseña.
        SET @valid = dbo.f_funcion2(@Contraseña);
        IF @valid = 0
        BEGIN
            RAISERROR('La contraseña no cumple con los requisitos.', 16, 1);
            RETURN;
        END


        -- Obtener el tipo actual del usuario.
        DECLARE @TipoActual NVARCHAR(50);
        SELECT @TipoActual = 
            CASE 
                WHEN EXISTS (SELECT 1 FROM Argenprop.dbo.ANUNCIANTE WHERE IDUsuario = @IDUsuario) THEN 'ANUNCIANTE'
                WHEN EXISTS (SELECT 1 FROM Argenprop.dbo.INTERESADO WHERE IDUsuario = @IDUsuario) THEN 'INTERESADO'
                WHEN EXISTS (SELECT 1 FROM Argenprop.dbo.ADMINISTRADOR WHERE IDUsuario = @IDUsuario) THEN 'ADMINISTRADOR'
                ELSE NULL
            END;

        -- Actualiza el usuario, modificándolo o dejando el previo.
        UPDATE Argenprop.dbo.USUARIO
        SET 
            Nombre = COALESCE(@Nombre, Nombre),
            Apellido = COALESCE(@Apellido, Apellido),
            Email = COALESCE(@Email, Email),
            Telefono = COALESCE(@Telefono, Telefono),
            Contraseña = COALESCE(ENCRYPTBYPASSPHRASE('password', @contraseña), Contraseña)
        WHERE IDUsuario = @IDUsuario;

        -- Si el tipo de usuario ha cambiado o es NULL.
        IF @TipoUsuario IS NOT NULL AND @TipoUsuario <> @TipoActual
        BEGIN

            IF @TipoUsuario = 'ANUNCIANTE'
            BEGIN
                INSERT INTO Argenprop.dbo.ANUNCIANTE (IDUsuario, TipoAnunciante, Empresa, Reseña)
                VALUES (@IDUsuario, @TipoAnunciante, @Empresa, @Reseña);
            END
            ELSE IF @TipoUsuario = 'INTERESADO'
            BEGIN
                INSERT INTO Argenprop.dbo.INTERESADO (IDUsuario, CantContactos)
                VALUES (@IDUsuario, COALESCE(@CantContactos, 0));
            END
            ELSE IF @TipoUsuario = 'ADMINISTRADOR'
            BEGIN
                INSERT INTO Argenprop.dbo.ADMINISTRADOR (IDUsuario, Nombre, Email)
                VALUES (@IDUsuario, @Nombre, @Email);
            END
            ELSE
            BEGIN
                RAISERROR('Tipo de usuario no válido. Use ANUNCIANTE, INTERESADO o ADMINISTRADOR.', 16, 1);
                RETURN;
            END
        END
        ELSE IF @TipoUsuario IS NOT NULL AND @TipoUsuario = @TipoActual
        BEGIN
            -- Actualiza la información según el tipo de usuario.
            IF @TipoActual = 'ANUNCIANTE'
            BEGIN
                UPDATE Argenprop.dbo.ANUNCIANTE
                SET 
                    Empresa = COALESCE(@Empresa, Empresa),
                    Reseña = COALESCE(@Reseña, Reseña),
					TipoAnunciante = COALESCE(@TipoAnunciante, TipoAnunciante)
                WHERE IDUsuario = @IDUsuario;
            END
            ELSE IF @TipoActual = 'INTERESADO'
            BEGIN
                -- Sumar o restar contactos
                UPDATE Argenprop.dbo.INTERESADO
                SET 
                    CantContactos = COALESCE(CantContactos, 0) + @ModificarContactos
                WHERE IDUsuario = @IDUsuario;
            END
            ELSE IF @TipoActual = 'ADMINISTRADOR'
            BEGIN
                UPDATE Argenprop.dbo.ADMINISTRADOR
                SET 
                    Nombre = COALESCE(@Nombre, Nombre),
                    Email = COALESCE(@Email, Email)
                WHERE IDUsuario = @IDUsuario;
            END
        END
    END
    ELSE
    BEGIN
        RAISERROR('Acción no válida. Use ALTA, BAJA o MODIFICACION.', 16, 1);
    END
END;
GO

-- CASO DE PRUEBA --

-- ALTA
EXEC p_proceso1 
    @Accion = 'ALTA',
    @Nombre = 'Juan',
    @Apellido = 'Pérez',
    @Email = 'juan.1perez@example.com',
    @Telefono = '1234567890',
    @Contraseña = 'cHola2344$%321a',
    @TipoUsuario = 'INTERESADO',
    @CantContactos = 5;  -- Inicialmente, 5 contactos

-- MODIFICACION 1
EXEC p_proceso1 
    @Accion = 'MODIFICACION',
    @TipoUsuario = 'INTERESADO',
	@Email = 'juan.perez@example.com', --Email de usuario a modificar
    @ModificarContactos = 3;  -- Agregar 3 contactos

-- MODIFICACION 2
EXEC p_proceso1 
    @Accion = 'MODIFICACION',
    @Nombre = 'Juan Carlos',
    @Apellido = 'Pérez',
    @Email = 'juan.perez@example.com', --Email de usuario a modificar
    @Telefono = '0987654321',
    @Contraseña = 'nuevaCoeñ123!aSegura',
    @TipoUsuario = 'ANUNCIANTE',
	@TipoAnunciante = 'Propietario',
    @Empresa = 'Nueva Empresa S.A.',
    @Reseña = 'Nueva reseña de la empresa.';

-- BAJA
EXEC p_proceso1 
    @Accion = 'BAJA',
	@Email = 'juan.1perez@example.com' --Email de usuario a eliminar

-- CASO DE PRUEBA | ENCRIPTADO DE CONTRASEÑA --

SELECT CAST(DECRYPTBYPASSPHRASE('password', Contraseña) AS NVARCHAR(50)) FROM Argenprop.dbo.USUARIO WHERE Email = 'juan.1perez@example.com'
SELECT Contraseña FROM Argenprop.dbo.USUARIO WHERE Email = 'juan.perez@example.com'

SELECT * FROM Argenprop.dbo.USUARIO