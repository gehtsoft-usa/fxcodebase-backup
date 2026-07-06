-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4037

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
    indicator:name("Better Volume");
    indicator:description("Better Volume");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("N", "Average Period", "No description", 20);
    indicator.parameters:addInteger("Back", "Analyse Period Back", "No description", 20);
    indicator.parameters:addBoolean("TwoBars", "Use TwoBars", "No description", false);
    
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("LowVol_color", "Color of LowVol_color", "Color of LowVol_color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("ClimaxUp_color", "Color of ClimaxUp", "Color of ClimaxUp", core.rgb(255, 0, 0));
    indicator.parameters:addColor("ClimaxDn_color", "Color of ClimaxDn", "Color of ClimaxDn", core.rgb(255, 255, 255));
    indicator.parameters:addColor("DensityUp_color", "Color of Churn", "Color of DensityUp", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DensityDn_color", "Color of ClimaxChurn", "Color of DensityDn", core.rgb(255, 0, 128));
    indicator.parameters:addColor("VolumeBar_color", "Color of VolumeBar", "Color of VolumeBar", core.rgb(128, 128, 128)); 
    indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128,128, 128));  
    indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50); 
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block 
local N;
local Back;

local first;
local source = nil;

-- Streams block
local ClimaxUp = nil;
local ClimaxDn = nil;
local DensityUp = nil;
local DensityDn = nil;    
local HSpace; 
 
