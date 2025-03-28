% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [ha, R] = plotmatrix2(X,xstr)
nx=size(X,2);  ny=size(X,2);  R=zeros(nx,ny);

%fig; hist211(X(:,15),X(:,9),'pcolor')


ha=fig(nx,ny,.5,.5,[0 0]);
ha=reshape(ha,nx,ny);

cmap=flipud(redblue(256));
F = griddedInterpolant(linspace(-1,1,256)',1:256,'nearest');

for i=1:nx
    for j=1:ny
        h = ha(i,j);
        %if i>j; delete(h); continue; end
        a=X(:,i); b=X(:,j);  grid(h,'off');
        if i==1;  h.YLabel.String=str_(xstr{j}); else h.YColor=[1 1 1]; h.YTick=[]; end
        if j==nx; h.XLabel.String=str_(xstr{i}); else h.XColor=[1 1 1]; h.XTick=[];end
        k = isfinite(a) & isfinite(b); if ~any(k); continue; end
        
        r=corr(a(k),b(k));  if ~isnan(r); color = cmap(F(r),:)*.98;  R(i,j)=r; else color=[1 1 1]; end
        plot(h,a,b,'.','Color',color)
    end
    fcntight(ha(i,:),'xjoint sigma');
end

for j=1:ny
   fcntight(ha(:,j),'yjoint sigma')
   for i=1:nx
      h=ha(i,j);
      text(h.XLim(1),h.YLim(1),1,sprintf('  %.2f\n',R(i,j)),'Parent',h) 
   end
end

fcnfontsize(16); fcnmarkersize(.1);



