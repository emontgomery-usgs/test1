function [minens, maxens, nens, trimFile] = goodends(theBeamFile,theMaskFile,trimFile,settings)

%function [minens, maxens, nens, trimFile] = goodends(theBeamFile,theMaskFile,trimFile,settings)
%Make an educated guess at the first good ensemble and the last good.
%This function performs a series of checks at the ends of the record:
%		1. If the number of good bins is greater than 75%
%		2. If the pitch and roll vary by less than 2 degrees
%		3. Based on the above criteria there are four possible asnwers,
%			one for each of the four beams.  AS a last check see if one of those
%			answers also matches the recovery and deployment dates.
%
%Input:
%	theBeamFile = the masked netcdf data file in beam coordinates
%	theMaskFile = the mask used to screen the data (*.msk),
%						**must be the same dimensions as theBeamFile
%	trimFile = the shortened file to be produced by cutting
%		at the beginning and end of the ensemble record
%   settings.stop_date = end date to trumcate file
%
%Outputs:
%	minens = minimum ensemble 
%	trimFile = the shortened file to be produced by cutting
%		at the beginning and end of the ensemble record


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

 
%Requires additional functions
%	Netcdf toolbox (including nctrim)
%	The following RPS stuff (written by R. Signell)
%		gregorian.m
%		julian.m

% Written by Jessica M. Cote
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to jcote@usgs.gov
%
%
% Updated 18-jun-2008 (MM) change to SVN revision info
% updated 11-jan-2008 (MM) clean up some mlint, replace a switch statement
% that was causing trimming in the wrong place.
% updated 13-sep-2007 (MM) catch a bug if script operation omits a stop_date
% updated 3-may-2007 (MM) improve detection of recovery and deployemnt
% using features of find.m that didn't exist when this was first written,
% provide an override method during batch for recovery date dialog box
% updated 31-jan-2007 (MM) remove batch calls
%version 1.0
% updated 06-Sep-2005 (SDR) added lines to calculate start_time in cases
%       where start_time was not established in deployment ensemble calculation,
%       but is needed in recovery ensemble calculation
% updated 05-Feb-2003 (ALR) correct comma separator error in versions 6.2 and higher
% updated 21-Sep-2001 - revised trimming of out of water data for Earth and added
%       more comments to explain the code (ALR)
% updated 28-Dec-2000 08:53:22 - added line feeds to history attribute (ALR)
% updated 27-Dec-2000 14:50:19 - trims recovery time/date more accurately for all data (ALR)
% updated 19-Dec-2000 12:36:57 - trims Earth data more accurately (ALR)
% updated 30-Jun-2000 11:11:50 - better for Earth
% updated 13-Jun-2000 10:53:45
% updated 02-Feb-2000 09:34:12 - runs batch
% updated 12-Jan-2000 09:38:01 - create catch for out of range dates
% updated 15-Oct-1999 09:31:48

ncquiet

% get the current SVN version- the value is automatically obtained in svn
% is the file's svn.keywords which is set to "Revision"
rev_info = 'SVN $Revision: 1063 $';
disp(sprintf('%s %s running',mfilename,rev_info))

if nargin < 1, help(mfilename), end
if nargin< 1, theBeamFile = ''; end
if nargin < 2, theMaskFile = ''; end
if nargin < 3, trimFile = ''; end
if nargin < 4, settings.stop_date = []; end

if isempty(theBeamFile), theBeamFile = '*'; end
if isempty(theMaskFile), theMaskFile = '*'; end
if isempty(trimFile), trimFile = '*'; end

% Get ADCP Beam filename.
if any(theBeamFile == '*') || ~exist(theBeamFile,'file')
    [theFile, thePath] = uigetfile(theBeamFile, 'Select ADCP Netcdf File:');
    if ~any(theFile), return, end

    if thePath(end) ~= filesep, thePath(end+1) = filesep; end
    theBeamFile = [thePath theFile];
end
g=netcdf(theBeamFile,'nowrite');

[path,name]=fileparts(theBeamFile);
suggest=[name(1:end-1) 'T.cdf'];


% Get trimmed ADCP filename.
if any(trimFile == '*')
    [theFile, thePath] = uiputfile(suggest, 'Save the Trimmed ADCP File As:');
    if ~any(theFile), return, end
    if thePath(end) ~= filesep, thePath(end+1) = filesep; end
    trimFile = [thePath theFile];
end

