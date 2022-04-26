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
Phi     = toeplitz(u, [u(1), zeros(1, K-1)]);

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

Phi     = [[0; -y(1:end-1)], [ 0; 0; -y(1:end-2)], ...
           [0;  u(1:end-1)], [ 0; 0;  u(1:end-2)] ];

theta   = (Phi.' * Phi)\(Phi.' * y);

y_hat   = Phi * theta;

% loss function
J       = sum((y - y_hat).^2);
fprintf("the value of the loss function J is %.3f\n", J)

% plot the predicted vs. true output
figure(3), clf
plot(time, y), hold on,
plot(time, y_hat)
legend("$y$",  sprintf('$\\hat{y}$ (K=%d)', K), 'Interpreter','latex')
title("ARX Model output")
ylabel("y")
grid on

%% simulate 
G = tf([0 theta(3), theta(4)], [1 theta(1), theta(2)], 1/fs, 'Variable','z^-1');
ym = lsim(G, u);

figure(4), clf
plot(time, y), hold on
plot(time, ym)
legend("$y$",  '$\hat{y}_m$', 'Interpreter','latex')
title("lsim output")
ylabel("y")
grid on

