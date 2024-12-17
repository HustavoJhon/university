a = 0
b = 1

print("\n========== INGRESO DE DATOS ==========")
lim = int(input("Ingrese limite:\t\t"))
print("La serie fibonaccci es: ")
print(a)
while (b <= lim):
    print(b)
    c = a + b
    a = b
    b = c