function ndepths = fix_buoy_ts(infile)
% fix_buoy_ts corrects the variable names, dimensions, and
%   attributes of a netCDF file that was produced by Signell's
%   buoy2epic.exe, to produce one or more standard EPIC netCDF
%   time series.
% infile is the name of the initial data file.
% ndepths created data files will be created, one for each depth 
%   coordinate in the input file.
% If the input file is named fname.cdf (or fname.nc), the output
%   files will have names fname_d1.nc, fname_d2.nc, etc.
% The file ep_standard.nc, a no-data netcdf file of EPIC standard
% attributes, is required.
% Fran Hotchkiss  13 Apr 1999
% Improved to impose character type on global attribute
%   DELTA_T.  Fran Hotchkiss 1 Jul 1999.

% Open ep_standard.nc (read only).
eps = netcdf('ep_standard.nc','read');

% Create structure to aid in matching buoy variables to epic
%		variables.
mkconvar;

% Open (read only) and analyze input file:  
inc = netcdf(infile,'read');
%%		How many depths does	it have? 
%%				(This many output files will be made.)
indims = dim(inc);
dimnames = ncnames(indims);
is_depth = strncmp(dimnames,'depth',5);
ndepths = sum(sum(is_depth));
%%		What should the output files be named?
i = findstr(infile,'.');
handle = infile(1:i-1);
% For each depth:
for i = 1:ndepths
   %%    What depth coodinate?
   if i == 1
      dname = 'depth';
   else
      dname = ['depth00',int2str(i)];
   end
   %% 	Open (noclobber) output file.
   outfile = [handle,'_d',int2str(i),'.nc'];
   outc = netcdf(outfile,'noclobber');
   qstruct = ['Ep',handle,'_d',int2str(i)]%;
   minuses = findstr(qstruct,'-');
   qstruct(minuses)='_'%;
   %% 	Create global attributes.
   %%%		Copy from ep_standard.nc.
   inatts = att(eps);
	for j=1:length(inatts)
      copy (inatts(j),outc);
   end
   %%%		Copy from input file.
   inatts = att(inc);
	for j=1:length(inatts)
      copy (inatts(j),outc);
   end
   %%%		Update as needed.
   history = ['Attributes and variable names adjusted to EPIC standard'];
   history = [history, ' using fix_buoy_ts.m :BUOY file converted to '];
   history = [history, 'netCDF using Signell''s buoy2epic.exe :Original'];
   history = [history, ' BUOY creation date was ',inc.CREATION_DATE(:)];
   outc.history = ncchar(history);
   outc.CREATION_DATE = ncchar(datestr(now,0));
   dt = inc.sampling_interval(:);
   if (ischar(dt))
      outc.DELTA_T = ncchar(dt);
   else
      outc.DELTA_T = ncchar(num2str(dt));
   end
   var_list = ':';
   %%		Create dimensions (copy from ep_standard.nc).
   copy(eps{'time'},outc,0,1);
   copy(eps{'time2'},outc,0,1);
   copy(eps{'lat'},outc,0,1);
   copy(eps{'lon'},outc,0,1);
   copy(eps{'depth'},outc,0,1);
   %%		Create variables.
   %%%      Copy coordinate variables from ep_standard.nc.
   incoords = coord(eps);
	for j=1:length(incoords)
      copy (incoords{j},outc,0,1);
   end
   %%%		Find record variables for this depth coordinate.
   invars = var(inc);
	for j=1:length(invars)
      vardim = dim(invars{j});
		dimnames = ncnames(vardim);
      is_depth = strcmp(dimnames,dname);
      is_time = strcmp(dimnames,'time');
      flag(j) = sum(sum(is_depth))*sum(sum(is_time));
   end
   outvars=find(flag);
   %%%		Map input to output variables.
   %%%			Check mapping with interactive dialog.
   for j=1:length(outvars)
      v = invars{outvars(j)};
      bname{j} = name(v);
      if length(bname{j})>=3;
         b3name = bname{j}(1:3);
      else 
         b3name = '   ';
         b3name(1:length(bname{j})) = bname{j};
      end
         
      bunits = v.units(1:3);
      guess = 'discard'; % this name flags variables to discard.
   	eval([qstruct '.inst_type = v.serial_number(:)']);
      for k=1:length(convar)
         if ~isempty(strmatch(b3name,convar(k).buoyname))
            if ~isempty(strmatch(bunits,convar(k).buoyunit))
               guess = convar(k).epicname;
            end
         end
      end
      eval([qstruct '.varname_' bname{j} '= guess']);
   end
   eval(['uigetparm(',qstruct,')']);
   eval(['load ',qstruct]);
   eval(['outc.INST_TYPE = ',qstruct,'.inst_type']);
%%%      Create output variables.
	for j=1:length(outvars)
   	eval(['epname = ',qstruct,'.varname_',bname{j}]);
   	if ~strcmp('discard',epname)
%%%			Copy from ep_standard.nc.
			invar = eps{epname};
			copy(invar,outc,0,1);
%%%			Copy from input file.
			invar = inc{bname{j}};
         var = outc{epname};
         var.sensor_depth = invar.sensor_depth(:);
         var.serial_number = invar.serial_number(:);
         var.minimum = invar.minimum(:);
         var.maximum = invar.maximum(:);
			var_list = [var_list,var.name(:),':'];
      end
   end
   j=length(var_list)-1;   
   outc.VAR_DESC = var_list(2:j);
%%		Fill variables (copy from input file).
   endef(outc);
%%%		Coordinate variables.
   copy(inc{'time'},outc{'time'},1,0);
   copy(inc{'time2'},outc{'time2'},1,0);
   copy(inc{'lat'},outc{'lat'},1,0);
   copy(inc{'lon'},outc{'lon'},1,0);
   copy(inc{dname},outc{'depth'},1,0);
   % check to make sure lon has correct sign
   if outc{'lon'}(1)>=0.;
      outc{'lon'}(1) = -outc{'lon'}(1);
   end
   
%%%		Record variables.
	for j=1:length(outvars)
   	eval(['epname = ',qstruct,'.varname_',bname{j}]);
   	if ~strcmp('discard',epname)
			invar = inc{bname{j}};
			copy(invar,outc{epname},1,0);
      end
   end
%%		Close this output file.
   close(outc)
end

% Close input file and ep_standard.nc.
ncclose

