-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27847
-- Id: 8180

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
    indicator:name("Gaussian Bands");
    indicator:description("Gaussian Bands");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("CP", "Central Line Period", "Central Line Period", 12);
    indicator.parameters:addInteger("D1", "1. Deviation Period", "1. Deviation Period", 12);
    indicator.parameters:addInteger("M1", "1. Multiplier", "1. Multiplier", 2);
    indicator.parameters:addInteger("D2", "2. Deviation Period", "2. Deviation Period", 12);
    indicator.parameters:addInteger("M2", "2. Multiplier", "2. Multiplier", 4);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top2_color", "Color of Top2", "Color of Top2", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("widthT2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleT2", "Line style", "", core.LINE_SOLID);	
    indicator.parameters:setFlag("styleT2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Top1_color", "Color of Top1", "Color of Top1", core.rgb(200, 0, 0));
	indicator.parameters:addInteger("widthT1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleT1", "Line style", "", core.LINE_SOLID);	
    indicator.parameters:setFlag("styleT1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Central_color", "Color of Central", "Color of Central", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);	
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("Bottom1_color", "Color of Bottom1", "Color of Bottom1", core.rgb(0,  200,0 ));
	indicator.parameters:addInteger("widthB1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleB1", "Line style", "", core.LINE_SOLID);	
    indicator.parameters:setFlag("styleB1", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("Bottom2_color", "Color of Bottom2", "Color of Bottom2", core.rgb(0,  255,0));
	
	indicator.parameters:addInteger("widthB2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleB2", "Line style", "", core.LINE_SOLID);	
    indicator.parameters:setFlag("styleB2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local CP;
local D1;
local M1;
local D2;
local M2;

local first;
local source = nil;

-- Streams block
local Top2 = nil;
local Top1 = nil;
local Central = nil;
local Bottom1 = nil;
local Bottom2 = nil;
local A={};
local var, var1, var2;
-- Routine
function Prepare(nameOnly)
    CP = instance.parameters.CP;
    D1 = instance.parameters.D1;
    M1 = instance.parameters.M1;
    D2 = instance.parameters.D2;
    M2 = instance.parameters.M2;
    source = instance.source;
    first = source:first();
	
	A["C"]= Alfa(CP)
	A["D1"]= Alfa(D1)
	A["D2"]= Alfa(D2)
	
	 

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(CP) .. ", " .. tostring(D1) .. ", " .. tostring(M1) .. ", " .. tostring(D2) .. ", " .. tostring(M2) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
	
	    Central = instance:addStream("Central", core.Line, name .. ".Central", "Central", instance.parameters.Central_color, first);
		Central:setWidth(instance.parameters.width);
        Central:setStyle(instance.parameters.style);
	    var = instance:addInternalStream(0, 0);
		var1 = instance:addInternalStream(0, 0);
		var2 = instance:addInternalStream(0, 0);

        Top2 = instance:addStream("Top2", core.Line, name .. ".Top2", "Top2", instance.parameters.Top2_color, first);
		Top2:setWidth(instance.parameters.widthT2);
        Top2:setStyle(instance.parameters.styleT2);
		
        Top1 = instance:addStream("Top1", core.Line, name .. ".Top1", "Top1", instance.parameters.Top1_color, first);
		Top1:setWidth(instance.parameters.widthT1);
        Top1:setStyle(instance.parameters.styleT1);
        
        Bottom1 = instance:addStream("Bottom1", core.Line, name .. ".Bottom1", "Bottom1", instance.parameters.Bottom1_color, first);
		Bottom1:setWidth(instance.parameters.widthB1);
        Bottom1:setStyle(instance.parameters.styleB1);
		
        Bottom2 = instance:addStream("Bottom2", core.Line, name .. ".Bottom2", "Bottom2", instance.parameters.Bottom2_color, first);
		Bottom2:setWidth(instance.parameters.widthB2);
        Bottom2:setStyle(instance.parameters.styleB2);
    end
end

function Alfa(p)

    local alfa, beta, w;
	
     w = 2*math.pi/p;
	  beta = (1 - math.cos(w))/(math.pow(1.414,2.0/3) - 1);
	 alfa = -beta + math.sqrt(beta*beta + 2*beta);
	 return alfa;
end


function  SMOOTH(price, arr, alfa, period)
	    arr[period] = math.pow(alfa,4)*price[period] + 4*(1-alfa)*arr[period-1] - 6*math.pow(1-alfa,2)*arr[period-2] + 4*math.pow(1-alfa,3)*arr[period-3] - math.pow(1-alfa,4)*arr[period-4];
       
end	   

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first +4  then
	return;
	end
	
	
	  SMOOTH(source,Central,A["C"], period);
      var[period]=math.abs(source[period]-Central[period]);
    
      SMOOTH(var,var1,A["D1"],period);
      SMOOTH(var,var2,A["D2"],period);

	
        Top2[period] =  Central[period]+(var1[period]*M2);  
        Top1[period] = Central[period]+(var1[period]*M1);    
        Bottom1[period] = Central[period]-(var1[period]*M1);  
        Bottom2[period] = Central[period]-(var1[period]*M2);  
 
end

