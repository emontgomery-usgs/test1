function next_note_num = mcnote(cdfid, varid, text, note_num);
% mcnote.m annotates netCDF variables by using text attributes
%
% function next_note_num = mcnote(cdfid, varid, text, note_num);
%
% notes are of the form
%	NOTE_# ==> 'This is a note about this data'
%
% written by the command
% 	mexcdf('ATTPUT',cdfid,varid,['NOTE_',int2str(note_num)],...
% 	'CHAR',length(text),text);
%
% Where: 
%	cdfid = the handle of a netCDF file opened 
%		for writing   
%	varid = the variable id, can be NC_GLOBAL
%	text = the text of the annotation
%	note_num = the number of the note
%	new_note_num = the number to use for the next note
%
%  4/16/99 go back to mexcdf... it's faster!
%	3/19/99 update this to use netcdf rather than mexcdf MATLAB hooks


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

 
% we want feedback in case the user forgot to open the file
opts = mexcdf('SETOPTS','NC_VERBOSE');
%no netcdf equivalent

mexcdf('ATTPUT',cdfid,varid,['NOTE_',int2str(note_num)],...
	'CHAR',length(text),text);

% global attributes get handled differently
%if ~isempty(findstr(lower(varid), 'glo')),
%	eval(['cdfid.NOTE_',int2str(note_num),' = text;']);
%else
%	eval(['cdfid{varid}.NOTE_',int2str(note_num),' = text;']);
%end

% reset opts to the original state
%eval('SETOPTS',opts);
mexcdf('SETOPTS',opts);

next_note_num = note_num+1;

