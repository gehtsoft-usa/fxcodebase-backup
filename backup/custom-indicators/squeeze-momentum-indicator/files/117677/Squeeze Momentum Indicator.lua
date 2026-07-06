-- Id: 20532
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65716

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Squeeze Momentum Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("lengthKC", "KC Length", "", 20, 2, 2000);
 
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
     indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
local first;
local source = nil;
local MA, Average,Raw;
local Alert;  
local close_local_up, local_ex_up;
local close_local_dn,local_ex_dn;
local val;
local lengthKC;
local Up,Down,Neutral;
-- Routine
 function Prepare(nameOnly)   
 
 
    lengthKC= instance.parameters.lengthKC;
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  lengthKC .. ")";
    instance:name(name); 
 
 
    Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;

    if   (nameOnly) then
        return;
    end

	close_local_up = instance:addInternalStream(0, 0);
	local_ex_up = instance:addInternalStream(0, 0);
    close_local_dn = instance:addInternalStream(0, 0);
	local_ex_dn = instance:addInternalStream(0, 0);
	val = instance:addInternalStream(0, 0); 
	MA= instance:addInternalStream(0, 0); 
	Average= instance:addInternalStream(0, 0);
	Raw = instance:addInternalStream(0, 0);
    source = instance.source;
    first=source:first()+lengthKC;
	
	 
   
 
	Alert = instance:addStream("Alert" , core.Bar, " Alert"," Alert",instance.parameters.Neutral, first+lengthKC);
    Alert:setPrecision(math.max(2, instance.source:getPrecision()));
 
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)

   

	
	
    if period < first then
	return;
	end
	 MA[period]=  mathex.avg(source.close, period-lengthKC+1, period);
	 Average[period] = ((source.high[period]+source.low[period])/2 + MA[period])/2;
	 
	Raw[period]= source.close[period]-Average[period];
	
	
	 if period < first+lengthKC then
	return;
	end
	
	val[period] =mathex.lreg (  Raw, period-lengthKC+1,period);
 
	
	
	if(val[period]>0 and val[period]<val[period-1] and val[period-1]>val[period-2]) then
	local_ex_up[period]= val[period]
	else
	local_ex_up[period]=local_ex_up[period-1]
    end	
	
	
     if val[period]>0 and val[period]<val[period-1] and val[period-1]>val[period-2] then
	 close_local_up[period]=source.close[period]
	 else
	 close_local_up[period]=close_local_up[period-1]
	 end
 
     if val[period]<0 and val[period]>val[period-1] and val[period-1]<val[period-2] then
	 local_ex_dn[period]=val[period]
	  else
	 local_ex_dn[period]=local_ex_dn[period-1] 
	 end
 
     if val[period]<0 and val[period]>val[period-1] and val[period-1]<val[period-2] then
	 close_local_dn[period]=source.close[period]
	 else
	 close_local_dn[period]=close_local_dn[period-1] 
	 end
	
	
	if (close_local_up[period]>close_local_up[period-1] and local_ex_up[period-1]>local_ex_up[period])  then
	dn_sg=true;
	else
	dn_sg=false;
	end
	
	
    if (close_local_dn[period]>close_local_dn[period-1] and local_ex_dn[period-1]>local_ex_dn[period]) then
	dn_sg_custom=true;
	else
	dn_sg_custom=false;
	end
	
     if (close_local_dn[period]<close_local_dn[period-1] and local_ex_dn[period-1]<local_ex_dn[period]) then
	 up_sg=true;
     else
	 up_sg=false;
	 end
     
	 if (close_local_up[period]<close_local_up[period-1] and local_ex_up[period-1]<local_ex_up[period]) then
	 up_sg_custom=true;
	 else
	 up_sg_custom=false;
	 end
	 

	
	
	if dn_sg or dn_sg_custom or up_sg or up_sg_custom then	
    Alert[period]=1;
	else
	Alert[period]=0;
	end
	
	if( val[period] >val[period-1]) then
	Alert:setColor(period, Up);
	elseif( val[period] < val[period-1]) then
	Alert:setColor(period, Down);
	else
	Alert:setColor(period, Neutral);
	end
				  
end

