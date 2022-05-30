%% ---------------------------------
%  Parametric Identification
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

%% 0. load data & preprocessing

load("data\CE2.mat")
N       = length(u);            % [samples]
fs      = 1/Ts;                 % [Hz]
time    = seconds([0:N-1]/fs)'; % [s]

y = detrend(y, 0);
io_data = iddata(y, u, Ts, ...
            'Name', 'Flexible Link', ...
            'InputName', 'Current', ...
            'OutputName', 'Motor Angle');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Order Estimation
section 'Order Estimation'
N_max = 10;

%% ARX order estimation
subsection 'ARX order estimation'

model_arx = cell(N_max,1);
for n = 1:N_max
    model_arx{n} = arx(io_data, [n, n, 1]);
end
loss = cellfun(@(M) (M.EstimationInfo.LossFcn), model_arx);
dloss = abs(diff(loss));
n = find(dloss > .1*max(dloss), true, 'last');
n = 8; % override auto thingy
fprintf("\tARX order estimated as %d\n", n)

% plot loss function in function of order
make_fig([],[],[], "ARX Order vs. Loss")
scatter(1:length(loss), loss)
xline(n, 'r')
legend("loss", "estimated order")
xlabel("order")


%% ARMAX validation
subsection 'ARMAX validation'

model_armax = cell(4,1);
for n_check = (n-1):(n+2)
    model_armax{n_check-n+2} = armax(io_data, [n_check, n_check, n_check, 1]);

    % check if there are any Zero/Pole cancellations -> this is done visually. 
    % If there is a cancellation / near cancellation, we know the order is too high
    fig = figure();
    fig.Name = sprintf("ARMAX order %d Zeroes/Poles", n_check);
    h = iopzplot(model_armax{n_check-n+2});
    showConfidence(h, 2);
    a = gca();
    a.Title.String = sprintf("%s (%s)", a.Title.String, fig.Name);
    % axis([-1, 1, -1, 1])
    axis equal
end
fprintf("\tplease check the figures for Zero/Pole cancellation\n")

%% estimate delay
subsection 'estimate delay'

model_oe = oe(io_data, [50, 0, 1]);

% using the coefficients of B
% THERE IS ALWAYS ONE LEADING ZERO DUE TO THE SAMPLING DELAY : DO NOT COUNT IT 
nk = find(abs(model_oe.b(2:end)) > .1*max(abs(model_oe.b)), true, 'first'); 

if isempty(nk), nk = 0; end

fprintf("\testimated delay is %d sample(s)\n", nk)

figure()
errorshade([0:(length(model_oe.b)-1)], model_oe.b, 2*model_oe.db)
xline(nk, 'r')
legend('B', '$\sigma_B$ (95\% confidence)', 'delay $n_k$', 'Interpreter','latex')

% estimation of nb 
model_arx_nb = cell(n-1+1, 1);
for nb = 1:n-1+1
    model_arx_nb{nb} = arx(io_data, [n, nb, 1]);
end
loss = cellfun(@(M) (M.EstimationInfo.LossFcn), model_arx_nb);
[~, nb] = min(loss);
fprintf("\torder of nb for minimum loss is %d\n", nb)

%% comparison using selstruc
subsection 'comparison using selstruc'

nn = struc(1:N_max, 1:N_max, 1:N_max);
V = arxstruc(io_data, io_data, nn);

% prompt user to select the model to use
nn = selstruc(V);
fprintf("\tselected ARX model is: [%d, %d, %d]\n", nn)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Parametric Identification
section 'Parametric Identification'

% prepare data
subsection 'divide data into identification / validation'
split = round(3/4*length(y));
idt_data = iddata(detrend(y(1:split),0), u(1:split), Ts, 'Name', 'Flexible Link Identification', 'InputName', 'Current', 'OutputName', 'Motor Angle');
val_data = iddata(detrend(y(split+1:end),0), u(split+1:end), Ts, 'Name', 'Flexible Link Validation', 'InputName', 'Current', 'OutputName', 'Motor Angle');
fprintf("\tdone\n")

% other parametric models 
subsection 'compare other parametric models '

na = nn(1);
nb = nn(2);
nk = nn(3);
nc = na;
nd = na;
nf = na;
% na = 4;
% nb = 4;
% nk = 1;
% nc = na;
% nd = na;
% nf = na;


model_arx    = arx(idt_data, [na, nb, nk]);
% model_iv4    = iv4(idt_data, [na, nb, nk], iv4Options('EnforceStability', true));
model_iv4    = iv4(idt_data, [na, nb, nk]);
model_armax  = armax(idt_data, [na, nb, nc, nk]);
model_oe     = oe(idt_data, [nb, nf, nk]);
model_bj     = bj(idt_data, [nb, nc, nd, nf, nk]);
model_n4sid  = n4sid(idt_data, n);

fprintf("\tdone\n")



%% 3. Model Validation 
section 'Model Validation'


%% compare 
subsection 'compare'

figure(); 
compare(val_data, ...
        model_arx, ...
        model_iv4, ...
        model_armax, ...
        model_oe, ...
        model_bj, ...
        model_n4sid) 
fprintf("\tdone\n")

%% frequency response 
subsection 'frequency response'

model_spa = spa(idt_data);

fig = figure(); 
compare(model_spa, ...
        model_arx, ...
        model_iv4, ...
        model_armax, ...
        model_oe, ...
        model_bj, ...
        model_n4sid) 
fig.Children(3).String{1} = 'Flexible Link Validation (Motor Angle)';

fprintf("\tdone\n")


