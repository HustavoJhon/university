// 1. Crear dos matrices de 2x2 y sumarlas
#include <iostream>
using namespace std;

int main() {
  int a[2][2], b[2][2], suma[2][2];

  cout << "Ingrese los valores de la primera matriz 2x2:" << endl;
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++) {
      cout << "A[" << i << "][" << j << "]: ";
      cin >> a[i][j];
    }
  }

  cout << "Ingrese los valores de la segunda matriz 2x2:" << endl;
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++) {
      cout << "B[" << i << "][" << j << "]: ";
      cin >> b[i][j];
    }
  }

  cout << "Matriz suma:" << endl;
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++) {
      suma[i][j] = a[i][j] + b[i][j];
      cout << suma[i][j] << " ";
    }
    cout << endl;
  }
  return 0;
}
