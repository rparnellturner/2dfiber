% calculate image moment properties for bathymetric data
% Input is 100 dpi tif image of slope grid from GMT / Imagemagik
% Ross Parnell-Turner, SIO June 2022

clear all
close all

foutname=['box_stats.dat'];
fout=fopen(foutname,'w');

for box = 1;
    
% edit to read in location of tif files   
I=imread(['images/box' num2str(box) '.tif']);
% T=rgb2gray(I);

f=fft2(I);
f=abs(f);
k = fftshift(log(1+f.*f));
k=imrotate(k,90);
k=mat2gray(k);

b=0.65;
level=graythresh(I);
kb=imbinarize(k,b);

s = regionprops(kb, 'Orientation', 'MajorAxisLength', ...
    'MinorAxisLength', 'Eccentricity', 'Centroid');

% find largest centroid
[M,n] = max([s.MajorAxisLength]);

% calc aspect ratio of centroid (proxy for anisotropy)
ar=(s(n).MajorAxisLength)/(s(n).MinorAxisLength);

% azimith of centroid  
azi=(((s(n).Orientation))-90)*-1;

fprintf(fout,'%2.0f %2.1f %2.1f\n',box, ar, azi);

% make plot

phi = linspace(0,2*pi,50);
cosphi = cos(phi);
sinphi = sin(phi);

scrsz = get(0,'ScreenSize');
h1=figure;
x0=10;
y0=10;
width=700;
height=800;
set(gcf,'position',[x0,y0,width,height])
imshow(kb, [])
hold on
text(50,50,['Aspect ratio = ',num2str(ar,'%2.1f')],'Color','white');
text(50,80,['Azimuth = ',num2str(azi,'%2.0f')],'Color','white');


h2=figure;

x0=10;
y0=10;
width=700;
height=800;
set(gcf,'position',[x0,y0,width,height])

subplot(2,2,1:2)
imshow(I)
title('Slope image','FontSize',12)
hold on

subplot(2,2,3)
hold on
imshow(k,[])
title('Power spectrum','FontSize',12)
hold on

subplot(2,2,4)
imshow(kb, [])
title(['Aspect ratio = ',num2str(ar,'%2.1f') ' |  Azimuth = ',num2str(azi,'%2.0f') ],'FontSize',12)
hold on
text(0,-80,['binarize = ',num2str(b,'%2.2f')],'BackgroundColor','white','FontSize',15);

for k = n;
    xbar = s(k).Centroid(1);
    ybar = s(k).Centroid(2);

    a = s(k).MajorAxisLength;
    b = s(k).MinorAxisLength;

    theta = pi*s(k).Orientation/180;
    R = [ cos(theta)   sin(theta)
         -sin(theta)   cos(theta)];

    xy = [a*cosphi; b*sinphi];
    xy = R*xy;

    x = xy(1,:) + xbar;
    y = xy(2,:) + ybar;

    plot(x,y,'r','LineWidth',2);
end

%  write out eps file
outfile=(['images/box' num2str(box) 'centroid_June22.eps']);
% set(h1, 'PaperPositionMode', 'auto')   % Use screen size
% print(h1, '-depsc', outfile)

close all

    end




