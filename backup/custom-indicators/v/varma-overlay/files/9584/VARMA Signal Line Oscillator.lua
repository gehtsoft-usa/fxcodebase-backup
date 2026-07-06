-- Id: 3600
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3881

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
    indicator:name("VARMA Signal Line Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Fast VARMA"); 
    indicator.parameters:addInteger("FP", "Period", "", 9, 2, 2000);
	indicator.parameters:addInteger("FS", "Smoothing", "", 2, 1, 200);
	indicator.parameters:addString("Fast_Price", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Fast_Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Fast_Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Fast_Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Fast_Price", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Fast_Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Fast_Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Fast_Price", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addGroup("Signal VARMA Line"); 
    indicator.parameters:addInteger("SP", "Period", "", 27, 2, 2000);
	indicator.parameters:addString("Mode", "Signal Line MA Mode", "", "EMA");
	indicator.parameters:addStringAlternative("Mode", "(EMA) Exponential Moving Average", "", "EMA");
    indicator.parameters:addStringAlternative("Mode", "(SMA) Simple Moving Average", "", "MVA");   
    indicator.parameters:addStringAlternative("Mode", "(LWMA) Linear-weighted Moving Average", "", "LWMA");
    indicator.parameters:addStringAlternative("Mode", "(LSMA) Least Square Moving Average (Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("Mode", "(SMMA) Smoothed Moving Average", "", "SMMA");
    indicator.parameters:addStringAlternative("Mode", "(WMA) Wilders Smooth", "", "WMA");
	
	
	
	

    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpUp", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownDown", "Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(128, 128, 128));
 
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
   
   
end 

local HSpace;
local UpUp, DownDown,Neutral;
 
local FP, FS, SP, Mode;
local Fast_Price, Slow_Price;
local indicator={};
function Prepare(nameOnly)
 
    source = instance.source;	
	HSpace=(instance.parameters.HSpace/100);
	
	Fast_Price= instance.parameters.Fast_Price;
    Slow_Price= instance.parameters.Slow_Price;	
    FP = instance.parameters.FP;
    FS = instance.parameters.FS;
	
	Mode = instance.parameters.Mode;
    SP = instance.parameters.SP;
  
		
	assert(core.indicators:findIndicator("VARMA") ~= nil, "Please, download and install VARMA.LUA indicator");
 

    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	 instance:name(name );
	if nameOnly then
		return;
	end
	
    indicator["Fast"] = core.indicators:create("VARMA", source[Fast_Price], FP, FS);
    assert(core.indicators:findIndicator(Mode) ~= nil, Mode .. " indicator must be installed");
    indicator["Slow"] = core.indicators:create(Mode, indicator["Fast"].DATA, SP);
	 first = math.max(source:first(),indicator["Fast"].DATA:first(), indicator["Slow"].DATA:first()   );	
	
   UpUp=instance.parameters.UpUp;    
   DownDown=instance.parameters.DownDown;   
   Neutral=instance.parameters.Neutral;
   
   instance:setLabelColor(Neutral);
   instance:ownerDrawn(true);
	
		
end



function Update(period, mode)

    indicator["Fast"]:update(mode);
    indicator["Slow"]:update(mode);
	
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
			
			context:createPen (5, context.SOLID, 1, Neutral)       
			context:createSolidBrush(6, Neutral);
			 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			
						
								
										if period > first then 
										
												 
									         	     if indicator["Fast"].DATA[period] > indicator["Slow"].DATA[period] then		 
																 
																C2=2;
																C1=1;
																 
																
																 
														elseif indicator["Fast"].DATA[period] < indicator["Slow"].DATA[period]then	
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