-- Routine
function Prepare(nameOnly)
    
    HSpace=(instance.parameters.HSpace/100);
     
 
     N = instance.parameters.N;
    Back = instance.parameters.Back; 
    source = instance.source;
    first = source:first() + N + Back -1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(N) .. ", " .. tostring(Back) .. ")";
    instance:name(name);

	if   (nameOnly) then
        return;
    end
	
        Value1 = instance:addInternalStream(0,0);
        Value2 = instance:addInternalStream(0,0);
        Value3 = instance:addInternalStream(0,0);
        Value4 = instance:addInternalStream(0,0);
        Value5 = instance:addInternalStream(0,0);
        Value6 = instance:addInternalStream(0,0);
        Value7 = instance:addInternalStream(0,0);
        Value8 = instance:addInternalStream(0,0);
        Value9 = instance:addInternalStream(0,0);
        Value10 = instance:addInternalStream(0,0);
        Value11 = instance:addInternalStream(0,0);
        Value12 = instance:addInternalStream(0,0);
        Value13 = instance:addInternalStream(0,0);
        Value14 = instance:addInternalStream(0,0);
        Value15 = instance:addInternalStream(0,0);
        Value16 = instance:addInternalStream(0,0);
        Value17 = instance:addInternalStream(0,0);
        Value18 = instance:addInternalStream(0,0);
        Value19 = instance:addInternalStream(0,0);
        Value20 = instance:addInternalStream(0,0);
        Value21 = instance:addInternalStream(0,0);
        Value22 = instance:addInternalStream(0,0);
	
  
   instance:ownerDrawn(true);
    assert(source:supportsVolume(), "The source must have volume");
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

      local p = period;
        local HIGH = source.high[period];
        local LOW = source.low[period];
        local OPEN = source.open[period];
        local CLOSE = source.close[period];
        local VOLUME = source.volume[period];
    
 
    
    if period < first   then
	
	    Value1[p] = 0;
        Value2[p] = 0;
        Value3[p] = 0;
        Value4[p] = 0;
        Value5[p] = 0;
        Value6[p] = 0;
        Value7[p] = 0;
        Value8[p] = 0;
        Value9[p] = 0;
        Value10[p] = 0;
        Value11[p] = 0;
        Value12[p] = 0;
        Value13[p] = 0;
        Value14[p] = 0;
        Value15[p] = 0;
        Value16[p] = 0;
        Value17[p] = 0;
        Value18[p] = 0;
        Value19[p] = 0;
        Value20[p] = 0;
        Value21[p] = 0;
        Value22[p] = 0;
		
		
	return;
	end
      
   
            Range = HIGH-LOW;
         

        if  CLOSE > OPEN then
            Value1[p] = VOLUME*(Range/(2*Range + OPEN - CLOSE));
        elseif CLOSE < OPEN then
            Value1[p] = VOLUME*((Range + CLOSE-OPEN)/(2*Range + CLOSE-OPEN));
        end
        if CLOSE == OPEN then
            Value1[p] = 0.5*VOLUME;
        end
        Value2[p] =     VOLUME - Value1[p];
        Value3[p] =     Value1[p] + Value2[p];
        Value4[p] =     Value1[p] * Range;
        Value5[p] = (   Value1[p]-Value2[p])*Range
        Value6[p] =     Value2[p]*Range;
        Value7[p] = (   Value2[p]-Value1[p])*Range;
        if Range ~= 0 then
            Value8[p]  =    Value1[p]/Range;
            Value9[p]  = (  Value1[p]-Value2[p])/Range;
            Value10[p] =    Value2[p]/Range;
            Value11[p] = (  Value2[p]-Value1[p])/Range;
            Value12[p] =    Value3[p]/Range;
        end

        Value13[p] = Value3[p] + Value3[p-1];
        Value14[p] = (Value1[p]+Value1[p-1])*(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value15[p] = (Value1[p]+Value1[p-1] - Value2[p] - Value2[p-1]) * (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value16[p] = (Value2[p]+Value2[p-1])*(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value17[p] = (Value2[p]+Value2[p-1] - Value1[p] - Value1[p-1]) * (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        if mathex.max(source.high,p-2+1,p) ~= mathex.min(source.low,p-2+1,p) then
            Value18[p] = (Value1[p] + Value1[p-1])/(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        end
        Value19[p] = (Value1[p]+Value1[p-1] - Value2[p] - Value2[p-1]) / (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value20[p] = (Value2[p]+Value2[p-1]) / (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value21[p] = (Value2[p]+Value2[p-1] - Value1[p] - Value1[p-1]) / (mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
        Value22[p] = Value13[p]/(mathex.max(source.high,p-2+1,p) - mathex.min(source.low,p-2+1,p));
		
		
end


function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
    

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		    
        context:createPen (1, context.SOLID, 1, instance.parameters.LowVol_color)       
		context:createSolidBrush(2, instance.parameters.LowVol_color);
        
        context:createPen (3, context.SOLID, 1, instance.parameters.ClimaxUp_color)       
		context:createSolidBrush(4, instance.parameters.ClimaxUp_color);

		
        context:createPen (5, context.SOLID, 1, instance.parameters.ClimaxDn_color)       
		context:createSolidBrush(6, instance.parameters.ClimaxDn_color);	
        
        context:createPen (7, context.SOLID, 1, instance.parameters.DensityUp_color)       
		context:createSolidBrush(8, instance.parameters.DensityUp_color);	

        context:createPen (9, context.SOLID, 1, instance.parameters.DensityDn_color)       
		context:createSolidBrush(10, instance.parameters.DensityDn_color);
        
        context:createPen (11, context.SOLID, 1, instance.parameters.Neutral)       
		context:createSolidBrush(12, instance.parameters.Neutral);
 
			
            init = true;
        end
     
        
        local first = math.max(source:first()+Back, context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 
	
        local p;
		local HIGH, LOW,OPEN, VOLUME, CLOSE;
 
		
			 for p= first, last, 1 do	

           HIGH = source.high[p];
           LOW = source.low[p];
           OPEN = source.open[p];
           CLOSE = source.close[p];
           VOLUME = source.volume[p];

		
			   x0, x1, x2 = context:positionOfBar (p);
			    if p < Back then
			   C1=11; C2=12;	
			    else	  			
          							
				C1=11; C2=12;		 
								
								if not instance.parameters.TwoBars then
									--Con 1 or Con 11
									if (Value3[p] == mathex.min(Value3,p-Back+1,p)) then  -- Yellow -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
									C1=1;C2=2;
									end
									--Con 2 or Con 3 or Con 8 or Con 9 or Con 12 or Con 13 or Con 18 or con 19
									if (Value4[p] == mathex.max(Value4,p-Back+1,p) and CLOSE > OPEN) or
									   (Value5[p] == mathex.max(Value5,p-Back+1,p) and CLOSE > OPEN) or
									   (Value10[p] == mathex.min(Value10,p-Back+1,p) and CLOSE > OPEN) or 
									   (Value11[p] == mathex.min(Value11,p-Back+1,p) and CLOSE > OPEN) then  --RED -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
									C1=3;C2=4;
									end
									--Con 4 or Con 5 or Con 6 or Con 7 or Con 14 or Con 15 or Con 16 or con 17
									if (Value6[p] == mathex.max(Value6,p-Back+1,p) and CLOSE < OPEN) or
									   (Value7[p] == mathex.max(Value7,p-Back+1,p) and CLOSE < OPEN) or
									   (Value8[p] == mathex.min(Value8,p-Back+1,p) and CLOSE < OPEN) or 
									   (Value9[p] == mathex.min(Value9,p-Back+1,p) and CLOSE < OPEN) then -- White
									C1=5;C2=6;
									end
									-- Churn Con 10
									if Value12[p] == mathex.max(Value12,p-Back+1,p) then -- Green
									C1=7;C2=8;
									end
									--ClimaxChurn
									if (Value12[p] == mathex.max(Value12,p-Back+1,p) ) and 
									   (    (Value4[p] == mathex.max(Value4,p-Back+1,p) and CLOSE > OPEN) or
											(Value5[p] == mathex.max(Value5,p-Back+1,p) and CLOSE > OPEN) or
											(Value10[p] == mathex.min(Value10,p-Back+1,p) and CLOSE > OPEN) or 
											(Value11[p] == mathex.min(Value11,p-Back+1,p) and CLOSE > OPEN) or
											(Value6[p] == mathex.max(Value6,p-Back+1,p) and CLOSE < OPEN) or
											(Value7[p] == mathex.max(Value7,p-Back+1,p) and CLOSE < OPEN) or
											(Value8[p] == mathex.min(Value8,p-Back+1,p) and CLOSE < OPEN) or 
											(Value9[p] == mathex.min(Value9,p-Back+1,p) and CLOSE < OPEN) ) then
									C1=9;C2=10;
									end
								else
									--Con 1 or Con 11
									if (Value13[p] == mathex.min(Value13,p-Back+1,p)) then  -- Yellow -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
									C1=1;C2=2;
									end
									--Con 2 or Con 3 or Con 8 or Con 9 or Con 12 or Con 13 or Con 18 or con 19
									if ((Value14[p] == mathex.max(Value14,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
									   ((Value15[p] == mathex.max(Value15,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
									   ((Value20[p] == mathex.min(Value20,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or 
									   ((Value21[p] == mathex.min(Value21,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) then  --RED -- TwoBars or (Vlaue13[p] == mathex.min(Value13,p-Back+1,p)) then
									C1=3;C2=4;
									end
									--Con 4 or Con 5 or Con 6 or Con 7 or Con 14 or Con 15 or Con 16 or con 17
									if ((Value16[p] == mathex.max(Value16,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
									   ((Value17[p] == mathex.max(Value17,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
									   ((Value18[p] == mathex.min(Value18,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or 
									   ((Value19[p] == mathex.min(Value19,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) then -- White
									C1=5;C2=6;
									end
									-- Churn Con 10
									if Value22[p] == mathex.max(Value22,p-Back+1,p) then -- Green
									C1=7;C2=8;
									end
									--ClimaxChurn
									if (Value22[p] == mathex.max(Value22,p-Back+1,p) ) and 
									   (    ((Value14[p] == mathex.max(Value14,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
											((Value15[p] == mathex.max(Value15,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
											((Value20[p] == mathex.min(Value20,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or 
											((Value21[p] == mathex.min(Value21,p-Back+1,p)) and (CLOSE > OPEN) and (source.close[p-1] > source.open[p-1])) or
											((Value16[p] == mathex.max(Value16,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
											((Value17[p] == mathex.max(Value17,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or
											((Value18[p] == mathex.min(Value18,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) or 
											((Value19[p] == mathex.min(Value19,p-Back+1,p)) and (CLOSE < OPEN) and (source.close[p-1] < source.open[p-1])) ) then
									  C1=9;C2=10;
									end
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
				 
				
	
end




