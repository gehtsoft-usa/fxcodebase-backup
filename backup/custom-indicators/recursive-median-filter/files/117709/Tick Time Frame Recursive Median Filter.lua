-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65722

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Tick Time Frame Recursive Median Filter");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "EMA Period (in seconds)", "", 140, 2, 20000);
	 indicator.parameters:addInteger("Period2", "Median Period (in seconds)", "", 50, 2, 20000);
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period1,Period2; 
local first;
local source = nil;
 
local alpha; 
local RM;
local Second=1/86400;
local PI = 3.1415926;
-- Routine
 function Prepare(nameOnly)   
 
     Period1= instance.parameters.Period1;
	 Period2= instance.parameters.Period2;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Period1.. ", " ..  Period2  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

  
 
    source = instance.source;
	first=source:first() ;
	

 
	RM = instance:addStream("RM" , core.Line, " RM"," RM",instance.parameters.color, first);
	RM:setWidth(instance.parameters.width);
    RM:setStyle(instance.parameters.style);
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)

   
    if period < first then
	return;
	end
	
	
	
	local P1= core.findDate (source, source:date(period)- Second * Period1, false);
	local P2= core.findDate (source, source:date(period)- Second * Period2, false);

	if P1==-1
	or P1< first+1 
	or P2==-1
	or P2< first+1 
    then
    return;
    end 
	
	local angle;
	
	--Set EMA constant from LPPeriod input
    angle = 2 * PI / (period-P1);

	
    alpha = ( math.cos( angle ) + math.sin( angle ) - 1 )/math.cos( angle );
	
	
	local Median;
    --Recursive Median (EMA of a 5 bar Median filter)
	 Median = mathex.median_s(source, P2, period);

	 

	 RM[period] = alpha *Median  + (1 - alpha )*RM[period-1];
end


