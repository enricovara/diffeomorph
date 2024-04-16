clear all
%==========================================================================
% Generate cartoons from facial landmarks and warp them.

% Author: Enrico Varano

% MAKE_cartoon - make cartoons based on facial landmarks
% MAKE_transrotation - make the translated+rotated cartoon
% MAKE_diffeomorphed - make the diffeomorphed cartoon
% MAKE_transdiffeo - make the translated+rotated+diffeomorphed cartoon

% Instructions:
%   1) review the "settings" cell
%   2) run this file
%   3) select "change folder" (not "add to path"), the rest of the
%      path management is automatic
%   4) review results in "samples" subfolder and the "settings" cell

%==========================================================================

%% uncomment the following (and line 78 or so) to parallelise computation
% delete(gcp('nocreate'))
% parpool(12)

%% settings

% videosize = [270 360];
% videosize = [480 720];
% OPT_general.videosize = [540 720]; % best not to change for now
OPT_general.videosize = [270 360]; % best not to change for now
OPT_general.fps = 25;
OPT_general.type = "grid";
OPT_general.num_frames = 75;
OPT_general.quality = 100;
OPT_general.rng_val = 0; % set to non-0 to obtain consistent results across runs


OPT_cartoon.do = 1; % make cartoons or to skip the step
OPT_cartoon.do_lips = 1; % make cartoons or to skip the step
OPT_cartoon.normalised = 1; % normalise the landmarks to the canonical face
OPT_cartoon.filter_lp = 0; % LP filter landmark movement (is w cutoff if non-zero)

OPT_transrotation.do = 1; % make the translated+rotated cartoon

OPT_diffeomorphed.do_df = 0; % make diffeomorphed
OPT_diffeomorphed.do_trdf = 1; % make transrtdiffeo
OPT_diffeomorphed.max_distort_arr = [30]; % max pxl shift after nsteps flowfield appli.s
OPT_diffeomorphed.nsteps_arr = [4]; % number of flowfield application steps to max_distort
OPT_diffeomorphed.ncomp_arr = [4]; % number of DCT components along each axis
param_fields = {'max_distort_arr', 'nsteps_arr', 'ncomp_arr'};
lengths = cellfun(@(f) length(OPT_diffeomorphed.(f)), param_fields);
if max(lengths) > 1
    OPT_diffeomorphed.params_in_name = 1;
else
    OPT_diffeomorphed.params_in_name = 0;
end

OPT_add_lips.do = 1;
OPT_add_lips.lip_types = ["edge", "cartoon", "ellipse_v"];%, "ellipse_e", "disk_e"];

% GENERAL REMARKS
    % increasing nsteps decreases sharpeness and increases stability 


in_dirs = ["24"];
% in_dirs = input("Provide input folder names as a list (e.g. ['samples','speaker_2']):" );

%% setup

 %home
if exist("cd0", "var")
    cd(cd0)
else
    cd0 = cd;
end
addpath(genpath("library"));
addpath(genpath(cd0));

%% iterate over all selected speakers
for in_dir = in_dirs

    % define input/output directories
    cdi_csv = fullfile(in_dir, 'csv_XL');
    OPT_cartoon.out_dir = fullfile(in_dir, '01_cartoon');
    OPT_transrotation.out_dir = fullfile(in_dir, '02_transrotation');
    OPT_diffeomorphed.out_dir_df = fullfile(in_dir, '03_diffeomorphed');
    OPT_diffeomorphed.out_dir_trdf = fullfile(in_dir, '04_transrtdiffeo');

    %extract file paths of CSV files to be processed
    cd(cdi_csv); contents = dir('*.csv');
    CSVs.full = strings(length(contents),1);
    CSVs.name = strings(length(contents),1);
    for i = 1:length(contents)
        CSVs.full(i) = fullfile(contents(i).folder,contents(i).name);
        CSVs.name(i) = contents(i).name;
    end
    clear contents i
    cd(cd0)


    %% for each file export video     
    rand_order_i = randperm(length(CSVs.name));
    for i = rand_order_i %1:length(CSVs.name)
%     parfor file = 1:length(CSVs.name)
        
        %% load landmarks coordinates
        if OPT_cartoon.do || OPT_cartoon.do_lips || OPT_transrotation.do || OPT_add_lips.do
            data = readcell(CSVs.full(i));
            [~, ~, x, y, ~, ~] = extractPoints_new(data, OPT_cartoon.normalised); 
            if OPT_cartoon.filter_lp % Constrain lip thickness and de-jitter
                [x, y] = filterPoints_new(x, y, filter_lp, OPT_general.fps, OPT_general.type);
            end
        end

        %% MAKE_cartoon and/or MAKE_transrotation

        if OPT_cartoon.do
            OPT_cartoon = make_cartoon(CSVs.name(i), OPT_cartoon, x, y, OPT_general);
            cla
            if OPT_cartoon.do_lips
                make_lips_cartoon(CSVs.name(i), OPT_cartoon, x, y, OPT_general);
                cla
                make_lips_ellipse_v(CSVs.name(i), OPT_cartoon, x, y, OPT_general);
                cla
            end
            if OPT_add_lips.do
                temp = OPT_add_lips.lip_types;
                OPT_add_lips.lip_types = ["edge"];
                add_lips_new(OPT_cartoon.output_s, CSVs.full(i), OPT_add_lips, x, y)
                cla
                OPT_add_lips.lip_types = temp;
            end
            
        end
        if OPT_transrotation.do
            OPT_transrotation = make_transrotation(CSVs.name(i), OPT_transrotation, x, y, OPT_general);
            cla
%             if OPT_add_lips.do
%                 add_lips_new(OPT_transrotation.output_s, CSVs.full(i), OPT_add_lips, x, y)
%             end
        end


        %% MAKE_diffeomorphed and/or MAKE_transdiffeo

        for max_distort = OPT_diffeomorphed.max_distort_arr % max pxl shift after nsteps flowfield appli.s
            for nsteps = OPT_diffeomorphed.nsteps_arr % number of flowfield application steps to max_distort
                for ncomp = OPT_diffeomorphed.ncomp_arr % number of DCT components along each axis
                    OPT_diffeomorphed.max_distort = max_distort;
                    OPT_diffeomorphed.nsteps = nsteps; OPT_diffeomorphed.ncomp = ncomp;
        
                    if OPT_diffeomorphed.do_df
                        OPT_diffeomorphed.trans_rot = 0;
                        OPT_diffeomorphed = make_diffeomorphed(CSVs.name(i), OPT_diffeomorphed, OPT_general);
                        cla
                        if OPT_add_lips.do
                            add_lips_new(OPT_diffeomorphed.output_s_df, CSVs.full(i), OPT_add_lips, x, y)
                        end
                    end
                    
                    if OPT_diffeomorphed.do_trdf
                        OPT_diffeomorphed.trans_rot = 1;
                        OPT_diffeomorphed = make_diffeomorphed(CSVs.name(i), OPT_diffeomorphed, OPT_general);
                        cla
                        if OPT_add_lips.do
                            add_lips_new(OPT_diffeomorphed.output_s_trdf, CSVs.full(i), OPT_add_lips, x, y)
                        end
                    end

                end
            end
        end

    end
    disp("Done with input dir " + in_dir)
end