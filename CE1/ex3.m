%% ---------------------------------
%  IMPULSE RESPONSE BY DECONVOLUTION
%% ---------------------------------

% paternoster 
close all
clear
clc
addpath("functions")

%% 0. simulation params
Te      = 0.1; % [s]    sampling time 
T_end   = 200; % [s]    simulation duration
time    = seconds(0:Te:T_end).'; % [s]
u_sat  = 0.5;

%% 1. generate random input signal
u      = u_sat - 2*u_sat*rand(size(time));


%% 2. construct toeplitz input matrix
U      = toeplitz(u, [u(1), zeros(1, length(time)-1)]);


%% 3. simulate the system
simin  = timetable(time, u);

% do simulation
simout = sim('model1');


%% 4. compute the impulse response using finite numerical deconvolution
K = 100; % arbitrary truncation length

Uk = U(:, 1:K);
impulse_deconv_finite = Uk \ simout.y.Data;


%% 5. compute the impulse response using regularization deconvolution

lambda = 1.2;
impulse_deconv_regul = (U.'*U + lambda*eye(size(U))) \ (U.' * simout.y.Data);


%% 6. compare result to the true impulse response

sys_disc     = c2d(tf([-1, 2], [1, 1.85, 4]), Te, 'zoh');
impulse_true = Te*impulse(sys_disc, T_end); % account for saturation and stuff


% get the 2-norm error (finite response)
err_finite  = impulse_true(1:K) - impulse_deconv_finite(1:K);
err2_finite = norm(err_finite, 2);
% get the 2-norm error (regularization)   
err_regul   = impulse_true(1:K) - impulse_deconv_regul(1:K);
err2_regul  = norm(err_regul, 2);

fprintf("err2 for the finite response deconvolution : %f\n", err2_finite)
fprintf("err2 for the regularization deconvolution : %f\n", err2_regul)

%%

% plot simulation output
figure(1), clf
plot(time(1:length(impulse_true)),    impulse_true, 'k', LineWidth=1.5), hold on
plot(time(1:length(impulse_deconv_regul)),  impulse_deconv_regul,  'b')
plot(time(1:length(impulse_deconv_finite)), impulse_deconv_finite, 'r')

legend("true system response",  sprintf("regularization (\\lambda=%.1f)", lambda), sprintf("finite deconv (K=%d)", K))
title("Impulse response by deconvolution")
ylabel("y")
xlim(seconds([0, 3*Te*K]))
grid on
