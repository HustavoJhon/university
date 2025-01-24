#include <iostream>
using namespace std;

class Empleado {
private:
  string nombre;
  double pagoHora;
  int horas;

public:
  void Registrar() {
    cout << "Nombre: ";
    getline(cin, nombre);
    cout << "Pago por hora: ";
    cin >> pagoHora;
    cout << "Horas trabajadas: ";
    cin >> horas;
  }
  double CalcularSalario() {
    if (horas <= 40)
      return horas * pagoHora;
    else
      return 40 * pagoHora + (horas - 40) * pagoHora * 1.5;
  }
  int HorasExtras() {
    if (horas > 40)
      return horas - 40;
    else
      return 0;
  }
  void MostrarInformacion() {
    cout << "Empleado: " << nombre << "\nHoras: " << horas
         << "\nHoras Extras: " << HorasExtras()
         << "\nSalario: " << CalcularSalario() << endl;
  }
};

int main() {
  Empleado empleado;
  empleado.Registrar();
  empleado.MostrarInformacion();
  return 0;
}
