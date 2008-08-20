% script do_fix_vbrange
% do_fix_vbrange- a script to fix the MVCO ranges and re-run adr2nc
%
%  probably best to test first to find the appropriate settings- 
%       this is not a one-size-fits all fix!
%   try running both_cleanup.m, which is a standalone program that
%   reads both adv and pcacp files to play with best settings to clean-up
%   individual datasets sith fix_vbrange called from cleanhydra
% usage : [c,q]=both_cleanup('8375advBs2.cdf','brange',seta);
%
% these settings are pretty good defaults, but vrange and brange are
% usually different, as are the number of points and the threshold

diary(sprintf('run%s',datestr(now,30)))
% This instrument malfunctiones, so there is no first part of the timeseries

% now do the second part
outFileRoot='8376advB';

seta.std_threshold=10;
seta.min=300; seta.max=450;
seta.npts=25;
seta.nstds=2.4;
cleanhydra([outFileRoot 'b2.cdf'], [outFileRoot 's2.cdf'], ...
        [outFileRoot 'q2.cdf'], 'fix_vbrange','settings', seta, ...
        'variables',{'vrange'});
    
seta.std_threshold=10;
seta.min=400; seta.max=600;
seta.npts=25;
seta.nstds=2.4;
cleanhydra([outFileRoot 'b2.cdf'], [outFileRoot 's2.cdf'], ...
        [outFileRoot 'q2.cdf'], 'fix_vbrange','settings', seta, ...
        'variables',{'brange'});
    
    switches = []; % invoke all defaults
    Adv = adv2nc([outFileRoot 'b2.cdf'], [outFileRoot 's2.cdf'], outFileRoot, switches);

diary off

