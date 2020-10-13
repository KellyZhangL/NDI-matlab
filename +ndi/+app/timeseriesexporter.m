classdef timeseriesexporter < ndi.app
	% ndi.app.timeseriesexporter - an app for exporting timeseries from NDI
	%
	% This application provides support for exporting NDI timeseries to 
	% formats such as the MDA (multidimensional array) format.
	%
	% ndi.app.timeseries Properties:
	%   chunkTime - number of seconds of data to read in at a time
	%
	% ndi.app.timeseries Methods:
	%  timeseriesexporter - Creator, requires an ndi.session object
	%  setchunktime - Set the chunk time
	%  epoch2mda16i - write an epoch to an mda file
		
	properties,
		chunkTime; % number of seconds of data to read in at a time
	end; % properties

	methods,
		function ndi_app_timeseriesexporter_obj = timeseriesexporter(varargin)
			% ndi.app.timeseriesexporter - an app to export time series data
			%
			% NDI_APP_TIMESERIESEXPORTER_OBJ = ndi.app.timeseriesexporter(SESSION)
			%
			% Creates a new ndi.app.timeseriesexporter app object that can operate
			% on ndi.session objects. The app is named 'ndi.app.timeseriesexporter.
			%
			% By default, the chunkTime property is set to 300 (seconds).
			%
				session = [];
				name = 'ndi.app.timeseriesexporter';
				if numel(varargin)>0,
					session = varargin{1};
				end
				ndi_app_timeseriesexporter_obj = ndi_app_timeseriesexporter_obj@ndi.app(session, name);
				ndi_app_timeseriesexporter_obj.chunkTime = 300;

		end; % ndi.app.timeseriesexporter() constructor

		function ndi_app_timeseriesexporter_obj = setchunktime(ndi_app_timeseriesexporter_obj, chunkTime)
			% SETCHUNKTIME - set chunk time of an ndi.app.timeseriesexporter app
			% 
			% NDI_APP_TIMESERIESEXPORTER_OBJ = SETCHUNKTIME(NDI_APP_TIMESERIESEXPORTER_OBJ, CHUNKTIME)
			%
			% Sets the chunk time of an ndi.app.timeseriesexporter application. The chunk time has units of seconds.
			%
			% Example: ndi_app_timeseriesexporter_obj = ndi_app_timeseriesexporter_obj.setchunktime(300);
			%

			ndi_app_timeseriesexporter_obj.chunkTime = chunkTime;

		end; % setchunktime

		function b = epoch2mda16i(ndi_app_timeseriesexporter_obj, ndi_timeseries_obj, timeref_or_epoch, t0, t1, scale, filename)
			% EPOCH2MDA16I - convert an epoch from an ndi.timeseries to an MDA 16-bit integer file
			%
			% B = EPOCH2MDA16i(NDI_APP_TIMESERIESEXPORTER_OBJ, NDI_TIMESERIES_OBJ, TIMEREF_OR_EPOCH, T0, T1, SCALE, FILENAME)
			%
			% Reads in an ndi.timeseries object NDI_TIMESERIES_OBJ at the time reference EPOCH_OR_TIMEREF from
			% time T0 to T1, and writes MDA 16-bit integer format to FILENAME. The data is first rescaled using vlt.math.rescale
			% from SCALE(1) (low) to SCALE(2) (high). The data are rescaled to be in the range -2^15 and 2^15-1.
			%
				if isa(timeref_or_epoch,'ndi.time.timereference'),
					timeref = timeref_or_epoch;
				else,
					timeref_or_epoch = ndi_timeseries_obj.epochid(timeref_or_epoch);
					timeref = ndi.time.timereference(ndi_timeseries_obj, ndi.time.clocktype('dev_local_time'), timeref_or_epoch, 0);
				end;

				[epoch_t0_out, epoch_timeref, msg] = ndi_timeseries_obj.session.syncgraph.time_convert(timeref, t0, ...
						ndi_timeseries_obj, ndi.time.clocktype('dev_local_time'));
				[epoch_t1_out, epoch_timeref, msg] = ndi_timeseries_obj.session.syncgraph.time_convert(timeref, t1, ...
						ndi_timeseries_obj, ndi.time.clocktype('dev_local_time'));

				if isempty(epoch_timeref),
					error(['Could not find time mapping (maybe wrong epoch name?): ' msg ]);
				end;


				n = 1;
				epoch = {epoch_timeref.epoch};

				sample_rate = ndi_timeseries_obj.samplerate(epoch{n});
				data_example = ndi_timeseries_obj.readtimeseries(epoch{n},0,1/sample_rate); % read a single sample
				start_sample = ndi_timeseries_obj.times2samples(epoch{n},epoch_t0_out);

				if isnan(start_sample),
					start_sample = 1;
				end;
				read_start_sample = start_sample;
				end_sample =  ndi_timeseries_obj.times2samples(epoch{n},epoch_t1_out);
				if isnan(end_sample),
					end_sample = Inf;
				end;
				endReached = 0; % Variable to know if end of file reached

				appending = 0;

				while (~endReached)
					read_end_sample = ceil(read_start_sample + ndi_app_timeseriesexporter_obj.chunkTime * sample_rate); % end sample for chunk to read
					if read_end_sample > end_sample,
						read_end_sample = end_sample;
					end;
					% Read from element in epoch n from start_time to end_time
					read_times = ndi_timeseries_obj.samples2times(epoch{n}, [read_start_sample read_end_sample]);
					data = ndi_timeseries_obj.readtimeseries(epoch{n}, read_times(1), read_times(2));

					% Checks if endReached by a threshold sample difference (data - (end_time - start_time))
					if (size(data,1) - ((read_end_sample - read_start_sample) + 1)) < 0 % if we got less than we asked for, we are done
						endReached = 1;
					elseif read_end_sample==end_sample,
						endReached = 1;
					end

					data = int16(rescale(data,scale,[-2^15 2^15-1]));

					data = data'; % must convert so each data point is a column; readtimeseries returns each data point as a row

					writemda16i(data, filename, appending);

					appending = 1;

					read_start_sample = round(read_start_sample + ndi_app_timeseriesexporter_obj.chunkTime * sample_rate);

				end;
		end; % epoch2mda16i

	end; % methods

end % classdef
