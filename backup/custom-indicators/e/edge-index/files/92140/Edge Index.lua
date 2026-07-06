-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60218
-- Id: 10964

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Edge Index");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
 
	indicator.parameters:addGroup("On/Off Selector");	 
    indicator.parameters:addBoolean("On"  .. 1, "USD", "", true);
	indicator.parameters:addBoolean("On"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("On"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("On"  .. 4, "CHF", "", true);
	indicator.parameters:addBoolean("On"  .. 5, "JPY", "", true);
	indicator.parameters:addBoolean("On"  .. 6, "AUD", "", true);
	indicator.parameters:addBoolean("On"  .. 7, "NZD", "", true);
	indicator.parameters:addBoolean("On"  .. 8, "CAD", "", true);

	
	indicator.parameters:addGroup("Show Selector");	 
    indicator.parameters:addBoolean("Show"  .. 1, "USD", "", true);
	indicator.parameters:addBoolean("Show"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("Show"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("Show"  .. 4, "CHF", "", true);
	indicator.parameters:addBoolean("Show"  .. 5, "JPY", "", true);
	indicator.parameters:addBoolean("Show"  .. 6, "AUD", "", true);
	indicator.parameters:addBoolean("Show"  .. 7, "NZD", "", true);
	indicator.parameters:addBoolean("Show"  .. 8, "CAD", "", true);
	
indicator.parameters:addGroup("MA Parameters");
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("FastMethod", " Fast MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("FastMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("FastMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("FastMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("FastMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("FastMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("FastMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("FastMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("FastMethod", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("FastPeriod", "Period", " " , 8);
	
	
	indicator.parameters:addString("MediumMethod", " Medium MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("MediumMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MediumMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MediumMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MediumMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MediumMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MediumMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MediumMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MediumMethod", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("MediumPeriod", "Period", " " , 21);
	
	
	
	indicator.parameters:addString("SlowMethod", " Slow MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("SlowMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("SlowMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("SlowMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("SlowMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("SlowMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("SlowMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("SlowMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("SlowMethod", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("SlowPeriod", "Period", " " , 55);
	
   indicator.parameters:addGroup("ROC Parameters");
   
   indicator.parameters:addInteger("ROC", "ROC Period", " " , 8);
    indicator.parameters:addInteger("SIGNAL", "ROC Signal  Period", " " , 8);
	indicator.parameters:addString("ROCMethod", " Slow MA Method", "Method" , "EMA");
	 indicator.parameters:addStringAlternative("ROCMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("ROCMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("ROCMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("ROCMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("ROCMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("ROCMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("ROCMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("ROCMethod", "WMA", "WMA" , "WMA");
   
   indicator.parameters:addGroup("Style Parameters");
   
   local Pair = {"USD","EUR","GBP","CHF","JPY" ,"AUD" ,"NZD","CAD"}
    local Coloring= {core.rgb(255, 0, 0), core.rgb(255, 128, 0), core.rgb(128, 255, 0),   core.rgb(0, 255, 0), core.rgb(0, 255, 128), core.rgb(0, 128, 255),    core.rgb(0, 0, 255),    core.rgb(128, 128, 128)}
     local i;
	 for i=1, 8 , 1 do
	 AddStyle(i , Pair[i], Coloring[i]);
	 end
end


local ROCMethod, ROC, SIGNAL;

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
 local roc={};
 local signal={};
local SlowMethod,SlowPeriod;
local MediumMethod,MediumPeriod;
local FastMethod,FastPeriod;
 
local slowMA={};
local mediumMA={};
local fastMA={} ;


local Out={};
local Pair = {"USD","EUR","GBP","CHF","JPY" ,"AUD" ,"NZD","CAD"}
local On={};
local Show={};
local loading={};
local List={};
local  Count;
local RawList, RawCount;
local SourceData={};
local pauto =  "(%a%a%a)/(%a%a%a)";
 
local Shift;
local Color={};
local Style={};
local Width={};
 
local Bold, Size;
local id;

	local host;
	local offset;
	local weekoffset;	 

local iNum={}; 

-- Routine
function Prepare(nameOnly)
    SlowMethod = instance.parameters.SlowMethod; 
	SlowPeriod = instance.parameters.SlowPeriod;  
	MediumMethod = instance.parameters.MediumMethod; 
	MediumPeriod = instance.parameters.MediumPeriod;  
    FastMethod = instance.parameters.FastMethod; 
	FastPeriod = instance.parameters.FastPeriod;  
	
	ROCMethod = instance.parameters.ROCMethod;
	ROC = instance.parameters.ROC;
	SIGNAL = instance.parameters.SIGNAL;
	
	Price = instance.parameters.Price;
	 
	local i,j;
	

	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
    source = instance.source;
   

    local name = profile:id() .. "  " .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	local crncy1, crncy2;
	 
	RawList, RawCount= getInstrumentList();
	
	 

	local FLAG= false;
	Count=0;
	 
	for j= 1 , 8 , 1 do
	On[j] = instance.parameters:getBoolean("On" .. j);	
	Show[j] = instance.parameters:getBoolean("Show" .. j);	
	end
	
	
	for i = 1, RawCount, 1 do
	
	
	FLAG= false;
	
	crncy1, crncy2 = string.match(RawList[i], pauto);
	
		   for j = 1, 8 , 1 do
		   
		   Width[j]= instance.parameters:getDouble("width" .. j);	
		   Style[j]= instance.parameters:getDouble("style" .. j);	
		   Color[j]= instance.parameters:getDouble("color" .. j);	
		   
			 if ( (Check(crncy1) and (Check(crncy2)) ))			 
			 then
			 FLAG= true;
			 end
		   end 
		   
		 if FLAG then
		 Count = Count+ 1;
		
		 List[Count]= RawList[i]; 
		 end
	
	end

	
	local Temp1,Temp2,Temp3,Temp4,Temp5;
    assert(core.indicators:findIndicator(SlowMethod) ~= nil, SlowMethod .. " indicator must be installed");
	 Temp1= core.indicators:create(SlowMethod, source[Price], SlowPeriod);
    assert(core.indicators:findIndicator(MediumMethod) ~= nil, MediumMethod .. " indicator must be installed");
	  Temp2= core.indicators:create(MediumMethod, source[Price], MediumPeriod);
    assert(core.indicators:findIndicator(FastMethod) ~= nil, FastMethod .. " indicator must be installed");
	   Temp3= core.indicators:create(FastMethod, source[Price], FastPeriod);
	    Temp4= core.indicators:create("ROC", source[Price], ROC);  
    assert(core.indicators:findIndicator(ROCMethod) ~= nil, ROCMethod .. " indicator must be installed");
	    Temp5= core.indicators:create(ROCMethod, Temp4.DATA, SIGNAL);

	 first = math.max(Temp1.DATA:first(),Temp2.DATA:first(),Temp3.DATA:first(),Temp5.DATA:first());
	
	for i = 1, Count, 1 do
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), first , 200+i , 100+i);
	 loading[i] = true;  
	 
	  slowMA[i] = core.indicators:create(SlowMethod, SourceData[i][Price], SlowPeriod);
	  mediumMA[i] = core.indicators:create(MediumMethod, SourceData[i][Price], MediumPeriod);
	  fastMA[i] = core.indicators:create(FastMethod, SourceData[i][Price], FastPeriod);
	  
	  roc[i]= core.indicators:create("ROC", SourceData[i][Price], ROC); 
	  signal[i]= core.indicators:create(ROCMethod, roc[i].DATA, SIGNAL);
	  
	end
	for j = 1, 8 , 1 do
		if Show[j] then
		Out[j] = instance:addStream(Pair[j], core.Line, name, Pair[j], Color[j], first);
    Out[j]:setPrecision(math.max(2, instance.source:getPrecision()));
		Out[j]:setWidth(Width[j]);
        Out[j]:setStyle(Style[j]);
		
		else
		Out[j] = instance:addInternalStream(0, 0);
		end
	end
end
 


function Check(Find)
 local FLAG= false;
            for j = 1, 8 , 1 do
			 if  (Find==Pair[j] and On[j])then
			 FLAG= true;
			 end
		   end 
return FLAG;		   
end
function getInstrumentList()
    local list={};
   
    local count = 0;   
    local row, enum;   
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
        row = enum:next();
    end

    return list, count;
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < source:first() or not source:hasData(period) then
	return;
	end
	
	
	
    local FLAG=false; 
	local Number=0;
	local i;
	
	for i = 1, Count, 1 do
	             if loading[i] then
				 FLAG= true;
				 Number=Number+1;
				 end
	end
	
	
		
	if FLAG then
	return;
	end
	
	core.host:execute ("setStatus",    "" );
	  
	 for i = 1 , 8, 1 do 
	  Out[i][period]=0;
	 end

	for i = 1, Count, 1 do			   
	   
				     slowMA[i]:update(mode); 		
                    mediumMA[i]:update(mode);
                    fastMA[i]:update(mode);	
                    roc[i]:update(mode);
                    signal[i]:update(mode);						
				   Calculate(i , period);				  
					
	end
	 
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



		
		
		
function Calculate(i, k )
 
local  period =Initialization(k,i);
  
  if  period == false then
  return 
  end

if not slowMA[i].DATA:hasData(period)  
or not mediumMA[i].DATA:hasData(period)
or not fastMA[i].DATA:hasData(period)
or not roc[i].DATA:hasData(period)
or not signal[i].DATA:hasData(period)
 then
 return;
end

 
local j;
local crncy1, crncy2;

	 for j= 1, 8 , 1 do  
 

     
       
		if On[j] then
		 
		
				 crncy1, crncy2 = string.match(List[i], pauto);
					
							--1			
							if fastMA[i].DATA[period] > mediumMA[i].DATA[period] 	
							and mediumMA[i].DATA[period] > slowMA[i].DATA[period] 	
							then
								if crncy1 == Pair[j] then
								Out[j][k] = Out[j][k] + 3;
								elseif crncy2 == Pair[j] then
								Out[j][k] = Out[j][k] - 3;
								end
							
							end
							
							
							if fastMA[i].DATA[period] < mediumMA[i].DATA[period] 	
							and mediumMA[i].DATA[period] < slowMA[i].DATA[period] 	
							then
								if crncy1 == Pair[j] then
								Out[j][k] = Out[j][k] - 3;
								elseif crncy2 == Pair[j] then
								Out[j][k] = Out[j][k] + 3;
								end
							
							end
							
							--2
							if fastMA[i].DATA[period] < mediumMA[i].DATA[period] 	
							and mediumMA[i].DATA[period] > slowMA[i].DATA[period] 	
							then
								if crncy1 == Pair[j] then
								Out[j][k] = Out[j][k] + 2;
								elseif crncy2 == Pair[j] then
								Out[j][k] = Out[j][k] - 1;
								end
							
							end
							
							
							if fastMA[i].DATA[period] > mediumMA[i].DATA[period] 	
							and mediumMA[i].DATA[period] < slowMA[i].DATA[period] 	
							then
								if crncy1 == Pair[j] then
								Out[j][k] = Out[j][k] - 1;
								elseif crncy2 == Pair[j] then
								Out[j][k] = Out[j][k] + 2;
								end
							
							end
							
							
					
							
							if roc[i].DATA[period] > signal[i].DATA[period] 	
							and signal[i].DATA[period] > 0	
							then
								if crncy1 == Pair[j] then
								Out[j][k] = Out[j][k] + 3;
								elseif crncy2 == Pair[j] then
								Out[j][k] = Out[j][k] - 3;
								end
							
							end
							
						
						   if roc[i].DATA[period]< signal[i].DATA[period] 	
							and signal[i].DATA[period] < 0	
							then
								if crncy1 == Pair[j] then
								Out[j][k] = Out[j][k] - 3;
								elseif crncy2 == Pair[j] then
								Out[j][k] = Out[j][k] + 3;
								end
							
							end
							
							
					
							
							if roc[i].DATA[period] < signal[i].DATA[period] 	
							and signal[i].DATA[period] > 0	
							then
								if crncy1 == Pair[j] then
								Out[j][k] = Out[j][k] + 2;
								elseif crncy2 == Pair[j] then
								Out[j][k] = Out[j][k] - 1;
								end
							
							end
							
						
						   if roc[i].DATA[period]>signal[i].DATA[period] 	
							and signal[i].DATA[period] < 0	
							then
								if crncy1 == Pair[j] then
								Out[j][k] = Out[j][k] - 1;
								elseif crncy2 == Pair[j] then
								Out[j][k] = Out[j][k] + 2;
								end
							
							end
							
				 
	    end		
		
					
			
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
 