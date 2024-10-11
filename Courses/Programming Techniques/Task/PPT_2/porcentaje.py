print("\n==========INGRESO DE DATOS ==========")

CantHombres = int(input("Ingrese cantidad de hombres:\t\t"))

CantMujeres = int(input("Ingrese cantiidad de mujeres:\t\t"))

TotalAlumnos = CantHombres + CantMujeres


PorcentHombres = round((CantHombres * 100)/TotalAlumnos)

PorcentMujeres = round((CantMujeres * 100)/TotalAlumnos)


print("\n========== REPORTE ==========")
print("el Porcentaje de Hombres es:\t\t", PorcentHombres)
print("el Porcentaje de MUjeres es:\t\t", PorcentMujeres)
