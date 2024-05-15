x = EYEX; t = timeeye;
t = t - t(1);
tv = t(2:end);
v = (diff(x))*60; % velocity in deg/s
%v2 = movmean(v,6);
v2 = smooth(v,30,'loess');
%sw = round(60*0.5); % smoothing window 500 ms

acc = diff(v2);
ta = tv(2:end);

acc2 = diff(acc);
ta2 = ta(2:end);

inc = v2<.5 & [0 acc] < 0.1 & [0 0 acc2] <0.01;

%%
v3=[];
for i=1:length(v2)-11
    v3 = [v3 v(i+11)-v(i)];
end


%%
figure; 
subplot(3,1,1)
plot(t,x)
subplot(3,1,2)
hold on
plot(tv,v2,'O-')
subplot(3,1,3)

plot(tv(inc),v2(inc))
%plot(tv,smooth(v,12,'loess'),'LineWidth',3)