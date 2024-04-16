function outputVideo4n_V2(filepath, fps, cdo, videosize)


% Create source/destination filepaths -------------------------------------
tmp = convertStringsToChars(filepath);

input_s = convertStringsToChars(strrep(tmp,"csv_XL","4d"));
input_s = convertStringsToChars(strrep(input_s,".csv",".mp4"));

output_s = convertStringsToChars(strrep(input_s,"4d","4n2"));

if ~exist(cdo,'dir')
    mkdir(cdo);
end
clear tmp


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
im_sz=max(videosize)+4*maxdistortion;    
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
    morphed = diffeomorphic_1frame(frame, yD, xD, nsteps, im_sz);

    % write morphed frame
    writeVideo(vid, morphed);

end

% Close input video -------------------------------------------------------
close(vid);

end