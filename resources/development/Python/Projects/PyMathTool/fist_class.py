import os


def sumas_restas():
  print("===== SUMAS Y RESTAS =====")
  print("a - b - c + d + e + f + g + h + i - j")
  try:
    a = int(input("1. enter a number: "))
    b = int(input("2. enter a number: "))
    c = int(input("3. enter a number: "))
    d = int(input("4. enter a number: "))
    e = int(input("5. enter a number: "))
    f = int(input("6. enter a number: "))
    g = int(input("7. enter a number: "))
    h = int(input("8. enter a number: "))
    i = int(input("9. enter a number: "))
    j = int(input("10. enter a number: "))

    resultado = a - b - c + d + e + f + g + h + i - j

    print("El resultados es ", resultado)
  except:
    os.system("clear")
    print("Error, solo se aceptan numeros")


def multiplicaciones_divisiones():
  print("===== MULTIPLICACION Y DIVISIONES =====")
  print("""
    resultado_y = (i * m) / n
    restultado_z = (x / z) + (x * y) - (x + y)
  """)

  try:
    x = int(input("1. enter a number: "))
    y = int(input("2. enter a number: "))
    z = int(input("3. enter a number: "))
    m = int(input("4. enter a number: "))
    n = int(input("5. enter a number: "))
    i = int(input("6. enter a number: "))

    resultado_y = (i * m) / n
    restultado_z = (x / z) + (x * y) - (x + y)

    print("El primer resultados es ", resultado_y)
    print("El segundo resultados es ", restultado_z)

  except:
    os.system("clear")
    print("Error, solo se aceptan numeros")


def potencia():
  print("===== POTENCIA =====")
  try:
    a = int(input("1. enter a number: "))
    b = int(input("2. enter a number: "))

    c = a**b
    print("El resultado es ", c)
  except:
    os.system("clear")
    print("Error, solo se aceptan numeros")


def raiz():
  print("===== RAIZ =====")
  print("""
    z = (x**0.5 + y**5) + (y**0.5 + x**4)
        """)
  try:
    x = int(input("1. enter a number: "))
    y = float(input("2. enter a number: "))

    z = (x**0.5 + y**5) + (y**0.5 + x**4)
    print("El resultado es ", z)
  except:
    os.system("clear")
    print("Error, solo se aceptan numeros")


def divmod():
  print("===== DIVMOD =====")
  print("¿Cual es el residuo de dividir 2^100 entre 13?")
  try:
    x = int(input("1. enter a number: "))
    y = int(input("2. enter a number (potencia): "))
    z = int(input("3. enter a number: "))

    potencia = (x**y)
    residuo = divmod(potencia, z)

    print(f"El resultado es: {residuo}")

  except:
    os.system("clear")
    print("Error, solo se aceptan numeros")