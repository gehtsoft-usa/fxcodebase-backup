-- Id: 289
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=548&p=112262

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
    indicator:name("Linear Regrasion Line");
    indicator:description("Linear Regrasion Line");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addInteger("period", "Period", "Period", 14);
	
	indicator.parameters:addString("Raff", "Raff Channel", "Raff Channel Y/N" , "Yes");
    indicator.parameters:addStringAlternative("Raff", "Yes", "Raff Channel Yes" , "Yes");
	indicator.parameters:addStringAlternative("Raff", "No", "Raff Channel No" , "No");
	
	indicator.parameters:addString("HighLowClose", "Close or High and Low ", "Close or High and Low" , "HighLow");
    indicator.parameters:addStringAlternative("HighLowClose", "High/Low", "High/Low" , "HighLow");
	indicator.parameters:addStringAlternative("HighLowClose", "Close", "Close" , "Close");
	
	 indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("out_color", "Color of Central", "Color of Central", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("top_color", "Color of Top", "Color of Top", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addBoolean("Show", "Show Middle Lines", "", true);
	indicator.parameters:addColor("bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color4", "Color of Middle", "Color of Middle", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_DASH );
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;

-- Streams block
local out = nil;
local top = nil;
local bottom = nil;


local a=0;
local b=0;
local c=0;
local petlja=0;
local oldx=0;
local oldy=0;
local frame=0;
local w=0;
local z=0;
local maksimum=0;
local minimum=0;
local dd=0;
local dl=0;
local gl=0;
local gd=0;
local gornja=0;
local doljnja=0;
local raff;
local CloseHighLow;
local h=0;
local loop=0;
local test =0;
local reset=0;
local top_mid, botom_mid;
local Show;
-- Routine
function Prepare(nameOnly)
    frame = instance.parameters.period;
	raff = instance.parameters.Raff;
    source = instance.source;
	CloseHighLow=instance.parameters.HighLowClose;
	Show=instance.parameters.Show;
	
    first = source:first()+frame;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. frame .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	slope = instance:addInternalStream(0, 0);
	x = instance:addInternalStream(0, 0);
	y = instance:addInternalStream(0, 0);
	xy = instance:addInternalStream(0, 0);
	x2 = instance:addInternalStream(0, 0);
    out = instance:addStream("out", core.Line, name, "out", instance.parameters.out_color, first);
	out:setWidth(instance.parameters.width1);
    out:setStyle(instance.parameters.style1);
	top = instance:addStream("top", core.Line, name, "top", instance.parameters.top_color, first);
	top:setWidth(instance.parameters.width2);
    top:setStyle(instance.parameters.style2);
	bottom = instance:addStream("bottom", core.Line, name, "botom", instance.parameters.bottom_color, first);
	bottom:setWidth(instance.parameters.width3);
    bottom:setStyle(instance.parameters.style3);
	
	if Show then
	bottom_mid = instance:addStream("bottom_mid", core.Line, name, "botom_mid", instance.parameters.color4, first);
	bottom_mid:setWidth(instance.parameters.width4);
    bottom_mid:setStyle(instance.parameters.style4);
	
	top_mid = instance:addStream("top_mid", core.Line, name, "top_mid", instance.parameters.color4, first);
	top_mid:setWidth(instance.parameters.width4);
    top_mid:setStyle(instance.parameters.style4);	
	else
	top_mid = instance:addInternalStream(first, 0);
	bottom_mid = instance:addInternalStream(first, 0);
	end
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

if period == first then
	test=0;	
	z=0;
	oldx=period;
	end   
	
	if reset ~= period or reset==0 then
	reset=period;
	test=test+1;
    end
	
	y[period] = source.close[period];
	xy[period]=source.close[period]*test;
	x[period]=test;
	x2[period]=test*test;
	
	 if test < frame then	
	   z=2;
	 end
	
	


if period < first  then
return;
end
    	
     if test < frame then	
			if slope[period] >0 and slope[period-1] <0  or  slope[period] <0 and slope[period-1] >0  then
			z=1;
			end
	 end
	 
	 if  test== 0 
	 then
	 return;
	 end
		
		if test > frame or z==1 or z==2   then 
		
		c=((mathex.sum(x2, period-test+1, period)) *test-(mathex.sum(x, period-test+1, period)) *(mathex.sum(x,period-test+1, period)) );
		b=(mathex.sum (xy,period-test+1, period) *test-mathex.sum(x, period-test+1, period) *mathex.sum(y,period-test+1, period) )/c;		
		a=   (mathex.sum(y, period-test+1, period) -mathex.sum(x, period-test+1, period)*b) /test;
		w=a+b*test;
		
		--if z~=2 then 
		 oldy=a;
		--end
		core.drawLine(out, core.range(oldx, period), oldy, oldx, w,period);
		out:setBreak (oldx, true);	
						   
		
		
			--Raff Channel
				if raff =="Yes"  then
																		 
					for petlja =1, test, 1 do
					
						            if  CloseHighLow=="Close" then
									h=source.close[period-test+petlja];
									l=source.close[period-test+petlja]
									else
									 h=source.high[period-test+petlja];
									 l=source.low[period-test+petlja]
									end
																	
									if petlja==1 then 
									maksimum = h - out[period-test+petlja]; 
									minimum  =  out[period-test+petlja] -l;
									end
																
																									
													
							if (h - out[period-test+petlja]) > maksimum then maksimum = (h - out[period-test+petlja]); end
							if (out[period-test+petlja]- l )> minimum then minimum = (out[period-test+petlja]- l); end
						end	    
											
											
											
						  lg=(out[oldx] + maksimum );
						  dg=(out[period]+maksimum );
						 ld=(out[oldx]-minimum);
						 dd=(out[period] -minimum);
											 
								 
						core.drawLine(top, core.range(oldx, period), lg, oldx, dg,period);
						core.drawLine(bottom, core.range(oldx, period),ld, oldx, dd,period);
						
						core.drawLine(top_mid, core.range(oldx, period), ((top[oldx]-out[oldx])/2+out[oldx]), oldx, ((top[period]-out[period])/2+out[period]),period);
						core.drawLine(bottom_mid, core.range(oldx, period), ((out[oldx]-bottom[oldx])/2+bottom[oldx]), oldx, ((out[period]-bottom[period])/2+bottom[period]),period);
						top_mid:setBreak (oldx, true);	
                        bottom_mid:setBreak (oldx, true);	 
                        top:setBreak (oldx, true);	
                        bottom:setBreak (oldx, true);	     						
											 
					end
				if z~=2 then	
				oldx=period;
				test =0;
				end
				z=0;
				
		   end
	 
end