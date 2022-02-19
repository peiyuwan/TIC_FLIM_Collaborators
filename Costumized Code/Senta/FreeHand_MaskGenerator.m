%% Generate the Membrane Label for INS-1E cells labeled with Cell Mask
% 05/10/2021
% Peiyu Wang

close all;clear all;

addpath("D:\Scott Lab\Leica Program\CurrentVersion\Functions");
%%
master_folder = "D:\Scott Lab\Papers\Machine Learning Metabolism\Nucleus";

master_save_folder = "D:\Scotts Lab\Papers\Machine Learning Metabolism\Nucleus\Labeled Data2";
if ~exist(master_save_folder,'dir')
    mkdir(master_save_folder)
end

sample_folder = dir(master_folder);

% SE = strel('disk', 4);
% SE2 = strel('disk', 3);

image_size = 512;   %%  Change this according to your size. 

for idx1 = 12 : 15
    current_folder = fullfile(sample_folder(idx1).folder,sample_folder(idx1).name);
    disp(["idx:" + num2str(idx1) + ", sample: " + num2str(sample_folder(idx1).name)])

      
    save_folder = fullfile(master_save_folder,sample_folder(idx1).name);
    
    if ~exist(save_folder,'dir')
        mkdir(save_folder)
        mkdir(fullfile(save_folder,"Label"))
        mkdir(fullfile(save_folder,"Image"))
    end
    
    image_file = dir(fullfile(current_folder,"*.tif"));
    BF_file = dir(fullfile(current_folder,"BF","*.tif"));
    
    stain_int = imread(fullfile(image_file(1).folder,image_file(1).name));
    stain_G = normalizephaseG(imread(fullfile(image_file(3).folder,image_file(3).name)));
    stain_S = normalizephaseS(imread(fullfile(image_file(4).folder,image_file(4).name)));
    
    BF_stain = normalizeBF(imread(fullfile(BF_file(2).folder,BF_file(2).name)));   

    
    
    %% Normlizing the input
    
    % phase normaization: we have everything below 0 in phase domain as 0;
    % for G: we stretch 0 - 1 to 0 to 255;
    % for S: we stretch 0 - 0.5 to 0 to 255; 
    % 
    % For BF. we take the minimum 200 values as 0, the maximum 200 values
    % as 255.
    int = normalizeImg(imread(fullfile(image_file(5).folder,image_file(5).name)));
    
    G = normalizephaseG(imread(fullfile(image_file(7).folder,image_file(7).name)));
    S = normalizephaseS(imread(fullfile(image_file(8).folder,image_file(8).name)));
   
    BF_NADH = normalizeBF(imread(fullfile(BF_file(3).folder,BF_file(3).name)));
    
    %% Correction for frame shift between 2P and confocal channel. 
    
    disp('Registering Images')
    c = normxcorr2(BF_NADH,BF_stain);
    [max_c, imax] = max(c(:));
    [ypeak, xpeak] = ind2sub(size(c),imax(1));
    
