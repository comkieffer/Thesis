%
%     C = VRFT1_dy(u,y,Md,B,W,k,optFilt)
% 
% Design a 1 d.o.f. linear controller so as to match the d(t) to y(t) output 
% sensitivity with the model reference Md (see figure below).
% 
% Inputs (mandatory)--------------------------------------------------------------
% u:  column vector (Nx1) that contains the INPUT data collected from the plant.
% y:  column vector (Nx1) that contains the OUTPUT data collected from the plant.
%     If y is a Nx2 matrix, the two columns contain the output data collected
%     in 2 different experiments (both experiments are made with the same input u(t); 
%     the two noise realizations must be uncorrelated).
% Md: tf-object that represents the discrete transfer function of the reference model.
%     The reference model Md(z) describes the desired closed loop behaviour from the 
%     signal d(t) to the output y(t) (output sensitivity).
% B:  column vector of tf-objects. The linear controller has the following structure: 
%     C(z,theta)= B'*theta, where B is a column vector of transfer functions, and 
%     theta is the vector of parameters.
% 
% Inputs (optional)---------------------------------------------------------------
% W:  tf-object of the weighting function W(z). If this parameter is empty
%     [], the function automatically sets W(z) = 1.
% k:  this parameter must be used only if the measured output y is noisy, and a 
%     single experiment is available; in this case this parameter sets the order 
%     of an ARX(k,k) model used to make an approximate model of the plant. Otherwise 
%     this parameter must be empty: [].
% optFilt: if this parameter is set to 'n', the optimal filter is disabled, and the 
%     filter L(z) is set to 1. If this parameter is empty ([]) the function uses 
%     the optimal VRFT filter.
%          
% Outputs -------------------------------------------------------------------------
% C:  tf-object, which represents the transfer function of the designed controller.
%      
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%                   ____________             ____________         d(t)
%                  |            |           |            |         |
% r(t)       e(t)  | C(z,theta) |   u(t)    |    P(z)    |         |  y(t)
% -------->O------>|            |---------->|            |-------->O------->           
%          |-      |____________|           |____________|             |
%          |                                                           |
%          |___________________________________________________________|
%          
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 


function [C] = VRFT1_dy(u,y,Md,B,W,k,optFilt)

% Passo 1: controllo della correttezza dei parametri inseriti

errore = 0; %inizializzazioni variabli

if( nargin ~= 7 )   %controllo numero argomenti passati alla funzione
    errore = 1;
    dispMsg(errore)
    return
end

[nRu nCu] = size(u);
[nRy nCy] = size(y);
[nRB nCB] = size(B);
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

if( isempty(Md) )   %controllo Md
    errore = 7;
    dispMsg(errore)
    return
elseif( Md.variable ~= 'z^-1')  %Md puo' essere inserito in qualunque forma (z,z^-1,q)
    Md.variable = 'z^-1';
end

if( isempty(B) )    %controllo B
    errore = 8;
    dispMsg(errore)
    return
elseif(nRB >= nCB)
    for h = 1:nRB   %per ogni elemento di B
        fdt = B(h,1);
        if(fdt.variable ~= 'z^-1')  %sistemo la variabile
            fdt.variable = 'z^-1';
            B(h,1) = fdt;
        end
        if(fdt.Ts ~= Md.Ts) %controllo il tempo di campionamento
            errore = 9;
            dispMsg(errore)
            return
        end
    end
end

if( isempty(W) )    %controllo W
    Tsampling = Md.Ts;
    W = tf([1],[1],Tsampling,'variable','z^-1');
elseif( ~isempty(W) )
    if( W.Ts ~= Md.Ts)
        errore = 10;
        dispMsg(errore)
        return
    end
    W.variable = 'z^-1';
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

if( isempty(optFilt) )
    Tsampling = Md.Ts;
    U = stima_U(u,Tsampling);
    L = minreal( (1 - Md)*Md*W*(inv(U)) );  %calcolo il filtro ottimo
else
    try
        if( optFilt == 'n')
        L = tf([1],[1],Md.Ts,'variable','z^-1');
        end
    catch   %FUNZIONALITA' NON DICHIARATA: permette di filtrare i dati con il filtro proposto
        L = optFilt;
        if(L.Ts ~= Md.Ts)
            errore = 12;
            dispMsg(errore)
            return
        else
            L.variable = 'z^-1';
        end
    end
end


% Passo 2: chiamo il VRFT_engine se non ci sono errori

[Cr, Cy, An, Fn] = vrft_engine(u,y1,y2,[],Md,[],B,[],L,k,'n');
C = Cy;

