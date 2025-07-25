clc
clear all
close all

% Available from: https://nsidc.org/data/nsidc-0484/versions/2
filename = 'raw/antarctica_ice_velocity_450m_v2.nc';

% Read data
x = single(ncread( filename,'x')); dx = x(2) - x(1);
y = single(ncread( filename,'y')); dy = abs(y(2) - y(1));

u_surf = ncread( filename,'VX');
v_surf = ncread( filename,'VY');

% Flip y dimension, as this is upside-down in the raw file
y = flipud(y);
u_surf = fliplr( u_surf);
v_surf = fliplr( v_surf);

% Extend to cover the the ISMIP domain
n_extra_x_west = 0;
while x(1) > -3040e3
  n_extra_x_west = n_extra_x_west+1;
  x = [x(1) - dx; x];
end
n_extra_x_east = 0;
while x(end) < 3040e3
  n_extra_x_east = n_extra_x_east+1;
  x = [x; x(end) + dx];
end
n_extra_y_south = 0;
while y(1) > -3040e3
  n_extra_y_south = n_extra_y_south+1;
  y = [y(1) - dy; y];
end
n_extra_y_north = 0;
while y(end) < 3040e3
  n_extra_y_north = n_extra_y_north+1;
  y = [y; y(end) + dy];
end

u_surf = padarray( u_surf, [n_extra_x_west, n_extra_y_south], NaN, 'pre');
u_surf = padarray( u_surf, [n_extra_x_east, n_extra_y_north], NaN, 'post');
v_surf = padarray( v_surf, [n_extra_x_west, n_extra_y_south], NaN, 'pre');
v_surf = padarray( v_surf, [n_extra_x_east, n_extra_y_north], NaN, 'post');

% Calculate absolute surface velocity
uabs_surf = sqrt( u_surf.^2 + v_surf.^2);

% Start with the 450m version
write_to_upscaled_file( x, y, u_surf, v_surf, uabs_surf, filename)

%% Then do the upscaled versions
for n_up = 1:5

  %% Upscale data

  x_new = 0.25 * x(1:2:end-2) + 0.5 * x(2:2:end-1) + 0.25 * x(3:2:end);
  y_new = 0.25 * y(1:2:end-2) + 0.5 * y(2:2:end-1) + 0.25 * y(3:2:end);
  
  nx = length( x_new);
  ny = length( y_new);
  
  u_new = zeros( nx,ny);
  v_new = zeros( nx,ny);
  
  w = [
    0.25 * 0.25, 0.50 * 0.25, 0.25 * 0.25;
    0.25 * 0.50, 0.50 * 0.50, 0.25 * 0.50;
    0.25 * 0.25, 0.50 * 0.25, 0.25 * 0.25];
  
  pprev = -Inf;
  for i = 1: nx
  
    p = floor( 100 * (i-1) / (nx-1) );
    if p>pprev
      pprev = p;
      disp(['Progress: ' num2str(p) '%...'])
    end
  
    for j = 1: ny
  
      ibl = 2*i - 1;
      ibu = 2*i + 1;
  
      jbl = 2*j - 1;
      jbu = 2*j + 1;
      
      ub = u_surf( ibl:ibu, jbl:jbu);
      m = ~isnan( ub);
      u_new( i,j) = sum(ub(m) .* w(m)) / sum(w(m));
      
      vb = v_surf( ibl:ibu, jbl:jbu);
      m = ~isnan( vb);
      v_new( i,j) = sum(vb(m) .* w(m)) / sum(w(m));
  
    end
  end

  x      = x_new;
  y      = y_new;
  u_surf = u_new;
  v_surf = v_new;

  % Calculate absolute surface velocity
  uabs_surf = sqrt( u_surf.^2 + v_surf.^2);

  % Write to NetCDF
  write_to_upscaled_file( x, y, u_surf, v_surf, uabs_surf, filename);

end

function write_to_upscaled_file( x, y, u_surf, v_surf, uabs_surf, filename)

  nx = length( x);
  ny = length( y);

  dx = x(2) - x(1);
  if dx < 1000
    dx_str = [num2str(dx) 'm'];
  else
    dx_str = [num2str(double(dx)/1e3) 'km'];
  end

  disp(['Upscaling MEaSUREs Antarctica to ' dx_str '...'])
 
  %% Read NetCDF template of raw file, use that as a basis

  f_raw = ncinfo( filename);
  
  dim_x  = f_raw.Dimensions(1);
  dim_y  = f_raw.Dimensions(2);
  
  var_x  = f_raw.Variables(2);
  var_y  = f_raw.Variables(3);

  var_u_surf    = f_raw.Variables(6);
  var_v_surf    = f_raw.Variables(7);
  var_uabs_surf = var_u_surf;

  %% Set up NetCDF template for upscaled file

  f = f_raw;

  f.Filename   = ['MEaSUREs_Antarctica_v2_' dx_str '.nc'];
  f.Attributes(end+1).Name  = 'Notes_UFEMISM';
  f.Attributes(end  ).Value = ['Preprocessed to be used in UFEMISM on ' char(datetime)];

  f.Dimensions = [];
  f.Variables = [];
  
  % Geometry variables
  var_u_surf.Name    = 'u_surf';
  var_v_surf.Name    = 'v_surf';
  var_uabs_surf.Name = 'uabs_surf';

  % Set dimensions
  dim_x.Length = nx;
  dim_y.Length = ny;

  var_x.Dimensions = dim_x;
  var_x.Size = nx;
  var_x.Datatype = 'single';
  var_y.Dimensions = dim_y;
  var_y.Size = ny;
  var_y.Datatype = 'single';
  
  var_u_surf.Dimensions = [dim_x, dim_y];
  var_u_surf.Size = [nx,ny];
  var_u_surf.ChunkSize = [];
  var_v_surf.Dimensions = [dim_x, dim_y];
  var_v_surf.Size = [nx,ny];
  var_v_surf.ChunkSize = [];
  var_uabs_surf.Dimensions = [dim_x, dim_y];
  var_uabs_surf.Size = [nx,ny];
  var_uabs_surf.ChunkSize = [];

  var_uabs_surf.Attributes(1).Value = 'Ice speed';
  var_uabs_surf.Attributes(1).Value = 'land_ice_speed';

  f.Dimensions = [dim_x, dim_y];
  f.Variables = [var_x, var_y, var_u_surf, var_v_surf, var_uabs_surf];

  %% Create NetCDF file
  if exist( f.Filename,'file')
    delete( f.Filename)
  end
  ncwriteschema( f.Filename,f);

  %% Write data
  ncwrite( f.Filename,'x' ,x );
  ncwrite( f.Filename,'y' ,y );
  ncwrite( f.Filename,'u_surf',u_surf);
  ncwrite( f.Filename,'v_surf',v_surf);
  ncwrite( f.Filename,'uabs_surf',uabs_surf);
  
end
