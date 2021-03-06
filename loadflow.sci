// Program for Bus Power Injections, Line & Power flows (p.u)...

function loadflow(nb,V,del,BMva, alg, report)
global busdat;
global linedat;
Y = ybus();                   // Calling Ybus program..
lined = linedat;          // Get linedats..
busd = busdat;            // Get busdatas..
Vm = pol2rect(V,del);           // Converting polar to rectangular..
Del = 180/%pi*del;               // Bus Voltage Angles in Degree...
fb = lined(:,1);                // From bus number...
tb = lined(:,2);                // To bus number...
nl = length(fb);                // No. of Branches..
Pl = busd(:,7);                 // PLi..
Ql = busd(:,8);                 // QLi..

Iij = zeros(nb,nb);
Sij = zeros(nb,nb);
Si = zeros(nb,1);

// Bus Current Injections..
 I = Y*Vm;
 Im = abs(I);
 Ia =atan(imag(I),real(I));
 
// Line Current Flows..
for m = 1:nl
    p = fb(m); q = tb(m);
    Iij(p,q) = -(Vm(p) - Vm(q))*Y(p,q); // Y(m,n) = -y(m,n)..
    Iij(q,p) = -Iij(p,q);
end
Iij_temp=Iij
Iij = sparse(Iij);
Iijm = abs(Iij);
Iija_temp = atan(imag(Iij_temp),real(Iij_temp));
Iija= sparse(Iija_temp);

// Line Power Flows..
for m = 1:nb
    for n = 1:nb
        if m ~= n
            Sij(m,n) = Vm(m)*conj(Iij(m,n))*BMva;
        end
    end
end
Sij_temp=Sij
Sij = sparse(Sij);
Pij=real(Sij);
Pij_temp = real(Sij_temp); 
Qij = imag(Sij);
Qij_temp=imag(Sij_temp); 
// Line Losses..
Lij = zeros(nl,1);
for m = 1:nl
    p = fb(m); q = tb(m);
    Lij_temp(m) = Sij_temp(p,q) + Sij_temp(q,p);
    Lij=sparse(Lij_temp);
end
Lpij = real(Lij);
Lpij_temp=real(Lij_temp);
Lqij = imag(Lij);
Lqij_temp=imag(Lij_temp);

// Bus Power Injections..
for i = 1:nb
    for k = 1:nb
        Si(i) = Si(i) + conj(Vm(i))* Vm(k)*Y(i,k)*BMva;
    end
end
Pi = real(Si);
Qi = -imag(Si);
Pg = Pi+Pl;
Qg = Qi+Ql;
if(report==0) 
 if(alg== 'nr')
     disp('#########################################################################################');
disp('-----------------------------------------------------------------------------------------');
disp('                              Newton Raphson Loadflow Analysis ');
disp('-----------------------------------------------------------------------------------------');
elseif(alg == 'gs')
    disp('#########################################################################################');
disp('-----------------------------------------------------------------------------------------');
disp('                                Gauss Seidel Loadflow Analysis ');
disp('-----------------------------------------------------------------------------------------');
end
disp('| Bus |    V   |  Angle  |     Injection      |     Generation     |          Load      |');
disp('| No  |   pu   |  Degree |    MW   |   MVar   |    MW   |  Mvar    |     MW     |  MVar | ');
for m = 1:nb
    disp('-----------------------------------------------------------------------------------------');
    mprintf('%3g', m); mprintf('  %8.4f', V(m)); mprintf('   %8.4f', Del(m));
    mprintf('  %8.3f', Pi(m)); mprintf('   %8.3f', Qi(m)); 
    mprintf('  %8.3f', Pg(m)); mprintf('   %8.3f', Qg(m)); 
    mprintf('  %8.3f', Pl(m)); mprintf('   %8.3f', Ql(m)); mprintf('\n');
end
disp('-----------------------------------------------------------------------------------------');
mprintf(' Total                  ');mprintf('  %8.3f', sum(Pi)); mprintf('   %8.3f', sum(Qi)); 
mprintf('  %8.3f', sum(Pi+Pl)); mprintf('   %8.3f', sum(Qi+Ql));
mprintf('  %8.3f', sum(Pl)); mprintf('   %8.3f', sum(Ql)); mprintf('\n');
disp('-----------------------------------------------------------------------------------------');
disp('#########################################################################################');

disp('-------------------------------------------------------------------------------------');
disp('                              Line Flow and Losses ');
disp('-------------------------------------------------------------------------------------');
disp('|From|To |    P    |    Q     | From| To |    P     |   Q     |      Line Loss      |');
disp('|Bus |Bus|   MW    |   MVar   | Bus | Bus|    MW    |  MVar   |     MW   |    MVar  |');
for m = 1:nl
    p = fb(m); q = tb(m);
    disp('-------------------------------------------------------------------------------------');
    mprintf('%4g', p); mprintf('%4g', q); mprintf('  %8.3f', Pij_temp(p,q)); mprintf('   %8.3f', Qij_temp(p,q)); 
    mprintf('   %4g', q); mprintf('%4g', p); mprintf('   %8.3f', Pij_temp(q,p)); mprintf('   %8.3f', Qij_temp(q,p));
    mprintf('  %8.3f', Lpij_temp(m)); mprintf('   %8.3f', Lqij_temp(m));
    mprintf('\n');
