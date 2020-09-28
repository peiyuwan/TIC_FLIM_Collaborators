function FLIM_GVar(G,S,G_min,G_max)


% select_mask = zeros(size(G,1),size(G,2));
% 
% map_res = 1024;
% for i = 1:size(G,1)
%     for j = 1:size(G,2)
%         G_index = floor(org_struct.G(i,j)*map_res/2+map_res/2+1); %function floor is doing the binning for you.
%         S_index = floor(org_struct.S(i,j)*map_res/2+map_res/2+1);
%         if G_index < 1; G_index = 1; end
%         if S_index < 1; S_index = 1; end
%         if G_index > map_res; G_index = map_res; end
%         if S_index > map_res; S_index = map_res; end
%           
%         for k = 1: size(select_mask,3)
%             if ph_phasor(S_index,G_index,k) == 0
%             select_mask(i,j,k) = 0;
%             end
%         end
%     end
% end
% 
% 
% select_mask = logical(select_mask);
% G_selected = G(mask);
% 
% [G_order,G_I] = sort(G_selected);
% G_max = G_order(round(numel(G_order)*1));
% G_min = G_order(1);
% 
% colors = [0,1,1;1,0,1];
% 
% G_image = ones(size(org_struct.G))*(-1.001);
% 
% for j = 1:size(org_struct.int,1)
%     for i = 1:size(org_struct.int,2)
%         
%         if select_mask(i,j,2) == 1
%             G_image(i,j) = round((org_struct.G(i,j)-G_min)/(G_max-G_min)*255);
%         end
%     end
% end
% D = GenerateColorcode(colors);
% figure;set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% imagesc(G_image);axis image; ax = gca; ax.Colormap = D; colorbar;
% hold on;
% black_map = zeros([size(org_struct.G),3]);
% h = imshow(black_map); set(h,'AlphaData',1-select_mask(:,:,2));
% 
% yellow_map = cat(3,ones(size(org_struct.G)),ones(size(org_struct.G)),ones(size(org_struct.G))*0);
% h = imshow(yellow_map);  set(h,'AlphaData',select_mask(:,:,1));
% title(name);set(gca,'FontSize',21);
% saveas(gcf,fullfile(SaveFigFolder,[name+"_Gvar_Seperate.tif"]))
%%
figure;set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
map_res = 1024;
phasor_his = zeros(map_res,map_res);

for i = 1:size(G,1)
    for j = 1:size(G,2)
        G_index = floor(G(i,j)*map_res/2+map_res/2+1); %function floor is doing the binning for you.
        S_index = floor(S(i,j)*map_res/2+map_res/2+1);
        if G_index < 1; G_index = 1; end
        if S_index < 1; S_index = 1; end
        if G_index > map_res; G_index = map_res; end
        if S_index > map_res; S_index = map_res; end
        
        phasor_his(S_index,G_index) = phasor_his(S_index,G_index)+1;
        
    end
end

mask = G~=-1;

% G_selected = G(mask);
% 
% [G_order,G_I] = sort(G_selected);
% G_max = G_order(round(numel(G_order)*1));
% G_min = G_order(1);

colors = [0,1,1;1,0,1];

G_image = ones(size(G))*G_min-0.01;

for j = 1:size(G,1)
    for i = 1:size(G,2)
        
        if mask(i,j) == 1
            if G(i,j)< G_min; G_image(i,j)=G_min;
            elseif G(i,j)>G_max; G_image(i,j)=G_max;
            else
                G_image(i,j)=G(i,j);
%                 G_image(i,j) = round((G(i,j)-G_min)/(G_max-G_min));
            end
        end
    end
end

D = GenerateColorcode(colors);D(1,:) = [1,1,1];
figure;set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
imagesc(G_image);axis image; ax = gca; ax.Colormap = D; colorbar;




% 
% [max_val,max_Idx] = max(phasor_his(:));
% phasor_his(max_Idx) = 0;
% phasor_his = flip(phasor_his);
% % imagesc(phasor_his);
% % colormap(gca,hot); axis image; caxis('auto');axis on;
% % ax=gca; ax.Colormap(1,:) = [1,1,1];
% 
% hold on;
% % white_mask = ones([size(phasor_his),3]);
% % white_trans = sum(phasor_his_Stack,3);
% % % h = imshow(white_mask);  set(h, 'AlphaData', 1-flip(white_trans))
% temp = flip(phasor_his_Stack(:,:,2))*0.7;
% h = imagesc(flip(pha2_mask)); ax=gca; ax.Colormap = D; set(h,'AlphaData',temp);
% 
% 
% 
%     
% 
% 
% pha1_mask = cat(3,ones(size(phasor_his)),...
%     ones(size(phasor_his)),...
%     ones(size(phasor_his))*0);
%     
% h = imshow(pha1_mask);  set(h, 'AlphaData', flip(phasor_his_Stack(:,:,1))*0.7);
% 
% x_circle     = [1:map_res];
% y_circle_pos = map_res/2-floor(sqrt((map_res/2)^2-((x_circle-map_res/2)).^2));
% y_circle_neg = map_res/2+floor(sqrt((map_res/2)^2-((x_circle-map_res/2)).^2));
% hold on; plot(x_circle,[y_circle_pos;y_circle_neg],'k','LineWidth',1)
% 
% 
% xticks([0:map_res/8:map_res]);
% xticklabels({'-1','-0.75','-0.5','-0.25','0','0.25','0.5','0.75','1'});
% 
% yticks([0:map_res/8:map_res]);
% yticklabels({'-1','-0.75','-0.5','-0.25','0','0.25','0.5','0.75','1'});
% plotRadialGrid(map_res);
% 
% 
% axis on; axis image
% title(name)
% xlabel('G');ylabel('S');
% set(gca,'FontSize',21);
% saveas(gcf,fullfile(SaveFigFolder,[name+"_Gvar_Phasor.tif"]))
end



function D = GenerateColorcode(colorcode)
D = zeros(256,3);
for i = 1:3
       D(:,i) = interp1([1,256],[colorcode(1,i),colorcode(2,i)],[1:256])';
end
end