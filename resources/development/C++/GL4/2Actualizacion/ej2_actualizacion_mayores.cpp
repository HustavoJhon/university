/*
Ejercicio 2: Actualizar Todos los Elementos Mayores a un Valor
Enunciado:
Dado un array de enteros arr[] = {10, 3, 8, 15, 25, 18},
escribe un programa que actualice todos los elementos
mayores a 10 y los cambie por el valor 10.

Ejemplo:
El array original seria {10, 3, 8, 15, 25, 18}
y despues de la actualizacion quedaria {10, 3, 8, 10, 10, 10}.
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {10, 3, 8, 15, 25, 18};

  for (int i = 0; i < 6; i++) {
    if (arr[i] > 10)
      arr[i] = 10;
  }

  cout << "Array actualizado: ";
  for (int i = 0; i < 6; i++)
    cout << arr[i] << " ";
  return 0;
}
