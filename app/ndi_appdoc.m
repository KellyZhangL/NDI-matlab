classdef ndi_appdoc

	properties
		doc_types;         % types of the parameter documents; the app developer can choose (cell array)
		doc_document_types % NDI_document datatypes for each doc 
	end

	methods
		function ndi_appdoc_obj = ndi_appdoc(doc_types, doc_document_types)
			% NDI_APPDOC - create a new NDI_APPDOC document
			% 
			% NDI_APPDOC_OBJ = NDI_APPDOC(DOC_TYPES, DOC_DOCUMENT_TYPES)
			%
			% Creates and initializes a new NDI_APPDOC object.
			%
			% DOC_TYPES should be a cell array of strings describing the internal names
			% of the document types.
			% DOC_DOCUMENT_TYPES should be a cell array of strings describing the
			% NDI_document datatypes for each parameter document.
			%
			% Example:
			%   ndi_appdoc_obj = ndi_appdoc({'extraction_doc'},{'/apps/spikeextractor/spike_extraction_parameters'});
			%
		end; % ndi_appdoc() 

		function doc = add_appdoc(ndi_appdoc_obj, session, appdoc_type, appdoc_struct, docexistsaction, varargin)
			% ADD_APPDOC - Load data from an application document
			%
			% [...] = ADD_APPDOC(NDI_APPDOC_OBJ, SESSION, APPDOC_TYPE, ...
			%     APPDOC_STRUCT, DOCEXISTSACTION, [additional arguments])
			%
			% Creates a new NDI_DOCUMENT that is based on the type APPDOC_TYPE with creation data
			% specified by APPDOC_STRUCT.  [additional inputs] are used to find or specify the
			% NDI_document in the SESSION database. They are passed to the function FIND_APPDOC,
			% so see help FIND_APPDOC for the documentation for each app.
			%
			% The DOC is returned as a cell array of NDI_DOCUMENTs (should have 1 entry but could have more than
			% 1 if the document already exists).
			%
			% If APPDOC_STRUCT is empty, then default values are used. If it is a character array, then it is
			% assumed to be a filename of a tab-separated-value text file. If it is an NDI_DOCUMENT, then it
			% is assumed to be an NDI_DOCUMENT and it will be converted to the parameters using DOC2STRUCT.
			%
			% This function also takes a string DOCEXISTSACTION that describes what it should do
			% in the event that the document fitting the [additional inputs] already exists:
			% DOCEXISTACTION value      | Description
			% ----------------------------------------------------------------------------------
			% 'Error'                   | An error is generating indicating the document exists.
			% 'NoAction'                | The existing document is left alone. The existing NDI_DOCUMENT
			%                           |    is returned in DOC.
			% 'Replace'                 | Replace the document; note that this deletes all NDI_DOCUMENTS
			%                           |    that depend on the original.
			% 'ReplaceIfDifferent'      | Conditionally replace the document, but only if the 
			%                           |    the data structures that define the document are not equal.
			% 
			%

				% Step 1, load the appdoc_struct if it is not already a structure

				if isempty(appdoc_struct),
					appdoc_struct = ndi_appdoc_obj.defaultstruct_appdoc(appdoc_type);
				elseif isa(appdoc_struct,'ndi_document'),
					appdoc_struct = ndi_appdoc_obj.doc2struct(appdoc_type,appdoc_struct);
				elseif isa(appdoc_struct,'char'),
					try,
						appdoc_struct = loadStructArray(appdoc_strut);
					catch,
						error(['APPDOC_STRUCT was a character array, so it was assumed to be a file.' ...
								' But file reading failed with error ' lasterr '.']);
					end;
				elseif isstruct(appdoc_struct),
					% we are happy, nothing to do
				else,
					error(['Do not know how to process APPDOC_STRUCT as provided.']);
				end;

				% Step 2, see if a document by this description already exists

				doc = ndi_appdoc_obj.find_appdoc(session, appdoc_type, varargin{:});
				if ~isempty(doc),
					switch (lower(docexistsaction)),
						case 'error',
							error([int2str(numel(doc)) ' document(s) of application document type '...
								appdoc_type ' already exist.']);
						case 'NoAction',
							return; % we are done
						case {'Replace','ReplaceIfDifferent'},
							aredifferent = 1; % by default, we will replace unless told to check
							if strcmpi(docexistsaction,'ReplaceIfDifferent'),
								% see if they really are different
								if numel(doc)>1, % there are multiple versions, must be different
									aredifferent = 1;
								else,
									appdoc_struct_here = ndi_appdoc_obj.doc2struct(appdoc_type, doc{1});
									b = ndi_appdoc_obj.isequal_appdoc_struct(appdoc_type, appdoc_struct, ...
										appdoc_struct_here);
									aredifferent = ~b;
								end;
							end;
							if aredifferent,
								b = ndi_app_obj.clear_appdoc(session, appdoc_type, varargin{:});
								if ~b,
									error(['Could not delete existing ' appdoc_type ' document(s).']);
								end;
							else,
								return; % nothing to do, it's already there and the same as we wanted
							end;
					end; % switch(docexistsaction)
				end;

				% if we haven't returned, we need to make a document and add it

				doc = ndi_appdoc_obj.struct2doc(session,appdoc_type,appdoc_struct,varargin{:});

				session.database_add(doc);

				doc = {doc}; % make it a cell array

		end; % add_appdoc

		function doc = struct2doc(ndi_appdoc_obj, session, appdoc_type, appdoc_struct, varargin)
			% STRUCT2DOC - create an NDI_DOCUMENT from an input structure and input parameters
			%
			% DOC = STRUCT2DOC(NDI_APPDOC_OBJ, SESSION, APPDOC_TYPE, APPDOC_STRUCT, [additional parameters]
			%
			% Create an NDI_DOCUMENT from a data structure APPDOC_STRUCT. The NDI_DOCUMENT is created
			% according to the APPDOC_TYPE of the NDI_APPDOC_OBJ.
			%
			% In the base class, this always returns empty. It must be overridden in subclasses.
			%
				doc = [];
		end; % struct2doc()

		function appdoc_struct = doc2struct(ndi_appdoc_obj, appdoc_type, doc)
			% DOC2STRUCT - create an NDI_DOCUMENT from an input structure and input parameters
			%
			% DOC = STRUCT2DOC(NDI_APPDOC_OBJ, SESSION, APPDOC_TYPE, APPDOC_STRUCT, [additional parameters]
			%
			% Create an NDI_DOCUMENT from a data structure APPDOC_STRUCT. The NDI_DOCUMENT is created
			% according to the APPDOC_TYPE of the NDI_APPDOC_OBJ.
			%
			% In the base class, this uses the property info in the NDI_DOCUMENT to load the data structure.
			%
				listname = doc.document_properties.document_class.property_list_name;
				appdoc_struct = getfield(doc.document_properties,listname);
		end; % doc2struct()


		function appdoc_struct = defaultstruct_appdoc(ndi_appdoc_obj, session, appdoc_type)
			% DEFAULTSTRUCT_APPDOC - return a default appdoc structure for a given APPDOC type
			%
			% APPDOC_STRUCT = DEFAULTSTRUCT_APPDOC(NDI_APPDOC_OBJ, SESSION, APPDOC_TYPE)
			%
			% Return the default data structure for a given APPDOC_TYPE of an NDI_APPDOC object.
			%
			% In the base class, this always returns empty. It must be overridden in subclasses.
			%
				appdoc_struct = [];
		end; % defaultstruct_appdoc()

		function varargout = loaddata_appdoc(ndi_appdoc_obj, session, appdoc_type, varargin)
			% LOADDATA_APPDOC - Load data from an application document
			%
			% [...] = LOADDATA_APPDOC(NDI_APPDOC_OBJ, SESSION, APPDOC_TYPE, [additional arguments])
			%
			% Loads the data from app document of style DOC_NAME from the SESSION database.
			% [additional inputs] are used to find the NDI_document in the SESSION database.
			% They are passed to the function FIND_APPDOC, so see help FIND_APPDOC for the documentation
			% for each app.
			%
			% In the base class, this always returns empty. This function should be overridden by each
			% subclass.
			%
				varargout = {};
		end; % loaddata_appdoc()

		function b = clear_appdoc(ndi_appdoc_obj, session, appdoc_type, varargin)
			% CLEAR_APPDOC - remove an NDI_APPDOC document from a session database
			% 
			% B = CLEAR_APPDOC(NDI_APPDOC_OBJ, SESSION, APPDOC_TYPE, [additional inputs])
			%
			% Deletes the app document of style DOC_NAME from the SESSION database.
			% [additional inputs] are used to find the NDI_document in the SESSION database.
			% They are passed to the function FIND_APPDOC, so see help FIND_APPDOC for the documentation
			% for each app.
			%
				doc = ndi_appdoc_obj.find_appdoc(session,appdoc_type,varargin{:});
				if ~isempty(doc),
					session.database_rm(doc);
				end;

		end; % clear_appdoc

		function doc = find_appdoc(ndi_appdoc_obj, session, appdoc_type, varargin)
			% FIND_APPDOC - find an NDI_APPDOC document in the session database
			%
			% DOC = FIND_APPDOC(NDI_APPDOC_OBJ, SESSION, APPDOC_TYPE, [additional inputs])
			%
			% Using search criteria that is supported by [additional inputs], FIND_APPDOC
			% searches the SESSION database for the NDI_DOCUMENT object DOC that is
			% described by APPDOC_TYPE.
			%
			% In this superclass, empty is always returned. Subclasses should override
			% this function to search for each document type.
			%
				doc = [];
		end; % find_appdoc

		function [b,errormsg] = isvalid_appdoc_struct(ndi_appdoc_obj, appdoc_type, appdoc_struct)
			% ISVALID_APPDOC_STRUCT - is an input structure a valid descriptor for an APPDOC?
			%
			% [B,ERRORMSG] = ISVALID_APPDOC_STRUCT(NDI_APPDOC_OBJ, APPDOC_TYPE, APPDOC_STRUCT)
			%
			% Examines APPDOC_STRUCT and determines whether it is a valid input for creating an
			% NDI_DOCUMENT described by APPDOC_TYPE. B is 1 if it is valid and 0 otherwise.
			%
			% In the base class, B is always 0 with ERRORMSG 'Base class always returns invalid.'
			%
				b = 0;
				errormsg = 'Base class always returns invalid';
		end; % isvalid_appdoc_struct()

		function b = isequal_appdoc_struct(ndi_appdoc_obj, appdoc_type, appdoc_struct1, appdoc_struct2)
			% ISEQUAL_APPDOC_STRUCT - are two APPDOC data structures the same (equal)?
			% 
			% B = ISEQUAL_APPDOC_STRUCT(NDI_APPDOC_OBJ, APPDOC_TYPE, APPDOC_STRUCT1, APPDOC_STRUCT2)
			%
			% Returns 1 if the structures APPDOC_STRUCT1 and APPDOC_STRUCT2 are valid and equal. In the base class, this is
			% true if APPDOC_STRUCT1 and APPDOC_STRUCT2 have the same field names and same values and same sizes. That is,
			% B is EQLEN(APPDOC_STRUCT1, APPDOC_STRUCT2).
			%
				b = 0;
				b1 = ndi_appdoc_obj.isvalid_appdoc_struct(appdoc_type, appdoc_struct1);
				b2 = ndi_appdoc_obj.isvalid_appdoc_struct(appdoc_type, appdoc_struct2);
				if b1&b2,
					b = eqlen(appdoc_struct1,appdoc_struct2);
				end;
		end; % isequal_appdoc_struct
	end;


end % ndi_appdoc
