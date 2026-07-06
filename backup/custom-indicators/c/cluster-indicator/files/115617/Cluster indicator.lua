-- Id: 19370
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65206


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
    indicator:name("Cluster indicator");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
 
--{"USD","EUR","GBP","AUD","NZD" ,"CAD" ,"CHF","JPY"}
	indicator.parameters:addGroup("Calculation Selector");	 
    indicator.parameters:addBoolean("On"  .. 1, "USD", "", true);
	indicator.parameters:addBoolean("On"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("On"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("On"  .. 4, "AUD", "", true);
	indicator.parameters:addBoolean("On"  .. 5, "NZD", "", true);
	indicator.parameters:addBoolean("On"  .. 6, "CAD", "", true);
	indicator.parameters:addBoolean("On"  .. 7, "CHF", "", true);
	indicator.parameters:addBoolean("On"  .. 8, "JPY", "", true);
	
	
	indicator.parameters:addGroup("Show Line Selector");	 
    indicator.parameters:addBoolean("Show"  .. 1, "USD", "", true);
	indicator.parameters:addBoolean("Show"  .. 2, "EUR", "", true);
	indicator.parameters:addBoolean("Show"  .. 3, "GBP", "", true);
	indicator.parameters:addBoolean("Show"  .. 4, "AUD", "", true);
	indicator.parameters:addBoolean("Show"  .. 5, "NZD", "", true);
	indicator.parameters:addBoolean("Show"  .. 6, "CAD", "", true);
	indicator.parameters:addBoolean("Show"  .. 7, "CHF", "", true);
	indicator.parameters:addBoolean("Show"  .. 8, "JPY", "", true);

	
	indicator.parameters:addGroup("1. MA Parameters");
	
	indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period1", "Period", " " , 3);
   
   
   	indicator.parameters:addGroup("2. MA Parameters");
	
	indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period2", "Period", " " , 5);
   
   
   indicator.parameters:addGroup("Style Parameters");
   
   local Instrument = {"USD","EUR","GBP","AUD","NZD" ,"CAD" ,"CHF","JPY"}
    local Coloring= {core.rgb(255, 0, 0), core.rgb(255, 128, 0), core.rgb(128, 255, 0),   core.rgb(0, 255, 0), core.rgb(0, 255, 128), core.rgb(0, 128, 255),    core.rgb(0, 0, 255),    core.rgb(128, 128, 128)}
     local i;
	 for i=1, 8 , 1 do
	 AddStyle(i , Instrument[i], Coloring[i]);
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
local Method1, Price1, Period1;
local Method2, Price2, Period2;
-- Streams block
 
local Instrument = {"USD","EUR","GBP","AUD","NZD" ,"CAD" ,"CHF","JPY"}


 
local loading={};
local SourceData={};


local Color={};
local Style={};
local Width={};
 
local host;
local offset;
local weekoffset;

local On={};
local Show={};


local USD;
local EUR;
local GBP;
local CHF;
local AUD; 
local CAD; 
local JPY;
local NZD;

local p={};

local Index={};
		
  --    1     2     3      4     5       6     7      8
  -- {"USD","EUR","GBP","AUD","NZD" ,"CAD" ,"CHF","JPY"}	
			
		
local List={"EUR/USD","GBP/USD",  "AUD/USD","NZD/USD","USD/CAD","USD/CHF","USD/JPY" };
local Count=7;

local EURUSD_Fast_Indicator,EURUSD_Slow_Indicator,GBPUSD_Fast_Indicator,GBPUSD_Slow_Indicator,AUDUSD_Fast_Indicator,AUDUSD_Slow_Indicator,NZDUSD_Fast_Indicator,NZDUSD_Slow_Indicator,USDCAD_Fast_Indicator,USDCAD_Slow_Indicator,USDCHF_Fast_Indicator,USDCHF_Slow_Indicator,USDJPY_Fast_Indicator,USDJPY_Slow_Indicator; 


function EURUSD_Fast(period)
local index=1;
return EURUSD_Fast_Indicator.DATA[p[index]];
end

function EURUSD_Slow(period) 
local index=1;
return EURUSD_Slow_Indicator.DATA[p[index]];
end

function GBPUSD_Fast(period)
local index=2;
return GBPUSD_Fast_Indicator.DATA[p[index]];
end
function GBPUSD_Slow(period)
local index=2;
return GBPUSD_Slow_Indicator.DATA[p[index]];
end
function AUDUSD_Fast(period)
local index=3;
return AUDUSD_Fast_Indicator.DATA[p[index]];
end
function AUDUSD_Slow(period)
local index=3;
return AUDUSD_Slow_Indicator.DATA[p[index]];
end
function NZDUSD_Fast(period)
local index=4;
return NZDUSD_Fast_Indicator.DATA[p[index]];
end
function NZDUSD_Slow(period)
local index=4;
return NZDUSD_Slow_Indicator.DATA[p[index]];
end
function USDCAD_Fast(period)
local index=5;
return USDCAD_Fast_Indicator.DATA[p[index]];
end
function USDCAD_Slow(period)
local index=5;
return USDCAD_Slow_Indicator.DATA[p[index]];
end
function USDCHF_Fast(period)
local index=6;
return USDCHF_Fast_Indicator.DATA[p[index]];
end
function USDCHF_Slow(period)
local index=6;
return USDCHF_Slow_Indicator.DATA[p[index]];
end
function USDJPY_Fast(period)
local index=7;
return USDJPY_Fast_Indicator.DATA[p[index]];
end
function USDJPY_Slow(period)	
local index=7;
return USDJPY_Slow_Indicator.DATA[p[index]];			   
end
-- Routine
function Prepare(nameOnly)
   
 
	 
	Method1 = instance.parameters.Method1;  
	Price1 = instance.parameters.Price1;
	Period1 = instance.parameters.Period1;
	
	Method2 = instance.parameters.Method2;  
	Price2 = instance.parameters.Price2;
	Period2 = instance.parameters.Period2;
	
	local i,j;
	

	 
	
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
	
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
  
	if   (nameOnly) then
        return;
    end

	local FLAG= false;
 
	 
	for j= 1 , 8 , 1 do
	On[j] = instance.parameters:getBoolean("On" .. j);	
	Show[j] = instance.parameters:getBoolean("Show" .. j);	

           Width[j]= instance.parameters:getDouble("width" .. j);	
		   Style[j]= instance.parameters:getDouble("style" .. j);	
		   Color[j]= instance.parameters:getDouble("color" .. j);		
	end
	
	

	


	 i= 1;
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), math.min(300,math.max(Period1,Period2)*2) , 200+i , 100+i);
	 loading[i] = true;  
	 
	  EURUSD_Fast_Indicator = core.indicators:create(Method1, SourceData[i][Price1], Period1);
	  EURUSD_Slow_Indicator = core.indicators:create(Method2, SourceData[i][Price2], Period2);
	  
	  
	 i= 2;
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), math.min(300,math.max(Period1,Period2)*2) , 200+i , 100+i);
	 loading[i] = true;  
	 
	  GBPUSD_Fast_Indicator = core.indicators:create(Method1, SourceData[i][Price1], Period1);
	  GBPUSD_Slow_Indicator = core.indicators:create(Method2, SourceData[i][Price2], Period2);
	  
	  
	   i= 3;
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), math.min(300,math.max(Period1,Period2)*2) , 200+i , 100+i);
	 loading[i] = true;  
	 
	  AUDUSD_Fast_Indicator = core.indicators:create(Method1, SourceData[i][Price1], Period1);
	  AUDUSD_Slow_Indicator = core.indicators:create(Method2, SourceData[i][Price2], Period2);
	  
	  
	     i= 4;
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), math.min(300,math.max(Period1,Period2)*2) , 200+i , 100+i);
	 loading[i] = true;  
	 
	  NZDUSD_Fast_Indicator = core.indicators:create(Method1, SourceData[i][Price1], Period1);
	  NZDUSD_Slow_Indicator = core.indicators:create(Method2, SourceData[i][Price2], Period2);

	      i= 5;
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), math.min(300,math.max(Period1,Period2)*2) , 200+i , 100+i);
	 loading[i] = true;  
	 
	  USDCAD_Fast_Indicator = core.indicators:create(Method1, SourceData[i][Price1], Period1);
	  USDCAD_Slow_Indicator = core.indicators:create(Method2, SourceData[i][Price2], Period2);
	  
	  
	  	      i= 6;
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), math.min(300,math.max(Period1,Period2)*2) , 200+i , 100+i);
	 loading[i] = true;  
	 
	  USDCHF_Fast_Indicator = core.indicators:create(Method1, SourceData[i][Price1], Period1);
	  USDCHF_Slow_Indicator = core.indicators:create(Method2, SourceData[i][Price2], Period2);
	  
	  
	  	      i= 7;
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), math.min(300,math.max(Period1,Period2)*2) , 200+i , 100+i);
	 loading[i] = true;  
	 
	  USDJPY_Fast_Indicator = core.indicators:create(Method1, SourceData[i][Price1], Period1);
	 USDJPY_Slow_Indicator = core.indicators:create(Method2, SourceData[i][Price2], Period2);
	  
	  
 
 
	for i = 1, 8 , 1 do
		if Show[i] then 
		Index[i] = instance:addStream(Instrument[i], core.Line, name, Instrument[i], Color[i], source:first());
		Index[i]:setWidth(Width[i]);
        Index[i]:setStyle(Style[i]);
		Index[i]:setPrecision(math.max(2, instance.source:getPrecision()));
		else
		Index[i] = instance:addInternalStream(0, 0);
		end
		 
	end
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
	             if loading[List[i]] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
		 
	end
	
		
	if FLAG   then
	return;
	end
	
     local Flag=false;
	 
	 p[1]=  Initialization(period,1);
	 p[2]=  Initialization(period,2);
	 p[3]=  Initialization(period,3);
	 p[4]=  Initialization(period,4);
	 p[5]=  Initialization(period,5);
	 p[6]=  Initialization(period,6);
	 p[7]=  Initialization(period,7);
	 

	 
	 for i=1, 7, 1 do
	 if not p[i] or p[i]==-1 then
	 Flag=true;
	 end
	 end
	 
	 if Flag then
	 return;
	 end
 
	 
