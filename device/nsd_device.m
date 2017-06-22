classdef nsd_device < nsd_dbleaf
% NSD_DEVICE - Create a new NSD_DEVICE class handle object
%
%  D = NSD_DEVICE(NAME, THEFILETREE)
%
%  Creates a new NSD_DEVICE object with name and specific data tree object.
%  This is an abstract class that is overridden by specific devices.


	properties (GetAccess=public, SetAccess=protected)
		filetree   % The NSD_FILETREE associated with this device
	end

	methods
		function obj = nsd_device(name,thefiletree)
		% NSD_DEVICE - create a new NSD_DEVICE object
		%
		%  OBJ = NSD_DEVICE(NAME, THEFILETREE)
		%
		%  Creates an NSD_DEVICE with name NAME and NSD_FILETREE
		%  THEFILETREE. THEFILETREE is an interface object to the raw data files
		%  on disk that are read by the NSD_DEVICE.
		%
		%  NSD_DEVICE is an abstract class, and a specific implementation must be called.
		%

			loadfromfile = 0;

			if nargin==0, % undocumented 0 argument creator
				name = '';
				thefiletree = [];
			elseif nargin==2,
				if ischar(thefiletree), % it is a command
					loadfromfile = 1;
					filename = name;
					name='';
					if ~strcmp(lower(thefiletree), lower('OpenFile')),
						error(['Unknown command.']);
					else,
						thefiletree=[];
					end
				end;
			else,
				error(['Function requires 2 input arguments exactly.']);
			end

			obj = obj@nsd_dbleaf(name);
			if loadfromfile,
				obj = obj.readobjectfile(filename);
			else,
				obj.name = name;
				obj.filetree = thefiletree;
			end

		end % nsd_device

		function obj = readobjectfile(nsd_device_obj, fname)
			% READOBJECTFILE
			%
			% NSD_DEVICE_OBJ = READOBJECTFILE(NSD_DEVICE_OBJ, FNAME)
			%
			% Reads the NSD_DEVICE_OBJ from the file FNAME (full path).

				obj=readobjectfile@nsd_dbleaf(nsd_device_obj, fname);
				ft = nsd_filetree;
				[dirname] = fileparts(fname); % same parent directory
				subdirname = [dirname filesep obj.objectfilename '.filetree.device.nsd'];
				f = dir([subdirname filesep 'object_*']);
				if isempty(f),
					error(['Could not find filetree file!']);
				end
				obj.filetree=ft.readobjectfile([subdirname filesep f(1).name]);
		end % readobjectfile

		function obj = writeobjectfile(nsd_device_obj, dirname)
			% WRITEOBJECTFILE - write an nsd_device to a directory
			%
			% NSD_DEVICE_OBJ = WRITEOBJECTFILE(NSD_DEVICE_OBJ, dirname)
			%
			% Reads the NSD_DEVICE_OBJ from the file FNAME (full path).

				obj=writeobjectfile@nsd_dbleaf(nsd_device_obj, dirname);
				subdirname = [dirname filesep obj.objectfilename '.filetree.device.nsd'];
				if ~exist(subdirname,'dir'), mkdir(subdirname); end;
				obj.filetree.writeobjectfile(subdirname)
				
		end % writeobjectfile

		function b = deleteobjectfile(nsd_device_obj, thedirname)
			% DELETEOBJECTFILE - Delete / remove the object file (or files) for NSD_DEVICE
			%
			% B = DELETEOBJECTFILE(NSD_DEVICE_OBJ, THEDIRNAME)
			%
			% Delete all files associated with NSD_DEVICE_OBJ in directory THEDIRNAME (full path).
			%
			% If no directory is given, NSD_DEVICE_OBJ.PATH is used.
			%
			% B is 1 if the process succeeds, 0 otherwise.
			%

				b = 1;
				subdirname = [thedirname filesep nsd_device_obj.objectfilename '.filetree.device.nsd'];
				rmdir(subdirname,'s');
				b = b&deleteobjectfile@nsd_dbleaf(nsd_device_obj, thedirname);

		end % deletefileobject

		function epochfiles = getepochfiles(self, number)
		% GETEPOCH - retreive the data files associated with a recording epoch
		%
		%   EPOCHFILES = GETEPOCHFILES(NSD_DEVICE_OBJ, NUMBER)
		%
		% Returns the data file(s) associated the the data epoch NUMBER for the
		% NSD_DEVICE.
		%
		% In the abstract base class NSD_DEVICE, this returns empty always.
		% In specific device classes, this can return a full path filename, a cell
                % list of file names, or some other suitable list of links to the epoch data.
		%
		% See also: NSD_DEVICE
			epochfiles = '';
		end  %epochfiles

		function deleteepoch(self, number, removedata)
		% DELETEEPOCH - Delete an epoch and an epoch record from a device
		%
		%   DELETEEPOCH(NSD_DEVICE_OBJ, NUMBER ... [REMOVEDATA])
		%
		% Deletes the data and NSD_EPOCHCONTENTS and epoch data for epoch NUMBER.
		% If REMOVEDATA is present and is 1, the data and record are physically deleted.
		% If REMOVEDATA is omitted or is 0, the data and record are renamed but not deleted from disk.
		%
		% In the abstract class, this command takes no action.
		%
		% See also: NSD_DEVICE, NSD_EPOCHCONTENTS
		end % deleteepoch

		function setepochcontents(self, epochcontents, number, overwrite)
			% SETEPOCHCONTENTS - Sets the epoch record of a particular epoch
			%
			%   SETEPOCHCONTENTS(NSD_DEVICE_OBJ, EPOCHCONTENTS, NUMBER, [OVERWRITE])
			%
			% Sets or replaces the NSD_EPOCHCONTENTS object for NSD_DEVICE_OBJ with EPOCHCONTENTS for the epoch
			% numbered NUMBER.  If OVERWRITE is present and is 1, then any existing epoch record is overwritten.
			% Otherwise, an error is given if there is an existing epoch record.
			%
			% See also: NSD_DEVICE, NSD_EPOCHCONTENTS
				
				if nargin<4,
					overwrite = 0;
				end

				self.filetree.setepochcontents(epochcontents, number, overwrite);
		end % setepochcontents()

                function epochcontents = getepochcontents(self, number)
			% GETEPOCHCONTENTS - retreive the epoch record associated with a recording epoch
			%
			%   EPOCHCONTENTS = GETEPOCHCONTENTS(NSD_DEVICE_OBJ, NUMBER)
			%
			% Returns the EPOCHCONTENTS associated the the data epoch NUMBER for the
			% NSD_DEVICE.
			%
			% See also: NSD_DEVICE, NSD_EPOCHCONTENTS
			%
				   % Developer note: Why is this function present in nsd_device, when it pretty much 
				   % just calls the nsd_filetree version? Because, some devices may include some sort of epoch
				   % record in their own files natively, and the nsd_device_DRIVER that reads it may simply read from that
				   % information. So nsd_device_DRIVER needs the ability to override this function.

				epochcontents = self.filetree.getepochcontents(number, self.name);
				if ~(verifyepochcontents(self,epochcontents))
					error(['the numbered epoch is not a valid epoch for the given device']);
				end
                end %getepochcontents()

		function b = verifyepochcontents(self, epochcontents, number)
			% VERIFYEPOCHCONTENTS - Verifies that an EPOCHCONTENTS is compatible with a given device and the data on disk
			%
			%   B = VERIFYEPOCHCONTENTS(NSD_DEVICE_OBJ, EPOCHCONTENTS, NUMBER)
			%
			% Examines the NSD_EPOCHCONTENTS EPOCHCONTENTS and determines if it is valid for the given device
			% epoch NUMBER.
			%
			% For the abstract class NSD_DEVICE, EPOCHCONTENTS is always valid as long as
			% EPOCHCONTENTS is an NSD_EPOCHCONTENTS object.
			%
			% See also: NSD_DEVICE, NSD_EPOCHCONTENTS
				b = isa(epochcontents, 'nsd_epochcontents');
		end % verifyepochcontents

		function probes_struct=getprobes(self)
			% GETPROBES = Return all of the probes associated with an NSD_DEVICE object
			%
			% PROBES_STRUCT = GETPROBES(NSD_DEVICE_OBJ)
			%
			% Returns all probes associated with the NSD_DEVICE object NSD_DEVICE_OBJ
			%
			% This function returns a structure with fields of all unique probes across
			% all EPOCHCONTENTS objects returned in NSD_DEVICE/GETEPOCHCONTENTS.
			% The fields are 'name', 'reference', and 'type'.
				probes_struct = emptystruct('name','reference','type');
				N = self.filetree.numepochs();
				for n=1:N,
					epc = self.getepochcontents(n);
					newentry.name = epc.name;
					newentry.reference= epc.reference;
					newentry.type= epc.type;
					probes_struct(end+1) = newentry;
				end
				probes_struct = structunique(probes_struct);

		end % getprobes()
			
	end % methods
end
