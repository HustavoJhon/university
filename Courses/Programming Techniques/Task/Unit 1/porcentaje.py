print("\n ------- INGRESO DE DATOS --------")

cant_hombre = int(input("Ingrese cantidad de hombres:\t\t"))

cant_mujer = int(input("Infrese cantidad de mujeres:\t\t"))

total_alumno = cant_hombre + cant_mujer

porcentaje_hombre = round((cant_hombre * 100)/total_alumno)

porcentaje_mujer = round((cant_mujer * 100)/total_alumno)

print("\n ------- REPORTE --------")

print("el Porcentaje de hombres es:\t\t", porcentaje_hombre, "%")
print("el Porcentaje de mujer es:\t\t", porcentaje_mujer, "%")
