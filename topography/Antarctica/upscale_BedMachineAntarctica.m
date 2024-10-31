clc
clear all
close all

% Available from: https://nsidc.org/data/nsidc-0756/versions/3
filename = 'raw/BedMachineAntarctica-v3.nc';

x = single(ncread( filename,'x'));
y = single(ncread( filename,'y'));

Hi = ncread( filename,'thickness');
Hb = ncread( filename,'bed');
Hs = ncread( filename,'surface');

% Start with the 500m version
write_to_upscaled_file( x, y, Hi, Hb, Hs, filename)

%% Then do the upscaled versions
for n_up = 1:6

  %% Upscale data

  % Upscale x

  if mod( x(1), x(3)-x(1)) == 0
    % Start from x(1)
    x  = [x( 1  ); 0.25 * x( 2:2:end-3  ) + 0.5 * x( 3:2:end-2  ) + 0.25 * x( 4:2:end-1  ); x( end  )];
    Hi = [Hi(1,:); 0.25 * Hi(2:2:end-3,:) + 0.5 * Hi(3:2:end-2,:) + 0.25 * Hi(4:2:end-1,:); Hi(end,:)];
    Hb = [Hb(1,:); 0.25 * Hb(2:2:end-3,:) + 0.5 * Hb(3:2:end-2,:) + 0.25 * Hb(4:2:end-1,:); Hb(end,:)];
    Hs = [Hs(1,:); 0.25 * Hs(2:2:end-3,:) + 0.5 * Hs(3:2:end-2,:) + 0.25 * Hs(4:2:end-1,:); Hs(end,:)];
  else
    % Start from x(2)
    x  = 0.25 * x( 1:2:end-2  ) + 0.5 * x( 2:2:end-1  ) + 0.25 * x( 3:2:end  );
    Hi = 0.25 * Hi(1:2:end-2,:) + 0.5 * Hi(2:2:end-1,:) + 0.25 * Hi(3:2:end,:);
    Hb = 0.25 * Hb(1:2:end-2,:) + 0.5 * Hb(2:2:end-1,:) + 0.25 * Hb(3:2:end,:);
    Hs = 0.25 * Hs(1:2:end-2,:) + 0.5 * Hs(2:2:end-1,:) + 0.25 * Hs(3:2:end,:);
  end

  % Upscale y

  if mod( y(1), y(3)-y(1)) == 0
    % Start from y(1)
    y  = [y(   1); 0.25 * y(   2:2:end-3) + 0.5 * y(   3:2:end-2) + 0.25 * y(   4:2:end-1); y(   end)];
    Hi = [Hi(:,1), 0.25 * Hi(:,2:2:end-3) + 0.5 * Hi(:,3:2:end-2) + 0.25 * Hi(:,4:2:end-1), Hi(:,end)];
    Hb = [Hb(:,1), 0.25 * Hb(:,2:2:end-3) + 0.5 * Hb(:,3:2:end-2) + 0.25 * Hb(:,4:2:end-1), Hb(:,end)];
    Hs = [Hs(:,1), 0.25 * Hs(:,2:2:end-3) + 0.5 * Hs(:,3:2:end-2) + 0.25 * Hs(:,4:2:end-1), Hs(:,end)];
  else
    % Start from y(2)
    y  = 0.25 * y(   1:2:end-2) + 0.5 * y(   2:2:end-1) + 0.25 * y(   3:2:end);
    Hi = 0.25 * Hi(:,1:2:end-2) + 0.5 * Hi(:,2:2:end-1) + 0.25 * Hi(:,3:2:end);
    Hb = 0.25 * Hb(:,1:2:end-2) + 0.5 * Hb(:,2:2:end-1) + 0.25 * Hb(:,3:2:end);
    Hs = 0.25 * Hs(:,1:2:end-2) + 0.5 * Hs(:,2:2:end-1) + 0.25 * Hs(:,3:2:end);
  end

  % Write to NetCDF
  write_to_upscaled_file( x, y, Hi, Hb, Hs, filename);

end

function write_to_upscaled_file( x, y, Hi, Hb, Hs, filename)

  nx = length( x);
  ny = length( y);

  dx = x(2) - x(1);
  if dx < 1000
    dx_str = [num2str(dx) 'm'];
  else
    dx_str = [num2str(double(dx)/1e3) 'km'];
  end

  disp(['Upscaling BedMachineAntarctica to ' dx_str '...'])
 
  %% Read NetCDF template of raw file, use that as a basis

  f_raw = ncinfo( filename);
  
  dim_x  = f_raw.Dimensions(1);
  dim_y  = f_raw.Dimensions(2);
  
  var_x  = f_raw.Variables(2);
  var_y  = f_raw.Variables(3);
  var_Hi = f_raw.Variables(7);
  var_Hb = f_raw.Variables(8);
  var_Hs = f_raw.Variables(6);

  %% Set up NetCDF template for upscaled file

  f = f_raw;

  f.Filename   = ['BedMachineAntarctica_v3_' dx_str '.nc'];
  f.Attributes(end+1).Name  = 'Notes_UFEMISM';
  f.Attributes(end  ).Value = ['Preprocessed to be used in UFEMISM on ' char(datetime)];

  f.Dimensions = [];
  f.Variables = [];
  
  % Geometry variables
  var_Hi.Name = 'Hi';
  var_Hb.Name = 'Hb';
  var_Hs.Name = 'Hs';

  % Set dimensions
  dim_x.Length = nx;
  dim_y.Length = ny;

  var_x.Dimensions = dim_x;
  var_x.Size = nx;
  var_x.Datatype = 'single';
  var_y.Dimensions = dim_y;
  var_y.Size = ny;
  var_y.Datatype = 'single';
  
  var_Hi.Dimensions = [dim_x, dim_y];
  var_Hi.Size = [nx,ny];
  var_Hi.ChunkSize = [];
  var_Hb.Dimensions = [dim_x, dim_y];
  var_Hb.Size = [nx,ny];
  var_Hb.ChunkSize = [];
  var_Hs.Dimensions = [dim_x, dim_y];
  var_Hs.Size = [nx,ny];
  var_Hs.ChunkSize = [];

  f.Dimensions = [dim_x, dim_y];
  f.Variables = [var_x, var_y, var_Hi, var_Hb, var_Hs];

  %% Create NetCDF file
  if exist( f.Filename,'file')
    delete( f.Filename)
  end
  ncwriteschema( f.Filename,f);

  %% Write data
  ncwrite( f.Filename,'x' ,x );
  ncwrite( f.Filename,'y' ,y );
  ncwrite( f.Filename,'Hi',Hi);
  ncwrite( f.Filename,'Hb',Hb);
  ncwrite( f.Filename,'Hs',Hs);
  
end
