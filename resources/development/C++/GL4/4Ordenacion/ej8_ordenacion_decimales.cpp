/*
Ejercicio 8: Ordenacion de Array con Decimales
Enunciado:
Dado el array arr[] = {12.5, 3.7, 9.1, 7.8, 5.4}, implementa el
algoritmo de ordenacion por burbuja para ordenar el array de menor
a mayor.
Resultado esperado: {3.7, 5.4, 7.8, 9.1, 12.5}
*/

#include <iostream>
using namespace std;

int main() {
  double arr[] = {12.5, 3.7, 9.1, 7.8, 5.4};
  int n = 5;

  for (int i = 0; i < n - 1; i++) {
    for (int j = 0; j < n - i - 1; j++) {
      if (arr[j] > arr[j + 1]) {
        double temp = arr[j];
        arr[j] = arr[j + 1];
        arr[j + 1] = temp;
      }
    }
  }

  cout << "Array ordenado: ";
  for (int i = 0; i < n; i++)
    cout << arr[i] << " ";
  cout << endl;
  return 0;
}
