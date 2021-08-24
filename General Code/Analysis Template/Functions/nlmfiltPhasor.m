function filt_struct = nlmfiltPhasor2(org_struct,mask_size,window_size,exp_h)

if nargin == 1
    mask_size = 3;
    window_size = 9;
    exp_h = 20;
end

mask_edge = (mask_size-1)/2;
window_edge = (window_size-1)/2;

% new_int et. al are associated with the expanded image. 
new_int = padarray(org_struct.int, [window_edge+mask_edge window_edge+mask_edge],'replicate','both');
new_G = padarray(org_struct.G, [window_edge+mask_edge window_edge+mask_edge],'replicate','both');
new_S = padarray(org_struct.S, [window_edge+mask_edge window_edge+mask_edge],'replicate','both');

% filt_mse et. al are the filted image. 
filt_G = zeros(size(org_struct.G));
filt_S = zeros(size(org_struct.S));
%%
tic
% i and j indexes for the new_int images.
% i and j do not move to full extend of new_int images. they only move in
% range of the filt images. 
for i = 1+window_edge+mask_edge: window_edge+mask_edge+size(org_struct.int,1)
    for j = 1+window_edge+mask_edge: window_edge+mask_edge+size(org_struct.int,2)
        % We are ignoring the points which are thresholded and set to zero. 
        if org_struct.int(i - (window_edge+mask_edge),j- (window_edge+mask_edge)) ~= 0
            % mask is created for the temporary window for comparision. 
            mask = new_int(i-mask_edge: i+mask_edge,j-mask_edge: j+mask_edge);
            mask_G = new_G(i-window_edge:i+window_edge,j-window_edge:j+window_edge);
            mask_S = new_S(i-window_edge:i+window_edge,j-window_edge:j+window_edge);
            mse_window = zeros(window_size);
            % mse_window shows the mses of masks inside the window. high
            % mse meanse low similarity.
            
            % m and n are used for the search window. 
            for m = -window_edge:window_edge
                for n = -window_edge:window_edge
                   if new_int(i+m,j+n)~= 0
                        window_mask = new_int(i+m-mask_edge:i+m+mask_edge,j+n-mask_edge:j+n+mask_edge);
                        mse_window(m+1+window_edge,n+1+window_edge) = norm(double(mask(:)-window_mask(:)));
                   end
                end
            end
            exp_window = exp(-mse_window/exp_h^2);    
            exp_window(exp_window == 1) = 0;
            exp_window(window_edge+1,window_edge+1) = 1;
            

            filt_G(i - (window_edge+mask_edge),j- (window_edge+mask_edge))=...
                exp_window(:)'* mask_G(:)/sum(exp_window(:));
            filt_S(i - (window_edge+mask_edge),j- (window_edge+mask_edge))=...
                exp_window(:)'* mask_S(:)/sum(exp_window(:));
        end
    end
end
toc
filt_G(isnan(filt_G)) = 0; filt_S(isnan(filt_S)) = 0;
filt_struct = struct('int',org_struct.int,'G',filt_G,'S',filt_S);

end
