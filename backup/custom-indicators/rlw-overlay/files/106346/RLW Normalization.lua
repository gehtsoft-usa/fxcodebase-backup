-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63494

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("RLW Normalization");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 14, 2, 1000);
    indicator.parameters:addDouble("OB", "OB Level", "", -20);
	indicator.parameters:addDouble("OS", "OS Level", "", -80);
	
	
	indicator.parameters:addGroup("Normalization");	
	indicator.parameters:addInteger("NormalizationPeriod", "Normalization Period", "Period", 50);

	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("RLWColor", "RLW color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("OBColor", "OS color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("OSColor", "OS color", "", core.rgb(255, 0, 0));
	
 
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local OBColor, OSColor, RLWColor;
local OB,OS;
local first;
local source = nil;
local NormalizationPeriod; 
local min1=nil;
local max1=nil;
 

local Period;
local RLW;

function Prepare(nameOnly)

    
	OB = instance.parameters.OB;
	OS = instance.parameters.OS;
	OBColor= instance.parameters.OBColor;
	OSColor= instance.parameters.OSColor;
	RLWColor= instance.parameters.RLWColor;
	
    NormalizationPeriod= instance.parameters.NormalizationPeriod;	
    Period = instance.parameters.Period;
 
	source = instance.source;
	
	min1=nil;
    max1=nil; 
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize()..", "..Period ..", "..NormalizationPeriod 	..  ")";
    instance:name(name);
		
	if   (nameOnly) then
        return;
    end
	
	RLW=core.indicators:create("RLW",  source, Period);
    first=RLW.DATA:first()+NormalizationPeriod  ;
	
	
	instance:ownerDrawn(true);
 
	OBLevel = instance:addStream("OB", core.Line, name, "OB", OBColor, first);
    OSLevel = instance:addStream("OS", core.Line, name, "OS", OSColor, first);
    RLWLevel = instance:addStream("RLW", core.Line, name, "RLW", RLWColor, first);
end  

-- Indicator calculation routine
function Update(period, mode)
 
	
	RLW:update(mode);
	 
		
 end

function Draw(stage, context)

if stage~= 2 then
return;
end


min1= context:minPrice ();
max1= context:maxPrice ();

if min1== nil then
return;
end
 
 

       for period= math.max(source:first(), context:firstBar ()), math.min(source:size()-1, context:lastBar ()), 1 do
        min2,max2=mathex.minmax(RLW.DATA,period-NormalizationPeriod+1, period); 
	 
        RLWLevel[period] =  ((RLW.DATA[period] - min2)/ (max2-min2))*(max1-min1) +min1  ;
        OBLevel[period] =  ((100+OB)/ 100)*(max1-min1) +min1  ;
		OSLevel[period] =  ((100+OS)/ 100)*(max1-min1) +min1  ;
	   end	 		
end
 