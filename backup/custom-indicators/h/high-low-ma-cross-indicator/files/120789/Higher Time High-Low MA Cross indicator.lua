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
    indicator:name("Higher Time High-Low MA Cross indicator");
    indicator:description("Higher Time High-Low MA Cross indicator");
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
    
      indicator.parameters:addString("TF1", "Time frame of MA1", "", "m1");
      indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);	    
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
    
    indicator.parameters:addString("TF2", "Time frame of MA2", "", "m1");
    indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);	        
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
    
  	indicator.parameters:addString("TF3", "Time frame of MA3", "", "m1");
    indicator.parameters:setFlag("TF3", core.FLAG_PERIODS);	        
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
local Period={}
local Method={};
local Price={};

local MA={};
local MA1_Buff=nil;
local MA2_Buff=nil;
local MA3_Buff=nil;
local up=nil;
local down=nil;
local dayoffset, weekoffset;

local TF={};
local Source={};
local loading={};


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
	
	
	Period[1]=instance.parameters.Period1;
	Period[2]=instance.parameters.Period2;
	Period[3]=instance.parameters.Period3;
	
    
    Method[1]=instance.parameters.Method1;
	Method[2]=instance.parameters.Method2;
	Method[3]=instance.parameters.Method3;
 
 
	Price[1]=instance.parameters.Price1; 
	Price[2]=instance.parameters.Price2; 
	Price[3]=instance.parameters.Price3; 
	
	TF[1]=instance.parameters.TF1;
    TF[2]=instance.parameters.TF2;
	TF[3]=instance.parameters.TF3;
	
	
	 local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
	
	for i= 1 , 3, 1 do 
    s2, e2 = core.getcandle(TF[i], 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), i.. ". MA time frame must be equal to or bigger than the chart time frame!");
	end
	
	 dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
	
	local Test;		
	
	
	for i=1, 3, 1 do 
	
	Test = core.indicators:create("AVERAGES", TickSource(source, Price[i]), Method[i], Period[i], false);
	first= Test.DATA:first() ; 
	
	Source[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), First, 100*i, 100*i+1);
	loading[i]=true;
	
    MA[i] = core.indicators:create("AVERAGES", TickSource(Source[i], Price[i]), Method[i], Period[i], false);
	 
	end 
	
	
 
   
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
   
 
   
    for i= 1, 3, 1 do
    MA[i]:update(mode); 
    end	
	
	 local p1 =  Initialization(1, period);
	 local p2 =  Initialization(2, period);
	 local p3 =  Initialization(3, period);
     
	    if not p1 or not p2 or not p3 then
		return;
		end
	
	
	if not MA[1].DATA:hasData(p1)
	or  not MA[2].DATA:hasData(p2)
	or  not MA[3].DATA:hasData(p3)
	then
	return;
	end
	
    MA1_Buff[period]=MA[1].DATA[p1];
    MA2_Buff[period]=MA[2].DATA[p2];
    MA3_Buff[period]=MA[3].DATA[p3];
	
	
    if MA1_Buff[period-1]>MA2_Buff[period-1] and MA1_Buff[period]<MA2_Buff[period] then
     down:set(period, MA2_Buff[period], "\225");
    end
    if MA3_Buff[period-1]<MA2_Buff[period-1] and MA3_Buff[period]>MA2_Buff[period] then
     up:set(period, MA2_Buff[period], "\226");
    end
    
end

function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), dayoffset, weekoffset);

  
    if loading[id] or Source[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)



 for i= 1, 3 , 1 do 
    if cookie == 100*i then
        loading[i] = false;
    elseif cookie == 100*i+1 then
        loading[i] = true;
    end
	
end	



        if not loading[1] and not loading[2] and not loading[3] then
        instance:updateFrom(0);
		end
		
		
		 return core.ASYNC_REDRAW ;
end