%     ypeak = 529; xpeak = 516;
    
     y_offset = ypeak - 512;
    x_offset = xpeak - 512;
    
    if x_offset == 0
        NADH_x = [1,512]; Stain_x = [1,512];    
    elseif x_offset > 0
        NADH_x = [1,512-x_offset+1]; Stain_x = [x_offset,512];
    else
        NADH_x = [-x_offset,512]; Stain_x = [1, 512+x_offset+1];
    end
    
    
    
    if y_offset == 0
        NADH_y = [1,512]; Stain_y = [1,512];
    elseif y_offset > 0
        NADH_y = [1,512-y_offset+1]; Stain_y = [y_offset,512];
    else
        NADH_y = [-y_offset,512]; Stain_y = [1, 512+y_offset+1];
    end

    BF_NADH = BF_NADH(NADH_y(1):NADH_y(2),NADH_x(1):NADH_x(2));
    int = int(NADH_y(1):NADH_y(2),NADH_x(1):NADH_x(2));
    G = G(NADH_y(1):NADH_y(2),NADH_x(1):NADH_x(2));
    S = S(NADH_y(1):NADH_y(2),NADH_x(1):NADH_x(2));
    
    BF_stain = BF_stain(Stain_y(1):Stain_y(2),Stain_x(1):Stain_x(2));   
    stain_int = stain_int(Stain_y(1):Stain_y(2),Stain_x(1):Stain_x(2));
    stain_G = stain_G(Stain_y(1):Stain_y(2),Stain_x(1):Stain_x(2));
    stain_S = stain_S(Stain_y(1):Stain_y(2),Stain_x(1):Stain_x(2));
        
    %% Start drawing the membrane:
    mask_map = cat(3,ones(size(BF_stain))*0,ones(size(BF_stain))*1,ones(size(BF_stain))*0);
    current_map = cat(3,ones(size(BF_stain))*1,ones(size(BF_stain))*0,ones(size(BF_stain))*1);
    disp('Draw Membrane:')
    
    level = sort(stain_int(:));
    stain_int(stain_int > level(floor(numel(level)*0.95))) = level(floor(numel(level)*0.95));
    stain_int(stain_int < level(floor(numel(level)*0.3))) = 0;
 
    %%
    
    mask_img = zeros(size(int));
    
    figure;set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    subplot(2,2,1); 
    
    stain_phasor = double(stain_G) - double(stain_S);
    imagesc(stain_phasor); 
    colormap(gca, jet); axis image; colorbar; caxis([-250 150]);
        

    hold on; 
    p1 = imshow(mask_map); set(p1, 'AlphaData',mask_img);
    set(p1, 'AlphaData',mask_img);
    
    subplot(2,2,2); 
   
    imagesc(stain_int); axis image; colormap(gca, jet); colorbar;  
    
    hold on;  p2 = imshow(mask_map); set(p2, 'AlphaData',mask_img);
    
              
    subplot(2,2,4);    
    imshow(int);  colormap(gca, jet); axis image; colorbar;
    hold on;  p3 = imshow(mask_map); set(p3, 'AlphaData',mask_img);    
              
    judge_thresh = 1;
    while judge_thresh == 1
        
        temp_thresh_img = zeros(size(int));
        thresh = input("Please input threshold level: ");
        
        temp_thresh_img(stain_phasor<thresh)=1;
        
        set(p1, 'AlphaData',temp_thresh_img*0.5);
        set(p2, 'AlphaData',temp_thresh_img*0.5);
        set(p3, 'AlphaData',temp_thresh_img*0.5);
        
        subplot(2,2,3);
        imshow(temp_thresh_img)
        
        promptMessage = "Do you want to reselect?(Y/N):";
        button1 = questdlg(promptMessage, 'Reselect threshold?', 'Yes', 'No', 'Yes');
        if strcmpi(button1, 'No')
            judge_thresh = 0;
        else
            set(p1, 'AlphaData',0);
            set(p2, 'AlphaData',0);
            set(p3, 'AlphaData',0);
            
        end
    end
    mask_img(temp_thresh_img > 0) = 1;          
                    
              
              
              
              
              
    judge = 1;
    while judge == 1
        subplot(1,2,1)
        H=drawfreehand('color','m','closed',true,'Linewidth',2);
        
        add_mask = H.createMask;
%         add_mask = imdilate(add_mask,SE);
        set(p4, 'AlphaData',add_mask*0.55);
        set(p7, 'AlphaData',add_mask*0.55);
                
        button = questdlg("Add Another Region?", 'Next?', ...
            'Add to Current Mask', 'Redo','Done(with this round)',...
            'Add to Current Mask');
        if strcmp(button, 'Done(with this round)')
            mask_img(add_mask == 1) = 1;
            set(p4, 'AlphaData',0);
            set(p3, 'AlphaData',mask_img*0.55);
            
            set(p7, 'AlphaData',0);
            set(p6, 'AlphaData',mask_img*0.55);
            
            break
        elseif strcmp(button, 'Add to Current Mask')
            mask_img(add_mask == 1) = 1;
            set(p4, 'AlphaData',0);
            set(p3, 'AlphaData',mask_img*0.55);
            
            set(p7, 'AlphaData',0);
            set(p6, 'AlphaData',mask_img*0.55);
            
        else
            delete(H)
            set(p4, 'AlphaData',0);
            set(p7, 'AlphaData',0);
        end
    end
    
        %%
    subplot(1,2,1); 
    
    p1 =  imagesc(stain_int); axis image; colormap(gca, jet); colorbar; 
    
    subplot(2,2,2); 
   
    p2 = imagesc(double(stain_G) - double(stain_S)); 
    colormap(gca, jet); axis image; colorbar; caxis([-250 150]);
   
    hold on;  p3 = imshow(mask_map); set(p3, 'AlphaData',mask_img * 0.55);
              p4 = imshow(current_map); set(p4, 'AlphaData',0);
    
              
    subplot(2,2,4);    
    p5 = imshow(int);  colormap(gca, jet); axis image; colorbar;
    hold on;  p6 = imshow(mask_map); set(p6, 'AlphaData',mask_img * 0.55);
              p7 = imshow(current_map); set(p7, 'AlphaData',0);          
              
    
    judge = 1;
    while judge == 1
        subplot(1,2,1)
        H=drawfreehand('color','m','closed',true,'Linewidth',2);
        
        add_mask = H.createMask;
