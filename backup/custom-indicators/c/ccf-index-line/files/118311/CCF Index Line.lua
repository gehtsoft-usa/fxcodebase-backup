-- Id: 20759
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65853

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
    indicator:name("CCF Index Line");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	
 
	
	indicator.parameters:addGroup("Show Line");	 
    indicator.parameters:addBoolean("On"  .. 1, "USD", "", true);  
	indicator.parameters:addBoolean("On"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("On"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("On"  .. 4, "AUD", "", true);
	indicator.parameters:addBoolean("On"  .. 5, "NZD", "", true);
	indicator.parameters:addBoolean("On"  .. 6, "CHF", "", true);
	indicator.parameters:addBoolean("On"  .. 7, "CAD", "", true);
	indicator.parameters:addBoolean("On"  .. 8, "JPY", "", true);
	
	indicator.parameters:addGroup("Use In Calculation");	 
    indicator.parameters:addBoolean("Use"  .. 1, "USD", "", true); 
	indicator.parameters:addBoolean("Use"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("Use"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("Use"  .. 4, "AUD", "", true);
	indicator.parameters:addBoolean("Use"  .. 5, "NZD", "", true);
	indicator.parameters:addBoolean("Use"  .. 6, "CHF", "", true);
	indicator.parameters:addBoolean("Use"  .. 7, "CAD", "", true);
	indicator.parameters:addBoolean("Use"  .. 8, "JPY", "", true);

	
	indicator.parameters:addGroup("MA Parameters");
	
	 indicator.parameters:addString("TF" , "Time Frame ", "", "D1");
    indicator.parameters:setFlag("TF" , core.FLAG_PERIODS);
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Fast", "Fast Period", " " , 3);
    indicator.parameters:addInteger("Slow", "Slow Period", " " , 5); 
   
   indicator.parameters:addGroup("Style Parameters");
   
   local Pair = {"USD","EUR","GBP","AUD","NZD" ,"CHF" ,"CAD","JPY"}
    local Coloring= {core.rgb(255, 0, 0), core.rgb(255, 128, 0), core.rgb(128, 255, 0),   core.rgb(0, 255, 0), core.rgb(0, 255, 128), core.rgb(0, 128, 255),    core.rgb(0, 0, 255),    core.rgb(128, 128, 128)}
     local i;
	 for i=1, 8 , 1 do
	 AddStyle(i , Pair[i], Coloring[i]);
	 end
end




function AddStyle(id , Label, color)
indicator.parameters:addColor("color" ..id, Label ..  " Line Color","", color);
indicator.parameters:addInteger("width" .. id, "Line width", "", 1, 1, 5);
indicator.parameters:addInteger("style".. id, "Line style", "", core.LINE_SOLID);
indicator.parameters:setFlag("style".. id, core.FLAG_LINE_STYLE);
end

function ReleaseInstance()

	     core.host:execute("deleteFont", Bold);
 end  

 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block 

local first;
local source = nil;
local Method, Price, Slow, Fast;
-- Streams block
local Out={};
local Pair = {"USD","EUR","GBP","AUD","NZD" ,"CHF" ,"CAD","JPY"}
local On={};
local Use={};
local loading={};
local List={"AUD/USD","EUR/USD", "USD/CHF", "NZD/USD" ,"GBP/USD","USD/JPY","USD/CAD" };

local AUDUSD=1;
local EURUSD=2;
local USDCHF=3;
local NZDUSD=4;
local GBPUSD=5;
local USDJPY=6;
local USDCAD=7;

local  Count=7;
 
local SourceData={};
local pauto =  "(%a%a%a)/(%a%a%a)";
 
local Shift;
local Color={};
local Style={};
local Width={};
local SLOW={};
local FAST={};

local Bold, Size;
local id;
 
	local host;
	local offset;
	local weekoffset;
	 
 local Point={};
local Use={};
 
local TF; 
local Index={};
-- Routine
function Prepare(nameOnly)
    Method = instance.parameters.Method; 
	TF = instance.parameters.TF;  
	 
	 
	Price = instance.parameters.Price;
	Slow = instance.parameters.Slow;
	Fast = instance.parameters.Fast;
	local i,j;
	
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name().. ", " .. TF .. ", " .. Price  .. ", " .. Method .. ", " .. Slow .. ", " .. Fast.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end 
	
	 local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(TF, core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	
	local Flag=nil;
	for i = 1, 7, 1 do
	Flag = core.host:findTable("offers"):find("Instrument", List[i]);
	assert(InstrumentFlag == nil, "Please Subscribe to " ..  List[i] );    
	end
	
	 for j = 1, 7 , 1 do
	 Use[j] = instance.parameters:getBoolean("Use" .. j);	 
	 end
	
		   for j = 1, 8 , 1 do
		   On[j] = instance.parameters:getBoolean("On" .. j);	 
		   Width[j]= instance.parameters:getDouble("width" .. j);	
		   Style[j]= instance.parameters:getDouble("style" .. j);	
		   Color[j]= instance.parameters:getDouble("color" .. j);	
		    
		   end 
		 

	local Temp;
	 Temp1= core.indicators:create(Method, source, Slow);
	  Temp2= core.indicators:create(Method, source, Fast);
	 first = math.max(Temp1.DATA:first(),Temp2.DATA:first());
	
	for i = 1, Count, 1 do
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], TF, source:isBid(), math.min(300,first) , 200+i , 100+i);
	 loading[i] = true;  
	 
	  SLOW[i] = core.indicators:create(Method, SourceData[i][Price], Slow);
	  FAST[i] = core.indicators:create(Method, SourceData[i][Price], Fast);
	end
	for j = 1, 8 , 1 do
		if  On[j] then
		Index[j] = instance:addStream(Pair[j], core.Line, name, Pair[j], Color[j], first);
		Index[j]:setWidth(Width[j]);
        Index[j]:setStyle(Style[j]);
		else
		Index[j]= instance:addInternalStream(0, 0);
		end
		
	    Index[j]:setPrecision(math.max(2, instance.source:getPrecision()));
	end
end
 

 
 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
	
	
    local FLAG=false;  
	local i;
	
	for i = 1, Count, 1 do
	             if loading[i] then
				 FLAG= true; 
				 end
	end
	
	
		
	if FLAG then
	return;
	end
	
	core.host:execute ("setStatus",    "" );

	for i = 1, Count, 1 do			   
	   
				   SLOW[i]:update(mode);
                   FAST[i]:update(mode); 				   
				  		  
	end
	
 
     Calculate( period);		
	   
end	

 
function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
    if loading[id] or SourceData[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(SourceData[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	



		
		
		
function Calculate( period )
  
    local p={};
	local Flag=false;
	
	
	for i= 1 , 7 , 1 do	
    p[i] =Initialization(period,i);
     if  p[i] == false
	 or not SLOW[i].DATA:hasData(p[i])
	 or not FAST[i].DATA:hasData(p[i])
	 then
	 Flag=true;
	 end
	 
	end
	
	 if Flag then
     return;
	 end
	 
  
   for j=1, 8, 1 do
   Index[j][period]=0; 
   end

 
 
-- "USD","EUR","GBP","AUD","NZD" ,"CHF" ,"CAD","JPY"
 --USD
 
  if Use[2] then
  Index[1][period]=Index[1][period] + SLOW[EURUSD].DATA[p[EURUSD]]/ FAST[EURUSD].DATA[p[EURUSD]]-1;
  end
  if Use[3] then
  Index[1][period]=Index[1][period] + SLOW[GBPUSD].DATA[p[GBPUSD]]/ FAST[GBPUSD].DATA[p[GBPUSD]]-1;
  end  
  if Use[4] then
  Index[1][period]=Index[1][period] + SLOW[AUDUSD].DATA[p[AUDUSD]]/ FAST[AUDUSD].DATA[p[AUDUSD]]-1;
  end
  if Use[5] then
  Index[1][period]=Index[1][period] + SLOW[NZDUSD].DATA[p[NZDUSD]]/ FAST[NZDUSD].DATA[p[NZDUSD]]-1;
  end
  if Use[6] then
  Index[1][period]=Index[1][period] + FAST[USDCHF].DATA[p[USDCHF]]/ SLOW[USDCHF].DATA[p[USDCHF]]-1;
  end
  if Use[7] then
  Index[1][period]=Index[1][period] + FAST[USDCAD].DATA[p[USDCAD]]/ SLOW[USDCAD].DATA[p[USDCAD]]-1;
  end
  if Use[8] then
  Index[1][period]=Index[1][period] + FAST[USDJPY].DATA[p[USDJPY]]/ SLOW[USDJPY].DATA[p[USDJPY]]-1;
  end	 
	 
 --EUR
  if Use[1] then
  Index[2][period]=Index[2][period] + FAST[EURUSD].DATA[p[EURUSD]]   /  SLOW[EURUSD].DATA[p[EURUSD]] - 1;
  end
  if Use[3] then
  Index[2][period]=Index[2][period] + (FAST[EURUSD].DATA[p[EURUSD]] / FAST[GBPUSD].DATA[p[GBPUSD]]) /  ( SLOW[EURUSD].DATA[p[EURUSD]]/SLOW[GBPUSD].DATA[p[GBPUSD]]) - 1;
  end
  if Use[4] then
  Index[2][period]=Index[2][period]+ (FAST[EURUSD].DATA[p[EURUSD]] / FAST[AUDUSD].DATA[p[AUDUSD]]) /  ( SLOW[EURUSD].DATA[p[EURUSD]]/SLOW[AUDUSD].DATA[p[AUDUSD]]) - 1;
  end
  if Use[5] then
  Index[2][period]=Index[2][period]	+(FAST[EURUSD].DATA[p[EURUSD]] / FAST[NZDUSD].DATA[p[NZDUSD]]) /   ( SLOW[EURUSD].DATA[p[EURUSD]]/SLOW[NZDUSD].DATA[p[NZDUSD]]) - 1;
  end
  if Use[6] then
  Index[2][period]=Index[2][period] + (FAST[EURUSD].DATA[p[EURUSD]]*FAST[USDCHF].DATA[p[USDCHF]]) /   ( SLOW[EURUSD].DATA[p[EURUSD]]*SLOW[USDCHF].DATA[p[USDCHF]]) - 1;
  end
  if Use[7] then
  Index[2][period]=Index[2][period] +  (FAST[EURUSD].DATA[p[EURUSD]]*FAST[USDCAD].DATA[p[USDCAD]]) /  ( SLOW[EURUSD].DATA[p[EURUSD]]*SLOW[USDCAD].DATA[p[USDCAD]] ) - 1;
  end
  if Use[8] then  
  Index[2][period]=Index[2][period] + (FAST[EURUSD].DATA[p[EURUSD]]*FAST[USDJPY].DATA[p[USDJPY]]) /   ( SLOW[EURUSD].DATA[p[EURUSD]]*SLOW[USDJPY].DATA[p[USDJPY]] ) - 1;
  end
  
   --GBP
  if Use[1] then
  Index[3][period]=Index[3][period] + FAST[GBPUSD].DATA[p[GBPUSD]] / SLOW[GBPUSD].DATA[p[GBPUSD]] - 1;
  end
  if Use[2] then
  Index[3][period]=Index[3][period] + (SLOW[EURUSD].DATA[p[EURUSD]] / SLOW[GBPUSD].DATA[p[GBPUSD]]) / (FAST[EURUSD].DATA[p[EURUSD]] / FAST[GBPUSD].DATA[p[GBPUSD]]) - 1;
  end
  if Use[4] then
  Index[3][period]=Index[3][period] + (FAST[GBPUSD].DATA[p[GBPUSD]] / FAST[AUDUSD].DATA[p[AUDUSD]]) / (SLOW[GBPUSD].DATA[p[GBPUSD]] / SLOW[AUDUSD].DATA[p[AUDUSD]]) - 1;
  end
  if Use[5] then
  Index[3][period]=Index[3][period] + (FAST[GBPUSD].DATA[p[GBPUSD]] / FAST[NZDUSD].DATA[p[NZDUSD]]) / (SLOW[GBPUSD].DATA[p[GBPUSD]] / SLOW[NZDUSD].DATA[p[NZDUSD]]) - 1;
  end
  if Use[6] then
  Index[3][period]=Index[3][period] +(FAST[GBPUSD].DATA[p[GBPUSD]]*FAST[USDCHF].DATA[p[USDCHF]]) / (SLOW[GBPUSD].DATA[p[GBPUSD]]*SLOW[USDCHF].DATA[p[USDCHF]]) - 1;
  end  
  if Use[7] then
  Index[3][period]=Index[3][period] + (FAST[GBPUSD].DATA[p[GBPUSD]]*FAST[USDCAD].DATA[p[USDCAD]]) /  (SLOW[GBPUSD].DATA[p[GBPUSD]]*SLOW[USDCAD].DATA[p[USDCAD]] ) - 1;
  end
  if Use[8] then
  Index[3][period]=Index[3][period] +(FAST[GBPUSD].DATA[p[GBPUSD]]*FAST[USDJPY].DATA[p[USDJPY]]) /  (SLOW[GBPUSD].DATA[p[GBPUSD]]*SLOW[USDJPY].DATA[p[USDJPY]] ) - 1;
  end
  
   --AUD
  if Use[1] then
  Index[4][period]=Index[4][period] + FAST[AUDUSD].DATA[p[AUDUSD]] / SLOW[AUDUSD].DATA[p[AUDUSD]] - 1;
  end
  if Use[2] then
  Index[4][period]=Index[4][period] +(SLOW[EURUSD].DATA[p[EURUSD]] / SLOW[AUDUSD].DATA[p[AUDUSD]]) /  (FAST[EURUSD].DATA[p[EURUSD]] / FAST[AUDUSD].DATA[p[AUDUSD]]) - 1;
  end
  if Use[4] then
  Index[4][period]=Index[4][period] + (SLOW[GBPUSD].DATA[p[GBPUSD]] / SLOW[AUDUSD].DATA[p[AUDUSD]]) /  (FAST[GBPUSD].DATA[p[GBPUSD]] / FAST[AUDUSD].DATA[p[AUDUSD]]) - 1;
  end
  if Use[5] then
  Index[4][period]=Index[4][period]	+(FAST[AUDUSD].DATA[p[AUDUSD]]/FAST[NZDUSD].DATA[p[NZDUSD]]) /  (SLOW[AUDUSD].DATA[p[AUDUSD]] / SLOW[NZDUSD].DATA[p[NZDUSD]]) - 1;
  end
  if Use[6] then
  Index[4][period]=Index[4][period] + (FAST[AUDUSD].DATA[p[AUDUSD]]*FAST[USDCHF].DATA[p[USDCHF]]) /  (SLOW[AUDUSD].DATA[p[AUDUSD]]*SLOW[USDCHF].DATA[p[USDCHF]] ) - 1;
  end  
  if Use[7] then
  Index[4][period]=Index[4][period]+ (FAST[AUDUSD].DATA[p[AUDUSD]]*FAST[USDCAD].DATA[p[USDCAD]]) /  (SLOW[AUDUSD].DATA[p[AUDUSD]]*SLOW[USDCAD].DATA[p[USDCAD]] ) - 1;
  end
  if Use[8] then
  Index[4][period]=Index[4][period] +(FAST[AUDUSD].DATA[p[AUDUSD]]*FAST[USDJPY].DATA[p[USDJPY]]) /  (SLOW[AUDUSD].DATA[p[AUDUSD]]*SLOW[USDJPY].DATA[p[USDJPY]] ) - 1;
  end

  
  
   --NZD
  if Use[1] then
  Index[5][period]=Index[5][period] + FAST[NZDUSD].DATA[p[NZDUSD]] / SLOW[NZDUSD].DATA[p[NZDUSD]] - 1;
  end
  if Use[2] then
  Index[5][period]=Index[5][period] +  (SLOW[EURUSD].DATA[p[EURUSD]] / SLOW[NZDUSD].DATA[p[NZDUSD]]) /  (FAST[EURUSD].DATA[p[EURUSD]]/FAST[NZDUSD].DATA[p[NZDUSD]]) - 1;
  end
  if Use[3] then
  Index[5][period]=Index[5][period] + (SLOW[GBPUSD].DATA[p[GBPUSD]] / SLOW[NZDUSD].DATA[p[NZDUSD]]) /   (FAST[GBPUSD].DATA[p[GBPUSD]] / FAST[NZDUSD].DATA[p[NZDUSD]]) - 1;
  end
  if Use[4] then
  Index[5][period]=Index[5][period]	+ (SLOW[AUDUSD].DATA[p[AUDUSD]] / SLOW[NZDUSD].DATA[p[NZDUSD]]) /  (FAST[AUDUSD].DATA[p[AUDUSD]] / FAST[NZDUSD].DATA[p[NZDUSD]]) - 1;
  end
  if Use[6] then
  Index[5][period]=Index[5][period] + (FAST[NZDUSD].DATA[p[NZDUSD]]*FAST[USDCHF].DATA[p[USDCHF]]) /  (SLOW[NZDUSD].DATA[p[NZDUSD]]*SLOW[USDCHF].DATA[p[USDCHF]] ) - 1;
  end
  if Use[7] then
  Index[5][period]=Index[5][period] + (FAST[NZDUSD].DATA[p[NZDUSD]]*FAST[USDCAD].DATA[p[USDCAD]]) /  (SLOW[NZDUSD].DATA[p[NZDUSD]]*SLOW[USDCAD].DATA[p[USDCAD]] ) - 1;
  end
  if Use[8] then
  Index[5][period]=Index[5][period] + (FAST[NZDUSD].DATA[p[NZDUSD]]*FAST[USDJPY].DATA[p[USDJPY]]) /  (SLOW[NZDUSD].DATA[p[NZDUSD]]*SLOW[USDJPY].DATA[p[USDJPY]] ) - 1;
  end

  
   --CAD
  if Use[1] then 
  Index[6][period]=Index[6][period] + SLOW[USDCAD].DATA[p[USDCAD]]  / FAST[USDCAD].DATA[p[USDCAD]] - 1;
  end
  if Use[2] then 
  Index[6][period]=Index[6][period] + (SLOW[EURUSD].DATA[p[EURUSD]]*SLOW[USDCAD].DATA[p[USDCAD]] ) /  (FAST[EURUSD].DATA[p[EURUSD]]*FAST[USDCAD].DATA[p[USDCAD]]) - 1;
  end
  if Use[3] then
  Index[6][period]=Index[6][period]  +  (SLOW[GBPUSD].DATA[p[GBPUSD]]*SLOW[USDCAD].DATA[p[USDCAD]] ) /  (FAST[GBPUSD].DATA[p[GBPUSD]]*FAST[USDCAD].DATA[p[USDCAD]]) - 1;
  end
  if Use[4] then
  Index[6][period]=Index[6][period]	+  (SLOW[AUDUSD].DATA[p[AUDUSD]]*SLOW[USDCAD].DATA[p[USDCAD]] ) /  (FAST[AUDUSD].DATA[p[AUDUSD]]*FAST[USDCAD].DATA[p[USDCAD]]) - 1;
  end
  if Use[5] then
  Index[6][period]=Index[6][period] +   (SLOW[NZDUSD].DATA[p[NZDUSD]]*SLOW[USDCAD].DATA[p[USDCAD]] ) /  (FAST[NZDUSD].DATA[p[NZDUSD]]*FAST[USDCAD].DATA[p[USDCAD]]) - 1;
  end
  if Use[7] then 
 Index[6][period]=Index[6][period] +   (FAST[USDCHF].DATA[p[USDCHF]] / FAST[USDCAD].DATA[p[USDCAD]]) /  (SLOW[USDCHF].DATA[p[USDCHF]]  / SLOW[USDCAD].DATA[p[USDCAD]] ) - 1;
 end
  if Use[8] then
  Index[6][period]=Index[6][period] + (FAST[USDJPY].DATA[p[USDJPY]] / FAST[USDCAD].DATA[p[USDCAD]]) /  (SLOW[USDJPY].DATA[p[USDJPY]]  / SLOW[USDCAD].DATA[p[USDCAD]] ) - 1;
  end

  
  
   --CHF
  if Use[1] then  
  Index[7][period]=Index[7][period]  + SLOW[USDCHF].DATA[p[USDCHF]]  / FAST[USDCHF].DATA[p[USDCHF]] - 1;
  end
  if Use[2] then
  Index[7][period]=Index[7][period] + (SLOW[EURUSD].DATA[p[EURUSD]]*SLOW[USDCHF].DATA[p[USDCHF]] ) /  (FAST[EURUSD].DATA[p[EURUSD]]*FAST[USDCHF].DATA[p[USDCHF]]) - 1;
  end
  if Use[3] then
  Index[7][period]=Index[7][period] +  (SLOW[GBPUSD].DATA[p[GBPUSD]]*SLOW[USDCHF].DATA[p[USDCHF]] ) /   (FAST[GBPUSD].DATA[p[GBPUSD]]*FAST[USDCHF].DATA[p[USDCHF]]) - 1;
  end
  if Use[4] then
  Index[7][period]=Index[7][period]	+  (SLOW[AUDUSD].DATA[p[AUDUSD]]*SLOW[USDCHF].DATA[p[USDCHF]] ) /   (FAST[AUDUSD].DATA[p[AUDUSD]]*FAST[USDCHF].DATA[p[USDCHF]]) - 1;
  end
  if Use[5] then
  Index[7][period]=Index[7][period]  +  (SLOW[NZDUSD].DATA[p[NZDUSD]]*SLOW[USDCHF].DATA[p[USDCHF]] ) /  ( FAST[NZDUSD].DATA[p[NZDUSD]]*FAST[USDCHF].DATA[p[USDCHF]]) - 1;
  end
  if Use[6] then
  Index[7][period]=Index[7][period]  + (SLOW[USDCHF].DATA[p[USDCHF]]  / SLOW[USDCAD].DATA[p[USDCAD]] ) /   (FAST[USDCHF].DATA[p[USDCHF]] / FAST[USDCAD].DATA[p[USDCAD]]) - 1;
  end
  if Use[8] then  
  Index[7][period]=Index[7][period] +  (FAST[USDJPY].DATA[p[USDJPY]] / FAST[USDCHF].DATA[p[USDCHF]]) /   (SLOW[USDJPY].DATA[p[USDJPY]]  / SLOW[USDCHF].DATA[p[USDCHF]] ) - 1;
  end
  
   --JPY
  if Use[1] then 
  Index[8][period]=Index[8][period] +SLOW[USDJPY].DATA[p[USDJPY]]  / FAST[USDJPY].DATA[p[USDJPY]] - 1;
  end
  if Use[2] then
  Index[8][period]=Index[8][period] +(SLOW[EURUSD].DATA[p[EURUSD]]*SLOW[USDJPY].DATA[p[USDJPY]] ) /  (FAST[EURUSD].DATA[p[EURUSD]]*FAST[USDJPY].DATA[p[USDJPY]]) - 1;
  end
  if Use[3] then
  Index[8][period]=Index[8][period] + (SLOW[GBPUSD].DATA[p[GBPUSD]]*SLOW[USDJPY].DATA[p[USDJPY]] ) /  (FAST[GBPUSD].DATA[p[GBPUSD]]*FAST[USDJPY].DATA[p[USDJPY]]) - 1;
  end
  if Use[4] then
  Index[8][period]=Index[8][period]	+ (SLOW[AUDUSD].DATA[p[AUDUSD]]*SLOW[USDJPY].DATA[p[USDJPY]] ) /   (FAST[AUDUSD].DATA[p[AUDUSD]]*FAST[USDJPY].DATA[p[USDJPY]]) - 1;
  end
  if Use[5] then
  Index[8][period]=Index[8][period] + (SLOW[NZDUSD].DATA[p[NZDUSD]]*SLOW[USDJPY].DATA[p[USDJPY]] ) /  (FAST[NZDUSD].DATA[p[NZDUSD]]*FAST[USDJPY].DATA[p[USDJPY]]) - 1;
  end
  if Use[6] then  
  Index[8][period]=Index[8][period] +(SLOW[USDJPY].DATA[p[USDJPY]] /SLOW[USDCAD].DATA[p[USDCAD]] ) /   (FAST[USDJPY].DATA[p[USDJPY]]/FAST[USDCAD].DATA[p[USDCAD]]) - 1;
  end
  if Use[7] then
  Index[8][period]=Index[8][period] +(SLOW[USDJPY].DATA[p[USDJPY]] /SLOW[USDCHF].DATA[p[USDCHF]] ) /   (FAST[USDJPY].DATA[p[USDJPY]]/FAST[USDCHF].DATA[p[USDCHF]]) - 1;
   end
end		
		
 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

   local i;
    local FLAG=false; 
	local Number=0;
   
    for i = 1, Count, 1 do
		 
			  if cookie == 100+i then
			  loading[i] = true;
			  FLAG= true;
			  Number=Number+1;
		      elseif  cookie == 200+i then
			  loading[i] = false;   			  
			  end
		  
	end    
	
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count - Number) .. " / " .. Count );
    else
	 core.host:execute ("setStatus",    "Loaded" );
	 instance:updateFrom(0);
	end
   
        
     return core.ASYNC_REDRAW;
end
 