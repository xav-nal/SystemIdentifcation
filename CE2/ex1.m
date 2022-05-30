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
make_fig([], [], [], "FIR Model impulse response")
errorshade(time(1:K), theta, 2*sigma_theta) % 95% confidence interval
legend('impulse response $\theta$', '$\sigma_{\theta}$ (95\% confidence)', 'Interpreter','latex')


%% 2. ARX model
section('ARX model')
subsection('2nd order ARX')

% make the I/O matrix
Phi     = [[0; -y(1:end-1)], [ 0; 0; -y(1:end-2)], ...
           [0;  u(1:end-1)], [ 0; 0;  u(1:end-2)] ];

% get the ARX predictor via LS algorithm
theta   = (Phi.' * Phi)\(Phi.' * y);

% predict the output using the I/O matrix
y_hat   = Phi * theta;

fprintf("\tThe ARX model is : (%.3f z^-1 %+.3f z^-2)/(1 %+.3f z^-1 %+.3f z^-2)\n", theta(3:4), theta(1:2))

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

% make the I/O matrix based on the ARX model
Phi_iv   = [[0; -ym(1:end-1)], [ 0; 0; -ym(1:end-2)], ...
            [0;  u(1:end-1)],  [ 0; 0;  u(1:end-2)] ]; 

% get the IV predictor via LS algorithm
theta_iv = (Phi_iv.' * Phi)\(Phi_iv.' * y);

fprintf("\tThe IV model is : (%.3f z^-1 %+.3f z^-2)/(1 %+.3f z^-1 %+.3f z^-2)\n", theta_iv(3:4), theta_iv(1:2))


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
% r  = 200; % initial rank assumption -> overfit ? 
r  = 10; % initial rank assumption
ny = 1;
K  = length(u)+1-r;
Y  = zeros(r, K);
U  = zeros(r, K);
for k = 1:K
    Y(:,k) = y(k + (0:r-1));
    U(:,k) = u(k + (0:r-1));
end

U_orth = eye(K) - U.'* ((U*U.') \ U);
Q = Y*U_orth; 
n = rank(Q, norm(Q)/10); % rank() uses svd to estimate the rank
% n = 2; % force rank 
% n = 13; % force rank 
make_fig([],[],[],"SVD of Q")
scatter(1:r, svd(Q), "filled")
xline(n, 'r')
legend("singular values", sprintf("rank=%d", n))
fprintf("The estimated rank is %d\n", n)

% extended observability matrix
O = Q(:,1:n); 

% compute state-space matrices
C = O(1:ny,:);
A = O(1:((r-1)*ny),:) \ O(ny+1:end,:);

% compute input matrix
q = tf('q', 1/fs);
f = C/(q*eye(size(A)) - A);
uf = zeros(length(time), n);
for i = 1:n
    uf(:,i) = lsim(f(i), u, seconds(time));
end
Phi = [uf, u].';

theta = (y.'/Phi).';
B = theta(1 : (end-size(u,2)));
D = theta((end-size(u,2)+1) : end);


% simulate using lsim, loss function & plot
G_SS = ss(A, B, C, D, 1/fs);
y_m_SS = lsim(G_SS, u);
J = sum((y - y_m_SS).^2);
fprintf("\tWhen simulating SS, the loss function J is  \t%7.3f\n", J)
labels = {'$y$',  '$\hat{y}_{m, SS}$'};
make_fig(time, [y, y_m_SS], labels, "SS Model output")