/*
Ejercicio 9: Ordenar y buscar mayor
Enunciado:
Dado arr[] = {2, 4, 5, 8, 1}, ordena ascendente y encuentra el mayor y su
índice. Ejemplo: Ordenado: {1, 2, 4, 5, 8}, mayor=8 en índice=4.
*/

#include <algorithm>
#include <iostream>
using namespace std;

int main() {
  int arr[] = {2, 4, 5, 8, 1};
  int n = 5;

  sort(arr, arr + n);

  cout << "Array ordenado: ";
  for (int i = 0; i < n; i++)
    cout << arr[i] << " ";
  cout << endl;

  cout << "El mayor es " << arr[n - 1] << " en el indice " << n - 1 << endl;
  return 0;
}
