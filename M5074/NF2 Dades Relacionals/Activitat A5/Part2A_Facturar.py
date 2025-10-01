"""
M5074 - BigData i IA
Activitat: Optimització de Bases de Dades
Part 2A: Generació de dades fake amb Python
"""

import pyodbc
import random
from datetime import datetime, timedelta
from faker import Faker
import time

# Configuració
fake = Faker(['es_ES', 'es_ES'])
Faker.seed(42)
random.seed(42)

connection_string = (
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=sqlserver.codeworks.local;'
    'DATABASE=VendesBigData;'
    'uid=alumne;'
    'PWD=Password123!'
)

""" opció seguretat millorada
from dotenv import load_dotenv
import os

load_dotenv()

connection_string = (
    'DRIVER={ODBC Driver 17 for SQL Server};'
    f'SERVER={os.getenv("SQL_SERVER")};'
    f'DATABASE={os.getenv("SQL_DATABASE")};'
    f'UID={os.getenv("SQL_USER")};'
    f'PWD={os.getenv("SQL_PASSWORD")};'
)
"""

# Paràmetres de generació
NUM_JERARQUIES_PRODUCTES = 50
NUM_JERARQUIES_CLIENTS = 20
NUM_CLIENTS = 100000  # 100K clients
NUM_PRODUCTES = 10000  # 10K productes
NUM_COMANDES = 1000000  # 1M comandes
BATCH_SIZE = 10000  # Inserir en lots per optimitzar

print("=" * 60)
print("FACTURACIO MASSIVA - VENDESBigData")
print("=" * 60)

def executar_batch(cursor, query, data_list, batch_size=BATCH_SIZE):
    """Executa insercions en lots per millorar el rendiment"""
    total = len(data_list)
    for i in range(0, total, batch_size):
        batch = data_list[i:i+batch_size]
        cursor.fast_executemany = True
        cursor.executemany(query, batch)
        cursor.commit()
        print(f"  Processats {min(i+batch_size, total)}/{total} registres")

def generar_factures(cursor):
    """Genera factures i línies de factura per les comandes entregades"""
    print("\n6. Generant factures i línies de factura...")
    start_time = time.time()
    
    # Obtenir comandes entregades
    cursor.execute("SELECT ComandaID, ClientID, DataEntrega, DataComanda, ImportNet FROM Comandes WHERE Estat = 'Entregat'")
    comandes_entregades = cursor.fetchall()
    
    if not comandes_entregades:
        print("  ⚠ No hi ha comandes entregades per facturar")
        return
    
    print(f"  Generant factures per {len(comandes_entregades):,} comandes entregades...")
    
    formes_pagament = ['Transferència', 'Targeta', 'Efectiu', 'PayPal']
    factures_data = []
    
    for idx, (comanda_id, client_id, data_entrega, data_comanda, import_net) in enumerate(comandes_entregades, 1):
        num_factura = f"FAC-{idx:010d}"
        data_factura = (data_entrega or data_comanda) + timedelta(days=1)
        data_venciment = data_factura + timedelta(days=31)
        base_imposable = import_net
        iva = base_imposable * 0.21
        import_total = base_imposable + iva
        
        # Determinar estat (80% pagades, 15% pendents, 5% vençudes)
        dies_desde_factura = (datetime.now() - data_factura).days
        if dies_desde_factura > 30 and random.random() < 0.05:
            estat = 'Vençut'
            data_pagament = None
        elif random.random() < 0.8:
            estat = 'Pagat'
            data_pagament = data_factura + timedelta(days=random.randint(0, 25))
        else:
            estat = 'Pendent'
            data_pagament = None
        
        forma_pagament = random.choice(formes_pagament)
        
        factures_data.append((num_factura, comanda_id, client_id, data_factura, data_venciment,
                             base_imposable, iva, import_total, estat, data_pagament, forma_pagament))
    
    query = """
        INSERT INTO Factures (NumeroFactura, ComandaID, ClientID, DataFactura, DataVenciment,
                             BaseImposable, IVA, ImportTotal, Estat, DataPagament, FormaPagament)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """
    executar_batch(cursor, query, factures_data)
    
    print("  Generant línies de factura...")
    
    # Generar línies de factura basades en línies de comanda
    cursor.execute("""
        SELECT f.FacturaID, lc.NumeroLinia, lc.ProducteID, p.NomProducte, 
               lc.Quantitat, lc.PreuUnitari, lc.Descompte, lc.ImportLinia
        FROM Factures f
        INNER JOIN LiniesComanda lc ON f.ComandaID = lc.ComandaID
        INNER JOIN Productes p ON lc.ProducteID = p.ProducteID
    """)
    
    linies_factura_data = []
    for (factura_id, num_linia, producte_id, nom_producte, quantitat, 
         preu_unitari, descompte, import_linia) in cursor.fetchall():
        
        descompte_import = import_linia * (descompte / 100) if descompte > 0 else 0
        base_imposable = import_linia
        percentatge_iva = 21.00
        import_iva = base_imposable * 0.21
        import_total = base_imposable + import_iva
        
        linies_factura_data.append((factura_id, num_linia, producte_id, nom_producte, 
                                    quantitat, preu_unitari, descompte_import, 
                                    base_imposable, percentatge_iva, import_iva, import_total))
    
    query = """
        INSERT INTO LiniesFactura (FacturaID, NumeroLinia, ProducteID, Descripcio, Quantitat,
                                  PreuUnitari, Descompte, BaseImposable, PercentatgeIVA,
                                  ImportIVA, ImportTotal)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """
    executar_batch(cursor, query, linies_factura_data)
    
    elapsed = time.time() - start_time
    print(f"  ✓ Completat en {elapsed:.2f} segons")
    print(f"    - {len(factures_data):,} factures creades")
    print(f"    - {len(linies_factura_data):,} línies de factura creades")

def main():
    try:
        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()
        
        print("\nConnexió establerta amb SQL Server")
        
       
        # Generar dades

        generar_factures(cursor)  # NOVA FUNCIÓ

        # Estadístiques finals
        print("\n" + "=" * 60)
        print("GENERACIÓ COMPLETADA!")
        print("=" * 60)

        cursor.execute("SELECT COUNT(*) FROM Factures")
        print(f"Factures: {cursor.fetchone()[0]:,}")
        
        cursor.execute("SELECT COUNT(*) FROM LiniesFactura")
        print(f"Línies factura: {cursor.fetchone()[0]:,}")
        
        print("=" * 60)
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        raise

if __name__ == "__main__":
    main()
