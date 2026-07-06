-- Id: 19181
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65142

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
    indicator:name("MA Horizontal Lines");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
 

   Add(1, "m1", true);
   Add(2,"m5", true);
   Add(3,"m15", true);
   Add(4,"m30", true);
   Add(5,"H1",  false);
   Add(6,"H2", false);
   Add(7, "H3", false);
   Add(8,"H4", false);
   Add(9,"H6", false);
   Add(10,"H8",  false);
   Add(11,"D1", false);
   Add(12,"W1", false);
   Add(13,"M1",  false);
   
end

function Add(id, TF,  On)

indicator.parameters:addGroup(id ..". Line");
indicator.parameters:addBoolean("on"..id , "Show  This Line", "", On);


indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF);
 indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);

indicator.parameters:addString("Price"..id, "MA Price Source", "", "close");
indicator.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
indicator.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
indicator.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
indicator.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
indicator.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
indicator.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
indicator.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");	 

indicator.parameters:addInteger("Period"..id, "MA Period", "Period" , 50);

indicator.parameters:addString("Method"..id, "MA Method", "Method" , "MVA");
indicator.parameters:addStringAlternative("Method"..id, "MVA", "MVA" , "MVA");
indicator.parameters:addStringAlternative("Method"..id, "EMA", "EMA" , "EMA");
indicator.parameters:addStringAlternative("Method"..id, "LWMA", "LWMA" , "LWMA");
indicator.parameters:addStringAlternative("Method"..id, "TMA", "TMA" , "TMA");
indicator.parameters:addStringAlternative("Method"..id, "SMMA", "SMMA" , "SMMA");
indicator.parameters:addStringAlternative("Method"..id, "KAMA", "KAMA" , "KAMA");
indicator.parameters:addStringAlternative("Method"..id, "VIDYA", "VIDYA" , "VIDYA");
indicator.parameters:addStringAlternative("Method"..id, "WMA", "WMA" , "WMA");


indicator.parameters:addColor("color"..id , "Line Color", "", getRainbowColour(id/13));
indicator.parameters:addInteger("width"..id , "Indicator Line Width", "", 1, 1, 5);
indicator.parameters:addInteger("style"..id , "Indicator Line Style", "", core.LINE_SOLID);
indicator.parameters:setFlag("style"..id , core.FLAG_LINE_STYLE);

indicator.parameters:addInteger("Size"..id , "Font Size", "", 10);
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

function getRainbowColour(ratio)
    -- Using HSV colour system, where Hue is changed in proportion to ratio
    
    ratio = math.max(0, math.min(1, ratio));
    
    -- NOTE: hue is an angular value and can be 0..360, but it wraps around back to 'red' again
    -- which looks a bit weird so I limit to 300 degrees
    local hue = 300 * (1 - ratio);
    
    -- Convert back to RGB
    return convertHSVtoRGB(hue, 1, 1);
end
 
local color={};
local style={};
local width={};
local Size={};

local Price={};

local first;
local source;
local Source={};
local loading={};
local Number;

local Period={};
local MA={};
local Method={};
local TF={};

function Prepare(onlyName)
     
	source = instance.source; 
	first=source:first();
    local name;
    name = profile:id() .. "(" .. instance.source:name()  .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end 
	

	Number=0;
	
	for i= 1, 13 , 1 do
		if instance.parameters:getBoolean("on" .. i) then
		Number=Number+1;
		color[Number]=instance.parameters:getColor("color" .. i);
		width[Number]=instance.parameters:getInteger("width" .. i);
		style[Number]=instance.parameters:getInteger("style" .. i);
		Price[Number]=instance.parameters:getString("Price" .. i);	
		Method[Number]=instance.parameters:getString("Method" .. i);	
		Period[Number]=instance.parameters:getInteger("Period" .. i);	
		Size[Number]=instance.parameters:getInteger("Size" .. i);	
		TF[Number]=instance.parameters:getString("TF" .. i);	
		Source[Number] = core.host:execute("getSyncHistory", source:instrument(), TF[Number], source:isBid(), math.min(300,Period[Number]), 200+Number, 100+Number);
		loading[Number]=true;
    assert(core.indicators:findIndicator(Method[Number]) ~= nil, Method[Number] .. " indicator must be installed");
		MA[Number] = core.indicators:create(Method[Number], Source[Number][Price[Number]] ,  Period[Number]); 
		end
	end
	
   instance:ownerDrawn(true);
   
   core.host:execute ("setTimer", 1, 1);

end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

local j;
local FLAG=false; 
local Num=0;

    for j = 1, Number, 1 do
		       
			  if cookie == (100 + j) then
			  loading[j]  = true;
		      elseif  cookie == (200 + j ) then
			  loading[j]  = false;         
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
   
   
	if not FLAG and cookie== 1 then
			for i= 1, Number , 1 do
				  MA[i]:update(core.UpdateLast );
				 
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


function Update(period)     
end 


local init = false;

function Draw(stage, context)

   local j;
local FLAG=false; 
local Num=0;

    for j = 1, Number, 1 do
 	 
		       
                 if loading[j] then
				 FLAG= true;
				 end
	end    
   
   
   if FLAG then
   return;
   end
   

    if stage ~= 2 	
	then
	return;
	end
	
	
	local Shift= (context:right ()-context:left ())/Number;
	
        if not init then
		    for i=1, Number , 1 do
            context:createPen (i, context:convertPenStyle (style[i]), width[i], color[i]);
			context:createFont (20, "Arial", Size[i], Size[i], 0);
			end
            init = true;
         end
	
	
	
	for i=1, Number , 1 do
	
		if  MA[i].DATA:hasData(MA[i].DATA:size()-1) then
		visible, y = context:pointOfPrice (MA[i].DATA[MA[i].DATA:size()-1]);		 
		context:drawLine (i,  context:left (), y, context:right (), y);
		
		width, height = context:measureText (20, TF[i], 0)
		context:drawText (20, TF[i], color[i], -1, context:right ()-(i)*Shift, y-height, context:right ()-(i)*Shift+width, y, 0);
		end 
    end
	
end