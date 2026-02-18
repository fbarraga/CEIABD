# RAG-Chatbot amb Databricks
# Francesc Barragan
# Versió: 1.0
# Data 18.02.2026
# Basat en Jason Drew (Databricks)
Requeriments:

Workspace amb Unity Catalog, Model Serving i Vector Index

Clúster interactiu d'usuari únic amb versió 14.3 ML o superior (la part de Gradio no funciona amb Serverless ni amb clúster de Notebook Compartit). Es recomana utilitzar la versió LTS.

Codi per crear el teu propi RAG Chatbot a Databricks

Importa el fitxer RAG Chatbot.dbc, que inclou els quaderns següents:

1 Crear les taules necessàries
2A PDF incremental a docs_text
2B CSV a docs_text (mètode alternatiu per a l'extracció de text de llocs web)
3 RAG Chatbot
4 Interfície gràfica del Chatbot

Les instruccions sobre quin codi cal modificar per al teu ús propi es mostren al vídeo de demostració.
https://www.youtube.com/watch?v=p4qpIgj5Zjg


Website content crawler

https://apify.com/apify/website-content-crawler