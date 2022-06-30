addpath("functions")
paternoster

%% 0.1 remove previous figures 

% imgs = dir(fullfile('img', '*.png'));
% for i = 1:length(imgs)
delete('img\*')
% end

%% 0.2 load data 

% load("data\gyro400.mat")
% load("data\data4.mat")
load("data\data12.mat")

N       = length(u);            % [samples]

if ~exist('Ts', 'var') || isempty(Ts)
    Ts      = 20e-3;            % [s]
end
if ~exist('fs', 'var') || isempty(fs)
    fs      = 1/Ts;             % [Hz]
end

time    = seconds(Ts*(0:N-1))'; % [s]

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