/*
Ejercicio 4: Busqueda Binaria
Enunciado:
Dado un array ordenado arr[] = {2, 4, 6, 8, 10, 12, 14}
y un numero x, escribe un programa que realice una busqueda
binaria para determinar si x existe en el array y en que
posicion se encuentra.

Ejemplo:
Si x = 10 → "Encontrado en la posicion 4".
Si x = 5 → "No encontrado".
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {2, 4, 6, 8, 10, 12, 14};
  int n = 7, x;
  cout << "Ingrese el numero a buscar: ";
  cin >> x;

  int inicio = 0, fin = n - 1, medio;
  bool encontrado = false;

  while (inicio <= fin) {
    medio = (inicio + fin) / 2;
    if (arr[medio] == x) {
      cout << "Encontrado en la posicion " << medio << endl;
      encontrado = true;
      break;
    } else if (arr[medio] < x) {
      inicio = medio + 1;
    } else {
      fin = medio - 1;
    }
  }

  if (!encontrado)
    cout << "No encontrado" << endl;
  return 0;
}
