%% Instron testing of Titanium Spring for Elliott (slightly thicker than original blue ankle)
close all 
clear
% xlocs = {'00','10','20','30','40','50','60','70'}
xlocs = [1:3,5:16];
figure(2); hold on
for i = 1:length(xlocs)
    xloc = xlocs(i);
    data = csvread(strcat('Prosthetic Ankle 1-9-18_',num2str(xlocs(i)),'.txt'),8);
    load = data(:,2);
    deflection = data(:,3);
    plot(deflection,load)
    k(i) = 1000*(load(round(end/2))-load(round(0.75*end)))/(deflection(round(end/2))-deflection(round(0.75*end)));
    plot(deflection(round(end/2)),load(round(end/2)),'kx','LineWidth',2)
    plot(deflection(round(0.75*end)),load(round(0.75*end)),'kx','LineWidth',2)
end
ylabel('load (N)')
xlabel('Deflection (mm)')
set(gcf,'color','w');
set(gca,'FontSize',14);
set(gca,'FontName','Times New Roman');

figure(4); hold on
plot(0:5:70,k,'k.-','markersize',10)
p = polyfit(0:5:70,k,4)
plot(0:70, polyval(p,0:70))
ylabel('Stiffness (N/m)')
xlabel('Slider position (mm)')
set(gcf,'color','w');
set(gca,'FontSize',14);
set(gca,'FontName','Times New Roman');
legend boxoff