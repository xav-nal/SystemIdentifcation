function varargout = errorshade(varargin)
%ERRORSHADE like errorbar, but for stairs()
%   errorshade(y, sigma)
%   errorshade(x, y, sigma) 
%   errorshade(x, y, L, U) 

% plot stairs
if nargin > 2 
    [X, Y] = stairs(varargin{1}, varargin{2});
else 
    [X, Y] = stairs(varargin{1});
end


% plot uncertainty
if nargin == 2
    [XL, YL] = stairs(varargin{1}-varargin{2});
    [XH, YH] = stairs(varargin{1}+varargin{2});
elseif nargin == 3 
    [XL, YL] = stairs(varargin{1}, varargin{2}-varargin{3});
    [XH, YH] = stairs(varargin{1}, varargin{2}+varargin{3});
elseif nargin == 4 
    [XL, YL] = stairs(varargin{1}, varargin{2}-varargin{3});
    [XH, YH] = stairs(varargin{1}, varargin{2}+varargin{4});
end

dt = mean(diff(XL(1:2:end)));

C = colororder;
plot([X; X(end)+dt], [Y;Y(end)]), hold on
patch([XL; XL(end)+dt; XH(end)+dt; flip(XH)], [YL; YL(end); YH(end); flip(YH)], C(1,:), 'FaceAlpha',.3, 'EdgeColor', 'none')
hold off

varargout = {};

end

