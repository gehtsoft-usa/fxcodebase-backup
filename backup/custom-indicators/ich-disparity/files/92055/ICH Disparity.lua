-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60206
-- Id: 10942

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
    indicator:name("ICH Disparity");
    indicator:description("ICH Disparity");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	 indicator.parameters:addGroup("1. ICH Disparity");
	indicator.parameters:addInteger("A11", "First Component", "First Component" , 1);
    indicator.parameters:addIntegerAlternative("A11", "TL", "TL" , 1);
    indicator.parameters:addIntegerAlternative("A11", "KL", "KL" , 2);
    indicator.parameters:addIntegerAlternative("A11", "CS", "CS" , 3);
    indicator.parameters:addIntegerAlternative("A11", "SA", "SA" , 4);
    indicator.parameters:addIntegerAlternative("A11", "SB", "SB" , 5);
	
	local Label= "Smoothing";
	   indicator.parameters:addInteger("Period".. 11, Label .. " Period", "Period", 14);
	 
	 
    indicator.parameters:addString("Method".. 11, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method".. 11, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method".. 11, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method".. 11, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method".. 11, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method".. 11, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method".. 11, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method".. 11, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method".. 11, "WMA", "WMA" , "WMA");
 
	
	indicator.parameters:addInteger("A12", "Second Component", "First Component" , 2);
    indicator.parameters:addIntegerAlternative("A12", "TL", "TL" , 1);
    indicator.parameters:addIntegerAlternative("A12", "KL", "KL" , 2);
    indicator.parameters:addIntegerAlternative("A12", "CS", "CS" , 3);
    indicator.parameters:addIntegerAlternative("A12", "SA", "SA" , 4);
    indicator.parameters:addIntegerAlternative("A12", "SB", "SB" , 5);
	
	   indicator.parameters:addInteger("Period".. 12, Label .. " Period", "Period", 14);
	 
	 
    indicator.parameters:addString("Method".. 12, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method".. 12, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method".. 12, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method".. 12, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method".. 12, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method".. 12, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method".. 12, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method".. 12, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method".. 12, "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addGroup("2. ICH Disparity");
	indicator.parameters:addInteger("A21", "First Component", "First Component" , 1);
    indicator.parameters:addIntegerAlternative("A21", "TL", "TL" , 1);
    indicator.parameters:addIntegerAlternative("A21", "KL", "KL" , 2);
    indicator.parameters:addIntegerAlternative("A21", "CS", "CS" , 3);
    indicator.parameters:addIntegerAlternative("A21", "SA", "SA" , 4);
    indicator.parameters:addIntegerAlternative("A21", "SB", "SB" , 5);
	
	   indicator.parameters:addInteger("Period".. 21, Label .. " Period", "Period", 14);
	 
	 
    indicator.parameters:addString("Method".. 21, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method".. 21, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method".. 21, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method".. 21, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method".. 21, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method".. 21, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method".. 21, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method".. 21, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method".. 21, "WMA", "WMA" , "WMA");
 
	
	indicator.parameters:addInteger("A22", "Second Component", "First Component" , 3);
    indicator.parameters:addIntegerAlternative("A22", "TL", "TL" , 1);
    indicator.parameters:addIntegerAlternative("A22", "KL", "KL" , 2);
    indicator.parameters:addIntegerAlternative("A22", "CS", "CS" , 3);
    indicator.parameters:addIntegerAlternative("A22", "SA", "SA" , 4);
    indicator.parameters:addIntegerAlternative("A22", "SB", "SB" , 5);
	
	
	   indicator.parameters:addInteger("Period".. 22, Label .. " Period", "Period", 14);
	 
	 
    indicator.parameters:addString("Method".. 22, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method".. 22, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method".. 22, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method".. 22, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method".. 22, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method".. 22, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method".. 22, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method".. 22, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method".. 22, "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addGroup("3. ICH Disparity");
	indicator.parameters:addInteger("A31", "First Component", "First Component" , 4);
    indicator.parameters:addIntegerAlternative("A31", "TL", "TL" , 1);
    indicator.parameters:addIntegerAlternative("A31", "KL", "KL" , 2);
    indicator.parameters:addIntegerAlternative("A31", "CS", "CS" , 3);
    indicator.parameters:addIntegerAlternative("A31", "SA", "SA" , 4);
    indicator.parameters:addIntegerAlternative("A31", "SB", "SB" , 5);
	
	   indicator.parameters:addInteger("Period".. 31, Label .. " Period", "Period", 14);
	 
	 
    indicator.parameters:addString("Method".. 31, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method".. 31, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method".. 31, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method".. 31, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method".. 31, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method".. 31, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method".. 31, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method".. 31, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method".. 31, "WMA", "WMA" , "WMA");
 
	
	indicator.parameters:addInteger("A32", "Second Component", "First Component" , 5);
    indicator.parameters:addIntegerAlternative("A32", "TL", "TL" , 1);
    indicator.parameters:addIntegerAlternative("A32", "KL", "KL" , 2);
    indicator.parameters:addIntegerAlternative("A32", "CS", "CS" , 3);
    indicator.parameters:addIntegerAlternative("A32", "SA", "SA" , 4);
    indicator.parameters:addIntegerAlternative("A32", "SB", "SB" , 5);
	
	   indicator.parameters:addInteger("Period".. 32, Label .. " Period", "Period", 14);
	 
	 
    indicator.parameters:addString("Method".. 32, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method".. 32, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method".. 32, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method".. 32, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method".. 32, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method".. 32, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method".. 32, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method".. 32, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method".. 32, "WMA", "WMA" , "WMA");
	
	 

	 indicator.parameters:addGroup("ICH Calculation");
	 indicator.parameters:addInteger("X", "Tenkan-sen period ", "", 9, 1, 10000);
    indicator.parameters:addInteger("Y", "Kijun-sen period","", 26, 1, 10000);
    indicator.parameters:addInteger("Z", "Senkou Span B period","", 52, 1, 10000);
	
    indicator.parameters:addGroup("ICH Components Smoothing");

	

	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color1", "Color of 1. Disparity Line", "Color of Disparity", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("Color2", "Color of 2. Disparity Line", "Color of Disparity", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Color3", "Color of 3. Disparity Line", "Color of Disparity", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style3", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 0);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0);
	
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

function Add(id, Label)

  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period={};
local Method={};
local MA={};
local X, Y, Z;
local first;
local source = nil;
local ICH;
-- Streams block
local Disparity ={};
local A11, A12,A21, A22, A31, A32;

-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
	first = source:first();
	X=instance.parameters.X;
	Y=instance.parameters.Y;
	Z=instance.parameters.Z;
	
	A11=instance.parameters.A11;
	A12=instance.parameters.A12;
	A21=instance.parameters.A21;
	A22=instance.parameters.A22;
	A31=instance.parameters.A31;
	A32=instance.parameters.A32;
	
	local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        ICH= core.indicators:create("ICH", source, X,Y,Z);
    
        Period[11] =  instance.parameters:getInteger ("Period".. 11); 
        Method[11] =  instance.parameters:getString ("Method".. 11); 	
        Period[12] =  instance.parameters:getInteger ("Period".. 12); 
        Method[12] =  instance.parameters:getString ("Method".. 12); 
        
        Period[21] =  instance.parameters:getInteger ("Period".. 21); 
        Method[21] =  instance.parameters:getString ("Method".. 21); 
        Period[22] =  instance.parameters:getInteger ("Period".. 22); 
        Method[22] =  instance.parameters:getString ("Method".. 22); 
        
        Period[31] =  instance.parameters:getInteger ("Period".. 31); 
        Method[31] =  instance.parameters:getString ("Method".. 31); 
        Period[32] =  instance.parameters:getInteger ("Period".. 32); 
        Method[32] =  instance.parameters:getString ("Method".. 32); 
        
        MA[11]= core.indicators:create(Method[11], ICH:getStream(A11-1), Period[11]);	
        MA[12]= core.indicators:create(Method[12], ICH:getStream(A12-1), Period[12]);	

        MA[21]= core.indicators:create(Method[21], ICH:getStream(A21-1), Period[21]);	
        MA[22]= core.indicators:create(Method[22], ICH:getStream(A22-1), Period[22]);	
        
        MA[31]= core.indicators:create(Method[31], ICH:getStream(A31-1), Period[31]);	
        MA[32]= core.indicators:create(Method[32], ICH:getStream(A32-1), Period[32]);	
        
        first =math.max(MA[11].DATA:size()-1, MA[12].DATA:size()-1,MA[21].DATA:size()-1, MA[22].DATA:size()-1,MA[31].DATA:size()-1, MA[32].DATA:size()-1, first);
        
        
        Disparity[1] = instance:addStream("Disparity1", core.Line, name, "1. " .. Decode (A11, A12), instance.parameters.Color1, math.max(MA[11].DATA:first(), MA[12].DATA:first() ), Y);
		Disparity[1]:setWidth(instance.parameters.Width1);
        Disparity[1]:setStyle(instance.parameters.Style1);
		
		Disparity[1] :addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		Disparity[1] :addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
        Disparity[1] :addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    

		Disparity[2] = instance:addStream("Disparity2", core.Line, name, "2. ".. Decode (A21, A22) , instance.parameters.Color2,  math.max(MA[21].DATA:first(), MA[22].DATA:first() ), Y);
		Disparity[2]:setWidth(instance.parameters.Width2);
        Disparity[2]:setStyle(instance.parameters.Style2);
		
		
		Disparity[3] = instance:addStream("Disparity3", core.Line, name, "3. " .. Decode (A31, A32), instance.parameters.Color3,  math.max(MA[31].DATA:first(), MA[32].DATA:first() ), Y);
		Disparity[3]:setWidth(instance.parameters.Width3);
        Disparity[3]:setStyle(instance.parameters.Style3);
		
		Disparity[1]:setPrecision(math.max(2, instance.source:getPrecision()));
		Disparity[2]:setPrecision(math.max(2, instance.source:getPrecision()));
		Disparity[3]:setPrecision(math.max(2, instance.source:getPrecision()));
		
    end
end

function Decode(A1, A2)

  local One, Two;
  
  if A1 == 1 then
  One = "TL";
  elseif A1 == 2 then
  One = "KL";
  elseif A1 == 3  then
  One = "CS";
  elseif A1 == 4 then
  One = "SA";
  elseif A1 == 5 then
  One = "SB";
  end
  
   if A2 == 1 then
  Two = "TL";
  elseif A2 == 2 then
  Two = "KL";
  elseif A2 == 3 then
  Two = "CS";
  elseif A2 == 4 then
  Two = "SA";
  elseif A2 == 5 then
  Two = "SB";
  end
  
  return One .. "/" .. Two;

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    ICH:update(mode);
	
	 
	MA[11]:update(mode);
	MA[12]:update(mode);
	MA[21]:update(mode);
	MA[22]:update(mode);
	MA[31]:update(mode);
	MA[32]:update(mode);
	 
	
	
    if period < first   then
	return;
	end
	
	if period < source:size()-1 then
	
	    i= period;
		if  MA[11].DATA:hasData(i) and MA[12].DATA:hasData(i) then
		Disparity[1][i]= MA[11].DATA[i] -MA[12].DATA[i] ;
		end
		
		if  MA[21].DATA:hasData(i) and MA[22].DATA:hasData(i) then
		Disparity[2][i]= MA[21].DATA[i] -MA[22].DATA[i] ;
		end
		
		if  MA[31].DATA:hasData(i) and MA[32].DATA:hasData(i) then
		Disparity[3][i]= MA[31].DATA[i] -MA[32].DATA[i] ;
		end
		
	else
	
	
    for i = period-Y, period,  1 do
	
	if  MA[11].DATA:hasData(i) and MA[12].DATA:hasData(i) then
	Disparity[1][i]= MA[11].DATA[i] -MA[12].DATA[i] ;
	end
	
	if  MA[21].DATA:hasData(i) and MA[22].DATA:hasData(i) then
	Disparity[2][i]= MA[21].DATA[i] -MA[22].DATA[i] ;
	end
	
	if  MA[31].DATA:hasData(i) and MA[32].DATA:hasData(i) then
	Disparity[3][i]= MA[31].DATA[i] -MA[32].DATA[i] ;
	end
    

	end
	end
end

