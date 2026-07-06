-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68752

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
 
function Init()
    indicator:name("ADX Slope");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");	 
	indicator.parameters:addInteger("Period", "Period","", 14);
	indicator.parameters:addDouble("Level", "Level","", 20);

    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("StrongUp", "Up in Strong Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("StrongDown", "Down in Strong Trend Color","", core.rgb(0, 200, 0));
	indicator.parameters:addColor("WeakUp", "Up in Weak Trend Color","", core.rgb(200, 0, 0));
	indicator.parameters:addColor("WeakDown", "Down in Weak Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(128, 128, 128));
 
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
   
   
end 

local HSpace;
local WeakUp, WeakDown, StrongUp,StrongDown,Neutral;
local Indicator;
local Period;
local Level;
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 
    source = instance.source;	
	HSpace=(instance.parameters.HSpace/100);
	
   StrongUp=instance.parameters.StrongUp;
   StrongDown=instance.parameters.StrongDown;
   
   WeakUp=instance.parameters.WeakUp;
   WeakDown=instance.parameters.WeakDown;
   
   Neutral=instance.parameters.Neutral;
   
   Period=instance.parameters.Period;
   Level=instance.parameters.Level;
   
   instance:setLabelColor(Neutral);
   instance:ownerDrawn(true);
   

   
	
	 Indicator = core.indicators:create("ADX", source ,  Period);
	
		
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
		     context:createPen (1, context.SOLID, 1, StrongUp)       
			context:createSolidBrush(2, StrongUp);
			
			 context:createPen (3, context.SOLID, 1, StrongDown)       
			context:createSolidBrush(4, StrongDown);
			
			context:createPen (5, context.SOLID, 1, WeakUp)       
			context:createSolidBrush(6, WeakUp);
			
			 context:createPen (7, context.SOLID, 1, WeakDown)       
			context:createSolidBrush(8, WeakDown);
			
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
			   
			
						
								
										if Indicator.DATA:hasData(period) and Indicator.DATA:hasData(period-1) then 
										
												 
									         	     if Indicator.DATA[period] > Level then		 
																if Indicator.DATA[period] > Indicator.DATA[period-1] then	
																C2=2;
																C1=1;
																else
																C2=4;
																C1=3;
																end		
													 
														elseif Indicator.DATA[period] < Level  then	
																if Indicator.DATA[period] > Indicator.DATA[period-1] then	
																C2=6;
																C1=5;
																else
																C2=8;
																C1=7;
																end		
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

