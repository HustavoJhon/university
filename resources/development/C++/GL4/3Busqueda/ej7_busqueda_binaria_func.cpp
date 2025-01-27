/*
Ejercicio 7: Ultima Aparicion
Enunciado:
Dado un array arr[] = {3, 5, 7, 5, 9, 5, 11} y un numero x,
escribe un programa que muestre la ultima posicion donde aparece x.

Ejemplo:
Si x = 5 → "Ultima aparicion en la posicion 5".
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {3, 5, 7, 5, 9, 5, 11};
  int n = 7, x;
  int posicion = -1;

  cout << "Ingrese el numero a buscar: ";
  cin >> x;

  for (int i = 0; i < n; i++) {
    if (arr[i] == x)
      posicion = i;
  }

  if (posicion != -1)
    cout << "Ultima aparicion en la posicion " << posicion << endl;
  else
    cout << "No encontrado" << endl;

  return 0;
}
