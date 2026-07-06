
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63324

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
    indicator:name("Signal Evaluation");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Evaluation Calculation");
    indicator.parameters:addString("Evaluation", "Evaluation Method", "", "Current");
    indicator.parameters:addStringAlternative("Evaluation", "Current Period", "", "Current");
    indicator.parameters:addStringAlternative("Evaluation", "Onward", "", "Onward");
    indicator.parameters:addInteger("EvaluationPeriod", "Onward Period", "", 10);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method", "VAMA", "", "VAMA");

    
    indicator.parameters:addInteger("Period", "Period", "", 20);
 
 
    indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("Color", "Label Color", "Color of Label", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Size", "Font Size", "Size", 15);
end

local first;
local source = nil;
local Period, Method;
local Color;
local Size;
local Up, Down;
local Total, Count;
local Up, Down, Neutral;
local Indicator;
local EvaluationPeriod, Evaluation;
function Prepare(nameOnly) 
    source = instance.source;
	
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Up= core.rgb(0, 255, 0);
	Down= core.rgb(255, 0, 0);
	Neutral= core.rgb(128, 128, 128);
    Color=instance.parameters.Color;
    Size=instance.parameters.Size;
	Period=instance.parameters.Period;
	Method=instance.parameters.Method;
	EvaluationPeriod=instance.parameters.EvaluationPeriod;
	Evaluation=instance.parameters.Evaluation;
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
	Indicator= core.indicators:create("AVERAGES", source, Method, Period, true, Neutral, Up, Down  );
    first = Indicator.DATA:first();
    
 
   
    instance:ownerDrawn(true);
    
 
	 
end

function Update(period, mode)

   Indicator:update(mode);
   if period < source:size()-1 then
   return;
   end
   
   Total=0;
   Count=0;
   
   for Index= first, source:size()-1, 1 do
   
   
           if Indicator.DATA:colorI(Index)== Up 
		   and Indicator.DATA:colorI(Index-1)~= Up
		   then 
		   Total=Total+1;
			   if source[Index]<source[period] and Evaluation =="Current" then
			   Count=Count+1;  
			   elseif source[Index]<source[math.min((Index+EvaluationPeriod), (source:size()-1))] and Evaluation =="Onward" then
			   Count=Count+1;
			   end
		   end
		   
		   if Indicator.DATA:colorI(Index)== Down 
		   and Indicator.DATA:colorI(Index-1)~= Down		   
		   then 
		   Total=Total+1;
               if source[Index]>source[period]  and Evaluation =="Current"  then
			    Count=Count+1; 
			   elseif source[Index]>source[math.min((Index+EvaluationPeriod), (source:size()-1))] and Evaluation =="Onward" then
			   Count=Count+1;
			   end
		   end
		   
		  
   end
   
   
end

local init=false;

function Draw(stage, context)
    if stage ~= 0 then
    return;
	end
	
        if not init then
             context:createFont (1, "Arial", Size, Size, 0)
            init = true;
        end
   
      text1="Number or Profitable Trades: " .. tostring(Count);
      text2="Number of Trades : " .. tostring(Total);

      width1, height1 = context:measureText (1, text1, 0);
      width2, height2 = context:measureText (1, text2, 0);
	 
      local MAX= math.max(width1,width2);
	 
      context:drawText (1, text1, Color, -1,  context:right ()-MAX, context:top (), context:right (), context:top ()+ height1, context.LEFT);
      context:drawText (1, text2, Color, -1, context:right ()-MAX, context:top ()+height1, context:right (), context:top () +height1*2, context.LEFT);           
        
    
end
