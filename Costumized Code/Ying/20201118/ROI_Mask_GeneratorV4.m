%% Generate Mask For ROI plots
% Peiyu Wang
% 10/10/2020

% Mask is generated for the exported Leica Falcon Lifetime image. The masks
% will be stored under a different folder with name "ROI_Mask", with the
% name of the same file and mask.tif at the end.

% Excel file created in ROI_Mask Folder store the thresholds. 

% Expected exportion method: Tiff Files, with Fast FLim included

close all; clear all;

addpath(fullfile(pwd,'Functions'))
%% Hyper Parameters
% Please adjust the following parameters according to your needs

DataFolder = "D:\Scotts Lab\FLIM\Leica SP8\Leica Program\Collaborations\For Senta\20201117\RawData";
% Where the data is stored
z_stacks = 1;      % Number os Z_stacks
mask_base_ch = 5;  % Which detector sequence to base the mask creation on.
mask_ch = [8,12];  % the channel number you want to create the mask on. XX according to chXX.
plot_color = ['r','m','g','c','y','w'];  % Order of colors displayed. Does not effect the ROI exportion.


%% Tiff file format parameters. Please don't change.
tagstruct.SampleFormat = 1;
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 8;
tagstruct.SamplesPerPixel = 1;
tagstruct.Compression = Tiff.Compression.None;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;

%% Data Read in
imageFile = dir(fullfile(DataFolder,'*.tif'));
% z_stacks = numel(imageFile)/detector_No/4;

mask_folder = fullfile(DataFolder,'ROI_Mask');
if ~exist(mask_folder,'dir')
    mkdir(mask_folder)
end

if numel(imageFile)>10
    channel_con = '%01d';
else
    channel_con = '%02d';
end
colors = [1,0,1;0,1,1];

figure;set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
int = imread(fullfile(DataFolder,imageFile((mask_base_ch-1)*4+1).name));
G = standardPhase(imread(fullfile(DataFolder,imageFile((mask_base_ch-1)*4+3).name)));
S = standardPhase(imread(fullfile(DataFolder,imageFile((mask_base_ch-1)*4+4).name)));
current_struct = struct('int',int,'G',G,'S',S);
subplot(1,2,1); imagesc(current_struct.int); axis image; colorbar; colormap bone;
caxis([0 150]); %%This is the colorbar axis;%%You can adjust this accrouding to the figure

low_thresh = zeros(1,numel(mask_ch));

mask_set = zeros(size(int,1),size(int,1),2);
while 1
    for i = 1:numel(mask_ch)
        color_map = cat(3,ones(size(int))*colors(rem(i,2)+1,1),...
               ones(size(int))*colors(rem(i,2)+1,2),ones(size(int))*colors(rem(i,2)+1,3));
        subplot(2,2,2);
        mask_org = imread(fullfile(DataFolder,imageFile(mask_ch(i)+1).name));
              
        imagesc(mask_org);axis image; colormap(gca,'hot');colorbar;
        while 1
            low = input("Please input lower threshold: ");
            mask=mask_org;
            mask(mask<low)=0;
            mask(mask~=0)=1;
            subplot(1,2,1); hold on; h = imshow(color_map);
            title(["Channel:"+num2str(mask_ch(i))]);
            if i == 2
                mask(mask_set(:,:,1) == 1) = 0;
            end
            set(h,'AlphaData',double(mask)*0.5);
            thresh_struct = threshPhasorMask(current_struct,mask);
            subplot(2,2,4); plotPhasorFast(thresh_struct);title("Phasor Plot")
            promptMessage = "Reselect Thresholds?";
            button = questdlg(promptMessage, 'Next?','Yes','No','Yes');
            if strcmp(button, 'No')
                low_thresh(i) = low;
                mask_set(:,:,i) = mask;
                break
            else
                delete(h);
            end
        end
    end
    promptMessage = "Reselect Thresholds for whole stack?";
    button = questdlg(promptMessage, 'Next?','Yes','No','Yes');
    if strcmp(button, 'No')
        figure
        for i = 1:numel(mask_ch)
            subplot(1,2,i); imagesc(mask_set(:,:,i));axis image;
        end
        break
    else
        low_thresh = zeros(1,numel(mask_ch));
        close
        figure
        subplot(1,2,1); imagesc(current_struct.int); axis image; colorbar; colormap bone;
        caxis([0 150]);
    end

