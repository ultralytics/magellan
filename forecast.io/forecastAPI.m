% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [S, url, X, F] = forecastAPI(lat,lng,date)
% https://developer.forecast.io
% https://api.forecast.io/forecast/47ab0a8f644eb458f66eb4b46ac7b420/46.5475,7.9851;  %EXAMPLE
% lat = '46.5475';
% lng = '7.9851';
% date = '2014-09-06T12:00:00'; %SHOWS 24 hours UTC midnight to midnight

%api = 'https://api.forecast.io/forecast/47ab0a8f644eb458f66eb4b46ac7b420/';
api = 'https://api.darksky.net/forecast/47ab0a8f644eb458f66eb4b46ac7b420/';

if nargin==3
    if ischar(date);  date=now2unix(date);  end %convert to UNIX time
    url = sprintf('%s%.6f,%.6f,%.0f?units=si',api,lat,lng,date);
else
    url = sprintf('%s%.6f,%.6f?units=si',api,lat,lng);
end
wo=weboptions; wo.Timeout=60;  S=webread(url,wo);

F=forecastHourlyFields; nf=size(F,1); X=nan(24,nf);
try
    for i=1:numel(S.hourly.data)
        if iscell(S.hourly.data)
            a=S.hourly.data{i};
        else %isstruct
            a=S.hourly.data(i);
        end
        
        X(i,:)=grabForecastData(a,F(:,1));
    end
catch
    fprintf('ERROR: forecast.io ''%s'' returns\n%s\n',url,urlread(url))
end
end


function A=grabForecastData(a,F)
f = fieldnames(a); n=numel(f);
precipType = {'rain','snow','sleet','hail'}; %replace with 1,2,3,4

A = nan(1,numel(F));
for i=1:n
    j=strcmp(F,f{i});
    if any(j)
        b=a.(f{i});  if ischar(b); b=find(strcmp(precipType,b)); end
        A(j)=b;
    end
end
end


function F=forecastHourlyFields() %https://developer.forecast.io/docs/v2
F={ 'time',                 'unix';
    'precipIntensity',      'mm/hr';
    'precipProbability',    'fraction';
    'precipType',           'category';
    'precipAccumulation',   'cm';
    'temperature',          'C';
    'apparentTemperature',  'C';
    'dewPoint',             'C';
    'windSpeed',            'm/s';
    'windBearing',          'deg 0-360';
    'cloudCover',           'fraction';
    'humidity',             'fraction';
    'pressure',             'mbar';
    'visibility',           'km';
    'ozone',                'Dobson units'}; %add daily moonphase!!
end

