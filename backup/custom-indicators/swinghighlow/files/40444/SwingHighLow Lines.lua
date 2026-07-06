
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23506 
 
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
    indicator:name("Swing High/Low");
    indicator:description("Swing High/Low");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
   
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("Size", "Arrow Size", "", 12);
    indicator.parameters:addColor("clrUP", "Up Swing Color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", "Down Swing Color", "", core.COLOR_DOWNCANDLE);
	indicator.parameters:addGroup("Line Style");
	indicator.parameters:addBoolean("Lines", "Add line to most recent signals", "", true);
   
    indicator.parameters:addGroup("Top Line Style");
     for i= 1, 10 , 1 do
	 AddUP(i);
	 end
	 
     indicator.parameters:addGroup("Bottom Line Style");
     for i= 1, 10 , 1 do
	 AddDOWN(i);
	 end
end

function AddUP(i)

    indicator.parameters:addInteger("top_width"..i, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("top_style"..i, "Line style", "", core.LINE_SOLID );
    indicator.parameters:setFlag("top_style"..i, core.FLAG_LINE_STYLE);
	 indicator.parameters:addColor("top_color"..i, "Line color", "",core.COLOR_DOWNCANDLE);
end

function AddDOWN(i)

    indicator.parameters:addInteger("bottom_width"..i, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("bottom_style"..i, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("bottom_style"..i, core.FLAG_LINE_STYLE);
	 indicator.parameters:addColor("bottom_color"..i, "Line color", "",core.COLOR_UPCANDLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local SLOPE;
local SLH;
local LOW,HIGH;
local LAST;
local Size;
local Lines;
local Higher;
local Lower;

local bottom_style={};
local bottom_color={};
local bottom_width={};

local top_style={};
local top_color={};
local top_width={};
-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
    first = source:first()+6;
	
    
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if nameOnly then
	return;
	end
	
	 for i= 1, 10 ,1 do
	 top_style[i]=instance.parameters:getInteger("top_style" .. i)
     top_color[i]=instance.parameters:getColor("top_color" .. i);
     top_width[i]=instance.parameters:getInteger("top_width" .. i)
	 
	 bottom_style[i]=instance.parameters:getInteger("bottom_style" .. i)
     bottom_color[i]=instance.parameters:getColor("bottom_color" .. i);
     bottom_width[i]=instance.parameters:getInteger("bottom_width" .. i)
	 end
	
	
	Size= instance.parameters.Size;
	Lines=instance.parameters.Lines;
 
 
     Higher = instance:addInternalStream(0, 0);
     Lower= instance:addInternalStream(0, 0);
	 
     up = instance:createTextOutput ("Up", "Up", "Verdana", Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
	 down = instance:createTextOutput ("Dn", "Dn", "Verdana", Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    local Note, Color;
	if period < first or not source:hasData(period) then
        return;
    end

	  
	  if period == first then
	  HIGH=period;
	  LOW=period;
	  end
	
	
	 local curr = period - 2;
        if (source.high[curr]  > source.high[curr -1]  and source.high[curr] > source.high[curr -2] and
            source.high[curr]  > source.high[curr + 1] and source.high[curr]  > source.high[curr+2]) then
			
			if LAST  and  source.high[HIGH] < source.high[curr] then
			up:setNoData (HIGH);
			elseif LAST then
			return;
			end
			
			
			if source.high[curr] > source.high[HIGH]  then
             Note="HH";
			 Color = instance.parameters.clrUP;
			 Higher[curr]=2;
			else
			Note="LH";
			Color = instance.parameters.clrDN;
			Higher[curr]=1;
			end
			 
			up:set(curr, source.high[curr], Note, source.high[curr],Color);	
            LAST= true;			
			HIGH= curr;
			
			
           
        end
         
        if (source.low[curr]  < source.low[curr -1] and source.low[curr] < source.low[curr -2] and
            source.low[curr] < source.low[curr + 1] and source.low[curr] < source.low[curr+2]) then
			
			if not LAST   and  source.low[LOW] > source.low[curr] then
			down:setNoData (LOW);
			elseif not LAST then
			return;			
			end
			
			if source.low[curr] < source.low[LOW]  then
             Note="LL";
			 Color = instance.parameters.clrDN;
			 Lower[curr]=2;
			 
			else
			Note="HL";
			Color = instance.parameters.clrUP;
			 Lower[curr]=1;
			end
			 
            down:set(curr, source.low[curr], Note, source.low[curr],Color);
            LOW= curr;
			LAST= false;
			
        end
	 

	 
	 if period < source:size()-1 or not Lines then
	 return;
	 end
	  local Price;
      local T=0;
	  local B=0;
	  
	    for p = period, first, -1 do 
				  if Higher[p]~= 0 and T<10 then
				  T=T+1;  
				  Price=source.high[p];
				  core.host:execute ("drawLine", T, source:date(p), Price, source:date(source:size()-1), Price, top_color[T], top_style[T], top_width[T], Price)
				  end
				  
				  if Lower[p]~= 0 and B<10 then
				  B=B+1;	   
				 Price=source.low[p];
				  core.host:execute ("drawLine", 100+B, source:date(p), Price, source:date(source:size()-1), Price, bottom_color[B], bottom_style[B], bottom_width[B], Price)
				  
				  end
		  
		  if T== 10 and B == 10 then
		  break;
		  end
	  
	  end
	 
end

