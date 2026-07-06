-- Id:  
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68823

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
    indicator:name("RSI Filter");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI", "RSI Period", "", 14);
 
   
 
  
	
	indicator.parameters:addDouble("Overbought1", "1. Overbought Level", "", 70);
		indicator.parameters:addDouble("Overbought2", "2. Overbought Level", "", 40);
	  indicator.parameters:addDouble("Oversold1", " Oversold Level", "",  30);
	   indicator.parameters:addDouble("Oversold2", " Oversold Level", "",  60);
	  
	  
 
	indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("Up", "Color for Up Trend", "", core.rgb(0, 255, 0));
	  indicator.parameters:addColor("Dn", "Color for Down Trend", "", core.rgb(255, 0, 0));
	    indicator.parameters:addColor("Ne", "Color for Neutral Trend", "", core.rgb(0, 0, 255));
 
 
	  indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RSI;
 
local first;
local source = nil;
local RSI;
local trend; 
local Overbought1;
local Oversold1;
 local Overbought2;
local Oversold2;
local HSpace;
-- Routine
function Prepare(nameOnly)
    Overbought1 = instance.parameters.Overbought1;
	Oversold1 = instance.parameters.Oversold1;
	Overbought2 = instance.parameters.Overbought2;
	Oversold2 = instance.parameters.Oversold2;
	
 
    source = instance.source;
    HSpace=(instance.parameters.HSpace/100);

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(instance.parameters.RSI) .. ", " .. tostring(Overbought1).. ", " .. tostring(Oversold1).. ", " .. tostring(Overbought2).. ", " .. tostring(Oversold2)   .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	trend = instance:addInternalStream(0, 0);
	 RSI = core.indicators:create("RSI", source,    instance.parameters.RSI);
    
	 
	 first =RSI.DATA:first();
 
 
    instance:setLabelColor(instance.parameters.Ne);
     instance:ownerDrawn(true);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
	
	 RSI:update(mode);
 
	
	
	 if (RSI.DATA[period]>Overbought1) then trend[period]=1;  
	 elseif (RSI.DATA[period]<Oversold1) then trend[period]=-1;  
	 else trend[period]=trend[period-1];
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
		     context:createPen (1, context.SOLID, 1, instance.parameters.Up)       
			context:createSolidBrush(2, instance.parameters.Up);
			
			 context:createPen (3, context.SOLID, 1, instance.parameters.Dn)       
			context:createSolidBrush(4, instance.parameters.Dn); 
			
			
			 context:createPen (5, context.SOLID, 1, instance.parameters.Ne)       
			context:createSolidBrush(6, instance.parameters.Ne); 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			 Add(context,period);
			end					
				  
end

function Add (context, period)


    if not RSI.DATA:hasData(period) 
	then
	return;
	end
	
	
                                   x0, x1, x2 = context:positionOfBar (period);
			   
			
													
								if trend[period]> 0  and RSI.DATA[period] > Overbought2 then
										 
										  C1=1;C2=2;
									 
								 elseif trend[period]<0   and RSI.DATA[period] < Oversold2  then
										  
										 C1=3;C2=4;
										 
								 else 
										 
										    C1=5;C2=6; 
										 
								 
								 
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


 