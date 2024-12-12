print("\n ========= MENU ==========")
print("""
    1. Sopa
    2. Arroz con pollo
    3. Refresco
""")

print("\n === INGRESO DE DATOS ===")

precio_sopa = float(input("Ingrese precio de Sopa:\t"))
cantidad_sopa = int(input("Ingrese cuantos platos de Sopa:\t"))

precio_arroz = float(input("Ingrese precio de Arroz:\t"))
cantidad_arroz = int(input("Ingrese cuantos platos de Arroz:\t"))

precio_refresco = float(input("Ingrese precio de Refresco:\t"))
cantidad_refresco = int(input("Ingrese cuantos vasos de Refresco:\t"))

sub_total_sopa = precio_sopa * cantidad_sopa
sub_total_arroz = precio_arroz * cantidad_arroz
sub_total_refresco = precio_refresco + cantidad_refresco

monto_pagar = sub_total_sopa + sub_total_arroz + sub_total_refresco

print("========== reporte ===========")
print("El Sub total de Sopa es:\t\t", sub_total_sopa)
print("El Sub total de Arroz es:\t\t", sub_total_arroz)
print("El Sub total de Refresco es:\t\t", sub_total_refresco)
print("El Total a Pagar es:\t\t\t", monto_pagar)