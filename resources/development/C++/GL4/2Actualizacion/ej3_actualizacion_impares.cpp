/*
Ejercicio 3: Reemplazo Condicional en Array
Enunciado:
Dado un array de 8 numeros enteros arr[] = {4, 6, 7, 2, 5, 3, 9, 8},
escribe un programa que recorra el array y reemplace todos
los numeros impares por el numero 0.

Ejemplo:
El array despues de la actualizacion sera {4, 0, 0, 2, 0, 0, 0, 8}.
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {4, 6, 7, 2, 5, 3, 9, 8};

  for (int i = 0; i < 8; i++) {
    if (arr[i] % 2 != 0)
      arr[i] = 0;
  }

  cout << "Array actualizado: ";
  for (int i = 0; i < 8; i++)
    cout << arr[i] << " ";
  return 0;
}
