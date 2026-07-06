-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=71090

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Three Line Break");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period3", "1. Period", "", 14, 2, 2000);
    indicator.parameters:addInteger("Period1", "2. Period", "", 14, 2, 2000);
	
    indicator.parameters:addInteger("Period2", "3. Period", "", 1, 1, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
 
local first;
local source = nil;
local Line1, Line2,Line3, Line4; 
local Trend;
local Top,Bottom;
local Transparency;
-- Routine
 function Prepare(nameOnly)   
 
 
    Transparency= instance.parameters.Transparency;
    Transparency= 100-Transparency;
   
	
	local Parameters= "";
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first() ;
	
	Trend= instance:addInternalStream(0, 0);
	
    Line1= instance:addInternalStream(0, 0);
	Line2= instance:addInternalStream(0, 0);
	Line3= instance:addInternalStream(0, 0);
	Line4= instance:addInternalStream(0, 0);
 
	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.color1, first );
	Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:setPrecision(math.max(2, source:getPrecision()));
	
	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.color2, first );
	Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:setPrecision(math.max(2, source:getPrecision()));
	
	
	instance:createChannelGroup("Group","Group" , Top, Bottom, instance.parameters.color1, Transparency);
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period <= first then
	return;
	end
	
	
	Trend[period]=1;	
	Line1[period]=source[period];
	Line2[period]=source[period];
	Line3[period]=source[period];
	Line4[period]=source[period];
	
	
	
	if Trend[period -1] == 1 then
			if source[period] > Line1[period-1] then
			Line4[period]= Line3[period-1]
			Line3[period]= Line2[period-1]
			Line2[period]= Line1[period-1]
			Line1[period]= source[period];
			Trend[period]= 1
		elseif source[period] < Line4[period-1] then
			Line4[period]= Line2[period-1]
			Line3[period]= Line2[period-1]
			Line2[period]= Line2[period-1]
			Line1[period]= source[period];
			Trend[period]= -1
		else
        Trend[period]= 1;
		end
else
		if source[period] > Line4[period-1]  then
		Line4[period]= Line2[period-1]
		Line2[period]= Line2[period-1]
		Line2[period]= Line2[period-1]
		Line1[period]= source[period]
		Trend[period]= 1;
		elseif source[period] < Line1[period-1]  then
		Line4[period]= Line3[period-1]
		Line3[period]= Line2[period-1]
		Line2[period]= Line1[period-1]
		Line1[period]= source[period]
		Trend[period]= -1;
		else
		Trend[period]= -1;
        end

end		


Top[period]=Line1[period];
Bottom[period]=Line4[period];


if Trend[period]==1 then
Top:setColor(period, instance.parameters.color1);
else
Top:setColor(period, instance.parameters.color2);
end

 
end

 