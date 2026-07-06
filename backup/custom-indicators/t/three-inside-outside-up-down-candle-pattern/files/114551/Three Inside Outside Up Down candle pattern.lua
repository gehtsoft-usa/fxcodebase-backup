-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65037


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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Three Inside Outside Up Down candle pattern");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
    indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("S1", "Show Bullish Three Outside Signal", "", true);
	indicator.parameters:addBoolean("S2", "Show Bearish Three Outside Signal", "", true);
	indicator.parameters:addBoolean("S3", "Show Bullish Three Inside Signal", "", true);
	indicator.parameters:addBoolean("S4", "Show Bearish Three Inside Signal", "", true);
 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color_S1","Bullish Three Outside Signal Color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("Color_S2", "Bearish Three Outside Signal Color ", "", core.COLOR_DOWNCANDLE);
	indicator.parameters:addColor("Color_S3","Bullish Three Inside Signal Color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("Color_S4", "Bearish Three Inside Signal Color ", "", core.COLOR_DOWNCANDLE);
	
 
	
	indicator.parameters:addInteger("Size", "Size", "", 15);
 
     
end

local source;
local BullishThreeOutside, BearishThreeOutside;
local BullishThreeInside, BearishThreeInside;
local Size;
local S1, S2, S3, S4;

function Prepare(nameOnly) 

    source = instance.source;
	
	S1=instance.parameters.S1;
	S2=instance.parameters.S2;
	S3=instance.parameters.S3;
	S4=instance.parameters.S4;
	
	Size=instance.parameters.Size;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	if S1 then
    BullishThreeOutside = instance:createTextOutput ("BullishThreeOutside", "BullishThreeOutside", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Color_S1, 0);
	end
	
	if S2 then
    BearishThreeOutside = instance:createTextOutput ("BearishThreeOutside", "BearishThreeOutside", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Color_S2, 0);
    end
	
	if S3 then
    BullishThreeInside = instance:createTextOutput ("BullishThreeInside", "BullishThreeInside", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Color_S3, 0);
	end
	
	if S4 then
    BearishThreeInside = instance:createTextOutput ("BearishThreeInside", "BearishThreeInside", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Color_S4, 0);
    end
	
	
	
end

 
 
function Update(period, mode)
     if (period <= 3) then
	 return;
	 end
	
	 period = period-3;
	 if S1 then
	 BullishThreeOutside:setNoData(period);
	 end
	 if S2 then
	 BearishThreeOutside:setNoData(period);
	 end
	 if S3 then
	 BullishThreeInside:setNoData(period);
	 end
	 if S4 then
	 BearishThreeInside:setNoData(period);
	 end
	 
	 if source.close[period]< source.open[period]
	 and source.close[period+1] >  source.high[period]
	 and source.close[period+2] >  source.high[period+1]
	 and S1
	 then
	 BullishThreeOutside:set(period, source.low[period ], "\217", source.low[period ]);
 
	 elseif source.close[period]> source.open[period]
	 and source.close[period+1] <  source.low[period]
	 and source.close[period+2] < source.low[period+1]
	 and S2
	 then
	 BearishThreeOutside:set(period, source.high[period ], "\218", source.high[period ]);
	 end
	 
	 
	  if source.close[period]< source.open[period]
	  and source.high[period+1] <=  source.high[period]
	  and source.low[period+1] >=  source.low[period]
	 and source.close[period+2] >  source.high[period+1]
	 and S3
	 then
	 BullishThreeInside:set(period, source.low[period ], "\217", source.low[period ]);
 
	 elseif source.close[period]> source.open[period]
	 and source.high[period+1] <=  source.high[period]
	  and source.low[period+1] >=  source.low[period]
	 and source.close[period+2] < source.low[period+1]
	 and S4
	 then
	 BearishThreeInside:set(period, source.high[period ], "\218", source.high[period ]);
	 end
	 
 
end
