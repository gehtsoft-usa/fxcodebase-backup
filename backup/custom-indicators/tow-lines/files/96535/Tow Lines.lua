-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61328

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
    indicator:name("Tow Lines");
    indicator:description("Tow Lines");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Period1", "A Line Period", "Period",20, 1,2000);
	indicator.parameters:addInteger("Period2", "B Line Period", "Period",6, 1,2000);
	indicator.parameters:addInteger("Period3", "C Line Period", "Period",5, 1,2000);
	
	indicator.parameters:addGroup("Style");	 
    indicator.parameters:addColor("color1", "Color of A", "Color of A", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Color of B", "Color of C", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color3", "Color of C", "Color of C", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_DOT );
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local A = nil;
local B = nil;
local C = nil;
local MID;
local MA1, MA2;
local Period1,Period2,Period3;
-- Routine
function Prepare(nameOnly) 
    source = instance.source;
	Period1=instance.parameters.Period1;
    Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period1.. ", " .. Period2.. ", " .. Period3.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	MID = instance:addInternalStream(0, 0);
	
	first = source:first()+Period1;

    if (not (nameOnly)) then
        A = instance:addStream("A", core.Line, name, "A", instance.parameters.color1, first);
		A:setWidth(instance.parameters.width1);
        A:setStyle(instance.parameters.style1);
		
		MA1 = core.indicators:create("MVA", A,Period2);
		MA2 = core.indicators:create("MVA", source.close,Period3);
		
		B = instance:addStream("B", core.Line, name, "B", instance.parameters.color2, MA1.DATA:first());
		B:setWidth(instance.parameters.width2);
        B:setStyle(instance.parameters.style2);
		C = instance:addStream("C", core.Line, name, "C", instance.parameters.color3, MA2.DATA:first());
		C:setWidth(instance.parameters.width3);
        C:setStyle(instance.parameters.style3);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    MID[period]= (3*source.close[period] +  source.low[period] + source.open[period]+ source.high[period])/6;
	
	MA2:update(mode);	
	if period > MA2.DATA:first() then 
	C[period] = MA2.DATA[period];
	end
	
	
    if period  <first   then
	return;
	end
	
	local Sum1=0;
	local Sum2=0;
	
	for i= 1, Period1, 1 do
	Sum1=Sum1+ (Period1-i+1)* MID[period-i+1]; 
	Sum2=Sum2+i;
	end	
	
	A[period]=Sum1/Sum2;
		
	MA1:update(mode);
	if period > MA1.DATA:first() then
	B[period] = MA1.DATA[period];
	end
	 
end

--[[
MID:=(3*CLOSE+LOW+OPEN+HIGH)/6;
A:(20*MID+19*REF(MID,1)+18*REF(MID,2)+17*REF(MID,3)+16*REF(MID,4)+15*REF(MID,5)+14*REF(MID,6)+13*REF(MID,7)+12*REF(MID,8)+11*REF(MID,9)+10*REF(MID,10)+9*REF(MID,11)+8*REF(MID,12)+7*REF(MID,13)+6*REF(MID,14)+5*REF(MID,15)+4*REF(MID,16)+3*REF(MID,17)+2*REF(MID,18)+REF(MID,20))/210,COLORRED;
B:MA(A,6),COLORGREEN;
C:MA(CLOSE,5),POINTDOT,COLORLIBLUE;
 ]]