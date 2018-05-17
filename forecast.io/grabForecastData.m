function A=grabForecastData(a,F)
f = fieldnames(a); n=numel(f);

A = nan(1,12);
for i=1:n
    j=strcmp(F,f{i});
    if any(j)
        A(j)=a.(f{i});
    end
end

end

