/*
Ejercicio 10: Registro de Cursos Universitarios y Horas de Clase 

Crea un programa donde se cree un registro para almacenar el nombre del curso, código del curso, profesor 
y número de créditos de n cursos universitarios. El programa debe calcular las horas de clase por semana 
de cada curso, considerando que cada crédito equivale a 2 horas de clase por semana. Luego, debe mostrar 
los registros ingresados y las horas totales de clase para cada curso.
*/

#include <iostream>
using namespace std;

struct Curso {
    string nombre;
    string codigo;
    string profesor;
    int creditos;
    int horasPorSemana;
};

int main() {
    int n;
    cout << "Ingrese la cantidad de cursos: ";
    cin >> n;

    Curso cursos[n];

    for (int i = 0; i < n; i++) {
        cout << "\nCurso " << i + 1 << endl;
        cout << "Nombre: ";
        cin >> cursos[i].nombre;
        cout << "Codigo: ";
        cin >> cursos[i].codigo;
        cout << "Profesor: ";
        cin >> cursos[i].profesor;
        cout << "Creditos: ";
        cin >> cursos[i].creditos;

        // Cada crédito equivale a 2 horas de clase
        cursos[i].horasPorSemana = cursos[i].creditos * 2;
    }

    cout << "\n--- Cursos Registrados ---\n";
    for (int i = 0; i < n; i++) {
        cout << "Curso: " << cursos[i].nombre
             << " | Codigo: " << cursos[i].codigo
             << " | Profesor: " << cursos[i].profesor
             << " | Creditos: " << cursos[i].creditos
             << " | Horas por semana: " << cursos[i].horasPorSemana
             << endl;
    }

    return 0;
}
