-- Id: 21613
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66222
-- Id: 

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("ADXVMA (NT7)");
    indicator:description("Port from NT7 ana ADXVMA");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Length", "Length", "", 6, 2, 2000);
 
    indicator.parameters:addGroup("Style");     
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral Line Color", "", core.rgb(0, 0, 255));
 
 
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
    
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Length;

local Up, Down, Neutral;

local first;

local source = nil;
local ADXVMA ;
local k;
local volatility;
local up;
local down;
local ups;
local downs;
local index;
local trend;

local HSpace;
-- Routine
function Prepare(nameOnly) 
    Length = instance.parameters.Length;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " .. Length .. ")";
    instance:name(name); 
    if   (nameOnly) then
        return;
    end
    
	
	HSpace=(instance.parameters.HSpace/100);
	
    Up = instance.parameters.Up;
    Down = instance.parameters.Down;
    Neutral = instance.parameters.Neutral;
    source = instance.source;

    first = source:first() + Length + 1;
 
    k = 1.0 / Length;
    up = instance:addInternalStream(0, 0);
    down = instance:addInternalStream(0, 0);
    ups = instance:addInternalStream(0, 0);
    downs = instance:addInternalStream(0, 0);
    index = instance:addInternalStream(0, 0);
    trend = instance:addInternalStream(0, 0);
    volatility = core.indicators:create("ATR", source, 200);
    ADXVMA = instance:addInternalStream(0, 0);
 
     instance:setLabelColor(Neutral);
   instance:ownerDrawn(true);
   
end

local epsilon;
-- Indicator calculation routine
function Update(period, mode)

   
	
    volatility:update(mode);
    if period < first then
        return;
    elseif period == first then
        ADXVMA[period - 1] = source[period];
    end
    local currentUp = math.max(source[period] - source[period - 1], 0);
    local currentDown = math.max(source[period - 1] - source[period], 0);
    up[period] = (1 - k) * up[period - 1] + k * currentUp;
    down[period] = (1 - k) * down[period - 1] + k * currentDown;
    local sum = up[period] + down[period];
    local fractionUp = 0.0;
    local fractionDown = 0.0;
    if (sum ~= 0) then
        fractionUp = up[period] / sum;
        fractionDown = down[period] / sum;
    end
    ups[period] = (1 - k) * ups[period - 1] + k * fractionUp;
    downs[period] = (1 - k) * downs[period - 1] + k * fractionDown;
    
    local normDiff = math.abs(ups[period] - downs[period]);
    local normSum = ups[period] + downs[period];
    local normFraction = 0.0;
    if (normSum ~= 0) then
        normFraction = normDiff / normSum;
    end
    index[period] = (1 - k) * index[period - 1] + k * normFraction;
    
    epsilon = 0.1 * volatility.DATA[period - 1];
    local hhp = mathex.max(index, period - 1 - Length, period - 1);
    local llp = mathex.min(index, period - 1 - Length, period - 1);
    local hhv = math.max(index[period], hhp);
    local llv = math.min(index[period], llp);
    
    local vDiff = hhv - llv;
    local vIndex = 0;
    if (vDiff ~= 0) then
        vIndex = (index[period] - llv) / vDiff;
    end
    
    ADXVMA[period - 1] = (1 - k * vIndex) * ADXVMA[period - 2] + k * vIndex * source[period];
    if (trend[period - 1] > -0.5 and ADXVMA[period - 1] > ADXVMA[period - 2] + epsilon) then
        trend[period] = 1.0;
         
    elseif (trend[period - 1] < 0.5 and ADXVMA[period - 1] < ADXVMA[period - 2] - epsilon) then
        trend[period] = -1.0; 
    else
        trend[period] = 0.0; 
    end
   
end


function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
    

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, Up)       
			context:createSolidBrush(2, Up);
			
			 context:createPen (3, context.SOLID, 1, Down)       
			context:createSolidBrush(4, Down);			

			context:createPen (5, context.SOLID, 1, Neutral)       
			context:createSolidBrush(6, Neutral);
			 
		  
            init = true;
        end
     
        
        local ifirst = math.max(source:first(), context:firstBar ());
        local ilast = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period= ifirst, ilast, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			
						
								
										if trend:hasData(period) then 
										
												 
									         	     if trend[period] == 1  then		 
																 
																C2=2;
																C1=1;
																 
													 
														elseif  trend[period] == -1 then	
															 
																C2=4;
																C1=3;
															 	
														 else
					   
																 C1=5; C2=6;		
																					
														end		 
															
													 
												     
									   else		
									   C1=5; C2=6;										   
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
