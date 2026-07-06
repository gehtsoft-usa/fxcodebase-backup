-- Id: 22286
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66646

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

function Init()
    indicator:name("XO indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addDouble("BoxSize1", "Box Size 1", "", 6.5);
	indicator.parameters:addDouble("BoxSize2", "Box Size 2", "", 30);
 
 
	
	indicator.parameters:addGroup("1. Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("2. Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("1. Bar Style"); 	
    indicator.parameters:addColor("color3", "1. Bar Color", "", core.rgb(0, 255, 255));
 
	
	
	indicator.parameters:addGroup("2. Bar Style"); 	
    indicator.parameters:addColor("color4", "2. Bar Color", "", core.rgb(255, 0, 255));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local BoxSize1, BoxSize2; 
local first;
local source = nil;
local Pointsize; 
local kr2, no2;
local kr1, no1;
local hi1, hi2, lo1, lo2;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    BoxSize1= instance.parameters.BoxSize1;
    BoxSize2 = instance.parameters.BoxSize2;
			
    source = instance.source;
    first=source:first();
   
    Pointsize=source:pipSize();
	
	kr2 = instance:addStream("Line1" , core.Line, " Line1"," Line1",instance.parameters.color1, first);
    kr2:setPrecision(math.max(2, instance.source:getPrecision()));
	kr2:setWidth(instance.parameters.width1);
    kr2:setStyle(instance.parameters.style1);
	
	no2 = instance:addStream("Line2" , core.Line, " Line2"," Line2",instance.parameters.color2, first);
    no2:setPrecision(math.max(2, instance.source:getPrecision()));
	no2:setWidth(instance.parameters.width2);
    no2:setStyle(instance.parameters.style2);
	
	
	kr1 = instance:addStream("Line3" , core.Bar, " Line3"," Line3",instance.parameters.color3, first);
    kr1:setPrecision(math.max(2, instance.source:getPrecision()));
	no1 = instance:addStream("Line4" , core.Bar, " Line4"," Line4",instance.parameters.color4, first);
    no1:setPrecision(math.max(2, instance.source:getPrecision()));
	 
	hi1= instance:addInternalStream(0, 0);
	hi2= instance:addInternalStream(0, 0);
	lo1= instance:addInternalStream(0, 0);
	lo2= instance:addInternalStream(0, 0);
	
end

-- Indicator calculation routine
function Update(period, mode)

 
  
	local cur=source[period];
	
    if period <  first then
	return;
	end
	
	
	
	if period ==  first then 	
	hi1[period]=cur;
	hi2[period]=cur;
	lo1[period]=cur;
	lo2[period]=cur;
	no1[period] = 0
	no2[period] = 0
	kr1[period] = 0
	kr2[period] = 0
	else
	hi1[period]=hi1[period-1];
	hi2[period]=hi2[period-1];
	lo1[period]=lo1[period-1];
	lo2[period]=lo2[period-1];	
	no1[period] = no1[period-1]
	no2[period] = no2[period-1]
	kr1[period] = kr1[period-1]
	kr2[period] = kr2[period-1]
	end
	
		
if (cur > (hi1[period]+BoxSize1*Pointsize)) then
 hi1[period] = cur
 lo1[period] = cur-BoxSize1*Pointsize
 kr1[period] = kr1[period-1]+1
 no1[period] = 0
end
if (cur < (lo1[period]-BoxSize1*Pointsize)) then
 lo1[period] = cur
 hi1[period] = cur+BoxSize1*Pointsize
 no1[period] = no1[period-1]-1
 kr1[period] = 0
end
if (cur > (hi2[period]+BoxSize2*Pointsize)) then
 hi2[period] = cur
 lo2[period]  = cur-BoxSize1*Pointsize
 kr2[period] = kr2[period-1]+1
 no2[period] = 0
end
if (cur < (lo2[period]-BoxSize2*Pointsize)) then
 lo2[period]  = cur
 hi2[period]  = cur+BoxSize1*Pointsize
 no2[period] = no2[period-1]-1
 kr2[period] = 0
end
				  
end 

--[[
 //PRC_XO | indicator
//16.10.2017
//Nicolas @ www.prorealcode.com
//Sharing ProRealTime knowledge
//converted from MT4 version (original author mladen)

// --- settings
//BoxSize1 = 6.5 // First box size
//BoxSize2 = 30.0 // Second box size
// --- end of settings

BoxPrice = customclose // Price to use for box calculation

cur=BoxPrice
once hi1=cur
once hi2=cur
once lo1=cur
once lo2=cur

if (cur > (hi1+BoxSize1*Pointsize)) then
 hi1 = cur
 lo1 = cur-BoxSize1*Pointsize
 kr1 = kr1+1
 no1 = 0
endif
if (cur < (lo1-BoxSize1*Pointsize)) then
 lo1 = cur
 hi1 = cur+BoxSize1*pointsize
 no1 = no1-1
 kr1 = 0
endif
if (cur > (hi2+BoxSize2*pointsize)) then
 hi2 = cur
 lo2 = cur-BoxSize1*pointsize
 kr2 = kr2+1
 no2 = 0
endif
if (cur < (lo2-BoxSize2*pointsize)) then
 lo2 = cur
 hi2 = cur+BoxSize1*pointsize
 no2 = no2-1
 kr2 = 0
endif

return kr1 coloured(0,191,255) style(histogram),no1 coloured(219,112,147) style(histogram), 0 coloured(219,112,147) style(dottedline), 1 coloured(219,112,147) style(line), -1 coloured(219,112,147) style(line), kr2 coloured(255,215,0) style(line,3),no2 coloured(128,128,128) style(line,3)
]]
 
