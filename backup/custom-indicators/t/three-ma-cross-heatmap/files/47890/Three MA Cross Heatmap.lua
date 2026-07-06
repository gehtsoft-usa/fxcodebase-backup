-- Id: 8027

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27375


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

 function Add(id, TF,Flag, Instrument )
   
    indicator.parameters:addGroup(id..". Slot" );
	indicator.parameters:addBoolean("On".. id , "Show This Slot", "",true);	  
 
    indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument);
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addInteger("Period".. id, "Number of periods", "", 14, 1, 200);
    
end

 
 
function Init()
    indicator:name("Three MA Cross Heatmap");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	Add(1,"close", 5,"EMA","close",6, "EMA");
	Add(2,"close", 13, "EMA","close",21 , "EMA");
	Add(3,"close", 50, "EMA","close",200, "EMA");

 
     indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("Color", "Label Color","", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","", core.rgb(128, 128, 128));
   indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("Size", "Font Size (%)","",90, 50, 200);
   
   
end


function Add(id,Price1, P1, M1,Price2, P2, M2)
    indicator.parameters:addGroup( id .. ". MA Cross Calulation");	
	indicator.parameters:addString("Price1"..id,   "1. MA Price Source", "", Price1);
    indicator.parameters:addStringAlternative("Price1"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1"..id, "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addInteger("P1"..id, "1. MA Period", "Period", P1);
	
	indicator.parameters:addString("M1" .. id,  "1. MA Method", "Method" , M1);
    indicator.parameters:addStringAlternative("M1" .. id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("M1" .. id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("M1" .. id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("M1" .. id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("M1" .. id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("M1" .. id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("M1" .. id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("M1" .. id, "WMA", "WMA" , "WMA");

    indicator.parameters:addString("Price2"..id,   "2. MA Price Source", "", Price2);
    indicator.parameters:addStringAlternative("Price2"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2"..id, "WEIGHTED", "", "weighted");	

    indicator.parameters:addInteger("P2"..id, "2. MA Period", "Period", P2);	
		 
	indicator.parameters:addString("M2" .. id,   "2. MA Method", "Method" , M2);
    indicator.parameters:addStringAlternative("M2" .. id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("M2" .. id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("M2" .. id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("M2" .. id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("M2" .. id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("M2" .. id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("M2" .. id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("M2" .. id, "WMA", "WMA" , "WMA");

end

 
 
local source;
 

local VSpace,HSpace;
local Color;
local Size;
 
local Up,Down,Neutral ;

local Indicator1 = {} 
local Indicator2 = {} ;
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
    source = instance.source;	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Method=instance.parameters.Method;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
	 host = core.host;
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;
   instance:setLabelColor(Color);
   instance:ownerDrawn(true);
   

 
      
	 
	 for i= 1, 3, 1 do
    assert(core.indicators:findIndicator(instance.parameters:getString("M1" .. i)) ~= nil, instance.parameters:getString("M1" .. i) .. " indicator must be installed");
	 Indicator1[i] = core.indicators:create(instance.parameters:getString("M1" .. i), source[instance.parameters:getString("Price1" .. i)] , instance.parameters:getInteger("P1" .. i));   			 
    assert(core.indicators:findIndicator(instance.parameters:getString("M2" .. i)) ~= nil, instance.parameters:getString("M2" .. i) .. " indicator must be installed");
	 Indicator2[i] = core.indicators:create(instance.parameters:getString("M2" .. i), source[instance.parameters:getString("Price2" .. i)] , instance.parameters:getInteger("P2" .. i));   					   
     end 
 
      core.host:execute ("setTimer", 1, 1);
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 




function Update(period,mode)



end

function AsyncOperationFinished(cookie)
	 
	 
	 if cookie==1 then
	    for i= 1, 3, 1 do
             Indicator1[i]:update(core.UpdateLast);
			  Indicator2[i]:update(core.UpdateLast ); 
         end   
	  instance:updateFrom(0);
	end
	
 
   
        
    return core.ASYNC_REDRAW ;
	
	
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		   
			
			 context:createPen (1, context.SOLID, 3, Color)       
			context:createSolidBrush(2, Color);
			
			context:createPen (11, context.SOLID, 3, Up)       
			context:createSolidBrush(12, Up);
			
			context:createPen (21, context.SOLID, 3,Down)       
			context:createSolidBrush(22, Down);
		
			
			context:createPen (31, context.SOLID, 3, Neutral)       
			context:createSolidBrush(32, Neutral);
			 
		  
            init = true;
        end
     
	   
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =(X2-X1)*HSpace;
		 VCellSize =((context:bottom() -context:top())/ (4)); 
	
       
			    for i= first, last, 1 do	 
			   x0, x1, x2 = context:positionOfBar (i);
			   
			    for j= 1, 3 , 1 do
				  
                
								
										if Indicator1[j].DATA:hasData(i) and Indicator2[j].DATA:hasData(i) then 
										
												    if Indicator1[j].DATA[i] > Indicator2[j].DATA[i] then		 
															 
															C2=12;
															C1=11;
													elseif Indicator1[j].DATA[i] < Indicator2[j].DATA[i] then		 
															C2=22;
															C1=21;
												 	
												 
												    else  
													      
															C2=32;
															C1=31;
													 													
													 
													end
										
																									
												
											 
												 
												     
									   else		
									   C1=1; C2=2;										   
									   end 
									   
						 
			 				
				   context:drawRectangle (C1, C2, x1+HCellSize, context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace, x2-HCellSize, context:top() +VCellSize/2+ VCellSize * (j)-VCellSize* VSpace);
				   
				   
					 if i== first then			 	 
					 local width, height; 
					 context:createFont(3, "Arial", ((X2-X1)/100)*Size, (VCellSize/100)*Size, context.NORMAL);
					 Value= tostring( j..".");
					 width, height = context:measureText (3,  Value , style)	 
					 context:drawText(3,  Value , Color, -1, X2 +(X2-X1), context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace ,X2+(X2-X1)+width, context:top()+VCellSize/2 + VCellSize * (j)-VCellSize* VSpace, style);
					 
					 
									

					 end  				 
				 
				 
			 
			 end
			 
	   end
	   
	
end
 