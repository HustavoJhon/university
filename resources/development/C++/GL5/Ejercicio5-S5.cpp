/*
Ejercicio 5: Registro de Empleados y Salario Anual

Crea un programa donde se cree un registro para almacenar el nombre, cargo, fecha de ingreso y salario mensual de n empleados. El programa debe calcular el salario anual (salario mensual * 12) de cada empleado. Si el empleado tiene más de 5 años en la empresa, debe aplicarse un bono del 10% sobre el salario anual. Finalmente, debe mostrar los registros ingresados junto con el salario anual y si se aplicó un bono.
*/
#include <iostream>
using namespace std;

struct Empleado {
  string nombre;
  string cargo;
  int anioIngreso;
  float salarioMensual;
  float salarioAnual;
};

int main() {
  int n;
  cout << "Ingrese la cantidad de empleados: ";
  cin >> n;
  Empleado e[n];
  int actual = 2025;
  for (int i = 0; i < n; i++) {
    cout << "\nEmpleado " << i + 1 << endl;
    cout << "Nombre: ";
    cin >> e[i].nombre;
    cout << "Cargo: ";
    cin >> e[i].cargo;
    cout << "Anio de ingreso: ";
    cin >> e[i].anioIngreso;
    cout << "Salario mensual: ";
    cin >> e[i].salarioMensual;
    e[i].salarioAnual = e[i].salarioMensual * 12;
    if (actual - e[i].anioIngreso > 5)
      e[i].salarioAnual *= 1.1;
  }
  cout << "\n--- Empleados ---\n";
  for (int i = 0; i < n; i++) {
    cout << e[i].nombre << " | Cargo: " << e[i].cargo
         << " | Salario Anual: " << e[i].salarioAnual << endl;
  }
  return 0;
}
