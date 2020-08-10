%% Ploting pixels selected on the phasor map back to the original map;
% Peiyu Wang
% Updated: 07/03/2020

% Input: org_ref: A lifetime refstack for processed Leica lifetime file
% Ouput: final_mask: A 3D stack of output files. Each z layer is on output
%        of the original intensity image that has the specified lifetime
%        final_phasor: Phasor selected. It is displayed as a
%        2*len(original) image. 
                       

function [final_mask,final_phasor] = PhasorToPlotFree(org_ref)

figure
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

subplot(1,2,1)
imagesc(org_ref.int)
colorbar; axis image;colormap(gca,gray);

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
colormap(gca,jet); colorbar; axis image; caxis('auto');
ax=gca; ax.Colormap(1,:) = [1,1,1];

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
mask_idx = 1;

current_mask = zeros(size(org_ref.int,1),size(org_ref.int,2));
current_phasor = zeros(size(phasor_his));
while judge == 1
    
    subplot(1,2,2);
    H=drawfreehand('color',plot_color(color_idx),'closed',true,'Linewidth',1,'FaceAlpha',0.3);
    phase_selected = H.createMask;
   
    phase_selected = flip(phase_selected);
    
    
     
    add_mask = zeros(size(org_ref.int,1),size(org_ref.int,2));
    
    for i = 1: size(org_ref.int,1)
        for j = 1: size(org_ref.int,2)
            
            G_index = floor(org_ref.G(i,j)*map_res/2+map_res/2+1); %function floor is doing the binning for you.
            S_index = floor(org_ref.S(i,j)*map_res/2+map_res/2+1);
            if G_index < 1; G_index = 1; end
            if S_index < 1; S_index = 1; end
            if G_index > map_res; G_index = map_res; end
            if S_index > map_res; S_index = map_res; end

            if phase_selected(S_index,G_index)==1

                add_mask(i,j) = 1;
                
            end
        end
    end
    
    subplot(1,2,1);
    hold on;
    mask_plot = plot(fix(find(add_mask == 1)/size(add_mask,1)),rem(find(add_mask==1),size(add_mask,1)),...
        'color',plot_color(color_idx),'Marker','.','LineStyle','none','MarkerSize',3);
    
    promptMessage = "Add Another Region?";
    button = questdlg(promptMessage, 'Next?', ...
        'Redo', 'Add Color','Done(with this round)',...
        'Redo');
    if strcmp(button, 'Done(with this round)')
        current_mask(add_mask == 1) = 1;
        current_phasor(flip(phase_selected)==1) = 1;
        
        final_mask(:,:,mask_idx) = current_mask;
        final_phasor(:,:,mask_idx) = current_phasor;
        
        judge = 0;
    elseif strcmp(button, 'Redo')
        delete(mask_plot);
        delete(H);
    else
        current_mask(add_mask == 1) = 1;
        current_phasor(flip(phase_selected)==1) = 1;
        
        final_mask(:,:,mask_idx) = current_mask;
        final_phasor(:,:,mask_idx) = current_phasor;
        
        current_mask = zeros(size(org_ref.int,1),size(org_ref.int,2));
        current_phasor = zeros(size(phasor_his));
        
        final_mask = cat(3,final_mask,current_mask); 
        final_phasor= cat(3,final_phasor,current_phasor);
  
        mask_idx = mask_idx+1;
        
        color_idx = color_idx+1;
        if color_idx > numel(plot_color)
            color_idx = 1;
        end
    end
end

end

