-- Id: 2510
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2857

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

function Init()
    indicator:name("VORTEX Trend");
    indicator:description("VORTEX  Trend");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");	 
     indicator.parameters:addInteger("N", "Vortex Period", "", 14);
	  indicator.parameters:addInteger("M", "MA of Vortex Period", "", 20);	 
	   indicator.parameters:addInteger("Up", "Level", "", 110);
	  indicator.parameters:addInteger("Down", "Level", "", 90);
	  indicator.parameters:addBoolean("Use", "Use Averaging", "", true);
	  
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(0, 255, 0));	
    indicator.parameters:addColor("DOWN_color", "Color of DOWN", "Color of DOWN", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NEUTRAL_color", "Color of NEUTRAL", "Color of NEUTRAL", core.rgb(128, 128, 128));
	indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N;
local M;
local first;
local source = nil;
local Use;

-- Streams block
local Signal = nil;
local VORTEX;
local UpLevel, DownLevel;
local HSpace;
-- Routine
function Prepare(nameOnly)
    Use = instance.parameters.Use;
    UpLevel = instance.parameters.Up;
	DownLevel = instance.parameters.Down;
	HSpace= instance.parameters.HSpace;
    N = instance.parameters.N;
	M = instance.parameters.M;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. N.. ", " .. M .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
  
	Signal = instance:addInternalStream(0, 0);
	assert(core.indicators:findIndicator("VORTEX") ~= nil, "Please, download and install VORTEX.LUA indicator");

  
	
	VORTEX = core.indicators:create("VORTEX", source, N);
	MVAP = core.indicators:create("MVA", VORTEX.VIP, M);
	MVAN = core.indicators:create("MVA", VORTEX.VIM, M);
	
	  first = math.max(VORTEX.DATA:first(),MVAP.DATA:first(),MVAN.DATA:first());
	   
   instance:setLabelColor(instance.parameters.NEUTRAL_color);
   instance:ownerDrawn(true);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    Signal[period]=0;
   
    if period >= first and source:hasData(period) then	
	
		
			
			VORTEX:update(mode);			
			
			 
			if Use then
					MVAP:update(mode);
					MVAN:update(mode);
					
					 
					
					if  MVAP.DATA[period] > UpLevel and  MVAN.DATA[period] < DownLevel then
					Signal[period]=1;
					elseif  MVAP.DATA[period] < DownLevel  and  MVAN.DATA[period] > UpLevel then					
					Signal[period]=-1; 
					else
					Signal[period]=0;		
					end
			else	
                    if  VORTEX.VIP[period] > UpLevel and  VORTEX.VIM[period] < DownLevel then
					Signal[period]=1;
					elseif  VORTEX.VIM[period] > UpLevel  and  VORTEX.VIP[period] < DownLevel then
					Signal[period]=-1; 
					else
					Signal[period]=0;		 			
					end			
			end
    end

end


local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
    

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, instance.parameters.UP_color)       
			context:createSolidBrush(2, instance.parameters.UP_color);
			
			 context:createPen (3, context.SOLID, 1, instance.parameters.DOWN_color)       
			context:createSolidBrush(4, instance.parameters.DOWN_color);			
			 
			
			context:createPen (9, context.SOLID, 1, instance.parameters.NEUTRAL_color)       
			context:createSolidBrush(10, instance.parameters.NEUTRAL_color);
			 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			
						
								
										if Signal:hasData(period) then 
										
												 
									         	     if Signal[period]==1 then		 
																 
																C2=2;
																C1=1;
															 
													 
														elseif Signal[period]==-1  then	
																 
																C2=4;
																C1=3;
																 	
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