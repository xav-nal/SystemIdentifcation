function subsection(varargin)
%SECTION makes a subsection title in the terminal
global sect_counter subsect_counter

if ~exist("sect_counter", 'var') || isempty(sect_counter)
    sect_counter = 1;
end
if ~exist("subsect_counter", 'var') || isempty(subsect_counter)
    subsect_counter = 0;
end
subsect_counter = subsect_counter + 1;
disp(strjoin([sprintf('<strong>%d.%d.', sect_counter, subsect_counter), varargin, '</strong>']))

end

