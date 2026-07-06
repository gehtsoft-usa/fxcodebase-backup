-- Id: 951

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1373

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Bollinger Band Waves");
    indicator:description("Bollinger Band Waves");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
		indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "Number of periods", 20);
	indicator.parameters:addInteger("Dev", "Number of standard deviations", "Number of standard deviations", 2);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");
	
    indicator.parameters:addColor("UPC", "Color for Bollinger Band UP Waves", "Color for Bollinger Band Up Waves.", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("DOWNC", "Color for Bollinger Band Down Waves", "Color for Bollinger Band Down Waves.", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("CENTRALC", "Color for Bollinger Band Central Line", "Color for Bollinger Band Central Line.", core.rgb(0, 0, 255));
		indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addInteger("Transparency", "Transparency", "", 50, 0, 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;

local UP = nil;
local DOWN=nil;
local CENTRALUP=nil;
local CENTRALDOWN=nil;
local Sold=nil
local Bought=nil;
local Transparency;

local BBP=nil;
local MVAofBBP=nil;
local BB=nil;

local N, Dev, Method;
local TL, BL, AL, TL1, BL1;

-- Routine
 function Prepare(nameOnly)   
 
  
    N = instance.parameters.N;
	Dev = instance.parameters.Dev;
	Method = instance.parameters.Method;
	Transparency = (100- instance.parameters.Transparency);
	
    source = instance.source;	
   

    local name = "Bollinger Band Waves" .. " (" .. N .. ", " .. Dev.. ", " .. Method .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
	
	TL = instance:addInternalStream(0,0);
    BL = instance:addInternalStream(0,0);	
    AL = instance:addInternalStream(0,0);
	BBP = instance:addInternalStream(0,0);
	
	TL1 = instance:addInternalStream(0,0);
    BL1 = instance:addInternalStream(0,0);

	MVAofBBP = core.indicators:create("MVA", BBP, N);
	
	 first= MVAofBBP.DATA:first();
    
    UP =  instance:addInternalStream(0, 0);
	DOWN =  instance:addInternalStream(0, 0);
	CENTRALUP =  instance:addInternalStream(0, 0);
	CENTRALDOWN = instance:addStream("CENTRALDOWN", core.Line, name .. "Central", "", instance.parameters.CENTRALC, first);
	CENTRALDOWN:setWidth(instance.parameters.width3);
    CENTRALDOWN:setStyle(instance.parameters.style3); 
	
	Sold = instance:addStream("SOLD", core.Line, name .. "Sold", "Over Sold", instance.parameters.UPC, first);
	Sold:setWidth(instance.parameters.width2);
    Sold:setStyle(instance.parameters.style2);
	 Bought= instance:addStream("BOUGHT", core.Line, name .. "Bought", "Over Bought", instance.parameters.DOWNC, first);
	Bought:setWidth(instance.parameters.width1);
    Bought:setStyle(instance.parameters.style1); 
	 
	
	instance:createChannelGroup("Top","Top" , UP, CENTRALUP, instance.parameters.UPC, Transparency);
	instance:createChannelGroup("Bottom","Bottom" , DOWN, CENTRALDOWN, instance.parameters.DOWNC,  Transparency);
	--instance:createChannelGroup (label, id, first, second, color, alpha, mode?)
	
	
	CENTRALDOWN:setPrecision(math.max(2, instance.source:getPrecision()));	
	Sold:setPrecision(math.max(2, instance.source:getPrecision()));	
	Bought:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period,mode) 
   
      if period < source:first() + N then
		return;
		end
	   
       BB(period);			
	   MVAofBBP:update(mode);	   
	   
	   if period < MVAofBBP.DATA:first() then
		return;
		end
					 
					if BBP[period] >   MVAofBBP.DATA[period] then
		     		UP[period] = BBP[period]; 
					DOWN[period] = MVAofBBP.DATA[period];
					CENTRALUP[period]=MVAofBBP.DATA[period];
					CENTRALDOWN[period]=MVAofBBP.DATA[period];
					Bought[period]=TL1[period];
					Sold[period]=BL1[period];
					elseif BBP[period] <   MVAofBBP.DATA[period] then
					DOWN[period] = BBP[period];
					UP[period] = MVAofBBP.DATA[period]; 
					CENTRALUP[period]=MVAofBBP.DATA[period];
					CENTRALDOWN[period]=MVAofBBP.DATA[period];
					Sold[period]=BL1[period];
					Bought[period]=TL1[period];
					end
    
end


function BB(period)
     
        local ml = mathex.avg(source, period-N+1, period);
        local d = core.stdev(source, period-N+1, period);

        TL[period] = ml + Dev * d;
        BL[period] = ml - Dev * d;
        AL[period] = ml;		
		
		BBP[period] = ((source[period] - BL[period]) / (TL[period] - BL[period])) * 100;
		
		local ml = mathex.avg(BBP, period-N+1, period);
        local d = core.stdev(BBP, period-N+1, period);

        TL1[period] = ml + Dev * d;
        BL1[period] = ml - Dev * d;
      

end
