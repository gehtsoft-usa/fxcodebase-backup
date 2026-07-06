-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27846
-- Id: 8178

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
    indicator:name("Gaussian Rainbow");
    indicator:description("Gaussian Rainbow");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	

    indicator.parameters:addInteger("RainbowPeriod", "Rainbow Period", "Rainbow Period", 10);
    indicator.parameters:addInteger("GaussianOrder", "Gaussian Order", "GaussianOrder", 3);
	indicator.parameters:addIntegerAlternative("GaussianOrder","1", "", 1);
    indicator.parameters:addIntegerAlternative("GaussianOrder", "2", "", 2);
    indicator.parameters:addIntegerAlternative("GaussianOrder", "3", "", 3);
    indicator.parameters:addIntegerAlternative("GaussianOrder", "4", "", 4);
	
	
	
	indicator.parameters:addGroup("Style");	
	Add(1, Coloring (( 100/8)*1, 50));
	Add(2, Coloring((100/8)*2, 50));
	Add(3, Coloring((100/8)*3, 50));
	Add(4, Coloring((100/8)*4, 50));
	Add(5, Coloring((100/8)*5, 50));
	Add(6, Coloring((100/8)*6, 50));
	Add(7, Coloring((100/8)*7, 50));
	Add(8,Coloring((100/8)*8, 50));
end

function Coloring (value, mid)

local color;

if value <= mid then
color = core.rgb(255 * (value / mid), 255, 0) 
else 
color = core.rgb(255, 255 - 255 * ((value - mid) / mid), 0)
end


return  color;

end


    function Add (id, color)
    indicator.parameters:addColor("color".. id , id.. ". Line Color", "Color of Rainbow", color);
	indicator.parameters:addInteger("width"..id, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LINE_STYLE);	
	
	end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RainbowPeriod;
local GaussianOrder;

local first;
local source = nil;

