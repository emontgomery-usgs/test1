% cleanhydra - apply basic editing tools to hydra data
%
% function cleanhydra(cdfbFile, cdfsFile, cdfqFile, operation, ...
%       'variables', {vnames}, 'settings', settings.n, ...
%       'burstrange', [1:Inf])
%
% cdfbFile = raw ADV or PCADP netCDF burst data converted by adr2cdf.m or
%           adp2cdf.m
% cdfsFile = raw ADV or PCADP netCDF statistics data converted by adr2cdf.m
%           or adp2cdf.m
% cdfqFile = file to save the quality info returned by the cleanup
%           operation
% operation = which cleanup operation to perform on the data
%           variable to apply operation to, only one operation per run
% variables = cell array of variable names from the burst file to operate on
% settings = a structure of control settings for each operation below
% burstrange = range of bursts or individual bursts to work on, using the 
%           Sontek burst number assigned in-situ, 
%           as a vector of individual bursts [1 5 9 10 ...]
%           as a vector of burst ranges [1:10 20:30 ...]
%
% operation = autoclean
%   there are no settings for this, they are automatic
%   applies thumbfinger, deglitch1vector
% operation = deglitch1vector
%   uses the deglitch1vector function
%   settings.samplerate = 1; % Hz, taken from the netCDF file
%   settings.nsd = 2.8; % num std. deviations that defines outliers
%   settings.ndt = 6; % cutoff frequency
%   settings.verbose = turn on statistical output
%   Note that deglitch1vector cannot tolerate NaNs
% operation = checkcorr  
%   operates only on velocity, other variables ignored
%   settings.locorr = 65; % remove anything below this correlation value
%   settings.rvalue = NaN; % remove anything below this correlation value
% operation = thumbfinger
%   operates on heading, pitch, roll, temperature, velocity unless
%   variable names are provided
%   settings.nsd = 2.8; % remove anything beyone this number of std. dev.
% operation = clip
%   operates on a variable you must name
%   settings.min = miniumum acceptable value for data
%   settings.max = maximum acceptable value for data
%   settings.rvalue = NaN; 
%

% If you are a MATLAB jockey, you can add your own 'operation' to call a
% cleanup routine of your own design, simply use the existing ones in the 
% code below as a template, and thumbfinger.m as an example of how settings
% are passed between cleanhydra and the cleanpu routine that does the work.
% Cleanhydra.m is set up to take care of all the netcdf calls and to save
% quality information about the results of the cleanup operation.
%
% this function will not end gracefully if you don't include all the inputs

% 4/14/06
% -- clip function added
% 4/10/06
% -- added a variable checkcorr threshold
% -- added nsd values to cdf*.history
% 11/17/05
% -- update to recalculate the stats used by flagbadadv

function cleanhydra(varargin)

% parse the inputs
% cdfbFile, cdfsFile, cdfqFile, operation, variables, settings, ...
%       'variables', {vnames}, 'settings', settings.n, ...
%       'burstrange', [1:Inf])

error(nargchk(4,10, nargin))

% the first three must always be the files
cdfbFile = varargin{1}; % burst file
cdfsFile = varargin{2}; % stats file
cdfqFile = varargin{3}; % quality file
operation = varargin{4}; % operation to apply
if nargin > 4, 
    for n = 5:2:nargin,
        switch varargin{n}
            case 'variables', variables = varargin{n+1};
            case 'settings', settings = varargin{n+1};
            case 'burstrange', burstNums = varargin{n+1};
        end
    end
end

mversion = 'SVN $Revision: 1086 $';

if exist(cdfbFile,'file') ~=2,
    [fname, pathname] = uigetfile('*b*.cdf', 'Pick a netcdf file containing ADV burst data');
    if isequal(fname,0) || isequal(pathname,0)
        disp('User pressed cancel')
        return
    end
    cdfbFile = fullfile(pathname, fname);
    disp(['User selected ', cdfbFile])
end

% make sure this is a burst ADV or PCADP data file
cdfb = netcdf(cdfbFile,'write');
if isempty(cdfb),
    disp(['Unable to open ',cdfbFile]);
    return;
end

if strcmp(cdfb.DESCRIPT(:),'Sontek ADV raw data burst file'),
    vdatanames = {'Velx','Vely','Velz'};
    cdatanames = {'cor'};
