/*
Ejercicio 1: Busqueda Lineal
Enunciado:
Dado un array arr[] = {3, 8, 15, 7, 20, 5} y un numero x,
escribe un programa que busque x dentro del array usando
busqueda lineal. El programa debe indicar si el numero existe
y en que posicion se encuentra.

Ejemplo:
Si x = 7 → "Encontrado en la posicion 3".
Si x = 9 → "No encontrado".
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {3, 8, 15, 7, 20, 5};
  int x, n = 6;
  bool encontrado = false;

  cout << "Ingrese el numero a buscar: ";
  cin >> x;

  for (int i = 0; i < n; i++) {
    if (arr[i] == x) {
      cout << "Encontrado en la posicion " << i << endl;
      encontrado = true;
      break;
    }
  }

  if (!encontrado)
    cout << "No encontrado" << endl;

  return 0;
}
