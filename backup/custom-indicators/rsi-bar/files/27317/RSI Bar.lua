-- Id: 5929
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14385

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
    indicator:name("RSI Bar");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSI", "RSI Period", "", 14);
    indicator.parameters:addInteger("MA", "MA Period", "", 14);
   
    indicator.parameters:addString("Type", "MA Method", "MA Method" , "EMA");
    indicator.parameters:addStringAlternative("Type", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Type", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Type", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Type", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Type", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Type", "WMA", "WMA" , "WMA");
  
	
	indicator.parameters:addDouble("Overbought", "Overbought Level", "", 70);
	  indicator.parameters:addDouble("Oversold", " Oversold Level", "",  30);
	  
	  
 
	indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("UpOB", "Color for Up in Overbought", "", core.rgb(0, 255, 0));
	  indicator.parameters:addColor("DnOB", "Color for Down in Overbought", "", core.rgb(0, 200, 0));
	  
	  indicator.parameters:addColor("UpOS", "Color for Up in Oversold", "", core.rgb(255, 0,0));
	  indicator.parameters:addColor("DnOS", "Color for  Down in Oversold", "", core.rgb(200,0, 0)); 
	  
	   indicator.parameters:addColor("UpOF", "Color for Up over cental line", "", core.rgb(192, 192, 192));
	  indicator.parameters:addColor("DnOF", "Color for Down over cental line", "", core.rgb(137,137, 137)); 
	  
	   indicator.parameters:addColor("UpUF", "Color for Up under cental line", "", core.rgb(255,128, 0));
	  indicator.parameters:addColor("DnUF", "Color for Down under cental line", "", core.rgb(255,255, 0)); 
	  indicator.parameters:addColor("Color", "Label Color", "", core.rgb(0,0, 0)); 
	  
	  indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RSI;
local MA;
local Type;
local first;
local source = nil;
local Indicator={};
local Out = nil;
local Overbought;
local Oversold;
local Color;
local HSpace;
-- Routine
function Prepare(nameOnly)
    Overbought = instance.parameters.Overbought;
	Oversold = instance.parameters.Oversold;
	Color= instance.parameters.Color;
	RSI = instance.parameters.RSI;
    MA = instance.parameters.MA;
	Type = instance.parameters.Type;
    source = instance.source;
    HSpace=(instance.parameters.HSpace/100);

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(RSI) .. ", " .. tostring(Overbought).. ", " .. tostring(Oversold).. ", " .. tostring(MA) .. ", " .. tostring(Type) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	 Indicator["RSI"] = core.indicators:create("RSI", source, RSI);
    assert(core.indicators:findIndicator(Type) ~= nil, Type .. " indicator must be installed");
	 Indicator["MA"] = core.indicators:create(Type, Indicator["RSI"].DATA, MA);
	
	 
	 first = math.max(Indicator["RSI"].DATA:first(),Indicator["MA"].DATA:first());
 
 
    instance:setLabelColor(Color);
     instance:ownerDrawn(true);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
	
	 Indicator["RSI"]:update(mode);
	 Indicator["MA"]:update(mode);
	
	 
end



local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
    

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, instance.parameters.UpOB)       
			context:createSolidBrush(2, instance.parameters.UpOB);
			
			 context:createPen (3, context.SOLID, 1, instance.parameters.DnOB)       
			context:createSolidBrush(4, instance.parameters.DnOB);
			
			context:createPen (5, context.SOLID, 1, instance.parameters.UpOS)       
			context:createSolidBrush(6, instance.parameters.UpOS);
			
			 context:createPen (7, context.SOLID, 1, instance.parameters.DnOS)       
			context:createSolidBrush(8, instance.parameters.DnOS);
 
			  
			  
			 context:createPen (9, context.SOLID, 1, instance.parameters.UpOF)       
			context:createSolidBrush(10, instance.parameters.UpOF);
			
			 context:createPen (11, context.SOLID, 1, instance.parameters.DnOF)       
			context:createSolidBrush(12, instance.parameters.DnOF);
			
			context:createPen (13, context.SOLID, 1, instance.parameters.UpUF)       
			context:createSolidBrush(14, instance.parameters.UpUF);
			
			 context:createPen (15, context.SOLID, 1, instance.parameters.DnUF)       
			context:createSolidBrush(16, instance.parameters.DnUF);  
		  
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


    if not Indicator["MA"].DATA:hasData(period)
	or not Indicator["MA"].DATA:hasData(period)
	then
	return;
	end
	
	
                                   x0, x1, x2 = context:positionOfBar (period);
			   
			
													
								if  Indicator["MA"].DATA[period] > Overbought  then
										  if Indicator["MA"].DATA[period] > Indicator["MA"].DATA[period-1 ] then
										  C1=1;C2=2;
										  else	  
										  C1=3;C2=4;
										  end
								 elseif Indicator["MA"].DATA[period]  <  Oversold then
										   if Indicator["MA"].DATA[period] > Indicator["MA"].DATA[period-1 ] then
										 C1=5;C2=6;
										  else
										 C1=7;C2=8;
										  end
								 elseif Indicator["MA"].DATA[period]  > 50 then
								 
										  if Indicator["MA"].DATA[period] > Indicator["MA"].DATA[period-1 ] then
										    C1=9;C2=10; 
										  else			  
										   C1=11;C2=12; 
										  end
										  
								 elseif Indicator["MA"].DATA[period] < 50 then		  
											if Indicator["MA"].DATA[period] > Indicator["MA"].DATA[period-1 ] then
										   C1=13;C2=14; 
										  else			  
										   C1=15;C2=16; 
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


 