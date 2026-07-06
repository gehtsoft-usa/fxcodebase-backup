
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62219

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
    indicator:name("Transient Zones");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("h_right", "H Right", "H Right", 10);
    indicator.parameters:addInteger("h_left", "H Left", "H Left", 10);
	indicator.parameters:addInteger("sample_period", "Sample_period", "Sample_period", 1000);
	
    indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("show_channel", "Show Channel", "Show Channel", true);
    indicator.parameters:addBoolean("show_ptz", "Sample bars for % TZ", "Sample bars for % TZ", true);
	indicator.parameters:addBoolean("Signal", "Signal Mode", "Signal Mode", false);
	
	indicator.parameters:addGroup("Style");
 
	indicator.parameters:addColor("Top", "Top Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bottom", "Bottom Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Label", "Label Color", "Label Color", core.rgb(0, 0, 0));
	
	indicator.parameters:addInteger("Size1", "1. Label Size", "", 10, 1 , 100);
	indicator.parameters:addInteger("Size2", "2. Label Size", "", 20, 1 , 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block 
local first;
local source = nil; 
local show_channel;
local channel_high, channel_low;
local h_left, h_right;
local show_ptz;
local Size1, Size2;
local font1,font2;
local Top, Bottom;
local sample_period;
local X,Y;
local percent_total_ptz , percent_ptz_resolved;
local Label;
local total_tz;
local percent_total_tz;
local I,J;
local Signal;
function ReleaseInstance()
    core.host:execute("deleteFont", font1);
	core.host:execute("deleteFont", font2);
end	   

-- Routine
function Prepare(nameOnly)
    show_channel = instance.parameters.show_channel;
	Signal= instance.parameters.Signal;
	show_ptz = instance.parameters.show_ptz;
	h_left = instance.parameters.h_left;
	h_right = instance.parameters.h_right;
	Size1 = instance.parameters.Size1;
	Size2 = instance.parameters.Size2;
	Top= instance.parameters.Top;
	Bottom= instance.parameters.Bottom;
	sample_period= instance.parameters.sample_period; 
	Label= instance.parameters.Label;
    
  
	
	source = instance.source;
	first = source:first()+h_left;
	
 

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name); 
	
	if   (nameOnly) then
        return;
    end
	
	
	  font1 = core.host:execute("createFont", "Wingdings", Size1, false, false);
	font2 = core.host:execute("createFont", "Wingdings", Size2, false, false);
	
	
	if show_channel and not Signal then
	channel_high = instance:addStream("High", core.Line, name, "High",  Top, first);			
	channel_high:setWidth(instance.parameters.width1);
    channel_high:setStyle(instance.parameters.style1);
	channel_low= instance:addStream("oscillator", core.Line, name, "oscillator",  Bottom, first);
    channel_low:setWidth(instance.parameters.width2);
    channel_low:setStyle(instance.parameters.style2);	
	else
	channel_high = instance:addInternalStream(first, 0);
	channel_low = instance:addInternalStream(first, 0);
	end
	
	if Signal then
	
	X = instance:addStream("X", core.Bar, name, "X",  Top, first);	
	I = instance:addStream("I", core.Bar, name, "I",  Top, first);	
	
	Y = instance:addStream("Y", core.Bar, name, "Y",  Bottom, first);	
	J = instance:addStream("J", core.Bar, name, "J",  Bottom, first);	
	
	else
	
    X  = instance:addInternalStream(source:first(), 0);
    Y  = instance:addInternalStream(source:first(), 0);
	I  = instance:addInternalStream(source:first(), 0);
    J  = instance:addInternalStream(source:first(), 0);
    end
	
    
	
	instance:ownerDrawn(true);

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 
		
    if period < first or not source:hasData(period) then
	return;
	end
	
	I[period]=0;
	J[period]=0;
	X[period]=0;
	Y[period]=0;
	
	core.host:execute ("removeLabel", source:serial(period)); 
    
    local min,max=mathex.minmax(source, period-h_left+1, period);
	
	channel_high[period]= max;
	channel_low[period]=min; 
	
	if show_ptz then
	    if source.low[period] <= min then
		if not Signal then
		core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font1, Bottom, "\218");
		end
		J[period]=1;
		end
		
        if source.high[period] >= max then
		if not Signal then
		core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, font1, Top, "\217");
		end
		I[period]=1;
		end
	
	end
	
	
	 if period < first + h_right then
	return;
	end
	
	
	local central_bar_low = source.low[period-h_right + 1];
    local central_bar_high = source.high[period -h_right + 1];

	
	 local full_zone_low,full_zone_high=mathex.minmax(source, period-h_left-h_right+1, period);
	 
	 if central_bar_high >= full_zone_high then
	 core.host:execute ("removeLabel", source:serial(period-h_right+1)); 
	 if not Signal then
	 core.host:execute("drawLabel1", source:serial(period-h_right+1), source:date(period-h_right+1),  core.CR_CHART, source.high[period-h_right+1], core.CR_CHART, core.H_Center, core.V_Top, font2, Top, "\234");
	 end
	 X[period-h_right+1]=1;
	 end
	 
	 
    if central_bar_low <= full_zone_low then
	core.host:execute ("removeLabel", source:serial(period-h_right+1)); 
	if not Signal then
	core.host:execute("drawLabel1", source:serial(period-h_right+1), source:date(period-h_right+1),  core.CR_CHART, source.low[period-h_right+1], core.CR_CHART, core.H_Center, core.V_Bottom, font2, Bottom, "\233");
	end
	Y[period-h_right+1]=1;
	end
	
	if period < source:size()-1  or Signal then 
	return;
	end
	
	
	local high_bar_tz_count = mathex.sum(X, source:first(), period);
    local low_bar_tz_count = mathex.sum(Y, source:first(), period);
	
	total_tz = high_bar_tz_count + low_bar_tz_count;			
	local  percent_tz_high = (high_bar_tz_count / sample_period) * 100;
	local percent_tz_low = (low_bar_tz_count / sample_period) * 100;
	percent_total_tz = (percent_tz_high + percent_tz_low);
 
	if show_ptz then		
    high_bar_ptz_count = mathex.sum(I, source:first(), period);
	low_bar_ptz_count = mathex.sum(J, source:first(), period);
 
	local total_ptz = high_bar_ptz_count + low_bar_ptz_count;
    local percent_ptz_high = (high_bar_ptz_count / sample_period) * 100;
    local percent_ptz_low = (low_bar_ptz_count / sample_period) * 100;	
    percent_total_ptz = (percent_ptz_high + percent_ptz_low);
	
    percent_ptz_resolved = (1 - (total_tz / total_ptz)) * 100;
	end

