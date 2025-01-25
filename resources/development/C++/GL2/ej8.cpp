// 8. Crear un arreglo de 4 numeros enteros. Permitir al usuario ingresar los 4
// numeros y calcular el producto de todos los elementos.
#include <iostream>
using namespace std;

int main() {
  int arr[4], producto = 1;
  cout << "Ingrese 4 numeros enteros:" << endl;
  for (int i = 0; i < 4; i++) {
    cout << "Numero " << (i + 1) << ": ";
    cin >> arr[i];
    producto *= arr[i];
  }
  cout << "El producto de todos los elementos es: " << producto << endl;
  return 0;
}
