%% ---------------------------------
%  model identifcation
%% ---------------------------------

% paternoster 
close all
clear
clc
addpath("functions")
addpath("data")


global sect_counter subsect_counter
sect_counter = 0;
subsect_counter = 0;

%% 0. load data 

load("data\laserbeamdataN2.mat")
N       = length(u);            % [samples]
fs      = 1e3;                  % [Hz]
time    = seconds([0:N-1]/fs)'; % [s]

%% 1. FIR model
section('FIR model')

K       = 50; % response length
Phi     = toeplitz(u, [u(1), zeros(1, K-1)]);

% get the FIR predictor via LS algorithm
theta   = (Phi.' * Phi)\(Phi.' * y);
% g = Phi \ y; % using the deconvolution method from CE1

% predict the output
y_hat   = Phi * theta;

% loss function
J       = sum((y - y_hat).^2);
fprintf("\tThe value of the loss function J for the FIR is %7.3f\n", J)

% estimation of the noise variance 
sigma_noise = sqrt(J/(N-K));

% covariance of the estimate
sigma_theta = sigma_noise * sqrt(diag(inv(Phi.'*Phi)));

% plot the predicted vs. true output
labels = {'$y$',  sprintf('$\\hat{y}$ (K=%d)', K)};
make_fig(time, [y, y_hat], labels, "FIR Model output")


% plot the impulse response 
make_fig([], [], [], 2, "FIR Model impulse response")
errorbar(time(1:K), theta, sigma_theta)
legend('impulse response $\theta$', 'Interpreter','latex')


%% 2. ARX model
section('ARX model')
subsection('2nd order ARX')

Phi     = [[0; -y(1:end-1)], [ 0; 0; -y(1:end-2)], ...
           [0;  u(1:end-1)], [ 0; 0;  u(1:end-2)] ];

theta   = (Phi.' * Phi)\(Phi.' * y);

y_hat   = Phi * theta;

% loss function
J       = sum((y - y_hat).^2);
fprintf("\tWhen using the data, the loss function J is \t%7.3f\n", J)

% plot the predicted vs. true output
labels = {'$y$',  '$\hat{y}_{ARX}$'};
make_fig(time, [y, y_hat], labels, 3, "ARX Model output")

% simulate using lsim, loss function & plot
G = tf([0 theta(3), theta(4)], [1 theta(1), theta(2)], 1/fs, 'Variable','z^-1');
ym = lsim(G, u);
J = sum((ym-y).^2);
fprintf("\tWhen simulating ARX, the loss function J is \t%7.3f\n", J)

label = {'$y$',  '$\hat{y}_m$'};
make_fig(time, [y, ym], labels, "ARX lsim output")


% instrumental variables method 
subsection('IV model based on ARX')

Phi_iv   = [[0; -ym(1:end-1)], [ 0; 0; -ym(1:end-2)], ...
            [0;  u(1:end-1)],  [ 0; 0;  u(1:end-2)] ]; 
theta_iv = (Phi_iv.' * Phi)\(Phi_iv.' * y);

% simulate using lsim, loss function & plot
G_iv = tf([0 theta_iv(3), theta_iv(4)], [1 theta_iv(1), theta_iv(2)], 1/fs, 'Variable','z^-1');
y_m_iv = lsim(G_iv, u);
J = sum((y - y_m_iv).^2);
fprintf("\tWhen simulating IV, the loss function J is  \t%7.3f\n", J)

% plot the simulated IV vs. simulated ARX vs. true output
labels = {'$y$',  '$\hat{y}_{m, ARX}$', '$\hat{y}_{m, iv}$'};
make_fig(time, y_m_iv, labels, 4, "ARX and IV Model output")


%% 3. State Space model
section('State Space Model')

% construct matrices 

