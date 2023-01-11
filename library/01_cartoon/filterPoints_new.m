function [xf, yf] = filterPoints_new(x, y, wc, fps, type)

if ~strcmp(type,'grid')
    T = length(x);
    [lipThickLow, lipThickUp, lipThickLow2, lipThickUp2] = deal(zeros(3,T));
    for t=1:1:T
        lipThickLow2(1,t) = pdist([[x(20), y(20)];[x(11), y(11)]]);
        lipThickLow2(2,t) = pdist([[x(19), y(19)];[x(10), y(10)]]);
        lipThickLow2(3,t) = pdist([[x(18), y(18)];[x(9), y(9)]]);
        lipThickUp2(1,t) = pdist([[x(16), y(16)];[x(5), y(5)]]);
        lipThickUp2(2,t) = pdist([[x(15), y(15)];[x(4), y(4)]]);
        lipThickUp2(3,t) = pdist([[x(14), y(14)];[x(3), y(3)]]);

        lipThickLow(:,t) = lipThickLow2(:,t);
        lipThickUp(:,t) = lipThickUp2(:,t);

        if strcmp(type,'female')
            Threshold = [11.04 11.08 11.14 8.15 6.87 8.34]; %FEMALE
        elseif strcmp(type,'male')
            Threshold = [8.43 8.47 8.78 5.42 4.56 4.63]; %MALE
        end

        if abs(pdist([[x(20), y(20)];[x(11), y(11)]])) > Threshold(1)
            y(20) = y(11) - Threshold(1);
            lipThickLow(1,t) = pdist([[x(20), y(20)];[x(11), y(11)]]);
        end
        if abs(pdist([[x(19), y(19)];[x(10), y(10)]])) > Threshold(2)
            y(19) = y(10) - Threshold(2);
            lipThickLow(2,t) = pdist([[x(19), y(19)];[x(10), y(10)]]);
        end
        if abs(pdist([[x(18), y(18)];[x(9), y(9)]])) > Threshold(3)
            y(18) = y(9) - Threshold(3);
            lipThickLow(3,t) = pdist([[x(18), y(18)];[x(9), y(9)]]);
        end
        if abs(pdist([[x(16), y(16)];[x(5), y(5)]])) > Threshold(4)
            y(16) = y(5) + Threshold(4);
            lipThickUp(1,t) = pdist([[x(16), y(16)];[x(5), y(5)]]);
        end
        if abs(pdist([[x(15), y(15)];[x(4), y(4)]])) > Threshold(5)
            y(15) = y(4) + Threshold(5);
            lipThickUp(2,t) = pdist([[x(15), y(15)];[x(4), y(4)]]);
        end
        if abs(pdist([[x(14), y(14)];[x(3), y(3)]])) > Threshold(6)
            y(14) = y(3) + Threshold(6);
            lipThickUp(3,t) = pdist([[x(14), y(14)];[x(3), y(3)]]);
        end
    end
end

if strcmp(type,'grid') && wc==12
    wc=11;
elseif ~strcmp(type,'grid') && wc==12
%     wc=wc;
else
    wtf
end
forder=4;
Cf=(sqrt(2)-1)^(1/(2*forder));
Wn=wc*2/fps/Cf;
[a,b]=butter(forder,Wn,'low');
% filter1 = designfilt('lowpassiir', 'FilterOrder',forder, 'HalfPowerFrequency',wc, 'SampleRate',fps, 'DesignMethod','butter');

xf = filtfilt(a,b,x);
yf = filtfilt(a,b,y);

end