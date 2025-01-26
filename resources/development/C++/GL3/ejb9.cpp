// 9. Crear una matriz de 3x3 numeros enteros. Ingresar valores y verificar si
// existe algun numero negativo.
#include <iostream>
using namespace std;

int main() {
  int mat[3][3];
  bool hayNegativo = false;

  cout << "Ingrese los valores de la matriz 3x3:" << endl;
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      cout << "Valor [" << i << "][" << j << "]: ";
      cin >> mat[i][j];
      if (mat[i][j] < 0)
        hayNegativo = true;
    }
  }
  if (hayNegativo) {
    cout << "La matriz tiene al menos un numero negativo." << endl;
  } else {
    cout << "La matriz no tiene numeros negativos." << endl;
  }
  return 0;
}
