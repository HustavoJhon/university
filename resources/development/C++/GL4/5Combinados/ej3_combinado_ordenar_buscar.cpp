/*
Ejercicio 3: Ordenar y Buscar Elemento
Enunciado:
Dado el array arr[] = {12, 5, 7, 2, 9, 8}, realiza:
 - Ordenar el array en orden descendente.
 - Buscar el número 7 usando búsqueda binaria.
Ejemplo:
Ordenado: {12, 9, 8, 7, 5, 2}, posición del 7 = 3.
*/

#include <algorithm>
#include <iostream>
using namespace std;

int busquedaBinaria(int arr[], int n, int x) {
  int inicio = 0, fin = n - 1;
  while (inicio <= fin) {
    int mid = (inicio + fin) / 2;
    if (arr[mid] == x)
      return mid;
    else if (arr[mid] > x)
      inicio = mid + 1;
    else
      fin = mid - 1;
  }
  return -1;
}

int main() {
  int arr[] = {12, 5, 7, 2, 9, 8};
  int n = 6;

  sort(arr, arr + n, greater<int>());

  cout << "Array ordenado: ";
  for (int i = 0; i < n; i++)
    cout << arr[i] << " ";
  cout << endl;

  int pos = busquedaBinaria(arr, n, 7);
  if (pos != -1)
    cout << "El numero 7 esta en la posicion " << pos << endl;
  else
    cout << "No encontrado" << endl;

  return 0;
}
