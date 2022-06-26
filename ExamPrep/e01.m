%% ---------------------------------
section Input Data Analysis 
%-----------------------------------



%% ---------------------------------
subsection Characterization

% is the signal binary ? 
is_binary   = (length(unique(u)) == 2 );

% is the signal periodic ? 
[Ruu, h] = intcor(u, u);
h        = seconds(h/fs);
periods  = sum(Ruu > 0.99*max(Ruu));

% is the signal white ? 
up       = u(1:round(length(u)/periods));
[Suu, f] = intpsd(up, up, [], 1/fs);
is_white    = (abs(std(Suu) / mean(Suu)) < 1);

% output 
if is_binary 
    fprintf("\tThe input signal is binary\n")
else 
    fprintf("\tThe input signal is not binary\n")
end 

fprintf("\tThe input signal has %d period(s)\n", periods)

if is_white 
    fprintf("\tThe input signal is white\n")
else 
    fprintf("\tThe input signal is not white\n")
end

%% ---------------------------------
subsection Visialization

fig = make_fig([],[],[], "Input Data");
sgtitle("Input Data Analysis")
subplot(3,1,1)
    plot(time, u)
    axis('tight'), xlabel("time"), ylabel(sprintf('input [%s]', in_U{1}))
subplot(3,1,2)
    plot(h, Ruu)
    axis('tight'), xlabel("shifts"), ylabel("autocorrelation")
subplot(3,1,3)
    plot(f, Suu)
    axis('tight'), xlabel("frequency [Hz]"), ylabel("PSD")

drawnow
saveas(fig, 'img/1_input_data.png')

%% ---------------------------------
subsection Treatment

% detrend the input signal 
u = detrend(u, 0);

% detrend the output signal 
y = detrend(y, 0);

fprintf("\tIn/Out signals detrended\n")

%% ---------------------------------
subsection Data Structure

io_data = iddata(y, u, Ts, ...
                'Name',       'Dataset', ...
                'InputName',  in_name, ...
                'InputUnit',  in_U, ...
                'OutputName', out_name,...
                'OutputUnit', out_U);

fprintf("\tdone\n")