EURUSD_Fast_Indicator:update(mode); 					   
EURUSD_Slow_Indicator:update(mode); 
 			   
GBPUSD_Fast_Indicator:update(mode); 					   
GBPUSD_Slow_Indicator:update(mode); 

AUDUSD_Fast_Indicator:update(mode); 					   
AUDUSD_Slow_Indicator:update(mode); 

NZDUSD_Fast_Indicator:update(mode); 					   
NZDUSD_Slow_Indicator:update(mode); 

USDCAD_Fast_Indicator:update(mode); 					   
USDCAD_Slow_Indicator:update(mode); 

USDCHF_Fast_Indicator:update(mode); 					   
USDCHF_Slow_Indicator:update(mode); 

USDJPY_Fast_Indicator:update(mode); 					   
USDJPY_Slow_Indicator:update(mode); 
				   
                
 
	
	for i= 1, 8, 1 do		
		if On[i] then
		Index[i][period]=0;
		end 
	
	end
	
	  
	
	 if(On[1])then
   
 
           if(On[2]) then
               Index[1][period] =Index[1][period] +EURUSD_Slow(period) - EURUSD_Fast(period);
			end   
           if(On[3]) then
               Index[1][period] =Index[1][period] + GBPUSD_Slow(period)- GBPUSD_Fast(period);
			end      
           if(On[4]) then
                Index[1][period] =Index[1][period] + AUDUSD_Slow(period) - AUDUSD_Fast(period);
			end      
           if(On[5]) then
                Index[1][period] =Index[1][period] + NZDUSD_Slow(period) - NZDUSD_Fast(period);
			end      
           if(On[7]) then
                Index[1][period] =Index[1][period] + USDCHF_Fast(period) - USDCHF_Slow(period);
		   end   	   
           if(On[6]) then
                Index[1][period] =Index[1][period] + USDCAD_Fast(period) - USDCAD_Slow(period);
			end      
           if(On[8]) then
               Index[1][period] =Index[1][period] + USDJPY_Fast(period) - USDJPY_Slow(period);
		   end   	   
        end 
		
  --    1   2     3      4     5       6     7      8
  -- {"USD","EUR","GBP","AUD","NZD" ,"CAD" ,"CHF","JPY"}	
		
       if(On[2])then
 
           if(On[1]) then
                Index[2][period] =Index[2][period] + EURUSD_Fast(period) - EURUSD_Slow(period);
		   end   	   
           if(On[3]) then
                Index[2][period] =Index[2][period]+ EURUSD_Fast(period) / GBPUSD_Fast(period) - EURUSD_Slow(period) / 
                            GBPUSD_Slow(period);
			end   				
           if(On[4]) then
               Index[2][period] =Index[2][period]+ EURUSD_Fast(period) / AUDUSD_Fast(period) - EURUSD_Slow(period) / 
                            AUDUSD_Slow(period);
							
			end   				
           if(On[5]) then
               Index[2][period] =Index[2][period]+ EURUSD_Fast(period) / NZDUSD_Fast(period) - EURUSD_Slow(period) / 
                            NZDUSD_Slow(period);
			end   				
           if(On[7]) then
              Index[2][period] =Index[2][period]+ EURUSD_Fast(period)*USDCHF_Fast(period) - 
                            EURUSD_Slow(period)*USDCHF_Slow(period);
		  end   					
           if(On[6]) then
               Index[2][period] =Index[2][period]+ EURUSD_Fast(period)*USDCAD_Fast(period) - 
                            EURUSD_Slow(period)*USDCAD_Slow(period);
		  end   					
           if(On[8]) then
               Index[2][period] =Index[2][period]+ EURUSD_Fast(period)*USDJPY_Fast(period) - 
                            EURUSD_Slow(period)*USDJPY_Slow(period);
           end                 
			  end 
  --    1   2     3      4     5       6     7      8
  -- {"USD","EUR","GBP","AUD","NZD" ,"CAD" ,"CHF","JPY"}				   
			   
       if(On[3])then
      
 
           if(On[1]) then
              Index[3][period] =Index[3][period]+ GBPUSD_Fast(period) - GBPUSD_Slow(period);
			   end
           if(On[2]) then
                Index[3][period] =Index[3][period]+EURUSD_Slow(period) / GBPUSD_Slow(period) - EURUSD_Fast(period) / 
                            GBPUSD_Fast(period);
				end			
           if(On[4]) then
                Index[3][period] =Index[3][period]+GBPUSD_Fast(period) / AUDUSD_Fast(period) - GBPUSD_Slow(period) / 
                            AUDUSD_Slow(period);
				end			
           if(On[5]) then
               Index[3][period] =Index[3][period]+GBPUSD_Fast(period) / NZDUSD_Fast(period) - GBPUSD_Slow(period) / 
                            NZDUSD_Slow(period);
				end			
           if(On[7]) then
                Index[3][period] =Index[3][period]+ GBPUSD_Fast(period)*USDCHF_Fast(period) - 
                            GBPUSD_Slow(period)*USDCHF_Slow(period);
				end			
           if(On[6]) then
               Index[3][period] =Index[3][period]+ GBPUSD_Fast(period)*USDCAD_Fast(period) - 
                            GBPUSD_Slow(period)*USDCAD_Slow(period);
				end			
           if(On[8]) then
                Index[3][period] =Index[3][period]+ GBPUSD_Fast(period)*USDJPY_Fast(period) - 
                            GBPUSD_Slow(period)*USDJPY_Slow(period);
                end 
           end   
		   
  --    1   2     3      4     5       6     7      8
  -- {"USD","EUR","GBP","AUD","NZD" ,"CAD" ,"CHF","JPY"}	
		   if(On[4])  then
 
           if(On[1])  then
              Index[4][period] =Index[4][period]+AUDUSD_Fast(period) - AUDUSD_Slow(period);
			   end
           if(On[2]) then
                Index[4][period] =Index[4][period]+ EURUSD_Slow(period) / AUDUSD_Slow(period) - EURUSD_Fast(period) / 
                            AUDUSD_Fast(period);
				end			
           if(On[3]) then
               Index[4][period] =Index[4][period]+ GBPUSD_Slow(period) / AUDUSD_Slow(period) - GBPUSD_Fast(period) / 
                            AUDUSD_Fast(period);
			end				
           if(On[5]) then
                Index[4][period] =Index[4][period]+ AUDUSD_Fast(period) / NZDUSD_Fast(period) - AUDUSD_Slow(period) / 
                            NZDUSD_Slow(period);
			end				
           if(On[7]) then
               Index[4][period] =Index[4][period]+ AUDUSD_Fast(period)*USDCHF_Fast(period) - 
                            AUDUSD_Slow(period)*USDCHF_Slow(period);
				end			
           if(On[6]) then
               Index[4][period] =Index[4][period]+ AUDUSD_Fast(period)*USDCAD_Fast(period) - 
                            AUDUSD_Slow(period)*USDCAD_Slow(period);
			end				
           if(On[8]) then
                Index[4][period] =Index[4][period]+ AUDUSD_Fast(period)*USDJPY_Fast(period) - 
                            AUDUSD_Slow(period)*USDJPY_Slow(period);
               end 
		end   		
		
  --    1   2     3      4     5       6     7      8
  -- {"USD","EUR","GBP","AUD","NZD" ,"CAD" ,"CHF","JPY"}
		
       if(On[5])then
         
 
           if(On[1]) then
                Index[5][period] =Index[5][period]+ NZDUSD_Fast(period) - NZDUSD_Slow(period);
			end 			   
           if(On[2]) then
                 Index[5][period] =Index[5][period]+EURUSD_Slow(period) / NZDUSD_Slow(period) - EURUSD_Fast(period) / 
                            NZDUSD_Fast(period);
			end 							
           if(On[3]) then
                 Index[5][period] =Index[5][period]+GBPUSD_Slow(period) / NZDUSD_Slow(period) - GBPUSD_Fast(period) / 
                            NZDUSD_Fast(period);
			end 							
           if(On[4]) then
                 Index[5][period] =Index[5][period]+ AUDUSD_Slow(period) / NZDUSD_Slow(period) - AUDUSD_Fast(period) / 
                            NZDUSD_Fast(period);
			end 							
           if(On[7]) then
                 Index[5][period] =Index[5][period]+ NZDUSD_Fast(period)*USDCHF_Fast(period) - 
                            NZDUSD_Slow(period)*USDCHF_Slow(period);
			end 							
           if(On[6]) then
                 Index[5][period] =Index[5][period]+ NZDUSD_Fast(period)*USDCAD_Fast(period) - 
                            NZDUSD_Slow(period)*USDCAD_Slow(period);
			end 							
           if(On[8]) then
                 Index[5][period] =Index[5][period]+NZDUSD_Fast(period)*USDJPY_Fast(period) - 
                            NZDUSD_Slow(period)*USDJPY_Slow(period);
               end 
		end   	

  --    1   2     3      4     5       6     7      8
  -- {"USD","EUR","GBP","AUD","NZD" ,"CAD" ,"CHF","JPY"}	
		
       if(On[6])then
 
          
           if(On[1]) then
            Index[6][period] =Index[6][period]+ USDCAD_Slow(period) - USDCAD_Fast(period);
			end 		   
           if(On[2]) then
            Index[6][period] =Index[6][period]+  EURUSD_Slow(period)*USDCAD_Slow(period) - 
                        EURUSD_Fast(period)*USDCAD_Fast(period);
			end 						
           if(On[3]) then
            Index[6][period] =Index[6][period]+ GBPUSD_Slow(period)*USDCAD_Slow(period) - 
                        GBPUSD_Fast(period)*USDCAD_Fast(period);
			end 						
           if(On[4]) then
            Index[6][period] =Index[6][period]+  AUDUSD_Slow(period)*USDCAD_Slow(period) - 
                        AUDUSD_Fast(period)*USDCAD_Fast(period);
			end 						
           if(On[5]) then
            Index[6][period] =Index[6][period]+  NZDUSD_Slow(period)*USDCAD_Slow(period) - 
                        NZDUSD_Fast(period)*USDCAD_Fast(period);
			end 						
           if(On[7]) then
            Index[6][period] =Index[6][period]+  USDCHF_Fast(period) / USDCAD_Fast(period) - 
                        USDCHF_Slow(period) / USDCAD_Slow(period);
			end 						
           if(On[8]) then
            Index[6][period] =Index[6][period]+  USDJPY_Fast(period) / USDCAD_Fast(period) - 
                        USDJPY_Slow(period) / USDCAD_Slow(period);
         end 
		end    
		
		
		
 
		
       if(On[7])then
      
           
           if(On[1]) then
                Index[7][period] =Index[7][period]+  USDCHF_Slow(period) - USDCHF_Fast(period);
			end 			   
           if(On[2]) then
                Index[7][period] =Index[7][period]+EURUSD_Slow(period)*USDCHF_Slow(period)- 
                            EURUSD_Fast(period)*USDCHF_Fast(period);
			end 							
           if(On[3]) then
                Index[7][period] =Index[7][period]+GBPUSD_Slow(period)*USDCHF_Slow(period) - 
                            GBPUSD_Fast(period)*USDCHF_Fast(period);
			end 							
           if(On[4]) then
                Index[7][period] =Index[7][period] +AUDUSD_Slow(period)*USDCHF_Slow(period) - 
                            AUDUSD_Fast(period)*USDCHF_Fast(period);
			end 							
           if(On[5]) then
                Index[7][period] =Index[7][period] +NZDUSD_Slow(period)*USDCHF_Slow(period) - 
                            NZDUSD_Fast(period)*USDCHF_Fast(period);
			end 
           if(On[6])then 
               Index[7][period] =Index[7][period]+ USDCHF_Slow(period) / USDCAD_Slow(period) - 
                            USDCHF_Fast(period) / USDCAD_Fast(period);
			end 
           if(On[8]) then
                Index[7][period] =Index[7][period]+USDJPY_Fast(period) / USDCHF_Fast(period) - 
                            USDJPY_Slow(period) / USDCHF_Slow(period);
                 end 
		end   	


  --    1   2     3      4     5       6     7      8
  -- {"USD","EUR","GBP","AUD","NZD" ,"CAD" ,"CHF","JPY"}	

				  
       if(On[8]) then
        
          
           if(On[1]) then
           Index[8][period] =Index[8][period]+USDJPY_Slow(period) - USDJPY_Fast(period);
			end 		   
           if(On[2]) then
            Index[8][period] =Index[8][period]+ EURUSD_Slow(period)*USDJPY_Slow(period) - 
                        EURUSD_Fast(period)*USDJPY_Fast(period);
			end 						
           if(On[3]) then
            Index[8][period] =Index[8][period]+GBPUSD_Slow(period)*USDJPY_Slow(period) - 
                        GBPUSD_Fast(period)*USDJPY_Fast(period);
			end 						
           if(On[4]) then
            Index[8][period] =Index[8][period]+ AUDUSD_Slow(period)*USDJPY_Slow(period) - 
                        AUDUSD_Fast(period)*USDJPY_Fast(period);
			end 
           if(On[5]) then
            Index[8][period] =Index[8][period]+ NZDUSD_Slow(period)*USDJPY_Slow(period) - 
                        NZDUSD_Fast(period)*USDJPY_Fast(period);
			end   			
           if(On[6]) then
           Index[8][period] =Index[8][period]+ USDJPY_Slow(period) / USDCAD_Slow (period)- 
                        USDJPY_Fast(period) / USDCAD_Fast(period);
			end   			
           if(On[7]) then
            Index[8][period] =Index[8][period]+ USDJPY_Slow(period) / USDCHF_Slow(period) - 
                        USDJPY_Fast(period) / USDCHF_Fast(period);
                end 
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
 