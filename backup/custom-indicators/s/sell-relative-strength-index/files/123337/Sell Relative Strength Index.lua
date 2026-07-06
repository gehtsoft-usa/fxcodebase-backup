-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67264

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
    indicator:name("Sell Relative Strength Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Length", "Length", "", 20, 1, 2000);
	indicator.parameters:addBoolean("Absolute", "Absolute", "", false);
  
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Line Color", "", core.rgb(255 ,128, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 0.38);
    indicator.parameters:addDouble("oversold","Oversold Level","", -0.38);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);


	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Length; 
local first;
local source = nil;
 
local srsi;  
local Value1;
local Value2; 
local Value3; 
local Absolute;
-- Routine
 function Prepare(nameOnly)   
 
    Length = instance.parameters.Length;
	Absolute = instance.parameters.Absolute;
	
	
	local Parameters= Length;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    first=source:first();
  
  
    Value1= instance:addInternalStream(0, 0);
	Value2= instance:addInternalStream(0, 0);
	Value3= instance:addInternalStream(0, 0);
	 
   
 
	srsi = instance:addStream("srsi" , core.Line, " srsi"," srsi",instance.parameters.Neutral, source:first()+Length);
	srsi:setWidth(instance.parameters.width);
    srsi:setStyle(instance.parameters.style);
    srsi:setPrecision(math.max(2, source:getPrecision()));
	
	srsi:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	srsi:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);   
    srsi:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    	
end

-- Indicator calculation routine
function Update(period ) 
	
    if period < source:first() then
	return;
	end  
	
	Value1[period] = (source.close[period] - source.open[period]) ;    
	
	if Absolute then
	Value1[period]=math.abs(Value1[period]);
	end
	
	Value2[period] =  source.high[period] - source.low[period]  ; 
	
	         if Value2[period] == 0 then
			 Value3[period] = 0;      
			 else       
			 Value3[period] = Value1[period]/Value2[period] ;  
			 end
	

	 if period < source:first()+Length then
	return;
	end   
	
     srsi[period]=mathex.sum(Value3, period-Length+1,period)/Length ;   
	 
	 
	 if srsi[period] >= -0.05 and srsi[period] <= 0.05 then 
	 srsi:setColor(period,   instance.parameters.Neutral);
	 elseif srsi[period] > 0 then
	 srsi:setColor(period, instance.parameters.Up);
	 elseif srsi[period] < 0 then
	 srsi:setColor(period, instance.parameters.Down);
     end
	 
	
				  
end

 
