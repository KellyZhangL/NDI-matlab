classdef nsd_timemapping
% NSD_TIMEMAPPING - class for managing mapping of time across epochs and devices
%
% Describes mapping from one time base to another. The base class, NSD_TIMEMAPPING, provides
% polynomial mapping, although usually only linear mapping is used.
% The property MAPPING is a vector of length N+1 that describes the coefficients of a
% polynomial such that:
%
% t_out = mapping(1)*t_in^N + mapping(2)*t_in^(N-1) + ... mapping(N)*t_in + mapping(N+1)
%
% Usually, one specifies a linear relationship only, with MAPPING = [scale shift] so that
%
% t_out = scale * t_in + shift
% 

        properties (SetAccess=protected,GetAccess=public)
		mapping  % mapping parameters; in the NSD_TIMEMAPPING base class, this is a polynomial (see help POLYVAL)
        end % properties
        properties (SetAccess=protected,GetAccess=protected)
		
        end % properties

        methods

		function nsd_timemapping_obj = nsd_timemapping(varargin)
			% NSD_TIMEMAPPING
			%
			% NSD_TIMEMAPPING_OBJ = NSD_TIMEMAPPING()
			%    or
			% NSD_TIMEMAPPING_OBJ = NSD_TIMEMAPPING(MAPPING)
			%
			% Creates a new NSD_TIMEMAPPING object. In this base class,
			% the NSD_TIMEMAPPING object specifies a polynomial mapping
			% from one time base to another.
			% 
			% If the function is called with no input arguments, then
			% the trivial mapping MAPPING = [ 1 0 ] is used; this corresponds
			% to the polynomial t_out = 1*t_in + 0.
			%
			% Typically, the mapping is linear, so that MAPPING = [scale shift].
			%
			% See also: POLYVAL
			%
				if nargin==0,
					mapping = [1 0];
				elseif nargin==1,
					mapping = varargin{1};
				else,
					error(['Too many inputs to nsd_timemapping creator.']);
				end;

				nsd_timemapping_obj.mapping = mapping;
				
				try, 
					t_out = nsd_timemapping_obj.map(0);
				catch,
					error(['A test of the mapping with t_in = 0 failed: ' lasterr]);
				end
				
		end % nsd_timemapping

		function t_out = map(nsd_timemapping_obj, t_in)
			% MAP - perform a mapping from one time base to another
			%
			% T_OUT = MAP(NSD_TIMEMAPPING_OBJ, T_IN)
			%
			% Perform the mapping described by NSD_TIMEMAPPING_OBJ from one time base to another.
			%
			% In the base class NSD_TIMEMAPPING, the mapping is a polynomial.
				t_out = polyval(nsd_timemapping_obj.mapping, t_in);
		end % map

	end % methods
end % class nsd_timemapping

