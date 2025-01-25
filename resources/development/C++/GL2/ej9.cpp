// 9. Crear un arreglo de 12 numeros enteros. Permitir al usuario ingresarlos.
// Luego, dividir en dos arreglos: pares e impares. Mostrar ambos.
#include <iostream>
using namespace std;

int main() {
  int arr[12], pares[12], impares[12], cp = 0, ci = 0;
  cout << "Ingrese 12 numeros enteros:" << endl;
  for (int i = 0; i < 12; i++) {
    cout << "Numero " << (i + 1) << ": ";
    cin >> arr[i];
    if (arr[i] % 2 == 0)
      pares[cp++] = arr[i];
    else
      impares[ci++] = arr[i];
  }
  cout << "Arreglo de pares: ";
  for (int i = 0; i < cp; i++)
    cout << pares[i] << " ";
  cout << endl;

  cout << "Arreglo de impares: ";
  for (int i = 0; i < ci; i++)
    cout << impares[i] << " ";
  cout << endl;

  return 0;
}
