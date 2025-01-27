/*
Ejercicio 5: Contar Ocurrencias
Enunciado:
Dado un array arr[] = {5, 7, 5, 2, 7, 5, 9} y un numero x,
escribe un programa que cuente cuantas veces aparece x en el array.

Ejemplo:
Si x = 5 → "El numero aparece 3 veces".
Si x = 7 → "El numero aparece 2 veces".
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {5, 7, 5, 2, 7, 5, 9};
  int n = 7, x, contador = 0;

  cout << "Ingrese el numero a contar: ";
  cin >> x;

  for (int i = 0; i < n; i++) {
    if (arr[i] == x)
      contador++;
  }

  if (contador > 0)
    cout << "El numero aparece " << contador << " veces" << endl;
  else
    cout << "El numero no aparece en el array" << endl;

  return 0;
}
