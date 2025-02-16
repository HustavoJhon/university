/* Ejercicio 15: Registro de Pacientes y Consultas Médicas 

Crea un programa donde se cree un registro para almacenar el nombre del paciente, edad, número de historia clínica y fecha de última consulta de n pacientes. Dentro de este registro, debe haber un registro anidado para almacenar los detalles de la consulta médica, que contenga:
    • Diagnóstico
    • Tratamiento prescrito
El programa debe calcular el promedio de edad de todos los pacientes y mostrar los registros ingresados, junto con el promedio de edad.
*/
#include <iostream>
using namespace std;
struct Consulta {
  string diagnostico;
  string tratamiento;
};
struct Paciente {
  string nombre;
  int edad;
  int historia;
  string fecha;
  Consulta c;
};
int main() {
  int n;
  cout << "Cantidad pacientes: ";
  cin >> n;
  Paciente p[n];
  int suma = 0;
  for (int i = 0; i < n; i++) {
    cout << "\nPaciente " << i + 1 << endl;
    cout << "Nombre: ";
    cin >> p[i].nombre;
    cout << "Edad: ";
    cin >> p[i].edad;
    suma += p[i].edad;
    cout << "Historia: ";
    cin >> p[i].historia;
    cout << "Fecha: ";
    cin >> p[i].fecha;
    cout << "Diagnostico: ";
    cin >> p[i].c.diagnostico;
    cout << "Tratamiento: ";
    cin >> p[i].c.tratamiento;
  }
  cout << "Promedio edad: " << (float)suma / n << endl;
  return 0;
}
