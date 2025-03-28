% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function Rcv = convertWMMtoVRC(lat,lon)
%Converts Wold Magnetic Model (nT) to Vertical Cutoff Rigidity (GV)
%http://engineering.dartmouth.edu/~d76205x/research/Shielding/docs/Smart_06.pdf

if nargin==0
    n=180;  [lat,lon]=meshgrid(linspace(-1,1,n)*90,linspace(-1,1,n*2)*180);
    
    lambda = WMM(lat,lon,'Inclination');
    Rcv = 14.5.*cosd(lambda).^2./1^2;
    
    h=fig(1,1,2,4); coasts(h);  [c,h]=contour(lon,lat,Rcv,1:15,'linewidth',1.5); title('Vertical Cutoff Rigidity = 14.5*cos(inclination)^4 (GV)');  clabel(c,h,'LabelSpacing',400)
    h=fig(1,1,2,4); coasts(h);  [c,h]=contour(lon,lat,lambda,-90:10:90,'linewidth',1.5); title('WMM Inclination (deg)');  clabel(c,h,'LabelSpacing',400)
else
    lambda = WMM(lat,lon,'Inclination');
    Rcv = 14.5.*cosd(lambda).^2./1^2;
end

