/*
Ejercicio 2: Búsqueda y Actualización
Enunciado:
Dado un array arr[] = {3, 8, 10, 15, 5}, busca un número x dado por el usuario.
 - Si se encuentra, actualizarlo al doble.
 - Si no se encuentra, agregarlo al final.
Ejemplo:
Si x = 8 → {3, 16, 10, 15, 5}.
*/

#include <iostream>
using namespace std;

int main() {
  int arr[100] = {3, 8, 10, 15, 5};
  int n = 5, x;
  bool encontrado = false;

  cout << "Ingrese un numero: ";
  cin >> x;

  for (int i = 0; i < n; i++) {
    if (arr[i] == x) {
      arr[i] *= 2;
      encontrado = true;
    }
  }

  if (!encontrado)
    arr[n++] = x;

  cout << "Array actualizado: ";
  for (int i = 0; i < n; i++)
    cout << arr[i] << " ";
  cout << endl;
  return 0;
}
