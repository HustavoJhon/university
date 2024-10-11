# Ingresar nombre, precio y cantidad deproducto, tambien un descuento
# Calcular el monto de pago

print("\n========== INGRESO DE DATOS ==========\n")
nombre_producto = input("Ingrese nombre de producto:\t\t")
precio_producto = float(input("Ingrese precio de producto:\t\t"))
cantidad_producto = int(input("Ingrese cantidad de producto:\t"))
porcentaje_descuento = float(input("Ingrese porcentaje descuento:\t"))

monto_bruto = precio_producto * cantidad_producto
monto_descuento = monto_bruto * porcentaje_descuento
monto_pago = monto_bruto - monto_descuento

print("\n========== REPORTE ==========\n")
print("El monto bruto es:\t\t", monto_bruto)
print("El monto descuento es:\t", monto_descuento)
print("El monto a pagar es:\t", monto_pago)