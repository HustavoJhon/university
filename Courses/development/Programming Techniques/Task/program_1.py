import math

def Ecuacion():
    print('\n', "===== Ecuaciones =====", '\n')

    x = eval(input("Infrese x: "))

    potencia_1 = pow(x + 3, 2)
    raiz = math.sqrt(x + 5)
    potencia_2 = pow(x, 2/3)
    z = (potencia_1 + x + raiz) / potencia_2 + 1

    print(" La respuesta es: ", z)


Ecuacion()
