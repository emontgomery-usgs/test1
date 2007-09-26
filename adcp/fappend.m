function theResult = fappend(varargin)% fappend -- Append files to an existing file.%  fappend('outfile', 'infile_1', infile_2', ...)%   appends the given input files to the output%   file, creating it if necessary.  Partial names%   are resolved with the Matlab "which" command.%   Note: the output file should not have the same%   name as any input file.

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

  % Copyright (C) 2001 Dr. Charles R. Denham, ZYDECO.%  All Rights Reserved.%   Disclosure without explicit written consent from the%    copyright owner does not constitute publication. % Version of 06-Aug-2001 14:18:38.% Updated    06-Aug-2001 14:55:12.CHUNK = 2048;if nargin < 1	help(mfilename)	returnendw = which(varargin{1});if ~isempty(w)	outfile = w;else	outfile = varargin{1};	fout = fopen(outfile, 'a');	if fout < 0		disp([' ## Unable to create/open output-file: "' outfile '"'])		return	end	outfile = fopen(fout);	fclose(fout);endfor i = 2:length(varargin)	infile = which(varargin{i});	if isequal(outfile, infile)		disp(' ## Output-file must not have the same name as any input-file.')		return	elseif isempty(infile)		disp([' ## No such input-file: "' varargin{i} '"'])		return	endendfout = fopen(outfile, 'a');if fout < 0	disp([' ## Unable to open output-file: "' outfile '"'])	returnendfor i = 2:length(varargin)	infile = which(varargin{i});	fin = fopen(infile, 'r');	if fin < 0		disp([' ## Unable to open output-file: "' infile '"'])		fclose(fout)		return	end	while (1)		[s, count] = fread(fin, [1 CHUNK]);   % Read characters.		if count > 0			fwrite(fout, s);		end		if count < CHUNK			fclose(fin);			break;		end	endendfclose(fout);