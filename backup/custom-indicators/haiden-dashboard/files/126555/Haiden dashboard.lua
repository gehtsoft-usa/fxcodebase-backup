-- Id: 25105
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=68510

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Haiden dashboard");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
	
	
	indicator.parameters:addGroup("TDI Calculation");  

    indicator.parameters:addInteger("RSI_N", "RSI Periods", "Recommended values are in 8-25 range", 13, 2, 1000);
    indicator.parameters:addInteger("VB_N", "Volatility Band", "Number of periods to find volatility band. Recommended value is 20-40", 34, 2, 1000);
    indicator.parameters:addDouble("VB_W", "Volatility Band Width", "", 1.6185, 0, 100);

    indicator.parameters:addInteger("RSI_P_N", "RSI Price Line Periods", "", 2, 1, 1000);
    indicator.parameters:addString("RSI_P_M", "RSI Price Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M", "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("RSI_P_M", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "KAMA(Kaufman)", "", "KAMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("RSI_P_M", "VIDYA", "VIDYA" , "VIDYA");
 


    indicator.parameters:addInteger("TS_N", "Trade Signal Line Periods", "", 7, 1, 1000);
    indicator.parameters:addString("TS_M", "Trade Signal Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M", "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("TS_M", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("TS_M", "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("TS_M", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("TS_M", "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("TS_M", "KAMA(Kaufman)", "", "KAMA");
	 indicator.parameters:addStringAlternative("TS_M", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("TS_M", "VIDYA", "VIDYA" , "VIDYA");
	
	
	indicator.parameters:addGroup("1. Price /MA  Calculation");  
	indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");

   indicator.parameters:addInteger("Period1", "MA Period", "Period" , 7); 
	indicator.parameters:addString("Method1", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");	

	
	indicator.parameters:addGroup("1. MA Slope Calculation");  
	
	indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addInteger("Period2", "MA Period", "Period" , 7); 
	indicator.parameters:addString("Method2", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("2. Price /MA  Calculation");  
	indicator.parameters:addString("Price3", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price3", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price3", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price3", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price3","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price3", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price3", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price3", "WEIGHTED", "", "weighted");

   indicator.parameters:addInteger("Period3", "MA Period", "Period" , 26); 
	indicator.parameters:addString("Method3", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");	

	
	indicator.parameters:addGroup("2. MA Slope Calculation");  
	
	indicator.parameters:addString("Price4", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price4", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price4", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price4", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price4","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price4", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price4", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price4", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addInteger("Period4", "MA Period", "Period" , 26); 
	indicator.parameters:addString("Method4", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method4", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method4", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method4", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method4", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method4", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method4", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method4", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addGroup("MACD Calculation");	
    indicator.parameters:addInteger("FMA", "Fast EMA periods", "", 12, 1, 5000);
    indicator.parameters:addInteger("SMA", "Slow EMA Periods", "", 24, 1, 5000);
    indicator.parameters:addInteger("SigMA", "Signal EMA periods", "", 9, 1, 5000);
	
	
	indicator.parameters:addGroup("Stochastic Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "", 25, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 25, 2, 1000);
    indicator.parameters:addInteger("D", "The number of periods for %D.", "", 25, 2, 1000);

    indicator.parameters:addString("KS", "Smoothing type for %K", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("KS", "EMA","", "EMA");
    indicator.parameters:addStringAlternative("KS", "FS","", "FS");
    
    indicator.parameters:addString("DS", "Smoothing type for %D", "", "MVA");
    indicator.parameters:addStringAlternative("DS", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DS", "EMA", "", "EMA");
	
   
	
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
 

local Number=7;
local BC, SC,NC ;
local Signal={};
local Label={"TDI", "1. Price/MA", "1. MA Slope", "2. Price/MA", "2. MA Slope", "Zero Lag MACD Slope","Stochastic"};
local VSpace, HSpace, Size, Color;
local MA1, MA2, Period1, Period2, Method2, Method1, Price1, Price2;
local MA3, MA4, Period3, Period4, Method3, Method4, Price3, Price4;
local TDI, RSI_N, VB_N, VB_W, RSI_P_N, RSI_P_M, TS_N, TS_M;
local Stochastic, K, SD, D, KS, DS;
local MACD, FMA, SMA, SigMA;
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
	
	
	assert(core.indicators:findIndicator("TRADERSDYNAMICINDEX") ~= nil, "Please, download and install TRADERSDYNAMICINDEX.LUA indicator");
	assert(core.indicators:findIndicator("ZEROLAGMACD") ~= nil, "Please, download and install ZEROLAGMACD.LUA indicator");
 
 
    RSI_N=instance.parameters.RSI_N;
	VB_N=instance.parameters.VB_N;
	VB_W=instance.parameters.VB_W;
	RSI_P_N=instance.parameters.RSI_P_N;
	RSI_P_M=instance.parameters.RSI_P_M;
	TS_N=instance.parameters.TS_N;
	TS_M=instance.parameters.TS_M;
	
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Method2=instance.parameters.Method2;
	Method1=instance.parameters.Method1;
	Price1=instance.parameters.Price1;
	Price2=instance.parameters.Price2;
	
	Period3=instance.parameters.Period3;
	Period4=instance.parameters.Period4;
	Method3=instance.parameters.Method3;
	Method4=instance.parameters.Method4;
	Price3=instance.parameters.Price3;
	Price4=instance.parameters.Price4;
	
	FMA=instance.parameters.FMA;
	SMA=instance.parameters.SMA;
	SigMA=instance.parameters.SigMA;
	
	K=instance.parameters.K;
	SD=instance.parameters.SD;
	D=instance.parameters.D;
	KS=instance.parameters.KS;
	DS=instance.parameters.DS;
	
	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;
	
	
	for i= 1, Number, 1 do
	Signal[i] = instance:addInternalStream(0, 0);
	end
	
    source = instance.source;
   

	TDI = core.indicators:create("TRADERSDYNAMICINDEX", source.close,RSI_N, VB_N, VB_W, RSI_P_N, RSI_P_M, TS_N, TS_M);
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	MA1 = core.indicators:create(Method1, source[Price1],Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
    MA2 = core.indicators:create(Method2, source[Price2],Period2);
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	MA3 = core.indicators:create(Method3, source[Price3],Period3);
    assert(core.indicators:findIndicator(Method4) ~= nil, Method4 .. " indicator must be installed");
    MA4 = core.indicators:create(Method4, source[Price4],Period4);
	
	MACD = core.indicators:create("ZEROLAGMACD", source.close,FMA, SMA, SigMA);
	Stochastic = core.indicators:create("STOCHASTIC", source , K, SD, D, KS, DS);
	
    first=math.max(TDI.DATA:first(), MA1.DATA:first(), MA2.DATA:first() , MA3.DATA:first(), MA4.DATA:first(), MACD.HISTOGRAM:first(), Stochastic.D:first());
	
	 
    instance:ownerDrawn(true);
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)



    TDI:update(mode);
	MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);
	MA4:update(mode);
	MACD:update(mode);
	Stochastic:update(mode);
	
    if period < first then
	return;
	end
	
    
	for i= 1, Number, 1 do
	
	
		 
		    if i== 1 then
				if TDI.RSI_P[period]> TDI.MB[period] then
				Signal[i][period]=1;
				elseif TDI.RSI_P[period]< TDI.MB[period] then
				Signal[i][period]=-1;
				else 
				Signal[i][period]=0;
				end
		    end	
			
			if i== 2 then
				if source.close[period]> MA1.DATA[period] then
				Signal[i][period]=1;
				elseif source.close[period]< MA1.DATA[period] then
				Signal[i][period]=-1;
				else 
				Signal[i][period]=0;
				end
		    end	
			
			
			
			
			
			if i== 3 then
				if MA2.DATA[period]> MA2.DATA[period-1] then
				Signal[i][period]=1;
				elseif MA2.DATA[period]< MA2.DATA[period-1] then
				Signal[i][period]=-1;
				else 
				Signal[i][period]=0;
				end
		    end	
			
			
			if i== 4 then
				if source.close[period]> MA3.DATA[period] then
				Signal[i][period]=1;
				elseif source.close[period]< MA3.DATA[period] then
				Signal[i][period]=-1;
				else 
				Signal[i][period]=0;
				end
		    end	
			
			
			
			
			
			if i== 5 then
				if MA4.DATA[period]> MA4.DATA[period-1] then
				Signal[i][period]=1;
				elseif MA4.DATA[period]< MA4.DATA[period-1] then
				Signal[i][period]=-1;
				else 
				Signal[i][period]=0;
				end
		    end	
			
			
			
			if i== 6 then
				if MACD.MACD[period]> MACD.MACD[period-1] then
				Signal[i][period]=1;
				elseif MACD.MACD[period]< MACD.MACD[period-1] then
				Signal[i][period]=-1;
				else 
				Signal[i][period]=0;
				end
		    end	
			
			 if i== 7 then
				if Stochastic.K[period]> Stochastic.D[period] then
				Signal[i][period]=1;
				elseif Stochastic.K[period]< Stochastic.D[period] then
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
 