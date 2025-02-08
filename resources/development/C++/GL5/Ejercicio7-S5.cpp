/*
Ejercicio 7: Registro de Notas de Estudiantes y Promedio

Crea un programa donde se cree un registro para almacenar el nombre, nota de matemáticas, nota de ciencias, 
nota de historia y nota de literatura de n estudiantes. El programa debe calcular el promedio de las notas 
de cada estudiante. Luego, debe mostrar los registros ingresados y si el estudiante aprobó (promedio >= 10) 
o reprobó (promedio < 11).
*/

#include <iostream>
using namespace std;

struct Estudiante {
    string nombre;
    float matematicas;
    float ciencias;
    float historia;
    float literatura;
    float promedio;
};

int main() {
    int n;
    cout << "Ingrese la cantidad de estudiantes: ";
    cin >> n;

    Estudiante est[n];

    for (int i = 0; i < n; i++) {
        cout << "\nEstudiante " << i + 1 << endl;
        cout << "Nombre: ";
        cin >> est[i].nombre;
        cout << "Nota de Matematicas: ";
        cin >> est[i].matematicas;
        cout << "Nota de Ciencias: ";
        cin >> est[i].ciencias;
        cout << "Nota de Historia: ";
        cin >> est[i].historia;
        cout << "Nota de Literatura: ";
        cin >> est[i].literatura;

        est[i].promedio = (est[i].matematicas + est[i].ciencias + est[i].historia + est[i].literatura) / 4;
    }

    cout << "\n--- Resultados ---\n";
    for (int i = 0; i < n; i++) {
        cout << "Estudiante: " << est[i].nombre
             << " | Promedio: " << est[i].promedio
             << " | " << (est[i].promedio >= 10 ? "Aprobado" : "Reprobado")
             << endl;
    }

    return 0;
}
