// 7. Crear un arreglo de 7 numeros enteros. Permitir al usuario ingresar los 7
// numeros y luego pedir un numero de referencia. Mostrar la posicion en el
// arreglo del primer elemento que coincida.
#include <iostream>
using namespace std;

int main() {
  int arr[7], ref;
  cout << "Ingrese 7 numeros enteros:" << endl;
  for (int i = 0; i < 7; i++) {
    cout << "Numero " << (i + 1) << ": ";
    cin >> arr[i];
  }
  cout << "Ingrese el numero de referencia: ";
  cin >> ref;

  int pos = -1;
  for (int i = 0; i < 7; i++) {
    if (arr[i] == ref) {
      pos = i;
      break;
    }
  }

  if (pos != -1)
    cout << "El numero se encuentra en la posicion: " << pos << endl;
  else
    cout << "El numero no se encontro en el arreglo." << endl;

  return 0;
}
