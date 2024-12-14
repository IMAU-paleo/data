clc
clear all
close all

%% Read Pattyn et al. (2008) ensemble results
foldername = 'ismip_all';

model_types = {...
  'aas1','FS';...
  'aas2','FS';...
  'ahu1','HO';...
  'ahu2','HO';...
  'bds1','HO';...
  'cma1','FS';...
  'cma2','HO';...
  'dpo1','HO';...
  'fpa1','HO';...
  'fpa2','FS';...
  'fsa1','HO';...
  'ghg1','FS';...
  'jvj1','FS';...
  'lpe1','HO';...
  'mbr1','HO';...
  'mmr1','FS';...
  'mtk1','HO';...
  'oga1','FS';...
  'oso1','HO';...
  'rhi1','FS';...
  'rhi2','HO';...
  'rhi3','FS';...
  'rhi4','HO';...
  'rhi5','HO';...
  'spr1','FS';...
  'ssu1','FS';...
  'tpa1','HO';...
  'yko1','FS'};

models = dir(foldername);
models = models(3:end);

ensemble.a160 = [];
ensemble.a080 = [];
ensemble.a040 = [];
ensemble.a020 = [];
ensemble.a010 = [];
ensemble.a005 = [];

for mi = 1: length(models)

  modeldata = dir([foldername '/' models(mi).name]);
  modeldata = modeldata(3:end);

  % Go over all experiments, check if this model has them.
  flds = fields(ensemble);
  for xi = 1:length(flds)
    ex = flds{xi};

    for di = 1:length(modeldata)
      mdname = modeldata(di).name;
      str = [ex '.txt'];
      if length(mdname) >= length(str)
        if strcmpi(mdname(end-length(str)+1:end),str)
          % This is the experiment from this model

          disp(['Reading data from model ' models(mi).name ', experiment ' ex])

          fid = fopen([foldername '/' models(mi).name '/' mdname]);
          temp = textscan(fid,'%s','delimiter','\n','MultipleDelimsAsOne',1); temp = temp{1};
          fclose(fid);

          n = length(temp);
          nx = sqrt(n);
          if nx-floor(nx)>0
            error('whaa!')
          end
          x_vec = zeros(n,1);
          y_vec = zeros(n,1);
          u_vec = zeros(n,1);
          v_vec = zeros(n,1);
          w_vec = zeros(n,1);
          for i = 1:n
            temp2 = textscan(temp{i},'%f %f %f %f %f %f %f %f');
            x_vec(i) = temp2{1};
            y_vec(i) = temp2{2};
            u_vec(i) = temp2{3};
            v_vec(i) = temp2{4};
            w_vec(i) = temp2{5};
          end

          ensemble.(ex).(models(mi).name).x = reshape(x_vec,[nx,nx]);
          ensemble.(ex).(models(mi).name).y = reshape(y_vec,[nx,nx]);
          ensemble.(ex).(models(mi).name).u = reshape(u_vec,[nx,nx]);
          ensemble.(ex).(models(mi).name).v = reshape(v_vec,[nx,nx]);
          ensemble.(ex).(models(mi).name).w = reshape(w_vec,[nx,nx]);

          if (ensemble.(ex).(models(mi).name).x(1,1) == ensemble.(ex).(models(mi).name).x(end,1))
            ensemble.(ex).(models(mi).name).x = ensemble.(ex).(models(mi).name).x';
            ensemble.(ex).(models(mi).name).y = ensemble.(ex).(models(mi).name).y';
            ensemble.(ex).(models(mi).name).u = ensemble.(ex).(models(mi).name).u';
            ensemble.(ex).(models(mi).name).v = ensemble.(ex).(models(mi).name).v';
            ensemble.(ex).(models(mi).name).w = ensemble.(ex).(models(mi).name).w';
          end

        end
      end
    end
  end

end

% save('ISMIP_HOM_A_ensemble.mat','ensemble');
% load('ISMIP_HOM_A_ensemble.mat')

%% Set up GUI

wa = 250;
ha = 200;

margins_hor = [90,50,50,25];
margins_ver = [50,50,90];

H = setup_multipanel_figure( wa, ha, margins_hor, margins_ver);

set( H.Ax{ 1,1},'xtick',0:0.2:1,'xticklabels','');
set( H.Ax{ 1,2},'xtick',0:0.2:1,'xticklabels','');
set( H.Ax{ 1,3},'xtick',0:0.2:1,'xticklabels','');
set( H.Ax{ 2,1},'xtick',0:0.2:1);
set( H.Ax{ 2,2},'xtick',0:0.2:1);
set( H.Ax{ 2,3},'xtick',0:0.2:1);

xlabel( H.Ax{ 2,1},'x / L');
xlabel( H.Ax{ 2,2},'x / L');
xlabel( H.Ax{ 2,3},'x / L');

ylabel( H.Ax{ 1,1},'Surface x-velocity (m/yr)');
ylabel( H.Ax{ 2,1},'Surface x-velocity (m/yr)');

title( H.Ax{ 1,1},'5 km');
title( H.Ax{ 1,2},'10 km');
title( H.Ax{ 1,3},'20 km');
title( H.Ax{ 2,1},'40 km');
title( H.Ax{ 2,2},'80 km');
title( H.Ax{ 2,3},'160 km');