-- Streams block
local Rainbow = {};
local w, beta, alfa;
-- Routine
function Prepare(nameOnly)
    RainbowPeriod = instance.parameters.RainbowPeriod;
    GaussianOrder = instance.parameters.GaussianOrder;
    source = instance.source;
    first = source:first()+4;
    local i;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(RainbowPeriod) .. ", " .. tostring(GaussianOrder) .. ")";
    instance:name(name);
	
	w = 2*math.pi/RainbowPeriod;
	beta = (1 - math.cos(w))/(math.pow(1.414,2.0/GaussianOrder) - 1);
	alfa = -beta + math.sqrt(beta*beta + 2*beta);

    if (not (nameOnly)) then
	    
		for i = 1, 8, 1 do
        Rainbow[i] = instance:addStream("Rainbow"..i, core.Line, name, "Rainbow"..i, instance.parameters:getInteger("color"..i), first);
		end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
           Rainbow[1][period] =0;
		   Rainbow[2][period]=0;
		    Rainbow[3][period] =0;
		     Rainbow[4][period]=0;
			 Rainbow[5][period]=0; 
			 Rainbow[6][period] =0;
			  Rainbow[7][period]=0;
			  Rainbow[8][period] =0;

    if period < first   then
	return;
	end
	
		if GaussianOrder == 1 then
		  Rainbow[1][period] = alfa*source[period] + (1-alfa)*Rainbow[1][period-1]; 
		   Rainbow[2][period] = alfa*Rainbow[1][period] + (1-alfa)*Rainbow[2][period-1]; 
		    Rainbow[3][period] = alfa*Rainbow[2][period] + (1-alfa)*Rainbow[3][period-1]; 
		     Rainbow[4][period] = alfa*Rainbow[3][period] + (1-alfa)*Rainbow[4][period-1];  
			 Rainbow[5][period] = alfa*Rainbow[4][period] + (1-alfa)*Rainbow[5][period-1]; 
			 Rainbow[6][period] = alfa*Rainbow[5][period] + (1-alfa)*Rainbow[6][period-1]; 
			  Rainbow[7][period] = alfa*Rainbow[6][period] + (1-alfa)*Rainbow[7][period-1]; 
			  Rainbow[8][period] = alfa*Rainbow[7][period] + (1-alfa)*Rainbow[8][period-1]; 
		elseif GaussianOrder == 2 then
		    Rainbow[1][period] = math.pow(alfa,2)*source[period] + 2*(1-alfa)*Rainbow[1][period-1] -   math.pow(1-alfa,2)*Rainbow[1][period-2];
		    Rainbow[2][period] = math.pow(alfa,2)*Rainbow[1][period] + 2*(1-alfa)*Rainbow[2][period-1] -   math.pow(1-alfa,2)*Rainbow[2][period-2]; 
		    Rainbow[3][period] = math.pow(alfa,2)*Rainbow[2][period] + 2*(1-alfa)*Rainbow[3][period-1] -   math.pow(1-alfa,2)*Rainbow[3][period-2];
		    Rainbow[4][period] = math.pow(alfa,2)*Rainbow[3][period] + 2*(1-alfa)*Rainbow[4][period-1] -   math.pow(1-alfa,2)*Rainbow[4][period-2];
		    Rainbow[5][period] = math.pow(alfa,2)*Rainbow[4][period] + 2*(1-alfa)*Rainbow[5][period-1] -   math.pow(1-alfa,2)*Rainbow[5][period-2]; 
		    Rainbow[6][period] = math.pow(alfa,2)*Rainbow[5][period] + 2*(1-alfa)*Rainbow[6][period-1] -   math.pow(1-alfa,2)*Rainbow[6][period-2];
		    Rainbow[7][period] = math.pow(alfa,2)*Rainbow[6][period] + 2*(1-alfa)*Rainbow[7][period-1] -   math.pow(1-alfa,2)*Rainbow[7][period-2];
		     Rainbow[8][period] = math.pow(alfa,2)*Rainbow[7][period] + 2*(1-alfa)*Rainbow[8][period-1] -   math.pow(1-alfa,2)*Rainbow[8][period-2];
	    elseif GaussianOrder == 3 then
		  Rainbow[1][period] = math.pow(alfa,3)*source[period] + 3*(1-alfa)*Rainbow[1][period-1] - 3*math.pow(1-alfa,2)*Rainbow[1][period-2] + math.pow(1-alfa,3)*Rainbow[1][period-3];
		   Rainbow[2][period] = math.pow(alfa,3)*Rainbow[1][period] + 3*(1-alfa)*Rainbow[2][period-1] - 3*math.pow(1-alfa,2)*Rainbow[2][period-2] + math.pow(1-alfa,3)*Rainbow[2][period-3];
		    Rainbow[3][period] = math.pow(alfa,3)*Rainbow[2][period] + 3*(1-alfa)*Rainbow[3][period-1] - 3*math.pow(1-alfa,2)*Rainbow[3][period-2] + math.pow(1-alfa,3)*Rainbow[3][period-3];
		    Rainbow[4][period] = math.pow(alfa,3)*Rainbow[3][period] + 3*(1-alfa)*Rainbow[4][period-1] - 3*math.pow(1-alfa,2)*Rainbow[4][period-2] + math.pow(1-alfa,3)*Rainbow[4][period-3];
			 Rainbow[5][period] = math.pow(alfa,3)*Rainbow[4][period] + 3*(1-alfa)*Rainbow[5][period-1] - 3*math.pow(1-alfa,2)*Rainbow[5][period-2] + math.pow(1-alfa,3)*Rainbow[5][period-3];
			 Rainbow[6][period] = math.pow(alfa,3)*Rainbow[5][period] + 3*(1-alfa)*Rainbow[6][period-1] - 3*math.pow(1-alfa,2)*Rainbow[6][period-2] + math.pow(1-alfa,3)*Rainbow[6][period-3];
			   Rainbow[7][period] = math.pow(alfa,3)*Rainbow[6][period] + 3*(1-alfa)*Rainbow[7][period-1] - 3*math.pow(1-alfa,2)*Rainbow[7][period-2] + math.pow(1-alfa,3)*Rainbow[7][period-3];
				 Rainbow[8][period] = math.pow(alfa,3)*Rainbow[7][period] + 3*(1-alfa)*Rainbow[8][period-1] - 3*math.pow(1-alfa,2)*Rainbow[8][period-2] + math.pow(1-alfa,3)*Rainbow[8][period-3];
			
        elseif GaussianOrder == 4 then
           Rainbow[1][period] = math.pow(alfa,4)*source[period] + 4*(1-alfa)*Rainbow[1][period-1] - 6*math.pow(1-alfa,2)*Rainbow[1][period-2] + 4*math.pow(1-alfa,3)*Rainbow[1][period-3] - math.pow(1-alfa,4)*Rainbow[1][period-4];
		    Rainbow[2][period] = math.pow(alfa,4)*Rainbow[1][period] + 4*(1-alfa)*Rainbow[2][period-1] - 6*math.pow(1-alfa,2)*Rainbow[2][period-2] + 4*math.pow(1-alfa,3)*Rainbow[2][period-3] - math.pow(1-alfa,4)*Rainbow[2][period-4];
			 Rainbow[3][period] = math.pow(alfa,4)*Rainbow[2][period] + 4*(1-alfa)*Rainbow[3][period-1] - 6*math.pow(1-alfa,2)*Rainbow[3][period-2] + 4*math.pow(1-alfa,3)*Rainbow[3][period-3] - math.pow(1-alfa,4)*Rainbow[3][period-4];
			 Rainbow[4][period] = math.pow(alfa,4)*Rainbow[3][period] + 4*(1-alfa)*Rainbow[4][period-1] - 6*math.pow(1-alfa,2)*Rainbow[4][period-2] + 4*math.pow(1-alfa,3)*Rainbow[4][period-3] - math.pow(1-alfa,4)*Rainbow[4][period-4];
			  Rainbow[5][period] = math.pow(alfa,4)*Rainbow[4][period] + 4*(1-alfa)*Rainbow[5][period-1] - 6*math.pow(1-alfa,2)*Rainbow[5][period-2] + 4*math.pow(1-alfa,3)*Rainbow[5][period-3] - math.pow(1-alfa,4)*Rainbow[5][period-4];
			  Rainbow[6][period]= math.pow(alfa,4)*Rainbow[5][period] + 4*(1-alfa)*Rainbow[6][period-1] - 6*math.pow(1-alfa,2)*Rainbow[6][period-2] + 4*math.pow(1-alfa,3)*Rainbow[6][period-3] - math.pow(1-alfa,4)*Rainbow[6][period-4];
			   Rainbow[7][period] = math.pow(alfa,4)*Rainbow[6][period] + 4*(1-alfa)*Rainbow[7][period-1] - 6*math.pow(1-alfa,2)*Rainbow[7][period-2] + 4*math.pow(1-alfa,3)*Rainbow[7][period-3] - math.pow(1-alfa,4)*Rainbow[7][period-4];
			   Rainbow[8][period] = math.pow(alfa,4)*Rainbow[7][period] + 4*(1-alfa)*Rainbow[8][period-1] - 6*math.pow(1-alfa,2)*Rainbow[8][period-2] + 4*math.pow(1-alfa,3)*Rainbow[8][period-3] - math.pow(1-alfa,4)*Rainbow[8][period-4];
	    end	
		


   
end