%         add_mask = imdilate(add_mask,SE);
        set(p4, 'AlphaData',add_mask*0.55);
        set(p7, 'AlphaData',add_mask*0.55);
                
        button = questdlg("Add Another Region?", 'Next?', ...
            'Add to Current Mask', 'Redo','Done(with this round)',...
            'Add to Current Mask');
        if strcmp(button, 'Done(with this round)')
            mask_img(add_mask == 1) = 1;
            set(p4, 'AlphaData',0);
            set(p3, 'AlphaData',mask_img*0.55);
            
            set(p7, 'AlphaData',0);
            set(p6, 'AlphaData',mask_img*0.55);
            
            break
        elseif strcmp(button, 'Add to Current Mask')
            mask_img(add_mask == 1) = 1;
            set(p4, 'AlphaData',0);
            set(p3, 'AlphaData',mask_img*0.55);
            
            set(p7, 'AlphaData',0);
            set(p6, 'AlphaData',mask_img*0.55);
            
        else
            delete(H)
            set(p4, 'AlphaData',0);
            set(p7, 'AlphaData',0);
        end
    end
    
    
    
    
    
    %%
    % Storing a version before doing the image resizing. 
    imwrite(mask_img,fullfile(current_folder,"BF","label_org.tif"));
    %% Resizing the images to what we want. 
    
    
    BF_NADH = BF_NADH(1:image_size,1:image_size);
    int = int(1:image_size,1:image_size);
    G = G(1:image_size,1:image_size);
    S = S(1:image_size,1:image_size);
    
    BF_stain = BF_stain(1:image_size,1:image_size);
    mask_img = mask_img(1:image_size,1:image_size);
%     mask_img = imerode(mask_img,SE2);
    
    
    %%
    figure;set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    subplot(2,3,1); imagesc(int); axis image; colorbar; colormap(gca,jet);caxis([0 255]);title('NADH Intensity');
    subplot(2,3,2); imagesc(G); axis image; colorbar; colormap(gca,jet);caxis([0 255]);title('G');
    subplot(2,3,3); imagesc(S); axis image; colorbar; colormap(gca,jet);caxis([0 255]);title('S');
    subplot(2,3,4); imagesc(BF_NADH); axis image; colorbar; colormap(gca,bone); caxis([0 255]);title('BF');
    subplot(2,3,5); imshow(mask_img); axis image;title('MASK');
    subplot(2,3,6); imshowpair(BF_NADH,BF_stain,'falsecolor');title('Blending')
    
    %%

    
    imwrite(int,fullfile(save_folder,"Image","ch0.tif"));
    imwrite(G,fullfile(save_folder,"Image","ch1.tif"));
    imwrite(S,fullfile(save_folder,"Image","ch2.tif"));
    imwrite(BF_NADH,fullfile(save_folder,"Image","ch3.tif"));
    imwrite(mask_img,fullfile(save_folder,"Label","label.tif"));
    
    pause
    close all;
end

%% function: normalizeImg
% Normalize image to 0-255 image; 

function new_img = normalizeImg(org_img)
max_val = double(max(org_img(:)));
new_img = uint8(double(org_img)/max_val*255);
end

function new_img = normalizeBF(org_img)
level = sort(org_img(:));
min_val = level(200);
org_img = org_img - min_val;
org_img(org_img<0) = 0;
max_val = (level(end - 200)-min_val);
org_img(org_img>max_val) = max_val; 
new_img = uint8(double(org_img)/double(max_val)*255);
end

function new_img = normalizephaseG(org_img)
org_img(org_img < 2^15) = 0;
org_img = org_img - 2^15;
new_img = uint8(double(org_img)/2^15*255);
end


function new_img = normalizephaseS(org_img)
org_img(org_img < 2^15) = 0;
org_img = org_img - 2^15;
org_img(org_img > 2^14) = 2^14;
new_img = uint8(double(org_img)/2^14*255);
end


%% Unused Code: 
   
%     
%     %%
%     stain_G = imread(fullfile(image_file(3).folder,image_file(3).name));
%     stain_G = normalizephaseG(stain_G);
%     stain_G = stain_G(Stain_y(1):Stain_y(2),Stain_x(1):Stain_x(2));
%     
%     
%     figure; p0 = imagesc(stain_G); axis image; colormap jet; colorbar; caxis([130 185])
%     set(p0, 'AlphaData',double(stain_int)/double(max(stain_int(:))));
    