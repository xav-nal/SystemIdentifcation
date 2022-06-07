%% ---------------------------------
%  Parametric Identification
%% ---------------------------------

% paternoster 
close all
clear
clc
addpath("functions")
addpath("data")

plotting = false;
% plotting = true;

global sect_counter subsect_counter
sect_counter = 0;
subsect_counter = 0;

%% 0. load data & preprocessing

load("data\CE2.mat")
N       = length(u);            % [samples]
fs      = 1/Ts;                 % [Hz]
time    = seconds([0:N-1]/fs)'; % [s]

y = detrend(y, 0);
% y = y - y(1);
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
% n = find(dloss > .1*max(dloss), true, 'last');
n = 6; % override auto thingy
fprintf("\tARX order estimated as %d\n", n)

% plot loss function in function of order
if plotting 
    make_fig([],[],[], "ARX Order vs. Loss")
    scatter(1:length(loss), loss)
    xline(n, 'r')
    legend("loss", "estimated order")
    xlabel("order")
end 


%% ARMAX validation
subsection 'ARMAX validation'

model_armax = cell(4,1);
for n_check = (n-1):(n+2)
    model_armax{n_check-n+2} = armax(io_data, [n_check, n_check, n_check, 1]);

    % check if there are any Zero/Pole cancellations -> this is done visually. 
    % If there is a cancellation / near cancellation, we know the order is too high
    if plotting 
        fig = figure();
        fig.Name = sprintf("ARMAX order %d Zeroes/Poles", n_check);
        h = iopzplot(model_armax{n_check-n+2});
        showConfidence(h, 2);
        a = gca();
        a.Title.String = sprintf("%s (%s)", a.Title.String, fig.Name);
        % axis([-1, 1, -1, 1])
        axis equal
    end 
end
fprintf("\tplease check the figures for Zero/Pole cancellation\n")

%% estimate delay
subsection 'estimate delay'

model_oe = oe(io_data, [50, 0, 1]);

% using the coefficients of B
% THERE IS ALWAYS ONE LEADING ZERO DUE TO THE SAMPLING DELAY : DO NOT COUNT IT 
nk = find(abs(model_oe.b(2:end)) > .1*max(abs(model_oe.b)), true, 'first'); 

if isempty(nk), nk = inf; end

fprintf("\testimated delay is %d sample(s)\n", nk-1)

if plotting 
    figure()
    errorshade([0:(length(model_oe.b)-1)], model_oe.b, 2*model_oe.db)
    xline(nk, 'r')
    legend('B', '$\sigma_B$ (95\% confidence)', 'delay $n_k$', 'Interpreter','latex')
end 

% estimation of nb 
model_arx_nb = cell(n-1+1, 1);
for nb = 1:n-1+1
    model_arx_nb{nb} = arx(io_data, [n, nb, 1]);
end
loss = cellfun(@(M) (M.EstimationInfo.LossFcn), model_arx_nb);
[~, nb] = min(loss);
fprintf("\torder of nb for minimum loss is %d\n", nb)

% estimation of na 
na = n;

%% comparison using selstruc
subsection 'comparison using selstruc'

nn = struc(1:N_max, 1:N_max, 1:N_max);
V = arxstruc(io_data, io_data, nn);

% prompt user to select the model to use
if plotting
    nn = selstruc(V);
else
    nn = [10, 10, 2];
end

if ~isempty(nn) 
    fprintf("\tselected ARX model is: [%d, %d, %d]\n", nn)
else 
    fprintf("\tEnding program\n")
    return;
end

% set the selstruc model as the model to test
% na = nn(1); 
% nb = nn(2);
% nk = nn(3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Parametric Identification
section 'Parametric Identification'

% prepare data
subsection 'divide data into identification / validation'
split_idx = round(1/2*length(y));
% split_idx = round(3/4 * length(y));

% identification data
idt_u = u(1:split_idx);
idt_y = detrend(y(1:split_idx),0);
idt_data = iddata(idt_y, idt_u , Ts, 'Name', 'Flexible Link Identification', 'InputName', 'Current', 'OutputName', 'Motor Angle');

% validation data
val_u = u(split_idx+1:end);
val_y = detrend(y(split_idx+1:end),0);
val_data = iddata(val_y, val_u , Ts, 'Name', 'Flexible Link Validation', 'InputName', 'Current', 'OutputName', 'Motor Angle');

fprintf("\tdone\n")

%% other parametric models 
subsection 'create other parametric models '

% set unset orders for parametric models
nc = na;
nd = na;
nf = na;

% create parametric models 
model_arx    = arx(idt_data, [na, nb, nk]);
% model_iv4    = iv4(idt_data, [na, nb, nk], iv4Options('EnforceStability', true)); % this causes mysterious toolbox errors
model_iv4    = iv4(idt_data, [na, nb, nk]);
model_armax  = armax(idt_data, [na, nb, nc, nk]);
model_oe     = oe(idt_data, [nb, nf, nk]);
model_bj     = bj(idt_data, [nb, nc, nd, nf, nk]);
model_n4sid  = n4sid(idt_data, n);

% prepare for plotting 
models = {model_arx, model_iv4, model_armax, model_oe, model_bj, model_n4sid};
titles = ["ARX", "IV4", "ARMAX", "OE", "BJ", "N4SID"];

fprintf("\tdone\n")



%% 3. Model Validation 
section 'Model Validation'

%% compare models in the time domain
subsection 'compare models in time domain'

if plotting 
    fig = figure('Name', 'Simulated Response'); 
    compare(val_data, models{:})
    fig.Children(3).String{1} = 'Flexible Link Validation';
    for i = 1:length(models)
        fig.Children(3).String{1+i} = titles(i);
    end
    fprintf("\tdone\n")
else 
    [~, FIT, ~] = compare(val_data, models{:});
    fprintf("\t%s\n", sprintcells('%s : %4.1f%%', {titles{:}}, FIT));
end 


%% compare models in the frequency domain
subsection 'compare models in frequency domain'

% spectrum of the validation data using a large Hann window
model_spa = spa(val_data, 1000); % manually change the Hann used to length M

if plotting 
    fig = figure('Name', 'Frequency Response'); 
    compare(model_spa, models{:}) 
    fig.Children(3).String{1} = 'Flexible Link Validation';
    for i = 1:length(models)
        fig.Children(3).String{1+i} = titles(i);
    end
    fprintf("\tdone\n")
else 
    [~, FIT, ~] = compare(model_spa, models{:});
    fprintf("\t%s\n", sprintcells('%s : %4.1f%%', {titles{:}}, FIT));
end 



%% check whiteness of residuals 
subsection 'check whiteness of residuals'

if plotting 
    figure('Name', 'Residuals')
    resid(val_data, models{:})
    legend(titles)
    
%     for i = 1:length(models)
%         figure('Name', titles{i});
%         resid(val_data, models{i});
%     end 
else 
    is_OK = cell(size(models));
    for i = 1:length(models)
        [~, R] = resid(val_data, models{i});
        Rnorm  = R(:,1,1)./max(R(:,1,1));
        e      = std(Rnorm);
        if any(abs(Rnorm(2:end)) > 2*e)
            is_OK{i} = "not OK";
        else 
            is_OK{i} = "OK";
        end
    end 
    fprintf("\t%s\n", sprintcells('%s is %s', {titles{:}}, is_OK));
end 


