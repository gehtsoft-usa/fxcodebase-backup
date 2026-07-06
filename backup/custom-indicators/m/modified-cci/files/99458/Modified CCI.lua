-- Id: 13863
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62039

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Modified CCI");
    indicator:description("Modified CCI");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addInteger("CCI_Period", "CCI Period", "CCI Period", 12);
	indicator.parameters:addInteger("T3_Period", "T3 Period", "T3 Period", 10, 1, 2000);
	indicator.parameters:addDouble("b", "B", "B", 0.5);
	indicator.parameters:addString("Method", "Bar Color Method", "Method" , "Zero");
    indicator.parameters:addStringAlternative("Method", "Zero", "Zero" , "Zero");
    indicator.parameters:addStringAlternative("Method", "Previous", "Previous" , "Previous"); 
    indicator.parameters:addStringAlternative("Method", "Not Used", "Not Used" , "Not Used");
 
	
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("CCI_color", "Color of CCI", "Color of CCI", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	  
	
	indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","",100);
    indicator.parameters:addDouble("oversold","Oversold Level","", -100);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CCI_Period; 
local first;
local source = nil; 
-- Streams block
local CCI,cci;
local Method; 
local b2, b3,c1, c2, c3, c4, n, w1, w2,b;
local T3_Period;
local  e1;
local  e2;
local  e3;
local  e4;
local  e5;
local  e6;  
-- Routine
function Prepare(nameOnly)
    CCI_Period = instance.parameters.CCI_Period; 	
    Multiplier= instance.parameters.Multiplier;
	Method= instance.parameters.Method;
	T3_Period= instance.parameters.T3_Period;
	b= instance.parameters.b;
    source = instance.source; 
	
 
    b2 = b*b;                     
    b3 = b2*b;                   
    c1 = -b3;                     
    c2 = (3*(b2 + b3));           
    c3 = -3*(2*b2 + b + b3);     
    c4 = (1 + 3*b + b3 + 3*b2);  
    n = T3_Period;
 
    if(n < 1) then
        n = 1;
	end	
    n = 1 + 0.5*(n - 1);
    w1 = 2 / (n + 1);
    w2 = 1 - w1;    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(T3_Period).. ", " .. tostring(b).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        cci = core.indicators:create("CCI", source, CCI_Period);
        first = source:first();
        
        e1= instance:addInternalStream(0, 0);
        e2= instance:addInternalStream(0, 0);
        e3= instance:addInternalStream(0, 0);
        e4= instance:addInternalStream(0, 0);
        e5= instance:addInternalStream(0, 0);
        e6= instance:addInternalStream(0, 0);  
        CCI = instance:addStream("CCI", core.Line, name, "CCI", instance.parameters.CCI_color, first);
    CCI:setPrecision(math.max(2, instance.source:getPrecision()));
		if Method~= "Not Used" then
		Bar = instance:addStream("Bar", core.Bar, name, "Bar", instance.parameters.CCI_color, first);
    Bar:setPrecision(math.max(2, instance.source:getPrecision()));
		else
		Bar = instance:addInternalStream(0, 0);
		end
		CCI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		CCI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
        CCI:setWidth(instance.parameters.width1);
        CCI:setStyle(instance.parameters.style1);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    cci:update(mode); 

    if period < first or not  source:hasData(period) then
	return;
	end
	
 
       e1[period] = w1*cci.DATA [period] + w2*e1[period-1];
       e2[period] = w1*e1[period] + w2*e2[period-1];
       e3[period] = w1*e2[period] + w2*e3[period-1];
       e4[period] = w1*e3[period] + w2*e4[period-1];
       e5[period] = w1*e4[period] + w2*e5[period-1];
       e6[period] = w1*e5[period] + w2*e6[period-1];    
 
        CCI[period] = c1*e6[period] + c2*e5[period] + c3*e4[period] + c4*e3[period];  
        Bar[period] =CCI[period];
	
    if Method == "Zero" then	
		if CCI[period]> 0 then
		Bar:setColor(period, instance.parameters.Up_color);
	    else
		Bar:setColor(period, instance.parameters.Down_color);
		end
	elseif Method == "Previous" then
	    if CCI[period]> CCI[period-1] then
		Bar:setColor(period, instance.parameters.Up_color);
	    else
		Bar:setColor(period, instance.parameters.Down_color);
		end
	end
	
end

