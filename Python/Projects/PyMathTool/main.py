import os
import rich
from fist_class import multiplicaciones_divisiones
from fist_class import sumas_restas
from fist_class import potencia
from fist_class import raiz
from fist_class import divmod

from practice import problem_1
from practice import problem_2
from practice import problem_3

# from nice import rich_print

if __name__ == "__main__":
  user = input("""Que quieres hacer? \n 
      [1]. Sumas y restas 
      [2]. Multiplicaciones 
      [3]. Potencia 
      [4]. Raiz 
      [5]. Div 
      [6]. Practice\n
      >>> """)
  os.system("clear")
  if user == "1":
    sumas_restas()
    os.system("clear")
  elif user == "2":
    multiplicaciones_divisiones()
    os.system("clear")
  elif user == "3":
    os.system("clear")
    potencia()
  elif user == "4":
    os.system("clear")
    raiz()
  elif user == "5":
    divmod()
  elif user == "6":
    os.system("clear")
    problem_1()
    problem_2()
    problem_3()
 # elif user == "7":
 #   os.system("clear")
 #   rich_print()

  else:
    print("Adios, Gracias por usar el programa")