end
disp('-------------------------------------------------------------------------------------');
mprintf('   Total Loss                                                 ');
mprintf('  %8.3f', sum(Lpij_temp)); mprintf('   %8.3f', sum(Lqij_temp));  mprintf('\n');
disp('-------------------------------------------------------------------------------------');
disp('#####################################################################################');
disp('The load flow analysis is completed successfully');


elseif(report==1)



if(alg== 'nr')
  fileid= strcat([pwd(), "/","nr_report" ,"/","nr_report.txt"]);

  f_temp= mopen(fileid, 'at')
  mclose(f_temp);
 
  fid= mopen(fileid, 'wt');

     mfprintf(fid , '#########################################################################################');
     mfprintf(fid , '\n');
     mfprintf(fid, '-----------------------------------------------------------------------------------------');
     mfprintf(fid , '\n');
     mfprintf(fid, '                              Newton Raphson Loadflow Analysis ');
     mfprintf(fid , '\n');
     mfprintf(fid, '-----------------------------------------------------------------------------------------');
mfprintf(fid , '\n');
mfprintf(fid, '| Bus |    V   |  Angle  |     Injection      |     Generation     |          Load      |');
mfprintf(fid , '\n');
mfprintf(fid, '| No  |   pu   |  Degree |    MW   |   MVar   |    MW   |  Mvar    |     MW     |  MVar | ');
mfprintf(fid , '\n');
for m = 1:nb
    mfprintf(fid, '-----------------------------------------------------------------------------------------');
    mfprintf(fid , '\n');
    mfprintf(fid, '%3g', m); mfprintf(fid, '  %8.4f', V(m)); mfprintf(fid, '   %8.4f', Del(m));
    mfprintf(fid, '  %8.3f', Pi(m)); mfprintf(fid, '   %8.3f', Qi(m)); 
    mfprintf(fid, '  %8.3f', Pg(m)); mfprintf(fid, '   %8.3f', Qg(m)); 
    mfprintf(fid, '  %8.3f', Pl(m)); mfprintf(fid, '   %8.3f', Ql(m)); mfprintf(fid, '\n');
end
mfprintf(fid, '-----------------------------------------------------------------------------------------');
mfprintf(fid , '\n');
mfprintf(fid, ' Total                  ');mfprintf(fid, '  %8.3f', sum(Pi)); mfprintf(fid, '   %8.3f', sum(Qi)); 
mfprintf(fid, '  %8.3f', sum(Pi+Pl)); mfprintf(fid, '   %8.3f', sum(Qi+Ql));
mfprintf(fid, '  %8.3f', sum(Pl)); mfprintf(fid, '   %8.3f', sum(Ql)); mfprintf(fid, '\n');
mfprintf(fid,'-----------------------------------------------------------------------------------------');
mfprintf(fid , '\n');
mfprintf(fid,'#########################################################################################');
mfprintf(fid , '\n');

mfprintf(fid,'-------------------------------------------------------------------------------------');
mfprintf(fid , '\n');
mfprintf(fid,'                              Line Flow and Losses ');
mfprintf(fid , '\n');
mfprintf(fid,'-------------------------------------------------------------------------------------');
mfprintf(fid , '\n');
mfprintf(fid,'|From|To |    P    |    Q     | From| To |    P     |   Q     |      Line Loss      |');
mfprintf(fid , '\n');
mfprintf(fid,'|Bus |Bus|   MW    |   MVar   | Bus | Bus|    MW    |  MVar   |     MW   |    MVar  |');
mfprintf(fid , '\n');
for m = 1:nl
    p = fb(m); q = tb(m);
    mfprintf(fid,'-------------------------------------------------------------------------------------');
    mfprintf(fid , '\n');
    mfprintf(fid,'%4g', p); mfprintf(fid,'%4g', q); mfprintf(fid,'  %8.3f', Pij_temp(p,q)); mfprintf(fid,'   %8.3f', Qij_temp(p,q)); 
    mfprintf(fid,'   %4g', q); mfprintf(fid,'%4g', p); mfprintf(fid,'   %8.3f', Pij_temp(q,p)); mfprintf(fid,'   %8.3f', Qij_temp(q,p));
    mfprintf(fid,'  %8.3f', Lpij_temp(m)); mfprintf(fid,'   %8.3f', Lqij_temp(m));
    mfprintf(fid,'\n');
