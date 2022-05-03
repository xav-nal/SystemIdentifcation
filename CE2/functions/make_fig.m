function varargout = make_fig(varargin)
%MAKE_PLOT Summary of this function goes here

%   make_fig(time, signals, labels, N)         % adds signals to figure
%   make_fig(time, signals, labels, title)     % creates new figure with title
%   make_fig(time, signals, labels, N, title)  % % adds signals to figure and updates title
    
    if nargin > 3 && ~isempty(varargin{4})
        if isnumeric(varargin{4})
            fig = figure(varargin{4});
        elseif isa(varargin{4}, 'matlab.ui.Figure')
            fig = varargin{4};
        elseif isa(varargin{4}, 'string') || isa(varargin{4}, 'char')
            fig = figure("Name", varargin{4});
            title(varargin{4});
        end
    else
        fig = figure();
    end

    if nargin > 4 && isempty(fig.Name) && ...
       (isa(varargin{5}, 'string') || isa(varargin{5}, 'char'))
        title(varargin{5});
        fig.Name = gca().Title.String;
    end
    
    hold on;
    if nargin > 1 && ~isempty(varargin{1}) && ~isempty(varargin{2})
        stairs(varargin{1}, varargin{2});
    end
    if nargin > 2 && ~isempty(varargin{3})
        legend(varargin{3}, 'Interpreter','latex');
    end
    ylabel("y")


    grid on

    if nargout > 0
        varargout = {fig};
    end
end
