% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function x1=fcnCovarianceModel(iC,xv,mu)
%GENERAL MULTIVARIATE NORMAL FORM: dx = (x-mu)';  %fx = 1/((2*pi)^(n/2)*sqrt(det(C))) * exp(-.5*dx'*C^-1*dx)
n = numel(mu);

%dx=sym('dx',[n 1]); sym(dx,'real'); syms x mu1 real
%dx(1) = x-mu(1); for i=2:n; dx(i)=xv(1,i)-mu(i); end
%f = dx'*iC*dx;
%vpa(collect(f),3)
%f=solve(f,x)


%SOLVE FOR x1 CONDITIONAL ON x2...xn
i = 2:n;
a = iC(1,1); %C11*x^2
b = sum(bsxfun(@times,iC(1,i),bsxfun(@minus,xv(:,i),mu(i))),2)*2 - iC(1,1)*mu(1)*2; %(C12*dx2 + C13*dx3 + C21*dx2 + C31*dx3 - 2*C11*mu)*x
%c = 0;
%f = quadratic(a,b,c);
x1 = -b/2/a;
%f = (-b+sqrt(b.^2-4*a.*c))./(2*a);


% iC=sym('C%d%d',[3 3]); sym(iC,'real');
% dx=sym('dx',[3 1]); sym(dx,'real');
% syms x mu real
% dx(1)=x-mu;  f=dx'*iC*dx;
% factor(f,x)
% collect(f,x)
end