%get some information from the data file
dbin=g('bin');
nbins=dbin(:);
ens = g('ensemble');
nens = ens(:);
%if only 1 ensemble skip to end
if nens <= 2
    disp('ensemble trimming was skipped due to insufficient ensembles')
    if isunix
        eval(['!cp  ' theBeamFile ' ' trimFile])
    elseif any(findstr(lower(computer), 'pcwin')) || isVMS
        eval(['!copy  ' theBeamFile ' ' trimFile])
    elseif any(findstr(lower(computer), 'mac')) && ...
            exist('aduplicate','var')
        feval('aduplicate', theBeamFile, trimFile)
    else
        fcopy(theBeamFile, trimFile)
    end

    thecomment=sprintf('No ensembles were trimmed by %s %s\n',...
        mfilename, rev_info);
    history(trimFile,thecomment);

    %the required outputs
    minens = nens(1);
    maxens = nens(end);
    return
end

coord = g.transform (:);

time=g{'TIM'}(:);
%get recovery and deployment dates and find ensemble where this occurs
ddate=g.Deployment_date(:);
if ~isempty(ddate)
    jr = julian(datevec(ddate));
    ddens = find(time >= jr,1,'first');
    if isempty(ddens)
        ddens = 1;
    end
else
    ddens = 1;
end

rdate=g.Recovery_date(:);
if ~isempty(rdate)
    jr = julian(datevec(rdate));
    rdens = find(time >= jr,1,'first');
    if isempty(rdens)
        rdens = nens;
    end
else
    rdens = nens;
end


% The section below checks the data for bad velocites in order to find the first good ensemble when the ADCP was
%   actually in the water, and the last good ensemble when the ADCP was taken out of the water.
% It checks 'Beam' data in the first portion, and 'Earth' data in the second portion.
% See each section on how the checking procedure works.

% The Beam data have a mask file which will be used for the check of 'in-the-water-data'
switch coord
    case 'BEAM'

        % Get ADCP Mask filename
        if any(theMaskFile == '*') || ~exist(theMaskFile,'file')
            [theFile, thePath] = uigetfile(theMaskFile, 'Select ADCP Mask File:');
            if ~any(theFile), return, end

            if thePath(end) ~= filesep, thePath(end+1) = filesep; end
            theMaskFile = [thePath theFile];
        end
        f=netcdf(theMaskFile,'nowrite');

        % Pulls out the masked velocity beam data into 4 cell arrays, one for each beam
        vmask = cell(4);
        for k = 1:4
            vmask{k} = f{['vel' int2str(k)]};
        end

        CHUNK=100;  % For use below, to break up processing into 'chunks' of 100 for easier/quicker processing
        inens=ones(4,1);    % For use below, to store the first good ensemble for each beam
        oxens=ones(4,1);    % For use below, to store the last good ensemble for each beam

        % Creates an ncvariable 'p' for each cell array of masked beam data
        for k = 1:4;
            theVarname = ['vel' int2str(k)];
            disp([' checking ' theVarname ' ...']);
            p = vmask{k};  % new ncvariable for each masked beam data
            m= size(p,1);  % size of each beam (i.e. number of ensembles)
            m=m(1);
            i = 0;
            t=zeros(m,1);  % temp array of zeros for good/bad data flags for each beam and ensemble to be stored

            % Below checks velocity data for bad ensembles by checking the maksed data for ones (bad) and zeros (good).
            % Then sums each column of beam data and if the sum is greater than 25% of the total number of depth bins
            %     the beam for that ensemble is marked with a '1' to designate a bad ensemble for that beam.
            % For example, the column has a length of 20 (meaning 20 depth bins), and the sum for the column is 10, meaning
            %     that 10 bins were bad velocities, than the Beam data for that ensemble would be marked bad.
            % This check is done in 100 ensemble increments for easier/quicker processing
            while i < m
                j = i+1:min(i+CHUNK,nens); % Check data in 'chunks' of 100 ensembles
                q=t(j,:);
                s = sum(p(j,:),2);  % Sums the column of masked data
                bad = s > 0.25*nbins;	% if # of bad bins is greater than 25%, it is marked with a '1' for 'bad'
                q =  q | bad;
                t(j,:)= q;    % Fills in the temp array with flags for 'good' and 'bad' data
                i = i + CHUNK;
            end

            id=find(t==0);  % Finds the good velocity data for each beam, for each ensemble
            if isempty(id)
                id = NaN;
            end

            % The first/last good ensemble of velocity data (inens/oxens) for each beam is saved here
            inens(k,:)=id(1);
            oxens(k,:)=id(end);

        end	%for k=1:4 loop

        % Will give conservative estimates for the min and max ensembles using the first/last good ensembles of velocity
        %  data found for each beam above
        minens=min(inens);   % First good ensemble to use
        maxens=max(oxens);   % Last good ensemble to use
        disp(['Based on the # of good bins, ' num2str(minens) ' is the first good ensemble']);
        disp(['and ' num2str(maxens) ' is the last good, out of ' num2str(nens) ' total ensembles'])
        disp(['from the file ' theMaskFile]);
        disp(' ')
        close(f)

        % Now check if Earth coordinates are used.
        % Earth coordinates will not have a masked file.
    case 'EARTH'
        v = cell(4);
        for k = 1:4
            v{k} = g{['vel' int2str(k)]};  % Pulls out the velocity data and puts into cell array
        end


        CHUNK = 100;     % For use below, to break up processing into 'chunks' of 100 for easier/quicker processing
        inens = ones(4,1);   % For use below, to store the first good ensemble for each beam
        oxens = ones(4,1);   % For use below, to store the last good ensemble for each beam

        for k = 1:4
            theVarname = ['vel' int2str(k)];   % Pulls out each beam of velocity data
            disp([' checking ' theVarname '...']);
            p = v{k};  % Creates new ncvariable for each beam of data
            m = size(p,1);  % Finds length of ncvariable (i.e. ensemble length)
            m = m(1);
            i = 0;
            t = zeros(m,1);  % Creates a temp array of zeros for good/bad data flags for each beam and ensemble to be stored
            fV = fillval(p);  %Finds the fill value for velocity data

            % Below checks velocity data for bad ensembles by seeing if more than 25% of the bins are fill values.
            % A sum of each beam data for each ensemble (each column) is computed.
            % A 'bad' value is found by finding what the value would be if 25% of the bins were fill values.
            % If the sum of the beam data for an ensemble is greater than the 'bad' value, it is marked 'bad'.
            % For example, if the column has a length of 92 (meaning 92 depth bins), 25% of the column has fill values, or
            %     the 'bad' value, would be 2.3000e+36.
            % If the sum of the column exceeded 2.300e+36, than the column would be marked bad.
            % This check is done in 100 ensemble increments for easier/quicker processing
            while i < m
                j = i+1:min(i+CHUNK,nens);  % Check data in 'chunks' of 100 ensembles
                q = t(j,:);
                s = sum(p(j,:),2);  % Sums the column of beam
                bad = s > (fV * nbins) * 0.25;  % if # of bins with fill values is greater than 25, marks with '1'
                q = q | bad;
                t(j,:) = q;  % Fills in the temp array with flags for 'good' and 'bad' data
                i = i + CHUNK;
            end

            id = find(t==0);  % Finds the good velocity data for each beam, for each ensemble

            if isempty(id)
                id = nan;
            end

            % The first/last good ensemble of velocity data (inens/oxens) for each beam is saved here
            inens(k,:) = id(1);
            oxens(k,:) = id(end);
        end  %for k=1:4 loop

        % Will give conservative estimates for the min and max ensembles using the first/last good ensembles of velocity
        %  data found for each beam above
        minens = min(inens);      % First good ensemble to use
        maxens = max(oxens);      % Last good ensemble to use
        disp(['Based on the # of good bins, ' num2str(minens) ' is the first good ensemble']);
        disp(['and ' num2str(maxens) ' is the last good ensemble, out of ' num2str(nens) ' total ensembles'])
        disp(['from the file ' theBeamFile]);
        disp(' ')
