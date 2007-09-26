function fixmetadata(filename, settings)

%function fimetadata(filename, settings)
%fixes certain metada attributes 'experiment', 'project', 'description' in
%a user friendly way
%
%filename = name of netcdf file
% also can provide metadata as the following struct fields
% settings.experiment
% settings.project
% settings.descript
% settings.cmt
% settings.long
% settings.lonUnits
% settings.latit
% settings.latUnits


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

 
%
%
% Written by Stephen Ruane
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to sruane@usgs.gov

% 04-jan-2007 (MM) add struct input

h = netcdf(filename,'write')
if isempty(h),return, end

if ~exist('settings','var'),
    prompt  = {...
        'Experiment:                                ',...
        'Description:                               ',...
        'Project:                                   ',...
        'Comments:                                  ',...
        'Longitude(decimal degrees):                ',...
        'Units:                                     ',...
        'Latitude(decimal degrees):                 ',...
        'Units:                                     '};

    def     = {h.EXPERIMENT(:),h.PROJECT(:),h.DESCRIPT(:),h.DATA_CMNT(:),...
        num2str(h.longitude(:)),h{'lon'}.units(:),num2str(h.latitude(:)),h{'lat'}.units(:)};
    title   = ['Mooring ',h.MOORING(:)];
    lineNo  = 1;
    dlgresult  = inputdlg(prompt,title,lineNo,def,'on');
    experiment = dlgresult{1};
    project = dlgresult{2};
    descript = dlgresult{3};
    cmnt = dlgresult{4};
    long = str2num(dlgresult{5});
    lonUnits = dlgresult{6};
    latit = str2num(dlgresult{7});
    latUnits = dlgresult{8};
else
    experiment = settings.experiment;
    project = settings.project;
    descript = settings.descript;
    cmnt = settings.cmnt;
    long = settings.long;
    lonUnits = settings.lonUnits;
    latit = settings.latit;
    latUnits = settings.latUnits;

end

fexperiment = h.EXPERIMENT;
fproject = h.PROJECT;
fdescript = h.DESCRIPT;
fcmnt = h.DATA_CMNT;
flong = h.longitude;
flonUnits = h{'lon'}.units;
flatit = h.latitude;
flatUnits = h{'lat'}.units;

fexperiment(:) = experiment;
fproject(:) = project;
fdescript(:) = descript;
fcmnt(:) = cmnt;
flong(:) = long;
flonUnits(:) = lonUnits;
flatit(:) = latit;
flatUnits(:) = latUnits;



% %Get the correct intervals
% prompt  = {'Enter Experiment Name:', 'Enter the Project Name:'...
%    'Enter the Site Description:', 'Comments:'};
% def     = {h.EXPERIMENT(:), h.PROJECT(:),h.DESCRIPT(:), h.DATA_CMNT(:)};
% title   = 'Input correct metadata:';
% lineNo  = 1;
% dlgresult  = inputdlg(prompt,title,lineNo,def);
% Experiment = dlgresult{1};
% Project = dlgresult{2};
% Description = dlgresult{3};
% Comments = dlgresult{4};
%
% fexper = h.EXPERIMENT;
% fproj = h.PROJECT;
% fdescrip = h.DESCRIPT;
% fcomnt = h.DATA_CMNT;
%
% fexper(:) = Experiment;
% fproj(:) = Project;
% fdescrip(:) = Description;
% fcomnt(:) = Comments

ncclose

thecomment=sprintf('%s\n',' The metadata were corrected by fixmetadata.m');
history(filename,thecomment);

