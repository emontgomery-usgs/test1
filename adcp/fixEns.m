function [nMissEns] = fixEns(rawcdf,theFilledFile)

% function  missing = fixEns(rawcdf, theFilledFile)
% Checks for missing ensembles in the ADCP data and places place holders with
% fill values for any missing ensembles in the netCDF files
% If only rawcdf is specified, then only checks for missing ensembles
%
% INPUTS:
%       rawcdf = the raw netCDF file created by rdi2cdf.m
%       theFilledFile = the name of the file created if missing ensembles are found and filled
%
% OUTPUTS:
%       nMissENs = the number of missing ensembles found
%

% Written by Andree L. Ramsey
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to aramsey@usgs.gov
%
% Updated 18-jun-2008 (MM) change to SVN revision info
% updated 25-feb-2008 (MM) to remove hardwired variable names to accommodate
% future toolbox modifications, I am looking for data to test this.
% updated 22-dec-2006 to work around a subsref problem win copy with multidimensional vars
% updated 21-Sep-2005 to correct for ensemble number resets (see GV 9/20/05)for places of changes
% updated 10-Jan-2003 (ALR) added ability to run without having to give inputs names and added information
%   to the description
% updated 20-Sep-2001 (ALR) to run on PC and to print missing ensemble numbers to history attribute
% Version 2.0 updated by Marinna Martini
% Version 1.1
% changed to look for PD12 data and act appropriately, 7/12/01 Marinna Martini
% updated 28-Dec-2000 09:27:25 - added linefeed to comment/history attribute (ALR)
% updated 15-Dec-2000 - adjusted so will work whether height variable exists or not
% Beta version 06-Dec-2000 - created


%%% START USGS BOILERPLATE -------------%
% Use of this program is described in:
%
% Acoustic Doppler Current Profiler Data Processing System Manual 
% Jessica M. Côté, Frances A. Hotchkiss, Marinna Martini, Charles R. Denham
% Revisions by: Andrée L. Ramsey, Stephen Ruane
% U.S. Geological Survey Open File Report 00-458 
% Check for later versions of this Open-File, it is a living document.
%
% Program written in Matlab v7.1.0 SP3
% Program updated in Matlab 7.2.0.232 (R2006a)
% Program ran on PC with Windows XP Professional OS.
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%
%%% END USGS BOILERPLATE --------------

% get the current SVN version- the value is automatically obtained in svn
% is the file's svn.keywords which is set to "Revision"
rev_info = 'SVN $Revision: 1063 $';
disp(sprintf('%s %s running',mfilename,rev_info))

if nargin < 1, rawcdf = ''; end
if nargin < 2, theFilledFile = ''; end

if isempty(rawcdf), rawcdf = '*'; end
if isempty(theFilledFile), theFilledFile = '*'; end

% Get ADCP filename.
if any(rawcdf == '*')
	[theFile, thePath] = uigetfile(rawcdf, 'Select Netcdf ADCP File:');
	if ~any(theFile), return, end
	if thePath(end) ~= filesep, thePath(end+1) = filesep; end
	rawcdf = [thePath theFile];
end
%
%Before First step is to determine if we have any resets in ensemble numbers
% Start of update ------------------ GV 9/20/05 --------------
a=netcdf(rawcdf);
Rec=a{'Rec'}(:);
RRec=Rec;
DifRec=diff(Rec);
ineg=find(DifRec<0);
if isempty(ineg)==0;
    noResets=length(ineg);
    disp(['Rats...there are ',num2str(noResets),' resets in ensemble numbering!! :) :) '])
    for ijk=1:noResets
        RRec(ineg(ijk)+1:end)=RRec(ineg(ijk)+1:end)+Rec(ineg(ijk));
    end
end
nRec=length(Rec);
%First step is to determine if there are any missing ensemble numbers
%a=netcdf(rawcdf);
%Rec=a{'Rec'}(:);
%nRec=length(Rec);
%firstRec=Rec(1);
%lastRec=Rec(end);
firstRec=RRec(1);
lastRec=RRec(end);
%
% ---------------- End of this segment of update  GV 9/20/05
% ---------------
%
if lastRec<=firstRec
   ncclose
   error('The LAST RECORD # is smaller than the FIRST RECORD #, Problem with the file!! ')
   %return
end
%
nEns=lastRec-(firstRec-1); % why is 1 subtracted here?
nMissEns=nEns-nRec;
if nMissEns == 0,
   disp('Yippie...there are no missing ensembles!! :) :) :) :) :) :) :) ')
   ncclose
   return
end

disp(sprintf('Rats...there are %d missing ensemble',nMissEns))
disp('')
disp('FixEns.m will place fill values in for missing ensemble numbers')
disp('This may take a while')

% detect PD12 data.  This is important because PD12 does not contain all variables
PD12=0;
data_subtype = a.DATA_SUBTYPE(:);
if ~isempty(data_subtype),
    disp([mfilename,': data type = ',data_subtype])
    if findstr(data_subtype, 'PD12'), 
        disp([mfilename,': trapping for PD12 data']);
        PD12=1;
    end
end

% reconstruct the time and record indeces
oldTIM = a{'TIM'}(:);
newRec = firstRec:lastRec;
%newTIM = interp1(Rec, oldTIM, newRec); --------------GV 9/20/05
newTIM = interp1(RRec, oldTIM, newRec);

