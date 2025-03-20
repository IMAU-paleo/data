function ensemble = process_MISMIPplus_ensemble( experiment)
% Read and process the MISMIP+ model ensemble from Cornford et al. (2020)
%
% Cornford, S. L., Seroussi, H., Asay-Davis, X. S., Gudmundsson, G. H., 
% Arthern, R., Borstad, C., Christmann, J., Dias dos Santos, T., 
% Feldmann, J., Goldberg, D., Hoffman, M. J., Humbert, A., Kleiner, T., 
% Leguy, G., Lipscomb, W. H., Merino, N., Durand, G., Morlighem, M., 
% Pollard, D., R\"uckamp, M., Williams, C. R., and Yu, H.: 
% Results of the third Marine Ice Sheet Model Intercomparison Project 
% (MISMIP+), The Cryosphere 14, 2283--2301, 2020.
%
% Supplement available from doi: 10.5194/tc-14-2283-2020

%% List all files for the experiment we're interested in
henk = dir('submission_data');

files_to_read = {};

for i = 1: length( henk)
  if startsWith( henk( i).name, [experiment '_'],'IgnoreCase',true) && ...
     endsWith( henk( i).name, '.nc')
    files_to_read{ end+1} = henk( i).name;
  end
end
if isempty( files_to_read)
  error(['Couldnt find any files for experiment "' experiment '"'])
end

%% Read data
xGL_midstream_sum = 0;
xGL_midstream_min = Inf;
xGL_midstream_max = -Inf;
n_models = 0;

for fi = 1: length( files_to_read)

  filename = ['submission_data/' files_to_read{ fi}];

  time = ncread( filename,'time');
  xGL  = ncread( filename,'xGL');
  yGL  = ncread( filename,'yGL');

  % Find mid-stream xGL
  xGL_midstream = zeros( size( time));
  for ti = 1: length( time)
    i = find( abs( yGL( ti,:)) == min( abs( yGL( ti,:))) ); i = i(1);
    xGL_midstream( ti) = xGL( ti,i);
  end

  % Skip invalid models
  if length( xGL_midstream) == 1 || max( abs( xGL_midstream)) > 1e7
    continue
  end

  % Add results to ensemble
  n_models = n_models + 1;
  xGL_midstream_sum =      xGL_midstream_sum + xGL_midstream;
  xGL_midstream_min = min( xGL_midstream_min,  xGL_midstream);
  xGL_midstream_max = max( xGL_midstream_max,  xGL_midstream);

end

xGL_midstream_av = xGL_midstream_sum / n_models;

ensemble.time    = time;
ensemble.xGL_av  = xGL_midstream_av;
ensemble.xGL_min = xGL_midstream_min;
ensemble.xGL_max = xGL_midstream_max;

end