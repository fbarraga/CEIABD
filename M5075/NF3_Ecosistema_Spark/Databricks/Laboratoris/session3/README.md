* Creem un nou volum al workspace->default anomenat xxxx
* Pugem el fitxer customers.csv
* Ens copiem el path del sistema i anem a fer sql sobre el fitxer sense necessitat de crear-ho com a taula
* select * from csv.`/Volumes/workspace/default/xxxxx/customerscsv.csv`
* Ara anem a carregar com a taula el fitxewr ordersjson
*Ara anem a ingenieria de datos->ingesta i anem a connectar un google drive on tindrem fitxers que després ens apareixeran com taules
* veurem que afegeix os columnes per mantenir la consistencia de la sincronització
* Si creem un notebook posant %md %sql %r li diem si el que ve després es un markdown un tros de codi sql o r o ...
* Per exemple per fer un select de la taula amd spark
* df= spark.table('workspace.rag.docs_text')
display(df)
