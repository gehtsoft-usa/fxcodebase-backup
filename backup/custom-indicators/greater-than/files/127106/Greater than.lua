-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68603

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


function Init()
    indicator:name("Greater Candle");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addDouble("Size", "Size (%)","Size", 100);
	
    indicator.parameters:addGroup("Coloring");
 
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral", core.rgb(128, 128, 128));
	
     indicator.parameters:addColor("Greater", "Greater Color","Color", core.COLOR_UPCANDLE);
	indicator.parameters:addColor("Smaller", "Smaller Color","Color",  core.COLOR_DOWNCANDLE);
 
end

local first;
local source = nil;
local Greater,Smaller;
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local  Neutral;
local Range;

--STEP 2--
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Size = instance.parameters.Size;
  
	Neutral = instance.parameters.Neutral;
	
	Greater = instance.parameters.Greater;
	Smaller = instance.parameters.Smaller;
	 

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if (not (nameOnly)) then
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
	volume = instance:addStream("volume", core.Line, name, "volume", core.rgb(0, 0, 0), first)
	
    instance:createCandleGroup("ZONE", "ZONE", open, high, low, close, volume);
    end
	
	Range = instance:addInternalStream(0, 0);
end

--STEP 3--

function Update(period)

    high[period]= source.high[period];
	low[period]	= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
	volume[period]= source.volume[period]; 
	
	
	Range[period]=math.abs(source.open[period]-source.close[period]);
	
 
 
	
   if period < first  or not source:hasData(period) then  
	 open:setColor(period, Neutral);		
    return;
    end 
	
	 
	if Range[period] >  ((Range[period-1]/100)*Size)
	then
	open:setColor (period, Greater); 
	elseif Range[period] < ((Range[period-1]/100)*Size)
	then
	open:setColor (period, Smaller);
	else
	open:setColor(period, Neutral);
	end
 
 
end
