% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function F=forecastHourlyFields() %https://developer.forecast.io/docs/v2
F={ 'precipIntensity' 
    'precipProbability' 
    'precipAccumulation' 
    'temperature' 
    'apparentTemperature' 
    'dewPoint' 
    'windSpeed' 
    'cloudCover' 
    'humidity' 
    'pressure' 
    'visibility' 
    'ozone'}; 

% F={ 'precipIntensity' 
%     'precipProbability'
%     'precipType'
%     'precipAccumulation' 
%     'temperature' 
%     'apparentTemperature' 
%     'dewPoint' 
%     'windSpeed'
%     'windBearing'
%     'cloudCover' 
%     'humidity' 
%     'pressure' 
%     'visibility' 
%     'ozone'}; 
%add precipType, windBearing (hourly) and moonPhase (daily) !!
end
