% script do_cvt_lacsd
% runs the programs needed to read the SAIC ascii files and save them as
% .mat, then read the .mat files and save as .cdf files.
% The metadata in the .cdf files is exctacted from the header info in the
% ascii files.

  % start be combining the ascii files to matrices in one .mat
  n_rdlacsd('LA00A1')
  n_rdlacsd('LA00A2')
  n_rdlacsd('LA00A3')
  n_rdlacsd('LA00A4')
  n_rdlacsd('LA00A5')
  n_rdlacsd('LA00A6')
  n_rdlacsd('LA00A7')
  n_rdlacsd('LA00A8')
  n_rdlacsd('LA00A9')
  n_rdlacsd('LA00AA')
  n_rdlacsd('LA00AB')
  n_rdlacsd('LA00AC') 
  n_rdlacsd('LA00AD') 
  n_rdlacsd('LA00AE') 
  n_rdlacsd('LA00AF')
  n_rdlacsd('LA00AG')
  
  % now make the .cdf files from the .mat files
  n_wrtnc('LA00A1')
  n_wrtnc('LA00A2')
  n_wrtnc('LA00A3')
  N_wrtnc('LA00A4')
  n_wrtnc('LA00A5')
  n_wrtnc('LA00A6')
  n_wrtnc('LA00A7')
  n_wrtnc('LA00A8')
  n_wrtnc('LA00A9')
  n_wrtnc('LA00AA')
  n_wrtnc('LA00AB')
  n_wrtnc('LA00AC') 
  n_wrtnc('LA00AD') 
  n_wrtnc('LA00AE') 
  n_wrtnc('LA00AF')
  n_wrtnc('LA00AG')
  
  % now we should have 16 .cdl, .mat and .cdf files

         