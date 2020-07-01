
function filt_struct = nlmfiltPhasor(org_struct,mask_size,window_size)

if nargin == 1
    mask_size = 3;
    window_size = 9;
end

mask_edge = (mask_size-1)/2;
window_edge = (window_size-1)/2;

new_int = padarray(org_struct.int, [window_edge+mask_edge window_edge+mask_edge],'replicate','both');
new_G = padarray(org_struct.G, [window_edge+mask_edge window_edge+mask_edge],'replicate','both');
new_S = padarray(org_struct.S, [window_edge+mask_edge window_edge+mask_edge],'replicate','both');

filt_G = zeros(size(org_struct.G));
filt_S = zeros(size(org_struct.S));

tic
% i and j indexes for the new_int images.
for i = 1+window_edge+mask_edge: window_edge+mask_edge+size(org_struct.int,1)
    for j = 1+window_edge+mask_edge: window_edge+mask_edge+size(org_struct.int,2)
        if org_struct.int(i - (window_edge+mask_edge),j- (window_edge+mask_edge)) ~= 0
            mask = new_int(i-mask_edge: i+mask_edge,j-mask_edge: j+mask_edge);
            mask_G = new_G(i-window_edge:i+window_edge,j-window_edge:j+window_edge);
            mask_S = new_S(i-window_edge:i+window_edge,j-window_edge:j+window_edge);
            mse_window = zeros(window_size);
            
            for m = -window_edge:window_edge
                for n = -window_edge:window_edge
                    if new_int(i+m,j+n)~= 0;
                        window_mask = new_int(i+m-mask_edge:i+m+mask_edge,j+n-mask_edge:j+n+mask_edge);
                        mse_window(m+1+window_edge,n+1+window_edge) = immse(mask,window_mask);
                    end
                end
            end
            non = (mse_window == 0);
            mse_window(mse_window == 0) = 1;
            temp_mse = 1./mse_window;
            temp_mse(non) = 0;  % if it is all NAN;
            filt_G(i - (window_edge+mask_edge),j- (window_edge+mask_edge))=...
                temp_mse(:)'* mask_G(:)/sum(temp_mse(:));
            filt_S(i - (window_edge+mask_edge),j- (window_edge+mask_edge))=...
                temp_mse(:)'* mask_S(:)/sum(temp_mse(:));
        end
    end
end
toc
filt_G(isnan(filt_G)) = 0; filt_S(isnan(filt_S)) = 0;
filt_struct = struct('int',org_struct.int,'G',filt_G,'S',filt_S);

end