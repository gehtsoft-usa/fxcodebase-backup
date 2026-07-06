-- Id: 13865

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=62040

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
    indicator:name("MTF Moving Average");
    indicator:description("MTF Moving Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    Add(1 ); 
    Add(2 ); 
    Add(3 ); 
    Add(4 ); 
    Add(5 ); 
    Add(6 ); 
    Add(7 ); 
    Add(8  ); 
    Add(9 ); 
    Add(10 ); 
	Add(11  ); 
    Add(12  ); 
    Add(13 ); 
	
	indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("Label", "Label Color", "Color of Label",core.rgb(0, 0, 0));
      indicator.parameters:addInteger("Size", "Font Size", "Font Size",10);
	  
	  indicator.parameters:addBoolean("Show", "Show Value", "", false);	
end
function Add(id )

    local TF={"m1", "m5","m15", "m30", "H1", "H2", "H3","H4", "H6", "H8", "D1", "W1", "M1"};
    indicator.parameters:addGroup(id .. ". Slot");	
	indicator.parameters:addBoolean("On"..id, "Use This Slot", "", true);	
	
	indicator.parameters:addString("TF" .. id, "Time Frame", "", TF[id]);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	
    
	
	indicator.parameters:addString("Price".. id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price".. id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price".. id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price".. id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price".. id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price".. id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price".. id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price".. id, "WEIGHTED", "", "weighted");	
   
    indicator.parameters:addInteger("Period" .. id, "MA Period", "", 14); 
	
	indicator.parameters:addString("Method".. id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method".. id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method".. id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method".. id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method".. id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method".. id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method".. id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method".. id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method".. id, "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addColor("Color".. id, "Line Color", "Color of Line",getRainbowColour((1/13)*id));
    
	
end 

function getRainbowColour(ratio)
    -- Using HSV colour system, where Hue is changed in proportion to ratio
    
    ratio = math.max(0, math.min(1, ratio));
    
    -- NOTE: hue is an angular value and can be 0..360, but it wraps around back to 'red' again
    -- which looks a bit weird so I limit to 300 degrees
    local hue = 300 * (1 - ratio);
    
    -- Convert back to RGB
    return convertHSVtoRGB(hue, 1, 1);
end

function convertHSVtoRGB(hue, saturation, value)
    -- http://en.wikipedia.org/wiki/HSL_and_HSV
    -- Hue is an angle (0..360), Saturation and Value are both in the range 0..1
    
    local hi = (math.floor(hue / 60)) % 6;
    local f = hue / 60 - math.floor(hue / 60);

    value = value * 255;
    local v = math.floor(value);
    local p = math.floor(value * (1 - saturation));
    local q = math.floor(value * (1 - f * saturation));
    local t = math.floor(value * (1 - (1 - f) * saturation));

    if hi == 0 then
        return core.rgb(v, t, p);
    elseif hi == 1 then
        return core.rgb(q, v, p);
    elseif hi == 2 then
        return core.rgb(p, v, t);
    elseif hi == 3 then
        return core.rgb(p, q, v);
    elseif hi == 4 then
        return core.rgb(t, p, v);
    else
        return core.rgb(v, p, q);
    end
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Size, Label;
local first;
local source = nil;
local Source={};
local Number;
-- Streams block
local Method = {};
local Period = {};
local Price = {};
local TF={};
local loading={};
local MA={};
local Color={};
local Show;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Size=  instance.parameters.Size;
	Label=  instance.parameters.Label;
	Show=  instance.parameters.Show;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    Number=0;
	
	for i= 1 , 13 , 1 do
	 if  instance.parameters:getBoolean("On" .. i)    then
	 Number=Number+1;
	 TF[Number]=  instance.parameters:getString("TF" .. i);	 
	 Period[Number]=  instance.parameters:getInteger("Period" .. i);	 
	 Method[Number]=  instance.parameters:getString("Method" .. i);
	 Price[Number]=  instance.parameters:getString("Price" .. i);
	 Color[Number]=  instance.parameters:getColor("Color" .. i);
     Source[Number]  = core.host:execute("getSyncHistory",  source:instrument(),  TF[Number], source:isBid(), math.min(Period[Number] ,300), 2000 + Number , 1000 +Number);	 
    assert(core.indicators:findIndicator(Method[Number]) ~= nil, Method[Number] .. " indicator must be installed");
     MA[Number] = core.indicators:create(Method[Number], Source[Number][Price[Number]], Period[Number]);	 
	 loading[Number]  = true;  	 
	 
	 end
	 
	end
	 core.host:execute ("setTimer", 1, 5);
	instance:ownerDrawn(true);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
end


local init = false;

function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end
	 
	 
	local FLAG=false; 

    for j = 1, Number, 1 do
		     
                if loading[j] then
				FLAG= true;			
				end
				 
	end    
    
	
	if FLAG then
	return;	 
	end
 
	 
  
      context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
    if not init then
	init =true;
		for i= 1, Number, 1 do
		context:createPen (i, context.SOLID, 1, Color[i])
		end
		context:createFont (Number+1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
	end
	local Shift=0;
	
	for i= 1, Number, 1 do	
			if MA[i].DATA:hasData(MA[i].DATA:size()-1) then
			visible, y= context:pointOfPrice (MA[i].DATA[MA[i].DATA:size()-1]);
			context:drawLine (i, context:left (), y,context:right (), y);
			
			local Text= TF[i];
			if Show then
			Text= Text .. " : " .. string.format("%." .. source:getPrecision() .. "f", MA[i].DATA[MA[i].DATA:size()-1]);
			end
			
			width, height = context:measureText (Number+1, Text, 0);
			Shift=Shift+width;
			context:drawText (Number+1, Text, Label, -1, context:right()-Shift, y-height, context:right()-Shift +width, y, 0);
			end
	end
end	


function AsyncOperationFinished(cookie)

local j;
local FLAG=false; 
local Num=0; 
    for j = 1, Number, 1 do
		   
			  if cookie == (1000 + j) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + j ) then
			  loading[j]  = false;     
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
   
     
	 if cookie == 1 and not FLAG then
	    for j = 1, Number, 1 do
	 	MA[j]:update(core.UpdateLast);
		end
		
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Num) .. " / " .. (Number) );	 
	else
	core.host:execute ("setStatus", "Loaded");
	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
	
end