end
mfprintf(fid,'-------------------------------------------------------------------------------------');
mfprintf(fid , '\n');
mfprintf(fid,'   Total Loss                                                 ');
mfprintf(fid,'  %8.3f', sum(Lpij_temp)); mfprintf(fid,'   %8.3f', sum(Lqij_temp));  mfprintf(fid,'\n');
mfprintf(fid,'-------------------------------------------------------------------------------------');
mfprintf(fid , '\n');
mfprintf(fid,'#####################################################################################');
mfprintf(fid , '\n');
mclose(fid);
mprintf('\n');
mprintf('The report is generated successfully');
mprintf('\n');
mprintf('Please find the report at %s', fileid);



elseif(alg == 'gs')

  fileid= strcat([pwd(), "/","gs_report" ,"/","gs_report.txt"]);

  f1_temp= mopen(fileid, 'at')
  mclose(f1_temp);
 
  fid1= mopen(fileid, 'wt');


    mfprintf(fid1, '#########################################################################################'); 
mfprintf(fid1 , '\n');
    mfprintf(fid1, '-----------------------------------------------------------------------------------------');
mfprintf(fid1 , '\n');
    mfprintf(fid1, '                                Gauss Seidel Loadflow Analysis ');
mfprintf(fid1 , '\n');
    mfprintf(fid1 , '-----------------------------------------------------------------------------------------');
mfprintf(fid1 , '\n');
for m = 1:nb
    mfprintf(fid1, '-----------------------------------------------------------------------------------------');
    mfprintf(fid1 , '\n');
    mfprintf(fid1, '%3g', m); mfprintf(fid1, '  %8.4f', V(m)); mfprintf(fid1, '   %8.4f', Del(m));
    mfprintf(fid1, '  %8.3f', Pi(m)); mfprintf(fid1, '   %8.3f', Qi(m)); 
    mfprintf(fid1, '  %8.3f', Pg(m)); mfprintf(fid1, '   %8.3f', Qg(m)); 
    mfprintf(fid1, '  %8.3f', Pl(m)); mfprintf(fid1, '   %8.3f', Ql(m)); mfprintf(fid1, '\n');
end
mfprintf(fid1, '-----------------------------------------------------------------------------------------');
mfprintf(fid1 , '\n');
mfprintf(fid1, ' Total                  ');mfprintf(fid1, '  %8.3f', sum(Pi)); mfprintf(fid1, '   %8.3f', sum(Qi)); 
mfprintf(fid1, '  %8.3f', sum(Pi+Pl)); mfprintf(fid1, '   %8.3f', sum(Qi+Ql));
mfprintf(fid1, '  %8.3f', sum(Pl)); mfprintf(fid1, '   %8.3f', sum(Ql)); mfprintf(fid1, '\n');
mfprintf(fid1,'-----------------------------------------------------------------------------------------');
mfprintf(fid1, '\n');
mfprintf(fid1,'#########################################################################################');
mfprintf(fid1 , '\n');

mfprintf(fid1,'-------------------------------------------------------------------------------------');
mfprintf(fid1 , '\n');
mfprintf(fid1,'                              Line Flow and Losses ');
mfprintf(fid1 , '\n');
mfprintf(fid1,'-------------------------------------------------------------------------------------');
mfprintf(fid1 , '\n');
mfprintf(fid1,'|From|To |    P    |    Q     | From| To |    P     |   Q     |      Line Loss      |');
mfprintf(fid1 , '\n');
mfprintf(fid1,'|Bus |Bus|   MW    |   MVar   | Bus | Bus|    MW    |  MVar   |     MW   |    MVar  |');
mfprintf(fid1 , '\n');
for m = 1:nl
    p = fb(m); q = tb(m);
    mfprintf(fid1,'-------------------------------------------------------------------------------------');
    mfprintf(fid1 , '\n');
    mfprintf(fid1,'%4g', p); mfprintf(fid1,'%4g', q); mfprintf(fid1,'  %8.3f', Pij_temp(p,q)); mfprintf(fid1,'   %8.3f', Qij_temp(p,q)); 
    mfprintf(fid1,'   %4g', q); mfprintf(fid1,'%4g', p); mfprintf(fid1,'   %8.3f', Pij_temp(q,p)); mfprintf(fid1,'   %8.3f', Qij_temp(q,p));
    mfprintf(fid1,'  %8.3f', Lpij_temp(m)); mfprintf(fid1,'   %8.3f', Lqij_temp(m));
    mfprintf(fid1,'\n');
end
mfprintf(fid1,'-------------------------------------------------------------------------------------');
mfprintf(fid1, '\n');
mfprintf(fid1,'   Total Loss                                                 ');
mfprintf(fid1,'  %8.3f', sum(Lpij_temp)); mfprintf(fid1,'   %8.3f', sum(Lqij_temp));  mfprintf(fid1,'\n');
mfprintf(fid1,'-------------------------------------------------------------------------------------');
mfprintf(fid1 , '\n');
mfprintf(fid1,'#####################################################################################');
mfprintf(fid1 , '\n');
mclose(fid1);
mprintf('\n');
mprintf('The report is generated successfully');
mprintf('\n');
mprintf('Please find the report at %s ', fileid);


end

end

	
endfunction
