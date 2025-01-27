/*
Ejercicio 2: Busqueda del Maximo
Enunciado:
Dado un array arr[] = {12, 5, 8, 20, 7, 15},
escribe un programa que encuentre el numero mayor en el array.

Ejemplo:
El maximo es 20.
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {12, 5, 8, 20, 7, 15};
  int n = 6;
  int maximo = arr[0];

  for (int i = 1; i < n; i++) {
    if (arr[i] > maximo)
      maximo = arr[i];
  }

  cout << "El maximo es: " << maximo << endl;
  return 0;
}
