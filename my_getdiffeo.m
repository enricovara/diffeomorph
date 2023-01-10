%==========================================================================
% Create diffeowarp matrices.

% 

% Adapted from:
% github.com/rhodricusack/diffeomorph/blob/master/diffeomorphic_movie.m
% Stojanoski, B., & Cusack, R. (2014).
% Time to wave good-bye to phase scrambling: Creating controlled scrambled
%    images using diffeomorphic transformations.
% Journal of Vision, 14(12), 6. doi:10.1167/14.12.6

% Note: Mturk perceptual ratings of images are based on maxdistortion = 80;
%    and nsteps = 20

% inputs
%    imsz - size of visual image (including padding)
%    max_distort - max pixel loc. shift after nsteps flow field appli.tions
%    nsteps - number of flowfield application steps needed to max_distort
%    ncomp - number of DCT components along each axis
% outputs
%    yD, xD are imsz*imsz flow field arrays of pixel dist.n in X and Y dir.

%==========================================================================

function [yD, xD] = my_getdiffeo(im_sz,max_distort,ncomp,nsteps,rng_val)

    % control seed of random generator for consitency
    if rng_val == 0
        % seed the random generator with a random number
        tic; pause(toc*3); pause(toc*7); b = toc^0.1*1000000;
        rng(b);
    else
        % or use the provided value
        rng(rng_val)
    end
    
    % create arrays containing cartesian coordinates of pixel locations
    [yI, xI] = meshgrid(1:im_sz,1:im_sz);
    
    % make diffeomorphic warp field by adding random DCTs
    ph = rand(ncomp,ncomp,4)*2*pi; % random phase for each component
    xA = rand(ncomp,ncomp)*2*pi; % different random amplitudes for x
    yA = rand(ncomp,ncomp)*2*pi; % and y DCT components
    
    % create deformation array by adding together the DCTs
    % TODO: verctorise this computation for faster performance
    xD = zeros(im_sz,im_sz);
    yD = zeros(im_sz,im_sz);
    for xC = 1:ncomp % for every x component
        for yC = 1:ncomp % for every y component
            xD = xD + xA(xC,yC)*cos(xC*xI/im_sz*2*pi+ph(xC,yC,1))*cos(yC*yI/im_sz*2*pi+ph(xC,yC,2));
            yD = yD + yA(xC,yC)*cos(xC*xI/im_sz*2*pi+ph(xC,yC,3))*cos(yC*yI/im_sz*2*pi+ph(xC,yC,4));
        end
    end

    % Normalise to RMS of warps in each direction
    xD = xD/sqrt(mean(xD(:).*xD(:)));
    yD = yD/sqrt(mean(yD(:).*yD(:)));
    
    % scale distorsion metricx by the number of steps and max distorsion
    xD = xD*max_distort/nsteps;
    yD = yD*max_distort/nsteps;

    % add distorsion to pixel cartesian coordinates
    [yI, xI]=meshgrid(1:im_sz,1:im_sz);
    xD = xD + xI;
    yD = yD + yI;

    % boundaries (don't stretch pixel locations past image boundary)
    mask = (xD<1) | (xD>im_sz) | (yD<1) | (yD>im_sz) ;
    xD(mask) = 1;
    yD(mask) = 1;

end