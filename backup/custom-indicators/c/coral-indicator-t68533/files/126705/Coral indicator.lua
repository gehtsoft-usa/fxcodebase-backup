-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68533

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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

function Init()
    indicator:name("Coral indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("sm", "Smoothing Period", "", 21, 1, 2000);
	indicator.parameters:addDouble("cd", "Constant D", "", 0.4);
   
   
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Line Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Line Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Line Neutral Color", "", core.rgb(128, 128, 128));
	--indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
   -- indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 5, 1, 5);
	
	indicator.parameters:addGroup("Ribbon Style");
	indicator.parameters:addBoolean("Ribbon"  , "Ribbon", "",true);
	indicator.parameters:addDouble("Percentage", "Vertical percentage", "", 5);
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Percentage;
local sm,cd; 
local first;
local source = nil;
local di, c1, c2, c3, c4, c5, i1, i2, i3,i4, i5,i6;
local Up, Down;
local Coral;
local Up,Down,Neutral;
local Ribbon;
-- Routine
 function Prepare(nameOnly)   
 
 
    sm= instance.parameters.sm;
	cd= instance.parameters.cd;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
	Ribbon= instance.parameters.Ribbon;
	Percentage= instance.parameters.Percentage;
	
	local Parameters= sm..", "..cd;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	di = (sm - 1.0) / 2.0 + 1.0
	c1 = 2 / (di + 1.0)
	c2 = 1 - c1
	c3 = 3.0 * (cd * cd + cd * cd * cd)
	c4 = -3.0 * (2.0 * cd * cd + cd + cd * cd * cd)
	c5 = 3.0 * cd + 1.0 + cd * cd * cd + 3.0 * cd * cd
	
	
	i1= instance:addInternalStream(0, 0);
	i2= instance:addInternalStream(0, 0);
	i3= instance:addInternalStream(0, 0);
	i4= instance:addInternalStream(0, 0);
	i5= instance:addInternalStream(0, 0);
	i6= instance:addInternalStream(0, 0);
	
    
			
    source = instance.source; 
    first=source:first();
	
	 
 
	Coral = instance:addStream("Coral" , core.Dot, "Coral","Coral",Up, first);
	Coral:setWidth(instance.parameters.width);
    --Coral:setStyle(instance.parameters.style);
    Coral:setPrecision(math.max(2, source:getPrecision()));
	
	if Ribbon then
	instance:setLabelColor(Up);
    instance:ownerDrawn(true);
	end
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:first()
	then
	return;
	end
	i1[period] = c1*source[period] + c2*(i1[period-1]);
	i2[period] = c1*i1[period] + c2* (i2[period-1]);
	i3[period] = c1*i2[period] + c2* (i3[period-1]);
	i4[period] = c1*i3[period] + c2* (i4[period-1]);
	i5[period] = c1*i4[period] + c2* (i5[period-1]);
	i6[period] = c1*i5[period] + c2* (i6[period-1]);
	
	
	 
		
     Coral[period]= -cd*cd*cd*i6[period] + c3*(i5[period]) + c4*(i4[period]) + c5*(i3[period]);
	 
	 if Coral[period] > Coral[period-1] then
	 Coral:setColor(period, Up);	
     elseif Coral[period] < Coral[period-1] then
     Coral:setColor(period, Down);
	 else
	 Coral:setColor(period, Neutral);
     end	 
end

 
local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
 
  
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
 
			
			context:createPen (11, context.SOLID, 1, Up)       
			context:createSolidBrush(12, Up);
			
			context:createPen (21, context.SOLID, 1, Down)       
			context:createSolidBrush(22, Down);
			
			context:createPen (31, context.SOLID, 1, Neutral)       
			context:createSolidBrush(32, Neutral);

		  
            init = true;
        end
     
        
    
	Add(context );
 
	
end


function Add(context )
         
       
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
     
	     local X0, X1, X2 = context:positionOfBar (source:size()-1); 
		-- local HCellSize =((X2-X1)/100);
		 local VCellSize =((context:bottom() -context:top())/ 100)*Percentage; 
	     local  x0,x1,x2;

			    for period= first, last, 1 do	 
			   x0, x1, x2 = context:positionOfBar (period);
			 
						         
								  
												      
															if Coral[period] > Coral[period-1]  then	
															C2=12;
															C1=11;
															elseif Coral[period] < Coral[period-1]  then	
															C2=22;
															C1=21;
															else
															C1=31; C2=32;
															end		
												 
											 										
												
											 
												 
												     
									   
									   
						 
				 
                   
						
					 
					  context:drawRectangle (C1, C2, x1 , context:bottom()-VCellSize, x2, context:bottom() );
										
				end						
				  
				   
				   
					  
	 
 end