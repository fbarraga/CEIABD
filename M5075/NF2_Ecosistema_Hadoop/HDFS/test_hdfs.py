from M5075.NF2_Ecosistema_Hadoop.HDFS.test_hdfs import InsecureClient

# Datos de conexión
HDFS_HOSTNAME = 'localhost'
HDFSCLI_PORT = 9870
HDFSCLI_CONNECTION_STRING = f'http://{HDFS_HOSTNAME}:{HDFSCLI_PORT}'

# En nuestro caso, al no usar Kerberos, creamos una conexión no segura
hdfs_client = InsecureClient(HDFSCLI_CONNECTION_STRING)
#hdfs_client = InsecureClient(HDFSCLI_CONNECTION_STRING,user=”hadoop”)


# Leemos el fichero de 'El quijote' que tenemos en HDFS
fichero = '/user/iabd/datos/el_quijote.txt'
with hdfs_client.read(fichero) as reader:
    texto = reader.read()

print(texto)

# Creamos una cadena con formato CSV y la almacenamos en HDFS
datos="nombre,apellidos\nFrancesc Barragan\nJonathan Lopez"
hdfs_client.write("/user/iabd/datos/datos.csv", datos)
