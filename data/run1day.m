function [] = run1day()
clc; close all; clear
% A=importNRLneutronFile('Neutron_Alaska_9_18_15_1s.csv');
% B=importWeatherAlaska('Weather_9_18_15_Dalton.dat');  save Alaska_9_18_2015.mat A B
load Alaska_9_all_2015.mat
 
 
% OVERLAY BOTH HAWAII FLUX MAPS
% fig; A=importNRLneutronFile('Neutron_7_24_15_1s.csv');
% X = cell2mat(A(:,11)); Y = fcnsmooth(cell2mat(A(:,12)),20);  plot(X,Y,'.','Display','7/24'); 
% A=importNRLneutronFile('Neutron_7_25_15_1s.csv');
% X = cell2mat(A(:,11)); Y = fcnsmooth(cell2mat(A(:,12)),20);  plot(X,Y,'.','Display','7/25'); 
% xyzlabel('altitude (m)','neutrons/s','','20s smoothing'); fcnfontsize(16); fcnmarkersize(3); fcntight('y0 x0'); legend show


% %COMBINE ALASKA DAYS INTO 1
% clc; close all; clear
% for i=13:17
%     f=['Alaska_9_' num2str(i) '_2015.mat']; load(f); As{i,1}=A; Bs{i,1}=B;
% end
% A=cat(1,As{:,1});  B=cat(1,Bs{:,1});  save Alaska_9_all_2015.mat A B

cols = size(B,2);
for i=1:size(B,1)
    B{i,cols+1} = datenum(B{i,1}, 'yyyy-mm-dd HH:MM:SS');
end
B(cellfun(@(x) ischar(x) && strcmp(x,'NAN'), B)) = {nan}; % Replace non-numeric cells

%c = [5 6 13 22 24];  weatherLabels = {'AirTC','RH','Alt','SlrkW','PTemp_C'};  %HAWAII FORMAT
%c = [6 7 19 5 4 25 26:31];  weatherLabels = {'AirTC','RH','Alt','SlrkW','PTemp_C','BP_kPa','VWC','EC','T','P','PA','VR'};  %ALASKA FORMAT (adds pressure and solar)
c = [6 7 19 5 4 25 26];  weatherLabels = {'AirTC','RH','Alt','SlrkW','PTemp_C','BP_kPa','SoilMoisture'};  %ALASKA FORMAT (adds pressure and solar)
B(cellfun(@(x) x==0, B(:,26)),26)={nan};

n=numel(c);  F=cell(n,1);  T = [B{:,end}]';
for i=1:n
    F{i} = griddedInterpolant(T, cell2mat(B(:,c(i))) ,'linear','none');
end

for i=1:size(A,1)
    dateString = [A{i,2} ' ' A{i,3}];
    t = datenum(dateString, 'mm:dd:yyyy HH:MM:SS') + 3/24;  %3 hours time diff!!
    A{i,13} = t;
    A{i,14} = dateString;
    for j=1:n
        G=F{j};  A{i,14+j}=G(t);
    end
end
Xi = cell2mat(A(:,[13 12 15:end]));  %adds 2-date, 3-time, 9-lat, 10-lon
Xi(:,1)=(Xi(:,1)-min(Xi(:,1)))*24;  
Xi(:,2:end)=fcnsmooth(Xi(:,2:end),300);

%PLOT CORRELATIONS
i = [1 2 3 4 5 6 8 9];
str = {'Time', 'Flux', weatherLabels{:},'Latitude','Longitude','Date'};  [~,R]=plotmatrix2(Xi(:,i),str(i));

%C=num2cell(Xi); C(:,end+1:end+3) = A(:,[9 10 14]);
%writetable(cell2table(C,'VariableNames',str),'tabledata.txt'); %writes to csv




%PLOT ELLIPSE
i=[2 5 9];  Y=Xi(:,i); Y(:,1)=Y(:,1)-xhat;
C=nancov(Y);  mu=nanmean(Y);  
fig;  fcnplot3(Y,'.');  fcnerrorellipse(C,mu,.9,true);  xyzlabel(str{i(1)},str{i(2)},str{i(3)}); fcnfontsize(14); fcnview('best')

%i=[2 5];  Y=Xi(:,i);  C=nancov(Y);  mu=nanmean(Y);  
%xhat=fcnCovarianceModel(C^-1,Y,mu); %estimated flux based on i(2)


h=fig; plot([A{:,13}],ones(size([A{:,13}])),'.','Display','Neutrons');  plot(T,1.1*ones(size(T)),'.','Display','Weather'); fcnmarkersize(5); h.YLim=[.9 1.2]; datetick