elseif strcmp(cdfb.DESCRIPT(:),'Sontek PCADP raw data burst file'),
    nBeams = cdfb.Nbeams(:);
    for n = 1:nBeams, 
        vdatanames{n} = sprintf('Vel%d',n); 
        cdatanames{n} = sprintf('Cor%d',n); 
    end
else
    disp('File is not a Sontek ADV or PCADP raw data netCDF file containing all sample data (*b.cdf)')
    close (cdfb)
    return
end

if exist(cdfsFile,'file') ~=2,
    [fname, pathname] = uigetfile('*s*.cdf', 'Pick a netcdf file containing burst data');
    if isequal(fname,0) || isequal(pathname,0)
        disp('User pressed cancel')
        return
    end
    cdfsFile = fullfile(pathname, fname);
    disp(['User selected ', cdfsbFile])
end

% make sure this is a stats ADV or PCADP data file
cdfs = netcdf(cdfsFile,'write');
if isempty(cdfs),
    disp(['Unable to open ',cdfsFile]);
    return;
end
if strcmp(cdfs.DESCRIPT(:),'Sontek ADV raw data statistics file'),
    vdatanames = {'Velx','Vely','Velz'};
    cdatanames = {'cor'};
    samplerate = cdfb.ADVDeploymentSetupSampleRate(:);
elseif strcmp(cdfs.DESCRIPT(:),'Sontek PCADP raw data statistics file'),
    nBeams = cdfs.Nbeams(:);
    for n = 1:nBeams, 
        vdatanames{n} = sprintf('Vel%d',n); 
        cdatanames{n} = sprintf('Cor%d',n); 
    end
    if strcmp(cdfb.PCADPUserSetupBurstMode(:), 'Enabled'),
        samplerate = cdfb.PCADPUserSetupProfileInterval(:);
    else
        % TODO - check this, do not have any data run in average mode
        samplerate = cdfb.PCADPUserSetupAvgInterval(:);
    end
else
    disp('File is not a Sontek ADV or PCADP raw data netCDF file containing statistics data (*s.cdf)')
    close (cdfs)
    return
end

if exist(cdfqFile,'file') ~=2, 
    [fname, pathname] = uigetfile('*q*.cdf', 'Pick a netcdf file containing ADV burst data');
    if isequal(fname,0) || isequal(pathname,0)
        disp('User pressed cancel')
        return
    end
  cdfqFile = fullfile(pathname, fname);
end
  cdfq = netcdf(cdfqFile,'write');
  disp(['User selected ', cdfqFile])

if isempty(cdfq),
    disp(['Unable to open ',cdfqFile]);
    return;
end

tic

% get the dimensionality of things
data = size(cdfb{'time'});
nSamples = data(2);
if strcmp(cdfb.DESCRIPT(:),'Sontek PCADP raw data burst file'),
    ProbeType = 'PCADP';
    theDim = 'cell';
else 
    ProbeType = 'ADV';
    theDim = 'axis';
end

% we need this later to look up burst indeces
burstNums_in_file = cdfb{'burst'}(:);
if isempty(burstNums_in_file),
    disp('Cleanhydra: problem reading burst numbers in file')
end

if ~exist('burstNums','var'), burstNums = []; end
if isempty(burstNums),
    % assume we'll work on everything in the file
    burstNums = burstNums_in_file;
end
if ~exist('settings','var'),
    % assume defaults
    settings = [];
end
if ~exist('variables','var'),
    % assume defaults
    variables = [];
end

% figure out which kind of pressure data is in there
if ~isempty(cdfb{'extpressfreq'}), % it's a freq Paros, no question
    pdataname = 'extpressfreq';
elseif ~isempty(cdfb{'extpress'}), % it's a druck or a serial paros
    pdataname = 'extpress';
elseif ~isempty(cdfb{'pressure'}), % it's an internal strain guage
    pdataname = 'pressure';
else
    disp('No pressure data in this file')
    pdataname = [];
end

% predefine data holder for speed, MATLAB is more efficient when it doesn't
% keep allocating memory
dirtydata = zeros(1, nSamples);
cleandata = dirtydata;

