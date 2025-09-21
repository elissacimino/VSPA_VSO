%calculations are done for the deflection of the follower center of rotation
%Use parallel theorem as the follower outer radius is in contact with the cam profile 

% useful link: https://en.wikipedia.org/wiki/Parallel_curve
% Follow equations under: "Parallel curve of a parametricaly given curve"
% x(t) becomes x(psi), x changes due to psi
% x'(t) becomes diff(x)./diff(psi)
% d = -roller_radius, as cam follower center is lower, more negative, than x

function [curve_x, curve_y] = offsetCamCurve(x,y,r,psi,roller_radius,offset_direction,derivative)
    if(strcmp(derivative,'dydx'))
            xprime = dydx(x,psi);
            yprime = dydx(y,psi);
    end
    if(strcmp(derivative,'diff'))
            xprime = diff(x)./diff(psi);
            xprime(end+1) = xprime(end);
            yprime = diff(y)./diff(psi);
            yprime(end+1) = yprime(end);
            x_vec = 1:length(xprime);
            figure(61), hold on
            subplot(3,1,1)
            hold on
            plot(psi)
            plot(x_vec(310:520), psi(310:520)),
            ylabel('\psi')
            subplot(3,1,2)
            hold on
            plot(x)
            plot(x_vec(310:520),x(310:520)),
            plot(x_vec(1),x(1),'o')
            ylabel('x')
            subplot(3,1,3)
            hold on
            plot(y)
            plot(x_vec(310:520),y(310:520)),
            plot(x_vec(1),y(1),'o')
            ylabel('y')
            figure(63),
            subplot(2,1,1)
            plot(xprime), hold on
            plot(x_vec(310:520),xprime((310:520)))
            ylabel('xdot')
            subplot(2,1,2)
            plot(yprime), hold on
            plot(x_vec(310:520),yprime((310:520)))
            plot(x_vec(1),yprime((1)),'o')
            ylabel('ydot')
    end
    if(strcmp(offset_direction,'offset'))
        curve_x = x + -roller_radius.*yprime./sqrt(xprime.^2 + yprime.^2);
        curve_y = y + -roller_radius.*-xprime./sqrt(xprime.^2 + yprime.^2);
        x_scale = 1:length(curve_x);
        [pks,locs] = findpeaks(curve_y(1:520));
        [pks2,locs2] = findpeaks(curve_x(1:520));
        TF = islocalmin(curve_y(1:520));
        TF2 = islocalmin(curve_x(1:520));
        %{
        figure(64),
        subplot(2,2,1), hold on
        plot(curve_x)
        plot(x_scale(310:520), curve_x(310:520))
        plot(x_scale(TF2),curve_x(TF2),'*')
        plot(locs2,pks2,'o')
        ylabel('curve x')
        %} %{
        subplot(2,2,3), hold on
        plot(curve_y)
        plot(x_scale(310:520),curve_y(310:520))
        plot(x_scale(TF),curve_y(TF),'*')
        plot(locs,pks,'o')
        ylabel('curve y')
        %} %{
        subplot(2,2,[2, 4]), hold on
        plot(curve_x,curve_y)
        plot(curve_x(310:520),curve_y(310:520))
        plot(curve_x(TF2),curve_y(TF),'*')
        %plot(pks2,pks,'o') 
        xlabel('curve x')
        ylabel('curve y')
        %}


    end
    if(strcmp(offset_direction,'progenitor'))
        %r = x./cos(psi);
        curve_x = x + roller_radius.*yprime./sqrt(xprime.^2 + yprime.^2);
        curve_y = y + roller_radius.*-xprime./sqrt(xprime.^2 + yprime.^2);
    end
end