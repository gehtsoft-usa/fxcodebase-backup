-- Id: 7509
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
 
function Init()
    indicator:name("Volatility Quality Index by Thomas Stridsman");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("Method", "Method", "Method" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
	
	 indicator.parameters:addBoolean("Steady", "Steady", "" , false); 
 
	indicator.parameters:addInteger("Length", "Length", "", 7);
    indicator.parameters:addInteger("Smoothing", "Smoothing", "", 1);
    indicator.parameters:addDouble("Filter", "Filter", "", 5);
	

    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpUp", "Up in Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownDown", "Down in Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(128, 128, 128));
 
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
   
   
end 

local HSpace;
local UpUp, DownDown,Neutral;
local Indicator;

function Prepare(nameOnly)
 
    source = instance.source;	
	HSpace=(instance.parameters.HSpace/100);
	
   UpUp=instance.parameters.UpUp;   
   DownDown=instance.parameters.DownDown;
   
   Neutral=instance.parameters.Neutral;
   
  
   
  
  assert(core.indicators:findIndicator("VQ") ~= nil, "Please, download and install VQ.LUA indicator");    
  
    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	 instance:name(name );
	 
	 if   (nameOnly) then
        return;
     end
	
	 Indicator = core.indicators:create("VQ", source ,  Method, Steady, Length, Smoothing, Filter, UpUp, DownDown, Neutral);
	
    instance:setLabelColor(Neutral);
   instance:ownerDrawn(true);		
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
			
			 context:createPen (3, context.SOLID, 1, DownDown)       
			context:createSolidBrush(4, DownDown);
			
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
										
												 
									         	     if Indicator.DATA:colorI(period) == UpUp then		 
																
																C2=2;
																C1=1;
																	
													 
														elseif  Indicator.DATA:colorI(period) == DownDown then		 
																 
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

