%
%     [Cr,Cy] = VRFT2_ry_dy(u,y,Mr,Md,Br,By,Wr,Wd,fIA,k,optFilt)
% 
% Design a 2 d.o.f. linear controller so as to match the r(t) to y(t) transfer
% function and the d(t) to y(t) transfer function (see figure below).
% 
% Inputs (mandatory)--------------------------------------------------------------
% u:  column vector (Nx1) that contains the INPUT data collected from the plant.
% y:  column vector (Nx1) that contains the OUTPUT data collected from the plant.
%     If y is a Nx2 matrix, the two columns contain the output data collected
%     in 2 different experiments (both experiments are made with the same input u(t); 
%     the two noise realizations must be uncorrelated).
% Mr: tf-object that represents the discrete transfer function of the reference 
%     model. The reference model Mr(z) describes the desired closed loop behaviour 
%     from the reference r(t) to the output y(t). 
% Md: tf-object that represents the discrete transfer function of the reference model.
%     The reference model Md(z) describes the desired closed loop behaviour from the 
%     signal d(t) to the output y(t) (output sensitivity).
% Br: column vector of tf-objects. The linear controller Cr has the following structure: 
%     Cr(z,theta_r)= Br'*theta_r, where Br is a column vector of transfer functions, and 
%     theta_r is the vector of parameters.    
% By: column vector of tf-objects. The linear controller Cy has the following structure: 
%     Cy(z,theta_y)= By'*theta_y, where By is a column vector of transfer functions, and 
%     theta_y is the vector of parameters.    
%     
% Inputs (optional)----------------------------------------------------------------
% Wr: tf-object of the weighting function Wr(z). If this parameter is empty [],
%     the function automatically sets Wr(z) = 1.
% Wd: tf-object of the weighting function Wd(z). If this parameter is empty [],
%     the function automatically sets Wd(z) = 1.
% fIA: this parameter must be use only if an integral action is inclused in both control
%     structures Br and By. Otherwise this parameter must be empty: [].
%     If: fIA = 'y' the constraint on the fixed integral action is enabled in order to have 
%               null tracking error (Mr(1) = 1) and perfect disturbance rejection (Md(1) = 0);
%         fIA = 'n' the constraint on the fixed integral action is disabled (Mr(1) = Cr(1)/Cy(1)).
% k:  this parameter must be used only if the measured output y is noisy, and a single 
%     experiment is available; in this case this parameter sets the order of an ARX(k,k) model
%     used to make an approximate model of the plant. Otherwise this parameter must be empty: [].
% optFilt: if this parameter is set to 'n', the optimal filter is disabled, and the filters Lr(z) 
%     and Ly(z) are set to 1. If this parameter is empty ([]) the function uses the optimal VRFT filter.     
%          
% Outputs -------------------------------------------------------------------------
% Cr: tf-object, which represents the transfer function of the designed controller Cr(z,theta_r).
% Cy: tf-object, which represents the transfer function of the designed controller Cy(z,theta_y).
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
%          _______________                   _______________         d(t)
%         |               |                 |               |         |
% r(t)    | Cr(z,theta_r) |          u(t)   |     P(z)      |         |   y(t)
% ------->|               |------>O-------->|               |-------->O------->           
%         |_______________|       |-        |_______________|             |
%                                 |                                       |
%                                 |          _______________              |
%                                 |         |               |             |
%                                 |_________| Cy(z,theta_y) |_____________| 
%                                           |               |
%                                           |_______________|
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 


function [Cr,Cy] = VRFT2_ry_dy(u,y,Mr,Md,Br,By,Wr,Wy,fIA,k,optFilt)

% Passo 1: controllo della correttezza dei parametri inseriti

errore = 0; %inizializzazioni variabli

if( nargin ~= 11 )   %controllo numero argomenti passati alla funzione
    errore = 1;
    dispMsg(errore)
    return
end

[nRu nCu] = size(u);
[nRy nCy] = size(y);
[nRBr nCBr] = size(Br);
[nRBy nCBy] = size(By);
[nRk nCk] = size(k);

if( isempty(u) )    %controllo u
    errore = 2;
    dispMsg(errore)
    return
elseif( nRu == 1 & nCu >  nRu ) %correggo se u viene inserito come vettore riga
    u = u';
    [nRu nCu] = size(u);
elseif( nCu ~= 1)
    errore = 3;
    dispMsg(errore)
    return
end

if( isempty(y) )    %controllo y
    errore = 4;
    dispMsg(errore)
    return
