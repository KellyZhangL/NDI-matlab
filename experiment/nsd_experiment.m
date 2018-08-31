classdef nsd_experiment < handle
	% NSD_EXPERIMENT - NSD_EXPERIMENT object class

	properties (GetAccess=public, SetAccess = protected)
		reference         % A string reference for the experiment
		variable          % An array of NSD_VARIABLE_BRANCH objects associated with this experiment
		iodevice          % An array of NSD_IODEVICE objects associated with this experiment
		synctable         % An NSD_SYNCTABLE object related to this experiment
		cache             % An NSD_CACHE object for the experiment's use
	end
	properties (GetAccess=protected, SetAccess = protected)
	end
	methods
		function obj = nsd_experiment(reference)
			% nsd_experiment - Create a new NSD_EXPERIMENT object
			%
			%   E=NSD_EXPERIMENT(REFERENCE)
			%
			% Creates a new NSD_EXPERIMENT object E. The experiment has a unique
			% reference REFERENCE. This class is an abstract class and typically
			% an end user will open a specific subclass.
			%
			% NSD_EXPERIMENT objects can access 0 or more NSD_IODEVICE objects.
			%
			% See also: NSD_EXPERIMENT/IODEVICE_ADD, NSD_EXPERIMENT/IODEVICE_RM, 
			%   NSD_EXPERIMENT/GETPATH, NSD_EXPERIMENT/GETREFERENCE

				obj.reference = reference;
				obj.iodevice = nsd_dbleaf_branch('','device',{'nsd_iodevice'},1);
				obj.variable = nsd_variable_branch('','variable',0);
				obj.synctable = nsd_synctable(obj);
				obj.cache = nsd_cache();
		end

		%%%%%% DEVICE METHODS

		function nsd_experiment_obj = iodevice_add(nsd_experiment_obj, dev)
			%IODEVICE_ADD - Add a sampling device to a NSD_EXPERIMENT object
			%
			%   NSD_EXPERIMENT_OBJ = IODEVICE_ADD(NSD_EXPERIMENT_OBJ, DEV)
			%
			% Adds the device DEV to the NSD_EXPERIMENT NSD_EXPERIMENT_OBJ
			%
			% The devices can be accessed by referencing NSD_EXPERIMENT_OBJ.device
			%  
			% See also: IODEVICE_RM, NSD_EXPERIMENT

				if ~isa(dev,'nsd_iodevice'),
					error(['dev is not a nsd_iodevice']);
				end;
				nsd_experiment_obj.iodevice.add(dev);
			end 
		function nsd_experiment_obj = iodevice_rm(nsd_experiment_obj, dev)
			% IODEVICE_RM - Remove a sampling device from an NSD_EXPERIMENT object
			%
			%   NSD_EXPERIMENT_OBJ = IODEVICE_RM(NSD_EXPERIMENT_OBJ, DEV)
			%
			% Removes the device DEV from the device list.
			%
			% See also: IODEVICE_ADD, NSD_EXPERIMENT
			
				leaf = nsd_experiment_obj.iodevice.load('name',dev.name);
				if ~isempty(leaf),
					nsd_experiment_obj.iodevice.remove(leaf.objectfilename);
				else,
					error(['No iodevice named ' dev.name ' found.']);
				end
			end

		function dev = iodevice_load(nsd_experiment_obj, varargin)
			% LOAD - Load iodevice objects from an NSD_EXPERIMENT
			%
			% DEV = IOIODEVICE_LOAD(NSD_EXPERIMENT_OBJ, PARAM1, VALUE1, PARAM2, VALUE2, ...)
			%         or
			% DEV = IOIODEVICE_LOAD(NSD_EXPERIMENT_OBJ, INDEXES)
			%
			% Returns the device object(s) in the NSD_EXPERIMENT at index(es) INDEXES or
			% searches for an object whose metadata parameters PARAMS1, PARAMS2, and so on, match
			% VALUE1, VALUE2, and so on (see NSD_DBLEAF_BRANCH/SEARCH).
			%
			% If more than one object is requested, then DEV will be a cell list of matching objects.
			% Otherwise, the object will be a single element. If there are no matches, empty ([]) is returned.
			%
				dev = nsd_experiment_obj.iodevice.load(varargin{:});
				if numel(dev)==1,
					dev=dev.setexperiment(nsd_experiment_obj);
				else,
					for i=1:numel(dev),
						dev{i}=dev{i}.setexperiment(nsd_experiment_obj);
					end
				end
		end % ioiodevice_load()	

		% NSD_VARIABLE METHODS

		function nsd_experiment_obj = variable_add(nsd_experiment_obj, var)
			%VARIABLE_ADD - Add an NSD_VARIABLE to an NSD_EXPERIMENT object
			%
			%   NSD_EXPERIMENT_OBJ = VARIABLE_ADD(NSD_EXPERIMENT_OBJ, VAR)
			%
			% Adds the NSD_VARIABLE VAR to the NSD_EXPERIMENT NSD_EXPERIMENT_OBJ
			%
			% The variable can be accessed by referencing NSD_EXPERIMENT_OBJ.variable
			%  
			% See also: VARIABLE_RM, NSD_EXPERIMENT

				if ~isa(var,'nsd_variable')|~isa(var,'nsd_variable_branch'), error(['var is not an NSD_VARIABLE']); end;
				nsd_experiment_obj.variable.add(var);
		end

		function nsd_experiment_obj = variable_rm(nsd_experiment_obj, var)
			% VARIABLE_RM - Remove an NSD_VARIABLE from an NSD_EXPERIMENT object
			%
			%   NSD_EXPERIMENT_OBJ = VARIABLE_RM(NSD_EXPERIMENT_OBJ, VAR)
			%
			% 
			% Removes the variable VAR from the experiment variable list.
			%
			% See also: VARIABLE_ADD, NSD_EXPERIMENT
			
				leaf = nsd_experiment_obj.variable.load('name',var.name);
				if ~isempty(leaf),
					nsd_experiment_obj.variable.remove(leaf.objectfilename);
				else,
					error(['No variable named ' var.name ' found.']);
				end
		end

		%%%%%% PATH methods

		function p = getpath(nsd_experiment_obj)
			% GETPATH - Return the path of the experiment
			%
			%   P = GETPATH(NSD_EXPERIMENT_OBJ)
			%
			% Returns the path of an NSD_EXPERIMENT object.
			%
			% The path is some sort of reference to the storage location of 
			% the experiment. This might be a URL, or a file directory, depending upon
			% the subclass.
			%
			% In the NSD_EXPERIMENT class, this returns empty.
			%
			% See also: NSD_EXPERIMENT
			p = [];
		end

		%%%%%% REFERENCE methods

		function probes = getprobes(nsd_experiment_obj)
			% GETPROBES - Return all NSD_PROBES that are found in NSD_IODEVICE epoch contents entries
			%
			% PROBES = GETPROBES(NSD_EXPERIMENT_OBJ)
			%
			% Examines all NSD_IODEVICE entries in the NSD_EXPERIMENT_OBJ's device array
			% and returns all NSD_PROBE entries that can be constructed from each device's
			% NSD_EPOCHCONENTS entries.
			%
			% PROBES is a cell array of NSD_PROBE objects.
			%
				probestruct = [];
				devs = nsd_experiment_obj.iodevice_load('name','(.*)');
				if ~isempty(devs),
					probestruct = getprobes(celloritem(devs,1));
				end
				for d=2:numel(devs),
					probestruct = cat(1,probestruct,getprobes(devs{d}));
				end
				probestruct = equnique(probestruct);
				probes = nsd_probestruct2probe(probestruct, nsd_experiment_obj);
		end % getprobes

	end % methods
end % classdef
