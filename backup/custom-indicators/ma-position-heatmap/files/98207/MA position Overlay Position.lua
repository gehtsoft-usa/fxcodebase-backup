-- Id: 13461
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61569

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
    indicator:name("MA position Overlay Position");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("1. MA Calculation");	
	indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
	  
	indicator.parameters:addInteger("Period1", "1. MA Period ", "", 7, 1, 2000);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("2. MA Calculation");
	indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	
	indicator.parameters:addInteger("Period2", "2. MA Period", "", 14, 1, 2000);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("3. MA Calculation");
	indicator.parameters:addString("Price3", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price3", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price3", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price3", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price3","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price3", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price3", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price3", "WEIGHTED", "", "weighted");	
	indicator.parameters:addInteger("Period3", "3. MA Period", "", 21, 1, 2000);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("Show", "Show Moving Averages", "", true); 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Color of Up in Uptrend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDn", "Color of Down in Up Trend", "", core.rgb(0, 200, 0))
	indicator.parameters:addColor("DnUp", "Color of Up in Down Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Dn", "Color of  Down in Down Trend", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("NoUp", "Color of Up in Neutral Trend", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("NoDown", "Color of Down in Neutral Trend", "", core.rgb(0, 0, 200));
	
	indicator.parameters:addGroup("Line Style");
	indicator.parameters:addColor("Color1", "Color of 1. Line", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Color2", "Color of 2. Line", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Color3", "Color of 3. Line", "", core.rgb(128, 128, 128));
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil; 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local Number;
local Show;
local Out={};
local Indicator={};
local Period= {} ;
local Method={};
local Price={};
local Color={};
function Prepare(nameOnly)   
  
	Show = instance.parameters.Show;
	 
	
	One= instance.parameters.One;
	Two= instance.parameters.Two;
	 
	source = instance.source;
	
	local name = profile:id() .. "(" .. source:name() 	..  ")";
    instance:name(name); 
	
	if   (nameOnly) then
        return;
    end
	
	
	Number = instance:addInternalStream(0, 0);

 
	first=   source:first() ;
	for i= 1, 3 , 1 do 
	Price[i]= instance.parameters:getString("Price" .. i);
	Period[i]= instance.parameters:getInteger("Period" .. i);
	Method[i]= instance.parameters:getString("Method" .. i);
	Color[i]= instance.parameters:getColor("Color" .. i);
    assert(core.indicators:findIndicator(Method[i]) ~= nil, Method[i] .. " indicator must be installed");
	Indicator[i]=core.indicators:create(Method[i],  source[Price[i]] , Period[i]);
	first=math.max(first,Indicator[i].DATA:first());
	
		if Show then
		Out[i] = instance:addStream("OUT".. i, core.Line, name, i,  Color[i], Indicator[i].DATA:first());
		else
		Out[i]= instance:addInternalStream(0, 0);
		end
	end
	

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	 
	
	for i= 1, 3, 1 do
	Indicator[i]:update(mode);
	Out[i][period]=Indicator[i].DATA[period];
	end
	
	
		
   if period < first+1 then
   open:setColor(period, instance.parameters.No);
   return;
   end
   
	
	       Number[period]=Number[period-1];
		   
		   if  Indicator[1].DATA[period] > Indicator[3].DATA [period] then
		   Number[period]=1;
		   elseif Indicator[1].DATA[period] < Indicator[3].DATA [period] then
		   Number[period]= -1;
		   end
		   
		   if  Number[period] == 1 and    Indicator[1].DATA[period] <Indicator[2].DATA[period] then
		    Number[period]= 0;
		   elseif Number[period] == -1 and    Indicator[1].DATA[period]  > Indicator[2].DATA[period]  then
		    Number[period]= 0;	
		   end
	 
	

	
 
 
		
		              if Number[period]== 1   then 
							 if source.close[period]>source.open[period] then
							  open:setColor(period, instance.parameters.Up);	
							 else
							 open:setColor(period, instance.parameters.UpDn);	
							 end
					  elseif Number[period]== -1  then
							 if source.close[period]>source.open[period] then
							 open:setColor(period, instance.parameters.DnUp);	
							 else
							 open:setColor(period, instance.parameters.Dn);	
							 end
					  else
		                    if source.close[period]>source.open[period] then
							 open:setColor(period, instance.parameters.NoUp);	
							 else
							 open:setColor(period, instance.parameters.NoDown);	
							 end
					  end
					  
		
		 
		
 end


