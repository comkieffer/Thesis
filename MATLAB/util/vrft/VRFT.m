%
% VRFT Toolbox - Version 1.0 - 29-Jul-2005
% ---------------------------------------------------------------------------------
% 
% VRFT1_ry:    designs a 1 degree of freedom (1 d.o.f.) linear controller so as to
%             match the r(t) to y(t) closed-loop transfer function with the model 
%             reference Mr (see Fig.1).
%             
% VRFT1_dy:    designs a 1 d.o.f. linear controller so as to match the d(t) to y(t) 
%             output sensitivity with the model reference Md (see Fig.1).
%             
% VRFT1_ry_ru: designs a 1 d.o.f. linear controller so as to match the r(t) to y(t) 
%             closed-loop transfer function with the model reference Mr and the
%             r(t) to u(t) input sensitivity with the model reference Mu (see Fig.1).
%              
% VRFT1_dy_du: designs a 1 d.o.f. linear controller so as to match the d(t) to y(t) 
%             closed-loop transfer function with the model reference Md and the
%             d(t) to u(t) input sensitivity with the model reference Mu (see Fig.1).
%             
% VRFT2_ry_dy: designs a 2 d.o.f. linear controller so as to match the r(t) to y(t)
%             transfer function and the d(t) to y(t) transfer function (see Fig.2).
%          
%
% Type "help Name_Function" for more details.
%             
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% - Figure 1: 1 DEGREE OF FREEDOM SCHEME
% 
%                   ____________             ____________         d(t)
%                  |            |           |            |         |
% r(t)       e(t)  | C(z,theta) |   u(t)    |    P(z)    |         |  y(t)
% -------->O------>|            |---------->|            |-------->O------->           
%          |-      |____________|           |____________|             |
%          |                                                           |
%          |___________________________________________________________|
%          
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% - Figure 2: 2 DEGREES OF FREEDOM SCHEME
% 
%          ______________                    ______________         d(t)
%         |              |                  |              |         |
% r(t)    | Cr(z,theta_r)|           u(t)   |     P(z)     |         |   y(t)
% ------->|              |------->O-------->|              |-------->O------->           
%         |______________|        |-        |______________|             |
%                                 |                                      |
%                                 |          ______________              |
%                                 |         |              |             |
%                                 |_________| Cy(z,theta_y)|_____________| 
%                                           |              |
%                                           |______________|
% 
% -----------------------------------------------------------------------------------
% 
% VRFT_GUI starts the Graphical User Interface for the VRFT toolbox.
% 
% -----------------------------------------------------------------------------------
% Main references:
%     - Campi M.C., A. Lecchini, S.M. Savaresi (2002). 
%       Virtual Reference Feedback Tuning: a Direct Method for the Design of Feedback Controllers. 
%       Automatica, Vol.38, n.8, pp.1337-1346.
%     - Campi M.C., Lecchini A., Savaresi S.M. (2003). 
%       An application of the Virtual Reference Feedback Tuning (VRFT) method to a benchmark active suspension system. 
%       European Journal of Control, Vol.9, pp.66-76. 
%     - Lecchini A., M.C. Campi, S.M. Savaresi (2002). 
%       Virtual reference feedback tuning for two degree of freedom controllers. 
%       International Journal on Adaptive Control and Signal Processing, vol.16, n.5, pp.355-371. 
%     - Guardabassi G.O., Savaresi S.M. (2000). 
%       Virtual Reference Direct Design method: an off-line approach to data-based control system design. 
%       IEEE Transactions on Automatic Control , Vol.45, n.5, pp.954-959. 
% -----------------------------------------------------------------------------------
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                                               LICENSE AGREEMENT 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% We (the licensee) understand that VRFT toolbox is supplied "as is", without expressed or implied warranty.
% We agree on the following:
% 
% - The licensers do not have any obligation to provide any maintenance or consulting help with respect 
%   to "VRFT toolbox".
% - The licensers neither have any responsibility for the correctness of systems designed using 
%   "VRFT toolbox", nor for the correctness of "VRFT toolbox" itself. 
% - We will never distribute or modify any part of the "VRFT toolbox" code without a written permission 
%   from Prof. Marco Campi (University of Brescia) or Prof. Sergio Savaresi (University of Milano). 
% - We will only use "VRFT toolbox" for non-profit research purposes. This implies that neither 
%   "VRFT toolbox" nor any part of its code should be used or modified for any commercial software product.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

