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
	 indicator.parameters:addDouble("Multiplier", "Deviation Multiplier", "If Deviation", 1.0, 0.0, 100.0);
	
	
	indicator.parameters:addGroup("Data Filter");	
	indicator.parameters:addBoolean("Filter", "Use Data Filter", "" ,  false);
	
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
local Top, Bottom,Mid;
local Model=nil;
local Multiplier;

local Filter;

 local SD;

local open, high, low, close;

-- Routine
 function Prepare(nameOnly)   
    Filter =instance.parameters.Filter;
    Multiplier =instance.parameters.Multiplier;
    Model =instance.parameters.Model;
    frame = instance.parameters.period;
	raff = instance.parameters.Raff;
    source = instance.source;
	CloseHighLow=instance.parameters.HighLowClose;
	
	
    first = source:first()+frame;
	 
	
	 local name;
	 
	if Model == "Deviation" then
     name = profile:id() .. "(" .. source:name() .. ", " .. frame ..", " ..   Model .. ", "  ..Multiplier .. ")";
	else
	 name = profile:id() .. "(" .. source:name() .. ", " .. frame ..", " ..   Model .. ")";
	end
	
    instance:name(name);	
	
	if   (nameOnly) then
        return;
    end
	
	
	open = instance:addInternalStream(0, 0);
	high = instance:addInternalStream(0, 0);
	low = instance:addInternalStream(0, 0);
	close = instance:addInternalStream(0, 0);
	
	SD = instance:addInternalStream(0, 0);
	
	x = instance:addInternalStream(0, 0);
	y = instance:addInternalStream(0, 0);
	xy = instance:addInternalStream(0, 0);
	x2 = instance:addInternalStream(0, 0);
	
	Mid = instance:addStream("Central", core.Line, name, "Central", instance.parameters.out_color, first);
	Mid:setWidth(instance.parameters.widthC);
    Mid:setStyle(instance.parameters.styleC);
	
	if raff =="Yes" then
	
	Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.bottom_color, first);
	Bottom:setWidth(instance.parameters.widthB);
    Bottom:setStyle(instance.parameters.styleB);
	
	Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.top_color, first);
	Top:setWidth(instance.parameters.widthT);
    Top:setStyle(instance.parameters.styleT);
	
	end
	
    		
	last_period =nil;
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


  
	open[period] = source.open[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	close[period] = source.close[period];		
	

    

    if  period  < first  then 
	return;
	end
	
	 SD[period] = mathex.stdev(close, period - frame , period);
		
		 if period == source:size() -1 then
		 
		 
		 
		    if last_period ~=  source:serial(period) then
			last_period =  source:serial(period)
			Clear(period);
			end
	
			oldx=period- frame;

						
			for i= 0 , frame, 1 do
			y[period-frame+i] = close[period-frame+i];
			xy[period-frame+i]= close[period-frame+i]*i;
			x[period-frame+i]=i;
			x2[period-frame+i]=i*i;
			end		

		c=((mathex.sum(x2, period-frame+1, period)) *frame-(mathex.sum(x, period-frame+1, period)) *(mathex.sum(x, period-frame+1, period)) );
		b=(mathex.sum (xy, period-frame+1, period) *frame-mathex.sum(x, period-frame+1, period) *mathex.sum(y, period-frame+1, period) )/c;		
		a=   (mathex.sum(y, period-frame+1, period) -mathex.sum(x, period-frame+1, period)*b) /frame;
		w=a+b*frame;
		
		 oldy=a;
		
		core.drawLine(Mid, core.range(oldx, period), oldy, oldx, w,period);       

	
        if Filter then	
		   for i= period - frame, period, 1 do
		   
										   if  open[i] > Mid[i]+  SD[i]*Multiplier then
										   open[i] = Mid[i]+  SD[i]*Multiplier;
										   elseif open[i] < Mid[i] -  SD[i]*Multiplier then
										   open[i] = Mid[i] -  SD[i]*Multiplier ;
										   end
										   
											
										   if  close[i] > Mid[i]+  SD[i]*Multiplier then
										   close[i] = Mid[i]+  SD[i]*Multiplier;
										   elseif close[i] < Mid[i] -  SD[i]*Multiplier then
										   close[i] = Mid[i] -  SD[i]*Multiplier; 
										   end
										   
										   
										   if  high[i] > Mid[i]+  SD[i]*Multiplier then
										   high[i] = Mid[i]+  SD[i]*Multiplier;
										   elseif high[i] < Mid[i] -  SD[i]*Multiplier then
										   high[i] = Mid[i] -  SD[i]*Multiplier; 
										   end
										   
											
										   if  low[i] > Mid[i]+  SD[i]*Multiplier then
										   low[i] = Mid[i]+  SD[i]*Multiplier;
										   elseif low[i] < Mid[i] -  SD[i]*Multiplier then
										   low[i] = Mid[i] -  SD[i]*Multiplier ;
										   end
			
			
			end
        end	
				
			--Raff Channel
				if raff =="Yes" and Model =="HighLow"   then
																		 
					for petlja =1, frame, 1 do
					
						            if  CloseHighLow=="Close" then
									h=close[period-frame+petlja];
									l=close[period-frame+petlja]
									else
									 h=high[period-frame+petlja];
									 l=low[period-frame+petlja]
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
								 
						
                     
                           core.drawLine(Top, core.range(oldx, period), lg, oldx, dg,period);	
					         core.drawLine(Bottom, core.range(oldx, period), ld, oldx, dd,period);		
                    elseif raff =="Yes" and Model ~= "HighLow"   then 
					
				        
						
						
						  lg=(Mid[oldx] + SD[period] * Multiplier );
						  dg=(Mid[period]+SD[period] * Multiplier );
						 ld=(Mid[oldx]-SD[period] * Multiplier);
						 dd=(Mid[period] -SD[period] * Multiplier);		
					
					           core.drawLine(Top, core.range(oldx, period), lg, oldx, dg,period);	
					         core.drawLine(Bottom, core.range(oldx, period), ld, oldx, dd,period);		
							 
											 
					end
			
			
		end
    
end

function Clear(p)

Top[p-frame-1] = nil;
Bottom[p-frame-1] = nil;
Mid[p-frame-1] = nil;
end
