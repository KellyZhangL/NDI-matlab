# ndi_document_syncgraph (ndi.document class)

## Class definition

**Class name**: [ndi_document_syncgraph](ndi_document_syncgraph.md)<br>
**Short name**: [ndi_document_syncgraph](ndi_document_syncgraph.md)<br>
**Superclasses**: [ndi_document](../ndi_document.md)

**Definition**: [$NDIDOCUMENTPATH/daq/ndi_document_syncgraph.json](https://github.com/VH-Lab/NDI-matlab/tree/master/ndi_common/database_documents/daq/ndi_document_syncgraph.json)<br>
**Schema for validation**: [$NDISCHEMAPATH/daq/ndi_document_syncgraph_schema.json](https://github.com/VH-Lab/NDI-matlab/tree/master/ndi_common/schema_documents/daq/ndi_document_syncgraph_schema.json)<br>
**Property_list_name**: `syncgraph`<br>
**Class_version**: `1`<br>


## [ndi_document_syncgraph](ndi_document_syncgraph.md) fields

Accessed by `syncgraph.field` where *field* is one of the field names below

| field | default_value | data type | description |
| --- | --- | --- | --- |
| **depends_on** | - | structure | Each document that this document depends on is listed; its document ID is given by the value, and the name indicates the type of dependency that exists. Note that the index for each dependency in the list below is arbitrary and can change. Use `ndi.document` methods `dependency`, `dependency_value`,`add_dependency_value_n`,`dependency_value_n`,`remove_dependency_value_n`, and `set_dependency_value` to read and edit `depends_on` fields of an `ndi.document`. |
| **depends_on**: *variable dependencies* |  |  |  |
| **ndi_syncgraph_class** |  |  |  |


## [ndi_document](../ndi_document.md) fields

Accessed by `ndi_document.field` where *field* is one of the field names below

| field | default_value | data type | description |
| --- | --- | --- | --- |
| **session_id** | - | NDI ID string | The globally unique identifier of any data session that produced this document |
| **id** | - | NDI ID string | The globally unique identifier of this document |
| **name** |  | character array (ASCII) | A user-specified name, free for users/developers to use as they like |
| **type** |  | character array (ASCII) | A user-specified type, free for users/developers to use as they like (deprecated, will be removed) |
| **datestamp** | (current time) | ISO-8601 date string, time zone must be UTC leap seconds | Time of document creation |
| **database_version** | - | character array (ASCII) | Version of this document in the database |


