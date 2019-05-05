classdef ndi_binarydoc < handle
	% NDI_BINARYDOC - a binary file class that handles reading/writing
	properties (SetAccess=protected, GetAccess=public)
	end  % protected, accessible

	methods (Abstract) 
		%ndi_binarydoc_obj = ndi_binarydoc(varargin)
			% NDI_BINARYDOC - create a new NDI_BINARYDOC object
			%
			% NDI_BINARYDOC_OBJ = NDI_BINARYDOC()
			%
			% This is an abstract class, so the creator does nothing.
			%

		%end; % ndi_binarydoc()

		ndi_binarydoc_obj = fopen(ndi_binarydoc_obj)
			% FOPEN - open the NDI_BINARYDOC for reading/writing
			%
			% FOPEN(NDI_BINARYDOC_OBJ)
			%
			% Open the file record associated with NDI_BINARYDOC_OBJ.
			%

		%end; % fopen()
			
		fseek(ndi_binarydoc_obj, location, reference)
			% FSEEK - move to a location within the file stream 
			%
			% FSEEK(NDI_BINARYDOC_OBJ, LOCATION, REFERENCE)
			%
			% Moves to a LOCATION (in bytes) in a file stream.
			%
			% LOCATION is relative to a REFERENCE:
			%    'bof'  - beginning of file
			%    'cof'  - current position in file
			%    'eof'  - end of file 
			%
			% See also: FSEEK, FTELL, NDI_BINARYDOC/FTELL
		%end % fseek()

		location = ftell(ndi_binarydoc_obj)
			% FSEEK - move to a location within the file stream 
			%
			% FSEEK(NDI_BINARYDOC_OBJ)
			%
			% Returns the current LOCATION (in bytes) in a file stream.
			%
			% See also: FSEEK, FTELL, NDI_BINARYDOC/FSEEK
		%end % ftell()

		b = feof(ndi_binarydoc_obj)
			% FEOF - is an NDI_BINARYDOC at the end of file?
			%
			% B = FEOF(NDI_BINARYDOC_OBJ)
			%
			% Returns 1 if the end-of-file indicator is set on the 
			% file stream NDI_BINARYDOC_OBJ, and 0 otherwise.
			%
			% See also: FEOF, FSEEK, NDI_BINARYDOC/FSEEK
		%end % feof

		count = fwrite(ndi_binarydoc_obj, data, precision, skip)
			% FWRITE - write data to an NDI_BINARYDOC
			% FOPEN - open the NDI_BINARYDOC for reading/writing
			%
			% COUNT = FWRITE(FILENAME, PERMISSIONS)
			%
			% 
			% See also: FWRITE
		%end; % fwrite()

		[data, count] = fread(ndi_binarydoc_obj, count, precision, skip)
			% FREAD - read data from an NDI_BINARYDOC
			%
			% [DATA, COUNT] = FREAD(NDI_BINARYDOC_OBJ, COUNT, [PRECISION],[SKIP])
			%
			% Read COUNT data objects (precision PRECISION) from an NDI_BINARYDOC object.
			% The actual COUNT is returned, along with the DATA.
			%
			% See also: FREAD
		%end; % fread()

		ndi_binarydoc_obj = fclose(ndi_binarydoc_obj)
			%FCLOSE - close an NDI_BINARYDOC
			%
			% FCLOSE(NDI_BINARYDOC_OBJ)
			%
			% 

		%end; % fclose()

	end; % Abstract methods

	methods

		function delete(ndi_binarydoc_obj)
		% DELETE - close an NDI_BINARYDOC and delete its handle
		%
		% DELETE(NDI_BINARYDOC_OBJ)
		%
		% Closes an NDI_BINARYDOC (if necessary) and then deletes the handle.
		%
			fclose(ndi_binarydoc_obj);
			delete@handle(ndi_binarydoc_obj); % call superclass
		end; % delete()	

	end % methods

end
