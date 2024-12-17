# RECURSIVIDAD
# Funcion de programa que se retroalimentan con valores generadas por si misma (se invocan a si misma).
# - Toda funcion recursiva debe tener un punto de finalizacion.
# - La funcion recursiva debe conducir a ese punto de finalizacion.
# Ejemplos:
# - recursividad de Factorial
# - recursividad de multiplicacion
# - recursividad de Potencia.
# - recursividad de Fibonacci
# - recursividad de Maximo Comun Divisor
# - recursividad de Torres de Honoi

# RECURSIVIDAD DEL FACTORIAL 
def factorial(n):
    if(n == 0):
        return 1
    else: 
        return n * factorial(n-1)

def Ejecutor():
    while True:
        num = int(input("Ingrese un numero para factorial:\t\t"))

        if (num < 0):
            print("ERROR. Vuelve a ingresar")
        else:
            break
    f - factorial(num)
    print("El factorial es: ", f)

Ejecutor()