end     %for case loop

%now let's check based on tilt
pitch=g{'Ptch'}(:);
pitch=pitch(minens:maxens);
roll=g{'Roll'}(:);
roll=roll(minens:maxens);
tnens=length(pitch);

dP=diff(pitch);
dr=diff(roll);

%look for pitch and roll that vary by less than 2 degrees
idP=find(abs(dP) < 2 & abs(dr) < 2);

if isempty(idP)
    minp = 1;
elseif isequal(idP(1),1) && ~isequal(idP(2),2)
    minp = idP(2);
else
    minp = idP(1);
end


if idP(end) >= tnens
    maxp=tnens;
elseif idP(end) < maxens
    maxp=idP(end);
else
    maxp=NaN;
end

minens=minens+minp-1;
lastEnsI = maxens;
maxens=maxp;
disp(['Based on pitch and roll, ' num2str(minens) ' is the first good ensemble']);
disp(['and ' num2str(maxens) ' is the last good, out of ' num2str(nens) ' total ensembles'])
disp(['in file ' theBeamFile])
disp(' ')


%Needs recently created Netcdf file to run
%some attributes may not be available in older files
%let's check these results by getting time in gregorian
gtD=gregorian(time(minens));
minT=datestr(datenum(gtD(1),gtD(2),gtD(3)),1);
gtR=gregorian(time(maxens));
maxT=datestr(datenum(gtR(1),gtR(2),gtR(3)),1);
disp(sprintf('minT = %s, maxT = %s',minT,maxT))
lastEnsT = maxT;

