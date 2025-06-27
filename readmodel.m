function [m,p,mss] = readmodel()
% PARAMETRIZE AND SOLVE THE MODEL

%% === Steady state parameters ===

% Potential output growth
p.ss_D_L_GDP_bar = 1.75;
%p.ss_D_L_D_bar = 1.75;
%p.ss_D_L_Ex_bar = 1.25;
%p.ss_D_L_Im_bar = 1.25;
%p.ss_D_L_L_bar = 0.5;

% Domestic inflation target
p.ss_D4_L_CPI_tar = 4; 

% Domestic real interest rate 
p.ss_RR_bar = 4; 
p.ss_RPM_bar = 2;

% Change in the real ER (negative number = real appreciation)
p.ss_D_L_Z_bar = 0.75; 

% Change in the real oil price
p.ss_D_L_ToT_bar = 0.0;

% Foreign inflation or inflation target
p.ss_D_L_CPI_f = 2;

% Level of foreign real interest rate
p.ss_RR_f_bar = 0.25;

%% === Typical and specific parameter values be used in calibrations === 

p.d_lag = 0.5;
p.d_lead = 0.2;
p.d_r = -0.15;
p.d_Poil = 0.015;
p.d_z = 0.04;
p.d_budg = -0.4;

p.x_lag = 0.5;
p.x_f = 0.08;
p.x_z = 0.05;
p.x_Poil = 0.01;

p.m_lag = 0.35;
p.m_d = 0.9;
p.m_z = -0.3;

p.w_ex = 0.278; %0.313; 
p.w_im = -0.176; %-0.203; 
p.w_d = 1-p.w_ex-p.w_im;
% p.ss_D_L_GDP_bar = p.w_d*p.ss_D_L_D_bar + p.w_ex*p.ss_D_L_Ex_bar + p.w_im*p.ss_D_L_Im_bar;
% p.ss_w_d = 0.96;
% p.ss_w_ex = 0.27;
% p.ss_w_im = -0.23;

% p.rho_w_d = 0.8;
% p.rho_w_ex = 0.8;
% p.rho_w_im = 0.8;

% p.a_calvo = 0.7;
% p.a_gdp = 0.14;
% p.a_z = 0.06;

p.a_calvo_core = 0.4;
p.a_gdp_core = 0.3;
p.a_z_core = 0.14;
p.w_cpi_core = 0.85;

%p.w_rational = 0.5;
% p.w_rational_cpi = 0.5;
p.w_r_cpi_core = 0.5;
p.w_r_s = 0.8;

p.w_i_m = 0.5;

p.p_lag = 0.75;
p.p_inf = 1.75; 
p.p_gdp = 0.5;

%p.w_cc = [0 0.35 0.75];
p.w_cab = 0.5;
p.s_cab = -0.4;
p.s_Poil = 0.33;

p.rho_D4_L_CPI_tar = 0.95; 
p.rho_D_L_Z_bar   = 0.8;
p.rho_D_L_ToT_bar = 0.8;
p.rho_L_ToT_gap = 0.8;
p.rho_D_L_GDP_bar = 0.8;
%p.rho_D_L_D_bar = 0.8;
%p.rho_D_L_Ex_bar = 0.8;
%p.rho_D_L_Im_bar = 0.8;
p.rho_RR_bar      = 0.8;
p.rho_RR_f_bar   = 0.8;
p.rho_L_GDP_f_gap = 0.8;
p.rho_NR_f      = 0.8;
p.rho_D_L_CPI_f = 0.8;

% p.rho_w_cpi_core = 0.8;
% % p.rho_w_cpi_s = 0.8;
% p.rho_w_cpi = 0.8;

p.rho_RPM_bar = 0.8;
p.rho_RPM_gap = 0.8;
p.rho_w_cc = 0.9;
p.rho_budg = 0.8;
p.rho_cpi_vol = 0.8;


%% === Solving the model === 
% 1) command 'model' reads the text file 'model.model' (contains the model's equations), 
% assigns the parameters and steady state values from database 'p' (see above),
% and transforms the model for the matrix algebra. Transformed model is written in the object 'm'. 
m = model('model.model','linear=',true,'assign',p);

% 2) command 'solve' takes the model object 'm' and solves the model
% for its reduced form (Blanchard-Kahn algorithm). The reduced form is again written in the object 'm'   
m = solve(m);

% 3) command 'sstate' further takes the model object 'm', calculates the model's
% steady-state and writes everything back in the object 'm'. 
m = sstate(m);


%% === Information which can be extracted from the model object === 
% a) extract steady-state values
mss = get(m,'sstate');

% b) extract comments on all variables and parameters
desc = get(m,'desc');

% c) extract list of variables'/parameters' names
ynames = get(m,'yList'); %- measuments variables
xnames = get(m,'xList'); %- transition variables
enames = get(m,'eList'); %- shocks
enames = get(m,'pList'); %- parameters

% d) extract list of equations
yeqtn = get(m,'yEqtn'); %- measuments equations
xeqtn = get(m,'xEqtn'); %- transition equations

% e) a database with current std deviations of shocks
std = get(m,'std');  

% f) maximum lead/lag in the model
maxlead = get(m,'maxLead');
maxlag = get(m,'maxLag');

% g) to find out more, type: help model.get


%% === Check steady state === 
[flag,discrep,eqtn] = chksstate(m,'error',false);

if ~flag
  error('Equation fails to hold in steady state: "%s"\n', eqtn{:});
end

%% === Save the model info file ===

m = solve(m);

save results/model.mat m

%% END