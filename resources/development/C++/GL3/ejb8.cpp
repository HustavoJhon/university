// 8. Crear una matriz de 4x4 numeros enteros. Ingresar valores y calcular el
// producto de todos los elementos.
#include <iostream>
using namespace std;

int main() {
  int mat[4][4];
  long long producto = 1;
  cout << "Ingrese los valores de la matriz 4x4:" << endl;
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      cout << "Valor [" << i << "][" << j << "]: ";
      cin >> mat[i][j];
      producto *= mat[i][j];
    }
  }
  cout << "El producto de todos los elementos es: " << producto << endl;
  return 0;
}