end

%% Using Lifetime and K-Means
figure
noise_thresh = zeros(1,numel(mask_ch));
K_set = [];
for idx_ch = 3:4
    int = imread(fullfile(DataFolder,imageFile((idx_ch-1)*4+1).name));
    G = standardPhase(imread(fullfile(DataFolder,imageFile((idx_ch-1)*4+3).name)));
    S = standardPhase(imread(fullfile(DataFolder,imageFile((idx_ch-1)*4+4).name)));
    
    current_struct = struct('int',int,'G',G,'S',S);
    subplot(1,2,1); imagesc(current_struct.int); axis image; colorbar; colormap hot;
    while 1
        noise_value = input("Please input noise threshold: ");
        
        thresh_struct = threshPhasor(current_struct,noise_value);
        subplot(1,2,2); imagesc(thresh_struct.int); axis image; colorbar; colormap hot;
        promptMessage = "Reselect Thresholds?";
        button = questdlg(promptMessage, 'Next?','Yes','No','Yes');
        if strcmp(button, 'No')
            noise_thresh(idx_ch-2) = noise_value;
            break
        end
    end
%     K_set = cat(2,K_set,thresh_struct.int(:));
    K_set = cat(2,K_set,thresh_struct.G(:));
    K_set = cat(2,K_set,thresh_struct.S(:));
end
%%
mask_k_set = zeros(size(K_set,1),1);
mask_k_set(sum(K_set,2)~=0)=1;

X = double(K_set(mask_k_set==1,:));
knum = 2;
[idx,~,sumd,D_org] = kmeans(X,knum);

phasor_mask = zeros(size(int));

index = 1;
mask_1 = imread(fullfile(DataFolder,imageFile(mask_ch(1)+1).name));
mask_2 = imread(fullfile(DataFolder,imageFile(mask_ch(2)+1).name));
mask_k_set = reshape(mask_k_set,size(int));
for j = 1:size(int,1)
    for i = 1:size(int,2)
        if mask_k_set(i,j) == 1;
            phasor_mask(i,j) = idx(index);
            index = index + 1;
        end
    end
end

t = Tiff(fullfile(mask_folder,"mask.tif"),'w');

tagstruct.ImageLength = size(int,1);
tagstruct.ImageWidth =size(int,2);

for ii=1:2
    setTag(t,tagstruct);
    write(t,uint8(mask_set(:,:,ii)));
    writeDirectory(t);
end























%%


filename = 'Parameters.xlsx';
writecell({'Mask 1','Mask 2'},fullfile(mask_folder,filename),'Sheet',1,'Range','B1:C1');
writecell({"Lower Threshold"},fullfile(mask_folder,filename),'Sheet',1,'Range','A2');
writematrix(low_thresh,fullfile(mask_folder,filename),'Sheet',1,'Range','B2');

%% Functions


function thresh_ref = threshPhasorMask(org_ref, mask)
thresh_ref = org_ref;
thresh_ref.int(mask == 0) = 0;
thresh_ref.G(mask == 0) = 0;
thresh_ref.S(mask == 0) = 0;
end

function thresh_ref = threshPhasor(org_ref, thresh_value)
thresh_ref = org_ref;
thresh_ref.int(org_ref.int <thresh_value) = 0;
thresh_ref.G(org_ref.int <thresh_value) = 0;
thresh_ref.S(org_ref.int <thresh_value) = 0;
end
