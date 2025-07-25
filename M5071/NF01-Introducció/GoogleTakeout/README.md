# Anàlisi de les dades de Google Location

Hashtags: #FpInfor #Daw #Dam #Asix #DawMp02 #DamMp02 #AsixMp02 #AsixMp10 #CE IA&BD

## Descripció

En aquest repositori trobaràs els scripts de Python i Jupyter notebooks per analitzar [Google Location History](https://support.google.com/accounts/answer/4388034?hl=en) les dades recuperades de [Google Takeout](https://takeout.google.com/settings/takeout). 

Pots utilitzar l'script [prepare_data.py](prepare_data.py) per llegir la informació de Takeout que es troba enzippada i reescriure-la en format CSV. Després pots utilitzar els notebooks de juypter [analyze_activities](analyze_activities.ipynb) i [analyze_places](analyze_places.ipynb) per analitzar les dades interactivament.

## Requeriments

Aquest projecte utilitza [Pandas](https://pandas.pydata.org/), [Matplotlib](https://matplotlib.org/), i [bokeh](https://bokeh.org) llibreries que s'han provat amb versions de Python 3.11. **La versió mínima de Python requerida es la 3.10 degut a [un bug a la llibreria Zipfile](https://bugs.python.org/issue40564) que existia abans de la versió 3.10**

## Reconeixements

Basats en el github de Stefan4472 https://github.com/Stefan4472/google-location-history-analysis.git

## Setup

Clonar aquest repositori:

```shell
git clone https://github.com/fbarraga/google-location-history-analysis.git
```

Crear un entorn virtual de python:

```shell
cd google-location-history-analysis
python -m venv env
# Windows
call env\Scripts\activate
```

Instal·lar els paquets necessaris:

```shell
python -m pip install -r requirements.txt
```

Preparar les dades de Google Takeout:

```shell
python prepare_data.py <INSERT_PATH_TO_TAKEOUT_ZIP>
```

Executar Jupyter Notebook:

```shell
python -m jupyter notebook
```


Estructura del fitxer zip descarregat de Google Takeout:

```bash
E:.
|   takeout_parser.py
|
\---Takeout
    |   archive_browser.html
    |
    \---Location History
        |   Records.json
        |   Settings.json
        |   Tombstones.csv
        |
        \---Semantic Location History
            +---2023
            |       2023_DECEMBER.json
            |       2023_NOVEMBER.json
            |
            \---2024
                    2024_FEBRUARY.json
                    2024_JANUARY.json
```

Aneu a l'enllaç que es mostra a la línia d'ordres, per exemple, 'http://localhost:8888/?token=...' i proveu els quaderns 'analyze_activities.ipynb' i 'analyze_places.ipynb' amb les vostres pròpies dades!
