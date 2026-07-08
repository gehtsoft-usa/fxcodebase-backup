-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1968

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
    indicator:name("Market Facilitation Index Bar");
    indicator:description("Market Facilitation Index Bar");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("RANGE", "Range", "Multiplication factor, which brings the difference in points down to whole", 1, 0.00001, 100);

    indicator.parameters:addGroup("Style");
    local colors = core.colors();
    indicator.parameters:addColor("MUVU_Color", "MFI Up/Volume Up Color", "", colors.Lime);
    indicator.parameters:addColor("MDVD_Color", "MFI Down/Volume Down Color", "", colors.SaddleBrown);
    indicator.parameters:addColor("MUVD_Color", "MFI Up/Volume Down Color", "", colors.Blue);
    indicator.parameters:addColor("MDVU_Color", "MFI Down/Volume Up Color", "", colors.Pink);
	
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(128, 128, 128)); 
    indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block 
local source;
local RANGE;
local first;
local first1;
local MFI;
local point;
local MUVU;
local MDVD;
local MUVD;
local MDVU;
local MU;
local VU; 
local HSpace; 

-- Routine
function Prepare(nameOnly)  
    
 
	source = instance.source;
    first = source:first() + 1;
    first1 = source:first();
    RANGE = instance.parameters.RANGE;		
	HSpace=(instance.parameters.HSpace/100);
    point = source:pipSize(); 
	
	
	 local name;
    name = profile:id() .. "(" .. source:name() .. "," .. RANGE .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
   instance:setLabelColor(instance.parameters.Neutral);
   instance:ownerDrawn(true);

    assert(source:supportsVolume(), "The source must have volume");

   
 
	MFI = instance:addInternalStream(0, 0);
    MU = instance:addInternalStream(0, 0);
    VU = instance:addInternalStream(0, 0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

     
    MU[period] = 0;
    VU[period] = 0;

    if period< first1 then
	return;
	end
        MFI[period] = RANGE * (source.high[period] - source.low[period]) / (source.volume[period] * point);
   

    if period < first then
	return;
	end
	
        local mu, vu;

        mu = MU[period - 1];
        vu = VU[period - 1];

        if MFI[period] > MFI[period - 1] then
            mu = 1;
        elseif MFI[period] < MFI[period - 1] then
            mu = -1;
        end

        if source.volume[period] > source.volume[period - 1] then
            vu = 1;
        elseif source.volume[period] < source.volume[period - 1] then
            vu = -1;
        end

        MU[period] = mu;
        VU[period] = vu;
 
    
end


function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
    

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, instance.parameters.MUVU_Color)       
			context:createSolidBrush(2, instance.parameters.MUVU_Color);
			
			 context:createPen (3, context.SOLID, 1, instance.parameters.MDVD_Color)       
			context:createSolidBrush(4, instance.parameters.MDVD_Color);
			
			context:createPen (5, context.SOLID, 1, instance.parameters.MUVD_Color)       
			context:createSolidBrush(6, instance.parameters.MUVD_Color);
			
			 context:createPen (7, context.SOLID, 1, instance.parameters.MDVU_Color)       
			context:createSolidBrush(8, instance.parameters.MDVU_Color);
			 
		    context:createPen (9, context.SOLID, 1, instance.parameters.Neutral)       
			context:createSolidBrush(10, instance.parameters.Neutral);
			
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local period;
		
			 for period= first, last, 1 do	   
			   x0, x1, x2 = context:positionOfBar (period);
			   
			 
													
									                
										
																									 
																				 if MU[period] > 0 and VU[period] > 0 then
																					  C1=1; C2=2;			
																				elseif MU[period] < 0 and VU[period] < 0 then
																					 C1=3; C2=4;		
																				elseif MU[period] > 0 and VU[period] < 0 then
																					  C1=5; C2=6;	
																				elseif MU[period] < 0 and VU[period] > 0 then
																					  C1=7; C2=8;	
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




