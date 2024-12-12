producto = 1 
print("="*50)
n = int(input("Ingrese numero para factial:\t\t"))

for i in range(n):
    i = i + 1
    producto = producto * i

print("\n========== REPORTE ==========")
print("El factorial de", n, "es:\t\t", producto)