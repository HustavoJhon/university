import Librerias.Operaciones_aritmeticas as calculadora
from Librerias.Operaciones_aritmeticas import restar


num1 = 5
num2 = 3

s = calculadora.sumar(num1, num2)
r = restar(num1, num2)

print("La suma es: ", s)
print("La resta es: ", r)
