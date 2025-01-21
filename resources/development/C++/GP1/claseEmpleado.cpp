#include <iostream>
#include <string>
using namespace std;

class Empleado {
private:
  string nombre;
  double salarioPorHora;
  int horasTrabajadas;

public:
  void Registrar() {
    cout << "Ingrese nombre del empleado: ";
    getline(cin, nombre);
    cout << "Ingrese salario por hora: ";
    cin >> salarioPorHora;
    cout << "Ingrese horas trabajadas: ";
    cin >> horasTrabajadas;
    cin.ignore();
  }

  double CalcularSalario() {
    double salario;
    if (horasTrabajadas > 40) {
      int extras = horasTrabajadas - 40;
      salario = (40 * salarioPorHora) + (extras * salarioPorHora * 1.5);
    } else {
      salario = horasTrabajadas * salarioPorHora;
    }
    return salario;
  }

  void MostrarInformacion() {
    cout << "\n--- Información del Empleado ---\n";
    cout << "Nombre: " << nombre << endl;
    cout << "Horas trabajadas: " << horasTrabajadas << endl;
    cout << "Salario calculado: " << CalcularSalario() << endl;
  }

  int HorasExtras() {
    return (horasTrabajadas > 40) ? horasTrabajadas - 40 : 0;
  }
};

int main() {
  Empleado emp;
  emp.Registrar();
  emp.MostrarInformacion();
  cout << "Horas extras: " << emp.HorasExtras() << endl;
  return 0;
}
