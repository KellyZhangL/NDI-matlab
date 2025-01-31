function [b, successes, failures] = test_ndi_document_jsons(generate_error)
% TEST_NDI_DOCUMNET_JSONS - test validity of all NDI_DOCUMENT json definitions
%
% [B, SUCCESSES, FAILURES]  = ndi.test.document_jsons(GENERATE_ERROR)
%
% Tries to make a blank ndi.document from all ndi.document JSON definitions.
% Returns a cell array of all JSON file names that were successfully created in
% SUCCESSES, and a cell array of JSON file names there unsuccessfully created in
% FAILURES. B is 1 if all ndi documents were created successfully.
% 
% If GENERATE_ERROR is present and is 1, then an error is generated if B is 0.
% 

if nargin<1,
	generate_error = 0;
end;

b = 0;
successes = {};
failures = {};

ndi.globals;

json_docs = vlt.file.findfilegroups(ndi_globals.path.documentpath,{'.*\.json\>'});

for i=1:numel(json_docs),
	[parentdir,filename,ext] = fileparts(json_docs{i}{1});
	ndidoc = [filename ext];

	if filename(1)=='.',  % ignore swap files and hidden files
		continue;
	end;
	try,
		mydoc = ndi.document(ndidoc);
		successes{end+1} = ndidoc;
	catch,
		failures{end+1} = ndidoc;
	end;
end;

b = isempty(failures);

if generate_error & ~b,
	disp(['ndi.document definitions failed']);
	failures'
	error(['At least one ndi.document failed to be built from its definition.']);
end;


