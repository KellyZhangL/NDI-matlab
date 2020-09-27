classdef ndi_app_markgarbage < ndi_app

	properties (SetAccess=protected,GetAccess=public)

	end % properties

	methods

		function ndi_app_markgarbage_obj = ndi_app_markgarbage(varargin)
			% NDI_APP_MARKGARBAGE - an app to help exclude garbage data from sessions
			%
			% NDI_APP_MARKGARBAGE_OBJ = NDI_APP_MARKGARBAGE(SESSION)
			%
			% Creates a new NDI_APP_MARKGARBAGE object that can operate on
			% NDI_SESSIONS. The app is named 'ndi_app_markgarbage'.
			%
				session = [];
				name = 'ndi_app_markgarbage';
				if numel(varargin)>0,
					session = varargin{1};
				end
				ndi_app_markgarbage_obj = ndi_app_markgarbage_obj@ndi_app(session, name);

		end % ndi_app_markgarbage() creator

		% developer note: it would be great to have a 'markinvalidinterval' companion
		function b = markvalidinterval(ndi_app_markgarbage_obj, ndi_epochset_obj, t0, timeref_t0, t1, timeref_t1)
			% MARKVALIDINTERVAL - mark a valid intervalin an epoch (all else is garbage)
			%
			% B = MARKVALIDINTERVAL(NDI_APP_MARKGARBAGE_APP, NDI_EPOCHSET_OBJ, T0, TIMEREF_T0, ...
			%	T1, TIMEREF_T1)
			%
			% Saves a variable marking a valid interval from T0 to T1 with respect
			% to an NDI_TIMEREFERENCE object TIMEREF_T0 (for T0) and TIMEREF_T1 (for T1) for
			% an NDI_EPOCHSET object NDI_EPOCHSET_OBJ.  Examples of NDI_EPOCHSET objects include
			% NDI_DAQSYSTEM and NDI_PROBE and their subclasses.
			%
			% TIMEREF_T0 and TIMEREF_T1 are saved as a name and type for looking up later.
			%
				% developer note: might be good idea to make sure these times exist at saving
				validinterval.timeref_structt0 = timeref_t0.ndi_timereference_struct();
				validinterval.t0 = t0;
				validinterval.timeref_structt1 = timeref_t1.ndi_timereference_struct();
				validinterval.t1 = t1;

				b = ndi_app_markgarbage_obj.savevalidinterval(ndi_epochset_obj, validinterval);

		end % markvalidinterval()

		function b = savevalidinterval(ndi_app_markgarbage_obj, ndi_epochset_obj, validintervalstruct)
			% SAVEVALIDINTERVAL - save a valid interval structure to the session database
			%
			% B = SAVEVALIDINTERVAL(NDI_APP_MARKGARBAGE_OBJ, NDI_EPOCHSET_OBJ, VALIDINTERVALSTRUCT)
			%
			% Saves a VALIDINTERVALSTRUCT to an experment database, in the appropriate place for
			% the NDI_EPOCHSET_OBJ data.
			%
			% If the entry is a duplicate, it is not saved but b is still 1.
			%

				if ~isa(ndi_epochset_obj, 'ndi_probe'),
					error(['do not know how to handle non-probes yet.']);
				end

				[vi,mydoc] = ndi_app_markgarbage_obj.loadvalidinterval(ndi_epochset_obj);
				b = 1;
			
				match = -1;
				for i=1:numel(vi),
					if vlt.data.eqlen(vi(i),validintervalstruct),
						match = i; 
						return; 
					end;
				end

				% if we are here, we found no match
				vi(end+1) = validintervalstruct;

				% save new variable, clearing old
				ndi_app_markgarbage_obj.clearvalidinterval(ndi_epochset_obj);
				newdoc = ndi_app_markgarbage_obj.session.newdocument('apps/markgarbage/valid_interval',...
						'valid_interval',vi) + ndi_app_markgarbage_obj.newdocument(); % order of operations matters! superclasses last
				newdoc = newdoc.set_dependency_value('element_id',ndi_epochset_obj.id());
				ndi_app_markgarbage_obj.session.database_add(newdoc);
		end; % savevalidinterval()

		function b = clearvalidinterval(ndi_app_markgarbage_obj, ndi_epochset_obj)
			% CLEARVALIDINTERVAL - clear all 'valid_interval' records for an NDI_EPOCHSET from session database
			% 
			% B = CLEARVALIDINTERVAL(NDI_APP_MARKGARBAGE_OBJ, NDI_EPOCHSET_OBJ)
			%
			% Clears all valid interval entries from the session database for object NDI_EPOCHSET_OBJ.
			%
			% Returns 1 on success, 0 otherwise.
			%
			% See also: NDI_APP_MARKGARBAGE/MARKVALIDINTERVAL, NDI_APP_MARKGARBAGE/SAVEALIDINTERVAL, ...
			%      NDI_APP_MARKGARBAGE/LOADVALIDINTERVAL 

				[vi,mydoc] = ndi_app_markgarbage_obj.loadvalidinterval(ndi_epochset_obj);
				if ~isempty(mydoc),
					ndi_app_markgarbage_obj.session.database_rm(mydoc);
				end

		end % clearvalidinteraval()

		function [vi,mydoc] = loadvalidinterval(ndi_app_markgarbage_obj, ndi_epochset_obj)
			% LOADVALIDINTERVAL - Load all valid interval records from session database
			%
			% [VI,MYDOC] = LOADVALIDINTERVAL(NDI_APP_MARKGARBAGE_OBJ, NDI_EPOCHSET_OBJ)
			%
			% Loads stored valid interval records generated by NDI_APP_MARKGARBAGE/MAKEVALIDINTERVAL
			%
			% MYDOC is the NDI_DOCUMENT that was loaded.
			%
				vi = vlt.data.emptystruct('timeref_structt0','t0','timeref_structt1','t1');

				searchq = ndi_query(ndi_app_markgarbage_obj.searchquery()) & ndi_query('','isa','valid_interval.json','');

				if isa(ndi_epochset_obj,'ndi_element'),
					searchq2 = ndi_query('','depends_on','element_id',ndi_epochset_obj.id());
					searchq = searchq & searchq2; 
				end

				mydoc = ndi_app_markgarbage_obj.session.database_search(searchq);

				if ~isempty(mydoc),
					for i=1:numel(mydoc),
						vi = cat(1,vi,mydoc{i}.document_properties.valid_interval);
					end;
				end;

				if isempty(vi), % underlying elements could still have garbage intervals
					% check here: is there a potential for a bug or error if the clocks differ?
					if isprop(ndi_epochset_obj,'underlying_element'),
						if ~isempty(ndi_epochset_obj.underlying_element),
							[vi_try,mydoc_try] = ndi_app_markgarbage_obj.loadvalidinterval(ndi_epochset_obj.underlying_element);
							if ~isempty(vi_try),
								vi = vi_try;
								mydoc = mydoc_try;
							end;
						end;
					end;
				end;

		end % loadvalidinterval()

		function [intervals] = identifyvalidintervals(ndi_app_markgarbage_obj, ndi_epochset_obj, timeref, t0, t1)
			% IDENTIFYVALIDINTERVAL - identify valid region within an interval
			%
			% INTERVALS = IDENTIFYVALIDINTERVALS(NDI_APP_MARKGARBAGE_OBJ, NDI_EPOCHSET_OBJ, TIMEREF, T0, T1)
			%
			% Examines whether there is a stored 'validinterval' variable by the app 'ndi_app_markgarbage' for
			% this NDI_EPOCHSET_OBJ, and, if so, returns valid intervals [t1_0 t1_1; t2_0 t2_1; ...] indicating
			% valid snips of data within the range T0 T1 (with respect to NDI_TIMEREFERENCE object TIMEREF).
			% INTERVALS has time with respect to TIMEREF.
			%
				% disp(['Call of identifyvalidintervals..']);
				baseline_interval = [t0 t1];
				explicitly_good_intervals = [];
				vi = ndi_app_markgarbage_obj.loadvalidinterval(ndi_epochset_obj);
				if isempty(vi),
					intervals = [];
					return;
				end;
				for i=1:size(vi,1),
					% for each marked valid region
					%    Can we project the marked valid region into this timeref?
						interval_t0_timeref = ndi_timereference(ndi_app_markgarbage_obj.session, vi(i).timeref_structt0);
						interval_t1_timeref = ndi_timereference(ndi_app_markgarbage_obj.session, vi(i).timeref_structt1);
						[epoch_t0_out, epoch_t0_timeref, msg_t0] = ...
								ndi_app_markgarbage_obj.session.syncgraph.time_convert(interval_t0_timeref, ...
									vi(i).t0, timeref.referent, timeref.clocktype);
						[epoch_t1_out, epoch_t1_timeref, msg_t1] = ...
								ndi_app_markgarbage_obj.session.syncgraph.time_convert(interval_t1_timeref, ...
									vi(i).t1, timeref.referent, timeref.clocktype);
						if isempty(epoch_t0_out) | isempty(epoch_t1_out),
							% so we say the region is valid, we have no restrictions to add
						elseif ~strcmp(epoch_t0_timeref.epoch,timeref.epoch) | ~strcmp(epoch_t1_timeref.epoch,timeref.epoch),
							% we can find a match but not in the right epoch
						else, % we have to carve out a bit of this region
							% do we need to check that epoch_t0_timeref matches our timeref? I think it is guaranteed
							explicitly_good_intervals = vlt.math.interval_add(explicitly_good_intervals, [epoch_t0_out epoch_t1_out]);
						end;
				end;
				if isempty(explicitly_good_intervals),
					intervals = baseline_interval;
				else,
					intervals = explicitly_good_intervals;
				end;
				
		end; % identifyvalidinterval

	end; % methods

end % ndi_app_markgarbage


