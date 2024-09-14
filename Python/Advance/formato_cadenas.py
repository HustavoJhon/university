from datetime import datetime

print("="*10)
numero = 11.5497

print("Con dos decimales: {0:.2f}".format(numero))
print("Completo: {0:f}".format(numero))
print("Redondear: ", round(numero))
print("Numero a cadena ", str(numero))

fecha_hora = datetime.now()
print("Mostrar fecha actual:", fecha_hora)

hora = fecha_hora.year
print("Mostrar hora actual:", hora)

anio = fecha_hora.year
mes = fecha_hora.month
dia = fecha_hora.day

print(f"{anio}/{mes}/{dia}")
