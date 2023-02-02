function [x,z]=uniformnodes(a,b,n)
% Function UniformNodes,
% (c) 2003 by Marco Maffezzoli. Ver. 1.0.0
%

x=linspace(a,b,n)';
if nargout==2
    z=2*(x-a)/(b-a)-1;
end