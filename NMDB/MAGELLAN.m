% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [] = MAGELLAN()
% load JUNG.mat  %loadJUNG()
% clc
% %elevation = fcnGoogleElevation(a)
%X(:,1)=now2unix(X(:,1));
covarianceModel(); return

lat = 46.5475;
lng = 7.9851;
alt = 3565; %(m) above geoid
t = now2unix(datenum('11-Sep-2014'));
[S,url] = forecastAPI(lat,lng,t);

load X.mat; clc; close all
stationTime=X(:,1); %(unix seconds)
F=forecastHourlyFields;
vt = min3(stationTime(30306)) : 86400 : max3(stationTime);
for t=vt; %vt(1:365)
    S = forecastAPI(lat,lng,t);
    disp(datestr(unix2now(S.currently.time)))
    try
        for i=1:numel(S.hourly.data)
            if iscell(S.hourly.data)
                a=S.hourly.data{i};
            else %isstruct
                a=S.hourly.data(i);
            end
            r = abs(a.time-stationTime);
            [mv,j] = min(r);

            if mv<1799; %<29:59min
                X(j,5+(1:12))=grabForecastData(a,F);
            end
        end
    catch
        ''
    end
end
%G(:,1)=num2cell((1:17)'); G(:,2) = cat(1,{'date';'pressure';'uncorr flux';'RH';'T'},F);
%save X.mat X G

%PROCESS THE DATA ---------------------------------------------------------
%llag2lla([lat lng alt])
X = X(1:9000,:);
X(:,3) = despike(X(:,3),6,99); %T (C)
X(:,9) = despike(X(:,9),6,13); %temperature (C)
X(:,15) = despike(X(:,15),6,13); %pSea (m
pSea = X(:,15); %(mbar)
elevation = 3565; %(m) above ellipsoid
X(:,15) = sea2stationPressure(pSea,elevation,X(:,9));

%i=[2:5 9 11 12 13 14 15 16];
%[~,R]=plotmatrix2(X(:,i),G(i,2));

i=[3 15 9]; Xi=X(:,i); str=G(i,2);
[~,R]=plotmatrix2(Xi,str);

C = nancov(Xi); iC=C^-1;  mu=nanmean(Xi);  
fig; fcnplot3(Xi,'.');  fcnerrorellipse(C,mu,.9,true);  xyzlabel(str{1},str{2},str{3}); fcnfontsize(14); fcnview('best')


%xv = repmat(mu,10000,1); xv(:,1)=linspace(140,210,10000);  xv(:,2)=mu(2)-10; xv(:,3)=mu(3)+16.052; xv(:,4)=mu(4)+.3;
%y = mvnpdf(xv,mu,C); fig; plot(xv(:,1),y)

%QUICKSILVER --------------------------------------------------------------
[T,pSea,pStation,altitude,rigidity,water] = fcnQuicksilver();
zm = zeros(size(T));
cloudCover = zm + .6;

xinputs = [zm(:), pSea(:), T(:)]; %, cloudCover(:)];
flux  = fcnsymsolution(iC,xinputs,mu);  flux=reshape(flux,size(pStation));

flux(water)=flux(water)*.8;
h=fig(1,1,2,4);  imshow(flux); h.CLim=[100 230]; colorbar; colormap(parula); title('Neutron Flux')
%fcncylindrical2geotiff(flipud(flux),'nmap',h.CLim)

% lata = 46.5475;  lnga = 7.9851;
% 
% F = griddedInterpolant(lng,-lat,altitude'); F(lnga,-lata)
% F = griddedInterpolant(lng,-lat,pStation'); F(lnga,-lata)
% F = griddedInterpolant(lng,-lat,T'); F(lnga,-lata)
% F = griddedInterpolant(lng,-lat,flux'); F(lnga,-lata)
end


function []=covarianceModel()
clear; load X.mat; clc; close all;
X(:,3) = despike(X(:,3),6,99,nan); %T (C)
X(:,9) = despike(X(:,9),6,13); %temperature (C)
X(:,15) = despike(X(:,15),6,13); %pSea (m
pSea = X(:,15); %(mbar)
elevation = 3565; %(m) above ellipsoid
%X(:,15) = sea2stationPressure(pSea,elevation,X(:,9));
t = unix2now(X(:,1)); dayOfYear = datenum(t) - datenum(year(t),0,0);
X(:,18) = (t-min(t))/365; %year
X(:,19) = dayOfYear;  G(18:19,2)={'year','day'};
i = 1:40000;
U = X(i,:);  t=t(i);

%TRAIN MODEL
i=[3 9:16]; str=G(i,2);  U=U(:,i);  x = U(:,1);  U0=U;  U0(isnan(U0))=0;  C=nancov(U);  mu=nanmean(U);
xhat = fcnCovarianceModel(C^-1,U0,mu);
residual = x - xhat;

%PLOT RESULTS
ha=fig(2,1,'19cm');  xyzlabel(ha,'Date','flux (neutrons/s)');
sca(1); plot(t,x,'Display','measurement'); plot(t,xhat,'Display','model A'); datetick('x','QQ-YYYY');
sca(2); plot(t,residual,'Display',sprintf('Residual %.1f MSE',mse(residual))); datetick('x','QQ-YYYY');

%NEURAL NETWORK
X=X([1:9000 31000:40000],:); inputs=X(:,i(2:end));  targets=X(:,i(1));
net=NNtrain(inputs,targets);
xhat = net(U0(:,2:end)')';

% X = tonndata(inputs,false,false);
% T = tonndata(targets,false,false);
% [x,xi,ai,t] = preparets(netNARX,X,{},T);
% y = netNARX(x(:,1:7),xi)


residual = x - xhat;
sca(1); plot(t,xhat,'Display','model B'); legend show
sca(2); plot(t,residual,'Display',sprintf('Residual NN %.1f MSE',mse(residual))); legend show
fcntight;
end




function loadJUNG()
if nargin==0
    [fname, pname] = uigetfile([pwd '/*.*'],'Select text file:','MultiSelect','on');
    if isequal(fname,0) || isequal(pname,0); fprintf('No file selected ... Done.\n'); A = []; return; end
    addpath(pname)
    
    hl = [22 22 26 26];
    fs = '%{yyyy-MM-dd HH:mm:ss}D%f';
    
    A = cell(1,4);
    for i=1
        fid=fopen(fname);
        A{i}=textscan(fid,fs,'HeaderLines',hl(i),'Delimiter',';');
        fclose(fid);
    end
    a=A{1}; b=A{2}; c=A{3}; d=A{4};
    weather = [datenum(a{1}) a{2} b{2}]; %[date RH T]
    data = [datenum(c{1}) c{2} d{2}]; %[date pressure uncorrectedflux]
    
    F = griddedInterpolant(weather(:,1),weather(:,2));  data(:,4)=F(data(:,1));
    F = griddedInterpolant(weather(:,1),weather(:,3));  data(:,5)=F(data(:,1)); X=data;  save JUNG.mat X
end
end








