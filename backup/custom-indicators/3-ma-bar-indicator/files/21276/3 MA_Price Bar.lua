-- Id: 5334

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9634

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
    indicator:name("5 MA Bar Indicator");
    indicator:description("5 MA_Price Bar Indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
    indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("O1", "Use 1. Indicator", "", true);
	indicator.parameters:addBoolean("O2", "Use 2. Indicator", "", true);
	indicator.parameters:addBoolean("O3", "Use 3. Indicator", "", true);
	indicator.parameters:addBoolean("O4", "Use 4. Indicator", "", true);
	indicator.parameters:addBoolean("O5", "Use 5. Indicator", "", true);
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P1", "1. Period", "1. Period", 34);
    indicator.parameters:addInteger("P2", "2. Period", "2. Period", 68);
    indicator.parameters:addInteger("P3", "3. Period", "3. Period", 102);
    indicator.parameters:addInteger("P4", "4. Period", "4. Period", 136);
	indicator.parameters:addInteger("P5", "5. Period", "5. Period", 200);
	
	indicator.parameters:addString("Type", "Smoothing type", "", "EMA");
    indicator.parameters:addStringAlternative("Type", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("Type", "EMA", "EMA", "EMA");
	indicator.parameters:addStringAlternative("Type" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("Type" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("Type" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("Type" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("Type" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("Type" , "WMA", "", "WMA");	
				
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Color for Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Dn", "Color for Down Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Color for No Trend", "", core.rgb(255, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Type;
local first;
local source = nil;
local Num;
-- Streams block
local Indicator={};
local Out = nil;

-- Routine
function Prepare(nameOnly)
    
    
	Type = instance.parameters.Type;
    source = instance.source;
    
   local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Type); 
   instance:name(name);

    if   (nameOnly) then
        return;
    end  
	first= source:first();
	 Num=0;
	 
	 for i= 1 , 5, 1 do
		 if  instance.parameters:getBoolean ("O"..i) 	 then
		 Num=Num+1; 
    assert(core.indicators:findIndicator(Type) ~= nil, Type .. " indicator must be installed");
		 Indicator[Num] = core.indicators:create(Type, source, instance.parameters:getInteger ("P"..i));
		 first = math.max( first,Indicator[Num].DATA:first());
		 end
	 end
	 
	 
	 
  
        Out = instance:addStream("Out", core.Bar, name, "Out", instance.parameters.No, first);
		Out:addLevel(0);
		Out:setPrecision(math.max(4, source:getPrecision()));
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    Out[period] = 1
	  
    if period < first or  not source:hasData(period) then
	return;
	end
	
	if Num==0 then
	return;
	end
	
	for i=1, Num, 1 do
		 
		 Indicator[i]:update(mode);		
		 
	 end
	   
	 local Count=0;
	 
	 if   source[period] > Indicator[1].DATA[period]  then
	 Count=1;
	 elseif   source[period] < Indicator[1].DATA[period]  then
	 Count=-1;
	 end
	 
	 for i=2, Num, 1 do
		 if Indicator[i-1].DATA[period]> Indicator[i].DATA[period] then
		 Count=Count+1;
		 elseif Indicator[i-1].DATA[period]< Indicator[i].DATA[period] then
		 Count=Count-1;
		 end
	 end
	 
	  Out[period] = 1;
	 
	 if Count== Num then
	  Out:setColor(period, instance.parameters.Up);  
	 elseif Count== -Num then
	  Out:setColor(period, instance.parameters.Dn);  
	 else
	  Out:setColor(period, instance.parameters.No);  
	 end
       
    
end

