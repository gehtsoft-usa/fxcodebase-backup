-- Id: 21406
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66107

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Trend Confirmation Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 

	local Period={5,10,20,50,100,200};
    for i= 1, 6,1 do
    Add(i, Period[i]);
	end
	
		indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Buy Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
	
 
    indicator.parameters:addColor("color2", "Sell Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
	
   
   
    indicator.parameters:addColor("color3", "Delta Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
   
end


function Add(id, Period)


	indicator.parameters:addGroup(id.. ". MA Calculation");
	
	indicator.parameters:addString("Price"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addInteger("Period"..id, "Period", "", Period);

	indicator.parameters:addString("Method"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method"..id, "WMA", "WMA" , "WMA");
	
end


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Color;
local first;
local source = nil; 
 
local MA={};
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

  
	source = instance.source;
	first=source:first();
	
	
    for i= 1, 6, 1 do
    assert(core.indicators:findIndicator(instance.parameters:getString ("Method"..i)) ~= nil, instance.parameters:getString ("Method"..i) .. " indicator must be installed");
	MA[i]=  core.indicators:create(instance.parameters:getString ("Method"..i), source[instance.parameters:getString ("Price"..i)], instance.parameters:getInteger ("Period"..i));
	 first=math.max(first, MA[i].DATA:first());
	end
	
	Buy = instance:addStream("Buy" , core.Line, "Buy","Buy",instance.parameters.color1, first);
    Buy:setPrecision(math.max(2, instance.source:getPrecision()));
	Buy:setWidth(instance.parameters.width1);
    Buy:setStyle(instance.parameters.style1);
	
	Sell = instance:addStream("Sell" , core.Line, "Sell","Sell",instance.parameters.color2, first);
    Sell:setPrecision(math.max(2, instance.source:getPrecision()));
	Sell:setWidth(instance.parameters.width2);
    Sell:setStyle(instance.parameters.style2);	
	
	Delta = instance:addStream("Delta" , core.Line, "Delta","Delta",instance.parameters.color3, first);
    Delta:setPrecision(math.max(2, instance.source:getPrecision()));
	Delta:setWidth(instance.parameters.width3);
    Delta:setStyle(instance.parameters.style3);
		
end

-- Indicator calculation routine
function Update(period, mode)


if period < first then
return;
end

 Buy[period]=0;
 Sell[period]=0;

 
					 
 			
					for i = 1, 6, 1 do
					MA[i]:update(mode); 
				 
 		
		
		
					   if MA[i].DATA:hasData(period ) then
								if source.close[period ]> MA[i].DATA[period] then 
								Buy[period]=Buy[period]+1;
								elseif source.close[period ]< MA[i].DATA[period] then 
								Sell[period]=Sell[period]-1; 
								end
						end 
						
					
                    end	


 Delta[period]= Buy[period]	+Sell[period];				
		 
 end


