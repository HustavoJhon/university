/*
Ejercicio 6: Primera Aparicion
Enunciado:
Dado un array arr[] = {4, 8, 6, 8, 10, 8, 12} y un numero x,
escribe un programa que muestre la primera posicion donde aparece x.

Ejemplo:
Si x = 8 → "Primera aparicion en la posicion 1".
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {4, 8, 6, 8, 10, 8, 12};
  int n = 7, x;
  bool encontrado = false;

  cout << "Ingrese el numero a buscar: ";
  cin >> x;

  for (int i = 0; i < n; i++) {
    if (arr[i] == x) {
      cout << "Primera aparicion en la posicion " << i << endl;
      encontrado = true;
      break;
    }
  }

  if (!encontrado)
    cout << "No encontrado" << endl;
  return 0;
}
