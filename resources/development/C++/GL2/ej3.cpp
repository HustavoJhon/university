// 3. Crear un arreglo de 4 numeros enteros. Permitir al usuario ingresar los 4
// numeros y luego pedir un factor de multiplicacion. Multiplicar todos los
// elementos del arreglo por el factor y mostrar el nuevo arreglo resultante.
#include <iostream>
using namespace std;

int main() {
  int arr[4], factor;
  cout << "Ingrese 4 numeros enteros:" << endl;
  for (int i = 0; i < 4; i++) {
    cout << "Numero " << (i + 1) << ": ";
    cin >> arr[i];
  }
  cout << "Ingrese el factor de multiplicacion: ";
  cin >> factor;

  cout << "Arreglo resultante: ";
  for (int i = 0; i < 4; i++) {
    cout << arr[i] * factor << " ";
  }
  cout << endl;
  return 0;
}