end
 
local init = false;
 
function Draw(stage, context)
    if stage ~= 2
	or Signal 
	or not show_ptz  	
	then
	return;
	end
	
	 if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size1), context:pointsToPixels (Size1), 0);
            init = true;
    end
    local text1="Total TZ : "..win32.formatNumber(percent_total_tz, false, 2);	
	local text2="Total PTZ : "..win32.formatNumber(percent_total_ptz, false, 2);	
	local text3="PTZ Resolved : ".. win32.formatNumber(percent_ptz_resolved, false, 2);
	if percent_total_tz==nil or percent_total_ptz==nil or percent_ptz_resolved==nil then
	return;
	end	
    width1, height1 =context:measureText (1, text1, 0); 
	width2, height2 =context:measureText (1, text2, 0); 
	width3, height3 =context:measureText (1, text3, 0); 
    context:drawText (1, text1, Label, -1, context:right ()-width1, context:top ()+height1, context:right (), context:top ()+height1+height1, 0);
	context:drawText (1, text2, Label, -1, context:right ()-width2, context:top ()+height1+height1, context:right (), context:top ()+height1+height2+height1, 0);
    context:drawText (1, text3, Label, -1, context:right ()-width3, context:top ()+height1+height2+height1, context:right (), context:top ()+height1+height2+height3+height1, 0);	 
 
end	
