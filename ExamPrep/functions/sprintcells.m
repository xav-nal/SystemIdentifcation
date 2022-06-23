function out = sprintcells(template, varargin)
%SPRINTCELLS print a comparison of cells values together
% example : 
%   A = {'A' 'B' 'C' 'D'};
%   B = {1 2 3 4 };
%   out = sprintcells('%c is %d', A, B)
%   out : "A is 1, B is 2, C is 3, D is 4"
%
% note : currently only works for two inputs 

    tmp = cellzip(varargin{1}, varargin{2});
    out = sprintf(repmat([char(template), ', '], 1, length(varargin{1})), tmp{:});

end

