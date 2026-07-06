-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74176

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Leading Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("l", "Moment len", "", 1, 1, 2000);
    indicator.parameters:addDouble("a1", "alfa 1", "", 0.25, 0, 2000);
    indicator.parameters:addDouble("a2", "alfa 2", "", 0.33, 0, 2000);	
    indicator.parameters:addDouble("a3", "EMA", "", 0.5, 0, 2000);	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Lead Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Trigger Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local l, a1, a2,a3; 
local first;
local source = nil;
 
local Oscillator;   

-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    l= instance.parameters.l;
    a1= instance.parameters.a1;
    a2 = instance.parameters.a2; 
    a3 = instance.parameters.a3; 	
	
	local Parameters= l ..  ", " .. a1 ..  ", " .. a2 ..  ", " .. a3;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
    le= instance:addInternalStream(0, 0);
    nl= instance:addInternalStream(0, 0);
	ema= instance:addInternalStream(0, 0); 
    
    first=source:first()+l;
	
	 
   
 
	lead = instance:addStream("lead" , core.Line, " lead"," lead",instance.parameters.color1, first);
	lead:setWidth(instance.parameters.width);
    lead:setStyle(instance.parameters.style);
    lead:setPrecision(math.max(2, source:getPrecision()));
	

	trigger = instance:addStream("trigger" , core.Line, " trigger"," trigger",instance.parameters.color2, first);
	trigger:setWidth(instance.parameters.width);
    trigger:setStyle(instance.parameters.style);
    trigger:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)

 
	
	
    if period <= first then
	return;
	end
	
     le[period]=2*source[period]+(a1-2)*source[period-l]+(1-a1)*le[period-1];
     nl[period]= a2*le[period]+(1-a2)* nl[period-1];
     ema[period]=a3*source[period]+a3* ema[period-1]; 
     lead[period]=nl[period]-ema[period];

	 
     trigger[period]=2*lead[period]-lead[period-2];
				  
end

--[[
//@version=2
// from Ehlers, John F. - Cybernetic Analysis for Stocks and Futures
study(title="Leading Oscillator",overlay=false)
pr=hl2
l=input(1,title="Moment len")
a1=input(.25,title="alfa 1",step=0.01)
a2=input(.33,title="alfa 2",step=0.01)


le=2*pr+(a1-2)*pr[l]+(1-a1)*nz(le[1])
nl=a2*le+(1-a2)*nz(nl[1])
ema=.5*pr+.5*nz(ema[1])
dif=nl-ema
ll=2*dif-dif[2]
plot(dif, color=silver,histbase=0, linewidth=2,transp=40,style=columns,title="lead")
plot(ll,title="trigger",color=lime,linewidth=1,transp=0)
]]
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--| USDT Donations                                                                                 |
--+------------------------------------------------+-----------------------------------------------+
--| Network                                        |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--| ERC20 (ETH Ethereum)                           |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--| TRC20 (Tron)                                   |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--| BEP20 (BSC BNB Smart Chain)                    |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--| Matic Polygon                                  |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--| SOL Solana                                     |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--| ARBITRUM Arbitrum One                          |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+