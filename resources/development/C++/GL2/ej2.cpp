// 2. Crear un arreglo de 8 numeros enteros. Permitir al usuario ingresar los 8
// numeros y luego pedir un numero para buscar. Verificar si el numero ingresado
// esta presente en el arreglo.
#include <iostream>
using namespace std;

int main() {
  int arr[8], buscar;
  cout << "Ingrese 8 numeros enteros:" << endl;
  for (int i = 0; i < 8; i++) {
    cout << "Numero " << (i + 1) << ": ";
    cin >> arr[i];
  }
  cout << "Ingrese el numero que desea buscar: ";
  cin >> buscar;

  bool encontrado = false;
  for (int i = 0; i < 8; i++) {
    if (arr[i] == buscar) {
      encontrado = true;
      break;
    }
  }
  cout << (encontrado ? "El numero SI se encuentra en el arreglo."
                      : "El numero NO se encuentra en el arreglo.")
       << endl;
  return 0;
}
