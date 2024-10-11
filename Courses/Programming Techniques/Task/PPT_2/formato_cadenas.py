from datetime import datetime   # para fecha

print("="*50)
Numero = 11.5497

print("Con dos decimales: {0:.2f}".format(Numero))
print("Completo: {0:f}".format(Numero))
print("Redondear: ", round(Numero))
print("Numero a cadena: ", str(Numero))

fechaAhora = datetime.now()
print("Mostrar fecha actual:", fechaAhora)

hora = fechaAhora.time()
print("Mostrar fecha actual:", hora)

Anio = fechaAhora.year
Mes = fechaAhora.month
Dia = fechaAhora.day
print("Mostrar Año:", Anio)
print("Mostrar Mes:", Mes)
print("Mostrar Dia:", Dia)
