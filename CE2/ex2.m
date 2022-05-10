%% ---------------------------------
%  model identifcation
%% ---------------------------------

% paternoster 
close all
clear
clc
addpath("functions")
addpath("data")


global sect_counter subsect_counter
sect_counter = 0;
subsect_counter = 0;

%% 0. load data & preprocessing

load("data\CE2.mat")
N       = length(u);            % [samples]
fs      = 1/Ts;                 % [Hz]
time    = seconds([0:N-1]/fs)'; % [s]

y = detrend(y, 0);
io_data = iddata(y, u, Ts, 'Name', 'Flexible Link', 'InputName', 'Current', 'OutputName', 'Motor Angle');


%% 1. Order Estimation
section 'Order Estimation'
N_max = 10;

%% ARX order estimation
subsection 'ARX order estimation'

model_arx = cell(N_max,1);
for n = 1:N_max
    model_arx{n} = arx(io_data, [n, n, 1]);
end
loss = cellfun(@(M) (M.EstimationInfo.LossFcn), model_arx);
dloss = abs(diff(loss));
n = find(dloss > .1*max(dloss), true, 'last');

% plot loss function in function of order
% figure()
make_fig([],[],[], "ARX Order vs. Loss")
bar(loss)
xline(n, 'r')
legend("loss", "estimated order")
xlabel("order")


%% ARMAX validation
subsection 'ARMAX validation'

model_armax = cell(4,1);
for n_check = (n-1):(n+2)
    model_armax{n_check-n+2} = armax(io_data, [n_check, n_check, n_check, 1]);

    fig = figure();
    fig.Name = sprintf("ARMAX order %d Zero/Poles", n_check);
    h = iopzplot(model_armax{n_check-n+2});
    showConfidence(h, 2);
    a = gca();
    a.Title.String = sprintf("%s (%s)", a.Title.String, fig.Name);
    % axis([-1, 1, -1, 1])
    axis equal
end



%% delay
% 
% M30 = oe(io_data, [100, 0, 1]); % 30 parameters random
% stairs(M30.b)
% [M30.b(1:5); % values 
%     2*M30.db(1:5)] % 2sigma (95% confidence, deviation of values 

% THERE IS ALWAYS ONE LEADING ZERO DUE TO THE SAMPLING DELAY : DO NOT COUNT
% IT 






%% 1. Parametric Identification
section('Parametric Identification')


%% estimation of nb 
% Mb2 = arx(Z, [3 2 2]), J2 = Mb2.EstimationInfo.LossFcn
% Mb1 = arx(Z, [3 1 2]), J1 = Mb1.EstimationInfo.LossFcn
% 
% % chose the model which gives the smaller loss -> this is nb
% 
% %% estimation of na
% % do the same but 
% Mb2 = arx(Z, [1 2 2]), J2 = Mb2.EstimationInfo.LossFcn
% Mb1 = arx(Z, [2 2 2]), J1 = Mb1.EstimationInfo.LossFcn
% Mb1 = arx(Z, [3 2 2]), J1 = Mb1.EstimationInfo.LossFcn


%% using struc
% can identify 1000 models 
% used to prepare structure alkfda lkdsjaéksfélsakdf ka a

% N_max = 20;
% nn = struc(1:N_max, 1:N_max, 1:N_max);
% V = arxstruc(io_data, io_data, nn);
% selstruc(V)

% use the function 
% figure(); compare(Z, model1, model2, model3) 


% spectral analysis : spa(Z, 100) -> compare with Mspa as the first model

