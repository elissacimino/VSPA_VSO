function out = dydx(y, x)
% INPUTS:
    % y: 1-D vector of dependent variable
    % x: 1-D vector of independent variable
% OUTPUT:
    % out: y differentiated with respect to x

    dy = filter22([-2 -1 0 1 2], y, 2);
    dx = filter22([-2 -1 0 1 2], x, 2);
    
    dy(1) = -21*y(1) + 13*y(2) + 17*y(3) - 9*y(4);
    dx(1) = -21*x(1) + 13*x(2) + 17*x(3) - 9*x(4);
    
    dy(2) = -11*y(1) + 3*y(2) + 7*y(3) + y(4);
    dx(2) = -11*x(1) + 3*x(2) + 7*x(3) + x(4);
    
    dy(end-1) = 11*y(end) - 3*y(end-1) - 7*y(end-2) - y(end-3);
    dx(end-1) = 11*x(end) - 3*x(end-1) - 7*x(end-2) - x(end-3);
    
    dy(end) = 21*y(end) - 13*y(end-1) - 17*y(end-2) + 9*y(end-3);
    dx(end) = 21*x(end) - 13*x(end-1) - 17*x(end-2) + 9*x(end-3);
    
    out = dy./dx;

end