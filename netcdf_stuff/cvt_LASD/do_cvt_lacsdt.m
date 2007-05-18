% script do_cvt_lacsdt
% runs the programs needed to read the LACSD thermistor ascii files and
% save them as .mat, then read the .mat files and save as .cdf files.
% The metadata in the .cdf files is exctacted from the header info in the
% ascii files.

  % start be combining the ascii files to matrices in one .mat
  n_rdlacsdt('t1PVFSF.csv')
  n_rdlacsdt('t2PVFSF.csv')
  n_rdlacsdt('t3PVFSF.csv')
  n_rdlacsdt('t4PVFSF.csv')
  n_rdlacsdt('t5PVFSF.csv')
  n_rdlacsdt('t6PVFSF.csv')
  n_rdlacsdt('t7PVFSF.csv')
  n_rdlacsdt('t8PVFSF.csv')
  n_rdlacsdt('t9PVFSF.csv')
  n_rdlacsdt('tEPVFSF.csv')
  n_rdlacsdt('tGPVFSF.csv')
  
  % now make the .cdf files from the .mat files
  n_wrtnct('t1PV')
  n_wrtnct('t2PV')
  n_wrtnct('t3PV')
  N_wrtnct('t4PV')
  n_wrtnct('t5PV')
  n_wrtnct('t6PV')
  n_wrtnct('t7PV')
  n_wrtnct('t8PV')
  n_wrtnct('t9PV')
  n_wrtnct('tEPV')
  n_wrtnct('tGPV')
  
  % now we should have 11 .cdl, .mat and .cdf files

         