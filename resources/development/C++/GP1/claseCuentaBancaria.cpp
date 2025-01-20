#include <iostream>
#include <string>
using namespace std;

class CuentaBancaria {
private:
  string titular;
  string numeroCuenta;
  double saldo;

public:
  CuentaBancaria() { saldo = 0; }

  void RegistrarCuenta() {
    cout << "Ingrese nombre del titular: ";
    getline(cin, titular);
    cout << "Ingrese numero de cuenta: ";
    getline(cin, numeroCuenta);
    saldo = 0;
  }

  void DepositarDinero(double cantidad) {
    saldo += cantidad;
    cout << "Depósito realizado. Nuevo saldo: " << saldo << endl;
  }

  void RetirarDinero(double cantidad) {
    if (cantidad <= saldo) {
      saldo -= cantidad;
      cout << "Retiro realizado. Nuevo saldo: " << saldo << endl;
    } else {
      cout << "Saldo insuficiente.\n";
    }
  }

  void ConsultarSaldo() { cout << "Saldo actual: " << saldo << endl; }

  void MostrarInformacion() {
    cout << "\n--- Información de la Cuenta ---\n";
    cout << "Titular: " << titular << endl;
    cout << "Numero de cuenta: " << numeroCuenta << endl;
    cout << "Saldo: " << saldo << endl;
  }
};

int main() {
  CuentaBancaria cuenta;
  int opcion;
  do {
    cout << "\n--- Menú ---\n";
    cout << "1. Registrar cuenta\n";
    cout << "2. Depositar dinero\n";
    cout << "3. Retirar dinero\n";
    cout << "4. Consultar saldo\n";
    cout << "5. Mostrar informacion\n";
    cout << "6. Salir\n";
    cout << "Opcion: ";
    cin >> opcion;
    cin.ignore();

    double monto;
    switch (opcion) {
    case 1:
      cuenta.RegistrarCuenta();
      break;
    case 2:
      cout << "Ingrese monto a depositar: ";
      cin >> monto;
      cuenta.DepositarDinero(monto);
      break;
    case 3:
      cout << "Ingrese monto a retirar: ";
      cin >> monto;
      cuenta.RetirarDinero(monto);
      break;
    case 4:
      cuenta.ConsultarSaldo();
      break;
    case 5:
      cuenta.MostrarInformacion();
      break;
    }
  } while (opcion != 6);

  return 0;
}
