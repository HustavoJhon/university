a = 0
b = 1

print("--- INGRESO DE DATOS ---")

limite = int(input("Ingrese limite: "))

print("La serie fibonaccci es: ")

print(a)

while (b <= limite):
    print(b)
    c = a + b 
    a = b
    b = c