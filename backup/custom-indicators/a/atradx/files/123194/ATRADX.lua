-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67237

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("ATRADX");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
 
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addDouble("Level", "Level", "", 5, 0, 2000);
    indicator.parameters:addInteger("ADX_Period", "ADX Period", "", 14, 2, 2000);
	indicator.parameters:addInteger("ADX_CUT", "ADX CUT Period", "", 20, 2, 2000);
    indicator.parameters:addInteger("ADX_H_CUT", "ADX H CUT Period", "", 60, 2, 2000); 
	
	
	indicator.parameters:addInteger("ATR_B", "ADX B Period", "", 14, 2, 2000); 
	indicator.parameters:addInteger("ADX_P", "ADX B CUT Period", "", 2, 2, 2000); 
	indicator.parameters:addInteger("ADX_ADJ", "ADX ADJ Period", "", 20, 2, 2000); 
 
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "ATRADX Color", "", core.rgb(128, 128, 0));
	indicator.parameters:addColor("color4", "ATRADX Line Color", "", core.rgb(255, 0, 255));
	indicator.parameters:addColor("color5", "ATRADX Line Color", "", core.rgb(255, 0, 255));
	
	
	indicator.parameters:addColor("color2", "ADX Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color3", "ADX Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local ADX_Period, ADX_CUT, ADX_H_CUT,ATR_B,ADX_P, ADX_ADJ;
local first;
local source = nil;
 
local Oscillator;  
local ADX,ATR1,ATR2;
local ADX_High_Cut;
local Level;
local ADX_Trend;
-- Routine
 function Prepare(nameOnly)    
 
    Level= instance.parameters.Level;
    ADX_Period= instance.parameters.ADX_Period;
	ADX_CUT= instance.parameters.ADX_CUT;
	ADX_H_CUT= instance.parameters.ADX_H_CUT;
	ATR_B= instance.parameters.ATR_B;
	ADX_P= instance.parameters.ADX_P;
	ADX_ADJ= instance.parameters.ADX_ADJ;
 
	ADX_High_Cut = ADX_H_CUT - ADX_CUT
	
	local Parameters= Level ..  ", " .. ADX_Period ..  ", " .. ADX_CUT ..  ", " .. ADX_H_CUT..  ", " ..ATR_B ..  ", " .. ADX_P ..  ", " .. ADX_ADJ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    ADX = core.indicators:create("ADX", source , ADX_Period);
	ATR1 = core.indicators:create("ATR", source , ADX_P);
	ATR2 = core.indicators:create("ATR", source , ADX_B);
    
    first=math.max(ADX.DATA:first(), ATR1.DATA:first(), ATR2.DATA:first());
	
	 
   
 
	ATRADX = instance:addStream("ATRADX" , core.Bar, " ATRADX"," ATRADX",instance.parameters.color1, first);
	ATRADX:setPrecision(math.max(2, source:getPrecision()));
	
	ADX_Trend= instance:addStream("ADX_Trend" , core.Line, " ADX"," ADX",instance.parameters.color2, first);
	ADX_Trend:setWidth(instance.parameters.width2);
    ADX_Trend:setStyle(instance.parameters.style2);
	ADX_Trend:setPrecision(math.max(2, source:getPrecision()));
	
	
	ADXR_Trend= instance:addStream("ADX_Trend" , core.Line, " ADX R"," ADX R",instance.parameters.color3, first);
	ADXR_Trend:setWidth(instance.parameters.width3);
    ADXR_Trend:setStyle(instance.parameters.style3);
	ADXR_Trend:setPrecision(math.max(2, source:getPrecision()));
   
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    ADX:update(mode);
	ATR1:update(mode);
	ATR2:update(mode);
    
	
	
    if period < ADX.DATA:first()+ADX_Period then
	return;
	end
	
	local ADXR = (ADX.DATA[period] + ADX.DATA[period-ADX_Period]) / 2
	
		
    ADX_Trend[period] = ADX.DATA[period]-ADX_CUT;
    ADXR_Trend[period] = ADXR -ADX_CUT;
	
	
	local ADX_Strength = ADX.DATA[period] - ADXR;
	
	if period < first then
	return;
	end
	
	
	ATRADX[period] = ((ATR1.DATA[period]-ATR2.DATA[period])/ATR2.DATA[period]*ADX_ADJ)*1/3+ADX_Strength*2/3;	


   
   
   if ADX_Trend[period]>0 and ADX_Trend[period]>ADXR_Trend[period] and ATRADX[period]>Level then
   ATRADX:setColor(period, instance.parameters.color4);
   
 
	elseif ADX_Trend[period]<0 and ADX_Trend[period]<ADXR_Trend[period] and ATRADX[period]<-Level then
	ATRADX:setColor(period, instance.parameters.color5);
	 
	else

    ATRADX:setColor(period, instance.parameters.color1);	
	end
end


 