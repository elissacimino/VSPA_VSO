function fig_autoplace(figs)
    num_fig = max([figs.Number]);
    num_cols =  4;
    num_rows = 2;
    screen_size  = get(0,'screensize');
    task_bar = screen_size(3)/35;
    pc_width  = 1*(screen_size(3)-task_bar);
    pc_height = screen_size(4);
    width = pc_width/num_cols;
    height = 0.60*pc_height/num_rows;
    buffer = 85;
    x = 0;
    y = 0;
    for f=1:num_fig
        h = figure(f);
        if(x<=((num_cols-1)/num_cols)*pc_width)
            set_fig_position(h,y,x,height,width)

        else
            x = 0;
            y = y+height+buffer;
            set_fig_position(h,y,x,height,width)
        end
        x = x+width; 
    end
end
