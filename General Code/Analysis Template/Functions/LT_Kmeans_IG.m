%% Function: K means Figure Generator
% Peiyu Wang
% 09/03/2020


function phasor_mask = LT_Kmeans_IG(org_struct,knum,name,noise_level)


global SaveFigFolder
% SaveFigFolder = pwd;

X = cat(2,org_struct.G(and(org_struct.int>noise_level,abs(org_struct.G)>1.5e-5)),org_struct.S(and(org_struct.int>noise_level,abs(org_struct.G)>1.5e-5)));

[idx,~,sumd,D_org] = kmeans(X,knum);

phasor_mask = zeros(size(org_struct.int));

index = 1;
for j = 1:size(org_struct.int,1)
    for i = 1:size(org_struct.int,2)
        
        if and(org_struct.int(i,j)>noise_level,abs(org_struct.G(i,j))>1.5e-5)
            phasor_mask(i,j) = idx(index);
            index = index + 1;
        end
        
    end
end

idx_img = phasor_mask; idx_mean = zeros(1,knum);

for i = 1:knum
   idx_mean(i) = mean(org_struct.G(phasor_mask == i));   
end
[idx_rank,I] = sort(idx_mean);
phasor_mask = zeros(size(org_struct.int));
for i = 1:knum
    phasor_mask(idx_img == I(i)) = i;
end

colorcode = [0,0,0;1,0,1;0,1,1;1,1,0;0,1,0;0,0,1;1,0,0];  % Magenta, Cyan, Yellow, Grean, Blue, Red

figure;set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
h = imagesc(phasor_mask); axis image;
ax = gca;ax.Colormap = colorcode(1:1+knum,:);
title(name)
set(gca,'FontSize',21);axis off;
saveas(gcf,fullfile(SaveFigFolder,[name+"_Kmeans_Seperate.tif"]))

%% Phasor Figure
figure;set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
map_res = size(org_struct.int,1)*2;
phasor_his = zeros(map_res,map_res);
phasor_his_Stack = zeros(map_res,map_res,knum+1);


for i = 1:size(org_struct.int,1)
    for j = 1:size(org_struct.int,2)
        G_index = floor(org_struct.G(i,j)*map_res/2+map_res/2+1); %function floor is doing the binning for you.
        S_index = floor(org_struct.S(i,j)*map_res/2+map_res/2+1);
        if G_index < 1; G_index = 1; end
        if S_index < 1; S_index = 1; end
        if G_index > map_res; G_index = map_res; end
        if S_index > map_res; S_index = map_res; end
        
        phasor_his(S_index,G_index) = phasor_his(S_index,G_index)+1;
        phasor_his_Stack(S_index,G_index,phasor_mask(i,j)+1) = 1;
    end
end
phasor_his_Stack = phasor_his_Stack(:,:,2:end);
[max_val,max_Idx] = max(phasor_his(:));
phasor_his(max_Idx) = 0;
phasor_his = flip(phasor_his);
imagesc(phasor_his);
colormap(gca,hot); axis image; caxis('auto');axis on;
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

hold on;
for i = 1:knum
    pha_mask = cat(3,ones(size(phasor_his))*colorcode(i+1,1),...
    ones(size(phasor_his))*colorcode(i+1,2),...
    ones(size(phasor_his))*colorcode(i+1,3));
    
    h = imshow(pha_mask);  set(h, 'AlphaData', flip(phasor_his_Stack(:,:,i))*0.7)
end
axis on;
title(name)

set(gca,'FontSize',21);
saveas(gcf,fullfile(SaveFigFolder,[name+"_PhasorSep.tif"]))


end