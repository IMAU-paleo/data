clc
clear all
close all

% Read Pattyn et al. (2008) ensemble results
[HO,FS] = process_ISMIP_HOM_ensemble_experiment_C( 'ismip_all');

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
c_HO  = [0.1,0.5,0.2];
c_FS  = [0.2,0.5,1.0];
patch( 'parent',H.Ax{ 2,3},'vertices',[],'faces',[],'facecolor',c_HO,...
  'edgecolor','none','facealpha',0.3);
patch( 'parent',H.Ax{ 2,3},'vertices',[],'faces',[],'facecolor',c_FS,...
  'edgecolor','none','facealpha',0.7);
line( 'parent',H.Ax{ 2,3},'xdata',[],'ydata',[],'color',c_HO,'linewidth',3);
line( 'parent',H.Ax{ 2,3},'xdata',[],'ydata',[],'color',c_FS,'linewidth',3);

set( H.Ax{ 1,1},'ylim',[6,18]);
set( H.Ax{ 1,2},'ylim',[13.5,17]);
set( H.Ax{ 1,3},'ylim',[13,20]);
set( H.Ax{ 2,1},'ylim',[10,35]);
set( H.Ax{ 2,2},'ylim',[0,70]);
set( H.Ax{ 2,3},'ylim',[0,200]);

for Li = 1: 6

  if Li==1
    ex = 'L005';
    ax = H.Ax{ 1,1};
  elseif Li == 2
    ex = 'L010';
    ax = H.Ax{ 1,2};
  elseif Li == 3
    ex = 'L020';
    ax = H.Ax{ 1,3};
  elseif Li == 4
    ex = 'L040';
    ax = H.Ax{ 2,1};
  elseif Li == 5
    ex = 'L080';
    ax = H.Ax{ 2,2};
  elseif Li == 6
    ex = 'L160';
    ax = H.Ax{ 2,3};
  end

  % Ensemble ranges
  xdata = [HO.(ex).x    ; flipud( HO.(ex).x    )];
  ydata = [HO.(ex).u_min; flipud( HO.(ex).u_max)];
  patch('parent',ax,'xdata',xdata,'ydata',ydata,'facecolor',c_HO,...
    'edgecolor','none','facealpha',0.3);

  xdata = [FS.(ex).x    ; flipud( FS.(ex).x    )];
  ydata = [FS.(ex).u_min; flipud( FS.(ex).u_max)];
  patch('parent',ax,'xdata',xdata,'ydata',ydata,'facecolor',c_FS,...
    'edgecolor','none','facealpha',0.7);

  % Ensemble means
  line('parent',ax,'xdata',HO.(ex).x,'ydata',HO.(ex).u_av,...
    'color',c_HO,'linewidth',3)
  line('parent',ax,'xdata',FS.(ex).x,'ydata',FS.(ex).u_av,...
    'color',c_FS,'linewidth',3)
end

legend( H.Ax{ 2,3},'Full-Stokes','Higher-Order','FS mean','HO mean','location','northwest')
