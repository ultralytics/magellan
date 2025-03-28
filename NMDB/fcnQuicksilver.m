% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [T,pSea,pStation,altitude,rigidity,water] = fcnQuicksilver(nc)
if nargin==0; nc=720; end %number of columns
nr=nc/2;  [lat,lon]=meshgrid(linspace(90,-90,nr), linspace(-180,180,nc));

%PROJECT QUICKSILVER ------------------------------------------------------
url = '2015_09_16_15.tif'; %url='http://maps.forecast.io/temperature/2015/09/16/15.tif';
T = imread(url);  T = single(T)/100 - 273.15;  T = imresize(T, [nr nc]);  

[altitude, water] = fcnaltitude(lat,lon);

pSea = readNOAA_NCAR('09/06/2015',lat,lon)'; %pSea = 1013.25; %mbar

pStation = sea2stationPressure(pSea,altitude,T);

rigidity = convertWMMtoVRC(lat,lon)';

plotFlag=1;
if plotFlag
    h=fig(3,2,1.5,3);
    sca;  imshow(T);        h(1).CLim=[-30 35];     colorbar; colormap(parula);  title('forecast.io Temperature (C)')
    sca;  imshow(pSea);     h(2).CLim=[980 1020];   colorbar; colormap(parula);  title('NOAA Sea Level Pressure (mbar)')
    sca;  imshow(pStation); h(3).CLim=[600 1020];   colorbar; colormap(parula);  title('Station Pressure (mbar)')
    sca;  imshow(rigidity); h(4).CLim=[0 14];       colorbar; colormap(parula);  title('Rigidity (GV)')
    sca;  imshow(altitude); h(5).CLim=[0 4000];  colorbar; colormap(parula); title('Altitude (m)')

%     h=fig(1,1,2,4);;  imshow(T);        h.CLim=[-30 35];     c=colorbar; colormap(parula);  title('forecast.io Temperature (C)'); c.Position = [0.914 0.119 0.0161 0.816]; fcnfontsize(16)
%     h=fig(1,1,2,4);;  imshow(pSea);     h.CLim=[980 1020];   c=colorbar; colormap(parula);  title('NOAA Sea Level Pressure (mbar)'); c.Position = [0.914 0.119 0.0161 0.816]; fcnfontsize(16)
%     h=fig(1,1,2,4);;  imshow(pStation); h.CLim=[600 1020];   c=colorbar; colormap(parula);  title('Station Pressure (mbar)'); c.Position = [0.914 0.119 0.0161 0.816]; fcnfontsize(16)
%     h=fig(1,1,2,4);;  imshow(rigidity); h.CLim=[0 14];       c=colorbar; colormap(parula);  title('D.F. Smart 2002, Rigidity (GV)'); c.Position = [0.914 0.119 0.0161 0.816]; fcnfontsize(16)
%     h=fig(1,1,2,4);;  imshow(altitude); h.CLim=[0 4000];     c=colorbar; colormap(parula); title('ETOPO1 Altitude (m)'); c.Position = [0.914 0.119 0.0161 0.816]; fcnfontsize(16)
end

end

function [altitude, water] = fcnaltitude(lat,lon)
etopo = etopo1(lat,lon)';
egm = egm1(lat,lon)';
altitude = max(etopo,egm);
water = egm>etopo;
end
