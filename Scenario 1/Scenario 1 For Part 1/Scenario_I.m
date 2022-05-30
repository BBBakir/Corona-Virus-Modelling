%% Zuhal Ceren Aydın  2444370
%% Burak Baki Bakır   2530103

clear all
clc

T = 20;
N = 240;

coords = zeros(2,240);
infs = [];
grid = zeros(T,T);

for i= 1:240
    pl = true;
    while pl == true
        [a ,b] = coord();
        na = false;
        for k = 1:length(coords)
            if a == coords(1,k) && b == coords(2,k)
                na= true;
            end
        end
        if na == false    
            coords(1,i) =  a;
            coords(2,i) =  b;
            pl=false;
        end
    end
end

infs = [coords(1,240*0.05*0.5+1:240*0.05) ; coords(2,240*0.05*0.5+1:240*0.05)];
not_infs = [coords(1,240*0.05+1:240);coords(2,240*0.05+1:240)];
isos = [coords(1,1:240*0.05*0.5) ; coords(2,1:240*0.05*0.5)];
isos_i = isos;
iter_inf = zeros(1,length(infs(1,:)));
iter_n = zeros(1,length(not_infs(1,:)));
iter_isos = zeros(1,length(isos(1,:)));
heal = [];
n_d = 0;
t_nni = [];
t_ni = [];
t_nnh = [];
t_nh = [];
t_nnd = [];
t_nd = [];
t_it = 1:150;
total_i = length(infs(1,:))+length(isos(1,:));
total_h = 0;

for z = 1:150
    n_nd = 0;
    n_ni = 0;
    n_nh = 0;

    %%%%%%%%% walk nonisolated people
    if length(infs(1,:)) >= 1 
        for k = 1:length(infs(1,:))
            coor = [infs(1,k)  infs(2,k)];
            new_c = randomWalk(coor);
            infs(1,k) = new_c(1);
            infs(2,k) = new_c(2);
            iter_inf(1,k) = iter_inf(1,k)+1;
        end
    end
    %%%%%%%%% walk isolated people
    if length(isos(1,:)) >= 1 
        for k = 1:length(isos(1,:))
            coor = [isos_i(1,k)  isos_i(2,k)];
            new_c = isoWalk(coor);
            isos(1,k) = new_c(1);
            isos(2,k) = new_c(2);
            iter_isos(1,k) = iter_isos(1,k)+1;
        end
    end
    %%%%%%%%% walk nonisolated people
    if length(not_infs(1,:)) >= 1 
        for k = 1:length(not_infs(1,:))
             coor = [not_infs(1,k)  not_infs(2,k)];
             new_c = randomWalk(coor);
             not_infs(1,k) = new_c(1);
             not_infs(2,k) = new_c(2);
             iter_n(1,k) = iter_n(1,k) +1;
        end
    end
    %%%%%%%%% infection checker with infs
    k=1;
    while k <= length(not_infs(1,:)) 
        tf_c = true;
        o = 1;
        ta_c = true;
        while o <= length(infs(1,:)) && ta_c == true
            if not_infs(1,k) == infs(1,o) && not_infs(2,k) == infs(2,o)
                pr = rand;
                pr2 = rand;
                if pr >= 0.5 % get infected
                    if pr2 >= 0.5
                        infs = [infs(1,:) not_infs(1,k) ; infs(2,:) not_infs(2,k)];
                        iter_inf = [iter_inf 0];
                        iter_n(:, k) = [];
                        n_ni =  n_ni +1;
                    else
                        isos = [isos(1,:) not_infs(1,k) ; isos(2,:) not_infs(2,k)];
                        isos_i = [isos_i(1,:) not_infs(1,k) ; isos_i(2,:) not_infs(2,k)];
                        iter_isos = [iter_isos 0];
                        iter_n(:, k) = [];
                        n_ni =  n_ni +1;
                    end
                    not_infs(:,k) = [];                   
                    k = k-1;
                    tf_c = false;
                end
                ta_c = false;
            end
            o = o+1;
        end
        %%%%%%%%% infection checker with isolated
        if tf_c == true
            o = 1;
            while o <= length(isos(1,:)) && ta_c == true
                if not_infs(1,k) == isos(1,o) && not_infs(2,k) == isos(2,o)
                    pr = rand;
                    pr2 = rand;
                    if pr >= 0.5 % get infected
                        if pr2 >= 0.5
                            infs = [infs(1,:) not_infs(1,k) ; infs(2,:) not_infs(2,k)];
                            iter_inf = [iter_inf 0];
                            iter_n(:, k) = [];
                            n_ni =  n_ni +1;
                        else
                            isos = [isos(1,:) not_infs(1,k) ; isos(2,:) not_infs(2,k)];
                            isos_i = [isos_i(1,:) not_infs(1,k) ; isos_i(2,:) not_infs(2,k)];
                            iter_isos = [iter_isos 0];
                            iter_n(:, k) = [];
                            n_ni =  n_ni +1;
                        end
                        not_infs(:,k) = [];
                        k = k-1;
                    end
                    ta_c = false;
                end
                o = o+1;
            end
        end
        k = k+1;
    end

    %healing process
    j = 1;
    while j <= length(iter_inf) 
        if iter_inf(j)==30
            p_h = rand;
            if p_h > 0.95 % die
                infs(:,j) = [];
                iter_inf(j) = [];
                n_d = n_d+1;
                j = j-1; 
                n_nd = n_nd +1;
            elseif p_h <= 0.95 % heal
                heal = [heal(:,:) infs(:,j) ];
                infs(:,j) = [];
                iter_inf(j) = []; 
                n_nh =  n_nh +1;
                j = j-1;
            end
        end
        j = j+1;
    end
    %%%isolated healing process
    j = 1;
    while  j <= length(iter_isos) 
        if iter_isos(j)==30
            p_h = rand;
            if p_h > 0.95 % die
                isos(:,j) = [];
                iter_isos(j) = [];
                n_d = n_d+1;
                j = j-1; 
                n_nd = n_nd +1;
            elseif p_h <= 0.95 %healed
                heal = [heal(:,:) isos(:,j)];
                isos(:,j) = [];
                iter_isos(j) = [];
                j = j-1;
                n_nh =  n_nh +1;
            end
        end
        j = j+1;
    end
    %%%datas needed
    total_i = total_i +n_ni;
    t_ni = [t_ni total_i];
    total_h = total_h +n_nh;
    t_nh = [t_nh total_h];
    t_nd = [t_nd n_d];
    t_nni = [t_nni n_ni];
    t_nnh = [t_nnh n_nh];
    t_nnd = [t_nnd n_nd];
end 


tiledlayout(3,2);

nexttile
plot(t_it,t_nni,"r",'LineWidth',2)
title('Number of newly infected people in each iteration')
xlim([0 175])
ylim([0 35])

nexttile
plot(t_it,t_ni,"r",'LineWidth',2)
title('Total number of infected people in the system in each iteration')
xlim([0 175])
ylim([0 240])


nexttile
plot(t_it,t_nnh,"g",'LineWidth',2)
title('Number of newly healed people in each iteration')
xlim([0 175])
ylim([0 30])

nexttile
plot(t_it,t_nh,"g",'LineWidth',2)
title('Total number of healed people in the system in each iteration')
xlim([0 175])
ylim([0 240])


nexttile
plot(t_it,t_nnd,'k','LineWidth',2)
title('Number of people that are died in that iteration')
xlim([0 175])
ylim([0 10])

nexttile
plot(t_it,t_nd,'k','LineWidth',2)
title('Total number of dead people in the system in each iteration')
xlim([0 175])
ylim([0 40])




