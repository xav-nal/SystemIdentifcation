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

%% 1. generate random siganl
N = 2000; 
u = randi([0,2*u_sat], [N,1]) -u_sat;

time    = seconds(Te*(0:(N-1))).';
T_end   = seconds(time(end));

simin  = timetable(time, u);

% do simulation
simout = sim('model1');
y = simout.y.Data;

%% 2. compute the requency response using spectral analysis

[PSD_U, f] = intpsd(u, u, [], Te);
PSD_Y      = intpsd(y, u, [], Te);

G1 = PSD_Y./PSD_U;

freq_model1 = frd(G1(1:floor(N/2)), f(1:floor(N/2)));


%% 3. Compute the same using Hann or Hamming window

win = hann(N);

[PSD_UW, f] = intpsd(u, u, win, Te);
PSD_YW      = intpsd(y, u, win, Te);

G2 = PSD_YW./PSD_UW;

freq_model2 = frd(G2(1:floor(N/2)), f(1:floor(N/2)));


%% 4. average over M epochs 
M = 10; % number of epochs

uu = reshape(u, [], M);
yy = reshape(y, [], M);

[PSD_UM, f] = intpsd(uu, uu, [], Te);
PSD_UM = mean(PSD_UM, 2);  % average the inputs
PSD_YM = mean(intpsd(yy, uu, [], Te), 2); % average the outputs

G3 = PSD_YM./PSD_UM;

freq_model3 = frd(G3(1:floor(N/M/2)), f(1:floor(N/M/2)));


%% 5. compare bode plot to true model 

sys_disc     = c2d(tf([-1, 2], [1, 1.85, 4]), Te, 'zoh');

figure()
h = bodeplot(sys_disc, 'k', freq_model1, 'r', freq_model2, 'b', freq_model3, 'g'); 
setoptions(h, 'FreqUnits', 'Hz', ...
              'PhaseUnits', 'Rad', ...
              'PhaseMatching', 'on', ...
              'PhaseMatchingFreq', 0, ...
              'PhaseMatchingValue', 2*pi, ...
              'Grid', 'on', ...
              'ConfidenceRegionNumberSD', 3)
title("random excitation spectral analysis")
legend("true freq. resp.", "truncation", "Hann window", "averaging", 'location', 'best')
ylim([-10, 20])
%grid on

% figure()
% h = bodeplot(sys_disc, 'k', freq_model3, 'rx-', freq_model4, 'gx-');
% setoptions(h, 'FreqUnits', 'Hz', 'PhaseUnits', 'Rad', 'ConfidenceRegionNumberSD', 3)
% legend("true freq. resp.", "avg ", "avg + Hann window")

%% for lols : impulse response 
impulse_true = Te*impulse(sys_disc, T_end); % account for saturation and stuff

figure()
plot(time, impulse_true, 'k', LineWidth=1.5), hold on
plot(time(1:length(G1)), ifft(G1), 'r', time(1:length(G2)), ifft(G2), 'b', time(1:length(G3)), ifft(G3), 'g')
legend("true impulse resp.", "truncation impulse resp.", "Hann impulse resp.", "averaging impulse resp.", 'location', 'best')
title("Impulse response by spectral analysis methods")
xlim(seconds([0, 20]))
grid on
set(findobj('color','g'),'Color',[0 0.75 0]); % fix ugly default green
