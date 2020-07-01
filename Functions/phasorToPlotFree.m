%% Ploting pixels selected on the phasor map back to the original map;
% Peiyu Wang
% Updated: 07/01/2020

function [mask,phase_selected] = PhasorToPlotFree(org_ref)

figure
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

subplot(1,2,1)
imagesc(org_ref.int)
colorbar; axis image;

map_res = size(org_ref.int,1)*2;
phasor_his = zeros(map_res,map_res);

for i = 1:size(org_ref.int,1)
    for j = 1:size(org_ref.int,2)
        G_index = floor(org_ref.G(i,j)*map_res/2+map_res/2+1); %function floor is doing the binning for you.
        S_index = floor(org_ref.S(i,j)*map_res/2+map_res/2+1);
        if G_index < 1; G_index = 1; end
        if S_index < 1; S_index = 1; end
        if G_index > map_res; G_index = map_res; end
        if S_index > map_res; S_index = map_res; end
        
        phasor_his(S_index,G_index) = phasor_his(S_index,G_index)+1;
    end
end
[max_val,max_Idx] = max(phasor_his(:));
phasor_his(max_Idx) = 0;
phasor_his = flip(phasor_his);
subplot(1,2,2)
imagesc(phasor_his);
colormap jet; colorbar; axis image; caxis([0 150])

x_circle     = [map_res/2:map_res];
y_circle_pos = map_res/2-floor(sqrt((map_res/4)^2-((x_circle-map_res/2)-map_res/4).^2));
y_circle_neg = map_res/2+floor(sqrt((map_res/4)^2-((x_circle-map_res/2)-map_res/4).^2));
hold on; plot(x_circle,[y_circle_pos;y_circle_neg],'k','LineWidth',1)
axis([map_res/2 map_res  map_res/5  map_res/2])

xticks([map_res/2:map_res/2^4:map_res]);
xticklabels({'0','0.125','0.25','0.375','0.5','0.625','0.75','0.875','1'});

yticks([0:map_res/2^4:map_res/2]);
yticklabels({'1','0.875','0.75','0.625','0.5','0.375','0.25','0.125','0'});
%%

%% selecting regions inside the phasor plots.
phasorMap_x = [-1:2/(map_res-1):1];
phasorMap_y = [-1:2/(map_res-1):1];
% Notice : Using countor for the phapsor plot, the y is from negative to
% positive;
% If you use imagesc to generate the phasor plot, you 1 to -1

plot_color = ['r','m','g','c','y','w'];

judge = 1;
%%
final_mask = zeros(size(org_ref.int,1),size(org_ref.int,2));
final_phasor = zeros(size(phasor_his));
color_idx = 1;
while judge == 1
    
    subplot(1,2,2);
    H=drawfreehand('color',plot_color(color_idx),'closed',true,'Linewidth',1);
    phase_selected = H.createMask;

    
    subplot(1,2,2);
    hold on;
    add_plot = plot(fix(find(phase_selected == 1)/size(phase_selected,1)),rem(find(phase_selected == 1),size(phase_selected,1)),'color',plot_color(color_idx),'Marker','.');
    
    phase_selected = flip(phase_selected);
    
    
     
    mask = zeros(size(org_ref.int,1),size(org_ref.int,2));
    
    for i = 1: size(org_ref.int,1)
        for j = 1: size(org_ref.int,2)
            
            G_index = floor(org_ref.G(i,j)*map_res/2+map_res/2+1); %function floor is doing the binning for you.
            S_index = floor(org_ref.S(i,j)*map_res/2+map_res/2+1);
            if G_index < 1; G_index = 1; end
            if S_index < 1; S_index = 1; end
            if G_index > map_res; G_index = map_res; end
            if S_index > map_res; S_index = map_res; end

            if phase_selected(S_index,G_index)==1

                mask(i,j) = 1;
                
            end
        end
    end
    
    subplot(1,2,1);
    hold on;
    mask_plot = plot(fix(find(mask == 1)/size(mask,1)),rem(find(mask==1),size(mask,1)),'color',plot_color(color_idx),'Marker','.','LineStyle','none');
    
    promptMessage = "Add Another Region?";
    button = questdlg(promptMessage, 'Next?', ...
        'Add', 'Add Color','Done(with this round)',...
        'Redo');
    if strcmp(button, 'Done(with this round)')
        final_mask(mask == 1) = 1;
        final_phasor(phase_selected==1) = 1;
        judge = 0;
    elseif strcmp(button, 'Add')
        final_mask(mask == 1) = 1;
        final_phasor(phase_selected==1) = 1;
    else
        final_mask(mask == 1) = 1;
        final_phasor(phase_selected==1) = 1;
        
        color_idx = color_idx+1;
        if color_idx > numel(plot_color)
            color_idx = 1;
        end
    end
end

end

