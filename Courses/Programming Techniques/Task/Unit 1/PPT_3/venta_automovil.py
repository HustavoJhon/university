from datetime import datetime

print("\n========== INGRESO DE DATOS ==========")
print("********** Cliente **********")

dni = int(input("Ingrese DNI del cliente: "))
apellido = input("Ingrese apellido del cliente: ")
nombre = input("Ingrese nombre del cliente: ")
datos_completos = nombre + " " + apellido

print("********** Automovil **********")
marca = input("Ingrese marca del automovil: ")
modelo = input("Ingrese modelo: ")
anio_car = int(input("Ingrese anio del automovil: "))
precio_venta_dolares = float(input("Ingrese precio de venta (dolares): "))

print("********** Tipo de Cambio **********")
tipo_cambio = float(input("Ingrese tipo del cambio a soles: "))

# CALCULANDO
monto_impuesto_dolares = precio_venta_dolares * 0.19
monto_pago_dolares = precio_venta_dolares + monto_impuesto_dolares

monto_impuesto_soles = monto_impuesto_dolares * tipo_cambio
monto_pago_soles = monto_pago_dolares * tipo_cambio

# GENERANDO EL COMPROBRANTE DE PAGO
numero_comprobante = input("Ingrese el numero de comprobante:\t")
fecha_hora = datetime.now()
anio = fecha_hora.year
mes = fecha_hora.month
dia = fecha_hora.day

print("\n ========== REPORTE DE DATOS ==========")
print("***** Comprobante de Pago *****")
print("Numero de comprobante:\t", numero_comprobante)
print("Cliente DNI:", dni)
print("Cliente datos:\t\t\t", datos_completos)
print("Fecha:\t\t\t\t", anio, "/", mes,"/", dia)

print(f"Monto a Pagar (dolares)\t\t: ${monto_pago_dolares:.2f}")
print(f"Impuesto (dolares)\t\t: ${monto_impuesto_dolares:.2f}")
print(f"Monto a Pagar (soles)\t\t: ${monto_pago_soles:.2f}")
print(f"Impuesto (soles)\t\t: ${monto_impuesto_soles:.2f}")
print("\nGracias por su compra...!")