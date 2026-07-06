-- More information about this indicator can be found at:
--http://www.fxcodebase.com/code/viewtopic.php?f=17&t=66681

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Genesis Matrix Trading");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
	
	
	indicator.parameters:addGroup("TVI Calculation"); 
	indicator.parameters:addInteger("r", "First Smoothing", "", 12);
    indicator.parameters:addInteger("s",  "Second Smoothing", "", 12);
    indicator.parameters:addInteger("u", "Signal", "u", 5);

	indicator.parameters:addGroup("CCI Calculation"); 
	indicator.parameters:addInteger("CCI_Period", "Period", "Period", 20);
	
	
	indicator.parameters:addGroup("T3 Calculation");
    indicator.parameters:addDouble("VF", "Volume Factor", "Volume Factor", 0.618, 0, 1);
    indicator.parameters:addInteger("F", "Period", "Period",8,2,2000);
	
	
	indicator.parameters:addGroup("GannHiLo Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 10);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BC", "Color of Buy", "Color of Buy", core.rgb(0, 255, 0));
	indicator.parameters:addColor("SC", "Color of Sell", "Color of Sell", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NC", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
	
	
	indicator.parameters:addColor("Color", "Label Color","", core.rgb(0, 0, 0)); 
   indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("Size", "Font Size (%)","",90, 50, 200);
end

 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 

local Number=4;
local BC, SC,NC ;
local Signal={};
local Label={"TVI", "CCI", "T3", "Gann HiLo"};
local VSpace, HSpace, Size, Color;
local TVI, r, s, u;
local CCI, CCI_Period;
local T3, VF, F;
local High, Low, Period;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	BC= instance.parameters.BC;
	SC= instance.parameters.SC;
	NC= instance.parameters.NC;  
	
	
	assert(core.indicators:findIndicator("TVI") ~= nil, "Please, download and install TVI.LUA indicator");
	assert(core.indicators:findIndicator("T3X6") ~= nil, "Please, download and install T3X6.LUA indicator");
	
	r= instance.parameters.r;
	s= instance.parameters.s;
	u= instance.parameters.u; 
	
	CCI_Period= instance.parameters.CCI_Period;
	
	VF= instance.parameters.VF;
	F= instance.parameters.F;
	
	Period= instance.parameters.Period;
 
	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;
	
	
	for i= 1, Number, 1 do
	Signal[i] = instance:addInternalStream(0, 0);
	end
	
    source = instance.source;
   

	TVI = core.indicators:create("TVI", source, r, s, u);
	CCI = core.indicators:create("CCI", source, CCI_Period);
	T3 = core.indicators:create("T3X6", source.close,  F, VF);
	High= core.indicators:create("MVA", source.high, Period);
	Low= core.indicators:create("MVA", source.low, Period);
	
    first=math.max(TVI.DATA:first(), CCI.DATA:first(), T3.DATA:first(), High.DATA:first());
	
	 
    instance:ownerDrawn(true);
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)



    TVI:update(mode);
	CCI:update(mode);
	T3:update(mode);
	High:update(mode);
	Low:update(mode);
	
    if period < first then
	return;
	end
	
    
	for i= 1, Number, 1 do
	
	
		 
		    if i== 1 then
				if TVI.DATA[period]> TVI.DATA[period-i] then
				Signal[i][period]=1;
				elseif TVI.DATA[period]< TVI.DATA[period-i] then
				Signal[i][period]=-1;
				else 
				Signal[i][period]=0;
				end
		    end	
			
			if i== 2 then
				if CCI.DATA[period]> 0 then
				Signal[i][period]=1;
				elseif CCI.DATA[period]< 0 then
				Signal[i][period]=-1;
				else 
				Signal[i][period]=0;
				end
		    end	
			
			if i== 3 then
				if T3.DATA[period]> T3.DATA[period-1] then
				Signal[i][period]=1;
				elseif T3.DATA[period]< T3.DATA[period-1] then
				Signal[i][period]=-1;
				else 
				Signal[i][period]=0;
				end
		    end	
			
			
			if i== 4 then
				if source.close[period]> High.DATA[period-1] then
				Signal[i][period]=1;
				elseif source.close[period]< Low.DATA[period-1] then
				Signal[i][period]=-1;
				else 
				Signal[i][period]=0;
				end
		    end	
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
		   
		 
			
			context:createPen (11, context.SOLID, 3, BC)       
			context:createSolidBrush(12, BC);
			
			context:createPen (21, context.SOLID, 3, SC)       
			context:createSolidBrush(22, SC);
		
			
			context:createPen (31, context.SOLID, 3, NC)       
			context:createSolidBrush(32, NC); 
			
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =(X2-X1)*HSpace;
		 VCellSize =((context:bottom() -context:top())/ (Number+1)); 
	
       
			    for i= first, last, 1 do	 
			   x0, x1, x2 = context:positionOfBar (i);
			   
			    for j= 1, Number , 1 do
				   
				  
				 
				 
						
								
										 
										
												    if Signal[j][i] == 1 then		 
															 
															C2=12;
															C1=11;
															 
												 
												    elseif Signal[j][i] == -1 then		 
															 
														   C2=22;
															C1=21;
													else
                                                            C2=32;
															C1=31;
															
													end
										
																									
												
											 
									 
									   
						 
				 				
				   context:drawRectangle (C1, C2, x1+HCellSize, context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace, x2-HCellSize, context:top() +VCellSize/2+ VCellSize * (j)-VCellSize* VSpace);
				   
				   
					 if i== first then			 	 
					 local width, height; 
					 context:createFont(3, "Arial", ((X2-X1)/100)*Size, (VCellSize/100)*Size, context.NORMAL);
					 Value= tostring( Label[j]);
					 width, height = context:measureText (3,  Value , style)	 
					 context:drawText(3,  Value , Color, -1, X2 +(X2-X1), context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace ,X2+(X2-X1)+width, context:top()+VCellSize/2 + VCellSize * (j)-VCellSize* VSpace, style);
					 
					 
									

					 end  				 
				 
				 
			 
			 end
			 
	   end
	   
	
end
 