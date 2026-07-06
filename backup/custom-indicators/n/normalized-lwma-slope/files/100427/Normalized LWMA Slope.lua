-- Id: 14176
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62214&p=100427#p100427

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

function Init()
    indicator:name("Normalized LWMA Slope");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
 
 
     indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("LWMA_Period", "LWMA Period", "", 56);
    indicator.parameters:addInteger("ATR_Period", "ATR Period", "", 100);
 

    indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("UpUp", "Color of Up in Up Trend", "UP color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DownUp", "Color of Down in Up Trend", "UP color", core.rgb(200, 0, 0));
	indicator.parameters:addColor("UpDown", "Color of Up in Down Trend", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DownDown", "Color of Down in Down Trend", "UP color", core.rgb(0, 200, 0));
	indicator.parameters:addColor("NeutralUp", "Color of Up in Neutral Trend", "Neutral Color", core.rgb(128, 128, 128));
    indicator.parameters:addColor("NeutralDown", "Color of Down in Neutral Trend", "Neutral Color", core.rgb(100, 100, 100));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
local first;
-- Streams block
local UpUp, UpDown,DownNeutral,UpNeutral, Label, DownUp, DownDown; 
local ATR_Period, LWMA_Period;
local source;
 
-- Routine
function Prepare(nameOnly)
  
	UpUp= instance.parameters.UpUp;
	DownUp= instance.parameters.DownUp;
	NeutralUp= instance.parameters.NeutralUp;
	UpDown= instance.parameters.UpDown;
	DownDown= instance.parameters.DownDown;
	NeutralDown= instance.parameters.NeutralDown;
    source = instance.source;	
	
	 
	LWMA_Period= instance.parameters.LWMA_Period;
	ATR_Period= instance.parameters.ATR_Period;
	local name = profile:id() .. "(" .. source:name() ..  ", " ..LWMA_Period .. ", " .. ATR_Period .. ")";
	instance:name(name); 
	if nameOnly then
		return;
	end

     LWMA = core.indicators:create("LWMA", source.close, LWMA_Period);
	 ATR = core.indicators:create("ATR", source , ATR_Period);
  

    first = LWMA.DATA:first() ;
	 	
	lwma = instance:addStream("NLWMAS", core.Bar, name, "NLWMAS", NeutralUp, first);
    lwma:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

-- Indicator calculation routine
function Update(period, mode)

		LWMA:update(mode);
		ATR:update(mode);
		
		if period < first then
		return;
		end

	lwma[period]=(LWMA.DATA[period]-LWMA.DATA[period-1])/ATR.DATA[period];
		
	if lwma[period]> 0 then		
        if lwma[period] > lwma[period-1] then 
        lwma:setColor(period, UpUp); 
		else
		lwma:setColor(period, DownUp); 
        end		
	else
	    if lwma[period] > lwma[period-1] then 
	    lwma:setColor(period, UpDown); 
		else
		lwma:setColor(period, DownDown); 
        end	
	end
	
		
end 