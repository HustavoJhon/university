print("="*50)

def leer_datos():
    dato = int(input("ingrese un numero: "))

    return dato

def ecuacion():
    print("Ingrese valor de x:\t\t\t\t", end="")
    x = leer_datos()
    if x <= 0:
        y = (x**2) + 5
    elif x > 0 and x < 2:
        y = (3*x) - 1
    elif x >= 2:
        y = (x**2) - (4*x) + 5
    print("El valor de y es:\t\t\t\t", y)

def ejecutar():
    ecuacion()

ejecutar()