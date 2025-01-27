/*
Ejercicio 6: Eliminar elementos por valor
Enunciado:
Dado arr[] = {10, 20, 30, 40, 50}, elimina todas las apariciones de x.
Ejemplo:
Si x=30 → {10, 20, 40, 50}.
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {10, 20, 30, 40, 50};
  int n = 5, x;

  cout << "Ingrese el numero a eliminar: ";
  cin >> x;

  int k = 0;
  for (int i = 0; i < n; i++)
    if (arr[i] != x)
      arr[k++] = arr[i];

  cout << "Array actualizado: ";
  for (int i = 0; i < k; i++)
    cout << arr[i] << " ";
  cout << endl;
  return 0;
}
