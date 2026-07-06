-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=73532

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Tick Peyton Indicator Heat Map");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
	
	
 
    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addInteger("Fast_Period", "Fast WPR period", "", 14);
    indicator.parameters:addInteger("Slow_Period", "Slow WPR period", "", 38);   
    indicator.parameters:addInteger("CCI_Period", "CCI Period", "", 39); 
	
    indicator.parameters:addInteger("wprhigh", "WPR High", "", 30);
    indicator.parameters:addInteger("wprlow", "WPR Low", "", 70);   
 
    indicator.parameters:addBoolean("SM", "Smooth", "Choose false to see the RAW Force Index value", true);
    indicator.parameters:addInteger("N", "Smoothing Periods", "", 33, 1, 1000);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("BCU", "Color of Buy Up ", "Color of Buy", core.rgb(0, 255, 0));
	indicator.parameters:addColor("BCD", "Color of Buy Down", "Color of Buy", core.rgb(0, 200, 0));
	indicator.parameters:addColor("SCU", "Color of Sell Up", "Color of Sell", core.rgb(255, 0, 0));
	indicator.parameters:addColor("SCD", "Color of Sell Down", "Color of Sell", core.rgb(200, 0, 0));	
	indicator.parameters:addColor("NCU", "Color of Neutral Up", "Color of Neutral", core.rgb(128, 128, 128));
	indicator.parameters:addColor("NCD", "Color of Neutral Down", "Color of Neutral", core.rgb(73, 73, 73));	
	
indicator.parameters:addColor("Color", "Label Color","", core.COLOR_LABEL ); 
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
local BCU, SCU,NCU ;
local BCD, SCD,NCD ;
local Signal={};
local Label={"RLW", "RLW", "CCI", "Force Index"};
local VSpace, HSpace, Size, Color; 
-- Routine
 function Prepare(nameOnly)

    source = instance.source;
	
	Fast_Period= instance.parameters.Fast_Period;
	Slow_Period= instance.parameters.Slow_Period;
	CCI_Period= instance.parameters.CCI_Period;
	  
	SM= instance.parameters.SM;
	N= instance.parameters.N;	
	
	wprhigh= instance.parameters.wprhigh;
	wprlow= instance.parameters.wprlow;
	
    Profile_Label=""; 
    Profile_Label=Profile_Label.. ", " ..  Fast_Period .. ", " ..  Slow_Period.. ", " ..  CCI_Period.. ", " ..  N; 
 
    local name = profile:id() .. "(" ..  instance.source:name() .. Profile_Label  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
	BCU= instance.parameters.BCU;
	SCU= instance.parameters.SCU;
	NCU= instance.parameters.NCU; 
	BCD= instance.parameters.BCD;
	SCD= instance.parameters.SCD;
	NCD= instance.parameters.NCD;  
	
	

	   
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Size=instance.parameters.Size;
    Color=instance.parameters.Color; 
 
    assert(core.indicators:findIndicator("TICK_RLW") ~= nil, "Please, download and install TICK_RLW.LUA indicator");	
    assert(core.indicators:findIndicator("TICK_CCI") ~= nil, "Please, download and install TICK_CCI.LUA indicator");
    assert(core.indicators:findIndicator("TICK_AEFI") ~= nil, "Please, download and install TICK_AEFI.LUA indicator");
	
	WPR1=core.indicators:create("TICK_RLW", source, Fast_Period);
	WPR2=core.indicators:create("TICK_RLW", source, Slow_Period);
	CCI= core.indicators:create("TICK_CCI", source, CCI_Period);	
	AEFI= core.indicators:create("TICK_AEFI", source, SM, N);	 
   

	for i= 1, Number, 1 do
	Signal[i] = instance:addInternalStream(0, 0); 
	end
	

    first=math.max(WPR1.DATA:first(),WPR2.DATA:first(),CCI.DATA:first());

 
	 
    instance:ownerDrawn(true);
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)



   WPR1:update(mode);
   WPR2:update(mode);  
   CCI:update(mode);   
   AEFI:update(mode);     
   
   if period <= first then
   return;
   end
 
  
    
	for i= 1, Number, 1 do
	
                if i== 1 then   
					if WPR2.DATA[period]> -wprhigh
					then						
						Signal[i][period]=1;	
					elseif WPR2.DATA[period]< -wprlow
                    then 	 
						Signal[i][period]=-1;
					      
					else 
					    Signal[i][period]=0;
					end
		        end
				
                if i== 2 then   
					if WPR2.DATA[period]> -50
					then						
						Signal[i][period]=1;	
					elseif WPR2.DATA[period]< -50
                    then 	 
						Signal[i][period]=-1;
					      
					else 
					    Signal[i][period]=0;
					end
		        end
 
                if i== 3 then   
					if CCI.DATA[period]> 0
					then						
						Signal[i][period]=1;	
					elseif CCI.DATA[period]< 0
                    then 	 
						Signal[i][period]=-1;
					      
					else 
					    Signal[i][period]=0;
					end
		        end	

                if i== 4 then   
					if AEFI.DATA[period]> 0
					then						
						Signal[i][period]=1;	
					elseif AEFI.DATA[period]< 0
                    then 	 
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
		   
		 
			
			context:createPen (1, context.SOLID, 3, BCU)       
			context:createSolidBrush(2, BCU);			
			context:createPen (3, context.SOLID, 3, BCD)       
			context:createSolidBrush(4, BCD)			
			
			context:createPen (5, context.SOLID, 3, SCU)       
			context:createSolidBrush(6, SCU);
			context:createPen (7, context.SOLID, 3, SCD)       
			context:createSolidBrush(8, SCD);		
			
			context:createPen (9, context.SOLID, 3, NCU)       
			context:createSolidBrush(10, NCU); 
			context:createPen (11, context.SOLID, 3, NCD)       
			context:createSolidBrush(12, NCD);			
			
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
				   
				  
				 
				 
						
								
										 
										
												    if Signal[j][i] == 1
													then	 	 
															 
															 
															if Signal[j][i] > Signal[j][i] then
															C1=1;  
															C2=2; 
															else
															C1=3;  
															C2=4; 															
															end

												    elseif Signal[j][i] == -1
													then	 
															 
															if Signal[j][i] > Signal[j][i] then
															C1=5;  
															C2=6; 
															else
															C1=7;  
															C2=8; 															
															end														
															 
												    else
													
													
															if Signal[j][i] > Signal[j][i] then
															C1=9;  
															C2=10; 
															else
															C1=11;  
															C2=12; 															
															end
													end
												    
										
																									
												
											 
									 
									   
						 
				 				
				   context:drawRectangle (C1, C2, x1+HCellSize, context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace, x2-HCellSize, context:top() +VCellSize/2+ VCellSize * (j)-VCellSize* VSpace);
				   
				   
					 if i== first then			 	 
					 local width, height; 
					 context:createFont(13, "Arial", ((X2-X1)/100)*Size, (VCellSize/100)*Size, context.NORMAL);
					 Value= tostring( Label[j]);
					 width, height = context:measureText (13,  Value , style)	 
					 context:drawText(13,  Value , Color, -1, X2 +(X2-X1), context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace ,X2+(X2-X1)+width, context:top()+VCellSize/2 + VCellSize * (j)-VCellSize* VSpace, style);
					 
					 
									

					 end  				 
				 
				 
			 
			 end
			 
	   end
	   
	
end


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+