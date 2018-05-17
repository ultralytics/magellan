function pStation = sea2stationPressure(pSea,elevation,tempC)
%http://www.sandhurstweather.org.uk/barometric.pdf
%p = pressure (millibar or hectopascals);
%elevation = elevation of station (m)
%tempC = temp at station (C)

k = (tempC+273.15) * 29.263;
%pSea = pStation./exp(-elevation./k);
pStation = pSea.*exp(-elevation./k);