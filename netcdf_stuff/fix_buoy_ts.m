function ndepths = fix_buoy_ts(infile)
% FIX_BUOY_TS: converts file with Buoy format named variables to EPIC
% fix_buoy_ts corrects the variable names, dimensions, and
%   attributes of a netCDF file that was produced by Signell's
%   buoy2epic.exe, to produce one or more standard EPIC netCDF
%   time series.
% infile is the name of the initial data file.
% ndepths created data files will be created, one for each depth
%   coordinate in the input file.
% If the input file is named fname.cdf (or fname.nc), the output
%   files will have names fname_d1.nc, fname_d2.nc, etc., depending
%   on whether dimensioned with depth, depth002, or depth003
% The file ep_standard.nc, a no-data netcdf file of EPIC standard
% attributes, is required in the directory with the files.
% Fran Hotchkiss  13 Apr 1999
% Improved to impose character type on global attribute
%   DELTA_T.  Fran Hotchkiss 1 Jul 1999.

% Open ep_standard.nc (read only).
% can't use this: exist('ep_standard.nc','file') because it finds it on
% the MATLABPATH, but it has to be in the CWD,
nstr=ls;
if isempty(findstr(nstr,'ep_standard.nc'))
    disp ('copy ep_standard.nc into cwd and try again');
    ndepths=0;
    return
else
    eps = netcdf('ep_standard.nc','read');
end
clear nstr

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
    if ndepths == 1
        outfile = [handle, '.nc'];
    else
        outfile = [handle,'_d',int2str(i),'.nc'];
    end
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
    history = [history, ' using fix_buoy_ts.m: ', inc.history(:)];
    history = [history, ': BUOY file converted to '];
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
        % was 'discard' when non-epic names caused problems
        % in 2008, can mix EPIC and non-EPIC, so keep the variables as-is
        guess = 'same'; % this name flags variables to keep.
        eval([qstruct '.inst_type = v.serial_number(:)']);
        for k=1:length(convar)
            if ~isempty(strmatch(b3name,convar(k).buoyname))
                if ~isempty(strmatch(bunits,convar(k).buoyunit))
                    guess = convar(k).epicname;
                    % vsp matchs both CS_300 & WS_400, and wdi matches
                    % CD_310 and WD_410. implement a inst_type condition 
                    % if Wspd and Wdirare needed. Cspd & cdir are found 
                    % first and are usually correct
                    break;
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
        if ~strcmp('same',epname)
            %%%		use name from ep_standard.nc.
            invar = eps{epname};
            copy(invar,outc,0,1);
            ovar = outc{epname};
        else
            %%%		keep from infile.
            invar = inc{bname{j}};
            copy(invar,outc,0,1);
            ovar = outc{bname{j}};
        end
        %%%		Copy from input file.
        invar = inc{bname{j}};
        ovar.sensor_depth = invar.sensor_depth(:);
        ovar.serial_number = invar.serial_number(:);
        ovar.minimum = invar.minimum(:);
        ovar.maximum = invar.maximum(:);
        % the .name attribute is established in ep_standard
        if ~strcmp('same',epname)
            var_list = [var_list, ovar.name(:), ':'];
        else    % for non-EPIC names you have to do something else
            var_list = [var_list, bname{j}(1:3), ':'];
            ovar.name=bname{j}(1:3);
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
        if ~strcmp('same',epname)
            invar = inc{bname{j}};
            copy(invar,outc{epname},1,0);
        end
    end
    %%		Close this output file.
    close(outc)
end

% Close input file and ep_standard.nc.
ncclose

