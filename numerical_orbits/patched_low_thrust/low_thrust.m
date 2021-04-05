%--------------------------------------------------------------------------
% low_thrust - low/continuous thrust orbit solution (using rk4)
% edited by sdf33, jjs280
%--------------------------------------------------------------------------
clear all; close all; clc;
disp('low_thrust');
fnmin=input('enter input file -> ','s'); fin=fopen(fnmin);
fnmout=input('enter output file -> ','s'); fout=fopen(fnmout,'w');
disp(' ');
%...read the input file, write to display
itan=fscanf(fin,'%g',[1,1]); s=fgetl(fin); fprintf(1,'%g %s\n',itan,s);
nu=fscanf(fin,'%g',[1,1]); s=fgetl(fin); fprintf(1,'%g %s\n',nu,s);
x1=fscanf(fin,'%g',[1,1]); s=fgetl(fin); fprintf(1,'%g %s\n',x1,s);
x2=fscanf(fin,'%g',[1,1]); s=fgetl(fin); fprintf(1,'%g %s\n',x2,s);
x3=fscanf(fin,'%g',[1,1]); s=fgetl(fin); fprintf(1,'%g %s\n',x3,s);
h=fscanf(fin,'%g',[1,1]); s=fgetl(fin); fprintf(1,'%g %s\n',h,s);
iprt=fscanf(fin,'%hd',[1,1]); s=fgetl(fin); fprintf(1,'%hd %s\n',iprt,s);
n=fscanf(fin,'%hd',[1,1]); s=fgetl(fin); fprintf(1,'%hd %s\n',n,s);
for i=1:n
    yv=fscanf(fin,'%g',[1,1]); s=fgetl(fin); 
    fprintf(1,'%g %s\n',yv,s); y(i)=yv;
end

%% begin edits....
r0 = fscanf(fin,'%g',[1,1]); s=fgetl(fin); fprintf(1,'%g %s\n',r0,s);
m = fscanf(fin,'%g',[1,1]); s=fgetl(fin); fprintf(1,'%g %s\n',m,s);
mu = fscanf(fin,'%g',[1,1]); s=fgetl(fin); fprintf(1,'%g %s\n',mu,s);
r_target = fscanf(fin,'%g',[1,1]); s=fgetl(fin); fprintf(1,'%g %s\n',r_target,s);
rho_target = fscanf(fin,'%g',[1,1]); s=fgetl(fin); fprintf(1,'%g %s\n',rho_target,s);
V0 = fscanf(fin,'%g',[1,1]); s=fgetl(fin); fprintf(1,'%g %s\n',V0,s);
V_kick = fscanf(fin,'%g',[1,1]); s=fgetl(fin); fprintf(1,'%g %s\n',V_kick,s);
disp(' ')
g = (mu/r0^2)*1000;
T = nu*m*g;
fprintf('Thrust: %.5f N\n',T)
t = (x3+x2)*sqrt(r0^3/mu);
fprintf('Time of Transfer: %.3f days\n',t/3600/24)
fprintf('DeltaV due to kick stage: %.3f km/s\n',V_kick)
%% end edits......more edits below

x=x1; 
yrow=y(1:end); fprintf(fout,'%12.4e',x); fprintf(fout,'%12.4e',yrow); 
fprintf(fout,'\r\n');
ii=0;
nn=0;
rho(1)=y(2); theta(1)=y(4);
while x <= x2-h
    ii=ii+1;
    dydx=derivs(x,y,nu,itan);
    yout=rk4(y,dydx,n,x,h,nu,itan);
    if (ii==iprt)
        yrow=yout(1:end); xp=x+h; fprintf(fout,'%12.4e',xp); 
        fprintf(fout,'%12.4e',yrow); fprintf(fout,'\r\n');
        ii=0;
    end
%...march the solution forward by interval h
    nn=nn+1;
    x=x1+h*nn;
    for i=1:n
        y(i)=yout(i);
    end
    rho(nn+1)=y(2); theta(nn+1)=y(4);
end
%...write to display C3 and state variables at the end of thrusting
c3=y(1)*y(1)+y(2)*y(2)*y(3)*y(3)-2.0/y(2); yrow=y(1:end);
fprintf(1,'\n');
fprintf(1,'%12.4e',c3); fprintf(1,'%12.4e',xp); fprintf(1,'%12.4e',yrow);
fprintf(1,'\r\n');
rho_end=y(2); theta_end=y(4);
%...zero-thrust coasting portion of the trajectory
nu=0.0;
while x < x2+x3
    ii=ii+1;
    dydx=derivs(x,y,nu,itan);
    yout=rk4(y,dydx,n,x,h,nu,itan);
    if (ii==iprt)
        yrow=y(1:end); xp=x+h; fprintf(fout,'%12.4e',xp); 
        fprintf(fout,'%12.4e',yrow); fprintf(fout,'\r\n');
        ii=0;
    end
%...march the solution forward by interval h
    nn=nn+1;
    x=x1+h*nn;
    for i=1:n
        y(i)=yout(i);
    end
    rho(nn+1)=y(2); theta(nn+1)=y(4);
end
%...plot the spiral orbit in polar coordinates
r1=linspace(1,1); th=linspace(0,2*pi);
polarplot(th,r1,'-r',theta,rho,'-b',theta_end,rho_end,'ro');
%...if version of MATLAB does not support polarplot, use polar below
%polar(theta,rho);
status=fclose('all');


%% begin edits......
r_final = r0*rho_end;
fprintf('Final Orbit Radius:     %.3f km\n',r_final)
fprintf('Desired Orbit Radius:   %.3f km\n',r_target)
disp(' ')

%...plot the sprial orbit in polar coordinates
r1=linspace(1,1); th=linspace(0,2*pi); 
desired_r=linspace(r_target,r_target); desired_th=linspace(0,2*pi);
polarplot(th,r1,'-r',theta,rho,'-b',theta_end,rho_end,'ro',desired_th,desired_r/r0,'-g')
% end edits........