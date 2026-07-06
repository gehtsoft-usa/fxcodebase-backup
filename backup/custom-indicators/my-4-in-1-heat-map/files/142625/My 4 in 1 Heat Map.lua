-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71303

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("My 4 in 1 Heat Map");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator); 
 
	indicator.parameters:addGroup("Calculation");
	
 
	indicator.parameters:addInteger("MVAPeriods", "MVA Periods", "MVA Periods", 10)
        indicator.parameters:addInteger("RSIPeriods", "RSI Periods", "RSI Periods", 14)
        indicator.parameters:addInteger("MVA1Periods", "MVA1 Periods", "MVA1 Periods", 20)
        indicator.parameters:addInteger("DMIPeriods", "DMI Periods", "DMI Periods", 14)
 
    
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
 
local Label = {"Price/MVA1", "RSI/50", "MVA1/MVA2", "DMI.DIP/DMI.DIM"};
 
--4 indicators
local VSpace, HSpace, Size, Color;
local MVA
local RSI
local MVA1
local DMI
local Indicator



-- Routine
 function Prepare(nameOnly)   
 
    Profile_Label=""; 
 
    local name = profile:id() .. "(" ..  instance.source:name() .. Profile_Label  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	BC= instance.parameters.BC;
	SC= instance.parameters.SC;
	NC= instance.parameters.NC; 
 
	
	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;
	
	
	for j= 1, Number, 1 do
	Signal[j] = instance:addInternalStream(0, 0); -- addInternalStream is same as {} (Array) but addInternalStream is  synchronous with the candles
	end
	 
	
    source = instance.source;


 
	
    MVA = core.indicators:create("MVA", source.close, instance.parameters["MVAPeriods"]);
   -- MVA = core.indicators:create("MVA", source.close, instance.parameters[0]);
    RSI = core.indicators:create("RSI", source.close, instance.parameters["RSIPeriods"]);
    
    MVA1 = core.indicators:create("MVA", source.close, instance.parameters["MVA1Periods"]);
    
    DMI = core.indicators:create("DMI", source, instance.parameters["DMIPeriods"]);
	
	
	first=math.max(MVA.DATA:first(),RSI.DATA:first(),MVA1.DATA:first(),DMI.DATA:first());
		
    instance:ownerDrawn(true);
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 
        MVA:update(core.UpdateLast);
        RSI:update(core.UpdateLast);
        MVA1:update(core.UpdateLast);
        DMI:update(core.UpdateLast);

 
   
   if period < first then
   return;
   end
   
 
	for i= 1, Number, 1 do
	
 
		    if i== 1 then
			--define signal for teh line 1
				if source.close[period] > MVA.MVA[period] then  --<-- Change this line
				--if source[period]> MVA1.DATA[period] then  --<-- Change this line
				Signal[i][period]=1;
				elseif source.close[period] < MVA.MVA[period] then  --<-- Change this line
				Signal[i][period]=-1;
				else 
				Signal[i][period]=0;
				end
		    elseif i== 2 then
			--define signal for teh line 2			
				if RSI.RSI[period] > 50 then  --<-- Change this line
				Signal[i][period]=1;
				elseif RSI.RSI[period] < 50 then  --<-- Change this line
				Signal[i][period]=-1;
				else 
				Signal[i][period]=0;
				end
		    elseif i== 3 then
			--define signal for teh line 3			
				if MVA.MVA[period] > MVA1.MVA[period] then  --<-- Change this line
				Signal[i][period]=1;
				elseif MVA.MVA[period] < MVA1.MVA[period] then  --<-- Change this line
				Signal[i][period]=-1;
				else 
				Signal[i][period]=0;
				end
		    elseif i== 4 then
			--define signal for teh line 4			
				if DMI.DIP[period] > DMI.DIM[period] then  --<-- Change this line
				Signal[i][period]=1;
				elseif DMI.DIP[period] < DMI.DIM[period] then  --<-- Change this line
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
	--when to draw 
 
   
    local style = context.SINGLELINE + context.CENTER + context.VCENTER;

  
    context:setClipRectangle(context:left(), context:top() , context:right(), context:bottom() );
   	--limit the area 
        if not init then
		   
		 
			
			context:createPen (11, context.SOLID, 3,BC)       
			context:createSolidBrush(12, BC);
			
			context:createPen (21, context.SOLID, 3, SC)       
			context:createSolidBrush(22, SC);
		
			
			context:createPen (31, context.SOLID, 3, NC)       
			context:createSolidBrush(32, NC); 
			
            init = true;
        end
     
        
        local first = math.max(first, context:firstBar ());
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
										
																									
												
											 
					-- 0 Top of the screen
					-- 1024 Bottom of the screen
					 --VCellSize =((context:bottom() -context:top())/ (Number+1)); 
					 --1024-0 /(5) -> 204,8
					-- context:top()+VCellSize/2+VCellSize * (j-1)	
				    -- context:top()+VCellSize/2+VCellSize * (j)	
					-- for j=1
					--0+102 + 204*(1-1) ->  102 as Top of the Rectangle for the 1 Line
					--0+102 + 204*(1 ) -> 306 as Bottom of the Rectangle for the 1 Line
						 
				 	                
				   context:drawRectangle (C1, C2, x1+HCellSize, context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace, x2-HCellSize, context:top() +VCellSize/2+ VCellSize * (j)-VCellSize* VSpace);
				   	 --context:drawRectangle (pen, brush, x1, y1, x2, y2, transparency?)
					 
				   
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
 