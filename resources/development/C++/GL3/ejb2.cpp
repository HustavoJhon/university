// 2. Crear una matriz de 2x2 numeros enteros. Ingresar valores y calcular la
// transpuesta. Mostrar ambas matrices.
#include <iostream>
using namespace std;

int main() {
  int mat[2][2], trans[2][2];
  cout << "Ingrese los valores de la matriz 2x2:" << endl;
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++) {
      cout << "Valor [" << i << "][" << j << "]: ";
      cin >> mat[i][j];
      trans[j][i] = mat[i][j];
    }
  }
  cout << "Matriz original:" << endl;
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++)
      cout << mat[i][j] << " ";
    cout << endl;
  }
  cout << "Matriz transpuesta:" << endl;
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++)
      cout << trans[i][j] << " ";
    cout << endl;
  }
  return 0;
}
