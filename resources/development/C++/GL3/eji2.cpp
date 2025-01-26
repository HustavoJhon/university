// 2. Rotacion 90 grados antihorario de una matriz 4x4
#include <iostream>
using namespace std;

int main() {
  int mat[4][4], rotada[4][4];

  cout << "Ingrese los valores de la matriz 4x4:" << endl;
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      cout << "Valor [" << i << "][" << j << "]: ";
      cin >> mat[i][j];
    }
  }

  // Rotacion 90 grados antihorario
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      rotada[4 - j - 1][i] = mat[i][j];
    }
  }

  cout << "Matriz original:" << endl;
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      cout << mat[i][j] << " ";
    }
    cout << endl;
  }

  cout << "Matriz rotada 90 grados antihorario:" << endl;
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      cout << rotada[i][j] << " ";
    }
    cout << endl;
  }
  return 0;
}
