-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1595

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
    indicator:name("Linear Regression Channel");
    indicator:description("Linear Regrasion Channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("period", "Period", "Period", 50);	
	
	indicator.parameters:addString("Raff", "Raff Channel", "Raff Channel Y/N" , "Yes");
    indicator.parameters:addStringAlternative("Raff", "Yes", "Raff Channel Yes" , "Yes");
	indicator.parameters:addStringAlternative("Raff", "No", "Raff Channel No" , "No");
	
	indicator.parameters:addString("HighLowClose", "Close or High and Low ", "Close or High and Low" , "HighLow");
    indicator.parameters:addStringAlternative("HighLowClose", "High/Low", "High/Low" , "HighLow");
	indicator.parameters:addStringAlternative("HighLowClose", "Close", "Close" , "Close");
	
	indicator.parameters:addGroup("Channel Mode");
	indicator.parameters:addString("Model", "HighLow / Deviation ", "" , "HighLow");
    indicator.parameters:addStringAlternative("Model", "High/Low", "High/Low" , "HighLow");
	indicator.parameters:addStringAlternative("Model", "Deviation", "" , "Deviation");
	indicator.parameters:addBoolean("On1", "Show 1. Line", "", false);
	indicator.parameters:addDouble("Multiplier1", "1. Deviation Multiplier", "If Deviation", 0.25, 0.0, 100.0);
	indicator.parameters:addBoolean("On2", "Show 2. Line", "", false);
	indicator.parameters:addDouble("Multiplier2", "2. Deviation Multiplier", "If Deviation", 0.5, 0.0, 100.0);
	indicator.parameters:addBoolean("On3", "Show 3. Line", "", false);
	indicator.parameters:addDouble("Multiplier3", "3. Deviation Multiplier", "If Deviation", 0.75, 0.0, 100.0);
	indicator.parameters:addBoolean("On4", "Show 4. Line", "", true);
	indicator.parameters:addDouble("Multiplier4", "4. Deviation Multiplier", "If Deviation", 1.0, 0.0, 100.0);
	indicator.parameters:addBoolean("On5", "Show 5. Line", "", false);
	indicator.parameters:addDouble("Multiplier5", "5. Deviation Multiplier", "If Deviation", 1.615, 0.0, 100.0);
	indicator.parameters:addBoolean("On6", "Show 6. Line", "", false);
	indicator.parameters:addDouble("Multiplier6", "6. Deviation Multiplier", "If Deviation", 2, 0.0, 100.0);	
	indicator.parameters:addBoolean("On7", "Show 7. Line", "", false);
    indicator.parameters:addDouble("Multiplier7", "7. Deviation Multiplier", "If Deviation", 3, 0.0, 100.0);	 	
 
	
	indicator.parameters:addGroup("Top Line Style");
	indicator.parameters:addColor("top_color", "Color of Top", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("widthT", "Width Top Line", "Width", 1, 1, 5);
    indicator.parameters:addInteger("styleT", "Style Top Line", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleT", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Cental Line Style");
	 indicator.parameters:addColor("out_color", "Color of Central Line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("widthC", "Width Central Line", "Width", 1, 1, 5);
    indicator.parameters:addInteger("styleC", "Style Central Line", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleC", core.FLAG_LINE_STYLE);
	
	
	
	indicator.parameters:addGroup("Bottom Line Style");
	indicator.parameters:addColor("bottom_color", "Color of Bottom", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("widthB", "Width Bottom Line", "Width", 1, 1, 5);
    indicator.parameters:addInteger("styleB", "Style Bottom Line", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleB", core.FLAG_LINE_STYLE);
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;

-- Streams block
--local out = nil;

local a=0;
local b=0;
local c=0;
local petlja=0;
local oldx=0;
local oldy=0;
local frame=0;
local w=0;
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
local i=0;
local last_period=nil;
local Top={};
local  Bottom={};
local Mid;
local Model=nil;
local Multiplier={};
local On={};
-- Routine
 function Prepare(nameOnly)   
    
    Multiplier[1] =instance.parameters.Multiplier1;
	Multiplier[2] =instance.parameters.Multiplier2;
	Multiplier[3] =instance.parameters.Multiplier3;
	Multiplier[4] =instance.parameters.Multiplier4;
	Multiplier[5] =instance.parameters.Multiplier5;
	Multiplier[6] =instance.parameters.Multiplier6;
	Multiplier[7] =instance.parameters.Multiplier7;
	
	On[1] =instance.parameters.On1;
	On[2] =instance.parameters.On2;
	On[3] =instance.parameters.On3;
	On[4] =instance.parameters.On4;
	On[5] =instance.parameters.On5;
	On[6] =instance.parameters.On6;
	On[7] =instance.parameters.On7;
	
    Model =instance.parameters.Model;
    frame = instance.parameters.period;
	raff = instance.parameters.Raff;
    source = instance.source;
	CloseHighLow=instance.parameters.HighLowClose;
	
	
    first = source:first()+frame;
	
	
	
	 local name;
	 
	if Model == "Deviation" then
     name = profile:id() .. "(" .. source:name() .. ", " .. frame ..", " ..   Model   .. ")";
	else
	 name = profile:id() .. "(" .. source:name() .. ", " .. frame ..", " ..   Model .. ")";
	end
	
    instance:name(name);	
	
	if   (nameOnly) then
        return;
    end
	
	x = instance:addInternalStream(0, 0);
	y = instance:addInternalStream(0, 0);
	xy = instance:addInternalStream(0, 0);
	x2 = instance:addInternalStream(0, 0);
	
	Mid = instance:addStream("Central", core.Line, name, "Central", instance.parameters.out_color, first);
	Mid:setWidth(instance.parameters.widthC);
    Mid:setStyle(instance.parameters.styleC);
	
	if raff =="Yes" and Model ~= "HighLow" then
	
	 
	   for i = 1, 7,1 do
				if On[i] then
				Bottom[i] = instance:addStream("Bottom"..i, core.Line, name, "Bottom", instance.parameters.bottom_color, first);
				Bottom[i]:setWidth(instance.parameters.widthB);
				Bottom[i]:setStyle(instance.parameters.styleB);
				
				Top[i] = instance:addStream("Top"..i, core.Line, name, "Top", instance.parameters.top_color, first);
				Top[i]:setWidth(instance.parameters.widthT);
				Top[i]:setStyle(instance.parameters.styleT);
				end
		end
	   
	else
	
	Bottom[1] = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.bottom_color, first);
	Bottom[1]:setWidth(instance.parameters.widthB);
    Bottom[1]:setStyle(instance.parameters.styleB);
	
	Top[1] = instance:addStream("Top", core.Line, name, "Top", instance.parameters.top_color, first);
	Top[1]:setWidth(instance.parameters.widthT);
    Top[1]:setStyle(instance.parameters.styleT);
	
	end
	
    		
	last_period =nil;
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if  period  < first then 
	return;
	end
	
	
		 if period == source:size() -1 then
		 
		 local i;
		 
		    if last_period ~=  source:serial(period) then
			last_period =  source:serial(period)
			Clear(period);
			end
	
			oldx=period- frame;

						
			for i= 0 , frame, 1 do
			y[period-frame+i] = source.close[period-frame+i];
			xy[period-frame+i]=source.close[period-frame+i]*i;
			x[period-frame+i]=i;
			x2[period-frame+i]=i*i;
			end		

		c=((mathex.sum(x2, period-frame+1, period)) *frame-(mathex.sum(x, period-frame+1, period)) *(mathex.sum(x, period-frame+1, period)) );
		b=(mathex.sum (xy, period-frame+1, period) *frame-mathex.sum(x, period-frame+1, period) *mathex.sum(y, period-frame+1, period) )/c;		
		a=   (mathex.sum(y, period-frame+1, period) -mathex.sum(x, period-frame+1, period)*b) /frame;
		w=a+b*frame;
		
		 oldy=a;
		
		core.drawLine(Mid, core.range(oldx, period), oldy, oldx, w,period);               
				
			--Raff Channel
				if raff =="Yes" and Model =="HighLow"   then
																		 
					for petlja =1, frame, 1 do
					
						            if  CloseHighLow=="Close" then
									h=source.close[period-frame+petlja];
									l=source.close[period-frame+petlja]
									else
									 h=source.high[period-frame+petlja];
									 l=source.low[period-frame+petlja]
									end
																	
									if petlja==1 then 
									maksimum = h - Mid[period-frame+petlja]; 
									minimum  =  Mid[period-frame+petlja] -l;
									end															
													
							if (h - Mid[period-frame+petlja]) > maksimum then maksimum = (h - Mid[period-frame+petlja]); end
							if (Mid[period-frame+petlja]- l )> minimum then minimum = (Mid[period-frame+petlja]- l); end
						end	 				
											
						  lg=(Mid[oldx] + maksimum );
						  dg=(Mid[period]+maksimum );
						 ld=(Mid[oldx]-minimum);
						 dd=(Mid[period] -minimum);											 
								 
						
                     
                           core.drawLine(Top[1], core.range(oldx, period), lg, oldx, dg,period);	
					         core.drawLine(Bottom[1], core.range(oldx, period), ld, oldx, dd,period);		
                    elseif raff =="Yes" and Model ~= "HighLow"   then 
					
				        local SD = mathex.stdev(source.close, period - frame , period);
						
						for i= 1, 7 , 1 do
						
							if On[i] then
							   lg=(Mid[oldx] + SD * Multiplier[i] );
							   dg=(Mid[period]+SD * Multiplier[i]  );
							   ld=(Mid[oldx]-SD * Multiplier[i] );
							   dd=(Mid[period] -SD * Multiplier[i] );		
						
								   core.drawLine(Top[i], core.range(oldx, period), lg, oldx, dg,period);	
								 core.drawLine(Bottom[i], core.range(oldx, period), ld, oldx, dd,period);		
							end	 
						end
											 
					end
			
			
		end
    
end

function Clear(p)

local i;
if raff =="Yes" and Model ~= "HighLow"   then 
	for i = 1, 7 , 1 do
		if On[i] then
		Top[i][p-frame-1] = nil;
		Bottom[i][p-frame-1] = nil;
		end
	 
	end
else
    Top[1][p-frame-1] = nil;
	Bottom[1][p-frame-1] = nil;
end

Mid[p-frame-1] = nil;
end
