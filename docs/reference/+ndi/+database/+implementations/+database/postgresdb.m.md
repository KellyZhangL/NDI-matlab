# CLASS ndi.database.implementations.database.postgresdb

```
ndi.database.implementations.database.postgresdb is a class.


```
## Superclasses
**[ndi.database](../../../database.m.md)**

## Properties

| Property | Description |
| --- | --- |
| *db* | Stores PostgreSQL database |
| *dbname* | Used to specify name of Postgres database |
| *path* |  |
| *session_unique_reference* |  |


## Methods 

| Method | Description |
| --- | --- |
| *add* | add an ndi.document to the database at a given path |
| *alldocids* | return all document unique reference numbers for the database |
| *clear* | remove/delete all records from an ndi.database |
| *closebinarydoc* | close and unlock an ndi.database.binarydoc |
| *ndi.database.postgresdb* |  |
| *ndiquery_to_sql* | Translates an ndiquery into a SQL command |
| *newdocument* | obtain a new/blank ndi.document object that can be used with a ndi.database |
| *openbinarydoc* | open and lock an ndi.database.binarydoc that corresponds to a document id |
| *postgresdb* | ndi.database.implementations.database.postgresdb/postgresdb is a constructor. |
| *read* | read an ndi.document from an ndi.database at a given db path |
| *remove* | remove a document from an ndi.database |
| *search* | search for an ndi.document from an ndi.database |


### Methods help 

**add** - *add an ndi.document to the database at a given path*

```
NDI_DATABASE_OBJ = ADD(NDI_DATABASE_OBJ, NDI_DOCUMENT_OBJ, DBPATH, ...)
 
  Adds the document NDI_DOCUMENT_OBJ to the database NDI_DATABASE_OBJ.
 
  This function also accepts name/value pairs that modify its behavior:
  Parameter (default)      | Description
  -------------------------------------------------------------------------
  'Update'  (1)            | If document exists, update it. If 0, an error is 
                           |   generated if a document with the same ID exists
  
  See also: vlt.data.namevaluepair

Help for ndi.database.implementations.database.postgresdb/add is inherited from superclass NDI.DATABASE
```

---

**alldocids** - *return all document unique reference numbers for the database*

```
DOCIDS = ALLDOCIDS(NDI_POSTGRESDB_OBJ, DBNAME)
 
  Return all document unique reference strings as a cell array of strings. If there
  are no documents, empty is returned.
 
  NOTE: Requires Database name as input and Assuming data is stored in public.documents
  docid_query = "SELECT id FROM " + ndi_postgresdb_obj.dbname + ".public.documents"
  data = select(ndi_postgresdb_obj.db,docid_query);
```

---

**clear** - *remove/delete all records from an ndi.database*

```
CLEAR(NDI_DATABASE_OBJ, [AREYOUSURE])
 
  Removes all documents from the vlt.file.dumbjsondb object.
  
  Use with care. If AREYOUSURE is 'yes' then the
  function will proceed. Otherwise, it will not.
 
  See also: ndi.database.implementations.database.postgresdb/REMOVE

Help for ndi.database.implementations.database.postgresdb/clear is inherited from superclass NDI.DATABASE
```

---

**closebinarydoc** - *close and unlock an ndi.database.binarydoc*

```
[NDI_BINARYDOC_OBJ] = CLOSEBINARYDOC(NDI_DATABASE_OBJ, NDI_BINARYDOC_OBJ)
 
  Close and lock an NDI_BINARYDOC_OBJ. The NDI_BINARYDOC_OBJ must be unlocked in the
  database, which is why it is necessary to call this function through the database.

Help for ndi.database.implementations.database.postgresdb/closebinarydoc is inherited from superclass NDI.DATABASE
```

---

**ndi.database.postgresdb** - **

```

```

---

**ndiquery_to_sql** - *Translates an ndiquery into a SQL command*

```
Assumes input is a ndiquery converted to struct
  Assumes params are correct
 
  q = ndi.query('ndi_document.id','exact_string','ABCD','')
  (This means: find all documents that have a field ndi_document.id that exactly matches the string 'ABCD')
  q = ndi.query('list','exact_string','abc','')
 
  Example SQL query:
  SELECT data ->> 'list' AS list                                                                  
  FROM dbname.public.documents                                                           
  WHERE data ->> 'list' LIKE ('%abc%')
```

