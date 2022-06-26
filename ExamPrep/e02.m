%% ---------------------------------
section System Frequency Response 
%-----------------------------------

if periods > 1 
%% ---------------------------------
subsection Fourier Analysis (periodic signal)

    % use averaging over periods
    N = length(u)/periods;                              % period length
    f = linspace(0, 2*pi*(N-1)/N/Ts, N);                % frequency vector
    
    FU = mean(fft(reshape(u, N, periods), [], 1), 2);   % fft of input s.
    FY = mean(fft(reshape(y, N, periods), [], 1), 2);   % fft of output s.
    
    FR = FY./FU;                                        % response
    freq_model = frd(FR(1:round(end/2)), f(1:round(end/2))); % model

else 
%% ---------------------------------
subsection Spectral Analysis (random signal)

    % use averaging over epochs
    epochs  = find(rem(length(u), 1:10) == 0, 1, 'last');
    
    uu = reshape(u, [], epochs);
    yy = reshape(y, [], epochs);
    [PSD_UU, f] = intpsd(uu, uu, [], Ts); 	% PSD of inputs 
    [PSD_YY, ~] = intpsd(yy, uu, [], Ts); 	% PSD of outputs
    PSD_UM = mean(PSD_UU, 2); 	            % average PSD in
    PSD_YM = mean(PSD_YY, 2); 	            % average PSD out
    
    FR = PSD_YM./PSD_UM;	                % response
    freq_model = frd(FR(1:floor(size(uu,1)/2)), f(1:floor(size(uu,1)/2)));
end 



%% ---------------------------------
subsection Visialization

fig = make_fig([],[],[], "Frequency Response");
h = bodeplot(freq_model, 'r');
setoptions(h, ...
           'FreqUnits', 'Hz', ...
           'PhaseUnits', 'Rad', ...
           'Grid', 'on', ...
           'ConfidenceRegionNumberSD', 2)
legend("identified freq. resp.", 'location', 'best')

drawnow
saveas(fig, 'img/2_frequency_response.png')
