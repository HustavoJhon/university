/*
Ejercicio 1: Registro de Estudiantes y Promedio

Crea un programa donde se cree un registro para almacenar el código, nombre,
nota consolidada 1, nota consolidada 2, nota del parcial y nota final de n
estudiantes. Además, debe calcular el promedio de cada estudiante y mostrar
todos los registros ingresados por pantalla, junto con su promedio final.
*/

#include <iostream>
using namespace std;

struct Estudiante {
  int codigo;
  string nombre;
  float nota1, nota2, parcial, final;
  float promedio;
};

int main() {
  int n;
  cout << "Ingrese la cantidad de estudiantes: ";
  cin >> n;
  Estudiante est[n];
  for (int i = 0; i < n; i++) {
    cout << "\nEstudiante " << i + 1 << endl;
    cout << "Codigo: ";
    cin >> est[i].codigo;
    cout << "Nombre: ";
    cin >> est[i].nombre;
    cout << "Nota 1: ";
    cin >> est[i].nota1;
    cout << "Nota 2: ";
    cin >> est[i].nota2;
    cout << "Parcial: ";
    cin >> est[i].parcial;
    cout << "Final: ";
    cin >> est[i].final;
    est[i].promedio =
        (est[i].nota1 + est[i].nota2 + est[i].parcial + est[i].final) / 4;
  }
  cout << "\n--- Resultados ---\n";
  for (int i = 0; i < n; i++) {
    cout << "Codigo: " << est[i].codigo << " | Nombre: " << est[i].nombre
         << " | Promedio: " << est[i].promedio << endl;
  }
  return 0;
}
