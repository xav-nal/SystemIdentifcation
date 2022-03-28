function git(varargin)
%
%GIT [args]
%   Executes git commands through MATLAB command prompt.
%   E.g.:
%       git --version
%       git commit -m 'message'
%   NOTE: git is not included. You may have to install git and add to system path.
%
%Brought to you by the lazy mind Hiran Wijesinghe (hiran.s@icloud.com)
    system(strjoin(['git' varargin]));
end