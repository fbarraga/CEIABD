En aquesta sessió el que farem serà utilitzar una eina de databricks (ai parse) per treure informació de fitxers 

* Catalog->nou cataleg idp
* CREATE CATALOG IF NOT EXISTS idp
COMMENT 'idp';
* creamos un nuevo volumen y subimos el fichero sample_medical_claim.pdf
* nuevo notebook idp_series

%sql
create or replace temp view raw_unstructured_doc as 
select 
path,content 
from read_files('/Volumes/idp/default/lesson')

%sql
select path,length(content)
from raw_unstructured_doc

%sql
create or replace temp view parsed_structured_doc as
select
path,
ai_parse_document(content) as parsed_content
from raw_unstructured_doc

%sql
select path,parsed_content
from parsed_structured_doc

%sql
create or replace temp view structured_tables as
select path,
       e.value:content as table_html
from parsed_structured_doc,
     lateral variant_explode(parsed_content:document:elements) as e
where try_cast(e.value:type as string) = 'table'

%sql
select * from structured_tables