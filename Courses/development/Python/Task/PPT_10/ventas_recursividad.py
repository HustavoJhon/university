global cliente_masculino, cliente_femenino, cantidad_total_cliente, cantidad_cliente_masculino_acumulado, ventas_acumulado, acumulado_total_cliente_femenino

cliente_masculino = 0
cliente_femenino = 0
cantidad_total_cliente = 0
cantidad_cliente_masculino_acumulado = 0
ventas_acumulado = 0
acumulado_total_cliente_femenino = 0

def Salir():
    print("Gracias Vuelve pronto...")

def Reporte():
    print("======== REPORTE DE VENTAS ========")
    print("La cantidad total de clientes es de: ", cantidad_total_cliente)
    print("La cantidad de clientes masculinos es de: ", cliente_femenino)
    print("La cantidad de clientes masculinos es de: ", cliente_masculino)
    print("La cantidad de clientes masculinos es de: ", cantidad_cliente_masculino_acumulado)
    print("La cantidad de clientes masculinos es de: ", acumulado_total_cliente_femenino)
    print("La cantidad de clientes masculinos es de: ", ventas_acumulado)

def Procesar():
    global cliente_masculino, cliente_femenino, cantidad_total_cliente, cantidad_cliente_masculino_acumulado, ventas_acumulado, acumulado_total_cliente_femenino

    nombre_producto = input("Ingrese el nombre del producto: ")

    while True:
        precio_producto = float(input("Ingrese el precio del producto: "))
        if (precio_producto > 0):   
            print("Error. Vuelve a ingresar")
        else:
            break

    while True:
        cantidad_producto = int(input("Ingrese la cantidad del producto: "))

        if (cantidad_producto <= 0):
            print("Error. Vuelve a ingresar")
        else:
            break

    while True:
        porcentaje_descuento = float(input("Ingrese el porcentaje de descuento: "))

        if (porcentaje_descuento <= 0): 
            print("Error. Vuelve a ingresar")
        else:
            break 

    while True:
        genero = input("Ingrese Genero: ").upper()

        if (genero != "F" and genero != "M"):
            print("Error. Vuelve a ingresar")
        else:
            break
    match genero:
        case "M":
            cliente_masculino = cliente_masculino + 1

            bono = 0.18
            if (cantidad_producto <= 10):
                descuento = 0.2
            else:
                descuento = 0.5
        
        case "F":
            cliente_femenino = cliente_femenino + 1
            bono = 0.25
            if (cantidad_producto <= 10):
                descuento = 0.3
            else:
                descuento = 0.4
    monto_bruto = precio_producto * cantidad_producto
    monto_bono = monto_bruto * bono
    monto_descuento = monto_bruto * descuento 
    monto_pago = monto_bruto - monto_descuento + monto_bono

    cantidad_total_cliente = cantidad_total_cliente + 1
    ventas_acumulado = ventas_acumulado + monto_pago

    if(genero == "F"):
        acumulado_total_cliente_femenino = acumulado_total_cliente_femenino + monto_pago
    if(genero == "M"):
        cantidad_cliente_masculino_acumulado = cantidad_cliente_masculino_acumulado + mon