-- Id: 11394

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60474

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
    indicator:name("Multiple CCI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    
    
   Add(1, 8 , Coloring (1, 5/2)); 
   Add(2, 10 , Coloring (2, 5/2)); 
   Add(3, 12 , Coloring (3, 5/2) ); 
   Add(4, 6 , Coloring (4, 5/2) ); 
   Add(5, 14 , Coloring (5, 5/2)); 
  
  --Replace 
  --Coloring (1, 5/2)
--  with core.rgb(44, 44, 44) 

   
    indicator.parameters:addGroup("Cycle Extreme");	
    indicator.parameters:addDouble("overbought1", "Cycle Extreme Up Level","", 150);
	indicator.parameters:addDouble("overbought2", "Cycle Extreme Up Level","", 100);
	indicator.parameters:addDouble("zero_line","Zero Line Level","", 0);
    indicator.parameters:addDouble("oversold1","Cycle Extreme Down Level","", -100);
	indicator.parameters:addDouble("oversold2","Cycle Extreme Down Level","", -150);

	indicator.parameters:addColor("bought_color1", "Over Bought Line Color","", core.rgb(44, 44, 44));
    indicator.parameters:addInteger("bought_width1","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("bought_style1", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("bought_style1", core.FLAG_LEVEL_STYLE);
	
		indicator.parameters:addColor("sold_color1", "Over Sold Line Color","", core.rgb(44, 44, 44));
    indicator.parameters:addInteger("sold_width1","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("sold_style1", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("sold_style1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addColor("bought_color2", "Over Bought Line Color","", core.rgb(44, 44, 44));
    indicator.parameters:addInteger("bought_width2","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("bought_style2", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("bought_style2", core.FLAG_LEVEL_STYLE);
	
		indicator.parameters:addColor("sold_color2", "Over Sold Line Color","", core.rgb(44, 44, 44));
    indicator.parameters:addInteger("sold_width2","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("sold_style2", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("sold_style2", core.FLAG_LEVEL_STYLE);

  	indicator.parameters:addColor("central_color", "Central Line Color","", core.rgb(44, 44, 44));
    indicator.parameters:addInteger("central_width","Central Line width","", 1, 1, 5);
    indicator.parameters:addInteger("central_style", "Central Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("central_style", core.FLAG_LEVEL_STYLE);
end

function Coloring (value, mid)

local color;

if value <= mid then
color = core.rgb(200 * (value / mid), 200, 0) 
else 
color = core.rgb(200, 200 - 200 * ((value - mid) / mid), 0)
end


return  color;

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
function Add(id, Period,Color  ) 

  indicator.parameters:addGroup(id .. ". Line");

  indicator.parameters:addBoolean("On"..id , "Show this line", "", true);	                     -- Shows Indicator Line
  indicator.parameters:addString("Label"..id , "Line Label", "", tostring(id));	                     -- Shows Indicator Line
  indicator.parameters:addInteger("Period".. id, "Period", "Period", Period);                    -- Shows Period
  indicator.parameters:addColor("Color".. id, "Line Color", "Line Color",Color );   -- Shows Line Color
  
  
  indicator.parameters:addInteger("width".. id, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style".. id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style".. id, core.FLAG_LINE_STYLE);

end
local Number= 5;
local first={};
local source = nil;
local Color={};
local Period={};
local On={};
-- Streams block
local CCI = {};
local cci={};
local Label={};
local width={};
local style={};
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
   
	
	local i;
	for i= 1 , Number , 1 do
	Label[i] = instance.parameters:getString("Label" .. i);
    On[i] = instance.parameters:getBoolean("On" .. i);
	Color[i] = instance.parameters:getDouble("Color" .. i);
	Period[i] = instance.parameters:getInteger("Period" .. i);
	width[i] = instance.parameters:getInteger("width" .. i);
	style[i] = instance.parameters:getInteger("style" .. i);
	end	

    local name = profile:id() .. ", " .. source:name()  
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	
	
	    for i= 1 , Number , 1 do
		    cci[i] = core.indicators:create("CCI", source, Period[i]);
			first[i]=cci[i].DATA:first();
			if On[i] then                                                    -- !!Removes CCI from label
			CCI[i] = instance:addStream("CCI"..i  , core.Line, Label[i], Label[i], Color[i], first[i]);
			CCI[i]:addLevel(instance.parameters.oversold1, instance.parameters.bought_style1, instance.parameters.bought_width1, instance.parameters.bought_color1);
		    CCI[i]:addLevel(instance.parameters.overbought1, instance.parameters.sold_style1, instance.parameters.sold_width1, instance.parameters.sold_color1);   
			CCI[i]:addLevel(instance.parameters.oversold2, instance.parameters.bought_style2, instance.parameters.bought_width2, instance.parameters.bought_color2);
		    CCI[i]:addLevel(instance.parameters.overbought2, instance.parameters.sold_style2, instance.parameters.sold_width2, instance.parameters.sold_color2);   
			CCI[i]:addLevel(instance.parameters.zero_line, instance.parameters.central_style, instance.parameters.central_width, instance.parameters.central_color);
			
			CCI[i]:setWidth(width[i]);
            CCI[i]:setStyle(style[i]);
			else
			CCI[i] = instance:addInternalStream(0, 0);
			end		
			
			
			CCI[i]:setPrecision(math.max(2, instance.source:getPrecision()));
		end
       
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    local i;
	for i= 1, Number, 1 do	   
	    cci[i]:update(mode);
		if period > first[i]  then
		CCI[i][period] = cci[i].DATA[period];
		end
 
	end
	    
end

