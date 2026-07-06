-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61341
-- Id: 12745

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Fractal Bar Indicator");
    indicator:description("Fractal Bar Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral_color", "Color of Neutral", "Color of Neutral", core.rgb(128, 128,128));
	
  indicator.parameters:addBoolean("Signal_Mode", "Signal Mode", "", false);	

   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50);
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local HSpace;
local first;
local source = nil;

-- Streams block
local Out = nil;
local Signal_Mode;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+6;
	
	Signal_Mode=instance.parameters.Signal_Mode;

    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end

        if Signal_Mode then
		Out = instance:addStream("Out", core.Bar, name, "Fractal Bar", instance.parameters.Neutral_color, first);
    Out:setPrecision(math.max(2, instance.source:getPrecision()));
		else		
        Out= instance:addInternalStream(first, 0);
        end
		
	
	Up=nil;
	Down=nil;
	
	HSpace=instance.parameters.HSpace;
	
	
	 instance:setLabelColor( instance.parameters.Neutral_color);
   instance:ownerDrawn(true);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    Out[period]=0;
	Out:setColor(period,instance.parameters.Neutral_color);

	
    if period < first or not source:hasData(period) then
	return;
	end
    
	local Up=nil;
    local Down=nil;
	
	Up, Down=Calculate(period);
	
	if Up== nil 
	or Down==nil
	then
	return;		
	end
	
	
	if period <Up 
	or period <Down
	then
	return;
	end
	
	
	if source.close[period] > source.high[Up] then
    Out[period]=1;
	Out:setColor(period,instance.parameters.Up_color);
	end
	if source.close[period] < source.low[Down] then
	Out[period]=-1; 
	Out:setColor(period,instance.parameters.Down_color);
	end 
		
     
end

function Calculate(Start)

local Up=nil;
local Down=nil;

        for period=Start, first, -1 do
		
        local curr = source.high[period - 2];
        if (curr > source.high[period - 4] and curr > source.high[period - 3] and
            curr > source.high[period - 1] and curr > source.high[period])
			and Up== nil
			then
             
            Up=period-2;
       
        end
        curr = source.low[period - 2];
        if (curr < source.low[period - 4] and curr < source.low[period - 3] and
            curr < source.low[period - 1] and curr < source.low[period]) 
			and Down==nil
			then
             
           Down=period-2;
        end
		
			if Up~= nil 
			and Down ~= nil
			then
			break;
			end
		
		
		end
		
		
		
		return Up,Down;
  end
  
  
  
local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
    

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, instance.parameters.Up_color)       
			context:createSolidBrush(2, instance.parameters.Up_color);
			
			 
			context:createPen (5, context.SOLID, 1, instance.parameters.Down_color)       
			context:createSolidBrush(6, instance.parameters.Down_color);
 
			
			context:createPen (9, context.SOLID, 1, instance.parameters.Neutral_color)       
			context:createSolidBrush(10, instance.parameters.Neutral_color);
			 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			
						
								
										if period > source:first() and source:hasData(period) and Out:hasData(period)  then 
										
												 
									         	     if Out[period] ==1 then		 
																 
																C2=2;
																C1=1;
																 	
													 
														elseif Out[period] == -1 then	
																 
																C2=6;
																C1=5;
																 
														 else
					   
																 C1=9; C2=10;		
																					
														end		 
															
													 
												     
									   else		
									   C1=9; C2=10;										   
									   end 
									   
			          	X1= x1+HCellSize;
                        X2= x2-HCellSize;
						
						if X1> x0 then
						X1= x0; 
						end
						
						if X2< x0 then
						X2= x0; 
						end
						
			           context:drawRectangle (C1, C2, X1, context:top(), X2, context:bottom()  );
			end					
				 
				
	
end



