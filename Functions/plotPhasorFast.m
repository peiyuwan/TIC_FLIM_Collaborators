%% Function: Plot Intensity, First and Second Harmonic.
%Peiyu Wang
% 03/20/2019

function plotPhasorFast(org_ref)

map_res = 512; 
phasor_his = zeros(map_res,map_res);

for i = 1:size(org_ref.int,1)
    for j = 1:size(org_ref.int,2)
        G_index = floor((org_ref.G(i,j)-1.526e-05)*map_res/2+map_res/2+1); %function floor is doing the binning for you. 
        S_index = floor((org_ref.S(i,j)-1.526e-05)*map_res/2+map_res/2+1);
        if G_index < 1; G_index = 1; end
        if S_index < 1; S_index = 1; end
        if G_index > map_res; G_index = map_res; end
        if S_index > map_res; S_index = map_res; end
        if G_index && S_index; phasor_his(S_index,G_index) = phasor_his(S_index,G_index)+1;end
    end
end

% because the pixel value at (0,0) is too high, we change that to 0;
[max_val,max_Idx] = max(phasor_his(:));
phasor_his(max_Idx) = 0;
phasor_his = flip(phasor_his);
imagesc(phasor_his)
colormap(gca,jet); ax = gca; ax.Colormap(1,:)= [1 1 1]; caxis('auto');
colorbar; axis image;

x_circle     = [map_res/2:map_res];
%% y_circle_pos = map_res/2-floor(sqrt((map_res/4)^2-((x_circle-map_res/2)-map_res/
y_circle_pos = map_res/2-floor(sqrt((map_res/4)^2-((x_circle-map_res/2)-map_res/4).^2));
y_circle_neg = map_res/2+floor(sqrt((map_res/4)^2-((x_circle-map_res/2)-map_res/4).^2));
hold on; plot(x_circle,[y_circle_pos;y_circle_neg],'k','LineWidth',1)
axis([map_res/2 map_res  map_res/5  map_res/2])
set(gca,'XTick',[0,0.5,1], 'YTick', [0,0.25,0.5])
xticks([map_res/2:map_res/2^4:map_res]);
xticklabels({'0','', '','','0.5','', '','','1'});

yticks([0:map_res/2^4:map_res/2]);
yticklabels({'0','', '0.25','','0.5'});
xlabel('G');ylabel('S')
end
