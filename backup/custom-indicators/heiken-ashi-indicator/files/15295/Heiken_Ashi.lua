-- Id: 4677
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6720

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

 
function Init()
    indicator:name("Heiken ashi indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	

    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpUp", " Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownDown", " Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(128, 128, 128));
 
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
   
   
end 

local HSpace;
local UpUp, UpDown, DownUp,DownDown,Neutral;
local Indicator;

function Prepare(nameOnly)
 
    source = instance.source;	
	HSpace=(instance.parameters.HSpace/100);
	
   UpUp=instance.parameters.UpUp;
   DownDown=instance.parameters.DownDown;
   
   Neutral=instance.parameters.Neutral;

    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	instance:name(name );
	if nameOnly then
		return;
	end
	
	instance:setLabelColor(Neutral);
	instance:ownerDrawn(true);
	Indicator = core.indicators:create("HA", source);
end



function Update(period, mode)

    Indicator:update(mode);
	
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
    

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, UpUp)       
			context:createSolidBrush(2, UpUp);
			
			
			
			 context:createPen (7, context.SOLID, 1, DownDown)       
			context:createSolidBrush(8, DownDown);
			
			context:createPen (9, context.SOLID, 1, Neutral)       
			context:createSolidBrush(10, Neutral);
			 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			
						
								
										if Indicator.DATA:hasData(period)   then 
										
												 
									         	     if Indicator.close[period] > Indicator.open[period] then		 
																 
																C2=2;
																C1=1;
														 
													 
														elseif Indicator.close[period] < Indicator.open[period] then
																 
																C2=8;
																C1=7;
																 
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

