%function [] = fcnMCNPmap()
clc; clear; close all
load background.mat; a=background;  n=613;  ov=ones(n,1);
a=permute(reshape(a,[303, 185739/303, 4]),[1 3 2]);  lla=[squeeze(a(1,1,:)), squeeze(a(1,2,:)), zeros(n,1)];

a=a(3:(end-1),:,:);  %size a = [300     4   613]

Eneutron = a(:,1,1);  Eproton = a(:,3,1);

sa=squeeze(nansum(a,1)); %size sa = [4 613];


ha=fig(1,1,2,4); coasts(ha);
scatter(lla(:,2),lla(:,1),ov*90,sa(2,:),'filled'); fcntight('csigma'); axis equal tight vis3d off; h=colorbar; h.Label.String='n/cm^2/s'; fcnfontsize(16)

ha=fig(1,1,2,4); coasts(ha);
scatter(lla(:,2),lla(:,1),ov*90,sa(4,:),'filled'); fcntight('csigma'); axis equal tight vis3d off; h=colorbar; h.Label.String='p/cm^2/s'; fcnfontsize(16)





% ha=fig(1,1,1.5,3); 
%         proj = 'winkel';
%         prettyname = proj; %strtrim(Q(j,:));
% 
%         %geoidrefvec = refvecworld(z,'cells');
%         axesm(proj,'Origin',[0 0 0],'FontColor',[1 1 1]*.8,'FontSize',3,'FFill',1000,'LabelRotation','on'); %Origin [elevation 0 azimuth] (deg)
%         %geoshow(z,geoidrefvec,'DisplayType','texturemap');
%         
%         
%         %if ~strcmp(proj,'pcarree')
%             %a=load('coast');  plotm(a.lat,a.long,'-','linewidth',1,'color',[1 1 1]) %.5
%             lw=.4;
%             mlabel(1);
%             plabel(180);
%             if ~any(regexpi(proj,'ortho')); set(handlem('PLabel'),'Tag',''); plabel(-180); end
%             if any(regexpi(proj,'mollweid')); mlabel(2); deleteh(findobj(gcf,'String',' 90^{\circ} N')); deleteh(findobj(gcf,'String',' 90^{\circ} S')); end
%             
%             h=gridm('-'); set(h,'color',c1,'Clipping','off','linewidth',lw*.6); %.3
%             h=framem('-'); set(h,'edgecolor',[1 1 1]*.9,'linewidth',20)
%             deleteh(findobj(gcf,'String','  0^{\circ}  ')); deleteh(findobj(gcf,'String','  0^{\circ}'));
%             fcnfontsize(12)
% 
%             coasts(gca);
% 
%         axis equal tight off;



