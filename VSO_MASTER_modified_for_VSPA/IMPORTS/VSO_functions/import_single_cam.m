function import_single_cam()
    kdelt = 650; %ToDO
    data = xlsread('ViktorCam.csv');
    %data = xlsread('MathDebugCam.csv');
    x_otto = data(:,1).*0.001;
    % x_import_offset = data(:,1)'.*0.001+6.5*mm2m;
    y_otto = data(:,2).*0.001;
    y_import = [min(y_otto):(max(y_otto)-min(y_otto))/9999:max(y_otto)];
    CamOttobock = polyfit(y_otto,x_otto,8);
    x_import = polyval(CamOttobock,y_import);
    figure(1)
    hold on
    plot(x_otto,y_otto,'o')
    plot(x_import,y_import)
    axis equal
    % data = xlsread('MathDebugCam.csv');
    % x_import_offset = data(:,1)'.*0.001+6.5*mm2m;
    % y_import_offset = data(:,2)'.*0.001;
    % res_mag = 10;
    % for i=1:(length(y_file)-1)
    %     inc_y = (y_file(i+1) - y_file(i))/res_mag;
    %     inc_x = (x_file(i+1) - x_file(i))/res_mag;
    %     for j=0:1:res_mag
    %         x_import(i+j) = x_file(i)+j*inc_x;
    %         y_import(i+j) = y_file(i)+j*inc_x;
    %     end
    % end

    %y_import = [min(y_file):(max(y_file)-min(y_file))/9999:max(y_file)];
    %Cam = polyfit(y_file,x_file,8);
    %x_import = polyval(Cam,y_import);
    %SolidworksImport = readtable('cam_feather_nonlin_0dot15.txt');
    %SolidworksImport = readtable('cam_3_final.txt');
    %SolidworksImport_Offset = readtable('CamTesting3.txt');
    % x_import = table2array(SolidworksImport(:,2)).*0.001;
    % y_import = table2array(SolidworksImport(:,1)).*0.001;
    % x_import = smooth(x_import);
    % y_import = smooth(y_import);

    %USING MATH TO OFFSET TO PROGENITOR CURVE
    % psi_import = atan(y_import./x_import);
    % r_import = x_import./cos(psi_import);
    % [x_import_offset y_import_offset] = offsetCamCurve(x_import, y_import, r_import, psi_import, cam_radius, -1, 0);

    

    %Invert to get (r,psi)
    psi = acot(x_import_offset./y_import_offset);
    r = y_import_offset./sin(psi);

    %USING MATH TO OFFSET TO OFFSET CURVE
    % psi_import_offset = atan(y_import_offset./x_import_offset);
    % r_import_offset = x_import./cos(psi_import_offset);
    [x_import_offset_back y_import_offset_back] = offsetCamCurve(x_import_offset, y_import_offset, r, psi, cam_radius, 1, 1);
    

    %PLOTTING CAM PROFILES
    figure(7)
    hold on
    plot(x_import_offset,y_import_offset,'linewidth',3)
    %plot(x_import_offset,y_import_offset)
    plot(x_import_offset_back,y_import_offset_back,'linewidth',2)
    axis equal
%     polarplot(psi,r)
%     polarplot(psi2,r2)
    hold off
end