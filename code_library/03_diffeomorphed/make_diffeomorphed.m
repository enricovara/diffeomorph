function OPT = make_diffeomorphed(filename, OPT, OPT_general)

% Create source/destination filepaths -------------------------------------

if OPT.params_in_name
    str_ = strcat('_d', num2str(max_distort), '_ns', num2str(nsteps), '_nc', num2str(ncomp));
else
    str_ = "";

if ~OPT.trans_rot
    input_s = convertStringsToChars(fullfile(OPT.out_dir_df,"nolips",strrep(filename,".csv",".mp4")));
    input_s = convertStringsToChars(strrep(input_s,'03_diffeomorphed','01_cartoon'));
    output_s = convertStringsToChars(fullfile(OPT.out_dir_df,"nolips",strrep(filename,".csv",strcat(str_,".mp4"))));
    OPT.output_s_df = output_s;
else
    input_s = convertStringsToChars(fullfile(OPT.out_dir_trdf,"nolips",strrep(filename,".csv",".mp4")));
    input_s = convertStringsToChars(strrep(input_s,'04_transrtdiffeo', '02_transrotation'));
    output_s = convertStringsToChars(fullfile(OPT.out_dir_trdf,"nolips",strrep(filename,".csv",strcat(str_,".mp4"))));
    OPT.output_s_trdf = output_s;
end

[dir_path, ~, ~] = fileparts(output_s); % Get directory
if ~exist(dir_path, 'dir')
   mkdir(dir_path); % Make directory if it does not exist
end


% Open input video --------------------------------------------------------

video = VideoReader(input_s);

% Extract video information
% assert(fps==video.FrameRate);
% assert(video.NumFrames==75);

% Create empty array to store video frames
% videoFrames = zeros(video.Height, video.Width, 3, video.NumFrames, 'uint8');

% Read in video frames [going to do this one frame at a time]
% for i = 1:videoFrameCount
%     videoFrames(:,:,:,i) = readFrame(video);
% end



% generate warping matrix
% im_sz = 1000;
im_sz=max(OPT_general.videosize)+4*OPT.max_distort;    
[yD, xD] = my_getdiffeo(im_sz, OPT.max_distort, OPT.ncomp, OPT.nsteps, OPT_general.rng_val);




% Open output video -------------------------------------------------------
if exist(output_s,'file')
    delete(output_s);
end
vid = VideoWriter(output_s,'MPEG-4');
vid.Quality = OPT_general.quality;

open(vid);


% Morph and write frames --------------------------------------------------    

for f = 1:video.NumFrames

    % read next frame of input, size: video.Height, video.Width, 3
    frame = readFrame(video);

    % morph frame
    morphed = diffeomorph_1frame(frame, yD, xD, OPT.nsteps, im_sz);

    % write morphed frame
    writeVideo(vid, morphed);

end

% Close input video -------------------------------------------------------
close(vid);

end