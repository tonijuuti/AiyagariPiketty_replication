function [d,out]=ridders(fname,a,b,tol,varargin)
%
% Ridder's algorithm for univariate functions
%
% Author: Marco Maffezzoli. 10/2012. Ver. 1.10.

objf=str2func(fname);
fa=objf(a,varargin{:});
fb=objf(b,varargin{:});
if sign(fa)==sign(fb)
    error('The initial interval is not bracketing a zero!')
end
tol=max(tol,eps*(abs(a)+abs(b))/2);
while abs(a-b)>tol
    disp(['Current interval: ' num2str([a b])])
    c=(a+b)/2;
    fc=objf(c,varargin{:});
    d=c+(c-a)*(sign(fa-fb)*fc)/sqrt(fc^2-fa*fb);
    fd=objf(d,varargin{:});
    if sign(fc)~=sign(fd)
        a=c;
        fa=fc;
        b=d;
        fb=fd;
    elseif sign(fa)~=sign(fd)
        b=d;
        fb=fd;
    else
        a=d;
        fa=fd;
    end
end
d=(a+b)/2;
[~,out]=objf(d,varargin{:});

end