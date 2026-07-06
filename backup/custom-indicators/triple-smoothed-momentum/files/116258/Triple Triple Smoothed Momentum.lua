-- Id: 19842
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65405


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
    indicator:name("Triple Triple Smoothed Momentum");
    indicator:description("Triple Smoothed Momentum");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MomentumLength_1", "1. Momentum Length", "Momentum Length", 10);
    indicator.parameters:addInteger("MomentumLength_2", "2. Momentum Length", "Momentum Length", 14);
	indicator.parameters:addInteger("MomentumLength_3", "3. Momentum Length", "Momentum Length", 21);
    indicator.parameters:addBoolean("Signal", "Signal Mode", "", false);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "1. Momentum Line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color2", "2. Momentum Line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color3", "3. Momentum Line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addColor("Up", "Up Trend", "", core.rgb(150, 150, 150));
	 indicator.parameters:addColor("Down", "Down Trend", "", core.COLOR_BACKGROUND );
	 indicator.parameters:addColor("Neutral", "Neutral Trend", "", core.COLOR_BACKGROUND  );
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local MomentumLength;

local first;
local source = nil;

-- Streams block
local Momentum1;
local Momentum2;
local Momentum3;
local Trend; 
local MomentumLength_1, MomentumLength_2, MomentumLength_3;

local powSlow=1;
local powFast=2;

local Signal;
local Up,Down,Neutral;
local Indicator1,Indicator2,Indicator3;
-- Routine
function Prepare(nameOnly)
    MomentumLength_1 = instance.parameters.MomentumLength_1;
	MomentumLength_2 = instance.parameters.MomentumLength_2;
	MomentumLength_3 = instance.parameters.MomentumLength_3;
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral;
	
	Signal = instance.parameters.Signal;
    source = instance.source;
	first = source:first();
	
	
	    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(MomentumLength_1) .. ", " .. tostring(MomentumLength_2)  .. ", " .. tostring(MomentumLength_3).. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("TRIPLE SMOOTHED MOMENTUM") ~= nil, "Please, download and install TRIPLE SMOOTHED MOMENTUM.LUA indicator"); 
	
	Indicator1 = core.indicators:create("TRIPLE SMOOTHED MOMENTUM", source, MomentumLength_1);
	Indicator2 = core.indicators:create("TRIPLE SMOOTHED MOMENTUM", source, MomentumLength_2);
	Indicator3 = core.indicators:create("TRIPLE SMOOTHED MOMENTUM", source, MomentumLength_3);
 


   
        Momentum1 = instance:addStream("Momentum_1", core.Line, name, "1. Momentum", instance.parameters.color1, first+MomentumLength_1);
    Momentum1:setPrecision(math.max(2, instance.source:getPrecision()));
		Momentum1:setWidth(instance.parameters.width1);
        Momentum1:setStyle(instance.parameters.style1);
		
		Momentum2 = instance:addStream("Momentum_2", core.Line, name, "2. Momentum", instance.parameters.color2, first+MomentumLength_2);
    Momentum2:setPrecision(math.max(2, instance.source:getPrecision()));
		Momentum2:setWidth(instance.parameters.width2);
        Momentum2:setStyle(instance.parameters.style2);
		
		
		Momentum3 = instance:addStream("Momentum_3", core.Line, name, "3. Momentum", instance.parameters.color3, first+MomentumLength_3);
    Momentum3:setPrecision(math.max(2, instance.source:getPrecision()));
		Momentum3:setWidth(instance.parameters.width3);
        Momentum3:setStyle(instance.parameters.style3);
		
		if Signal then
		Trend = instance:addStream("Trend", core.Line, name, "Trend", instance.parameters.color4 , first+math.max(MomentumLength_1,MomentumLength_2,MomentumLength_3));
    Trend:setPrecision(math.max(2, instance.source:getPrecision()));
		else	
		Trend = instance:addInternalStream(0, 0);
		end
 
		
    
	
	  instance:ownerDrawn(true);
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
    

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, Up )       
			context:createSolidBrush(2, Up );
			
			 context:createPen (3, context.SOLID, 1,  Down)       
			context:createSolidBrush(4,  Down);
			 
			  context:createPen (6, context.SOLID, 1,  Neutral)       
			context:createSolidBrush(5,  Neutral);
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			
						
								
										 
										
												 
									         	     if Trend[period] ==1 then		 
																 
																C2=2;
																C1=1;
																 
													 
														elseif  Trend[period] ==-1 then		
																 
																C2=4;
																C1=3;
																 
														 else
					   
																 C1=5; C2=6;		
																					
														end		 
															
													 
												     
									 
									   
			          	X1= x1 ;
                        X2= x2 ;
						
					
						
			           context:drawRectangle (C1, C2, X1, context:top(), X2, context:bottom()  );
			end					
				 
				
	
end




-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    if period < first or not  source:hasData(period) then
	return;
	end
	 
	 Indicator1:update(mode);
	 if period > Indicator1.DATA:first() then
	 Momentum1[period]=Indicator1.DATA[period];
     end

	 
	 Indicator2:update(mode);
	 if period > Indicator2.DATA:first() then
	 Momentum2[period]=Indicator2.DATA[period];
     end
	 
	 
	 Indicator3:update(mode);
	 if period > Indicator3.DATA:first() then
	 Momentum3[period]=Indicator3.DATA[period];
     end
 
 
     if period < first+math.max(MomentumLength_1,MomentumLength_2,MomentumLength_3) then
	 return;
	 end
	 
     
	 
      if Momentum1[period] > Momentum3[period] then
	  Trend[period] = 1
	  elseif Momentum1[period] < Momentum3[period]  then
	  Trend[period] = -1
	  else
	  Trend[period] = Trend[period-1];
	  end
	  	 
    
end
 