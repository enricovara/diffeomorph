function make_diffeomorphed(filename, out_filepath, max_distort, nsteps, ncomp, videosize, rng_val, TR)


% Create source/destination filepaths -------------------------------------

input_s = convertStringsToChars(fullfile(out_filepath,strrep(filename,".csv",".mp4")));
if ~TR
    input_s = convertStringsToChars(strrep(input_s,'03_diffeomorphed','01_cartoon'));
else
    input_s = convertStringsToChars(strrep(input_s,'04_diffeotransrotation','02_transrotation'));
end

str_ = strcat('_d', num2str(max_distort), '_ns', num2str(nsteps), '_nc', num2str(ncomp));
output_s = convertStringsToChars(fullfile(out_filepath,strrep(filename,".csv",strcat(str_,".mp4"))));

if ~exist(out_filepath,'dir')
    mkdir(out_filepath);
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
im_sz=max(videosize)+4*max_distort;    
[yD, xD] = my_getdiffeo(im_sz, max_distort, ncomp, nsteps, rng_val);




% Open output video -------------------------------------------------------
if exist(output_s,'file')
    delete(output_s);
end
vid = VideoWriter(output_s,'MPEG-4');
vid.Quality = 100;

open(vid);


% Morph and write frames --------------------------------------------------    

for f = 1:video.NumFrames

    % read next frame of input, size: video.Height, video.Width, 3
    frame = readFrame(video);

    % morph frame
    morphed = diffeomorph_1frame(frame, yD, xD, nsteps, im_sz);

    % write morphed frame
    writeVideo(vid, morphed);

end

% Close input video -------------------------------------------------------
close(vid);

end