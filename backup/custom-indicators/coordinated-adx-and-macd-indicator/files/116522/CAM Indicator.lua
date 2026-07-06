-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65462

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
    indicator:name("CAM Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("ADX Calculation");
    indicator.parameters:addInteger("ADX_Period", "Period","", 10);
	
	indicator.parameters:addGroup("MACD Calculation");
    indicator.parameters:addInteger("MACD_Fast", "Fast Period","", 12);
    indicator.parameters:addInteger("MACD_Slow", "Slow Period","", 26);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UP", "Up Color","", core.rgb(0,255,0));
	indicator.parameters:addColor("DN", "Down Color","", core.rgb(255,0,0));
	indicator.parameters:addColor("PB", "Pullback Color","", core.rgb(255,255,0));
	indicator.parameters:addColor("CT", "Countertrend Color","", core.rgb(0,0,255));
	indicator.parameters:addColor("NE", "Neutral Trend Color","", core.rgb(128,128,128));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 

local first;
local source = nil;
 
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local UP, DN, NE,PB,CT;
local MACD,ADX
-- Routine
function Prepare(nameOnly)  
    
	UP = instance.parameters.UP;
	DN = instance.parameters.DN;
	NE = instance.parameters.NE; 
	PB = instance.parameters.PB;
	CT = instance.parameters.CT;
	
    source = instance.source;
   
   
     local name = profile:id() .. "(" .. source:name() .. ", "  .. instance.parameters.ADX_Period .. ", " .. instance.parameters.MACD_Fast.. ", " .. instance.parameters.MACD_Slow .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    ADX = core.indicators:create("ADX", source, instance.parameters.ADX_Period);
	MACD = core.indicators:create("MACD", source.close, instance.parameters.MACD_Fast, instance.parameters.MACD_Slow);
    first = math.max( ADX.DATA:first(), MACD.DATA:first());	

  
    
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
end

-- Indicator calculation routine
function Update(period, mode)


    ADX:update(mode);
    MACD:update(mode);
	
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
     
	if period < first  or not source:hasData(period) then
	 open:setColor(period, Neutral);		
    return;
    end 
  
--CAM-UP				   
   if ADX.DATA[period] >= ADX.DATA[period-1] and (MACD.MACD[period]>MACD.MACD[period-1]) then
   open:setColor(period, UP);
    	
--CAM-PB
   elseif ADX.DATA[period] <= ADX.DATA[period-1]and   (MACD.MACD[period]<MACD.MACD[period-1]) then
      open:setColor(period, PB);
 	
--CAM-DN
   elseif ADX.DATA[period] >= ADX.DATA[period-1]and  (MACD.MACD[period]<MACD.MACD[period-1]) then
      open:setColor(period, DN);
   	
--CAM-CT
   elseif ADX.DATA[period] <= ADX.DATA[period-1]and  (MACD.MACD[period]>MACD.MACD[period-1]) then
      open:setColor(period, CT);
   else
       open:setColor(period, NE);  
   end		


       
		
		 
end

