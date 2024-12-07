print("=" * 50)

def leedatoE():
    dato = int(input(""))

    return dato

def ecuaciones():

    print("Ingrese valor de x:\t\t", end="") #end,para concatenar el valor de la variable x

    x = leedatoE()

    if (x<=0):
        y = (x**2) + 5

    elif (x>0 and x<2):
        y = (3*x) - 1

    elif (x>=2):
        y = (x**2) - (4*x) + 5

    print("El valor de y es:\t\t", y)

def Ejecutor():
    ecuaciones()

Ejecutor()
