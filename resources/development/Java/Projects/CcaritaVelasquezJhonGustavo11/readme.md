a. Crear un formulario que permita crear un login con los siguientes datos:

    - Nombre de usuario
    - contrasaena del usuario
    - nivel de acceso
    Estos datos debe ser recuperados de la tabla TUsuarios de la base de dato BDEvaluacion

b. Crear el formulario de Menu:

c. Crearun formulario CalcularPago, y que se muestre al seleccionar el submenu Calcular:

    - Costo base: 
    - Cambiar de medicamento
        - 0, 5-10, 11-20, 21 a mas
    - Forma de Pago: 
        - Contado, Tarjeta Directo, Tarjeta Cuotas
    - Promociones
        - Obtener Receta en Farmaccia, Medicamento en Lanzamiento
    - Pago Final
    - BTN: Calcular, Salir

    Considerando como restricciones para calcular el pago final:

        - Contado  :  0% de Precio Base
        - Tarjeta Directo  :  2% de Precio Base 
        - Tarjeta Cuotas  : 10% de Precio Base

    Descuento por Cantidad Medicamentos:

        - 0  : S/.0.00
        - 5 - 10 : S/.10.00
        - 11 - 20 : S/.20.00
        - 21 mas : S/.30.00 

        Descuento por Promociones: 
            - Obtener Receta: 5% de Precio Base 
            - Lanzamiento: 10% de Precio Base

## Indicadores
1. Conexion a la DB y Creacion de barra de menu con las opciones:
    - Operaciones ( con el submenu Operaciones Basicas y Salir), 
    - Transacciones ( con el submenu Calcular e Informe) y permite abrir el formulario CalcularPago 
2. Crear el formulario CalcularPago e implementar su boton Salir y Nuevo.
3. En el formulario CalcularPago, permite la seleccion de UNA SOLA FORMA DE PAGO. 
4. Validar el costo base a ingresar, (que sea mayor a cero y que no permita calcular el costo base negativo).
5. En el formulario CalcularPago, implementar el boton CALCULAR, para obtener el Pago Final, segun las restriccines ( condiciones: Descuentos y Promociones, Descuento por cantidad de medicamentos y Cargo adicionales por Forma de Pago.
6. En el formulario CalcularPago, mostrar en el textField el valor del Pago Final, calculando, segun la validacion de datos y las restricciones dadas.

# Explicación rápida

- TxtCostoBase: ingresa el costo base (validado para que sea > 0).
- CboCantidadMedicamentos: combo con las opciones 0, 5-10, 11-20, 21 o más (descuentos fijos).
- Radios para forma de pago (contado, tarjeta directo, tarjeta cuotas).
- CboPromociones: combo para elegir promoción (ninguna, receta, lanzamiento).
- TxtPagoFinal: campo solo lectura para mostrar el resultado.
- Botones: Calcular (realiza cálculo), Nuevo (limpia formulario), Salir (cierra ventana).
- La lógica considera descuentos, recargos y calcula el pago final.


