clc
clear all
close all

% NOTE: by Jorgo Bernales, 2023

% Paths
% =====

filename_in  = 'SSB_Likelihood.tif'; % from https://doi.org/10.5281/zenodo.6611940
filename_out = 'till_friction_angle_Li2022.nc';

% Read data
% =========

[A,R] = readgeoraster(filename_in);

% Coordinates
% ===========

x = R.XWorldLimits(1)+R.CellExtentInWorldX/2 : R.CellExtentInWorldX : R.XWorldLimits(2)-R.CellExtentInWorldX/2;
y = R.YWorldLimits(1)+R.CellExtentInWorldY/2 : R.CellExtentInWorldY : R.YWorldLimits(2)-R.CellExtentInWorldY/2;

% Sediment data
% =============

A = double(A);

A(A<0) = NaN;

A = 1-A;

A = atand(A);

A = rot90(A,3);

figure(20);imagesc(y,x,A);axis image; caxis([0 45]); colorbar

% Extend data domain
% ==================

X = -3040000.0 : 1e4: 3040000.0;
Y = -3040000.0 : 1e4: 3040000.0;

B = NaN(length(X),length(Y));

X1 = find(X==x(1));
Y1 = find(Y==y(1));

B(X1:X1+length(x)-1,Y1:Y1+length(y)-1) = A;

B = inpaint_nans(B,2);

figure(21);imagesc(Y,X,B);axis image; caxis([0 45]); colorbar

% Re-assign
% =========

x = X;
y = Y;
A = B;

% Safety
% ======

A(A<1e-3) = 1e-3;

% Projection parameters
% =====================

C.earth_radius = 6.371e6;   % Earth radius
C.lambda = 0.0;             % Longitude of reference
C.phi    = -90.0;           % Latitude of reference
C.alpha  = 19.0;            % Projection angle

% NetCDF
% ======

ncid  = netcdf.create(filename_out,'CLOBBER');

x_dim = netcdf.defDim(ncid,'x',length(x));
y_dim = netcdf.defDim(ncid,'y',length(y));

x_id = netcdf.defVar(ncid,'x', 'NC_FLOAT',x_dim);
y_id = netcdf.defVar(ncid,'y', 'NC_FLOAT',y_dim);
A_id = netcdf.defVar(ncid,'till_friction_angle','NC_FLOAT',[x_dim y_dim]);

lambda_id = netcdf.defVar(ncid,'lambda','NC_FLOAT',[]);
phi_id    = netcdf.defVar(ncid,'phi',   'NC_FLOAT',[]);
alpha_id  = netcdf.defVar(ncid,'alpha', 'NC_FLOAT',[]);

netcdf.endDef(ncid);

netcdf.putVar(ncid, x_id, x);
netcdf.putVar(ncid, y_id, y);
netcdf.putVar(ncid, A_id, A);
netcdf.putVar(ncid, lambda_id, C.lambda);
netcdf.putVar(ncid, phi_id, C.phi);
netcdf.putVar(ncid, alpha_id, C.alpha);

netcdf.reDef(ncid);

netcdf.putAtt(ncid,x_id,     'long_name','x-axis distance from center of projection');
netcdf.putAtt(ncid,y_id,     'long_name','y-axis distance from center of projection');
netcdf.putAtt(ncid,A_id,     'long_name','Till friction angle');
netcdf.putAtt(ncid,lambda_id,'long_name','Longitude of center of projection');
netcdf.putAtt(ncid,phi_id,   'long_name','Latitude of center of projection');
netcdf.putAtt(ncid,alpha_id, 'long_name','Standard parallel of projection');

netcdf.putAtt(ncid,x_id,     'units','meters');
netcdf.putAtt(ncid,y_id,     'units','meters');
netcdf.putAtt(ncid,A_id,     'units','degrees');
netcdf.putAtt(ncid,lambda_id,'units','degrees');
netcdf.putAtt(ncid,phi_id,   'units','degrees');
netcdf.putAtt(ncid,alpha_id, 'units','degrees');

netcdf.close(ncid);