%==========================================================================
% Create diffeowarp matrices.

% Adapted from:
% Stojanoski, B., & Cusack, R. (2014).
% Time to wave good-bye to phase scrambling: Creating controlled scrambled
%    images using diffeomorphic transformations.
% Journal of Vision, 14(12), 6. doi:10.1167/14.12.6

% Note: Mturk perceptual ratings of images are based on maxdistortion = 80;
%    and nsteps = 20

% inputs
%    imsz - size of visual image
%    maxdistortion - max displ. per pixel after nsteps flow field app.tions
%    nsteps - number of flowfield steps needed
%    ncomp - number of sin + cosine components along each axis
% outputs
%    XIn, YIn are imsz*imsz flow field arrays of pxl displ. in X and Y dir.

%==========================================================================

function morpher_M = my_getdiffeo(imsz,maxdistortion,ncomp,nsteps)
    
    [YI, XI] = meshgrid(1:imsz,1:imsz);
    
    % make diffeomorphic warp field by adding random DCTs
    ph = rand(ncomp,ncomp,4)*2*pi;
    a = rand(ncomp,ncomp)*2*pi;
    b = rand(ncomp,ncomp)*2*pi; % different amplitudes for x and y DCT components
    
    Xn = zeros(imsz,imsz);
    Yn = zeros(imsz,imsz);
    for xc = 1:ncomp
        for yc = 1:ncomp
            Xn = Xn+a(xc,yc)*cos(xc*XI/imsz*2*pi+ph(xc,yc,1))*cos(yc*YI/imsz*2*pi+ph(xc,yc,2));
            Yn = Yn+b(xc,yc)*cos(xc*XI/imsz*2*pi+ph(xc,yc,3))*cos(yc*YI/imsz*2*pi+ph(xc,yc,4));
        end
    end

    % Normalise to RMS of warps in each direction
    Xn = Xn/sqrt(mean(Xn(:).*Xn(:)));
    Yn = Yn/sqrt(mean(Yn(:).*Yn(:)));
    
    YIn = maxdistortion*Yn/nsteps;
    XIn = maxdistortion*Xn/nsteps;


    [YI, XI]=meshgrid(1:imsz,1:imsz);
    cy=YI+cy;
    cx=XI+cx;
    mask=(cx<1) | (cx>imsz) | (cy<1) | (cy>imsz) ;
    cx(mask)=1;
    cy(mask)=1;

end