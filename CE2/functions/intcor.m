function varargout = intcor(u, y, zero_pad)
%INTCOR [R, h] = intcor(u, y, zero_pad=false) 
%   intercorrelation of u and y
%   u and y must be similarly sized column-vectors
%   R is the intercorrelation
%   h contains the shifts (zero-centered)

    N = length(u);

    if nargin < 2
        y = u;
    end
    
    if (nargin > 2) && zero_pad
        u = [u; zeros(size(u))]; % zero-pad signals
        y = [y; zeros(size(u))];
    end
    
    R = fftshift(ifft(fft(u,[],1) .* conj(fft(y,[],1)), length(u), 1), 1) /length(u); % fast
%     R = fftshift(ifft(fft(u,[],1) .* ifft(y,[],1), [], 1), 1); % even faster, but floating-point errors


    if nargout > 1
        if length(u) > N 
            h = linspace(-N, N-1, length(u)).';
        else
            if ~mod(N,2)
                h = linspace(-N/2, N/2-1, N);
            else 
                h = linspace(1-ceil(N/2), floor(N/2), N);
            end
        end

        varargout={R, h};
    else
        varargout={R};
    end
end