%  set up for automatic operation
if strcmp(operation, 'autoclean'),
    % autoclean overrides other inputs except bursts
    % ------------------ thumbfinger outliers 
    iOp = 1;
    % this must replace with the mean or median as Nans 
    % will screw up the filtering in deglitch
    opbvarnames{iOp} = {vdatanames{1},vdatanames{2},vdatanames{3},...
        'heading','pitch','roll','temperature'};
    if ~isempty(pdataname), 
        opbvarnames{iOp}{length(opbvarnames{iOp})+1} = pdataname;
    end
    if strcmp(ProbeType,'PCADP'), % clean the res. velocity too
        opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures1';
        opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures2';
        opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures3';
    end
    % set up the actual function call information
    opname{iOp} = 'thumbfinger';  
    if isfield(settings,'nsd')
        opsettings(iOp).nsd = settings.nsd; 
    else
      opsettings(iOp).nsd = 2.8; % remove anything beyond N std around the median 
    end
        opsettings(iOp).nsd_ori=opsettings(iOp).nsd; 

     opsettings(iOp).samplerate = samplerate; % setsample rate
     opsettings(iOp).z=0;
    opcall{iOp} = '[cleandata, Qa] = thumbfinger(dirtydata,opsettings(iOp));';
    opQavnames{iOp} = {'nbad','delmean','delvar','stdr'};
    opQaunits{iOp} = {'count','ratio','ratio',''}; % use '' to get variable's units
    opQalname{iOp} = {'number of bad points',...
        'ratio of the mean before and after points were replaced',...
        'ratio of the variance before and after points were replaced',...
        'standard deviation of the residuals'};
    % --------------- deglitch everything
    iOp = 2;
    % opbvarnames{iOp} = {vdatanames{:},'heading','pitch','roll','temperature'};
      opbvarnames{iOp} = {vdatanames{1},vdatanames{2},vdatanames{3}};
    if ~isempty(pdataname), 
        opbvarnames{iOp}{length(opbvarnames{iOp})+1} = pdataname;
    end
    if strcmp(ProbeType,'PCADP'), % clean the res. velocity too
        opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures1';
        opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures2';
        opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures3';
    end

    % set up the actual function call information
    opname{iOp} = 'deglitch1vector';  
    opsettings(iOp).samplerate = samplerate;
    if isfield(settings,'verbose')
        opsettings(iOp).verbose=settings.verbose;
    else
       opsettings(iOp).verbose=0;
    end
    if isfield(settings,'nsd')
       opsettings(iOp).nsd = settings.nsd; 
    else
       opsettings(iOp).nsd = 2.8; % remove anything beyond 2.8 std around the median
       settings.nsd=2.8;
    end
      opsettings(iOp).nsd_ori=opsettings(iOp).nsd; 

    opcall{iOp} = '[cleandata, Qa] = deglitch1vector(dirtydata,opsettings(iOp));';
    opQavnames{iOp} = {'nbad','nfixed_dg','nfixed_filt','delmean','delvar','stdr'};
    opQaunits{iOp} = {'count','count','count','ratio','ratio',''}; % use '' to get variable's units
    opQalname{iOp} = {'number of bad points',...
        'number of endpoints fixed by deglitch',...
        'number of endpoints fixed by filter',...
        'ratio of the mean before and after points were replaced',...
        'ratio of the variance before and after points were replaced',...
        'standard deviation of the residuals'};
elseif strcmp(operation, 'thumbfinger'),
    % TODO check to see if inputs were already set
    iOp = 1;
    % this must replace with the mean or median as Nans 
    % will screw up the filtering in deglitch
    if isempty(variables), 
        opbvarnames{iOp} = {vdatanames{1},vdatanames{2},vdatanames{3},...
            'heading','pitch','roll','temperature'};
        if ~isempty(pdataname),
            opbvarnames{iOp}{length(opbvarnames{iOp})+1} = pdataname;
        end
        if strcmp(ProbeType,'PCADP'), % clean the res. velocity too
            opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures1';
            opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures2';
            opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures3';
        end
    else 
        opbvarnames{iOp} = variables;
    end
    % set up the actual function call information
    opname{iOp} = 'thumbfinger';  
    if isfield(settings,'nsd')
        opsettings(iOp).nsd = settings.nsd; 
    else
      opsettings(iOp).nsd = 2.8; % remove anything beyond N std around the median 
       settings.nsd=2.8;
    end
       opsettings(iOp).nsd_ori=opsettings(iOp).nsd; 

    opcall{iOp} = '[cleandata, Qa] = thumbfinger(dirtydata,opsettings(iOp));';
    opQavnames{iOp} = {'nbad','delmean','delvar','stdr'};
    opQaunits{iOp} = {'count','ratio','ratio',''}; % use '' to get variable's units
    opQalname{iOp} = {'number of bad points',...
        'ratio of the mean before and after points were replaced',...
        'ratio of the variance before and after points were replaced',...
        'standard deviation of the residuals'};
