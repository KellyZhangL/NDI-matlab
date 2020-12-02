function [md,info] = document2markdown(ndi_document_obj, varargin)
% DOCUMENT2MARKDOWN - convert an NDI document to markdown text
%
%    MD = ndi.database.fun.document2markdown(ndi_document_obj)
%
%  Given an ndi.document NDI_DOCUMENT_OBJ, this function creates a 
%  documentation-style markdown file.
%
% 

superclasses_already = {};
examine_superclasses = 1;
max_depth = 25;
current_depth = 1;
urldocpath = '';
giturl_path = 'https://github.com/VH-Lab/NDI-matlab/tree/master/ndi_common/database_documents/';
gitvalurl_path = 'https://github.com/VH-Lab/NDI-matlab/tree/master/ndi_common/schema_documents/';


vlt.data.assign(varargin{:});

if current_depth > max_depth,
	error(['Maximum depth of ' int2str(max_depth) ' exceeded. Check for loops in schema definitions.']);
end;

info.class_name = ndi_document_obj.document_properties.document_class.class_name;
info.url = strrep(ndi_document_obj.document_properties.document_class.definition,'$NDIDOCUMENTPATH/', urldocpath);
info.url = fileparts(info.url);
if ~isempty(info.url),
	info.url(end+1) = '/';
end;
info.url = [info.url info.class_name '.md'];
info.my_path_to_root = repmat('../',1,numel(find(info.url=='/')));
info.localurl = [info.class_name '.md'];


md = '';

md = cat(2,md,['# ' info.class_name ' (ndi.document class)' newline newline]);


md = cat(2,md,['## Class definition' newline newline]);

md = cat(2,md,['**Class name**: [' info.class_name '](' info.localurl  ')' newline newline ]);

	 % Superclasses

superclass_info = {};

if examine_superclasses,
	md = cat(2,md,['**Superclasses**: ']);

	if numel(ndi_document_obj.document_properties.document_class.superclasses)==0,
		md = cat(2,md,'*none*');
	else,
		for i=1:numel(ndi_document_obj.document_properties.document_class.superclasses),
			d=ndi.document(ndi_document_obj.document_properties.document_class.superclasses(i).definition);
			[blank,info_here] = ndi.database.fun.document2markdown(d,'examine_superclasses',0,'current_depth',current_depth+1);
			md=cat(2,md,['[' info_here.class_name '](' [info.my_path_to_root info_here.url] ')']);
			superclass_info{end+1} = info_here;
			if i~=numel(ndi_document_obj.document_properties.document_class.superclasses),
				md = cat(2,md,', ');
			end;
		end;
	end;

	md = cat(2,md,[newline newline]);
end;
info.superclass_info = superclass_info;


info.definition = ndi_document_obj.document_properties.document_class.definition;
info.definition_url = strrep(info.definition, '$NDIDOCUMENTPATH/', giturl_path);
md = cat(2,md,['**Definition**: [' info.definition '](' info.definition_url ')<br>' newline]);
info.validation = ndi_document_obj.document_properties.document_class.validation;
info.validation_url = strrep(info.validation, '$NDISCHEMAPATH/', gitvalurl_path);
ndi.globals
info.validation_path = strrep(info.validation, '$NDISCHEMAPATH', ndi_globals.path.documentschemapath);
info.validation_json = jsondecode(vlt.file.textfile2char(info.validation_path));
md = cat(2,md,['**Schema for validation**: [' info.validation '](' info.validation_url ')<br>' newline]);
info.property_list_name = ndi_document_obj.document_properties.document_class.property_list_name;
md = cat(2,md,['**Property_list_name**: `' info.property_list_name '`<br>' newline]);
info.class_version = ndi_document_obj.document_properties.document_class.class_version;
md = cat(2,md,['**Class_version**: `' num2str(info.class_version) '`<br>' newline]);

md = cat(2,md,[newline newline]);

 % core fields here

prop_list = getfield(ndi_document_obj.document_properties, info.property_list_name);

fn = fieldnames(prop_list);


info.prop_list = vlt.data.emptystruct('field','default_value','data_type','description');

if numel(fn)>0, % we have field names
	md = cat(2,md,['## [' info.class_name '](' info.localurl ') fields' newline newline]);
	md = cat(2,md,['Accessed by `' info.property_list_name '.field` where *field* is one of the field names below' newline newline]);
	md = cat(2,md,['| field | default_value | data type | description |' newline]);
	md = cat(2,md,['| --- | --- | --- | --- |' newline]);
	for i=1:numel(fn),
		% need to expand any structures
		phere.field = fn{i};
		phere.default_value = '';
		phere.data_type = '';
		phere.description = '';
		if isfield(info.validation_json.properties,fn{i}),
			v=getfield(info.validation_json.properties,fn{i}),
			if isfield(v,'doc_description'),
				phere.description = getfield(v,'doc_description');
			end;
			if isfield(v,'doc_data_type'),
				phere.data_type = getfield(v,'doc_data_type');
			end;
			if isfield(v,'doc_default_value'),
				phere.default_value = getfield(v,'doc_default_value');
			end;
		end;
		info.prop_list(end+1) = phere;
		md = cat(2,md,['| ' phere.field  ' | ' phere.default_value  ' | ' phere.data_type  ' | ' phere.description  ' |' newline]);
	end;
	md = cat(2,md,[newline newline]);
end;


 % superclass fields

if numel(superclass_info)>0,
	for i=1:numel(info.superclass_info),
		if numel(info.superclass_info{i}.prop_list)>0,
			md = cat(2,md,['## [' info.superclass_info{i}.class_name '](' [info.my_path_to_root info.superclass_info{i}.url] ...
				 ') fields' newline newline]);
			md = cat(2,md,['Accessed by `' info.superclass_info{i}.property_list_name '.field` where *field* is one of the field names below' newline newline]);
			md = cat(2,md,['| field | default_value | data type | description |' newline]);
			md = cat(2,md,['| --- | --- | --- | --- |' newline]);
			for j=1:numel(info.superclass_info{i}.prop_list),
				phere = info.superclass_info{i}.prop_list(j);
				md=cat(2,md,['| ' phere.field  ' | ' phere.default_value  ' | ' phere.data_type  ' | ' phere.description  ' |' newline]);
			end;
			md = cat(2,md,[newline newline]);
		end;
	end;
end;

