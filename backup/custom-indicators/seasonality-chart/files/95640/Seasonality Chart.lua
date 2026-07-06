-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61090

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
    indicator:name("Seasonality Chart");
    indicator:description("Seasonality Chart");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addString("Instrument" ,  "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("Instrument"  , core.FLAG_INSTRUMENTS); 
	
	indicator.parameters:addGroup("Style");	
	indicator.parameters:addColor("Color","Label Color", "Label Color", core.rgb(0, 0, 0));
    indicator.parameters:addColor("Up","Color of Positive", "Color of Positive", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down","Color of Negativ", "Color of Negativ", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local loading;
local first;
local source = nil;
local Color;
local Source;
-- Streams block
local Seasonality ;
local Instrument;
local init=false;
local transparency;
local Up,Down;
-- Routine
function Prepare(nameOnly) 
	Instrument= instance.parameters.Instrument;
	Color = instance.parameters.Color;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
    source = instance.source; 
	
	init=false;
	
	if Instrument== "Chart" then
	Instrument=source:instrument();
	end
	
    local name = profile:id() .. "(" .. Instrument    .. ")";
    instance:name(name); 
	
	if   (nameOnly) then
        return;
    end
	
	Source = core.host:execute("getSyncHistory", Instrument, "M1", source:isBid(), 300 ,2 , 1);
	loading  = true;  
	
	instance:ownerDrawn(true); 
end

 
function Draw(stage, context)
    if stage~= 2
	or loading
	then
	return;
	end
	
	
        if not init then           
            transparency = context:convertTransparency(instance.parameters.transparency);
             context:createPen(1, context.SOLID, 1, Up ); 
             context:createSolidBrush(2, Up );	
             context:createPen(3, context.SOLID, 1, Down ); 
             context:createSolidBrush(4, Down );					 
            init = true;
        end
		
		local top, bottom = context:top(), context:bottom();
		local left, right = context:left(), context:right();
		local mid= bottom-(bottom-top)/2;
		
		local xSize=(right-left)/12;
		local ySize=(bottom-top)/12;
		
		context:createFont (5, "Arial",xSize*0.2, xSize*0.2, 0);
		
		
		Seasonality = {0,0,0,0,0,0,0,0,0,0,0,0};
	        Counter = {0,0,0,0,0,0,0,0,0,0,0,0};
		
		for i= Source:first(), Source:size()-1, 1  do
	    date= core.dateToTable (Source:date(i));
		
			if Source.close[i]> Source.open[i] then
			Seasonality[date.month]=Seasonality[date.month]+1;			
			end
		
		Counter[date.month]=Counter[date.month]+1;
		 
		end
		
		for i=1,12,1 do
		x1=left+(i-1) *xSize;
		x2=x1+xSize*0.9;
				 
		Value = string.format("%." .. 0 .. "f", (Seasonality[i]/Counter[i])*100);
		value =  (Seasonality[i]/Counter[i])*100 ;
		
		VHeightCoeff= (bottom-top)/100 ;
		iHeight=math.abs(VHeightCoeff*( value-50));
		
		  if value  > 50 then
		  
		  y1=mid-iHeight;
          y2=mid;
		  context:drawRectangle(1, 2, x1 ,y1, x2, y2, 0);		  
		  else
		  y1=mid ;
          y2=mid+iHeight;
		  context:drawRectangle(3, 4, x1 ,y1, x2, y2, 0);
		  end
		  
		  
				
		width, height = context:measureText (5,  tostring(i), context.CENTER);	 
		context:drawText (5, tostring(i), Color, -1, x1  , mid-height, x2, mid, context.CENTER );
		
		
		
		width, height = context:measureText (5,  Value, context.CENTER);	 
		context:drawText (5, Value, Color, -1, x1  , mid, x2, mid+height, context.CENTER );
		
		end
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
		 
			  if cookie == 1 then
			  loading  = true;
		      elseif  cookie == 2 then
			  loading  = false;  			  
			  end
	 
  
	
	if loading then
	 core.host:execute ("setStatus", "  Loading " );	 
	else
	core.host:execute ("setStatus", "Loaded");	          
	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
end

	
	
	 
	 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 
end

