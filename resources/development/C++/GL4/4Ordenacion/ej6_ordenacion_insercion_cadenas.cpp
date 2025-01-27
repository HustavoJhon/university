/*
Ejercicio 6: Ordenacion por Insercion en Array de Cadenas
Enunciado:
Dado el array arr[] = {"manzana", "banana", "naranja", "cereza"},
implementa el algoritmo de ordenacion por insercion para ordenarlo
alfabeticamente de menor a mayor.
Resultado esperado: {"banana", "cereza", "manzana", "naranja"}
*/

#include <iostream>
#include <string>
using namespace std;

int main() {
  string arr[] = {"manzana", "banana", "naranja", "cereza"};
  int n = 4;

  for (int i = 1; i < n; i++) {
    string clave = arr[i];
    int j = i - 1;
    while (j >= 0 && arr[j] > clave) {
      arr[j + 1] = arr[j];
      j--;
    }
    arr[j + 1] = clave;
  }

  cout << "Array ordenado: ";
  for (int i = 0; i < n; i++)
    cout << arr[i] << " ";
  cout << endl;
  return 0;
}
