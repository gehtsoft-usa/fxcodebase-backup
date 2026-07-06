-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=367


--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("FBSR with Fibonacci levels");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Style");	  
    indicator.parameters:addColor("R_color", "Color of R", "Color of R", core.rgb(255, 192, 0));
    indicator.parameters:addColor("S_color", "Color of S", "Color of S", core.rgb(0, 192, 255));
	
	
	indicator.parameters:addInteger("W", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("S", "Line Style", " ", core.LINE_SOLID);
    indicator.parameters:setFlag("S", core.FLAG_LINE_STYLE);	
	indicator.parameters:addInteger("Size", "Font Size", "", 7, 1, 20);
	indicator.parameters:addColor("clrPrice", "Label Color", "", core.rgb(128, 128, 128));
	
	 indicator.parameters:addGroup("Price Overlay");
	 indicator.parameters:addBoolean("ShowPrice", "Show Price", "", false);
    
	
	 indicator.parameters:addGroup("Show Fibonacci levels");
	 indicator.parameters:addBoolean("ShowFibo", "Show Fibonacci levels", "", false);
	  indicator.parameters:addBoolean("F382", "Show 38,2 % Fibonacci levels", "", false);
	   indicator.parameters:addBoolean("F500", "Show 50 % Fibonacci levels", "", false);
	    indicator.parameters:addBoolean("F618", "Show 61,8 % Fibonacci levels", "", false);
		
		indicator.parameters:addInteger("FW", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("FS", "Line Style", " ", core.LINE_SOLID);
    indicator.parameters:setFlag("FS", core.FLAG_LINE_STYLE);	
	indicator.parameters:addColor("C382", "38,2 % Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("C500", "50 % Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("C618", "61,8 % Line Color", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;
local Size;
local ShowFibo;
local F382, F500, F618;

-- Streams block
local R = nil;
local S = nil;
local Top, Bottom;
local L382, L500, L618; 
local Label382, Label500, Label618; 
local format;

-- Routine
function Prepare()
     F382 = instance.parameters.F382;
	 F500 = instance.parameters.F500;
	 F618 = instance.parameters.F618;
    ShowFibo = instance.parameters.ShowFibo;
    Size = instance.parameters.Size;
    source = instance.source;
    first = source:first() + 4;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    R = instance:addStream("R", core.Line, name .. ".R", "R", instance.parameters.R_color, first);
    S = instance:addStream("S", core.Line, name .. ".S", "S", instance.parameters.S_color, first);
	
	R:setWidth(instance.parameters.W);
    R:setStyle(instance.parameters.S);
	
	S:setWidth(instance.parameters.W);
    S:setStyle(instance.parameters.S);
	
	
	L382= instance:addStream("S382", core.Line, name .. ".382", "382", instance.parameters.C382, first);
	L382:setWidth(instance.parameters.FW);
    L382:setStyle(instance.parameters.FS);
	L500= instance:addStream("S500", core.Line, name .. ".500", "500", instance.parameters.C500, first);
	L500:setWidth(instance.parameters.FW);
    L500:setStyle(instance.parameters.FS);
	L618= instance:addStream("S618", core.Line, name .. ".618", "618", instance.parameters.C618, first); 
	L618:setWidth(instance.parameters.FW);
    L618:setStyle(instance.parameters.FS);

	
	Label382 = instance:createTextOutput ("", "Label382", "Verdana", Size, core.H_Right, core.V_Top, instance.parameters.clrPrice, 0);
    Label500 = instance:createTextOutput ("", "Label500", "Verdana", Size, core.H_Right, core.V_Top, instance.parameters.clrPrice, 0);
	Label618 = instance:createTextOutput ("", "Label618", "Verdana", Size, core.H_Right, core.V_Top, instance.parameters.clrPrice, 0);
	
	Top = instance:createTextOutput ("", "Up", "Verdana", Size, core.H_Right, core.V_Top, instance.parameters.clrPrice, 0);
    Bottom = instance:createTextOutput ("", "Dn", "Verdana", Size, core.H_Right, core.V_Bottom, instance.parameters.clrPrice, 0);
	
	 format = "%." .. source:getPrecision() .. "f";

end

-- Indicator calculation routine
function Update(period)
    if period >= first and source:hasData(period) then
        -- defect fractals on two periods ago
        local up, down, curr, Level;
        up = false;
        down = false;
        curr = source.high[period - 2];
        if (curr >= source.high[period - 4] and curr >= source.high[period - 3] and
            curr >= source.high[period - 1] and curr >= source.high[period]) then
            up = true;
			
			if instance.parameters.ShowPrice then
                Top:set(period - 2, source.high[period - 2], "  " .. source.high[period - 2]);
            end
        end
        if up then
            R[period - 2] = curr;
            R[period - 1] = curr;
            R[period] = curr;
--            S[period-2]=nil;
            S[period-1]=nil;
            S[period]=nil;
			if R[period - 3]~= R[period - 2] then
			R:setBreak(period-2, true);
			end			
			
        else
            if R:hasData(period - 1) then
                R[period] = R[period - 1];				
            end
        end
        curr = source.low[period - 2];
        if (curr <= source.low[period - 4] and curr <= source.low[period - 3] and
            curr <= source.low[period - 1] and curr <= source.low[period]) then
            down = true;
			
	    	if instance.parameters.ShowPrice then
                Bottom:set(period - 2, source.low[period - 2], "  " .. source.low[period - 2]);
            end	
        end
        if down then
            S[period - 2] = curr;
            S[period - 1] = curr;
            S[period] = curr;
--            R[period-2]=nil;
            R[period-1]=nil;
            R[period]=nil;
			if S[period - 3]~= S[period - 2] then
			S:setBreak(period-2, true);
			end
			
			
			
        else
            if S:hasData(period - 1) then
                S[period] = S[period - 1];
				
            end
			
		
        end
		
		
		if S[period-3]~= S[period-2] or  R[period-3]~= R[period-2] then
		
		     if ShowFibo and F382 then
			        L382[period - 2] = S[period] +(R[period]- S[period])*0.382;
					L382[period - 1] = S[period] +(R[period]- S[period])*0.382;
					L382[period] = S[period] +(R[period]- S[period])*0.382;
					if L382[period - 3]~= L382[period - 2] then
					L382:setBreak(period-2, true);
					end	 
					
					if instance.parameters.ShowPrice then
						Label382:set(period - 2, L382[period - 2], "38,2: " .. string.format(format, L382[period - 2]));
					end
			     
			   
			end 	
		
		
		
		       if ShowFibo and F500 then
			
			        L500[period - 2] = S[period] +(R[period]- S[period])*0.500;
					L500[period - 1] = S[period] +(R[period]- S[period])*0.500;
					L500[period] = S[period] +(R[period]- S[period])*0.500;
					if L500[period - 3]~= L500[period - 2] then
					L500:setBreak(period-2, true);
					end	 
					
					if instance.parameters.ShowPrice then
						Label500:set(period - 2, L500[period - 2], "50: " ..string.format(format,  L500[period - 2]));
			       end
		       end
		
		        if ShowFibo and F618 then
			        L618[period - 2] = S[period] +(R[period]- S[period])*0.618;
					L618[period - 1] = S[period] +(R[period]- S[period])*0.618;
					L618[period] = S[period] +(R[period]- S[period])*0.618;
					if L618[period - 3]~= L618[period - 2] then
					L618:setBreak(period-2, true);
					end	 
					
					if instance.parameters.ShowPrice then
						Label618:set(period - 2, L618[period - 2], "61,8: " .. string.format(format,  L618[period - 2]));
					end
			    end
				
				
		
		
		 else
           L382[period] = L382[period - 1];
				L500[period] = L500[period - 1];
				L618[period] = L618[period - 1];		 
		
		
		end
		
    end
end

