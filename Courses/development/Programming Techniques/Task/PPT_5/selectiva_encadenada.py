print("INGRESO DE DATOS")

num1 = int(input("Ingrese primer numero: "))
num2 = int(input("Ingrese segundo numero: "))
num3 = int(input("Ingrese tercer numero: "))

if (num1 >= num2 and num1 >= num3):
    mayor = num1
elif (num2 >= num1 and num2 >= num3):
    mayotu = num2
elif (num3 >= num1 and num3 >= num2):
    mayor = num3

print("El numero mayor es: ", mayor)