if ~isempty([ddate,rdate]);
    % If these are not deployment or recovery dates check the less conservative min and maxes
    if ~isequal(datenum(minT),datenum(ddate))
        for ii=2:4;
            inens=sort(inens);
            NgtD=gregorian(time(inens(ii)));
            NminT=datestr(datenum(NgtD(1),NgtD(2),NgtD(3)),1);

            if isequal(datenum(minT),datenum(ddate))
                disp(['The first good ensemble' num2str(minens) ' recorded on ' num2str(minT)])
                disp('based on number of good bins, roll, and pitch matches the deployment date ')
                minens=inens(ii);
                minT=NminT;
                break

            elseif isequal(ii,4)
                disp('The first good ensemble was chosen based on deployment date')
                if ~isempty(ddens)
                    minens = ddens;
                end
                minT = ddate;
                %else
                %  disp('Could not match deployment date')
            end
        end %for ii
    end
    disp(' ')
    disp(['The first good ensemble occurs at ' minT])
    disp(['and the recorded deployment date is ' ddate]);

    if ~isequal(datenum(maxT),datenum(rdate))
        for ii=1:3;
            oxens=sort(oxens);
            NgtR=gregorian(time(oxens(ii)));
            NmaxT=datestr(datenum(NgtR(1),NgtR(2),NgtR(3)),1);

            if isequal(datenum(NmaxT),datenum(rdate))
                disp(sprintf('The last good ensemble was chosen based on recovery date %s',rdate))
                disp(['Number of good bins, roll, and pitch gave ensemble ' num2str(minens) ' recorded on ' minT])
                maxens=oxens(ii);
                maxT=NmaxT;
                break
                %else
                %  disp('Could not match recovery date')
            end
        end
    else
        disp(['The last good ensemble is same as recovery date, ' maxT]);
    end

    % first, see if the user has given a preferred override
    if isfield(settings, 'stop_date') && ~isempty(settings.stop_date),
        % see if there's a reasonable stop date given
        jr = julian(datevec(settings.stop_date));
        if jr > time(end), 
            maxens = nens(end); 
        else
            maxens = find(time >= jr,1,'first');
        end
        if ~isempty(maxens),
            disp(['User has specified a useable stop date of ', settings.stop_date])
        end
    else
        maxens = [];
    end

    if isempty(maxens),
        if ~isequal(lower(maxT),lower(rdate)), % ask user with dates in a GUI

            disp('End date unclear, ask user')
            str = {[maxT ' For Tilt'],[rdate ' Recovery'],[lastEnsT ' All Data']};
            % TODO - why are these modal dialog boxes causing problems?
            %[selection,ok] = listdlg('PromptString',{'Select a date:'},...
            %    'SelectionMode','single', 'ListString',str);
            %if ~ok, % user pressed cancel
            %    disp('Goodends: User aborted in choosing end dates')
            %    minens = []; maxens = [];
            %    return
            %end
            selection = menu('Select an end date:',...
                str{1}, str{2}, str{3});
            goodinfo = str{selection};
 
            if findstr(goodinfo,'Tilt'),
                jr = julian(datevec(maxT));
                maxens = find(time >= jr,1,'first');
                disp(['The last good ensemble occurs at ' maxT])
                disp(['and the recorded recovery date is ' rdate]);
            elseif findstr(goodinfo,'Recovery'),
                if ~isempty(rdens), 
                    maxens = rdens;
                end
                disp(['The recorded recovery date ' rdate])
                disp('was used to determine the last good ensemble')
            elseif findstr(goodinfo,'All'),
                maxens = lastEnsI;
                disp(['All data through ' lastEnsT ' will be kept'])
            else
                disp('invalid recovery date')
            end
            
            % TODO make sure that the selected end time is not past the end of the file
            
        else % max tilt date = recovery date, this is the last good ensemble
            jr = julian(datevec(maxT));
            maxens = find(time >= jr,1,'first');
        end
    end
end
close(g)

%let's cut down the record based on the minens and maxens given
if ~isequal(1,minens) || ~isequal(maxens,nens)
    disp(['Trimming file from ensemble ' num2str(minens) ' to ' num2str(maxens)]);
    nctrim(theBeamFile, trimFile, (minens:maxens), 'ensemble','isVerbose');

    thecomment=sprintf('Ensembles recorded pre and post deployment were trimmed by %s %s\n',...
        mfilename, rev_info);
    history(trimFile,thecomment);
else
    disp('no trimming was required')
    if isunix
        eval(['!cp  ' theBeamFile ' ' trimFile])
    elseif any(findstr(lower(computer), 'pcwin')) || isVMS
        eval(['!copy  ' theBeamFile ' ' trimFile])
    elseif any(findstr(lower(computer), 'mac')) && ...
            exist('aduplicate','var'),
        feval('aduplicate', theBeamFile, trimFile)
    else
        fcopy(theBeamFile, trimFile)
    end

    thecomment=sprintf('No ensembles were trimmed by %s %s;\n',...
        mfilename, rev_info);
    history(trimFile,thecomment);
end

ncclose