disp(['Size of oldRec = ',int2str(length(Rec))])
disp(['Size of newRec = ',int2str(length(newRec))])

% make a map to where the gaps were for padding later
gapmask = zeros(nEns, 1);  % make an array as long as the number of ensembles that should be present
%goodidx = Rec-firstRec+1;   % an index into this array for the ensembles received -------GV 9/20/05 -
goodidx = RRec-firstRec+1;
gapmask(goodidx) = ones(length(goodidx),1); % set those array positions to TRUE
MissEnsNos = find(gapmask == 0);
% now newRec(gapmask) should be equal to oldRec

fillV=fillval(a{'D'});  % what we will pad the missing ensembles with

% now, create a new, expanded netCDF file
c = netcdf(theFilledFile,'clobber');
% write new, expanded dimensions
c('ensemble') = nEns;   % this expands to the number of ensembles there SHOULD be
c('bin') = ncsize(a('bin'));
% copy the global attributes
c < att(a);
% copy the variables, this moves the definitions and attributes to the new file, 
% but the data are now out of sequence
%c < var(a);
% the statement above was crashing, try to figure it out MM 22-dec-2006
varObjs = var(a);
for ivar = 1:length(varObjs),
    varname = char(ncnames(varObjs{ivar}));
    disp(sprintf('copying %s',varname))
    %copy(varObjs{ivar}, c, 1, 1);
    % the above worked until vel1 was hit - it's a problem with the shape
    copy(varObjs{ivar}, c, 0, 1); % don't copy data yet, just define & atts
    % now copy data - special attention to one and two dimensions
    data = a{varname}(:);
    [nrows,ncols]=size(data);
    if ncols == 1,
        c{varname}(1:length(data)) = a{varname}(:);
    else
        c{varname}(1:nrows,1:ncols) = data;
    end
end

% now must fill in the data itself while accounting for the new gaps
% TIM and Rec are already fixed
c{'TIM'}(:)=newTIM;
c{'Rec'}(:)=newRec; 
% now fix data that's present in all ADCP file type
% sort the 1D and 2D variables out
n2d=1;
n1d=1;
twoDflag = 0;
varnames = ncnames(var(a));
for ivar=1:length(varnames), % skip some variables
    if ~strcmp(varnames{ivar},'D') && ~strcmp(varnames{ivar},'bin'),
        dimnames = ncnames(dim(a{varnames{ivar}})); % check dimensions
        for idim = 1:length(dimnames),
            if strcmp(dimnames{idim},'bin'),
                twoDflag = 1;
            end
        end
        if twoDflag,
            twoDvars{n2d} = varnames{ivar};
            n2d=n2d+1;
        else
            oneDvars{n1d} = varnames{ivar};
            n1d=n1d+1;
        end
        twoDflag = 0;
    end
end
if 1,
    % 1D variables first
    %     datatypes = {'Hdg'; 'Ptch'; 'Roll'; 'Tx'; 'height'; 'sv'; 'xmitc'; 'xmitv'; 'dac';...
    %         'VDD3'; 'VDD1'; 'VDC'; 'brange'; 'HdgSTD'; 'PtchSTD'; 'RollSTD';...
    %         'EWD1'; 'EWD2'; 'EWD3'; 'EWD4'; 'Pressure'; 'PressVar','ensemble'};
    % note that D is not listed here... it does not need to be fixed
    datatypes = oneDvars;
    for i=1:length(datatypes),
        disp(['Fixing ',datatypes{i}])
        if ~isempty(c{datatypes{i}}), % if they exist in this file.  Thus traps for variables missing from PD12 data
            newData = ones(length(newRec),1).*fillV;
            newData(goodidx) = a{datatypes{i}}(:); % fill in the good data
            c{datatypes{i}}(:) = newData;
        end
    end
    % now 2D variables
    % datatypes = {'vel1'; 'vel2'; 'vel3'; 'vel4'};
    % must do it this way for 2D variables.  For some reason, if c{datatypes{i}} doesn't work here
    %     if ~PD12,
    %         datatypes = {'vel1'; 'vel2'; 'vel3'; 'vel4'; 'cor1'; 'cor2'; 'cor3'; 'cor4';...
    %             'AGC1'; 'AGC2'; 'AGC3'; 'AGC4'; 'PGd1'; 'PGd2'; 'PGd3'; 'PGd4'};
    %     end
    datatypes = twoDvars;
    nbins = length(c{'D'}(:));
    for i=1:length(datatypes),
        disp(datatypes{i})
        newData = ones(length(newRec),nbins).*fillV;
        newData(goodidx,:) = a{datatypes{i}}(:,:); % fill in the good data
        c{datatypes{i}}(:,:) = newData;
    end
end

disp('Fill values have been filled in as place holders for missing ensemble numbers')

ncclose

%Last, need a commnet in the history field
thecomment1=sprintf...
   ('The missing ensemble numbers that were filled with fill values using %s %s were: \n',...
   mfilename, ver_info);
thecomment2=(sprintf(' %d;',MissEnsNos));
thecomment3=(sprintf('%s\n',''));   %A line feed to separate the previous comment
thecomment=[thecomment1 thecomment2 thecomment3];
history(theFilledFile,thecomment);