elseif strcmp(operation, 'checkcorr'),
    % this only operates on velocity
    iOp = 1;
    % this must replace with the mean or median as Nans 
    % will screw up the filtering in deglitch
    opbvarnames{iOp} = {vdatanames{:}};
    opcvarnames{iOp} = {cdatanames{:}};
    if strcmp(ProbeType,'PCADP'), % clean the res. velocity too
        opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures1';
        opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures2';
        opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures3';
        opcvarnames{iOp} = {cdatanames{:},cdatanames{:}};
    end
    % set up the actual function call information
    opname{iOp} = 'checkcorr';  
    
    opsettings(iOp).rvalue = NaN; % replacement value 
    if isfield(settings,'locorr') 
        opsettings(iOp).locorr = settings.locorr;
    else
        opsettings(iOp).locorr = 65;
     
    end
    opcall{iOp} = '[cleandata, Qa] = checkcorr(dirtydata,corrdata,opsettings(iOp));';
    opQavnames{iOp} = {'nbad'};
    opQaunits{iOp} = {'count'}; % use '' to get variable's units
    opQalname{iOp} = {'number of bad points'};
elseif strcmp(operation, 'clip'),
    % TODO check to see if inputs were already set
    iOp = 1;
    % there is no option to run this without specifying a variable
    if isempty(variables), 
        disp('User must specify variable names to use clip')
        return
    else 
        %variables MUST be a cell! try to convert if not 
        if ~iscell(variables)
            variables=cellstr(variables);
        end
        opbvarnames{iOp} = variables;
    end
    % set up the actual function call information
    opname{iOp} = 'clip';  
    if isfield(settings,'min')
        opsettings(iOp).min = settings.min; 
    else
        disp('User must specify min and max limit settings')
        return        
    end
    if isfield(settings,'max')
        opsettings(iOp).max = settings.max; 
    else
        disp('User must specify min and max limit settings')
        return        
    end
    opcall{iOp} = '[cleandata, Qa] = clip(dirtydata,opsettings(iOp));';
    opQavnames{iOp} = {'removed'};
    opQaunits{iOp} = {''}; % use '' to get variable's units
    opQalname{iOp} = {'true if all samples removed from burst'};
elseif strcmp(operation, 'deglitch1vector'),    
    % TODO check to see if inputs were already set
    iOp = 1;
    if isempty(variables),
        opbvarnames{iOp} = {vdatanames{1},vdatanames{2},vdatanames{3}};
        if ~isempty(pdataname),
            opbvarnames{iOp}{length(opbvarnames{iOp})+1} = pdataname;
        end
        if strcmp(ProbeType,'PCADP'), % clean the res. velocity too
            opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures1';
            opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures2';
            opbvarnames{iOp}{length(opbvarnames{iOp})+1} = 'Ures3';
        end
    else
        opbvarnames{iOp} = variables;
    end
    % set up the actual function call information
    opname{iOp} = 'deglitch1vector';     
    opsettings(iOp).samplerate = samplerate;
    if isfield(settings,'verbose')
        opsettings(iOp).verbose=settings.verbose;
    else
       opsettings(iOp).verbose=0;
    end
    if isfield(settings,'nsd')
        opsettings(iOp).nsd = settings.nsd; 
    else
      opsettings(iOp).nsd = 2.8; % remove anything beyond 2.8 std around the median
        settings.nsd=2.8;
   end
      opsettings(iOp).nsd_ori=opsettings(iOp).nsd; 
    if isfield(settings,'ndt'), opsettings(iOp).ndt = settings.ndt; end
    opcall{iOp} = '[cleandata, Qa] = deglitch1vector(dirtydata,opsettings(iOp));';
    opQavnames{iOp} = {'nbad','nfixed_dg','nfixed_filt','delmean','delvar','stdr'};
    opQaunits{iOp} = {'count','count','count','ratio','ratio',''}; % use '' to get variable's units
    opQalname{iOp} = {'number of bad points',...
        'number of endpoints fixed by deglitch',...
        'number of endpoints fixed by filter',...
        'ratio of the mean before and after points were replaced',...
        'ratio of the variance before and after points were replaced',...
        'standard deviation of the residuals'};
