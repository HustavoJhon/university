nombre_persona = input("Ingrese nombre de personas: ")
apellido_persona = input("Ingrese apellido de persona: ")
nombre_completo = nombre_persona + " " + apellido_persona

def a():
    print("="*50)
    nombre_completo = nombre_persona + " " + apellido_persona
    print("Nombre Completo: ", nombre_completo)

def b():
    print("="*50)
    print("Longitud de cadena: ", len(nombre_completo))

def c():
    print("="*50)
    print("Extraer dos primeras letras ")
    print(nombre_completo[0:2])

def d():
    print("="*50)
    print("j" in nombre_completo)
    print("ab" in nombre_completo)

def e():
    print("="*50)
    nombre_capitalize = nombre_completo.capitalize()
    print("Primera letra Mayuscula: ", nombre_capitalize)

    nombre_upper = nombre_completo.upper()
    print("Todo mayuscula: ", nombre_upper)

    nombre_lower = nombre_completo.lower()
    print("Todo minuscula: ", nombre_lower)

a()
b()
c()
d()
e()