---

**newdocument** - *obtain a new/blank ndi.document object that can be used with a ndi.database*

```
NDI_DOCUMENT_OBJ = NEWDOCUMENT(NDI_DATABASE_OBJ [, DOCUMENT_TYPE])
 
  Creates a new/blank ndi.document document object that can be used with this
  ndi.database.

Help for ndi.database.implementations.database.postgresdb/newdocument is inherited from superclass NDI.DATABASE
```

---

**openbinarydoc** - *open and lock an ndi.database.binarydoc that corresponds to a document id*

```
[NDI_BINARYDOC_OBJ, VERSION] = OPENBINARYDOC(NDI_DATABASE_OBJ, NDI_DOCUMENT_OR_ID, [VERSION])
 
  Return the open ndi.database.binarydoc object and VERSION that corresponds to an ndi.document and
  the requested version (the latest version is used if the argument is omitted).
  NDI_DOCUMENT_OR_ID can be either the document id of an ndi.document or an ndi.document object itsef.
 
  Note that this NDI_BINARYDOC_OBJ must be closed and unlocked with ndi.database/CLOSEBINARYDOC.
  The locked nature of the binary doc is a property of the database, not the document, which is why
  the database is needed.

Help for ndi.database.implementations.database.postgresdb/openbinarydoc is inherited from superclass NDI.DATABASE
```

---

**postgresdb** - *ndi.database.implementations.database.postgresdb/postgresdb is a constructor.*

```

```

---

**read** - *read an ndi.document from an ndi.database at a given db path*

```
NDI_DOCUMENT_OBJ = READ(NDI_DATABASE_OBJ, NDI_DOCUMENT_ID, [VERSION]) 
 
  Read the ndi.document object with the document ID specified by NDI_DOCUMENT_ID. If VERSION
  is provided (an integer) then only the version that is equal to VERSION is returned.
  Otherwise, the latest version is returned.
 
  If there is no ndi.document object with that ID, then empty is returned ([]).

Help for ndi.database.implementations.database.postgresdb/read is inherited from superclass NDI.DATABASE
```

---

**remove** - *remove a document from an ndi.database*

```
NDI_DATABASE_OBJ = REMOVE(NDI_DATABASE_OBJ, NDI_DOCUMENT_ID) 
      or
  NDI_DATABASE_OBJ = REMOVE(NDI_DATABASE_OBJ, NDI_DOCUMENT_ID, VERSIONS)
      or 
  NDI_DATABASE_OBJ = REMOVE(NDI_DATABASE_OBJ, NDI_DOCUMENT) 
 
  Removes the ndi.document object with the 'document unique reference' equal
  to NDI_DOCUMENT_OBJ_ID.  If VERSIONS is specified, then only the versions that match
  the entries in VERSIONS are removed.
 
  If an ndi.document is passed, then the NDI_DOCUMENT_ID is extracted using
  ndi.document/DOC_UNIQUE_ID. If a cell array of ndi.document is passed instead, then
  all of the documents are removed.

Help for ndi.database.implementations.database.postgresdb/remove is inherited from superclass NDI.DATABASE
```

---

**search** - *search for an ndi.document from an ndi.database*

```
[DOCUMENT_OBJS,VERSIONS] = SEARCH(NDI_DATABASE_OBJ, {'PARAM1', VALUE1, 'PARAM2', VALUE2, ... })
 
  Searches metadata parameters PARAM1, PARAM2, etc of NDS_DOCUMENT entries within an NDI_DATABASE_OBJ.
  If VALUEN is a string, then a regular expression is evaluated to determine the match. If VALUEN is not
  a string, then the items must match exactly.
  If PARAMN1 begins with a dash, then VALUEN indicates the value of one of these special parameters:
 
  This function returns a cell array of ndi.document objects. If no documents match the
  query, then an empty cell array ({}) is returned. An array VERSIONS contains the document version of
  of each ndi.document.

Help for ndi.database.implementations.database.postgresdb/search is inherited from superclass NDI.DATABASE
```

---

