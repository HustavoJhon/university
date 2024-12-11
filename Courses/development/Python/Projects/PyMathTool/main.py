import os

from rich import print
from rich.console import Console

from fist_class import multiplicaciones_divisiones
from fist_class import sumas_restas
from fist_class import potencia
from fist_class import raiz
from fist_class import divmod

from practice import problem_1
from practice import problem_2
from practice import problem_3

console = Console()


if __name__ == "__main__":
  print("""
  [bold]Que quieres hacer?[/bold]\n 
      [blue][1]. Sumas y restas 
      [2]. Multiplicaciones 
      [3]. Potencia 
      [4]. Raiz 
      [5]. Div 
      [6]. Practice[/blue]\n""")
  user = int(input(">>> "))
  os.system("clear")
  try:
    if user == 1:
      sumas_restas()
    elif user == 2:
      multiplicaciones_divisiones()
    elif user == 3:
      potencia()
    elif user == 4:
      raiz()
    elif user == 5:
      divmod()
    elif user == 6:
      problem_1()
      problem_2()
      problem_3()
    else:
      print("[red]Adios[/red], Gracias por usar el programa!")
  except:
    os.system("clear")
    print("Error, solo se aceptan numeros")

