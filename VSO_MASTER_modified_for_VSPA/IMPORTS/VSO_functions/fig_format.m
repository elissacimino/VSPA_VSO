function fig_format(x_label,y_label,fig_title)
    xlabel(x_label)
    ylabel(y_label)
    title(fig_title)
    set(gcf,'color','w'); 
    set(gca,'FontSize',18); set(gca,'linewidth',2);
    legend boxoff
    grid off;
end