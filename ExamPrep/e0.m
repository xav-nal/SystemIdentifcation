addpath("functions")
paternoster


%% 0. load data 

load("data\gyro400.mat")
N       = length(u);            % [samples]
Ts      = 20e-3;                % [s]
fs      = 1/Ts;                 % [Hz]
time    = seconds((0:N-1)/fs)'; % [s]

in_name  = 'u';
in_U     = {'-'};
out_name = 'y';
out_U    = {'-'};

%%
e01

%%
e02

%%
e03

%% 
e04

%%
e05

%%