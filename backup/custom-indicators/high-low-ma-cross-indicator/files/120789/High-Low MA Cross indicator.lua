-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66601

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
    indicator:name("High-Low MA Cross indicator");
    indicator:description("High-Low MA Cross indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Period of MA1", "", 50);
    indicator.parameters:addString("Method1", "Method of MA1", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
    
 -- 	indicator.parameters:addString("TF1", "Time frame of MA1", "", "m1");
 --   indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);	    
      indicator.parameters:addString("Price1", "Price of MA1", "", "high");
      indicator.parameters:addStringAlternative("Price1", "close", "", "close");
      indicator.parameters:addStringAlternative("Price1", "open", "", "open");
      indicator.parameters:addStringAlternative("Price1", "high", "", "high");
      indicator.parameters:addStringAlternative("Price1", "low", "", "low");
      indicator.parameters:addStringAlternative("Price1", "median", "", "median");
      indicator.parameters:addStringAlternative("Price1", "typical", "", "typical");
      indicator.parameters:addStringAlternative("Price1", "weighted", "", "weighted");
    
------------------------------------------------------------------------------------------   
    
    indicator.parameters:addInteger("Period2", "Period of MA2", "", 3);
    indicator.parameters:addString("Method2", "Method of MA2", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");
    
   --indicator.parameters:addString("TF2", "Time frame of MA2", "", "m1");
   -- indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);	        
    indicator.parameters:addString("Price2", "Price of MA2", "", "close");
    indicator.parameters:addStringAlternative("Price2", "close", "", "close");
    indicator.parameters:addStringAlternative("Price2", "open", "", "open");
    indicator.parameters:addStringAlternative("Price2", "high", "", "high");
    indicator.parameters:addStringAlternative("Price2", "low", "", "low");
    indicator.parameters:addStringAlternative("Price2", "median", "", "median");
    indicator.parameters:addStringAlternative("Price2", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "weighted", "", "weighted");
    
-----------------------------------------------------------------------------------------

    indicator.parameters:addInteger("Period3", "Period of MA3", "", 50);
    indicator.parameters:addString("Method3", "Method of MA3", "", "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method3", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method3", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method3", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method3", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method3", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method3", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method3", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method3", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method3", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method3", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method3", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method3", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method3", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method3", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method3", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method3", "JSmooth", "", "JSmooth");
    
--	indicator.parameters:addString("TF3", "Time frame of MA3", "", "m1");
--    indicator.parameters:setFlag("TF3", core.FLAG_PERIODS);	        
    indicator.parameters:addString("Price3", "Price of MA3", "", "low");
    indicator.parameters:addStringAlternative("Price3", "close", "", "close");
    indicator.parameters:addStringAlternative("Price3", "open", "", "open");
    indicator.parameters:addStringAlternative("Price3", "high", "", "high");
    indicator.parameters:addStringAlternative("Price3", "low", "", "low");
    indicator.parameters:addStringAlternative("Price3", "median", "", "median");
    indicator.parameters:addStringAlternative("Price3", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price3", "weighted", "", "weighted");   

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MA1_Clr", "MA1 Color", "MA1 Color", core.rgb(0, 128, 255));
    indicator.parameters:addColor("MA2_Clr", "MA2 Color", "MA2 Color", core.rgb(0, 128, 0));
    indicator.parameters:addColor("MA3_Clr", "MA3 Color", "MA3 Color", core.rgb(255, 128, 255));    
    indicator.parameters:addColor("UP_Clr", "UP Color", "UP Color", core.rgb(0, 200, 100));
    indicator.parameters:addColor("DN_Clr", "DN Color", "DN Color", core.rgb(255, 0, 128));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 5, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("ArrowSize", "Arrow size", "Arrow size", 40);
end

local first;
local source = nil;
local Period1;
local Method1;
local Price1;
local Period2;
local Method2;
local Price2;
local Period3;
local Method3;
local Price3;
local MA1;
local MA2;
local MA3;
local MA1_Buff=nil;
local MA2_Buff=nil;
local MA3_Buff=nil;
local up=nil;
local down=nil;

function TickSource(source, PriceType)
 if PriceType=="close" then
  return source.close;
 elseif PriceType=="open" then
  return source.open;
 elseif PriceType=="high" then
  return source.high;
 elseif PriceType=="low" then
  return source.low;
 elseif PriceType=="median" then
  return source.median;
 elseif PriceType=="typical" then
  return source.typical;
 else
  return source.weighted;
 end 
end

function Prepare(nameOnly) 


    source = instance.source;
	
	
    Period1=instance.parameters.Period1;
    Method1=instance.parameters.Method1;
    Price1=instance.parameters.Price1;
    Period2=instance.parameters.Period2;
    Method2=instance.parameters.Method2;
    Price2=instance.parameters.Price2;
    Period3=instance.parameters.Period3;
    Method3=instance.parameters.Method3;
    Price3=instance.parameters.Price3;   
   
	
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Method1 .. ", " .. instance.parameters.Period2 .. ", " .. instance.parameters.Method2 .. instance.parameters.Period3 .. ", " .. instance.parameters.Method3 .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
	
    MA1 = core.indicators:create("AVERAGES", TickSource(source, Price1), Method1, Period1, false);
    MA2 = core.indicators:create("AVERAGES", TickSource(source, Price2), Method2, Period2, false);
    MA3 = core.indicators:create("AVERAGES", TickSource(source, Price3), Method3, Period3, false);    
	
	
	 first = math.max(MA1.DATA:first(), MA2.DATA:first(), MA3.DATA:first());
   
    MA1_Buff = instance:addStream("MA1_Buff", core.Line, name .. ".MA1", "MA1", instance.parameters.MA1_Clr, first);
    MA2_Buff = instance:addStream("MA2_Buff", core.Line, name .. ".MA2", "MA2", instance.parameters.MA2_Clr, first);
    MA3_Buff = instance:addStream("MA3_Buff", core.Line, name .. ".MA3", "MA3", instance.parameters.MA3_Clr, first);    
    MA1_Buff:setWidth(instance.parameters.widthLinReg);
    MA1_Buff:setStyle(instance.parameters.styleLinReg);
    MA2_Buff:setWidth(instance.parameters.widthLinReg);
    MA2_Buff:setStyle(instance.parameters.styleLinReg);
    MA3_Buff:setWidth(instance.parameters.widthLinReg);
    MA3_Buff:setStyle(instance.parameters.styleLinReg);    
    up = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.DN_Clr, 0);
    down = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.UP_Clr, 0); 
end


function Update(period, mode)
   if (period<first) then
   return;
   end
   
    MA1:update(mode);
    MA2:update(mode);
    MA3:update(mode);    
	
    MA1_Buff[period]=MA1.DATA[period];
    MA2_Buff[period]=MA2.DATA[period];
    MA3_Buff[period]=MA3.DATA[period];
	
	
    if MA1.DATA[period-1]>MA2.DATA[period-1] and MA1.DATA[period]<MA2.DATA[period] then
     down:set(period, MA2.DATA[period], "\225");
    end
    if MA3.DATA[period-1]<MA2.DATA[period-1] and MA3.DATA[period]>MA2.DATA[period] then
     up:set(period, MA2.DATA[period], "\226");
    end
    
end

