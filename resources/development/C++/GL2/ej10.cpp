// 10. Crear un arreglo de 6 numeros enteros. Rotar una posicion a la derecha y
// mostrar el resultado.
#include <iostream>
using namespace std;

int main() {
  int arr[6];
  cout << "Ingrese 6 numeros enteros:" << endl;
  for (int i = 0; i < 6; i++) {
    cout << "Numero " << (i + 1) << ": ";
    cin >> arr[i];
  }
  int ultimo = arr[5];
  for (int i = 5; i > 0; i--) {
    arr[i] = arr[i - 1];
  }
  arr[0] = ultimo;

  cout << "Arreglo rotado: ";
  for (int i = 0; i < 6; i++)
    cout << arr[i] << " ";
  cout << endl;
  return 0;
}
