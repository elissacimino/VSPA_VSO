function plotShadedCurve(mainCurve,boundsCurve, color, x)
curve1 =  mainCurve + boundsCurve;
curve2 = mainCurve - boundsCurve;
fill([x,fliplr(x)],[curve1; flipud(curve2)],color,'HandleVisibility','off','facealpha',.1,'EdgeAlpha',0)
end