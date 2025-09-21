function collins_data(equilibrium_angle)
    scale_Collins = 0.6;
    ROM_collins = [0 0.3]; %rad
    stiffness_collins = scale_Collins*[130 180 240 310 400]*ROM_collins(end); %Nm/rad 130 180 240 310 400
    colors = {[148,0,211]./255; [0,206,209]./255; [0,255,127]./255; [255,140,0]./255; [220,20,60]./255};
    figure(2)
    hold on
    plot(rad2deg(ROM_collins)+equilibrium_angle, [0 stiffness_collins(end)],'Color',colors{1},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equilibrium_angle, [0 stiffness_collins(4)],'Color',colors{2},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equilibrium_angle, [0 stiffness_collins(3)],'Color',colors{3},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equilibrium_angle, [0 stiffness_collins(2)],'Color',colors{4},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equilibrium_angle, [0 stiffness_collins(1)],'Color',colors{5},'Linewidth',5)
end