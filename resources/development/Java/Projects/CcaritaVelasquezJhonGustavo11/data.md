📁 Base de Datos: BDEvaluacion.accdb

Tabla: TUsuarios

    Usuario (Texto)

    Clave (Texto)

    NivelAcceso (Texto)

🧾 Formulario: FrmInicio (Login)

Componentes JFrameForm:

    TxtUser (JTextField) → Nombre de usuario

    TxtPswd (JPasswordField) → Contraseña

    BtnInicioSesion (JButton) → Iniciar Sesión

    BtnCancelar (JButton) → Cancelar

Función principal:

    Verifica credenciales en TUsuarios

    Guarda nivel de acceso para uso posterior

🧭 Formulario: FrmMenu (Menú Principal)

JMenuBar:

    Operaciones

        jmiOperacionesBasicas (JMenuItem)

        jmiSalir (JMenuItem)

    Transacciones

        jmiCalcularPago (JMenuItem)

        jmiInforme (JMenuItem)

Eventos:

    jmiCalcularPago abre FrmCalcularPago

    jmiSalir cierra la aplicación

💊 Formulario: FrmCalcularPago

Componentes JFrameForm:

    txtCostoBase (JTextField)

    cmbCantidadMedicamento (JComboBox)

        Valores: 0, 5-10, 11-20, 21+

    rbContado, rbTarjetaDirecto, rbTarjetaCuotas (JRadioButton)

    chkReceta, chkLanzamiento (JCheckBox)

    txtPagoFinal (JTextField, deshabilitado)

    btnCalcular (JButton)

    btnSalir (JButton)

    btnNuevo (JButton)

    Grupo de botones de forma de pago con ButtonGroup

🧮 Reglas de Cálculo (Pago Final)

    Costo Base debe ser > 0

    Forma de Pago (solo una):

        Contado: +0%

        Tarjeta Directo: +2%

        Tarjeta Cuotas: +10%

    Descuento por cantidad de medicamentos:

        0: S/. 0

        5–10: S/. 10

        11–20: S/. 20

        21+: S/. 30

    Promociones:

        Receta: -5%

        Lanzamiento: -10%
