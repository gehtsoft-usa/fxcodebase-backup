-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64418

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
    indicator:name("ZIGZAG_PIVOT");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Depth", "Depth", "", 12, 1, 10000);
    indicator.parameters:addInteger("Deviation", "Deviation", "", 5, 1, 1000);
    indicator.parameters:addInteger("Backstep","Backstep", "", 3, 1, 10000);  
	indicator.parameters:addDouble("Delta","Delta (in pips)", "", 10); 

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BuyC", "Buy color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("SellC", "Sell color", "", core.rgb(255, 0, 0));
  
    indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local source;                    
local Indicator, Depth, Deviation, Backstep, Delta;
local Buy, Sell;
 function Prepare(nameOnly)   
    source = instance.source;
	Depth= instance.parameters.Depth;
	Deviation= instance.parameters.Deviation;
	Backstep= instance.parameters.Backstep;
	Delta= instance.parameters.Delta*source:pipSize();
	
	
	  local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	Indicator = core.indicators:create("ZIGZAG", source, Depth, Deviation, Backstep    );	 
	first=Indicator.DATA:first(); 

    
	
	
    Buy = instance:addStream("Buy", core.Line, name .. ".Buy", "Buy", instance.parameters.BuyC, first);
    Sell = instance:addStream("Sell", core.Line, name .. ".Sell", "Sell", instance.parameters.SellC, first);
    Buy:setWidth(instance.parameters.width);
    Buy:setStyle(instance.parameters.style);
    Sell:setWidth(instance.parameters.width);
    Sell:setStyle(instance.parameters.style);
end

 
-- the function which is called to calculate the period
function Update(period , mode) 

        if period < first+1 then
		return;
		end
		
		if Last~= source:serial(period) and period== source:size()-1 then
		Indicator:update(core.UpdateAll );
		Last= source:serial(period);
		return;
		else
		Indicator:update(mode );
		end	 
		
		local Top1, Bottom1, Top2, Bottom2= FindLast(period);
		
	   if Top1==nil or Bottom1 == nil 
	   or Top2==nil or Bottom2 == nil 
	   then
	   return;
	   end
	   
	   
	   for p=Top2, Top1, 1 do
	   Buy[p]=source.high[Top2]+Delta;	   
	   end
	   
	   for p=Bottom2, Bottom1, 1 do
	   Sell[p]=source.low[Bottom2]-Delta;	   
	   end
	   
	   if period == source:size()-1 then
	   
		   for p=Top1, period, 1 do
		   Buy[p]=source.high[Top1]+Delta;	   
		   end
		   
		   for p=Bottom1, period, 1 do
		   Sell[p]=source.low[Bottom1]-Delta;	   
		   end
		   
	   end
	   
	   

    
end

function FindLast(Start) 
 
 local Top1=nil;
 local Bottom1=nil;
 
local Top2=nil;
 local Bottom2=nil;
 
 for period= Start-1, first, -1 do 
  
  
    if Indicator.DATA[period]>  Indicator.DATA[period+1]
    and Indicator.DATA[period]>  Indicator.DATA[period-1]	 
	then
	
		if Top1==nil  then
		Top1=period;
		elseif Top2==nil  then
		Top2=period;
		end	
	end
	
	
	if Indicator.DATA[period]< Indicator.DATA[period+1]
    and Indicator.DATA[period]<  Indicator.DATA[period-1]
	then
	   if Bottom1== nil then
	   Bottom1=period;
	   elseif Bottom2== nil then
	   Bottom2=period;
	   end
	   
	end
	
    if Top1~=nil and Bottom1 ~= nil
	and Top2~=nil and Bottom2 ~= nil
	then
	break;
	end
	
 end
 
 return Top1, Bottom1, Top2, Bottom2;
 end
 