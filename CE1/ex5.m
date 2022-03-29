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

FR = FY./FU;


%% 3. Compute a frequency vector associated to the computed values

f = linspace(0, 2*pi*(N-1)/N/Te, N);


%% 4. Generate a frequency-domain model in Matlab 

freq_model = frd(FR, f);


%% 5. compare bode plot to true model 

sys_disc     = c2d(tf([-1, 2], [1, 1.85, 4]), Te, 'zoh');

figure()
h = bodeplot(sys_disc, 'k', freq_model, 'r');
setoptions(h, 'FreqUnits', 'Hz', 'PhaseUnits', 'Rad', 'ConfidenceRegionNumberSD', 3)
title(sprintf("PRBS(%d,%d) Fourier Analysis", 8, P))
legend("true freq. resp.", "identified freq. resp.", 'location', 'best')
grid on


%% for lols : impulse response 
impulse_true = Te*impulse(sys_disc, T_end); % account for saturation and stuff

figure()
plot(time, impulse_true, 'k', LineWidth=1.5), hold on
plot(time(1:N), real(ifft(FR)), 'r')
legend("true system response",  sprintf("PRBS(%d,%d) fourier resp.", 8, P))
title("Impulse response by Fourier Analysis methods")
xlim(seconds([0, Te*N]))
grid on