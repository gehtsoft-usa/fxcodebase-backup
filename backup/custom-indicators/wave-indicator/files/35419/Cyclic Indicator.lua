-- Id: 6766
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=19657

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Cyclical indicator");
    indicator:description("Cyclical indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local Cumulative={};
-- Streams block
local A, B, C, D, E, F, G,H, I, J, K, L, M, N, O , P, Q,R, S, T, U, V, W, X, Y, Z, AI, AB, AC, AD, AE, AF,AG, AH; 
local Out={A, B, C, D, E, F, G,H, I, J, K, L, M, N, O , P, Q,R, S, T, U, V, W, X, Y, Z,  AB, AC, AD, AE, AF,AG, AH};
-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
      A =instance:addInternalStream(0, 0);	  
	  B =instance:addInternalStream(0, 0);
	  C =instance:addInternalStream(0, 0);
	  D =instance:addInternalStream(0, 0);
	  E =instance:addInternalStream(0, 0);
	  F =instance:addInternalStream(0, 0);
	  G =instance:addInternalStream(0, 0);
	  H  =instance:addInternalStream(0, 0);
	  I  =instance:addInternalStream(0, 0);
	  J =instance:addInternalStream(0, 0);
	  K =instance:addInternalStream(0, 0);
	  L =instance:addInternalStream(0, 0);
	  M =instance:addInternalStream(0, 0);
	  N =instance:addInternalStream(0, 0);
	  O =instance:addInternalStream(0, 0);
	  P =instance:addInternalStream(0, 0);
	  Q =instance:addInternalStream(0, 0);
	  R =instance:addInternalStream(0, 0);
	  S =instance:addInternalStream(0, 0);
	  T =instance:addInternalStream(0, 0);
	  U =instance:addInternalStream(0, 0);
	  V =instance:addInternalStream(0, 0);
	  W =instance:addInternalStream(0, 0);
	  X =instance:addInternalStream(0, 0);
	  Y =instance:addInternalStream(0, 0);
	  Z =instance:addInternalStream(0, 0);	 
	  AI =instance:addInternalStream(0, 0);
	   AB =instance:addInternalStream(0, 0);
	   AC =instance:addInternalStream(0, 0);
	   AD =instance:addInternalStream(0, 0);
	   AE =instance:addInternalStream(0, 0);
	   AF =instance:addInternalStream(0, 0);
	   AG =instance:addInternalStream(0, 0);
	   AH =instance:addInternalStream(0, 0);
	
        Cumulative["AF"] = instance:addStream("AF", core.Line, name .. ".AF", "AF", core.rgb(0, 255, 0), first+384);
    Cumulative["AF"]:setPrecision(math.max(2, instance.source:getPrecision()));
		  Cumulative["Y"] = instance:addStream("Y", core.Line, name .. ".Y", "Y", core.rgb(255, 0, 0), first+384);
    Cumulative["Y"]:setPrecision(math.max(2, instance.source:getPrecision()));
		   Cumulative["K"] = instance:addStream("K", core.Line, name .. ".K", "K", core.rgb(0, 0, 255), first+384);
    Cumulative["K"]:setPrecision(math.max(2, instance.source:getPrecision()));
		    Cumulative["R"] = instance:addStream("R", core.Line, name .. ".R", "R", core.rgb(128, 128, 128), first+384);
    Cumulative["R"]:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values



function Update(period)
    if period < first   then
	return;
	end
	
	A[period] = source[period];
	B[period] = source[period];
	C[period] = Calculate(period, 36, source);
	D[period] = Calculate(period, 72, source);
	E[period] = Calculate(period, 97, source);
	F[period] = Calculate(period, 384, source);
	
	if period < 23 then
	return;
	end
	
	G[period]  = mathex.avg (C, period-23, period);
    H[period] = G[period]-G[period-1];
    I[period]  = mathex.avg (H, period-23, period);
    J[period] = (I[period]-I[period-1]) * (-100);
	K[period]  = mathex.avg (J, period-23, period);
	L[period] = (K[period]-K[period-1]) * (10);
	
	
	if period < 55 then
	return;
	end
	N[period]  = mathex.avg (D, period-50, period);
    O[period] = N[period]-N[period-1];   
	
	if period < 57 then
	return;
	end
	P[period]  = mathex.avg (O, period-57, period);
	Q[period] = (P[period]-P[period-1]) * (-350);
	R[period]  = mathex.avg (Q, period-47, period);
	S[period] = (R[period]-R[period-1]) * (30);
   
	
	if period < 95 then
	return;
	end
	
	U[period]  = mathex.avg (E, period-95, period);
	V[period] = U[period]-U[period-1]; 
	W[period]  = mathex.avg (V, period-89, period);
	X[period] = (W[period]-W[period-1]) * (-1000);
	Y[period] = mathex.avg (X, period-95, period);
	Z[period] = (Y[period]-Y[period-1]) * (50);
	
	if period < 191 then
	return;
	end
	
	AB[period] = mathex.avg (Z, period-191, period);
	AC[period] = (AB[period]-AB[period-1]) ;
	AD[period] = mathex.avg (AC, period-191, period);
	AE[period] = (AD[period]-AD[period-1]) * (-6000);
	
	AF[period] = mathex.avg (AE, period-191, period);
	AG[period] = (AF[period]-AF[period-1]) * (100);
	
	AH[period] = (K[period]/8) + (R[period]/4) +(Y[period]/2) + (AF[period]);
	AF[period] = (AH[period]-AH[period-1]) * (100);
	
	
	      Cumulative["AF"][period] =AF[period];
		  Cumulative["Y"] [period]= Y[period];
		   Cumulative["K"][period] =K[period];
		    Cumulative["R"][period] =R[period];
 end
function  Calculate(period, PERIOD, Source) 

   local short=0;
   local long=0;
   
   local i;
   
   for i = period- PERIOD, period + PERIOD , 1 do
    
	if i >= first and i <= (source:size() -1 ) then  
	long = long + Source[period]; 
	else 
	    if i >= first and i > (source:size()-1) then
		long = long + Source[source:size()-1]; 
		elseif  i < first and i <= (source:size()-1) then
		long = long + Source[first]; 
		end
	end	
    
   end
   
      for i = period- (PERIOD/2), period + (PERIOD/2) , 1 do
    
	if i >= first and i <= (source:size() -1 ) then  
	short = short + Source[period]; 
	else 
	    if i >=first and i > (source:size()-1) then
		short = short + Source[source:size()-1]; 
		elseif  i < first and i <= (source:size()-1) then
		short = short + Source[first]; 
		end
	end	
    
   end
   
   return   ( short / (PERIOD/2)) - (long/PERIOD) ;

end
