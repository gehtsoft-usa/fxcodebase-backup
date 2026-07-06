-- Id: 1346
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1921

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
    indicator:name("Multiple Wave Analysis");
    indicator:description("Multi-Wave Analysis indicator. For support and description: www.fxcodebase.com");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
      
    indicator.parameters:addGroup("Selector");  
	indicator.parameters:addBoolean("S1Flag", "Show 1. MA", "", true);  
	indicator.parameters:addBoolean("S2Flag", "Show 2. MA", "", true);  
	indicator.parameters:addBoolean("S3Flag", "Show 3. MA", "", true);  
	indicator.parameters:addBoolean("S4Flag", "Show 4. MA", "", true);  
	indicator.parameters:addBoolean("S5Flag", "Show 5. MA", "", true);  
	indicator.parameters:addBoolean("S6Flag", "Show 6. MA", "", true);  
    indicator.parameters:addBoolean("S7Flag", "Show Averege", "", true);  

	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("Method1", "Component MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period1", "1. Averege Period", "", 200);  
	indicator.parameters:addInteger("Period2", "2. Averege Period", "", 100);  
	indicator.parameters:addInteger("Period3", "3. Averege Period", "", 50);  
	indicator.parameters:addInteger("Period4", "4. Averege Period", "", 25);  
	indicator.parameters:addInteger("Period5", "5. Averege Period", "", 12);  
	indicator.parameters:addInteger("Period6", "6. Averege Period", "", 6);  
	
	
	
	indicator.parameters:addString("Method2", "Averege MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");	
	
	indicator.parameters:addInteger("Frame", "Averege Period", "", 6);  

    indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("Color1", "MVA 200 Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Color2", "MWA 100 Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Color3", "MWA 50 Color", "", core.rgb(255, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Color4", "MWA 25 Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Color5", "MWA 12 Color", "", core.rgb(255, 255, 0));
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Color6", "MWA 6 Color", "", core.rgb(125, 125, 125));
	indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Color7", "Average Color", "", core.rgb(125, 0, 125));
	indicator.parameters:addInteger("width7", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style7", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style7", core.FLAG_LINE_STYLE);

end

-- Parameters block
local first;
local firstPeriod;
local source = nil;
local Method1, Method2;
-- MVAs
local MVA200 = nil;
local residual200 = nil;
local residual200mva = nil;
local residual100 = nil;
local residual100mva = nil;
local residual50 = nil;
local residual50mva = nil;
local residual25 = nil;
local residual25mva = nil;
local residual12 = nil;
local residual12mva = nil;
local residual6 = nil;
local residual6mva = nil;

-- Streams block
local S1 = nil;
local S2 = nil;
local S3 = nil;
local S4 = nil;
local S5 = nil;
local S6 = nil;

local S7= nil;
local BUFFER=nil;
local AVERAGE=nil;
local Frame=nil;

local S1Flag = nil;
local S2Flag = nil;
local S3Flag = nil;
local S4Flag = nil;
local S5Flag = nil;
local S6Flag = nil;
local S7Flag = nil;
local  Period1, Period2,Period3,Period4,Period5,Period6;
--200, 100, 50, 25,12,6
-- Routine
 function Prepare(nameOnly)  
	source = instance.source;
	first = source:first();
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	S1Flag = instance.parameters.S1Flag;
	S2Flag = instance.parameters.S2Flag;
	S3Flag = instance.parameters.S3Flag;
	S4Flag = instance.parameters.S4Flag;
	S5Flag = instance.parameters.S5Flag;
	S6Flag = instance.parameters.S6Flag;
    S7Flag = instance.parameters.S7Flag;
	
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Period3 = instance.parameters.Period3;
	Period4 = instance.parameters.Period4;
	Period5 = instance.parameters.Period5;
	Period6 = instance.parameters.Period6;
	
	Frame = instance.parameters.Frame;
	
	

	local name = profile:id() .. "(" .. source:name() ..", "  .. Method1.. ", " .. Period1.. ", " .. Period2.. ", " ..Period3.. ", " ..Period4.. ", " ..Period5.. ", " ..Period6 
	.. ", " .. Method2.. ", " .. Frame..  ")";
	instance:name(name);	
	
	if   (nameOnly) then
        return;
    end
	
	
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	MVA200 = core.indicators:create(Method1, source, Period1);
		
	firstPeriod = MVA200.DATA:first();
	
	
	residual200 = instance:addInternalStream(MVA200.DATA:first());
	residual200mva = core.indicators:create(Method1, residual200, Period2);
	
	residual100 = instance:addInternalStream(residual200mva.DATA:first());
	residual100mva = core.indicators:create(Method1, residual100, Period3 );
	
	residual50 = instance:addInternalStream(residual100mva.DATA:first());
	residual50mva = core.indicators:create(Method1, residual50, Period4);
	
	residual25 = instance:addInternalStream(residual50mva.DATA:first());
	residual25mva = core.indicators:create(Method1, residual25, Period5);
   
    residual12 = instance:addInternalStream(residual25mva.DATA:first());
	residual12mva = core.indicators:create(Method1, residual12, Period6); 
	
	residual6 = instance:addInternalStream(residual12mva.DATA:first());
   

		
	if S1Flag then	
	S1 = instance:addStream("firstMVA2001", core.Line, "MVA200", "MVA200", instance.parameters.Color1, MVA200.DATA:first());
    S1:setPrecision(math.max(2, instance.source:getPrecision()));
	S1:setWidth(instance.parameters.width1);
    S1:setStyle(instance.parameters.style1);
	else
	S1 = instance:addInternalStream(MVA200.DATA:first());
	end
	if S2Flag then
	S2 = instance:addStream("secondMVA1001", core.Line, "MWA100", "MWA100", instance.parameters.Color2, residual200mva.DATA:first());
    S2:setPrecision(math.max(2, instance.source:getPrecision()));
	S2:setWidth(instance.parameters.width2);
    S2:setStyle(instance.parameters.style2);
	else
	S2 = instance:addInternalStream(residual200mva.DATA:first());
	end
	if S3Flag then
	S3 = instance:addStream("thirdMVA1001", core.Line, "MWA50", "MWA50", instance.parameters.Color3, residual100mva.DATA:first());
    S3:setPrecision(math.max(2, instance.source:getPrecision()));
	S3:setWidth(instance.parameters.width3);
    S3:setStyle(instance.parameters.style3);
	else
	S3 = instance:addInternalStream(residual100mva.DATA:first());
	end
	if S4Flag then
	S4 = instance:addStream("fourthMVA1001", core.Line, "MWA25", "MWA25", instance.parameters.Color4, residual50mva.DATA:first());
    S4:setPrecision(math.max(2, instance.source:getPrecision()));
	S4:setWidth(instance.parameters.width4);
    S4:setStyle(instance.parameters.style4);
	else
	S4 = instance:addInternalStream(residual50mva.DATA:first());
	end
	if S5Flag then 
	S5 = instance:addStream("fifthMVA1001", core.Line, "MWA12", "MWA12", instance.parameters.Color5, residual25mva.DATA:first());
    S5:setPrecision(math.max(2, instance.source:getPrecision()));
	S5:setWidth(instance.parameters.width5);
    S5:setStyle(instance.parameters.style5);
    else
	S5 = instance:addInternalStream(residual25mva.DATA:first());
    end
	if S6Flag then 
	S6 =  instance:addStream("sixthMVA1001", core.Line, "MVA6", "MVA6", instance.parameters.Color6, residual12mva.DATA:first());
    S6:setPrecision(math.max(2, instance.source:getPrecision()));
	S6:setWidth(instance.parameters.width6);
    S6:setStyle(instance.parameters.style6);
    else
	S6 = instance:addInternalStream(residual12mva.DATA:first());
    end
	
	BUFFER = instance:addInternalStream(0);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	AVERAGE = core.indicators:create(Method2, BUFFER, Frame);  
	
	if S7Flag then 
	S7 =  instance:addStream("OUT", core.Line, "WMA Average", "MWA Average", instance.parameters.Color7, AVERAGE.DATA:first());
    S7:setPrecision(math.max(2, instance.source:getPrecision()));
	S7:setWidth(instance.parameters.width7);
    S7:setStyle(instance.parameters.style7);
    else
	S7 = instance:addInternalStream( AVERAGE.DATA:first());
    end
     
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
	MVA200:update(mode);

	if( period >= 200 ) then
		S1[period] = 0;
		residual200[period] = source[period] - MVA200.DATA[period];
		residual200mva:update(mode);
	end
	
	if( period >= residual200mva.DATA:first() ) then
		residual100[period] = residual200[period] - residual200mva.DATA[period];
		residual100mva:update(mode);
		S2[period] =  residual200mva.DATA[period];
	end
	
	if( period >= residual100mva.DATA:first() ) then		
		residual50[period] = residual100[period] - residual100mva.DATA[period];
		residual50mva:update(mode);
		S3[period] =  residual100mva.DATA[period];
	end
		
	if( period >= residual50mva.DATA:first() ) then
		residual25[period] = residual50[period] - residual50mva.DATA[period];
		residual25mva:update(mode);
		S4[period] =  residual50mva.DATA[period];
	end	

      if( period >= residual25mva.DATA:first() ) then
		residual12[period] = residual25[period] - residual25mva.DATA[period];
		residual12mva:update(mode);
		S5[period] = residual25mva.DATA[period];
	end	
	
	

      if( period >= residual12mva.DATA:first() ) then
		residual6[period] = residual12[period] - residual12mva.DATA[period];
		S6[period] = residual12mva.DATA[period];
		
	end	
	
	   
	 BUFFER[period]= (S1[period]+S2[period]+S3[period]+S4[period]+S5[period]+S6[period]);	
	 
	 AVERAGE:update(mode); 
	   
	   
	   if( period <AVERAGE.DATA:first()) then
       return;
       end	   
         	  	   	   
	   S7[period]= AVERAGE.DATA[period];
	        
    
end