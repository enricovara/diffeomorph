function OPT = make_lips_ellipse_v(filename, OPT, x, y, OPT_general)
% ------------------------------------------------------------------------- 

% Positions of head (left and right) are defined as the "individual in the video"'s left
% and right 

lines_or_points = 1; %1 for lines, 0 for points

% ------------------------------------------------------------------------- 

% Create destination filepath
output_s = convertStringsToChars(fullfile(OPT.out_dir,"ellipse_v",strrep(filename,".csv",".mp4")));
OPT.output_s = output_s;
if ~exist(fileparts(output_s),'dir')
    mkdir(fileparts(output_s));
end

%Open video
if exist(output_s,'file')
    delete(output_s);
end
vid = VideoWriter(output_s,'MPEG-4');
vid.Quality = OPT_general.quality;
vid.FrameRate = OPT_general.fps;
open(vid);

% ------------------------------------------------------------------------- 
% PRE COMPUTE VIDEO-DRIVEN LIP FEATURES

leftCorner = [x(:,49), y(:,49)];
rightCorner = [x(:,55), y(:,55)];
topCentre = [x(:,51), y(:,51)];
bottomCentre = [x(:,58), y(:,58)];
leftCornerIn = [x(:,61), y(:,61)];
rightCornerIn = [x(:,65), y(:,65)];
topCentreIn = [x(:,63), y(:,63)];
bottomCentreIn = [x(:,67), y(:,67)];

SMA = sqrt(sum(((rightCorner+rightCornerIn)/2-(leftCorner+leftCornerIn)/2).^2, 2))/2; % semi Major axis
SmA = sqrt(sum(((topCentreIn)-(bottomCentreIn)).^2, 2))/2; % semi minor axis
% SmA = sqrt(sum(((topCentreIn+topCentre)/2-(bottomCentreIn+bottomCentre)/2).^2, 2))/2; % semi minor axis
spherical_equiv = sqrt(SmA .* SMA);

y0=mean(y(:, 49:68), 'all');
x0=mean(x(:, 49:68), 'all');
k=-pi:0.01:pi+0.05;

% ------------------------------------------------------------------------- 

% n_frame = 10;
n_frame = length(x);
s = 0.64;
yo = 2;
xo = 12;
for f = 1:n_frame
    
    % -------------------------------------------------------------------------    
    
    % DEFINE FACE POINTS/PARAMETERS
    
    % Forehead points
    face_width = abs(x(f,17) - x(f,1));
    forehead_height = 62; % Reasonable height for normalised grid points
    x_forehead_centre = x(f,28);
    y_forehead_centre = y(f,1) - forehead_height;
    
    x_forehead_right_1 = x(f,1) + face_width/4;
    y_forehead_right_1 = y(f,1) - forehead_height*9.25/10;
    x_forehead_right_2 = x(f,1) + face_width/8;
    y_forehead_right_2 = y(f,1) - forehead_height*8/10;
    x_forehead_right_3 = x(f,1) + face_width/16;
    y_forehead_right_3 = y(f,1) - forehead_height*6/10;
    
    x_forehead_left_1 = x(f,1) + face_width*3/4;
    y_forehead_left_1 = y(f,1) - forehead_height*9.25/10;
    x_forehead_left_2 = x(f,1) + face_width*7/8;
    y_forehead_left_2 = y(f,1) - forehead_height*8/10;
    x_forehead_left_3 = x(f,1) + face_width*15/16;
    y_forehead_left_3 = y(f,1) - forehead_height*6/10;
    
    x_forehead = [x_forehead_right_3 x_forehead_right_2 x_forehead_right_1 x_forehead_centre x_forehead_left_1 x_forehead_left_2 x_forehead_left_3];
    y_forehead = [y_forehead_right_3 y_forehead_right_2 y_forehead_right_1 y_forehead_centre y_forehead_left_1 y_forehead_left_2 y_forehead_left_3];
   
    % Eye circles
    x_eye_center_right = x(f,37) + abs(x(f,40)-x(f,37)) / 2;
    y_eye_center_right = y(f,41) - abs(y(f,41)-y(f,39)) / 2;
    x_eye_center_left = x(f,43) + abs(x(f,46)-x(f,43)) / 2;
    y_eye_center_left = y(f,48) - abs(y(f,48)-y(f,44)) / 2;
    r_outer_eye = 5;
    r_inner_eye = 1;
    
    % Outer eye
    th = 0:pi/50:2*pi;
    x_unit_eyes_or = r_outer_eye * cos(th) + x_eye_center_right; % Right
    y_unit_eyes_or = r_outer_eye * sin(th) + y_eye_center_right;
    x_unit_eyes_ol = r_outer_eye * cos(th) + x_eye_center_left; % Left
    y_unit_eyes_ol = r_outer_eye * sin(th) + y_eye_center_left;
    
    % Inner eye
    x_unit_eyes_ir = r_inner_eye * cos(th) + x_eye_center_right; % Right
    y_unit_eyes_ir = r_inner_eye * sin(th) + y_eye_center_right;
    x_unit_eyes_il = r_inner_eye * cos(th) + x_eye_center_left; % Left
    y_unit_eyes_il = r_inner_eye * sin(th) + y_eye_center_left;     
    
    % Eye lid
    eye_lid_left = [x(f, 37 : 40); y(f, 37 : 40)-4]';
    eye_lid_right = [x(f, 43 : 46); y(f, 43 : 46)-4]';
