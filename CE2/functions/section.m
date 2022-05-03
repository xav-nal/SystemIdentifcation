function section(varargin)
%SECTION makes a section title in the terminal
global sect_counter subsect_counter 

if ~exist("sect_counter", 'var') || isempty(sect_counter)
    sect_counter = 0;
end
sect_counter = sect_counter + 1;
subsect_counter = 0;
disp(strjoin([sprintf('<strong>%d.', sect_counter), varargin, '</strong>']))

end

