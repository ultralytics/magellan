% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function pSea = station2seaPressure(pStation,elevation,tempC)
%http://www.sandhurstweather.org.uk/barometric.pdf
%p = pressure (millibar or hectopascals);
%elevation (m)
tempK = tempC + 273.15;

k = tempK * 29.263;
pSea = pStation./exp(-elevation./k);
%pStation = pSea.*exp(-elevation./k);