%     eye_lid_right_bottom = [x(f, 46 : 48) x(f,43); y(f, 46 : 48) y(f,43)]';
%     eye_lid_left_bottom = [x(f, 40 : 42) x(f,37); y(f, 40 : 42) y(f,37)]';
    
    % Eye sides
    eye_side_left = [x(f,46) x(f,46)+3; y(f,46) y(f,46)]';
    eye_side_right = [x(f,37) x(f,37)-3; y(f,37) y(f,37)]';
    
    % Eye slots
    eye_slots_left = [x(f,28)-2+abs(x(f,43)-x(f,28))/2 x(f,23)-3 x(f,24:26); y(f,28)+3 y(f,23:25)+9.5 y(f,26)+12]';
    eye_slots_right = [x(f,19:21) x(f,22)+3 x(f,28)+2-abs(x(f,28)-x(f,40))/2; y(f,19)+12 y(f,20:22)+9.5 y(f,28)+3]';

    % Chin
%     x_chin = [x(f,8) x(f,9) x(f,10)];
%     y_chin = [y(f,8)-16 y(f,9)-20.5 y(f,10)-16];

    % Nose Mouth connection
%     x_no_mo_r = [x(f,33)+5 x(f,51)+3.5];
%     y_no_mo_r = [y(f,33)+4 y(f,51)-3];
%     x_no_mo_l = [x(f,35)-5 x(f,53)-3.5];
%     y_no_mo_l = [y(f,35)+4 y(f,53)-3];
    
    % ------------------------------------------------------------------------- 

    if ~exist('fig1', 'var')
        fig1 = figure('Visible', 'off'); %,'units','pixels','position',[0 0 428 339]);
        set(gcf,'Position',[100 100 OPT_general.videosize(1)*s OPT_general.videosize(2)*s]) %;set(gca,'Color','k')
    else
        set(0, 'CurrentFigure', fig1);
    end

    % ------------------------------------------------------------------------- 
         
    % PLOT ALL FACE POINTS
    
    if lines_or_points == 0
        plot(x(f, 1 : 68), y(f, 1 : 68), '.', 'color', 'w')
        hold on
        plot(x_forehead, y_forehead, '.', 'color', 'w')
        hold on
    end
    
    % -------------------------------------------------------------------------     

    % PLOT ALL FACE LINES

    if lines_or_points == 1
        plot(x(f, 1 : 17), y(f, 1 : 17), 'w')
        hold on

        plot(x(f, 18 : 22), y(f, 18 : 22), 'w')
        plot(x(f, 23 : 27), y(f, 23 : 27), 'w')

        plot(x(f, 28 : 31), y(f, 28 : 31), 'w')
        plot(x(f, 32 : 36), y(f, 32 : 36), 'w')

        plot([x(f, 37 : 42) x(f,37)], [y(f, 37 : 42) y(f,37)], 'w') % Eyes
        plot([x(f, 43 : 48) x(f,43)], [y(f, 43 : 48) y(f,43)], 'w')

        plot([x(f,1) x_forehead x(f,17)], [y(f,1) y_forehead y(f,17)], 'w')

        plot(eye_lid_left(:,1), eye_lid_left(:,2), 'w') % Eye lids
        plot(eye_lid_right(:,1), eye_lid_right(:,2), 'w')
        plot(eye_side_left(:,1), eye_side_left(:,2), 'w') % Eye side out
        plot(eye_side_right(:,1), eye_side_right(:,2), 'w')

        plot([x(f,40) x(f,40)+2], [y(f,40) y(f,40)], 'w') % Eyes sides in
        plot([x(f,43) x(f,43)-2], [y(f,43) y(f,43)], 'w')


%         if lipd.do
%         plot([x(f, 49 : 60) x(f,49)], [y(f, 49 : 60) y(f,49)], 'k')
%         plot([x(f, 61 : 68) x(f,61)], [y(f, 61 : 68) y(f,61)], 'k')
% %         x_b=x0+1000*cos(k);
% %         y_b=y0+1000*sin(k);
% %         fill(x_b,y_b,'k')
% %         hold on

        y_c=y0+(SmA(f)+2)*cos(k); % y and x correction flipped because ij
        x_c=x0+mean(SMA)*sin(k); % not sure why yo not necessary here

        plot(x_c,y_c,'k') %y and x flipped in arg position because of ij
%         fill(x_c,y_c,'k') %not hollow
%         end

    end


    % ------------------------------------------------------------------------- 
    
%     axis(5*6*[-36 36 -11 38]);
%     axis equal
    axis(3*[-36 36 -11 11])
    axis equal
    axis ij

    
    set(gca,'visible','off') % Remove axis

    cdata = print('-RGBImage');
    yr = ceil((size(cdata,1)-OPT_general.videosize(2))/2);
    xr = ceil((size(cdata,2)-OPT_general.videosize(1))/2);
    cda = cdata(yr-yo:end-yr-yo,xr+xo+1:end-xr+xo,:);
%     if size(cda)==[361 270 3] %#ok<BDSCA>
%         cda = cda(2:end,:,:);
%     elseif size(cda)==[360 270 3] %#ok<BDSCA>
%         %do nothing
%     else
%         cda = cda(1:360,1:270,:);
%         disp("Weird cda size.")
%         disp("BTW filename was: "+ wav_s)
%         disp("And size was: "+ size(cda))
%     end

%     if size(cda)==[720 540 3] %#ok<BDSCA>
% %         do nothing
%     elseif size(cda)==[721 540 3] %#ok<BDSCA>
%         cda = cda(2:end,:,:);
%     else
%         disp(size(cda))
%         disp("weird?")
% %         cda = cda(1:720,1:540,:);
% %         disp("Weird cda size.")
% %         disp("BTW filename was: "+ wav_s)
% %         disp("And size was: "+ size(cda))
%     end


    % make white on black (opposite)
    cda = -double(cda);
    cda = (cda+255)/255;
    writeVideo(vid, cda);
    hold off
end

close(vid);
hold off

end