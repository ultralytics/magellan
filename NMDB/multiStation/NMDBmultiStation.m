function [] = NMDBmultiStation()
clc; clear; close all
load ProjectMagellanNMDBTable.mat;  T=table2cell(ProjectMagellanNMDBTable);

newDataFlag=0;
if newDataFlag
    [t, flux, names] = getData();
    attachWeather(t,flux,names,T)
end
load('NEST + Weather Data.mat');
i=~any(isnan(X(:,1:8)),2) & ~all(isnan(X(:,10:23)),2);  X=X(i,:); [m,n]=size(X);
%X(:,21) = sea2stationPressure(X(:,21),X(:,5),X(:,14));
X(:,5) = X(:,5)+randn(m,1)*25;
X(:,6) = X(:,6)+randn(m,1)*.1;


nc=2880; [temperature,pSea,pStation,altitude,rigidity,water]=fcnQuicksilver(nc);  Xmap = [altitude(:) rigidity(:) temperature(:) pSea(:)];  land=~water;
i=[5 6 14 21];  inputs=X(:,i);  targets=X(:,8)./X(:,7);
%nc=1440; [temperature,pSea,pStation,altitude,rigidity,water]=fcnQuicksilver(nc);  Xmap = [altitude(:)];  land=~water;
%i=[5];  inputs=X(:,i);  targets=X(:,8)./X(:,7);

%NN MODEL
[inputsFU,fus]=fixunknowns(inputs');  net=NNtrain(inputsFU',targets);  
xhat = net(fixunknowns('apply',inputs',fus))';  e=targets-xhat;  fig; fcnhist(e,100);
fhat=net(fixunknowns('apply',Xmap',fus))';
fig(1,1,2,4);  imshow(reshape(fhat',[nc/2 nc])); colorbar; colormap(parula);  title('Neural Network Neutron Flux (n/s)'); fcntight('c')


%COVARIANCE MODEL
str=L([8 i],2); Xi=[targets X(:,i)];  plotmatrix2(Xi,str);

C = nancov(Xi);  mu=nanmean(Xi);  
fig; fcnplot3(Xi,'.');  fcnerrorellipse(C(1:3,1:3),mu(1:3),.9,true);  xyzlabel(str{1},str{2},str{3}); fcnfontsize(14); fcnview('best')
xhat=fcnCovarianceModel(C^-1,Xi,mu); e=targets-xhat;  fig; fcnhist(e,100);

fhat=fcnCovarianceModel(C^-1,[zeros(size(Xmap,1),1) Xmap],mu);  fhat=reshape(fhat',[nc/2 nc]);  %fhat=fhat-min3(fhat);
fig(1,1,2,4);  imshow((land+water*1).*fhat); colorbar; colormap(parula);  title('Covariance Model Neutron Flux (n/s)'); fcntight('c')


end



function [decimalDay, flux, names] = getData()
fname='NESTdata.txt';
%url = 'http://previ.obspm.fr/hidden3/draw_graph.php?formchk=1&stations[]=ATHN&stations[]=MXCO&stations[]=NANM&stations[]=CALM&stations[]=AATB&stations[]=ROME&stations[]=BKSN&stations[]=JUNG&stations[]=JUNG1&stations[]=LMKS&stations[]=IRK3&stations[]=IRKT&stations[]=DRBS&stations[]=MCRL&stations[]=NEWK&stations[]=KIEL2&stations[]=YKTK&stations[]=KERG&stations[]=OULU&stations[]=APTY&stations[]=TXBY&stations[]=FSMT&stations[]=INVK&stations[]=MCMU&stations[]=PWNK&stations[]=THUL&stations[]=SOPB&stations[]=SOPO&stations[]=TERA&tabchoice=revori&dtype=uncorrected&tresolution=60&force=1&yunits=0&shift=2&date_choice=last&last_days=10&last_label=days_label&output=both&ygrid=1&mline=1&transp=0&text_color=222222&background_color=FFFFFF&margin_color=CCCCCC';
%web(url);  websave(fname,'http://previ.obspm.fr/hidden3/data/upload/15Nov15_190000_15Nov25_190000_uncorrected_revori.txt');

fid=fopen(fname,'r');  s=textscan(fid,'%s',1,'Delimiter','','HeaderLines',24); fclose(fid); s=s{1}; n=(numel(s{1})+4)/8; %n=29, number of stations!
fid=fopen(fname,'r');  A=textscan(fid,repmat('%s',1,n),1,'Delimiter',' ','EmptyValue',NaN,'HeaderLines',24,'TreatAsEmpty','null','MultipleDelimsAsOne', true);  fclose(fid);  for i=1:n; B=A{i}; A{i}=B{1}; end; names=A;
fid=fopen(fname,'r');  A=textscan(fid,['%s' repmat('%f',1,n)],inf,'Delimiter',';','EmptyValue',NaN,'HeaderLines',25,'TreatAsEmpty','null');  fclose(fid);  flux=[A{2:end}];  t=A{1};
m=numel(t);  decimalDay=zeros(m,1);  for i=1:m;  decimalDay(i)=datenum(t{i});  end

fig;  for i=1:n; plot(decimalDay,flux(:,i),'-','Display',names{i});  end; fcntight('y0'); datetick
end


function [] = attachWeather(t,flux,names,T)
[m,n]=size(flux);  Y=cell(n,1);  ov=ones(m,1);   tstart=clock;
for i=1:n
    site=find(strcmp(T(:,3),names{i})); fprintf('\n%s weather... ',names{i})
    [lat, lon, alt, rigidity, tubes] = deal(T{site,7:11});  if any(isnan([lat, lon, alt, rigidity]));  fprintf('WARNING! NaN information for NMDB site ''%s'', skipping...\n',T{site,3}); continue; end
    
    X=[t, site*ov, lat*ov, lon*ov, alt*ov, rigidity*ov, tubes*ov, flux(:,i)];  weather=nan(m,15);
    for j=[1:24:m m] %every 24HR
        try
            [~,~,A,F] = forecastAPI(lat,lon,now2unix(t(j)));  forecastTime=unix2now(A(:,1));
            [mint,minj]=min(abs(bsxfun(@minus,forecastTime,t')));
            k=find(mint==0); weather(k,:) = A(minj(k),:);
        catch
            fprintf('WARNING: ''%s'' site forecast.io error\n',names{i})
        end
    end
    Y{i}=[X weather];
end
X=cat(1,Y{:});  L(:,1)=num2cell((1:size(X,2))'); L(:,2:3)=cat(1,{'date','decimalDay';'site','';'lat','deg';'lon','deg';'altitude','m';'rigidity','GV';'tubes','';'flux','n/s'},F);  
save('NEST + Weather Data.mat','X','L');  fprintf('Done (%.1fs).\n\n',etime(clock,tstart));
end
