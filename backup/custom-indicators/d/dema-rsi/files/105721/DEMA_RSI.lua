-- Id: 15855

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63359

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

function Init()
    indicator:name("DEMA_RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("DEMAPeriod", "DEMA Period", "Period", 30);
	indicator.parameters:addInteger("RSIPeriod", "RSI Period", "Period", 30);
	indicator.parameters:addInteger("PriceShift", "Price Shift", "Period", 0);	
	indicator.parameters:addBoolean("Invert", "Invert", "Invert", true);

    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("clrUp", "Color of Up", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDn", "Color of Down)", "Color", core.rgb(255, 0, 0));
   indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

local first;
local source = nil;
local DEMAPeriod, RSIPeriod, Invert;
local Trend;
local Alpha;
local First, Second;
local PriceShift;
 function Prepare(nameOnly)   
    source = instance.source;
    DEMAPeriod=instance.parameters.DEMAPeriod;
	RSIPeriod=instance.parameters.RSIPeriod;
	PriceShift=instance.parameters.PriceShift;
	Invert=instance.parameters.Invert;
    Alpha= 2.0/(DEMAPeriod + 1.0);
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. DEMAPeriod .. ", " .. RSIPeriod .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    First = instance:addInternalStream(0, 0);
    Second= instance:addInternalStream(0, 0);
    RSI = core.indicators:create("RSI", source, RSIPeriod);
    first = RSI.DATA:first()+PriceShift;
   
    
		
		Trend = instance:addStream("DemaRsi", core.Line, name .. ".Dema Rsi", "Dema Rsi", instance.parameters.clrUp, first);
		Trend:setWidth(instance.parameters.width);
        Trend:setStyle(instance.parameters.style);
		if not Invert then
		Trend:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		Trend:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	    end
		
		Trend:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)	

	    RSI:update(mode);
		
		if period< first then
		return;
		end
		
		local Rsi=RSI.DATA[period-PriceShift]-50;
		  First[period]=(1.0-Alpha)*First[period-1] + Alpha*Rsi;
          Second[period]=(1.0-Alpha)*Second[period-1] + Alpha*First[period];
 
		 
 		local  DemaRsi = 2.0*First[period] - Second[period];
		 

        if(Invert) then
			DemaRsi = (1.0-math.exp(-0.2*DemaRsi)) / (1.0+math.exp(-0.2*DemaRsi));	
		else 
			DemaRsi = DemaRsi + 50.0; 
		end
		
		Trend[period]=DemaRsi;
		
		if(Trend[period] > Trend[period-1])then
		Trend:setColor(period, instance.parameters.clrUp);
		else
		Trend:setColor(period, instance.parameters.clrDn);
		end
		
			 
		 
		
		
end