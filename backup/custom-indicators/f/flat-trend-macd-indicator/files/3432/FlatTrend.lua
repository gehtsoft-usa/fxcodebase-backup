-- Id: 1183

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1719

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
    indicator:name("Flat/Trend indicator");
    indicator:description("Flat/Trend indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("MACD_Fast", "MACD_Fast", "Period for fast MACD", 12);
    indicator.parameters:addInteger("MACD_Slow", "MACD_Slow", "Period for slow MACD", 26);
    indicator.parameters:addInteger("MACD_MA", "MACD_MA", "Period for signal MACD", 9);

    indicator.parameters:addColor("clrUP", "UP trend", "UP trend", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "DN trend", "DN trend", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrFL", "Flat", "Flat", core.rgb(0, 0, 255));
end

local first;
local source = nil;
local MACD_Fast;
local MACD_Slow;
local MACD_MA;
local MACD;
local buffUP=nil;
local buffDN=nil;
local buffFL=nil;

function Prepare(nameOnly)
    source = instance.source;
    MACD_Fast=instance.parameters.MACD_Fast;
    MACD_Slow=instance.parameters.MACD_Slow;
    MACD_MA=instance.parameters.MACD_MA;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MACD_Fast .. ", " .. instance.parameters.MACD_Slow .. ", " .. instance.parameters.MACD_MA .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    MACD = core.indicators:create("MACD", source, MACD_Fast, MACD_Slow, MACD_MA);
    first = MACD.DATA:first()+2;
    
	
    buffUP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.clrUP, first);
    buffDN = instance:addStream("DN", core.Bar, name .. ".DN", "DN", instance.parameters.clrDN, first);
    buffFL = instance:addStream("FL", core.Bar, name .. ".Flat", "Flat", instance.parameters.clrFL, first);
	
	buffUP:addLevel(1);	
	buffUP:addLevel(0);
	
	buffUP:setPrecision(math.max(2, source:getPrecision()));
	buffDN:setPrecision(math.max(2, source:getPrecision()));
	buffFL:setPrecision(math.max(2, source:getPrecision()));
end

function Update(period, mode)
    MACD:update(mode);
	
	buffUP[period]=0;
	buffDN[period]=0;
	buffFL[period]=0;
	
    if (period>first) then
     if MACD.SIGNAL[period]<MACD.MACD[period] and MACD.MACD[period]>0. then
      buffUP[period]=1;
     elseif MACD.SIGNAL[period]>MACD.MACD[period] and MACD.MACD[period]<0. then
      buffDN[period]=1;
     else
      buffFL[period]=1;
     end 
     
    end 
end

