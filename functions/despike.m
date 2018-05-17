function y=despike(y,srl,window,replacementValue)
if nargin<3;
    srl = 6;
    window = ceil(size(y,1)*.01);  %1% sliding window
end
x=1:numel(y); y0=y;

%FIX SINGLE NAN POINTS FROM GOOD DATA ON EACH SIDE ------------------------
a=isfinite(y);  i = ~a & circshift(a,1,1) & circshift(a,-1,1); %nan point but good on either side
F=griddedInterpolant(x(~i),y(~i)); y(i)=F(x(i)); %interpolate

%SIGMA REJECTION ----------------------------------------------------------
vel = [0; diff(y,1,1)];
ys=fcnsmooth(y,window);
[~,i]=fcnsigmarejection(vel,    srl,3);
[~,j]=fcnsigmarejection(y,      srl,3);
[~,k]=fcnsigmarejection(y-ys,   srl,3);
%fig; fcnhist(vel,50);

%REPLACE OUTLIERS ---------------------------------------------------------
i = i & j & k;
F=griddedInterpolant(x(i),y(i));
y(~i)=F(x(~i));
if nargin==4; y(~i)=replacementValue; end %typically repacementValue = 0 or = nan

%PLOT ---------------------------------------------------------------------
plotflag=false;
if plotflag
    fig(2,1,1.5,2);
    plot(x,y0,'b.-','displayname','data'); plot(x(~i),y0(~i),'ro','displayname','outliers');
    sca; plot(x,y,'b.-'); fcntight('x'); fcntight('yjoint');
end