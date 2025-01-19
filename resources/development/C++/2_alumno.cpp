#include <iostream>
#include <string>
using namespace std;

class Alumno {
private:
  int codigo;
  string nombre;
  string genero;
  int edad;

public:
  void registrar() {
    cout << "Ingrese codigo: ";
    cin >> codigo;
    cout << "Ingrese nombre: ";
    cin >> nombre;
    cout << "Ingrese genero: ";
    cin >> genero;
    cout << "Ingrese edad: ";
    cin >> edad;
  }

  void mostrar() {
    cout << "Datos del Alumno ";
    cout << "Codigo: " << codigo << endl;
    cout << "Nombre: " << nombre << endl;
    cout << "Genero: " << genero << endl;
    cout << "Edad: " << edad << endl;
  }
};

int main() {
  Alumno alumno1;
  alumno1.registrar();
  alumno1.mostrar();

  return 0;
}
