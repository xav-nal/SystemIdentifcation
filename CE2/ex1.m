%% ---------------------------------
%  model identifcation
%% ---------------------------------

% paternoster 
close all
clear
clc
addpath("functions")
addpath("data")


%% 0. load data 

load("data\laserbeamdataN2.mat")
N       = length(u);
fs      = 1e3; % [Hk]
time    = seconds([0:N-1]/fs)';

%% 1. FIR model

K       = 50; % response length
U       = toeplitz(u, [u(1), zeros(1, length(u)-1)]);
Phi     = U(:, 1:K);

% get the FIR predictor via LS algorithm
theta   = (Phi.' * Phi)\(Phi.' * y);
% g = Phi \ y; % using the deconvolution method from CE1

% predict the output
y_hat   = Phi * theta;

% loss function
J       = sum((y - y_hat).^2);
fprintf("the value of the loss function J is %.3f\n", J)

% estimation of the noise variance 
sigma_noise = sqrt(J/(N-K));

% covariance of the estimate
sigma_theta = sigma_noise * sqrt(diag(inv(Phi.'*Phi)));

% plot the predicted vs. true output
figure(1), clf
plot(time, y), hold on,
plot(time, y_hat)
legend("$y$",  sprintf('$\\hat{y}$ (K=%d)', K), 'Interpreter','latex')
title("FIR Model output")
ylabel("y")
grid on

% plot the impulse response 
figure(2), clf
errorbar(time(1:K), theta, sigma_theta)
legend('impulse response $\theta$', 'Interpreter','latex')
title("FIR Model impulse response")
ylabel("y")
grid on



%% 2. ARX model
