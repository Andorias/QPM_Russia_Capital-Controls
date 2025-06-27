%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% IMPULSE RESPONSE FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housekeeping
clearvars
close all

%% If non-existent, create "results" folder where all results will be stored
[~,~,~] = mkdir('results');

%% Read the model
[m,p,mss] = readmodel();

%% Define shocks
% One period unexpected shocks: inflation, output, exchange rate, interest rate
% Create a list of shock variables and a list of their titles. The shock variables
% must have the names found in the model code (in file 'model.model')
listshocks = {'shk_D_L_CPI_core','shk_D_L_CPI_vol','shk_L_D_gap','shk_L_Ex_gap','shk_L_Im_gap','shk_L_S','shk_KR','shk_RPM_gap','shk_L_ToT_gap','shk_NR_f','shk_L_GDP_f_gap','shk_w_cc'};
listtitles = {'Core Inflationary Shock','Vol Inflationary Shock','Domestic Demand Shock','Export Shock','Import Shock','Exchange Rate Shock','Key Rate Shock','Market Risk Premium Shock','Urals Price Shock','Foreign Monetary Policy Shock','Foreign Demand Shock','Capital Controls Shock'};

% Set the time frame for the simulation 
startsim = qq(0,1);
endsim = qq(3,4); % four-year simulation horizon

% For each shock a zero database is created (command 'zerodb') and named as 
% database 'd.{shock_name}'
for i = 1:length(listshocks)
    d.(listshocks{i}) = zerodb(m,startsim:endsim);
end

% Fill the respective databases with the shock values for the starting
% point of the simulation (startsim). For simplicity, all shocks are set to
% 1 percent

% d.shk_D_L_CPI.shk_D_L_CPI(startsim) = 1;
d.shk_D_L_CPI_core.shk_D_L_CPI_core(startsim) = 1;
d.shk_D_L_CPI_vol.shk_D_L_CPI_vol(startsim) = 1;
d.shk_L_D_gap.shk_L_D_gap(startsim) = 1;
d.shk_L_Ex_gap.shk_L_Ex_gap(startsim) = 1;
d.shk_L_Im_gap.shk_L_Im_gap(startsim) = 1;
d.shk_L_S.shk_L_S(startsim) = 1;
d.shk_KR.shk_KR(startsim) = 1;
d.shk_RPM_gap.shk_RPM_gap(startsim) = 1;
d.shk_L_ToT_gap.shk_L_ToT_gap(startsim) = 10;
d.shk_NR_f.shk_NR_f(startsim) = 1;
d.shk_L_GDP_f_gap.shk_L_GDP_f_gap(startsim) = 1;
d.shk_w_cc.shk_w_cc(startsim) = 10;

%% Simulate IRFs
% Simulate the model's response to a given shock using the command 'simulate'.
% The inputs are model 'm' and the respective database 'd.{shock_name}'.
% Results are written in database 's.{shock_name}'.
for i=1:length(listshocks)    
    s.(listshocks{i}) = simulate(m,d.(listshocks{i}),startsim:endsim,'deviation',true);
end

%% Generate pdf report
x = report.new('Shocks');

% Figure style
sty = struct();
sty.line.linewidth = 1;
sty.line.linestyle = {'-';'--'};
sty.line.color = {'k';'r'};
sty.legend.location = 'Best';

% Create separate page with IRFs for each shock
for i = 1:length(listshocks)

x.figure(listtitles{i},'zeroline',true,'style',sty, ...
         'range',startsim:endsim,'legend',false,'marks',{'Baseline','Alternative'});

% x.graph('CPI Inflation QoQ (% ar)','legend',true);
% x.series('',s.(listshocks{i}).D_L_CPI);

x.graph('CPI Inflation core (% ar)','legend',true);
x.series('',s.(listshocks{i}).D_L_CPI_core);

x.graph('CPI Inflation vol QoQ (% ar)','legend',true);
x.series('',s.(listshocks{i}).D_L_CPI_vol);

x.graph('Nominal Interest Rate (% ar)');
x.series('',s.(listshocks{i}).KR);

x.graph('Market Risk Premium (% ar)');
x.series('',s.(listshocks{i}).RPM);

x.graph('Nominal Market Interest Rate (% ar)');
x.series('',s.(listshocks{i}).i_m);

x.graph('Nominal ER Deprec. QoQ (% ar)');
x.series('',s.(listshocks{i}).D_L_S);

x.graph('Output Gap (%)');
x.series('',[s.(listshocks{i}).L_GDP_gap]);

x.graph('Domestic Demand (%)');
x.series('',[s.(listshocks{i}).L_D_gap]);

x.graph('Export (%)');
x.series('',[s.(listshocks{i}).L_Ex_gap]);

x.graph('Import (%)');
x.series('',[s.(listshocks{i}).L_Im_gap]);

x.graph('Real Interest Rate Gap (%)');
x.series('', s.(listshocks{i}).RR_gap);

x.graph('Real Market Interest Rate Gap (%)');
x.series('', s.(listshocks{i}).RR_m_gap);

x.graph('Real Exchange Rate Gap (%)');
x.series('', s.(listshocks{i}).L_Z_gap);

end

% x.figure('Nominal Exchange Rate Depreciation, %QoQ', 'subplot', [3,2], 'style', sty, 'range', startsim:endsim, 'marks',{'Open Capital Market','Relativly Closed','Capital Control'});
% 
% for i = 1:length(listshocks)
% 
% x.graph(listtitles{i},'legend',true);
% x.series('',s.(listshocks{i}).D_L_S);
% 
% end
% 
% x.figure('Real Exchange Rate gap, p.p', 'subplot', [3,2], 'style', sty, 'range', startsim:endsim, 'marks',{'Open Capital Market','Relativly Closed','Capital Control'});
% 
% for i = 1:length(listshocks)
% 
% x.graph(listtitles{i},'legend',true);
% x.series('',s.(listshocks{i}).L_Z_gap);
% 
% end

x.publish('results/shocks.pdf','display',false);
disp('Done!!!');