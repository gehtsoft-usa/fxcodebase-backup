
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63877

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


-- initializes the indicator
function Init()
    indicator:name("Bill Williams Base Line");
    indicator:description("")
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "Label");
    indicator.parameters:addStringAlternative("Method", "Label", "Label" , "Label");
    indicator.parameters:addStringAlternative("Method", "Line", "Line" , "Line");
 

    indicator.parameters:addColor("color1", "Color of Buy ", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("color2", "Color of Sell ", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addInteger("Size", "Font Size","", 15);
end


local Buy, Sell;

-- indicator source
local source;
local first;
local Method;
local Size;
local Last1, Last2;
-- process parameters and prepare for calculations
function Prepare(nameOnly) 
    
    source  = instance.source;
	Method= instance.parameters.Method;
	Size= instance.parameters.Size;
    first=source:first();    

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	if Method== "Line" then
    Buy = instance:addStream("Buy", core.Line, name .. ".Buy", "Buy",  instance.parameters.color1, first);
	Buy:setWidth(instance.parameters.width1);
    Buy:setStyle(instance.parameters.style1);
    Sell = instance:addStream("Sell", core.Line, name .. ".Sell", "Sell", instance.parameters.color2, first);
	Sell:setWidth(instance.parameters.width2);
    Sell:setStyle(instance.parameters.style2);
    else
	Buy = instance:createTextOutput ("Buy", "Buy", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.color1, 0);
    Sell = instance:createTextOutput ("Sell", "Sell", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.color2, 0);
	end
	
	
end

-- Indicator calculation routine
function Update(period)
   
   Buy:setNoData(period);
   Sell:setNoData(period);
   
   local Index1, Index2=Find(period);
   
   if Index1== nil 
   or Index2 == nil 
   then
   return;
   end
 
   if Method== "Line" then
   Buy[period]=source.low[Index1];
   Sell[period]=source.high[Index2];
   else
   Buy:set(Index1, source.low[Index1], "\253", source.low[Index1]);
   Sell:set(Index2, source.high[Index2], "\253", source.high[Index2]);
   end
 
end


function Find (period)

local High=nil;
local Low=nil;

 for period=period, first, -1 do 
     
	 if High == nil and  source.high[period]< source.high[period-1]  then
	 High= period;
	 end
	 
	 if Low == nil and  source.low[period]> source.low[period-1]  then
	 Low= period;
	 end
  
	 if High~= nil and Low ~= nil then
	 break;
	 end 
 end
 
    return High, Low;
 
end
