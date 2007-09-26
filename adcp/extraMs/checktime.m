function checktime(cdfFile,TE, verbose)
%checktime - perform basic checks on ADCP time base
% function checktime(cdfFile,TE, verbose)
% where
%   cdfFile = raw netCDF data file with TIM AS time variable
%               or a processed netCDF data file with time and time2
%   TE = time between ensemble setting, in seconds
%   verbose = 0 to suppress plots
%


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

 
% Written by Marinna Martini, USGS Woods Hole Science Center
% 19-jan-2006

% check raw convert ADCP data for time slips
if ~exist('cdfFile','var') && ~exist(cdfFile,'file'),
    [theFile, thePath] = uigetfile('*.cdf','*.cdf, ADCP raw netCDF data',...
        'Select raw netCDF ADCP File:');
    cdfFile = fullfile(thePath, theFile);
    if isempty(cdfFile), return, end
end
if ~exist('verbose','var'),
    verbose = 1; % we want plots
end

cdf = netcdf(cdfFile);
if isempty(cdf), return, end

% which one have we got?
if ~isempty(cdf{'TIM'}),
    tj = cdf{'TIM'}(:);
    tm = datenum(gregorian(tj));
    rec = cdf{'Rec'}(:);
    dtj = diff(tj);
    dtm = diff(tm).*(24*3600);
    nens = length(tj);
    lagBook = cdf{'TIM'}.slow_by(:); % seconds
    inan = find(isnan(tj));

    if ~exist('TE','var'),
        prompt='Enter the time between ensembles in sec (TE command setting):';
        name='Input for checktime';
        numlines=1;
        defaultanswer={sprintf('%6.2f',gmean(dtj))};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        TE = str2double(char(answer));
    end

    disp('ADCP time stamp evaluation')
    disp(sprintf('   There are %d NaNs in the variable TIM',length(inan)))
    disp(sprintf('   ADCP start time is %s at ensemble #%d', datestr(tm(1),0),rec(1)))
    disp(sprintf('   ADCP end time is %s at ensemble #%d', datestr(tm(end),0), rec(end)))
    disp(sprintf('   ADCP mean time between ensembles is %f sec', gmean(dtj).*(24*3600)))
    if lagBook > 0, buf = 'slow'; else buf = 'fast'; end
    disp(sprintf('   Instrument log indicates ADCP was %s by %f sec',buf, lagBook))
    disp('Checking clock drift by elapsed ADCP clock vs predicted')
    elapsedADCP = (tm(end)-tm(1)).*(24*3600); % number of seconds in the deployment
    elapsedWall = nens*TE; % number of seconds in the deployment
    disp(sprintf('   Elapsed real time = %f sec', elapsedWall))
    disp(sprintf('   Elapsed ADCP time = %f sec', elapsedADCP))
    disp(sprintf('   Elapsed real-ADCP time = %f sec', elapsedWall - elapsedADCP))
    disp(sprintf('   ADCP end time is %s at ensemble #%d', datestr(tm(end),0), rec(end)))
    predEnd = tm(1)+elapsedWall./(24*3600);
    disp(sprintf('   Predicted end time is %s for %d ensembles', datestr(predEnd,0), nens))
    lagStamps = ((tm(end)-predEnd).*(24*3600)); % lag determined by time stamps
    if lagStamps > 0, buf = 'late'; else buf = 'early'; end
    disp(sprintf('   Last ADCP ensemble was %s by %f sec', buf,abs(lagStamps)))
    disp(sprintf('   Instrument log indicates ADCP was slow by %f sec', lagBook))
    tolerance = 60/4; % number of seconds per month we'll tolerate being off,
    % typical is 1 min per 4 month deployment
    if abs(lagStamps-lagBook) < tolerance,
        disp(sprintf('ADCP ending time stamps are within an error tolerance of %f sec per month',...
            tolerance));
    else
        disp('Looking for time issues')
        ngreater = length(find(abs(dtm) > TE));
        disp(sprintf('   %d ensembles or %5.2f%% of intervals are greater than %d sec',...
            ngreater, (ngreater/nens)*100, TE));
        nless = length(find(abs(dtm) < TE));
        disp(sprintf('   %d ensembles or %5.2f%% of intervals are less than %d sec',...
            nless, (nless/nens)*100, TE));
    end
    if verbose,
        hist(dtm);
        ylabel('ensembles')
        xlabel(sprintf('seconds, TE = %d, axis limits are min & max of data',TE))
        title(sprintf('Histogram time between ensembles for %s',cdfFile))
    end
elseif ~isempty(cdf{'time'}) & ~isempty(cdf{'time2'}),
    tj = cdf{'time'}(:)+cdf{'time2'}(:)./(24*3600*1000);
    tm = datenum(gregorian(tj));
    dtj = diff(tj);
    dtm = diff(tm).*(24*3600);
    nens = length(tj);
    dt = cdf.DELTA_T(:);
    inan = find(isnan(tj));

    disp('ADCP time stamp evaluation')
    disp(sprintf('   There are %d NaNs in the variable time',length(inan)))
    if verbose & (length(inan)>0),
        plot(tm(inan),ones(size(inan)),'x');
        datetick('x')
        ylabel('NaNs')
        title(sprintf('Location of NaNs in %s',cdfFile))
    end
else
    disp('This file has an unrecognizeable time base')
end
close(cdf)