% Empty objects for legend - ISMIP-HOM ensemble
c_FS  = [0.2,0.5,1.0];
c_HO  = [0.1,0.5,0.2];
patch( 'parent',H.Ax{ 1,1},'vertices',[],'faces',[],'facecolor',c_FS,'edgecolor','none','facealpha',0.7)
patch( 'parent',H.Ax{ 1,1},'vertices',[],'faces',[],'facecolor',c_HO,'edgecolor','none','facealpha',0.3)
line(  'parent',H.Ax{ 1,1},'xdata',[],'ydata',[],'color',c_FS,'linewidth',3);
line(  'parent',H.Ax{ 1,1},'xdata',[],'ydata',[],'color',c_HO,'linewidth',3);

%% Plot Pattyn2008 ensemble
for a = 1:6

  if a == 1
    ax = H.Ax{ 2,3};
    ex = 'a160';
    ylim = [0,130];
  elseif a == 2
    ax = H.Ax{ 2,2};
    ex = 'a080';
    ylim = [0,100];
  elseif a == 3
    ax = H.Ax{ 2,1};
    ex = 'a040';
    ylim = [0,80];
  elseif a == 4
    ax = H.Ax{ 1,3};
    ex = 'a020';
    ylim = [0,60];
  elseif a == 5
    ax = H.Ax{ 1,2};
    ex = 'a010';
    ylim = [0,40];
  elseif a == 6
    ax = H.Ax{ 1,1};
    ex = 'a005';
    ylim = [0,30];
  end

  x_FS = linspace(0,1,200)';
  u_FS = [];
  u_HO = [];

  set( ax,'ylim',ylim);

  patch_HO  = patch( 'parent',ax,'xdata',[],'ydata',[],'facecolor',c_HO,'edgecolor','none','facealpha',0.3);
  patch_FS  = patch( 'parent',ax,'xdata',[],'ydata',[],'facecolor',c_FS,'edgecolor','none','facealpha',0.7);
  line_HO   = line(  'parent',ax,'xdata',[],'ydata',[],'color',c_HO,'linewidth',3);
  line_FS   = line(  'parent',ax,'xdata',[],'ydata',[],'color',c_FS,'linewidth',3);

  flds = fields(ensemble.(ex));
  for mi = 1:length(flds)
    m = flds{mi};

    x = ensemble.(ex).(m).x(:,1);
    y = ensemble.(ex).(m).y(1,:)';
    yi = round(0.25*length(y));
    u = ensemble.(ex).(m).u(:,yi);

    % Determine if this model is FS or HO
    FS = false;
    HO = false;
    for mii = 1:size(model_types,1)
      if strcmpi(model_types{mii,1},m)
        if strcmpi(model_types{mii,2},'FS')
          FS = true;
        else
          HO = true;
        end
      end
    end
    if ~(FS || HO)
      for mii = 1:size(model_types,1)
        if strcmpi(model_types{mii,1}(1:3),m(1:3))
          if strcmpi(model_types{mii,2},'FS')
            FS = true;
          else
            HO = true;
          end
        end
      end
    end
    if ~(FS || HO)
      % Unknown model?
      continue
    end

    % Add to data ranges for HO/FS models
    up = interp1(x,u,x_FS);
    if FS
      u_FS(:,end+1) = up;
    else
      u_HO(:,end+1) = up;
    end

  end

  % Missing data points
  m = true(size(x_FS));
  for i = 1:length(x_FS)
    if sum(isnan(u_FS(i,:)))+sum(isnan(u_HO(i,:)))>0
      m(i) = false;
    end
  end
  u_FS = u_FS(m,:);
  u_HO = u_HO(m,:);
  x_FS = x_FS(m);

  % ISMIP-HOM ensemble data
  uav_FS = mean(u_FS,2);
  uav_HO = mean(u_HO,2);
  sigma_FS = zeros(size(x_FS));
  sigma_HO = zeros(size(x_FS));
  for i = 1:size(u_FS,1)
    sigma_FS(i) = std(u_FS(i,:));
    sigma_HO(i) = std(u_HO(i,:));
    if isnan(sigma_FS(i)); sigma_FS(i) = 0; end
    if isnan(sigma_HO(i)); sigma_HO(i) = 0; end
  end
  umin_FS = uav_FS - sigma_FS;
  umax_FS = uav_FS + sigma_FS;
  umin_HO = uav_HO - sigma_HO;
  umax_HO = uav_HO + sigma_HO;

  xdata = [x_FS;flipud(x_FS)];
  ydata = [umin_FS;flipud(umax_FS)];
  set(patch_FS ,'xdata',xdata,'ydata',ydata)

  xdata = [x_FS;flipud(x_FS)];
  ydata = [umin_HO;flipud(umax_HO)];
  set(patch_HO ,'xdata',xdata,'ydata',ydata)

  set(line_HO ,'xdata',x_FS,'ydata',uav_HO)
  set(line_FS ,'xdata',x_FS,'ydata',uav_FS)

end

legend( H.Ax{ 2,3},'Full-Stokes','Higher-Order','FS mean','HO mean','location','northwest')
