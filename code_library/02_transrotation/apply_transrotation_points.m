function [x,y] = apply_transrotation_points(x,y,theta_dx_dy)

theta = theta_dx_dy(1)*pi/180;
dx = theta_dx_dy(2);
dy = theta_dx_dy(3);

x_o = x; y_o = y;
x_bar = mean(x_o);
y_bar = mean(y_o);

x = x_o-x_bar; y = y_o-y_bar;

% Create a meshgrid of the image coordinates
% [x, y] = meshgrid(1:ncols, 1:nrows);

[nrows, ncols] = size(x);

% Create transformation matrix
T = [cos(theta) -sin(theta) dx; sin(theta) cos(theta) dy; 0 0 1];
% Reshape the coordinates into column vectors
x_vec = reshape(x, [], 1);
y_vec = reshape(y, [], 1);
% Create a matrix of coordinates with an additional row of ones
coords = [x_vec y_vec ones(numel(x_vec), 1)]';
% Transform the coordinates
trans_coords = T*coords;
% Extract the transformed x and y coordinates
x_trans = trans_coords(1,:);
y_trans = trans_coords(2,:);


x = reshape(x_trans, nrows, ncols);
y = reshape(y_trans, nrows, ncols);


% Interpolate the image values at the transformed coordinates
% I_trans = interp2(x, y, I, x_trans, y_trans);
% Reshape the transformed image back into the original size
% I_trans = reshape(I_trans, nrows, ncols);

x = x+x_bar; y = y+y_bar;

