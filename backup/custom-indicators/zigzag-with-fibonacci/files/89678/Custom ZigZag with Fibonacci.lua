
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59571

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
    indicator:name("Custom ZigZag with Fibonacci");
    indicator:description("Automatic Fib or Gann levels on the base of H/L values");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
     indicator.parameters:addGroup("Zig Zag Parameters");
    indicator.parameters:addInteger("Depth", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
    indicator.parameters:addColor("ZigZag_color", "Color of ZigZag", "Color of ZigZag", core.rgb(255, 0, 0));
	
	
	 
  
	 
   indicator.parameters:addGroup("Levels Style");
   Add(1); 
   Add(2); 
   Add(3); 
   Add(4); 
   Add(5); 
   Add(6); 
   Add(7); 
   Add(8); 
   Add(9); 
   Add(10); 
   Add(11); 
   Add(12); 
   Add(13); 
   

    indicator.parameters:addGroup("Style");
    
    indicator.parameters:addColor("M_color", "Time marker color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("M_width", "Width of level lines", "", 1, 1, 5);
	  indicator.parameters:addInteger("M_style", "Style level lines", "", core.LINE_DOT);
    indicator.parameters:setFlag("M_style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Color", "Font color", "", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("Size", "Font Size", "", 10);  
	
    indicator.parameters:addBoolean("ShowLabels", "Show Line Labels", "", true);
	indicator.parameters:addBoolean("Show", "Show Fibonacci Lines", "", true);
	indicator.parameters:addBoolean("ShowZigZag", "Show ZigZag Line", "", true);
    indicator.parameters:addBoolean("Extend", "Extend Lines", "", true);
end

function Add(id)

   indicator.parameters:addGroup(id .. " Line");  
      local levels={ -0.25 ,-0.13, 0 , 0.125,  0.25,  0.375,  0.5,  0.625, 0.75,  0.875, 1, 1.13, 1.25 };	  
    
    indicator.parameters:addBoolean("On"..id , "Show  This Line", "", true);	
	indicator.parameters:addDouble("levels"..id , "Level", "", levels[id]);	
	
	  indicator.parameters:addGroup(levels[id] .. " Line Style");
    indicator.parameters:addColor("L_color".. id, "Color of level lines", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("L_width".. id, "Width of level lines", "", 1, 1, 5);
    indicator.parameters:addInteger("L_style".. id, "Style level lines", "", core.LINE_SOLID);
    indicator.parameters:setFlag("L_style".. id, core.FLAG_LINE_STYLE);
    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Depth;
local Deviation;
local Backstep;
local Color;
local Show,ShowZigZag;
local M;
local L;
local E;
local L_color={};
local L_width={};
local L_style={};
local M_color;
local M_width;
local M_style;
local ShowLabels;
local linelabel;
--local D = nil;
local barSize;
local format;
local On={};
local first;
local source = nil;

-- Streams block
local ZigZag = nil;
local HighMap = nil;
local LowMap = nil;


local searchBoth = 0;
local searchPeak = 1;
local searchLawn = -1;
local lastlow = nil;
local lashhigh = nil;

-- optimization hint
local g_last_peak_date = nil;
local g_last_peak = nil;
local g_prev_peak_date = nil;
local g_searchMode = nil;
local MIN = nil;
local MAX = nil;
local P = nil;
local levels = nil;
local Zig;
local Extend;
local Size;
-- Routine
 function Prepare(nameOnly)   

    Show = instance.parameters.Show;
	ShowZigZag = instance.parameters.ShowZigZag;
	Extend = instance.parameters.Extend;
	Size = instance.parameters.Size;
	Color = instance.parameters.Color;
     
   
    M_color  = instance.parameters.M_color;
    M_width  = instance.parameters.M_width;
    M_style = instance.parameters.M_style;
    ShowLabels = instance.parameters.ShowLabels;
	
		
	
	 levels = {};
  	  
	 local i;
     for i = 1, 13, 1 do	 
	  On[i]=instance.parameters:getBoolean ("On"..i);
	  levels[i] = instance.parameters:getDouble("levels"..i);
	  L_color[i] = instance.parameters:getDouble("L_color"..i);
       L_width[i] = instance.parameters:getDouble("L_width"..i);
      L_style[i] = instance.parameters:getDouble("L_style"..i);
    end
	
	
    source = instance.source;
    local s, e;
    s, e = core.getcandle(source:barSize(), core.now(), 0);
    barSize = math.floor(((e - s) * 1440) + 0.5) / 1440;
 
  
    format = "%.3f=%." .. source:getPrecision() .. "f";

    Depth = instance.parameters.Depth;
    Deviation = instance.parameters.Deviation;
    Backstep = instance.parameters.Backstep;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. Depth .. ", " .. Deviation .. ", " .. Backstep..   ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Zig = core.indicators:create("ZIGZAG", source, Depth,Deviation,Backstep);
    first = Zig.DATA:first();
	
	if ShowZigZag then
    ZigZag = instance:addStream("ZigZag", core.Line, name, "ZigZag", instance.parameters.ZigZag_color, first);
	else
	ZigZag= instance:addInternalStream(0, 0);
	end
    HighMap = instance:addInternalStream(0, 0);
    LowMap = instance:addInternalStream(0, 0);
	
	
	if   Show then
	instance:ownerDrawn(true);
	else
	instance:ownerDrawn(false);
	end
end



function Update(period, mode)


Zig:update(mode);

if period < first then
return;
end

if Zig.DATA[period]==0
or Zig.DATA[period]==nil
 then
ZigZag[period]=nil;
else
ZigZag[period]= Zig.DATA[period];
end


end

local init = false;

function Draw(stage, context)
 

   if stage ~= 2 then
   return;
   end
   
   
   
       if not init then
	   local j;
	   for j= 1 , 13 , 1 do
	   context:createPen (j,  context:convertPenStyle (L_style[j]) ,L_width[j], L_color[j])
	   end
	   
	   context:createPen (14, context:convertPenStyle (M_style),M_width, M_color)
	   context:createFont (15, "Arial", Size, Size, context.LEFT);
            init = true;
        end



local min, max, minp, maxp;
local p1=nil;
local p2=nil;

 
		
		for i= source:size()-2, first, -1 do  
		     
			 if Zig.DATA:hasData(i) then
			 
				if Zig.DATA[i]==0
				or Zig.DATA[i]==nil
				 then
				ZigZag[i]=nil;
				else
				ZigZag[i]= Zig.DATA[i];
				end
						   
				if p1== nil 
				and   ZigZag[i+1] ~= nil and ZigZag[i] ~= nil and ZigZag[i-1] ~= nil 
				and   ZigZag[i+1] ~= 0 and ZigZag[i] ~= 0 and ZigZag[i-1] ~= 0 
				then
					 if ZigZag[i]> ZigZag[i-1] and
					 ZigZag[i]> ZigZag[i+1] 
					 then
					  p1 =i;						
					 end
				end

				if p2== nil 
				and   ZigZag[i+1] ~= nil and ZigZag[i] ~= nil and ZigZag[i-1] ~= nil
				and   ZigZag[i+1] ~= 0 and ZigZag[i] ~= 0 and ZigZag[i-1] ~= 0
				then
					 if ZigZag[i]< ZigZag[i-1] and
					 ZigZag[i]< ZigZag[i+1] 
					 then
					  p2 =i;
						
					 end
				end

				if p1~= nil and  p2~= nil then
				break;
				end
			end
		end

local Direction;

if  ZigZag[p1]> ZigZag[p2] then
min=ZigZag[p2];
max=ZigZag[p1];
minp=p2;
maxp=p1;
Direction=1;
elseif ZigZag[p1]> ZigZag[p2] then
min=ZigZag[p1];
max=ZigZag[p2];
minp=p1;
maxp=p2;
Direction=-1;
else
return;
end

CalculateLevels(min, max, minp, maxp,Direction, context);

end

function CalculateLevels( min, max, minp, maxp,Direction, context)
   local N=10;
    
        local  p,i ,v, f, t, price, d, label;
     
        p = math.min(minp, maxp);
         
            

            local  visible1, y1,visible2, y2;
               if Extend then
				t=context:right ();
                f, x1, x2 = context:positionOfBar (p);			 
				else
				t=  context:positionOfBar (source:size()-1);
                 f, x1, x2 = context:positionOfBar (p);	
			   end	 
               
             MIN = min;
            MAX = max;
            d = max - min;
         
		   
            for i = 1, 13, 1  do 
			
			if On[i] then
			    if Direction == -1 then
                price = min +d * levels[i];
				else
				 price = max - d * levels[i];
				end
                label = string.format(format, levels[i], price);
				
                 visible1, y1 =  context:pointOfPrice (price);
				
					 context:drawLine (i, f, y1, t, y1);
				 
                if ShowLabels then
                    
				   local width, height = context:measureText (15, label, context.LEFT);
				   context:drawText (15, label, Color, -1, f, y1-height, f+width, y1, context.LEFT);
                end
			 end	
			 
            end
			   visible1, y1 =  context:pointOfPrice (min);
			   visible2, y2 =  context:pointOfPrice (max);
			 context:drawLine (14,  f, y1, f, y2);
      
        
     
end

