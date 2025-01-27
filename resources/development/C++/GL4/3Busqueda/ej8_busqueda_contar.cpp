/*
Ejercicio 8: Mostrar Todas las Posiciones
Enunciado:
Dado un array arr[] = {2, 4, 6, 4, 8, 4, 10} y un numero x,
escribe un programa que muestre todas las posiciones donde aparece x.

Ejemplo:
Si x = 4 → "Aparece en las posiciones: 1, 3, 5".
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {2, 4, 6, 4, 8, 4, 10};
  int n = 7, x;
  bool encontrado = false;

  cout << "Ingrese el numero a buscar: ";
  cin >> x;

  cout << "El numero aparece en las posiciones: ";
  for (int i = 0; i < n; i++) {
    if (arr[i] == x) {
      cout << i << " ";
      encontrado = true;
    }
  }

  if (!encontrado)
    cout << "Ninguna";
  cout << endl;

  return 0;
}
