print("""THE PROBLEM IS:
  - Cual es el residuo de multiplicar a * b / 35
  - Si a = residuo de 5 raiz de 16 entre 20
  - b = 2^100 - (20*5) + 4 + 6 + 2 - 4 - 5 - 5
""")


def problem_1():
  print("=====PROBLEMA 1=====")
  a = int(input("1. enter a number: "))
  b = int(input("2. enter a number: "))
  c = int(input("3. enter a number: "))

  resultado = (a * b) / 35
  residuo = divmod(resultado, c)

  print(f"El resultado es: {resultado} y el residuo es: {residuo}")


def problem_2():
  print("=====PROBLEMA 2=====")
  a = int(input("1. enter a number: "))
  b = int(input("2. enter a number: "))
  c = int(input("3. enter a number: "))

  # 16 ** (1 / 5)

  resultado = a**(1 / b)
  residuo = divmod(resultado, c)

  print(f"El resultado es: {residuo}")


def problem_3():
  print("=====PROBLEMA 3=====")
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

  resultado = a**b - (c * d) + e + f + g - h - i - j

  print("El resultado es ", resultado)
