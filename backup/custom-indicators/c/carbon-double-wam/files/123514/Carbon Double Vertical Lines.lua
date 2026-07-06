-- Id: 23743
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67297

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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

function Init()
    indicator:name("Carbon Double Vertical Lines");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
 
 
   indicator.parameters:addGroup("Selector"); 
    indicator.parameters:addBoolean("Show1", "Show 1./Zero Line Cross", "", true);
	indicator.parameters:addBoolean("Show2", "Show 2./Zero Line Cross", "", true);
	indicator.parameters:addBoolean("Show12", "Show 1./2. Line Cross", "", true);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 21, 1, 2000);
	indicator.parameters:addInteger("Period2", "2. Period", "", 3, 1, 2000);
	
	indicator.parameters:addInteger("Lag1", "Primary Lag", "", 1, 1, 2000);
 
    indicator.parameters:addInteger("Period3", "1. Smoothing Period", "", 21, 1, 2000);
	indicator.parameters:addInteger("Period4", "2. Smoothing Period", "", 21, 1, 2000);
	
	indicator.parameters:addInteger("Lag2", "Smoothing Lag", "", 1, 1, 2000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1U", "1. Line Cross Over Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color1D", "1. Line Cross Under Color", "", core.rgb(0, 200, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	 indicator.parameters:addColor("color2U", "2. Line Cross Over Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("color2D", "2. Line Cross Under Color ", "", core.rgb(200, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addColor("color12U", "1/2. Line Cross Over Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("color12D", "1/2. Line Cross Under Color" , "", core.rgb(0, 0, 200));
	indicator.parameters:addInteger("style12", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style12", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width12", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method1, Period1, Period2, Period3, Period4;
local Lag1, Lag2;
local first;
local source = nil;
 
local First1, Second1;
local First2, Second2;
local DataA,DataB;
local A,B;
local C,D;
local E,F;
local Show1, Show2, Show12;
-- Routine
 function Prepare(nameOnly)   
 
 
    Show1= instance.parameters.Show1;
	Show2= instance.parameters.Show2;
	Show12= instance.parameters.Show12;
 
 
    Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	Period4= instance.parameters.Period4;
    Method= instance.parameters.Method;
    
	
	Lag2= instance.parameters.Lag2;
	Lag1= instance.parameters.Lag1;
	
	
	
	
	local Parameters= Period1  ..  ", " .. Period2 ..  ", " .. Lag1 ..  ", " ..Period3 ..  ", " ..Period4 ..  ", " .. Lag2 ..  ", " .. Method;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    A = core.indicators:create(Method, source, Period1);
    B = core.indicators:create(Method, source, Period2);
    
   
	
	DataA1 = instance:addInternalStream(0, 0);
	DataB1  = instance:addInternalStream(0, 0);
		
	C = core.indicators:create(Method, DataA1, Period3);
    D = core.indicators:create(Method, DataB1, Period3);
	
	DataA2 = instance:addInternalStream(0, 0);
	DataB2  = instance:addInternalStream(0, 0);
   
   
    E = core.indicators:create(Method, DataA2, Period4);
    F = core.indicators:create(Method, DataB2, Period4); 
	
	
	first=math.max(E.DATA:first(), F.DATA:first()) 
 
	First1= instance:addInternalStream(0, 0);
	 
	
	First2= instance:addInternalStream(0, 0);
	 
	
	Second1 = instance:addInternalStream(0, 0);
 
	
	Second2= instance:addInternalStream(0, 0);
 
	 instance:ownerDrawn(true); 
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    A:update(mode);
    B:update(mode);
	
	
    if period < math.max(A.DATA:first(), B.DATA:first())  +math.max(Lag1,Lag2)  then
	return;
	end
	
	DataA1[period]=A.DATA[period]-A.DATA[period-Lag1];
	DataB1[period]=B.DATA[period]-B.DATA[period-Lag2];
	
	
	C:update(mode);
    D:update(mode);
	
	
	if period < math.max(C.DATA:first(), D.DATA:first())+math.max(Lag1,Lag2) then
	return;
	end
	
	
	DataA2[period]=C.DATA[period]-C.DATA[period-Lag1];
	DataB2[period]=D.DATA[period]-D.DATA[period-Lag2];
	
	E:update(mode);
    F:update(mode);
	
	
	if period < first then
	return;
	end
		
    First1[period]=E.DATA[period]/source:pipSize();
    Second1[period]=F.DATA[period]/source:pipSize();

    First2[period]=-E.DATA[period]/source:pipSize();
    Second2[period]=-F.DATA[period]/source:pipSize();
				  
end


 
function Draw(stage, context)
    if stage~= 2 then
	 return;
	end
	
	 
	 
	 
	
        if not init then
		
		    context:createPen(11, context:convertPenStyle (instance.parameters.style1), instance.parameters.width1, instance.parameters.color1U); 
			context:createPen(12, context:convertPenStyle (instance.parameters.style1), instance.parameters.width1, instance.parameters.color1D); 
			
            context:createPen(21, context:convertPenStyle (instance.parameters.style2), instance.parameters.width2, instance.parameters.color2U); 
			context:createPen(22, context:convertPenStyle (instance.parameters.style2), instance.parameters.width2, instance.parameters.color2D); 
			
			
            context:createPen(31, context:convertPenStyle (instance.parameters.style12), instance.parameters.width12, instance.parameters.color12U); 
			context:createPen(32, context:convertPenStyle (instance.parameters.style12), instance.parameters.width12, instance.parameters.color12D); 
						
            init = true;
        end
		
	  
	  
	  
	    local First = math.max(first, context:firstBar ());
        local Last = math.min (context:lastBar (), source:size()-1);
		
  
			    for i= First, Last, 1 do	 
			    x, x1, x2 = context:positionOfBar (i);
						if Show1 and core.crossesOver (First1 , 0, i) then
						context:drawLine (11, x , context:top(), x , context:bottom());
						end
						
						if Show1 and core.crossesUnder (First1 , 0, i) then
						context:drawLine (12, x , context:top(), x , context:bottom());
						end
						
						if Show2 and core.crossesOver (Second1 , 0, i) then
						context:drawLine (21, x , context:top(), x , context:bottom());
						end
						
						if Show2 and core.crossesUnder (Second1 , 0, i) then
						context:drawLine (22, x , context:top(), x , context:bottom());
						end
						
						if Show12 and core.crossesOver (First1 , Second1  , i) then
						context:drawLine (31, x , context:top(), x , context:bottom());
						end
						
						if Show12 and core.crossesUnder (First1 , Second1  , i) then
						context:drawLine (32, x , context:top(), x , context:bottom());
						end
				
				end
  
end	

