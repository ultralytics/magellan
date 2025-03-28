% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function Xout = readNOAA_NCAR(Date,LAT,LNG)
%http://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis.derived.surface.html
%Date = any matlab 'date' function. i.e. type >>date
%LAT = [-90 to 90] deg
%LNG = [-180 to 180] or [0 to 360] deg
LNG = longitude180to360(LNG);
dayOfYear = datenum(Date) - datenum(year(Date),0,0);


%NOAA NC FILE FOR PRESSURE ------------------------------------------------
file = 'slp.day.1981-2010.ltm.nc';  %sea level pressure
%file = 'air.sig995.day.1981-2010.ltm.nc';  %temperature
%ncdisp(file)
X = ncread(file,'slp'); 
X = X(:,:,dayOfYear)/100; %Pascals to mbar

lat = ncread(file,'lat');
lon = ncread(file,'lon');  lon(end+1)=360;  X(end+1,:)=X(1,:); %cover completely 0-360

F = griddedInterpolant({lon,-lat},X);
Xout = F(LNG,-LAT);


%PLOTTING -----------------------------------------------------------------
%fig(1,1,2,4);  imshow(Xout'); fcntight('c'); colorbar; colormap(parula); title('NOAA NCAR data')







