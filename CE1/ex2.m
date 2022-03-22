%% ---------------------------------
% Auto Correlation of a PRBS signal
%% ---------------------------------

% paternoster 
close all
clear
clc
addpath("functions")

%% 1. create input PRBS 
x = prbs(6, 4);


%% 2. auto-correlate 
[R, h]   = xcorr(x, x, 'biased');
[RR, hh] = intcor(x, x);

stem(h, R); hold on
stem(hh, RR);
grid on 
legend("xcorr", "intcor")

figure()
stem(hh, RR)
grid on
xlabel("time [s]")