else   
    disp(sprintf('cleanhydra: Unrecognized operation %s',operation))
    close(cdfb); close(cdfs); close(cdfq); 
    return
end

disp(['Setting up operation ',operation])

% setup the quality file for output
qvarnames = ncnames(var(cdfq));
% step through the operations
for iOp = 1:length(opname),
    disp(sprintf('Creating qFile variables for %s ',opname{iOp}));
    % see if there is already a name in there
    for iName = 1:length(qvarnames),
        if ~isempty(findstr(opname{iOp},qvarnames{iName})), opq = 1;
        else opq = 0;
        end
    end
    if ~opq, % we need a holder for quality output
        disp(sprintf('setting up quality output variables for %s in Quality file',opname{iOp}))
         for iVar = 1:length(opbvarnames{iOp}),
             % make sure the var is really in there
            if ~isempty(cdfb{opbvarnames{iOp}{iVar}}),        
                dimsizes = size(cdfb{opbvarnames{iOp}{iVar}});
                ndims = length(dimsizes);
                if ndims == 2,
                    % if data is not by cell or beam, add the size of the last dim
                    % for looping later without confusion
                    dimsizes(3) = 1;
                elseif ndims > 3,
                    disp('data has too many dimensions!');
                end
                for iName = 1:length(opQavnames{iOp}),
                    varname = sprintf('%s_%s_%s',opname{iOp},opbvarnames{iOp}{iVar},opQavnames{iOp}{iName});
                    if ndims > 2,
                        cdfq{varname} = ncfloat('burst',theDim);  cdfobj = cdfq{varname};
                    else
                        cdfq{varname} = ncfloat('burst');  cdfobj = cdfq{varname};
                    end
                    if ~isempty(opQaunits{iOp}{iName}),
                        cdfobj.units = cdfb{opbvarnames{iOp}{iVar}}.units(:);
                    else
                        cdfobj.units = ncchar(opQaunits{iOp}{iName});
                    end
                    cdfobj.long_name = ncchar(opQalname{iOp}{iName});
                end
            end
        end
    end
    % store the settings applied in the quality file as global attributes
    fnames = fieldnames(opsettings(iOp));
    for ifname = 1:length(fnames),
        buf = sprintf('cdfq.%s_%s = opsettings(iOp).%s;',opname{iOp},fnames{ifname},fnames{ifname});
        eval(buf);
    end
end

