#include <iostream>
#include <string>
using namespace std;

class Empleado {
private:
  int codigo;
  string nombre;
  double salario;
  int horasTrabajadas;

public:
  void registrar(int _codigo, string _nombre, double _salario,
                 int _horasTrabajadas) {
    codigo = _codigo;
    nombre = _nombre;
    salario = _salario;
    horasTrabajadas = _horasTrabajadas;
  }

  double calcularSalario() {
    int horasNormales = (horasTrabajadas > 40) ? 40 : horasTrabajadas;
    int horasExtras = (horasTrabajadas > 40) ? horasTrabajadas - 40 : 0;
    return horasNormales * salario + horasExtras * salario * 1.5;
  }

  void mostrar() {
    cout << "Codigo: " << codigo << endl;
    cout << "Nombre: " << nombre << endl;
    cout << "Horas trabajadas: " << horasTrabajadas << endl;
    cout << "Pago por hora: $" << salario << endl;
    cout << "Horas extras: "
         << ((horasTrabajadas > 40) ? horasTrabajadas - 40 : 0) << endl;
    cout << "Salario mensual: $" << calcularSalario() << endl;
    cout << "---------------------------" << endl;
  }
};

int main() {
  Empleado empleado1;
  empleado1.registrar(101, "Carlos Perez", 20.0, 45);
  empleado1.mostrar();

  Empleado empleado2;
  empleado2.registrar(102, "Ana Gomez", 22.5, 38);
  empleado2.mostrar();

  return 0;
}
