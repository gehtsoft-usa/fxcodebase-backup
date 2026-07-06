-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72406

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Triple Function Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
    indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addBoolean("Continuity", "Continuity", "Continuity", true);
 
    indicator.parameters:addGroup("SMI Calculation");
    indicator.parameters:addInteger("Period_Q", "Period_Q", "Period_Q", 2);
    indicator.parameters:addInteger("Period_R", "Period_R", "Period_R", 8);
    indicator.parameters:addInteger("Period_S", "Period_S", "Period_S", 5);
    indicator.parameters:addInteger("Period_Signal", "Period_Signal", "Period_Signal", 5);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	


    indicator.parameters:addGroup("CCI Calculation");
    indicator.parameters:addInteger("n", "Period", "Period", 17);	



    indicator.parameters:addGroup("RSI Calculation");
    indicator.parameters:addInteger("m", "Period", "Period", 5);	
	
 
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(255, 0, 0)); 
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(0, 255, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil; 
local SMI;
local Continuity;	
-- Routine
 function Prepare(nameOnly)   
 
    
 
	source = instance.source
	
	Continuity= instance.parameters.Continuity;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    assert(core.indicators:findIndicator("SMI") ~= nil, "Please, download and install SMI.LUA indicator");
	
	SMI= core.indicators:create("SMI", source, instance.parameters.Period_Q, instance.parameters.Period_R, instance.parameters.Period_S, instance.parameters.Period_Signal, instance.parameters.Method );
	RSI= core.indicators:create("RSI", source,   instance.parameters.m );	
	CCI= core.indicators:create("CCI", source,   instance.parameters.n );		
	first=math.max(SMI.SignalBuff:first(), RSI.DATA:first(),  CCI.DATA:first()) ; 
	
	
	ZLS1 = instance:addInternalStream(0, 0);
	ZLS2 = instance:addInternalStream(0, 0);
	ZLS3 = instance:addInternalStream(0, 0);	
	
	
    Line = instance:addStream("Line", core.Line, name, "Triple Function Indicator", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision()));
    Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:addLevel(0);	
 
 
    Top = instance:addStream("Top", core.Line, name, "Upper Limit", instance.parameters.color1, first );
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:addLevel(0);	


    Bottom = instance:addStream("Bottom", core.Line, name, "Lower Limit", instance.parameters.color2, first );
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:addLevel(0);		
end


function Update(period, mode)

	  SMI:update(mode); 
	  CCI:update(mode); 
	  RSI:update(mode); 	
	  
	 if period <= first then
	 return;
	 end
	 
   
    local c1=false; 
    if SMI.DATA[period] >40 then
    c1=true;
	end

    local c11=false; 
    if SMI.DATA[period] < -40 then
    c11=true;
	end	
	
 

    local c2=false; 
    if CCI.DATA[period] >100 then
    c2=true;
	end	
	
	
    local c21=false; 
    if CCI.DATA[period] < - 100 then
    c21=true;
	end		
	
    local c3=false; 
    if CCI.DATA[period] >70 then
    c3=true;
	end	
	
	
    local c31=false; 
    if CCI.DATA[period] < 30 then
    c31=true;
	end		
	
	if Continuity then
	ZLS1[period]=ZLS1[period-1];
	ZLS2[period]=ZLS2[period-1];
	ZLS3[period]=ZLS3[period-1];	
	else
	ZLS1[period]=0;
	ZLS2[period]=0;
	ZLS3[period]=0;
	end
	
	if c1 then
	ZLS1[period]= 1
	elseif c11 then
	ZLS1[period]=-1
	end 

	if c2 then
	ZLS2[period]=1
	elseif c21 then
	ZLS2[period]=-1
	end 

	if c3 then
	ZLS3[period]=1
	elseif c31 then
	ZLS3[period]=-1
	end 
	
	
	Line[period]= math.sin(math.atan(ZLS1[period]+ZLS2[period]+ZLS3[period]));
	Top[period]=  math.sin(math.atan(1)) 
	Bottom[period]=  math.sin(math.atan(-1)) 
end

 