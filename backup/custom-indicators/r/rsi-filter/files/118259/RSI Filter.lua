-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65843

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
    indicator:name("RSI Filter");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Period", "Period","", 14);
    indicator.parameters:addDouble("OB1", "Filter Overbought Level","", 70);
    indicator.parameters:addDouble("OS1","Filter Oversold Level","", 30);
    indicator.parameters:addDouble("OB2", "Trend Overbought Level","", 50);
    indicator.parameters:addDouble("OS2","Trend Oversold Level","", 40);
	 
	
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up in Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down in Up Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(128, 128, 128));
 
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
   
   
end 

local HSpace;
local Up,Down,Neutral;
local Indicator,Period;
local first;
local Trend, Filter;
local OB1,OS1;
local OB2,OS2;

 function Prepare(nameOnly)   
 
 
    Period=instance.parameters.Period;
	OB1=instance.parameters.OB1;
	OS1=instance.parameters.OS1;
	OB2=instance.parameters.OB2;
	OS2=instance.parameters.OS2;
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Period.. ", " ..  OB1.. ", " ..  OS1.. ", " ..  OB2.. ", " ..  OS2.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 
    source = instance.source;	
	HSpace=(instance.parameters.HSpace/100);
	
   Up=instance.parameters.Up;
   Down=instance.parameters.Down;
   
   Neutral=instance.parameters.Neutral;
   
   instance:setLabelColor(Neutral);
   instance:ownerDrawn(true);
   

   Trend = instance:addInternalStream(0, 0);
   Filter = instance:addInternalStream(0, 0);
	
    Indicator = core.indicators:create("RSI", source.close ,  Period);
	first=Indicator.DATA:first();
	
		
end



function Update(period, mode)

    Indicator:update(mode);
	
	
	if period < first then
	return;
	end
	
	Trend[period]= Trend[period-1];
    Filter[period]= Filter[period-1];
	
	
    local RSI=Indicator.DATA[period];
	
            if (RSI>OB1) then Filter[period] =  1; end
            if (RSI<OS1) then Filter[period] = -1; end
	  
            if (Filter[period]>0 and RSI > OS2) then Trend[period] =  1; end
            if (Filter[period]<0 and RSI < OB2) then Trend[period] = -1; end

            
end

local init = false;

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
			   
			
						
								
										 
												 
									         	     if Trend[period] == 1 then		 
																 
																C2=2;
																C1=1;
																
													 
														elseif  Trend[period] == -1 then		 
 
																C2=4;
																C1=3;
																 	
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

