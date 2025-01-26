// 3. Crear una matriz de 4x4 numeros enteros. Ingresar valores y calcular la
// suma de la diagonal principal.
#include <iostream>
using namespace std;

int main() {
  int mat[4][4], suma = 0;
  cout << "Ingrese los valores de la matriz 4x4:" << endl;
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      cout << "Valor [" << i << "][" << j << "]: ";
      cin >> mat[i][j];
      if (i == j)
        suma += mat[i][j];
    }
  }
  cout << "Suma diagonal principal: " << suma << endl;
  return 0;
}
