%==========================================================================
% Create diffeowarp matrices.

% Adapted from:
% github.com/rhodricusack/diffeomorph/blob/master/diffeomorphic_movie.m
% Stojanoski, B., & Cusack, R. (2014).
% Time to wave good-bye to phase scrambling: Creating controlled scrambled
%    images using diffeomorphic transformations.
% Journal of Vision, 14(12), 6. doi:10.1167/14.12.6

% Note: Mturk perceptual ratings of images are based on maxdistortion = 80;
%    and nsteps = 20

% inputs
%    frame - image to be diffeomorphed
%    yD, xD - imsz*imsz flow field arrays of pixel dist.n in X and Y dir.
%    nsteps - number of flowfield application steps needed to max_distort
%    im_sz - size of visual image (including padding)
% outputs
%    morphed - diffeomorphed image

%==========================================================================

function morphed = diffeomorph_1frame(frame, yD, xD, nsteps, im_sz)

    in_size = size(frame);
    frame = frame(:,:,1:3); % remove alpha channel if present
    % TODO: add alpha channel back in for compatibility with other formats
            
    % 0 for black, 128 for grey 256 for white background of padding
    out_frame = uint8(ones(im_sz,im_sz,3)*256);

    % Add fourth plane (alpha) if originally present and set to 0
    % (presumably to add values back later, check this)
    if (in_size(3) == 4)
        out_frame(:,:,4) = 0;
    end

    % Upsample by factor of 2 in two non-channel dimensions
    % TODO: why was this done in github.com/rhodricusack/diffeomorph?
%     frame_2x = zeros([2*im_sz(1:2),im_sz(3)]);
%     frame_2x(1:2:end,1:2:end,:) = frame;
%     frame_2x(2:2:end,1:2:end,:) = frame;
%     frame_2x(2:2:end,2:2:end,:) = frame;
%     frame_2x(1:2:end,2:2:end,:) = frame;
%     frame = frame_2x;
%     in_size = size(frame);
    
    % Introduce pixel values from input frame into padded image
    x1 = round((im_sz-in_size(1))/2);
    y1 = round((im_sz-in_size(2))/2);
    
    out_frame((x1+1):(x1+in_size(1)), (y1+1):(y1+in_size(2)), :) = frame;

    % Pad with mirrored extensions of input frame
    % (this undeos background colour set earlier)
    out_frame(1:x1,(y1+1):(y1+in_size(2)),:) = frame(x1:-1:1,:,:);
    out_frame(x1+in_size(1)+1:end,(y1+1):(y1+in_size(2)),:) = frame(end:-1:end-x1+1,:,:);
    out_frame(:,1:y1,:)=out_frame(:,(y1+1+y1):-1:(y1+2),:);
    out_frame(:,y1+in_size(2)+1:end,:)=out_frame(:,(y1+in_size(2):-1:in_size(2)+1),:);

    % apply the morphing nsteps and for each colour channel
    for st_ = 1:nsteps
        for chn = 1:3
            out_frame(:,:,chn)=interp2(double(out_frame(:,:,chn)),yD,xD);
        end
    end

    % trim back to original size
    morphed = out_frame((x1+1):(x1+in_size(1)),(y1+1):(y1+in_size(2)),:);
%     morphed = uint8(morphed);


end



