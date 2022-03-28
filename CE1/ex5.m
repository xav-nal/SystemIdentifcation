%% ---------------------------------
%  Frequency domain Identfication (Periodic signal)
%% ---------------------------------

% paternoster 
close all
clear
clc
addpath("functions")

%% 0. simulation params
Te      = 0.1; % [s]    sampling time 
u_sat   = 0.5;
P       = 8;   % [-]    number of periods in the PRBS

%% 1. generate PRBS input signal and apply to system
u       = u_sat * prbs(8, P);
time    = seconds(Te*(0:(length(u)-1)))';
T_end   = seconds(time(end));

simin  = timetable(time, u);

% do simulation
simout = sim('model1');

%% 2. compute the Fourier transform of the input and output signal
N = length(u)/P;

FU = mean(fft(reshape(u, N, P), [], 1), 2);
FY = mean(fft(reshape(simout.y.Data, N, P), [], 1), 2);


%% 3. Compute a frequency vector associated to the computed values

f = linspace(0, (N-1)/N/Te, N);
plot(f, abs(FY))


%% 4. Generate a frequency-domain model in Matlab 
