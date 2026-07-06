-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66099

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
    indicator:name("Boring Candle");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addDouble("Boring", "Boring Candle Percentage","", 50, 0, 100); 
	
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpColor", "Up Color","", core.COLOR_UPCANDLE);
	indicator.parameters:addColor("DownColor", "Downd Color","", core.COLOR_DOWNCANDLE );
    indicator.parameters:addColor("NeutralColor", "Neutral Color","", core.COLOR_LABEL  );
	indicator.parameters:addColor("BoringColor", "Boring Color","", core.rgb(255, 128, 0)); 
   
   
end 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local first;

local UpColor, DownColor, BoringColor, Boring,NeutralColor;
local source;

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	UpColor=instance.parameters.UpColor;
	DownColor=instance.parameters.DownColor;
	BoringColor=instance.parameters.BoringColor;
	Boring=instance.parameters.Boring;
	NeutralColor=instance.parameters.NeutralColor;
 
    source = instance.source;	
    first=source:first();
 
   open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
	
end



function Update(period )

     open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	

	
	
	         if period < first then
			open:setColor(period, NeutralColor);	
			return;
			end
			
			
			if  ( math.abs(source.open[period]-source.close[period])/math.abs(source.high[period]-source.low[period])) < (Boring/100 ) then 
			open:setColor(period, BoringColor);	
			elseif source.close[period]> source.open[period] then
			open:setColor(period, UpColor);	
			elseif source.close[period]< source.open[period] then
			open:setColor(period, DownColor);	
			end
			
end
 