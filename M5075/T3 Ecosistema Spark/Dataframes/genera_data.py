import random
import pandas as pd
import pyarrow as pa
import pyarrow.orc as orc
from faker import Faker

fake = Faker('es_ES')
num_users = 500
filename_csv = "datos.csv"
filename_txt = "datos.txt"
filename_json="datos.json"
filename_orc ="datos.orc"
filename_parquet ="datos.parquet"

# Generar archivo CSV con strings entre comillas
with open(filename_txt, "w",encoding="UTF8") as ft:
    with open(filename_csv, "w",encoding="UTF8") as fc:
        ft.write("nombre\tapellido\tciudad\tsueldo\n")  # Cabecera del TXT
        fc.write("nombre,apellido,ciudad,sueldo\n")  # Cabecera del CSV
        for i in range(1, num_users + 1):
                nombre = f"\"{fake.name()}\""
                apellido = f"\"{fake.last_name()}\""
                ciudad = f"\"{fake.city()}\""
                sueldo = random.randint(1000, 6000)
                ft.write(f"{nombre}\t{apellido}\t{ciudad}\t{sueldo}\n")
                fc.write(f"{nombre},{apellido},{ciudad},{sueldo}\n")

print(f"Arxiu generat: {filename_txt}")
print(f"Arxiu generat: {filename_csv}")


# Leer el archivo de texto
df = pd.read_csv(filename_txt, sep='\t', encoding='utf-8')

#Guardar com JSON
df.to_json(filename_json, orient='records', lines=True,force_ascii=False)
print(f"Arxiu generat: {filename_json}")

# Guardar como ORC
orc.write_table(pa.Table.from_pandas(df), filename_orc)
print(f"Arxiu generat: {filename_orc}")

# Guardar como Parquet
df.to_parquet(filename_parquet)
print(f"Arxiu generat: {filename_parquet}")
