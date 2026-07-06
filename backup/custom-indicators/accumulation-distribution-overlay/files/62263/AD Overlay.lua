-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=37403


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
    indicator:name("Accumulation/Distribution Overlay");
    indicator:description("Measures supply and demand by determining whether investors are generally accumulating (buying) or distributing (selling) a certain instrument by identifying divergences between the instrument price and volume flow.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method","", "CI");
    indicator.parameters:addStringAlternative("Method", "Classic","", "CS");
    indicator.parameters:addStringAlternative("Method", "Classic Incremental","", "CI");
    indicator.parameters:addStringAlternative("Method", "Trade Station","", "", "TS");

    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpUp", "Positive Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDn", "Positive Down color", "", core.rgb(0, 200, 0));	
	
	indicator.parameters:addColor("DnUp", "Negativ Up color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DnDn", "Negativ Down color", "", core.rgb(200, 0, 0));


	indicator.parameters:addColor("No", "Neutral color", "", core.rgb(0, 0, 255));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local AD, ad;
local Method;
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

-- Routine
function Prepare(nameOnly) 
    Method=instance.parameters.Method;  
    source = instance.source;
    ad = core.indicators:create("AD", source, Method);
     first = ad.DATA:first();
 
   local Label="";
   
   if Method == "CS" then
   Label="Classic";
   elseif Method == "CI" then
   Label="Classic Incremental";
   else
   Label="Trade Station";
   end
  
	 local name = profile:id() .. "(" .. source:name()  .. ", " .. Label .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

 
        AD = instance:addInternalStream(0, 0);
		
		open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
		high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
		low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
		close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
		instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    open:setColor(period, instance.parameters.No);		

    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	ad:update(mode);
	 
    if period < first or not source:hasData(period) then
	return;
	end
	
	 AD[period] = ad.DATA[period];    

	  
        if AD[period] > 0    then		
			if AD[period] > AD[period-1]    then
			open:setColor(period, instance.parameters.UpUp);
			else
			open:setColor(period, instance.parameters.UpDn);
			end
        elseif AD[period] < 0   then
			if AD[period] > AD[period-1]    then
		 	open:setColor(period, instance.parameters.DnUp);	
			else
			open:setColor(period, instance.parameters.DnDn);		
			end
		end
	 
end

