print("="*50)

def sumar(n1,n2):
    sum = n1 + n2
    return sum

def Ejecutor():
    num1 = eval(input("Ingrese primer numero:\t\t"))
    num2 = eval(input("Ingrese segundo numero:\t\t"))

    s = sumar(num1,num2)
    
    print("\n ============ REPORTE ============\n")
    print("La suma es \t\t", s)
    print("="*50)

Ejecutor()
