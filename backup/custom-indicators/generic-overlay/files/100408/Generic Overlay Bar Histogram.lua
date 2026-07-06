-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62211

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
    indicator:name("Generic Overlay Bar Histogram");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	

    indicator.parameters:addGroup("Data Selection");	
	indicator.parameters:addString("INDICATOR", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number", "Data Stream Number", "", 1, 1 , 100);
	
	
	indicator.parameters:addString("Type", "Type", "Type" , "Slope");
    indicator.parameters:addStringAlternative("Type", "Slope", "Slope" , "Slope");
    indicator.parameters:addStringAlternative("Type", "Position relation to the signal line", "Position relation to the signal line" , "Signal");
	indicator.parameters:addStringAlternative("Type", "Level", "Level" , "Level");
	indicator.parameters:addStringAlternative("Type", "Overbought / Oversold", "Overbought / Oversold" , "Overbought/Oversold"); 
	indicator.parameters:addStringAlternative("Type", "Line Color" ,"", "Color"); 
	
	indicator.parameters:addInteger("Overbought", "Overbought Level", "", 80);
	indicator.parameters:addInteger("Oversold", "Oversold Level", "", 20);
	indicator.parameters:addInteger("Level", "Level", "", 0);
		
	indicator.parameters:addGroup("Signal Line");
 
	indicator.parameters:addInteger("Period", "Smoothing Period", "", 20, 1 , 1000);
	indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	
 

    indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("Up", "Up  Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128)); 
 
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
   
   
end 

local HSpace;
local Number;
local INDICATOR;
local final={};
local FIRST=1;
local source;
local Indicator= nil;
local Count; 
local INDEX;
local Up,Down,Neutral;
local Method;
local MA;
local Period;
local Type;
local first;
local Overbought, Oversold,Level;
local  Histogram=nil;

function Prepare(nameOnly)
 
    source = instance.source;	
	HSpace=(instance.parameters.HSpace/100);

    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	instance:name(name );
	if nameOnly then
		return;
	end
	 
	Period=instance.parameters.Period;
    Method=instance.parameters.Method; 
    INDICATOR=instance.parameters.INDICATOR;
    Overbought=instance.parameters.Overbought;
    Oversold=instance.parameters.Oversold;	
	Level=instance.parameters.Level;
	Type=instance.parameters.Type;
   	Number=instance.parameters.Number;
	Number=Number-1;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	 
			assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install " ..  Method ..".LUA indicator");
 
	
		local iprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
		local iparams = instance.parameters:getCustomParameters("INDICATOR");

		if  iprofile:requiredSource() == core.Tick then			
			Indicator = iprofile:createInstance( source.close, iparams);
		else
			Indicator = iprofile:createInstance(source, iparams);
		end
	
	 Count= Indicator:getStreamCount ();
	 
	 if Number >= Count then
	 Number = Count;
	  assert( false, "Incorrect index of stream. The indicator has only ".. Count  .. " stream(s).");
	 end	 
	 
	INDEX=  Indicator:getStream (Number);	
			

	if Type== "Signal" then
	MA = core.indicators:create(Method, INDEX, Period);		
	FIRST = math.max(FIRST, MA.DATA:first()) ;
    else
    FIRST = math.max(FIRST, INDEX:first()) ;	
	end		

   instance:setLabelColor(Neutral);
   instance:ownerDrawn(true);	
		
end



function Update(period, mode)

    Indicator:update(mode);
	
	            if Type== "Signal" then
				MA:update(mode);
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
		     context:createPen (1, context.SOLID, 1, Up)       
			context:createSolidBrush(2, Up);
			
			 context:createPen (3, context.SOLID, 1, Down)       
			context:createSolidBrush(4, Down);			
			
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
			   
		 
						
								
										if Indicator.DATA:hasData(period) and Indicator.DATA:hasData(period-1) then 
										
										
										
										
																					
													if Type == "Signal" then	
														if INDEX[period]> MA.DATA[period] then
														C2=2;
														C1=1;
														elseif  INDEX[period]< MA.DATA[period] then
														C2=4;
														C1=3;
														else
														C2=6;
														C1=5;
														end
													elseif Type == "Slope" then
														if INDEX[period]> INDEX[period-1] then
														C2=2;
														C1=1;	
														elseif  INDEX[period]< INDEX[period-1] then
														C2=4;
														C1=3;
														else
														C2=6;
														C1=5;
														end
													elseif Type == "Level" then
														if INDEX[period]> Level then
														C2=2;
														C1=1;
														elseif INDEX[period]< Level then
														C2=4;
														C1=3;
														else
														C2=6;
														C1=5;
														end
													elseif Type == "Overbought/Oversold" then	
														if INDEX[period]> Overbought then
														C2=2;
														C1=1;	
														elseif INDEX[period]< Oversold then
														C2=4;
														C1=3;
														else
														C2=6;
														C1=5;	
														end
													elseif Type== "Color" then
													
													
													      context:createPen (7, context.SOLID, 1, INDEX:colorI(period))       
			                                              context:createSolidBrush(8, INDEX:colorI(period));
													        C2=8;
													    	C1=7;	
													
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

