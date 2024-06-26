%==========================================================================
% Generate cartoons from facial landmarks and warp them.

% Author: Enrico Varano

% MAKE_cartoon - make cartoons based  on facial landmarks
% MAKE_transrotation - make the translated+rotated cartoon
% MAKE_diffeomorphed - make the diffeomorphed cartoon
% MAKE_transdiffeo - make the translated+rotated+diffeomorphed cartoon

% Instructions:
%   1) review the "settings" cell
%   2) run this file
%   3) select "change folder" rather than "add to path", the rest of the
%      path management is automatic
%   4) review results in "samples" subfolder and the "settings" cell

%==========================================================================

%% uncomment the following (and line 78 or so) to parallelise computation
% delete(gcp('nocreate'))
% parpool(12)

%% settings

% videosize = [270 360];
videosize = [480 720]; % best not to change for now

MAKE_cartoon = 0; % make cartoons or to skip the step
    normalised = 1; % normalise the landmarks to the canonical face
    filter_lp = 0; % LP filter landmark movement (is w cutoff if non-zero)

MAKE_transrotation = 1; % make the translated+rotated cartoon

MAKE_diffeomorphed = 1; % make the diffeomorphed cartoon
    max_distort = 10:30:100; % max pxl shift after nsteps flowfield appli.s
    nsteps = 1:3:10; % number of flowfield application steps to max_distort
    ncomp = 1:3:10; % number of DCT components along each axis
    rng_val = 5; % set to non-0 to obtain consistent results across runs
MAKE_transdiffeo = 1; % make the translated+rotated+diffeo

% GENERAL REMARKS
    % increasing nsteps decreases sharpeness and increases stability 


in_dirs = ["samples"];
% in_dirs = input("Provide input folder names as a list (e.g. ['samples','speaker_2']):" );

%% set expectations for checks
fps = 25;
type = 'grid';
num_frames = 75;

%% setup

 %home
if exist('cd0', 'var')
    cd(cd0)
else
    cd0 = cd;
end
addpath(genpath('library'));
addpath(genpath(cd0));

%% iterate over all selected speakers
for in_d = 1:length(in_dirs)

    % define input/output directories
    cdi = fullfile(in_dirs(in_d), 'csv_XL');
    cdo_cartoon = fullfile(in_dirs(in_d), '01_cartoon');
    cdo_transrotation = fullfile(in_dirs(in_d), '02_transrotation');
    cdo_diffeomorphed = fullfile(in_dirs(in_d), '03_diffeomorphed');
    cdo_transdiffeo = fullfile(in_dirs(in_d), '04_diffeotransrotation');

    %extract file paths of CSV files to be processed
    cd(cdi); contents = dir('*.csv');
    CSVs_full = strings(length(contents),1); CSVs = strings(length(contents),1);
    for i = 1:length(contents)
        CSVs_full(i) = fullfile(contents(i).folder,contents(i).name);
        CSVs(i) = contents(i).name;
    end
    clear contents i; cd(cd0)


    %% for each file export video        
    for file = 1:length(CSVs)
%     parfor file = 1:length(CSVs)
        
        %% MAKE_cartoon and/or MAKE_transrotation
        if MAKE_cartoon || MAKE_transrotation
            type = 'grid';
            % Extract landmark coordinates
            data = readcell(CSVs_full(file));
            [~, ~, x, y, ~, ~] = extractPoints_new(data, normalised); 
            if filter_lp % Constrain lip thickness and de-jitter
                %[xf_mouth, yf_mouth] = filterPoints_new(x_mouth, y_mouth, wc, fps, type);
                [xf, yf] = filterPoints_new(x, y, filter_lp, fps, type);
                %[xf_eye, yf_eye] = filterPoints_new(x_eye, y_eye, wc, fps, type);
            else
                %xf_mouth = x_mouth; yf_mouth = y_mouth;
                xf = x; yf = y;
                %xf_eye = x_eye; yf_eye = y_eye;
            end
            if MAKE_cartoon
                make_cartoon(CSVs(file), cdo_cartoon, xf, yf, fps, videosize);
                cla
            end
            if MAKE_transrotation
                make_transrotation(CSVs(file), cdo_transrotation, xf, yf, fps, videosize, rng_val);
                cla
            end

        end

        %% MAKE_diffeomorphed and/or MAKE_transdiffeo
        for max_distort_ = max_distort % max pxl shift after nsteps flowfield appli.s
            for nsteps_ = nsteps % number of flowfield application steps to max_distort
                for ncomp_ = ncomp % number of DCT components along each axis
        
                    if MAKE_diffeomorphed
                        TR = 0;
                        make_diffeomorphed(CSVs(file), cdo_diffeomorphed, max_distort_, nsteps_, ncomp_, videosize, rng_val, TR);
                        cla
                    end
            
                    if MAKE_transdiffeo
                        TR = 1;
                        make_diffeomorphed(CSVs(file), cdo_transdiffeo, max_distort_, nsteps_, ncomp_, videosize, rng_val, TR);
                        cla
                    end

                end
            end
        end

    end
    disp("Done speaker " + speakers(speaker))
end