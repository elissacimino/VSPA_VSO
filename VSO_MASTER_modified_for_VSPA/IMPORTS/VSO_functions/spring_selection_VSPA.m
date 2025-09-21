function [titanium_data] = spring_selection_VSPA(spring,x_center_min,x_center_max,plotting, max_spring, max_FEA_only,FEA_peak,spring_change)
    %     addpath('IMPORTS/functions')
    addpath("Spring_Characterization/Max_charact_poweredVSPA/Titanium Spring Raw Instron Data/")
    addpath("Spring_Designer/")
    if(strcmp(spring,'stiff'))
        %Measured on Instron
        %         x_spring_data = perc2mm([10,20,30,40,50,60,70,80,90],x_center_max,x_center_min);
        %         k_spring_data = [0.504056504259215,0.643677301429046,0.832299197785623,1.05064584357359,1.32634309455410,1.66559355728660,2.08770991622833,2.63292510121457,3.32380116959065]*10^6;
        if max_spring == 1 && max_FEA_only == 0
            xlocs = [1:3,5:16];
            %         figure(2); hold on
            for i = 1:length(xlocs)
                xloc = xlocs(i);
                data = csvread(strcat('Prosthetic Ankle 1-9-18_',num2str(xlocs(i)),'.txt'),8);
                y_load = data(:,2);
                deflection = data(:,3);
                %             plot(deflection,y_load)
                k(i) = 1000*(y_load(round(end/2))-y_load(round(0.75*end)))/(deflection(round(end/2))-deflection(round(0.75*end)));
                %             plot(deflection(round(end/2)),y_load(round(end/2)),'kx','LineWidth',2)
                %             plot(deflection(round(0.75*end)),y_load(round(0.75*end)),'kx','LineWidth',2)
            end
            %         ylabel('y_load (N)')
            %         xlabel('Deflection (mm)')
            %         set(gcf,'color','w');
            %         set(gca,'FontSize',14);
            %         set(gca,'FontName','Times New Roman');

            p = polyfit(0:5:70,k,4)
            new_x = [0:0.5:x_center_max-x_center_min];
            for i = 1:length(new_x)
                corresponding_y(1,i) = interp1(0:70, polyval(p,0:70), new_x(i), 'linear');
            end
            k_spring_data = corresponding_y;
            x_spring_data = perc2mm(linspace(0,100,length(k_spring_data)),x_center_max,x_center_min);
            titanium_data = polyfit(new_x,k_spring_data,5);
            if(plotting)
                %         figure(3)
                %         hold on
                %         perc = mm2perc(x_spring_data,x_center_max,x_center_min);
                %         plot(perc,k_spring_data)
                %         x_titan = (x_center_max:-0.5:x_center_min); %== x_sping_data
                %         k_titan = polyval(titanium_data,x_titan);
                %         %Percentage
                %         titan_percent = 0:(100/(length(x_titan)-1)):100;
                %         k_titan_percent = k_titan./10^6;
                %         plot(mm2perc(x_spring_data,x_center_max,x_center_min),k_spring_data,'Linewidth',5)
                %         plot(mm2perc(x_titan,x_center_max,x_center_min),k_titan)
                %         fig_format('','','')
                %         legend('Spring Data','Fit used in Code')
                figure(2); hold on
                plot(0:5:70,k.*1e-6,'k.-','markersize',10)
                plot(0:70, polyval(p,0:70).*1e-6)
                plot(new_x,corresponding_y.*1e-6,'LineWidth',3)
                ylabel('Stiffness (kN/mm)')
                xlabel('Slider position (mm)')
                xline(x_center_max-x_center_min)
                set(gcf,'color','w');
                set(gca,'FontSize',14);
                set(gca,'FontName','Times New Roman');
                title('Characterization')
                %             legend('characterized','polyfit','Fit used in code','')
                legend('characterized','','','lead screw limit')
                legend('Location','northwest')

                legend boxoff
            end
        elseif max_spring == 1 && max_FEA_only == 1
            x_stroke = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593   0.0535    0.0478    0.0420    0.0362    0.0305];
            max_mass = 196.93; %g
            x_FEA_good_yield = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593     0.0535    0.0478    0.0420    0.0362    0.0305]; %m from inverse model
            F_FEA =       1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249    1.8309    2.1732    2.5773    3.0679    3.6751    4.4115];%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
            disp_FEA=    1e-3.*[1.004     0.929    0.9378   0.954     0.953     0.9391     0.912     0.875    0.818     0.746     0.648]; %mm
            k = F_FEA./disp_FEA;
            p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
            new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
            x_FEA = x_FEA_good_yield;
            k_FEA = k;
            %             load 'fea2reality.mat'
            %             cd ("Spring_Designer\")
            fea2reality = load('fea2reality.mat')
            fea2reality = fea2reality.fea2reality
            % SF = polyval(fea2reality,50.5); %should I consider the stroke of the lead
            SF = polyval(fea2reality,57.5); %should I consider the stroke of the lead
            k_instron_expected = k_FEA.*SF/10^6;
            titanium_data= polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k_instron_expected.*1e6,5);
            %             %test
            %             p10 = polyval(titanium_data,1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)));
            %             figure
            %             plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),p10,'linewidth',4)
            if(plotting)
                figure(2), hold on
                plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,'k.-','markersize',10), hold on
                plot(1e3*abs(x_stroke-max(x_stroke)), new_k)
                plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)), k_instron_expected,'linewidth',2)
                ylabel('Stiffness (kN/mm)')
                xlabel('Slider position (mm)')
                xline(x_center_max-x_center_min)
                set(gcf,'color','w');
                set(gca,'FontSize',14);
                set(gca,'FontName','Times New Roman');
                title('Characterization')
                legend('FEA','','k instron expected')
                legend('Location','northwest')

                legend boxoff
            end
        elseif FEA_peak == 1
            x_stroke = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593   0.0535    0.0478    0.0420    0.0362    0.0305];
            max_mass = 196.93; %g
            x_FEA_good_yield = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593     0.0535    0.0478    0.0420    0.0362    0.0305]; %m from inverse model
            F_FEA =       1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249    1.8309    2.1732    2.5773    3.0679    3.6751    4.4115];%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
            disp_FEA=    1e-3.*[1.004     0.929    0.9378   0.954     0.953     0.9391     0.912     0.875    0.818     0.746     0.648]; %mm
            k = F_FEA./disp_FEA;
            
            x_FEA_peak = [0, 10, 20, 30, 40, 50, 56];
            k_FEA_peak = [0.519, 0.637, 1.108, 1.663, 2.505, 3.987, 4.109];
            
            p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
            new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
            x_FEA = x_FEA_good_yield;
            k_FEA = k;

            %             load 'fea2reality.mat'
            %             cd ("Spring_Designer\")
            fea2reality = load('fea2reality.mat')
            fea2reality = fea2reality.fea2reality
            % SF = polyval(fea2reality,50.5); %should I consider the stroke of the lead
            SF = polyval(fea2reality,57.5); %should I consider the stroke of the lead
            k_instron_expected = k_FEA.*SF/10^6;
            titanium_data= polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k_instron_expected.*1e6,5);
            %             %test
            %             p10 = polyval(titanium_data,1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)));
            %             figure
            %             plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),p10,'linewidth',4)
            if(plotting)
                figure(2), hold on
                plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,'k.-','markersize',10), hold on
                plot(1e3*abs(x_stroke-max(x_stroke)), new_k)
                plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)), k_instron_expected,'linewidth',2)
                plot(x_FEA_peak, k_FEA_peak)

                ylabel('Stiffness (kN/mm)')
                xlabel('Slider position (mm)')
                xline(x_center_max-x_center_min)
                set(gcf,'color','w');
                set(gca,'FontSize',14);
                set(gca,'FontName','Times New Roman');
                title('Characterization')
                legend('FEA','','k instron expected')
                legend('Location','northwest')

                legend boxoff
            end
        else % powered vspa
            switch spring_change
                case 'modifywidthheight'
                    x_stroke = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593   0.0535    0.0478    0.0420    0.0362    0.0305];
                    powered_mass =  150.72;%g
                    x_FEA_good_yield = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593     0.0535    0.0478    0.0420    0.0362    0.0305]; %m from inverse model
                    F_FEA =       [2570.6/2 0    0   0    0    0    0   0 2570.6  0   2570.6];%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
                    disp_FEA=    1e-3.*[ 2.123   0.8035  0.8194  0.8482 0.8624  0.8655  0.8662   0.8523  0.8075   0.752  0.4528]; %m
                    k = F_FEA./disp_FEA;
                    p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
                    new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
                    x_FEA = x_FEA_good_yield;
                    k_FEA = k;
                    %             load 'fea2reality.mat'
                    %             cd ("Spring_Designer\")
                    fea2reality = load('fea2reality.mat')
                    fea2reality = fea2reality.fea2reality
                    % SF = polyval(fea2reality,50.5); %should I consider the stroke of the lead
                    SF = polyval(fea2reality,57.5); %should I consider the stroke of the lead
                    k_instron_expected = k_FEA.*SF/10^6;
                    titanium_data= polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k_instron_expected.*1e6,5);
                    %test
                    %             p10 = polyval(titanium_data,1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)));
                    %             figure
                    %             plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),p10,'linewidth',4)
                    if(plotting)
                        figure(2), hold on
                        plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,'k.-','markersize',10), hold on
                        plot(1e3*abs(x_stroke-max(x_stroke)), new_k)
                        plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)), k_instron_expected,'linewidth',2)
                        ylabel('Stiffness (kN/mm)')
                        xlabel('Slider position (mm)')
                        xline(x_center_max-x_center_min)
                        set(gcf,'color','w');
                        set(gca,'FontSize',14);
                        set(gca,'FontName','Times New Roman');
                        title('Characterization')
                        legend('FEA','','k instron expected')
                        legend boxoff
                        legend('Location','northwest')

                    end
                case 'width'
                    x_stroke = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593   0.0535    0.0478    0.0420    0.0362    0.0305];
                    powered_mass =  115.58;%g
                    x_FEA_good_yield = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593     0.0535    0.0478    0.0420    0.0362    0.0305]; %m from inverse model
                    F_FEA =       1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249    1.8309    2.1732    2.5773    3.0679    3.6751    4.4115]./2;%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
                    disp_FEA=    1e-3.*[ 0.86  0.8035  0.8194  0.8482 0.8624  0.8655  0.8662   0.8523   0.8174   0.752   0.675]; %mm
                    k = F_FEA./disp_FEA;
                    p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
                    new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
                    x_FEA = x_FEA_good_yield;
                    k_FEA = k;
                    %             load 'fea2reality.mat'
                    %             cd ("Spring_Designer\")
                    fea2reality = load('fea2reality.mat')
                    fea2reality = fea2reality.fea2reality
                    % SF = polyval(fea2reality,50.5); %should I consider the stroke of the lead
                    SF = polyval(fea2reality,57.5); %should I consider the stroke of the lead
                    k_instron_expected = k_FEA.*SF/10^6;
                    titanium_data= polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k_instron_expected.*1e6,5);
                    %test
                    %             p10 = polyval(titanium_data,1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)));
                    %             figure
                    %             plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),p10,'linewidth',4)
                    if(plotting)
                        figure(2), hold on
                        plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,'k.-','markersize',10), hold on
                        plot(1e3*abs(x_stroke-max(x_stroke)), new_k)
                        plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)), k_instron_expected,'linewidth',2)
                        ylabel('Stiffness (kN/mm)')
                        xlabel('Slider position (mm)')
                        xline(x_center_max-x_center_min)
                        set(gcf,'color','w');
                        set(gca,'FontSize',14);
                        set(gca,'FontName','Times New Roman');
                        title('Characterization')
                        legend('FEA','','k instron expected')
                        legend boxoff
                        legend('Location','northwest')

                    end
                case 'length'
                    x_stroke = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500         45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
                    powered_mass =  141.55;%g
                    x_FEA_good_yield = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500         45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
                    F_FEA =       1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249*2    1.8309*2    2.1732*2    2.5773*2    3.0679*2    3.6751*2    4.4115*2]./2;%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
                    disp_FEA=    1e-3.*[0.599     0.4871    0.4399    0.4069    0.7877     0.7601        0.7075     0.6274    0.5271        0.4144      0.301]; %mm
                    k = F_FEA./disp_FEA;
                    p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
                    new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
                    x_FEA = x_FEA_good_yield;
                    k_FEA = k;
                    fea2reality = load('fea2reality.mat')
                    fea2reality = fea2reality.fea2reality
                    % SF = polyval(fea2reality,50.5); %should I consider the stroke of the lead
                    SF = polyval(fea2reality,57.5); %should I consider the stroke of the lead
                    k_instron_expected = k_FEA.*SF/10^6;
                    titanium_data= polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k_instron_expected.*1e6,5);
                    if(plotting)
                        figure(2), hold on
                        plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,'k.-','markersize',10), hold on
                        plot(1e3*abs(x_stroke-max(x_stroke)), new_k)
                        plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)), k_instron_expected,'linewidth',2)
                        ylabel('Stiffness (kN/mm)')
                        xlabel('Slider position (mm)')
                        xline(x_center_max-x_center_min)
                        set(gcf,'color','w');
                        set(gca,'FontSize',14);
                        set(gca,'FontName','Times New Roman');
                        title('Characterization')
                        legend('FEA','','k instron expected')
                        legend('Location','northwest')

                        legend boxoff
                    end
                case 'widthlength'
                    x_stroke = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500         45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
                    powered_mass =  81.72;%g
                    x_FEA_good_yield = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500    45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
                    F_FEA =            1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249      1.8309     2.1732   2.5773   3.0679   3.6751    4.4115]./2;%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
                    disp_FEA=           1e-3.*[1.036   0.858     0.7908    0.7396     0.7357    0.733       0.7017   0.6403    0.547   0.4332        0.3155]; %mm
                    k = F_FEA./disp_FEA;
                    p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
                    new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
                    x_FEA = x_FEA_good_yield;
                    k_FEA = k;
                    fea2reality = load('fea2reality.mat')
                    fea2reality = fea2reality.fea2reality
                    % SF = polyval(fea2reality,50.5); %should I consider the stroke of the lead
                    SF = polyval(fea2reality,57.5); %should I consider the stroke of the lead
                    k_instron_expected = k_FEA.*SF/10^6;
                    titanium_data= polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k_instron_expected.*1e6,5);
                    if(plotting)
                        figure(2), hold on
                        plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,'k.-','markersize',10), hold on
                        plot(1e3*abs(x_stroke-max(x_stroke)), new_k)
                        plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)), k_instron_expected,'linewidth',2)
                        ylabel('Stiffness (kN/mm)')
                        xlabel('Slider position (mm)')
                        xline(x_center_max-x_center_min)
                        set(gcf,'color','w');
                        set(gca,'FontSize',14);
                        set(gca,'FontName','Times New Roman');
                        title('Characterization')
                        legend('FEA','','k instron expected')
                        legend('Location','northwest')
                        legend boxoff
                    end
                case 'widthlengthheight'
                    x_stroke = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500         45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
                    powered_mass =  65.68;%g
                    x_FEA_good_yield = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500    45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
                    F_FEA =            1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249      1.8309     2.1732   2.1732   2.1732   2.1732    2.1732]./2;%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
                    disp_FEA=           1e-3.*[2.578    2.46     2.397    2.454       2.637      2.783     2.768       2.036     1.326   0.7502     0.3805]; %mm
                    k = F_FEA./disp_FEA;
                    p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
                    new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
                    x_FEA = x_FEA_good_yield;
                    k_FEA = k;
                    fea2reality = load('fea2reality.mat')
                    fea2reality = fea2reality.fea2reality
                    % SF = polyval(fea2reality,50.5); %should I consider the stroke of the lead
                    SF = polyval(fea2reality,57.5); %should I consider the stroke of the lead
                    k_instron_expected = k_FEA.*SF/10^6;
                    titanium_data= polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k_instron_expected.*1e6,5);
                    if(plotting)
                        figure(2), hold on
                        plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,'k.-','markersize',10), hold on
                        plot(1e3*abs(x_stroke-max(x_stroke)), new_k)
                        plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)), k_instron_expected,'linewidth',2)
                        ylabel('Stiffness (kN/mm)')
                        xlabel('Slider position (mm)')
                        xline(x_center_max-x_center_min)
                        set(gcf,'color','w');
                        set(gca,'FontSize',14);
                        set(gca,'FontName','Times New Roman');
                        title('Characterization')
                        legend('FEA','','k instron expected')
                        legend boxoff
                        legend('Location','northwest')

                    end
            end
            
        % titanium_data = polyfit(x_spring_data,k_spring_data,3); %ToDo

    end
end

