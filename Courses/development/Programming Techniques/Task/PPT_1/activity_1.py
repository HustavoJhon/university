import math

print('\n', "--- Ecuaciones ---", '\n')

x = eval(input("Ingrese x: "))

potencia_1 = pow(x+3, 2)
raiz = math.sqrt(x+5)
potencia_2 = pow(x, 2/3)
z = (potencia_1 + x + raiz) / potencia_2+1
print("\nLa Ecuacion es: ", z, "\n")
