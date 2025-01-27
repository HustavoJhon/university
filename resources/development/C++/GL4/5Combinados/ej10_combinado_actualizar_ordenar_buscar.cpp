/*
Ejercicio 10: Actualizar, Ordenar y Buscar
Enunciado:
Dado arr[] = {10, 30, 5, 15, 25}, realiza:
 - Actualiza arr[2] = 40.
 - Ordena el array ascendente.
 - Busca el número 25 con búsqueda binaria.
Ejemplo:
Ordenado → {10, 15, 25, 30, 40}, posición del 25 = 2.
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
    else if (arr[mid] < x)
      inicio = mid + 1;
    else
      fin = mid - 1;
  }
  return -1;
}

int main() {
  int arr[] = {10, 30, 5, 15, 25};
  int n = 5;

  arr[2] = 40;        // actualización
  sort(arr, arr + n); // ordenar

  cout << "Array ordenado: ";
  for (int i = 0; i < n; i++)
    cout << arr[i] << " ";
  cout << endl;

  int pos = busquedaBinaria(arr, n, 25);
  if (pos != -1)
    cout << "El numero 25 esta en la posicion " << pos << endl;
  else
    cout << "No encontrado" << endl;

  return 0;
}
