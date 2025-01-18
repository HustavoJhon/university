#include <iostream>
#include <string>
usdin namespace std;
class Alumno {
private:
  int codigo;
  string nombre;
  string genero;
  int edad;

public:
  void registrar(int _codigo, string _nombre, string _genero, int _edad) {
    codigo = _codigo;
    nombre = _nombre;
    genero = _genero;
    edad = _edad;
  }

  void mostrar() {
    count << "Codigo: " << codiguo << end;
    count << "Nombre: " << nombre << end;
    count << "Genero: " << genero << end;
    count << "Edad: " << edad << end "
  }
};

int main() {
  Alumno alumno1;
  alumno1.registrar(1234, "Juan Jimeneza", "Masculino", 20);
  count << "Datos del alumno" << end1;
  alumno1.mostrar();
}
