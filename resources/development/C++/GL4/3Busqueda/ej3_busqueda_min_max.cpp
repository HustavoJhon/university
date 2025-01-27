/*
Ejercicio 3: Busqueda del Minimo
Enunciado:
Dado un array arr[] = {18, 25, 7, 12, 30, 5},
escribe un programa que encuentre el numero menor en el array.

Ejemplo:
El minimo es 5.
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {18, 25, 7, 12, 30, 5};
  int n = 6;
  int minimo = arr[0];

  for (int i = 1; i < n; i++) {
    if (arr[i] < minimo)
      minimo = arr[i];
  }

  cout << "El minimo es: " << minimo << endl;
  return 0;
}
