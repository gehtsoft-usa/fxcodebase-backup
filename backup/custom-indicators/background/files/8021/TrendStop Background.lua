-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3351

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
    indicator:name("TrendStop Background");
    indicator:description("TrendStop Background");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Trend Stop Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 10);
	indicator.parameters:addString("Type" ,"Triger", "", "Close");
    indicator.parameters:addStringAlternative("Type", "Close", "", "Close");
    indicator.parameters:addStringAlternative("Type", "High/Low", "", "High");
	
	indicator.parameters:addString("SignalType" ,"Signal Type", "", "Position");
    indicator.parameters:addStringAlternative("SignalType", "Position", "", "Position");
    indicator.parameters:addStringAlternative("SignalType", "Slope", "", "Slope")
	
     indicator.parameters:addGroup("Style");
     indicator.parameters:addInteger("Transparency", "Transparency", "", 80,0,100);
 
     indicator.parameters:addColor("up_color", "Up Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("dn_color", "Down Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("no_color", "Down Color", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;

-- Streams block
local Transparency = nil;
local Indicator;
local MIN,MAX;
local min,max;
local up_color,dn_color,no_color;
local Period, Type;
local Last;
local SignalType;
-- Routine
function Prepare(nameOnly)  
    no_color = instance.parameters.no_color;
     
    Transparency = instance.parameters.Transparency;
	up_color = instance.parameters.up_color;
	dn_color  = instance.parameters.dn_color;
	Transparency= 100-Transparency;
	
	Period  = instance.parameters.Period;
	Type  = instance.parameters.Type;
	SignalType  = instance.parameters.SignalType;
	
    source = instance.source;
	
	local name = profile:id() .. "(" .. source:name()   ..")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	assert(core.indicators:findIndicator("TRENDSTOP") ~= nil, "Please, download and install TRENDSTOP.BIN indicator");
	Indicator=core.indicators:create("TRENDSTOP", source,  Period, Type);
	first =Indicator.DATA:first();
	
    
	
	
	 MAX=instance:addInternalStream(source:first(), 0);
	 MIN=instance:addInternalStream(source:first(), 0);
    
	
	instance:createChannelGroup("Group","Group" , MIN, MAX, up_color, Transparency);
    Last=nil;
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    if period < first  then
	MIN:setColor(period,core.rgb( 255, 255, 255))
	Last=nil;
	return;
	end		
	
	if period <source:size()-1
	or Last== source:serial(period)
	then
	return;
	end
	
	
	local min,max= mathex.minmax(source,source:first(), source:size()-1);
	min=0;
	max= max*2;
	
	 
	 Last= source:serial(period);
	 
	
	
	Indicator:update(core.UpdateAll );
	local i;
	
			for i=source:first(), source:size()-1,1 do
			
			MAX[i] = max;
			MIN[i] = min;
			
			    if  Indicator.DATA:hasData(i)  and  Indicator.DATA:hasData(i-1) then	
                    if SignalType == "Position"	then			
							if source.close[i]> Indicator.DATA[i] then
							MIN:setColor(i,up_color);	
							elseif  source.close[i]< Indicator.DATA[i] then
							MIN:setColor(i,dn_color);
							else
							MIN:setColor(i,no_color)
							end
					else
					
					        if Indicator.DATA[i]> Indicator.DATA[i-1] then
							MIN:setColor(i,up_color);	
							elseif Indicator.DATA[i]< Indicator.DATA[i-1] then
							MIN:setColor(i,dn_color);
							else
							MIN:setColor(i,no_color)
							end
					end
				end	
			end
	 
       
end