disp(sprintf('Now scanning %d bursts in file %s',length(burstNums),cdfbFile))
% main loop
% step through the operations
for iOp = 1:length(opname),
    disp(sprintf('Applying %s ',opname{iOp}));
    % step through the bursts
    for n = 1:length(burstNums),
        % find the netCDF index to the Sontek burst number
        iBurst = find(burstNums_in_file == burstNums(n), 1, 'first');
        if isempty(iBurst), disp(sprintf('Sontek burst #%d not found in file', burstNums(n)))
        else
            if n<50 && ~rem(n,10), disp(sprintf('At burst %d %f min elapsed', burstNums_in_file(iBurst), toc/60)), end
            if n>50 && ~rem(n,100), disp(sprintf('At burst %d %f min elapsed', burstNums_in_file(iBurst), toc/60)), end
            Qdata.burstNum(iBurst) = burstNums_in_file(iBurst);
            %if Qdata.burstNum(iBurst) == 32, keyboard; end
            % step through the variables
            for iVar = 1:length(opbvarnames{iOp}),
                % check the shape for multiple bins or beams
                % things are always at least 2 dims, [burst, sample]
                % exceptions are PCADP: vel, amp, cor, for the cells [burst, sample, cell]
                %                  ADV: cor, amp for the beams [burst, sample, beam];
                % pressure (extpressfreq) is also an exception
                if strmatch(opbvarnames{iOp},'extpressfreq','exact')
                   dimsizes = size(cdfb{opbvarnames{iOp}});
                else
                   dimsizes = size(cdfb{opbvarnames{iOp}{iVar}});
                end
                ndims = length(dimsizes);
                if ndims == 2,
                    % if data is not by cell or beam, add the size of the last dim
                    % for looping later without confusion
                    dimsizes(3) = 1;
                elseif ndims > 3,
                    disp('data has too many dimensions!');
                end

                for iDim3 = 1:dimsizes(3), % index by beam or cell
                    % get data
                  if strmatch(opbvarnames{iOp},'extpressfreq')
                    dirtydata = cdfb{opbvarnames{iOp}{iVar}}(iBurst,:);
                  else
                    dirtydata = cdfb{opbvarnames{iOp}{iVar}}(iBurst,:,iDim3);
                  end
                    if strcmp(operation, 'checkcorr'),
                        if strcmp(ProbeType, 'PCADP'), % PCADP, cor1, cor2, cor3
                            corrdata = cdfb{opcvarnames{iOp}{iVar}}(iBurst,:,iDim3);
                        else % ADV cor(nsamples:3)
                            corrdata = cdfb{opcvarnames{iOp}{1}}(iBurst,:,iDim3);
                        end
                    end
                    if ~isempty(dirtydata),
                        % perform cleanup on whole burst - call the operation
                        % opcall returns clean data
                        % disp(sprintf('Applying %s to %s burst %d cell/axis %d',opname{iOp}(:), ...
                        %    opbvarnames{iOp}{iVar}(:), Qdata.burstNum(iBurst), iDim3));
                         
                        % this is where everything happens-
                        eval(opcall{iOp});
                        % store the quality results
                        for iQa = 1:length(opQavnames{iOp}),
                            varname = sprintf('%s_%s_%s',opname{iOp},opbvarnames{iOp}{iVar},opQavnames{iOp}{iQa});
                            cdfq{varname}(iBurst,iDim3) = getfield(Qa,opQavnames{iOp}{iQa});
                        end
                        % now store the data results
                        cdfb{opbvarnames{iOp}{iVar}}(iBurst,:,iDim3) = cleandata;
                        % do stats on the whole burst and save to cdfs
                        [sMeanvar, sStdvar] = mapvarnames(opbvarnames{iOp}{iVar}, ProbeType);
                        if ~isempty(sMeanvar),
                            if findstr('Median',sMeanvar),
                                cdfs{sMeanvar}(iBurst,:,iDim3) = gmedian(cleandata);
                            else
                                cdfs{sMeanvar}(iBurst,:,iDim3) = gmean(cleandata);
                            end
                        end
                        if ~isempty(sStdvar),
                            cdfs{sStdvar}(iBurst,:,iDim3) = gstd(cleandata);
                        end
                    end
                end
            end
        end % if ~isempty(iBurst)
    end % for n = 1:length(burstNums)
end

