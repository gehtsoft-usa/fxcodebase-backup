-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60177

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
    indicator:name("SonicR PVA Volumes Bar");
    indicator:description("SonicR PVA Volumes Bar");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");


    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PVA_Climax_Period", "PVA Climax Period", "PVA Climax Period", 10);
    indicator.parameters:addInteger("PVA_Rising_Period", "PVA Rising Period", "PVA Rising Period", 10);
    indicator.parameters:addDouble("PVA_Rising_Factor", "PVA Rising Factor", "PVA Rising Factor", 1);
    indicator.parameters:addDouble("PVA_Extreme_Factor", "PVA Extreme Factor", "PVA Extreme Factor", 2);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128,128, 128));
	
	indicator.parameters:addColor("RisingBull", "Color of Rising Bull", "Color of Rising Bull", core.rgb(0,200, 0));	
	indicator.parameters:addColor("RisingBear", "Color of Rising Bear", "Color of Rising Bear", core.rgb(200,0, 0));
	
	indicator.parameters:addColor("ClimaxBull", "Color of Climax Bull", "Color of Climax Bull", core.rgb(0,255, 0));	
	indicator.parameters:addColor("ClimaxBear", "Color of Climax Bear", "Color of Climax Bear", core.rgb(255,0, 0));
	
	
    indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block 
local source;
local PVA_Climax_Period;
local PVA_Rising_Period;
local PVA_Rising_Factor;
local PVA_Extreme_Factor;
local ma_volume; 
local source = nil;
local Range;  
local HSpace; 
local Max;
-- Routine
function Prepare(nameOnly)
    
    HSpace=(instance.parameters.HSpace/100);
    PVA_Climax_Period = instance.parameters.PVA_Climax_Period;
    PVA_Rising_Period = instance.parameters.PVA_Rising_Period;
    PVA_Rising_Factor = instance.parameters.PVA_Rising_Factor;
    PVA_Extreme_Factor = instance.parameters.PVA_Extreme_Factor;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PVA_Climax_Period) .. ", " .. tostring(PVA_Rising_Period) .. ", " .. tostring(PVA_Rising_Factor) .. ", " .. tostring(PVA_Extreme_Factor) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	ma_volume = core.indicators:create("MVA", source.volume, PVA_Rising_Period); 
	
	Range = instance:addInternalStream(0, 0);
	Max = instance:addInternalStream(0, 0);

	 assert(source:supportsVolume(), "The source must have volume");
	 
 
  
   instance:ownerDrawn(true);
    assert(source:supportsVolume(), "The source must have volume");
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    ma_volume:update(mode); 
    Range[period]= (source.high[period]-source.low[period])*source.volume[period];
	
	if period < PVA_Climax_Period then
	return;
	end
	
	Max[period] = mathex.max( Range, period -PVA_Climax_Period, period-1 );
end


function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
    

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, instance.parameters.RisingBull)       
			context:createSolidBrush(2, instance.parameters.RisingBull);
			
			 context:createPen (3, context.SOLID, 1, instance.parameters.RisingBear)       
			context:createSolidBrush(4, instance.parameters.RisingBear);
			
			context:createPen (5, context.SOLID, 1, instance.parameters.ClimaxBull)       
			context:createSolidBrush(6, instance.parameters.ClimaxBull);
			
			 context:createPen (7, context.SOLID, 1, instance.parameters.ClimaxBear)       
			context:createSolidBrush(8, instance.parameters.ClimaxBear);
			 
		    context:createPen (9, context.SOLID, 1, instance.parameters.Neutral)       
			context:createSolidBrush(10, instance.parameters.Neutral);
			
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar (),ma_volume.DATA:first(),PVA_Climax_Period );
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			   C1=9; C2=10;	
				  									
									                
										      if(source.volume[period] >= ma_volume.DATA[period] * PVA_Rising_Factor) then
	 
													  if(source.close[period] > source.open[period]) then
													  C1=1; C2=2;	
													  end
													  
													  if(source.close[period] <= source.open[period]) then
													  C1=3; C2=4;	
													  end 
											 
											 end
											 
											 if Range[period] >=  Max[period]  or  (source.volume[period] >= ma_volume.DATA[period] * PVA_Extreme_Factor) then
	
														if(source.close[period] > source.open[period]) then
														  C1=5; C2=6;	
														  end
														  
														  if(source.close[period] <= source.open[period]) then
														  C1=7; C2=8;	
														  end 
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




