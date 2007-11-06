% script to generate the table of data available for MB experiment
%  this table gets sent to Greg for edits then gets put on the experiment
%  page of the website on Stellwagen.

% creates mb_info.mat that contains dataArchiveStruct from all the .nc 
% files in data/MyrtleBeach/DATA_DVD/DATAFILES
[dataArchiveStruct] = archiveDirectory('\home\data\validation\boston\qc\a1h',...
    'end of MBay long term hourly', 'mblt1hinfo')

% creates the html table from the structure in dataArchiveStruct
createArchiveTable('endBosa1h_table.html',dataArchiveStruct,'web title',...
    'Massachussetts Bay Long term Study data available')
