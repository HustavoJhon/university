// 5. Crear un arreglo donde se ingresen 7 notas. Calcular la nota minima, el
// promedio de notas aprobadas (>=10.5) y el promedio de notas desaprobadas
// (<10.5).
#include <iostream>
using namespace std;

int main() {
  float notas[7];
  float sumaA = 0, sumaD = 0;
  int contA = 0, contD = 0;
  float min;

  cout << "Ingrese 7 notas:" << endl;
  for (int i = 0; i < 7; i++) {
    cout << "Nota " << (i + 1) << ": ";
    cin >> notas[i];
    if (i == 0)
      min = notas[i];
    if (notas[i] < min)
      min = notas[i];
    if (notas[i] >= 10.5) {
      sumaA += notas[i];
      contA++;
    } else {
      sumaD += notas[i];
      contD++;
    }
  }

  cout << "Nota minima: " << min << endl;
  cout << "Promedio de notas aprobadas: " << (contA ? sumaA / contA : 0)
       << endl;
  cout << "Promedio de notas desaprobadas: " << (contD ? sumaD / contD : 0)
       << endl;
  return 0;
}