% now update the stats that are used for flagbadadv
% this is for adv data only, so first make sure we have that stuff in the
% quality file
if ~isempty(cdfq{'flagbadadv_stdv'}) && ~isempty(cdfq{'flagbadadv_mcor'}),
    disp('Updating statistics used by flagbadadv')
    % make up our indeces for stepping through the subbursts.
    % account of uneven divisibility of number of subbursts into the actual
    % number of samples... get as many complete blocks as possible then do
    % the last one no matter how small it is
    nSamples = cdfb.ADVDeploymentSetupSamplesPerBurst(1);
    nSubbursts = length(cdfq('subburst'));
    nSubsamp = floor(nSamples/nSubbursts)
    indSubb(:,1) = [1:nSubsamp:nSamples]'; % starting indeces for each subburst
    if rem(nSamples, nSubbursts),
        indSubb(:,2) = [nSubsamp:nSubsamp:(nSubsamp*nSubbursts)+nSubsamp]'; % starting indeces for each subburst
    else
        indSubb(:,2) = [nSubsamp:nSubsamp:nSamples]'; % starting indeces for each subburst
    end
    indSubb = indSubb(1:nSubbursts,:);
    for n = 1:length(burstNums),
        % find the netCDF index to the Sontek burst number
        iBurst = find(burstNums_in_file == burstNums(n), 1, 'first');
        if isempty(iBurst), disp(sprintf('Sontek burst #%d not found in file', burstNums(n)))
        else
            velx = cdfb{'Velx'}(iBurst,:);
            vely = cdfb{'Vely'}(iBurst,:);
            velz = cdfb{'Velz'}(iBurst,:);
            corr = cdfb{'cor'}(iBurst,:,:); % [burst, sample, axis]
            cdfq{'flagbadadv_stdv'}(iBurst,1,:) = gstd(reshape(velx(indSubb(1,1):indSubb(end,2)),nSubsamp,nSubbursts));
            cdfq{'flagbadadv_stdv'}(iBurst,2,:) = gstd(reshape(vely(indSubb(1,1):indSubb(end,2)),nSubsamp,nSubbursts));
            cdfq{'flagbadadv_stdv'}(iBurst,3,:) = gstd(reshape(velz(indSubb(1,1):indSubb(end,2)),nSubsamp,nSubbursts));
            cdfq{'flagbadadv_mcor'}(iBurst,1,:) = gmean(reshape(corr(indSubb(1,1):indSubb(end,2),1),nSubsamp,nSubbursts));
            cdfq{'flagbadadv_mcor'}(iBurst,2,:) = gmean(reshape(corr(indSubb(1,1):indSubb(end,2),2),nSubsamp,nSubbursts));
            cdfq{'flagbadadv_mcor'}(iBurst,3,:) = gmean(reshape(corr(indSubb(1,1):indSubb(end,2),3),nSubsamp,nSubbursts));
            if ~isempty(cdfb{'extpress'}),
                cdfq{'flagbadadv_stdp'}(iBurst) = gstd(cdfb{'extpress'}(iBurst,:));
            elseif ~isempty(cdfb{'extpressfreq'}),
                cdfq{'flagbadadv_stdp'}(iBurst) = gstd(cdfb{'extpressfreq'}(iBurst,:));
            elseif ~isempty(cdfb{'pressure'}),
                cdfq{'flagbadadv_stdp'}(iBurst) = gstd(cdfb{'pressure'}(iBurst,:));
            end
        end
    end
end


opstring = [];
for iOp = 1:length(opname),
    opstring = [opstring, ' ', opname{iOp}]; 
end

if (findstr(opstring,'cor'))
    vvv=settings.locorr;
    ops='locorr';
elseif (findstr(opstring,'clip'))
    % clip has a default of using NaN, if no settings.rvalue entered
    if ~isfield('rvalue',settings), settings.rvalue = NaN; end
    vvv=settings.rvalue;
    ops='rvalue';
else         % thumbfinger or deglitch1vector
    vvv=settings.nsd;
    ops='nsd';
end
    
hstring = cdfs.history(:);
cdfs.history = sprintf('%s; %s %s applied %s with %s = %f',...
    hstring, mfilename, mversion, opstring, ops, vvv);
close(cdfs);
hstring = cdfb.history(:);
cdfb.history = sprintf('%s; %s %s applied %s with %s = %f',...
    hstring, mfilename, mversion, opstring, ops, vvv);
close(cdfb);
hstring = cdfq.history(:);
cdfq.history = sprintf('%s; %s %s applied %s with %s = %f',...
    hstring, mfilename, mversion, opstring, ops, vvv);
close(cdfq);
disp(sprintf('Finished fixing bursts in %f min',toc/60))

return

function cdfq = define_newqfile(cdfqFile, cdfb, cdfs)

cdfq=netcdf(cdfQile,'clobber');
cdfq.CREATION_DATE = datestr(now);
cdfq.DESCRIPT = 'Sontek ADV raw data quality file';
cdfq.COORD_SYSTEM = ncchar('NONE');
cdfq.DATA_TYPE = ncchar('TIME');

% copy dimensions to the quality file
cdfq < cdfb('burst');
cdfq < cdfb('axis');

% copy these variables
cdfq < cdfs{'burst'};
cdfq < cdfs{'time'};
cdfq < cdfs{'time2'};

return   
