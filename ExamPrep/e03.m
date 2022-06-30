%% ---------------------------------
section System Order
%-----------------------------------


%% ---------------------------------
subsection Global Order Estimation

n_max = 10;

% get loss function for ARX models of different orders
loss = arrayfun(@(n) (arx(io_data, [n, n, 1]).EstimationInfo.LossFcn), 1:n_max);

% try to guess the order from the 'elbow'
dloss = abs(diff(loss));
n = find(dloss > .02*max(dloss), true, 'last');

% output
fprintf("\tARX order estimated as %d\n", n)

% visualize for sanity check
fig = make_fig([],[],[], "ARX Order vs. Loss");
scatter(1:length(loss), loss)
xline(n, 'r')
legend("loss", "estimated order")
xlabel("order"), ylabel('loss')

drawnow
saveas(fig, "img/31_order_estimation.png")


%% ---------------------------------
subsection Global Order Validation

for i = n-1:n+1
    model_armax = armax(io_data, [i, i, i, 1]);

    fig = make_fig([], [], [], sprintf("ARMAX order %d Zeroes/Poles", i));
    showConfidence(iopzplot(model_armax), 2);
    a = gca();
    a.Title.String = sprintf("%s (%s)", a.Title.String, fig.Name);
    
    drawnow
    saveas(fig, sprintf("img/32_ZP_map_%d.png", i))
end

fprintf("\tplease check the figures for Zero/Pole cancellation\n")


%% ---------------------------------
subsection Delay Estimation

% make FIR using output error model
model_oe = oe(io_data, [100, 0, 1]);

% find the delay using the impulse response  
nk = find(abs(model_oe.b) > .1*max(abs(model_oe.b)), true, 'first')-1; 

if isempty(nk), nk = inf; end

fprintf("\testimated delay is %d sample(s)\n", nk-1)

% visualize for sanity check
fig = make_fig([], [], [], "Delay Estimation");
errorshade(0:(length(model_oe.b)-1), model_oe.b, 2*model_oe.db)
xline(nk, 'r')
legend('B$_{oe}$', '$\sigma_B$ (95\% confidence)', sprintf('delay $n_k$ = %d', nk), 'Interpreter','latex')
legend('location', 'best')
xlabel("samples [k]"), ylabel(sprintf('y [%s]', io_data.OutputUnit{1}))

drawnow
saveas(fig, "img/33_delay_estimation.png")

%% ---------------------------------
subsection Numerator Estimation

% get loss function for ARX models of different Numerator orders
loss = arrayfun(@(nb) (arx(io_data, [n, nb, nk]).EstimationInfo.LossFcn), 1:n);

% find the order which minimizes the loss function
[~, nb] = min(loss);
fprintf("\torder of nb for minimum loss is %d\n", nb)


%% ---------------------------------
subsection Denominator Estimation

na = n;


%% ---------------------------------
subsection ARX model orders

fprintf("\tselected ARX model orders are: [%d, %d, %d]\n", na, nb, nk)