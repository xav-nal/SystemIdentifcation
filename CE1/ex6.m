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

%% 1. generate random siganl
N = 2000; 
u = randi([0,2*u_sat], [N,1]) -u_sat;

time    = seconds(Te*(0:(N-1))).';
T_end   = seconds(time(end));

simin  = timetable(time, u);

% do simulation
simout = sim('model1');

%% 2. compute the requency response using spectral analysis

FU = fft(u, [], 1);
FY = fft(simout.y.Data, [], 1);

FG1 = FY./FU;
f = linspace(0, 2*pi*(N-1)/N/Te, N);
freq_model1 = frd(FG1, f);


%% 3. Compute the same using Hahn or Hamming window

win = hamming(length(u));

FU = fft(win.*u, [], 1);
FY = fft(win.*simout.y.Data, [], 1);

FG2 = FY./FU;
freq_model2 = frd(FG2, f);


%% 4. average over M groups 
M = 10;
NN = N/M;

uu = reshape(u, [], M);
yy = reshape(simout.y.Data, [], M);

FU = mean(fft(uu, [], 1), 2);
FY = mean(fft(yy, [], 1), 2);

FG3 = FY./FU;
f = linspace(0, 2*pi*(NN-1)/NN/Te, NN);
freq_model3 = frd(FG3, f);

%%
win = hamming(NN);
uuw = win .* uu;
yyw = win .* yy;

FU = mean(fft(uuw, [], 1), 2);
FY = mean(fft(yyw, [], 1), 2);

FG4 = FY./FU;
f = linspace(0, 2*pi*(NN-1)/NN/Te, NN);
freq_model4 = frd(FG4, f);



%% 5. compare bode plot to true model 

sys_disc     = c2d(tf([-1, 2], [1, 1.85, 4]), Te, 'zoh');

figure()
h = bodeplot(sys_disc, 'k', freq_model1, 'r', freq_model2, 'b', freq_model3, 'g'); 
%h = bodeplot(sys_disc, 'k', freq_model3, 'gx-'); 
setoptions(h, 'FreqUnits', 'Hz', 'PhaseUnits', 'Rad', 'ConfidenceRegionNumberSD', 3)
title("u = randi Fourier Analysis")
legend("true freq. resp.", "sqare window", "Hann window", "Averaging", 'location', 'best')
grid on

figure()
h = bodeplot(sys_disc, 'k', freq_model3, 'rx-', freq_model4, 'gx-');
setoptions(h, 'FreqUnits', 'Hz', 'PhaseUnits', 'Rad', 'ConfidenceRegionNumberSD', 3)
legend("true freq. resp.", "avg ", "avg + Hann window")

%% for lols : impulse response 
% impulse_true = Te*impulse(sys_disc, T_end); % account for saturation and stuff
% 
% figure()
% plot(time, impulse_true, 'k', LineWidth=1.5), hold on
% plot(time(1:N), ifft(FG), 'r')
% legend("true system response",  sprintf("PRBS(%d,%d) fourier resp.", 8, P))
% title("Impulse response by Fourier Analysis methods")
% xlim(seconds([0, Te*N]))
% grid on