function varargout = intpsd(u, y, win, Ts, zero_pad)
%INTPSD [S, f] = intpsd(u, y, window=[], Ts=1, zero_pad=false)
%   intercorrelational power-spectral density of a signal set

    if (nargin < 2) || isempty(y)
        y = u;
    end

    if (nargin < 4) || isempty(Ts)
        Ts = 1;
    end

    if (nargin > 4) && zero_pad
        u = [u; zeros(size(u))]; % zero-pad signals
        y = [y; zeros(size(u))];
    end

    N = length(u);
    if (nargin < 3) || isempty(win)
        S = fft(u) .* conj(fft(y))/N;   % fast psd without windowing
    else
        R = intcor(u, y);               % intcor
        S = fft(ifftshift(win.*R));     % psd of windowed intcor
    end
    
    if nargout > 1
        f = linspace(0, 2*pi*(N-1)/N/Ts, N); %associated freq
        varargout={S, f};
    else
        varargout={S};
    end

end


