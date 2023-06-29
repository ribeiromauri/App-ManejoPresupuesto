USE ManejoPresupuesto
GO

CREATE PROCEDURE Transacciones_Insertar
	@UsuarioId nvarchar(450),
	@FechaTransaccion date,
	@Monto decimal(18,2),
	@TipoOperacionId int,
	@Nota nvarchar(1000) = NULL
AS
BEGIN   
	INSERT INTO Transacciones(UsuarioId, FechaTransaccion, Monto, TipoOperacionId, Nota)
	Values(@UsuarioId, @FechaTransaccion, @Monto, @TipoOperacionId, @Nota)
END
GO

CREATE PROCEDURE Transacciones_SelectConTipoOperacion
	@fecha DATE
AS
BEGIN
    Select Transacciones.Id, UsuarioId, Monto, Nota, Descripcion
	From Transacciones
	INNER JOIN TiposOperaciones
	ON Transacciones.TipoOperacionId = TiposOperaciones.Id
	WHERE FechaTransaccion = @fecha
	ORDER BY UsuarioId DESC
END
GO

CREATE PROCEDURE Transacciones_Actualizar	
	@Id int,
	@FechaTransaccion datetime,
	@Monto decimal(18,2),
	@MontoAnterior decimal(18,2),
	@CuentaId int,
	@CuentaAnteriorId int,
	@CategoriaId int,
	@Nota nvarchar(1000) = NULL
AS
BEGIN
    --Revertir transaccion anterior
	UPDATE Cuentas SET Balance -= @MontoAnterior WHERE Id = @CuentaAnteriorId;

	--Realizar nueva transaccion
	UPDATE Cuentas SET Balance += @Monto WHERE Id = @CuentaId; 

	UPDATE Transacciones
	SET Monto = ABS(@Monto), FechaTransaccion = @FechaTransaccion, CategoriaId = @CategoriaId, CuentaId = @CuentaId, Nota = @Nota
	WHERE Id = @Id;
END
GO

CREATE PROCEDURE Transacciones_Borrar
	@Id int
AS
BEGIN	
	DECLARE @Monto decimal(18,2);
	DECLARE @CuentaId int;
	DECLARE @TipoOperacionId int;

	SELECT @Monto = Monto, @CuentaId = CuentaId, @TipoOperacionId = cat.TipoOperacionId
	FROM Transacciones 
	INNER JOIN Categorias cat
	ON cat.Id = Transacciones.CategoriaId
	WHERE Transacciones.Id = @Id;

	DECLARE @FactorMultiplicativo int = 1;

	IF(@TipoOperacionId = 2)
		SET @FactorMultiplicativo = -1;

	SET @Monto = @Monto * @FactorMultiplicativo;

	UPDATE Cuentas SET Balance -= @Monto WHERE Id = @CuentaId;
	DELETE Transacciones WHERE Id = @Id;
END
GO
