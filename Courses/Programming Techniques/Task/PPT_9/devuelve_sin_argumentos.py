print("=" * 50)

def sumar():

    num1 = eval(input("Ingrese primer numero:\t\t"))
    num2 = eval(input("Ingrese segundo numero:\t\t"))

    sum = num1 + num2

    return sum

def Ejecutor():

    s = sumar

    print("\n ========= REPORTE ==========\n")
    print("La suma es \t\t", s)
    print("=" * 50)

Ejecutor()
