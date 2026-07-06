-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71880

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Trend continuation factor");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator); 
  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("n", "N", "", 20, 1, 2000);
    indicator.parameters:addInteger("t3_period", "t3_period MA", "", 5, 1, 2000);
    indicator.parameters:addDouble("b", "B", "", 0.618);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local n, t3_period, b; 
local Indicator;
local b2, b3,c1, c2, c3, c4,n1,w1, w2;   	
-- Routine
 function Prepare(nameOnly)   
 
    
	n=instance.parameters.n;
	t3_period=instance.parameters.t3_period;
	b=instance.parameters.b;
	source = instance.source
	
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  n.. "," ..  t3_period.. "," ..  b  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
--	Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first() ; 
	
 
   b2=b*b;
   b3=b2*b;
   c1=-b3;
   c2=(3*(b2+b3));
   c3=-3*(2*b2+b+b3);
   c4=(1+3*b+b3+3*b2);
   n1=t3_period; 
   n1=1 + 0.5*(n1-1);
   w1=2/(n1 + 1);
   w2=1 - w1; 
	
   
    Change_P = instance:addInternalStream(0, 0);
	CF_p = instance:addInternalStream(0, 0);
	Change_n= instance:addInternalStream(0, 0);
	CF_n= instance:addInternalStream(0, 0);
	
	e1= instance:addInternalStream(0, 0);
	e2= instance:addInternalStream(0, 0);
	e3= instance:addInternalStream(0, 0);
	e4= instance:addInternalStream(0, 0);
	e5= instance:addInternalStream(0, 0);
	e6= instance:addInternalStream(0, 0);	

	e12= instance:addInternalStream(0, 0);
	e22= instance:addInternalStream(0, 0);
	e32= instance:addInternalStream(0, 0);
	e42= instance:addInternalStream(0, 0);
	e52= instance:addInternalStream(0, 0);
	e62= instance:addInternalStream(0, 0);
	
    Line1 = instance:addStream("Line1", core.Line, name, "1. Line", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
 
 
    Line2 = instance:addStream("Line2", core.Line, name, "2. Line", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);	
end


function Update(period, mode)

	--  Indicator:update(mode); 

	 if period < first then
	 return;
	 end
	 
 
	--shift=limit - cnt;
 
         if(source[period] > source[period-1]) then
            Change_P[period]=source[period]- source[period-1];
            CF_p[period]= Change_P[period] + CF_p[period-1];
            Change_n[period]=0;
            CF_n[period]= 0;
           
         else
            Change_P[period]=0;
            CF_p[period]=0;
            Change_n[period] =source[period-1]- source[period];
            CF_n[period]=Change_n[period]+ CF_n[period-1];
         end
	 
	  
	if period < n then
	return;
	end
	 
      k_p=mathex.sum(Change_P, period-n+1, period)-mathex.sum(Change_n, period-n+1, period);
      k_n=mathex.sum(Change_n, period-n+1, period)-mathex.sum(CF_p, period-n+1, period);
      A1=k_p;
      e1[period]=w1*A1 + w2*e1[period-1];
      e2[period]=w1*e1[period] + w2*e2[period-1];
      e3[period]=w1*e2[period] + w2*e3[period-1];
      e4[period]=w1*e3[period] + w2*e4[period-1];
      e5[period]=w1*e4[period] + w2*e5[period-1];
      e6[period]=w1*e5[period] + w2*e6[period-1];
      Line1[period]=c1*e6[period] + c2*e5[period] + c3*e4[period] + c4*e3[period];
 
	  
	  
      A2=k_n;
      e12[period]=w1*A2 + w2*e12[period-1];
      e22[period]=w1*e12[period] + w2*e22[period-1];
      e32[period]=w1*e22[period] + w2*e32[period-1];
      e42[period]=w1*e32[period] + w2*e42[period-1];
      e52[period]=w1*e42[period] + w2*e52[period-1];
      e62[period]=w1*e52[period] + w2*e62[period-1];
      Line2[period]=c1*e62[period] + c2*e52[period] + c3*e42[period] + c4*e32[period];
 
end
 