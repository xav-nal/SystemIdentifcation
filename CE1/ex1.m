clear
close all
clc

% simulation params
Te      = 0.1; % [s]    sampling time 
T_end   = 10;  % [s]    simulation duration
T_event = 1;   % [s]    time of event

time = seconds(0:Te:T_end).';

%% step response
% setup simulation
u_sat = 0.5; % [V]
data = ones(size(time));
data(time < seconds(T_event)) = 0;
simin = timetable(time, data);

% do simulation
simout1 = sim('model1');

% plot simulation output
plot(simout1)

%% impulse response 
% setup simulation
data = zeros(size(time));
data(time == seconds(T_event)) = 1;
simin = timetable(time, data);

% do simulation
simout2 = sim('model1');

% plot simulation output
plot(simout2)

%% plot
% plot(time, simout1.y.Data)
% hold on
% plot(time, simout2.y.Data)
