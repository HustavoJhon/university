/*
Ejercicio 4: Actualizar valor en índice
Enunciado:
Dado arr[] = {3, 8, 10, 4, 7}, permite al usuario ingresar un índice n y un
valor v.
 - Si el índice es válido, reemplazar arr[n] = v.
 - Si no es válido, mostrar error.
Ejemplo:
n=2, v=20 → {3, 8, 20, 4, 7}.
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {3, 8, 10, 4, 7};
  int n = 5, pos, v;

  cout << "Ingrese indice y valor: ";
  cin >> pos >> v;

  if (pos >= 0 && pos < n) {
    arr[pos] = v;
    cout << "Array actualizado: ";
    for (int i = 0; i < n; i++)
      cout << arr[i] << " ";
  } else {
    cout << "Error: indice invalido";
  }
  cout << endl;
  return 0;
}