elseif( nRy ~= nRu )    %controllo consistenza con u
    errore = 5;
    dispMsg(errore)
    return
elseif( nCy > 2)
    errore = 6;
    dispMsg(errore)
    return
elseif( nRy > nCy & nCy == 2)   %ricavo y1 e y2
    y1 = y(:,1);
    y2 = y(:,2);
elseif(nRy > nCy & nCy == 1)    %no noise / noise IV sim. experim.
    y1 = y;
    y2 = [];
end

if( isempty(Mr) | isempty(Md) )   %controllo Mr e Md
    errore = 7;
    dispMsg(errore)
    return
elseif(Mr.Ts ~= Md.Ts)
    errore = 17;
    dispMsg(errore)
    return
elseif( Mr.variable ~= 'z^-1' | Md.variable ~= 'z^-1')  %Mr e Md puo' essere inserito in qualunque forma (z,z^-1,q)
    Mr.variable = 'z^-1';
    Md.variable = 'z^-1';
end

if( isempty(Br) )    %controllo Br
    errore = 13;
    dispMsg(errore)
    return
elseif(nRBr >= nCBr)
    for h = 1:nRBr   %per ogni elemento di Br
        fdt = Br(h,1);
        if(fdt.variable ~= 'z^-1')  %sistemo la variabile
            fdt.variable = 'z^-1';
            Br(h,1) = fdt;
        end
        if(fdt.Ts ~= Mr.Ts) %controllo il tempo di campionamento
            errore = 14;
            dispMsg(errore)
        return
        end
    end
end

if( isempty(By) )    %controllo By
    errore = 15;
    dispMsg(errore)
    return
elseif(nRBy >= nCBy)
    for h = 1:nRBy   %per ogni elemento di By
        fdt = By(h,1);
        if(fdt.variable ~= 'z^-1')  %sistemo la variabile
            fdt.variable = 'z^-1';
            By(h,1) = fdt;
        end
        if(fdt.Ts ~= Mr.Ts) %controllo il tempo di campionamento
            errore = 16;
            dispMsg(errore)
        return
        end
    end
end

if( isempty(Wr) )    %controllo Wr
    Tsampling = Mr.Ts;
    Wr = tf([1],[1],Tsampling,'variable','z^-1');
elseif( ~isempty(Wr) )
    if( Wr.Ts ~= Mr.Ts)
        errore = 10;
        dispMsg(errore)
        return
    end
    Wr.variable = 'z^-1';
end

if( isempty(Wy) )    %controllo Wy
    Tsampling = Mr.Ts;
    Wy = tf([1],[1],Tsampling,'variable','z^-1');
elseif( ~isempty(Wy) )
    if( Wy.Ts ~= Mr.Ts)
        errore = 10;
        dispMsg(errore)
        return
    end
    Wy.variable = 'z^-1';
end

if( fIA ~= 'y' & fIA ~= 'Y' )   %controllo fIA
    fIA = 'n';
end
  
if( ~isempty(k) )   %controllo k
    if(nRk > nCk)   %sistemo eventuali vettori colonna
        k = k';
    end
    if(nCk > 2)
        errore = 11;
        dispMsg(errore)
        return
    elseif(nCk == 1)
        k = [k k];  %la funzione VRFT_engine si aspetta un vettore di due elementi
    end
end

if( isempty(optFilt) )  %controllo dei filtri
    Tsampling = Mr.Ts;
    U = stima_U(u,Tsampling);
    Lm = minreal( Mr*Md*Wr*(inv(U)) );      %calcolo i filtri ottimi
    Ls = minreal( (Md -1)*Md*Wy*(inv(U)) );
else
    try
        if( optFilt == 'n')
        Lm = tf([1],[1],Mr.Ts,'variable','z^-1');
        Ls = Lm;
        end
    catch   %FUNZIONALITA' NON DICHIARATA: permette di filtrare i dati con i filtri proposti --> optFilt = [Lm ; Ls]
        Lm = optFilt(1,1);
        Ls = optFilt(2,1);
        if(Lm.Ts ~= Mr.Ts | Ls.Ts ~= Mr.Ts)
            errore = 12;
            dispMsg(errore)
            return
        else
            Lm.variable = 'z^-1';
            Ls.variable = 'z^-1';
        end
    end
end    


% Passo 2: chiamo il VRFT_engine se non ci sono errori

[Cr, Cy, An, Fn] = vrft_engine(u,y1,y2,Mr,Md,Br,By,Lm,Ls,k,fIA);



