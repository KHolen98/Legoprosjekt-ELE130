clear; close all; clc


load("P05_MeasManuellKjoring_MF.mat")
k1= Tid(35);
MF = plot(Tid(1:35), e(1:35), 'b')
hold on


load("P05_MeasManuellKjoring_Marie2.mat")
k2= Tid(60);
M = plot(Tid(1:60), e(1:60), 'r')
hold on


load("P05_MeasManuellKjoring_KH.mat")
k3 = Tid(end);
tid = Tid;
ref = e(1);
KH = plot(Tid, e, 'g')
hold on


load("P05_MeasManuellKjoring_OMV.mat")
k4 = Tid(40);
OMV = plot(Tid(1:40),e(1:40), 'm')
hold on

legend([MF M KH OMV],{'Mikal','Marie','Kristoffer','Ole Martin',''})


plot(tid,ref*ones(1,length(tid)),'k--')

xline(k1,'Color','blue','LineStyle','--','Label','Stopp Mikal','LabelOrientation','horizontal','LabelHorizontalAlignment','left')
xline(k2,'Color','red','LineStyle','--','Label','Stopp Marie','LabelOrientation','horizontal','LabelHorizontalAlignment','left')
xline(k3,'Color','green','LineStyle','--','Label','Stopp Kristoffer','LabelOrientation','horizontal','LabelHorizontalAlignment','left')
xline(k4,'Color','magenta','LineStyle','--','Label','Stopp Ole Martin','LabelOrientation','horizontal')
