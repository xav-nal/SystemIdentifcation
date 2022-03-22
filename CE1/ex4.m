%% ---------------------------------
%  IMPULSE RESPONSE BY CORRELATION
%% ---------------------------------

% paternoster 
close all
clear
clc
addpath("functions")

%% 0. simulation params
Te      = 0.1; % [s]    sampling time 
u_sat   = 0.5;

%% 1. generate PRBS input signal and apply to system
u       = u_sat * prbs(8, 8);
time    = seconds(Te*(0:(length(u)-1)))';
T_end   = seconds(time(end));

simin  = timetable(time, u);

% do simulation
simout = sim('model1');


%% 2. compute impulse response using intcor

K = 200;

% biased estimator 
% [Ryu_i, ~  ] = intcor(simout.y_clean.Data, u);
[Ryu_i, ~  ] = intcor(simout.y.Data, u);
[Ruu_i, h_i] = intcor(u, u);

idx_i = find(h_i>=0, 1) : find(h_i>=(K-1),1);
RUUk_i = toeplitz(Ruu_i(idx_i), Ruu_i(idx_i).');
impulse_deconv_intcor = RUUk_i \ Ryu_i(idx_i);

%% 3. compute impulse response using xcorr

[Ryu_x, ~] = xcorr(simout.y.Data, u, 'biased');
[Ruu_x, h_x] = xcorr(u, u, 'biased');

idx_x = find(h_x>=0, 1) : find(h_x>=(K-1),1);
RUUk_x = toeplitz(Ruu_x(idx_x), Ruu_x(idx_x).');
impulse_deconv_xcorr = RUUk_x \ Ryu_x(idx_x);

%% error
sys_disc     = c2d(tf([-1, 2], [1, 1.85, 4]), Te, 'zoh');
impulse_true = Te*impulse(sys_disc, T_end); % account for saturation and stuff

% get the 2-norm error (finite response)
err_intcor  = impulse_true(1:K) - impulse_deconv_intcor(1:K);
err2_intcor = norm(err_intcor, 2);
% get the 2-norm error (regularization)   
err_xcorr   = impulse_true(1:K) - impulse_deconv_xcorr(1:K);
err2_xcorr  = norm(err_xcorr, 2);

fprintf("err2 for the intcor deconvolution : %f\n", err2_intcor)
fprintf("err2 for the xcorr  deconvolution : %f\n", err2_xcorr)

%% plot

plot(time, impulse_true, 'k', LineWidth=1.5), hold on
plot(Te*h_i(idx_i), impulse_deconv_intcor,  'b', LineWidth=1)
plot(Te*h_x(idx_x), impulse_deconv_xcorr, 'r')

legend("true system response",  sprintf("intcor (K=%d)", K), sprintf("xcorr (K=%d)", K))
title("Impulse response by correlation methods")
xlim(seconds([0, Te*K]))
grid on

