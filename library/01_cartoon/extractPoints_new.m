function [x_mouth, y_mouth, x, y, x_eye, y_eye] = extractPoints_new(data, normalised)


% Find face points in csv file
dim = size(data);
for p = 1:dim(1,2)
    if convertCharsToStrings(cell2mat(data(1,p))) == "eye_lmk_x_0"
        eye_loc_x_0 = p;
    elseif convertCharsToStrings(cell2mat(data(1,p))) == "eye_lmk_x_55"
        eye_loc_x_55 = p;
    elseif convertCharsToStrings(cell2mat(data(1,p))) == "eye_lmk_y_0"
        eye_loc_y_0 = p;
    elseif convertCharsToStrings(cell2mat(data(1,p))) == "eye_lmk_y_55"
        eye_loc_y_55 = p;
    elseif convertCharsToStrings(cell2mat(data(1,p))) == "x_0"
        x_0 = p;
    elseif convertCharsToStrings(cell2mat(data(1,p))) == "x_67"
        x_67 = p;
    elseif convertCharsToStrings(cell2mat(data(1,p))) == "y_0"
        y_0 = p;
    elseif convertCharsToStrings(cell2mat(data(1,p))) == "y_67"
        y_67 = p;
    end
end

% Extract face points from csv file
if normalised == 0
    x = cell2mat(data(2:end,x_0:x_67));
    y = cell2mat(data(2:end,y_0:y_67));

elseif normalised == 1
    PDM = load('pdm_68_aligned_wild.mat');
    p = cell2mat(data(2:end, end-33:end));
    P = PDM.M + PDM.V * p';

    p_per_dim = size(P,1)/3;
    x = P(1:p_per_dim,:)';
    y = P(p_per_dim+1:end-p_per_dim,:)';
end


if exist('eye_loc_x_0','var') == 1
    x_eye = cell2mat(data(2:end,eye_loc_x_0:eye_loc_x_55));
    y_eye = cell2mat(data(2:end,eye_loc_y_0:eye_loc_y_55));
else
    x_eye = double.empty;
    y_eye = double.empty;
end

x_mouth = x(:, end-19:end);
y_mouth = y(:, end-19:end);
    
end