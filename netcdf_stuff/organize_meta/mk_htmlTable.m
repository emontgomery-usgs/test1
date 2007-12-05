% script to generate the table of data available for MB experiment
%  this table gets sent to Greg for edits then gets put on the experiment
%  page of the website on Stellwagen.


%%% START USGS BOILERPLATE -------------% Program written in Matlab v6x
% Program works in Matlab v7.1.0 SP3
% Program updated in Matlab 7.2.0.232 (R2006a)
% Program ran on PC with Windows XP Professional OS.
% program ran on Redhat Enterprise Linux 4
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%%% END USGS BOILERPLATE --------------

 
% creates mb_info.mat that contains dataArchiveStruct from all the .nc 
% files in data/MyrtleBeach/DATA_DVD/DATAFILES
[dataArchiveStruct] = archiveDirectory(,...
    '/mnt/ccdr_stg/data/MyrtleBeach/DATA_DVD/DATAFILES',...
    'Myrtle Beach Erosion', 'mbinfo')

% creates the html table from the structure in dataArchiveStruct
createArchiveTable('mb_table.html',dataArchiveStruct,'web title',...
    'South Carolina Coastal Erosion Study data available')
