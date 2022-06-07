function C = cellzip(A, B)
%CELLZIP zips to cell arrays together
% example : 
%   A = {'A' 'B' 'C' 'D'};
%   B = {1 2 3 4 };
%   C = zip(A,B)
%   C : {'A' 1 'B' 2 'C' 3 'D' 4}
%
% https://stackoverflow.com/questions/19842696/is-there-a-function-to-zip-two-cell-arrays-together
    
    if size(A, 1) ~= 1 && size(A, 2) == 1
        A = A.';
    end
    if size(B, 1) ~= 1 && size(B, 2) == 1
        B = B.';
    end

    if length(A) ~= length(B)
        error("lengths do not match : cannot zip cell arrays together")
    end

    tmp = [A(:), B(:)].';
    C = tmp(:);
end

