function add_lips_new(input_s, CSV_s, OPT_add_lips, x, y)


for lip = OPT_add_lips.lip_types
    ALL_out_str = strrep(input_s,"nolips",lip);
    if ~exist(fileparts(ALL_out_str),'dir')
        mkdir(fileparts(ALL_out_str));
    end
    if exist(ALL_out_str,'file')
        delete(ALL_out_str);
    end

    ALL_out_vid = VideoWriter(ALL_out_str,'MPEG-4');
    ALL_out_vid.Quality = 100;
    open(ALL_out_vid);

    switch lip %["edge","cartoon", "ellipse_v", "ellipse_e", "disk_e"];

        case "edge"
            lip_inp_str = convertStringsToChars(strrep(CSV_s,".csv",".mp4"));
            lip_inp_str = convertStringsToChars(strrep(lip_inp_str,"csv_XL","bw"));

        case "cartoon"
            lip_inp_str = convertStringsToChars(strrep(CSV_s,".csv",".mp4"));
            lip_inp_str = convertStringsToChars(strrep(lip_inp_str,"csv_XL",fullfile("01_cartoon","cartoon")));

        case "ellipse_v"
            lip_inp_str = convertStringsToChars(strrep(CSV_s,".csv",".mp4"));
            lip_inp_str = convertStringsToChars(strrep(lip_inp_str,"csv_XL",fullfile("01_cartoon","ellipse_v")));
    end

    lip_inp_vid = VideoReader(lip_inp_str);
    FNF_inp_vid = VideoReader(input_s);

    for f = 1:lip_inp_vid.NumFrames

        switch lip %["edge","cartoon", "ellipse_v", "ellipse_e", "disk_e"];
    
            case "edge"
                lip_frame = readFrame(lip_inp_vid);
                lips = lip_frame(220:290, 60:210,:);
                lips = imresize(lips, 0.75);    
            case "cartoon"
                lip_frame = readFrame(lip_inp_vid);
                lips = lip_frame(184+12:236+12, 79:191,:);    
            case "ellipse_v"
                lip_frame = readFrame(lip_inp_vid);
                lips = lip_frame(184+12:236+12, 79:191,:);
        end

        if mod(size(lips, 1),2) == 1
            lips = lips(2:end,:,:);
        end
        if mod(size(lips, 2),2) == 1
            lips = lips(:,2:end,:);
        end

        FNF_frame = readFrame(FNF_inp_vid);
        xx = 540/2/2-6; xl = size(lips,2);
        yy = 404/2; yl = size(lips,1);
        FNF_frame(yy:yy+yl-1, xx-xl/2:xx+xl/2-1,:) = lips;

        writeVideo(ALL_out_vid, FNF_frame);
    end
    close(ALL_out_vid);

end
end
%{
    end

    elif
    lips_type = 'cartoon';
    lips_type = 'ellipse_v';
    lips_type = 'ellipse_e';
    lips_type = 'disk_e';    e
end

input_s = convertStringsToChars(fullfile(out_filepath,strrep(csv_filename,".csv",".mp4")));
if ~TR
    input_s = convertStringsToChars(strrep(input_s,'03_diffeomorphed','01_cartoon'));
else
    input_s = convertStringsToChars(strrep(input_s,'04_diffeotransrotation','02_transrotation'));
end

str_ = strcat('_d', num2str(max_distort), '_ns', num2str(nsteps), '_nc', num2str(ncomp));
output_s = convertStringsToChars(fullfile(out_filepath,strrep(csv_filename,".csv",strcat(str_,".mp4"))));

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

%}
