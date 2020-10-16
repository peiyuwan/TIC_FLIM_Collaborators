%% Generate Mask For ROI plots
% Peiyu Wang
% 10/10/2020

% Mask is generated for the exported Leica Falcon Lifetime image. The masks
% will be stored under a different folder with name "ROI_Mask", with the
% name of the same file and mask.tif at the end.

% Excel file created in ROI_Mask Folder store the thresholds. 

% Expected exportion method: Tiff Files, no Fast FLim included

close all; clear all;

addpath(fullfile(pwd,'Functions'))
%% Hyper Parameters
% Please adjust the following parameters according to your needs

DataFolder = "D:\Scotts Lab\FLIM\Leica SP8\Leica Program\Collaborations\For Senta\20201010\RawData";
% Where the data is stored
z_stacks = 1;      % Number os Z_stacks
mask_base_ch = 1;  % Which channel to base the mask creation on.
mask_ch = [12,15];  % the channel number you want to create the mask on. XX according to chXX.
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

figure;set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
int = imread(fullfile(DataFolder,imageFile((mask_base_ch-1)*3+1).name));
G = standardPhase(imread(fullfile(DataFolder,imageFile((mask_base_ch-1)*3+2).name)));
S = standardPhase(imread(fullfile(DataFolder,imageFile((mask_base_ch-1)*3+3).name)));
current_struct = struct('int',int,'G',G,'S',S);
red_map = cat(3,ones(size(int)),zeros(size(int))...
    ,zeros(size(int)));
subplot(1,2,1); imagesc(current_struct.int); axis image; colorbar; colormap jet;
caxis([0 150]); %%This is the colorbar axis;%%You can adjust this accrouding to the figure

low_thresh = zeros(1,numel(mask_ch));
for i = 1:numel(mask_ch)
    
    subplot(2,2,2);
    mask_org = imread(fullfile(DataFolder,imageFile(mask_ch(i)+1).name));
    imagesc(mask_org);axis image; colormap(gca,'hot');colorbar;
    
    while 1
        low = input("Please input lower threshold: ");
        mask=mask_org;
        mask(mask<low)=0;
        mask(mask~=0)=1;
        subplot(1,2,1); hold on; h = imshow(red_map);
        title(["Channel:"+num2str(mask_ch(i))]);
        set(h,'AlphaData',double(mask)*0.5);
        thresh_struct = threshPhasorMask(current_struct,mask);
        subplot(2,2,4); plotPhasorFast(thresh_struct);title("Phasor Plot")
        promptMessage = "Reselect Thresholds?";
        button = questdlg(promptMessage, 'Next?','Yes','No','Yes');
        if strcmp(button, 'No')
            low_thresh(i) = low;
            delete(h);
            break
        else
            delete(h);
        end
    end
end

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
