function [R, h] = intcor(u, y, zero_pad)
%INTCOR [R, h] = intcor(u, y, zero_pad=false) 
%   intercorrelation of u and y
%   u and y must be similarly sized column-vectors
%   R is the intercorrelation
%   h is the shifts 

    N = length(u);
    
    if (nargin > 2) && zero_pad
        U = fft([u; zeros(size(u))]); % zero-pad signals
        Y = fft([y; zeros(size(u))]);
    else
        U = fft(u); % don't zero-pad signals
        Y = fft(y);
    end
    
    R = fftshift(ifft(U .* conj(Y), length(U), 1), 1) /N;

    if length(U) > N 
        h = linspace(-N, N-1, length(U)).';
    else
        if ~mod(N,2)
            h = linspace(-N/2, N/2-1, length(U));
        else 
            h = linspace(1-ceil(N/2), floor(N/2), length(U));
        end
    end

end

