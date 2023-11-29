w=logspace(-2,2);
t=linspace(0,60);

% first form the plant as a sum of G1 and G2
G1=tf(1,[1 -0.1 0.05]);
G2=tf([0 0.1],[1 3 25]);
G=G1+G2;
%nyquist(G)
%figure(1),rlocus(G)
%figure(1),bode(G,w);
a=1.7;
K1=tf(a*[1 1/a],[1 a]);
Kb=K1*K1;
Kc=tf([1 0.2],[1 .002]);
L=G*Kb*Kc; % this is the return ratio
%figure(3),margin(L,w)
%figure(2),bode(Kb*G,w)
CL=feedback(G*Kc,Kb);% CLTF from output of Ka to y
Ka=tf([1 0.4 31],[0.25 1 1]);
CLref=CL*Ka; % this is CLTF from r to y
dcgain=bode(CLref,0);
Ka=Ka/dcgain;
CLref=CLref/dcgain;

%rlocus(CLref)
%figure(1); nyquist(CLref)
%figure(2);margin(CLref,w); % gain and phase margins
%figure(3);step(CLref); % step response
%figure(1);step(CLref,t);

% Check for objectives 1 
beta=linspace(-1,1);
G1=tf(1,[1 -0.1 0.05]);
maxValues_T=[];
maxValues_di=[];
maxValues_r=[];
for b = beta
    G2=tf([b 0.1],[1 3 25]);
    G=G1+G2;
    L=G*Kb*Kc;
    T=feedback(L,1);
    S=1-T;
    
    tf_di=G/(1+L);
    tf_di=minreal(tf_di,1e-3);
    
    tf_r=G*Kc*Ka/(1+L);
    tf_r=minreal(tf_r,1e-3);

    Pole_T=pole(T);
    Pole_di=pole(tf_di);
    Pole_r=pole(tf_r);
    real_parts_T = real(Pole_T);
    currentMax_T=max(real_parts_T);
    maxValues_T = [maxValues_T, currentMax_T];
    real_parts_di = real(Pole_di);
    currentMax_di=max(real_parts_di);
    maxValues_di = [maxValues_di, currentMax_di];
    real_parts_r = real(Pole_r);
    currentMax_r=max(real_parts_r);
    maxValues_r= [maxValues_r, currentMax_r];
end
%figure(2);plot(beta,maxValues_T)
%figure(3);plot(beta,maxValues_di)
%figure(4);plot(beta,maxValues_r)

% Check for objectives 3
final_value=[];
alpha=linspace(0.045,0.055,3);
G2=tf([0 0.1],[1 3 25]);
count=1;
for a = alpha
    G1=tf(1,[1 -0.1 a]);
    G=G1+G2;
    CL_3=feedback(G*Kc,Kb)*Ka;
    [response, time] = step(CL_3,t);
    final_value=[final_value, response(end)];
end
%figure(5);plot(alpha,final_value)

alpha=linspace(0.045,0.055,10);
beta=linspace(-1,1,10);
CL_add_arr=[];
for i = 1:length(alpha)
    for j = 1:length(beta)
        G1=tf(1,[1 -0.1 alpha(i)]);
        G2=tf([beta(j) 0.1],[1 3 25]);
        G=G1+G2;
        CL_add=feedback(G*Kc,Kb)*Ka;
        figure(5);step(CL_add, t);
        hold on;
    end
end