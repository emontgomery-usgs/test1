% script to generate the table of data available for MB experiment
%  this table gets sent to Greg for edits then gets put on the experiment
%  page of the website on Stellwagen.

% creates mb_info.mat that contains dataArchiveStruct from all the .nc 
% files in data/MyrtleBeach/DATA_DVD/DATAFILES
[dataArchiveStruct] = archiveDirectory(,...
    '/mnt/ccdr_stg/data/MyrtleBeach/DATA_DVD/DATAFILES',...
    'Myrtle Beach Erosion', 'mbinfo')

% creates the html table from the structure in dataArchiveStruct
createArchiveTable('mb_table.html',dataArchiveStruct,'web title',...
    'South Carolina Coastal Erosion Study data available')
