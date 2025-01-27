/*
Ejercicio 1: Actualizar y Ordenar Array
Enunciado:
Dado un array de enteros arr[] = {7, 1, 3, 5, 2}, escribe un programa que:
 - Primero actualice el valor en el índice 2 a 8.
 - Luego, ordene el array en orden ascendente.
Ejemplo:
El array después de la actualización y ordenación será {1, 2, 5, 7, 8}.
*/

#include <algorithm>
#include <iostream>
using namespace std;

int main() {
  int arr[] = {7, 1, 3, 5, 2};
  int n = 5;

  arr[2] = 8; // actualizar índice 2

  sort(arr, arr + n); // ordenar ascendente

  cout << "Array actualizado y ordenado: ";
  for (int i = 0; i < n; i++)
    cout << arr[i] << " ";
  cout << endl;
  return 0;
}
