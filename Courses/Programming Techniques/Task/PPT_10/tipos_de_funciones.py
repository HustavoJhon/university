# FUNCION INTERNA 
# Se define una funcion dentro de otra funcion 

print("="*50)

def FuncionExterna():
    def FuncionInterna():
        return "Ejemplo de Funcion Interior"

    return FuncionInterna

print(FuncionExterna())

# CLAUSURA : closure
print("="*50)

def FuncionExterna(n1):
    def FuncionInterna(n2):
        print("", n2 * n1)

    return FuncionInterna

FuncionExterna(5)(3)

# FUNCIONES ANONIMAS : LAMBDA 
# Se define en una linea y cuyo codigo a ejecutar suele ser pequenio, conlleva un return implicito, puede recibir cualquier numero de parametros.

# Normal
def suma(a, b):
    return a + b

# Anonima 
suma = lambda a, b: a + b
resultaso = suma(3, 5)
print(resultado)

# Una fucnion lambda puede ser la entrada a una funcion normal:

def suma(FuncionLambda):
    return FuncionLambda(2, 4)

suma(lambda a, b: a + b)

# Una funcion normal tambien puede ser la entrada de una funcion lambda:

def suma(a, b):
    return a + b

(lambda a, b: suma(a, b))(2, 4)

