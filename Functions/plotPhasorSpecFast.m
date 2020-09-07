% Function: Ploting Spectral Phasor
% Peiyu Wang
% Update: 07/01/2020


function plotPhasorSpecFast(org_ref)

map_res = size(org_ref.int,1); 
phasor_his = zeros(map_res,map_res);

for i = 1:size(org_ref.int,1)
    for j = 1:size(org_ref.int,2)
        G_index = floor(org_ref.G(i,j)*map_res/2+map_res/2); %function floor is doing the binning for you. 
        S_index = floor(org_ref.S(i,j)*map_res/2+map_res/2);
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

imagesc(phasor_his);hold on;
colorbar; axis image; colormap(gca,jet); caxis('auto') ;ax = gca;ax.Colormap(1,:)=[1,1,1];

x_circle     = [1:map_res];
y_circle_pos = map_res/2-floor(sqrt((map_res/2)^2-((x_circle-map_res/2)).^2));
y_circle_neg = map_res/2+floor(sqrt((map_res/2)^2-((x_circle-map_res/2)).^2));
plot(x_circle,[y_circle_pos;y_circle_neg],'k','LineWidth',1)


xticks([0:map_res/8:map_res]);
xticklabels({'-1','-0.75','-0.5','-0.25','0','0.25','0.5','0.75','1'});

yticks([0:map_res/8:map_res]);
yticklabels({'1','0.75','0.5','0.25','0','-0.25','-0.5','-0.75','-1'});

plotRadialGrid(map_res);
xlabel('G');ylabel('S');
hold off;
end


function plotRadialGrid(map_res)
hold on
colorcode = [0.7,0.7,0.7];
plot([1:map_res],[1:map_res],'color',colorcode,'LineStyle','--');
plot([1:map_res],[map_res:-1:1],'color',colorcode,'LineStyle','--');
plot([1:map_res],ones(1,map_res)*round(map_res/2),'color',colorcode,'LineStyle','--');
plot(ones(1,map_res)*round(map_res/2),[1:map_res],'color',colorcode,'LineStyle','--');
end