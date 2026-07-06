-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=11367
-- Id: 5537

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
 
function Init()
    indicator:name("Trix Bar");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("P_N", "TRIX Periods", "", 14);
    indicator.parameters:addString("MA_1", "First Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "EMA");
    indicator.parameters:addStringAlternative("MA_1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_1", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA_1", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_1", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_1", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_1", "Wilders*", "", "WMA");
    indicator.parameters:addString("MA_2", "Second Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "EMA");
    indicator.parameters:addStringAlternative("MA_2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_2", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA_2", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_2", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_2", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_2", "Wilders*", "", "WMA");
    indicator.parameters:addString("MA_3", "Third Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "EMA");
    indicator.parameters:addStringAlternative("MA_3", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_3", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_3", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_3", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA_3", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_3", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_3", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_3", "Wilders*", "", "WMA");
    indicator.parameters:addInteger("S_N", "Signal Periods", "", 9);
    indicator.parameters:addString("MA_S", "Signal Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MA_S", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_S", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_S", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_S", "TMA", "", "TMA");
    indicator.parameters:addStringAlternative("MA_S", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_S", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MA_S", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MA_S", "Wilders*", "", "WMA");

    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpUp", "Up in Up Trend Color","", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("DownDown", "Down in Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(128, 128, 128));
 
    indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
end 

local HSpace;
local UpUp, UpDown, DownUp,DownDown,Neutral;
local Indicator;
local P_N, MA_1, MA_2, MA_3, S_N, MA_S;
local first;
local Short={};
function Prepare(nameOnly)
 
    source = instance.source;	
	HSpace=(instance.parameters.HSpace/100);
	
	P_N=instance.parameters.P_N;
	MA_1=instance.parameters.MA_1;
	MA_2=instance.parameters.MA_2;
	MA_3=instance.parameters.MA_3;
	S_N=instance.parameters.S_N;
	MA_S=instance.parameters.MA_S;
	
   UpUp=instance.parameters.UpUp;
   UpDown=instance.parameters.UpDown;
   
   DownUp=instance.parameters.DownUp;
   DownDown=instance.parameters.DownDown;
   
   Neutral=instance.parameters.Neutral;
   
   
   
    assert(core.indicators:findIndicator(instance.parameters.MA_1) ~= nil, "Please, download and install ".. instance.parameters.MA_1.. " indicator");  
	assert(core.indicators:findIndicator(instance.parameters.MA_2) ~= nil, "Please, download and install ".. instance.parameters.MA_2.. " AVERAGES.LUA indicator");  
	assert(core.indicators:findIndicator(instance.parameters.MA_2) ~= nil, "Please, download and install  ".. instance.parameters.MA_3.. "AVERAGES.LUA indicator");  
   

    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
     instance:name(name );
    if nameOnly then
        return;
    end
	
	
	instance:setLabelColor(Neutral);
    instance:ownerDrawn(true);
	
	 assert(core.indicators:findIndicator("TRIX") ~= nil, "Please, download and install TRIX.LUA indicator");    
	 Indicator = core.indicators:create("TRIX", source  ,  P_N, MA_1, MA_2, MA_3, S_N, MA_S);
	 Short[1] = Indicator:getStream(0);
	 Short[2] = Indicator:getStream(1);
	  Short[3] = Indicator:getStream(2);
	 
	 first = math.max(Short[1]:first(),Short[2]:first());
		
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
			   
			
						
								
										if period > first  then 
										
												 
									         	     if    Short[1][period] >  Short[2][period] 
                                                  	 and Short[1][period]  > 0
													 then
																 
																C2=2;
																C1=1;
															 	
													 
														elseif    Short[1][period] <  Short[2][period] 
                                                  	    and Short[1][period]  < 0
													    then 
																 
																 
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

