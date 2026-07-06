-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27630
-- Id: 8076

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Complex");
    indicator:description(" Complex");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("usd", "USD", "", true);
	indicator.parameters:addBoolean("eur", "EUR", "", true);
	indicator.parameters:addBoolean("gbp", "GBP", "", true);
	indicator.parameters:addBoolean("chf", "CHF", "", true);
	indicator.parameters:addBoolean("aud", "AUD", "", true);
	indicator.parameters:addBoolean("cad", "CAD", "", true);
	indicator.parameters:addBoolean("jpy", "JPY", "", true);
	indicator.parameters:addBoolean("nzd", "NZD", "", true);
	
    indicator.parameters:addGroup("Caclulation");
    indicator.parameters:addInteger("Short", "Short Period", "Short Period", 8);
    indicator.parameters:addInteger("Long", "Long Period", "Long Period", 24);
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("USD_color", "Color of USD", "Color of USD", core.rgb(255, 0, 0));
    indicator.parameters:addColor("EUR_color", "Color of EUR", "Color of EUR", core.rgb(0, 255, 0));
    indicator.parameters:addColor("GBP_color", "Color of GBP", "Color of GBP", core.rgb(0, 0, 255));
    indicator.parameters:addColor("CHF_color", "Color of CHF", "Color of CHF", core.rgb(255, 255, 0));
    indicator.parameters:addColor("AUD_color", "Color of AUD", "Color of AUD", core.rgb(255, 0, 255));
    indicator.parameters:addColor("CAD_color", "Color of CAD", "Color of CAD", core.rgb(0, 255, 255));
    indicator.parameters:addColor("JPY_color", "Color of JPY", "Color of JPY", core.rgb(128, 128, 128));
    indicator.parameters:addColor("NZD_color", "Color of NZD", "Color of NZD", core.rgb(0, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Short;
local Long;
local Method, Price;
local first;
local source = nil;

-- Streams block
local Out={};
local List={"EUR/USD", "GBP/USD", "USD/CHF", "AUD/USD", "USD/CAD", "USD/JPY", "NZD/USD"};
local  SourceData={};
local loading={};
local FIRST;
local offset, weekoffset, host;
local Point={};
local Fast={};
local Slow={}; 
 local On={};
 local P={};
-- Routine
function Prepare(nameOnly)
    Short = instance.parameters.Short;
    Long = instance.parameters.Long;
    source = instance.source;
    first = source:first();
	On[8] = instance.parameters.usd;
	On[1] = instance.parameters.eur;
	On[2] = instance.parameters.gbp;
	On[3] = instance.parameters.chf;
	On[4] = instance.parameters.aud;
	On[5] = instance.parameters.cad;
	On[6] = instance.parameters.jpy;
	On[7] = instance.parameters.nzd;
	Method = instance.parameters.Method;
	Price = instance.parameters.Price;
	
	host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Short) .. ", " .. tostring(Long) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	
	local I1 = core.indicators:create(Method, source.close, Short);
	local I2 = core.indicators:create(Method, source.close, Long);
	
	
	
	
	FIRST= math.max(I1.DATA:first(), I2.DATA:first());
	
	local i;
	 for i = 1, 7, 1 do
	 Point[i]=    core.host:findTable("offers"):find("Instrument", List[i]).PointSize;	
	 SourceData[i] = core.host:execute("getSyncHistory", List[i], source:barSize(), source:isBid(), FIRST , 200+i , 100+i);
	 loading[i] = true;
	 
	 Fast[i] = core.indicators:create(Method, SourceData[i][Price], Short);
	 Slow[i] = core.indicators:create(Method, SourceData[i][Price], Long);
	 end
--USD, EUR, GBP, CHF, AUD, CAD, JPY, NZD;
    if (not (nameOnly)) then
	    if On[8] then
        Out[8] = instance:addStream("USD", core.Line, name .. ".USD", "USD", instance.parameters.USD_color, FIRST);
		Out[8]:setPrecision(math.max(2, instance.source:getPrecision()));
		end
		if On[1] then
        Out[1] = instance:addStream("EUR", core.Line, name .. ".EUR", "EUR", instance.parameters.EUR_color, FIRST);
		Out[1]:setPrecision(math.max(2, instance.source:getPrecision()));
		end
        if On[2] then
		Out[2] = instance:addStream("GBP", core.Line, name .. ".GBP", "GBP", instance.parameters.GBP_color, FIRST);
		Out[2]:setPrecision(math.max(2, instance.source:getPrecision()));
        end
		if On[3] then
		Out[3] = instance:addStream("CHF", core.Line, name .. ".CHF", "CHF", instance.parameters.CHF_color, FIRST);
		Out[3]:setPrecision(math.max(2, instance.source:getPrecision()));
        end
		if On[4] then
		Out[4] = instance:addStream("AUD", core.Line, name .. ".AUD", "AUD", instance.parameters.AUD_color, FIRST);
		Out[4]:setPrecision(math.max(2, instance.source:getPrecision()));
        end
		if On[5] then
		Out[5] = instance:addStream("CAD", core.Line, name .. ".CAD", "CAD", instance.parameters.CAD_color, FIRST);
		Out[5]:setPrecision(math.max(2, instance.source:getPrecision()));
        end
		if On[6] then
		Out[6] = instance:addStream("JPY", core.Line, name .. ".JPY", "JPY", instance.parameters.JPY_color, FIRST);
		Out[6]:setPrecision(math.max(2, instance.source:getPrecision()));
        end
		if On[7] then
		Out[7] = instance:addStream("NZD", core.Line, name .. ".NZD", "NZD", instance.parameters.NZD_color, FIRST);
		Out[7]:setPrecision(math.max(2, instance.source:getPrecision()));
		end
    end
end



function   Initialization(i,period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);

  
    if loading[i] or SourceData[i]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData[i], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < FIRST  then
	return;
	end
	
	
	if loading[1]
	or loading[2]
	or loading[3]
	or loading[4]
	or loading[5]
	or loading[6]
	or loading[7] 
	then
	return;
	end
		
	local i;
		for i = 1, 8 , 1 do
		   if On[i] then  
		  Out[i][period] = 0;
		  end
		 
		end
		
		
		
		for i = 1, 7, 1 do	
	   
				   Fast[i]:update(mode); 	
				   Slow[i]:update(mode); 
				   
					 P[i]= Initialization(i, period) 				    
    	end		  
		
		  
		  Calculate(  period);	
		         
		
end


function Calculate(  period)

	if not P[1]
	or not P[2]
	or not P[3]
	or not P[4]
	or not P[5]
	or not P[6]
	or not P[7]
	then
	 return;
	end

	if not Fast[1].DATA:hasData(P[1]) 
	or not Slow[1].DATA:hasData(P[1]) 	
	or not Fast[2].DATA:hasData(P[2]) 
	or not Slow[2].DATA:hasData(P[2]) 
	or not Fast[3].DATA:hasData(P[3]) 	
	or not Slow[3].DATA:hasData(P[3]) 	
	or not Fast[4].DATA:hasData(P[4]) 
	or not Slow[4].DATA:hasData(P[4]) 	
	or not Fast[5].DATA:hasData(P[5]) 
	or not Slow[5].DATA:hasData(P[5]) 
    or not Fast[6].DATA:hasData(P[6]) 
	or not Slow[6].DATA:hasData(P[6]) 	
	or not Fast[7].DATA:hasData(P[7]) 
	or not Slow[7].DATA:hasData(P[7]) 		
	then
	return;
	end
	
	
	 
	Algorithm( p, period);	
	 

	
end

function Algorithm (  p, period) 

--{   "EUR/USD", "GBP/USD", "USD/CHF", "AUD/USD", "USD/CAD", "USD/JPY", "NZD/USD"};
 --   USD, EUR,        GBP,       CHF,       AUD,       CAD,       JPY,        NZD;  
     
				if On[8] then
							 
							   	--EUR				   
								if On[1]   then
								   Out[8][period]  = Out[8][period] + Slow[1].DATA[P[1]] - Fast[1].DATA[P[1]];	
								end
								
								--GBP;
								if On[2]  then
								   Out[8][period]  =  Out[8][period] + Slow[2].DATA[P[2]] - Fast[2].DATA[P[2]];
								end   
								
								--CHF
								if On[3]   then
								   Out[8][period] =  Out[8][period] +Fast[3].DATA[P[3]] -Slow[3].DATA[P[3]];
								end
 								
								--AUD
								if On[4]   then
								   Out[8][period] = Out[8][period]  + Slow[4].DATA[P[4]] - Fast[4].DATA[P[4]];
								 end 
 								 --CAD
								if On[5]   then 
								   Out[8][period] =  Out[8][period] + Fast[5].DATA[P[5]] -Slow[5].DATA[P[5]];
								end   
								--JPY    
								if On[6]   then
								   Out[8][period] = Out[8][period]  +Fast[6].DATA[P[6]]/100 -Slow[6].DATA[P[6]]/100;
								end  
                                 --NZD								
								if On[7]   then 
								   Out[8][period] = Out[8][period] + Slow[7].DATA[P[7]] - Fast[7].DATA[P[7]];
								end				
								--USD
                                if On[8]   then 
								   Out[8][period] = Out[8][period] ;
								end
                                 								
				end
				
				--   USD, EUR,        GBP,       CHF,       AUD,       CAD,       JPY,        NZD;  
				
		       if On[1] then
							 
							   	--EUR
								 	   
								if On[1]   then
								   Out[1][period]  = Out[1][period] ;	
								end
								
								--GBP;
								--arrEUR[i] +EURUSD_Fast / GBPUSD_Fast - EURUSD_Slow /  GBPUSD_Slow;
								if On[2]  then
								   Out[1][period]  =  Out[1][period] + Fast[1].DATA[P[1]] /  Fast[2].DATA[P[2]] -   Slow[1].DATA[P[1]] /  Slow[2].DATA[P[2]];
								end   
								
								--CHF
								-- arrEUR[i] += EURUSD_Fast*USDCHF_Fast - EURUSD_Slow*USDCHF_Slow;
								if On[3]   then
								   Out[1][period] =  Out[1][period] +  Fast[1].DATA[P[1]] * Fast[3].DATA[P[3]] - Slow[1].DATA[P[1]] * Slow[3].DATA[P[3]] ;
								end
 								
								--AUD
								---arrEUR[i] += EURUSD_Fast / AUDUSD_Fast - EURUSD_Slow / AUDUSD_Slow;
								if On[4]   then
								   Out[1][period] = Out[1][period] +  Fast[1].DATA[P[1]] / Fast[4].DATA[P[4]] - Slow[1].DATA[P[1]] / Slow[4].DATA[P[4]];
								 end 
 								 --CAD
								 -- arrEUR[i] += EURUSD_Fast*USDCAD_Fast - EURUSD_Slow*USDCAD_Slow;
								if On[5]   then 
								   Out[1][period] =  Out[1][period] +Fast[1].DATA[P[1]] *Fast[5].DATA[P[5]] - Slow[1].DATA[P[1]] *Slow[5].DATA[P[5]];
								end   
								--JPY    
								--  arrEUR[i] += EURUSD_Fast*USDJPY_Fast -  EURUSD_Slow*USDJPY_Slow; 
								if On[6]   then
								   Out[1][period] = Out[1][period]+Fast[1].DATA[P[1]] *Fast[6].DATA[P[6]]/100 - Slow[1].DATA[P[1]] *Slow[6].DATA[P[6]]/100;
								end  
                                 --NZD		
								 -- arrEUR[i] += EURUSD_Fast / NZDUSD_Fast - EURUSD_Slow /  NZDUSD_Slow;
								if On[7]   then 
								   Out[1][period] = Out[1][period] +  Fast[1].DATA[P[1]] /  Fast[7].DATA[P[7]] -   Slow[1].DATA[P[1]] /  Slow[7].DATA[P[7]];
								end				
								--USD   EURUSD_Fast - EURUSD_Slow;	
                                if On[8]   then 
								   Out[1][period] = Out[1][period] + Fast[1].DATA[P[1]] - Slow[1].DATA[P[1]];
								end
                                 								
				end
				--           1,          2,         3,         4,        5,         6,           7
				--   USD, EUR,        GBP,       CHF,       AUD,       CAD,       JPY,        NZD; 
                --   Fast[1].DATA[P[1]] /  Fast[2].DATA[P[2]] -   Slow[1].DATA[P[1]] /  Slow[2].DATA[P[2]];	
				 --   Slow[1].DATA[P[1]] /  Slow[2].DATA[P[2]] -   Fast[1].DATA[P[1]] /  Fast[2].DATA[P[2]];
                --   Fast[1].DATA[P[1]] * Fast[3].DATA[P[3]] - Slow[1].DATA[P[1]] * Slow[3].DATA[P[3];	
                -- Fast[1].DATA[P[1]] - Slow[1].DATA[P[1]]		
                -- Slow[1].DATA[P[1]] - Fast[1].DATA[P[1]]					
				
				 if On[2] then
							 
							   	--EUR
							    -- arrGBP[i] += EURUSD_Slow / GBPUSD_Slow - EURUSD_Fast /  GBPUSD_Fast;
								if On[1]   then
								   Out[2][period]  = Out[2][period] + Slow[1].DATA[P[1]] /  Slow[2].DATA[P[2]] -   Fast[1].DATA[P[1]] /  Fast[2].DATA[P[2]]; 	
								end
								
								--GBP;
								-- 
								if On[2]  then
								   Out[2][period]  =  Out[2][period];
								end   
								
								--CHF
								--arrGBP[i] += GBPUSD_Fast*USDCHF_Fast - GBPUSD_Slow*USDCHF_Slow; 
								if On[3]   then
								   Out[2][period] =  Out[2][period]  + Fast[2].DATA[P[2]] * Fast[3].DATA[P[3]] - Slow[2].DATA[P[2]] * Slow[3].DATA[P[3]] ;
								end
 								
								--AUD
								--  arrGBP[i] += GBPUSD_Fast / AUDUSD_Fast - GBPUSD_Slow /   AUDUSD_Slow; 
								if On[4]   then
								   Out[2][period] = Out[2][period] + Fast[2].DATA[P[2]] /  Fast[4].DATA[P[4]] -   Slow[2].DATA[P[2]] /  Slow[4].DATA[P[4]];
								 end 
 								 --CAD
								 -- arrGBP[i] += GBPUSD_Fast*USDCAD_Fast -GBPUSD_Slow*USDCAD_Slow;
								if On[5]   then 
								   Out[2][period] =  Out[2][period] +  Fast[2].DATA[P[2]] * Fast[5].DATA[P[5]] - Slow[2].DATA[P[2]] * Slow[5].DATA[P[5]];	
								end   
								--JPY    
								--arrGBP[i] += GBPUSD_Fast*USDJPY_Fast - GBPUSD_Slow*USDJPY_Slow; 
								if On[6]   then
								   Out[2][period] = Out[2][period] +  Fast[2].DATA[P[2]] * Fast[6].DATA[P[6]]/100 - Slow[2].DATA[P[2]] * Slow[6].DATA[P[6]]/100;
								end  
                                 --NZD		
								 --  arrGBP[i] += GBPUSD_Fast / NZDUSD_Fast - GBPUSD_Slow /   NZDUSD_Slow;
								if On[7]   then 
								   Out[2][period] = Out[2][period]+ Fast[2].DATA[P[2]] /  Fast[7].DATA[P[7]] -   Slow[2].DATA[P[2]] /  Slow[7].DATA[P[7]];	
								end				
								--USD  
								 --arrGBP[i] += GBPUSD_Fast - GBPUSD_Slow;
                                if On[8]   then 
								   Out[2][period] = Out[2][period] + Fast[2].DATA[P[2]] - Slow[2].DATA[P[2]];	
								end
                                 								
				end
				
				
				--           1,          2,         3,         4,        5,         6,           7
				--   USD, EUR,        GBP,       CHF,       AUD,       CAD,       JPY,        NZD; 
                --   Fast[1].DATA[P[1]] /  Fast[2].DATA[P[2]] -   Slow[1].DATA[P[1]] /  Slow[2].DATA[P[2]];	
				 --   Slow[1].DATA[P[1]] /  Slow[2].DATA[P[2]] -   Fast[1].DATA[P[1]] /  Fast[2].DATA[P[2]];
                --   Fast[1].DATA[P[1]] * Fast[3].DATA[P[3]] - Slow[1].DATA[P[1]] * Slow[3].DATA[P[3]];	
				--   Slow[1].DATA[P[1]] * Slow[3].DATA[P[3]] - Fast[1].DATA[P[1]] * Fast[3].DATA[P[3]];	
                -- Fast[1].DATA[P[1]] - Slow[1].DATA[P[1]]		
                -- Slow[1].DATA[P[1]] - Fast[1].DATA[P[1]]			
				
				if On[3] then							 
							   	--EUR
							 -- arrCHF[i] += EURUSD_Slow*USDCHF_Slow -EURUSD_Fast*USDCHF_Fast;
								if On[1]   then
								   Out[3][period]  = Out[3][period] + Slow[1].DATA[P[1]] * Slow[3].DATA[P[3]] - Fast[1].DATA[P[1]] * Fast[3].DATA[P[3]];	
								end								
								--GBP;
								-- arrCHF[i] += GBPUSD_Slow*USDCHF_Slow -GBPUSD_Fast*USDCHF_Fast; 
								if On[2]  then
								   Out[3][period]  =  Out[3][period] + Slow[2].DATA[P[2]] * Slow[3].DATA[P[3]] - Fast[2].DATA[P[2]] * Fast[3].DATA[P[3]];	
								end   								
								--CHF
								 
								if On[3]   then
								   Out[3][period] =  Out[3][period] ;
								end 								
								--AUD
								 --arrCHF[i] += AUDUSD_Slow*USDCHF_Slow -  AUDUSD_Fast*USDCHF_Fast;
								if On[4]   then
								   Out[3][period] = Out[3][period] + Slow[4].DATA[P[4]] * Slow[3].DATA[P[3]] - Fast[4].DATA[P[4]] * Fast[3].DATA[P[3]];	
								 end 
 								 --CAD
								-- arrCHF[i] += USDCHF_Slow / USDCAD_Slow - USDCHF_Fast / USDCAD_Fast;
								if On[5]   then 
								   Out[3][period] =  Out[3][period] + Slow[3].DATA[P[3]] /  Slow[5].DATA[P[5]] -   Fast[3].DATA[P[3]] /  Fast[5].DATA[P[5]];
								end   
								--JPY    
								--  arrCHF[i] += USDJPY_Fast / USDCHF_Fast - USDJPY_Slow / USDCHF_Slow;
								if On[6]   then
								   Out[3][period] = Out[3][period] + (Fast[6].DATA[P[6]]/100) /  Fast[3].DATA[P[3]] -   (Slow[6].DATA[P[6]]/100) /  Slow[3].DATA[P[3]];	
								end  
                                 --NZD		
								  --arrCHF[i] += NZDUSD_Slow*USDCHF_Slow -  NZDUSD_Fast*USDCHF_Fast;
								if On[7]   then 
								   Out[3][period] = Out[3][period]+  Slow[7].DATA[P[7]] * Slow[3].DATA[P[3]] - Fast[7].DATA[P[7]] * Fast[3].DATA[P[3]];	
								end				
								--USD  
								 -- arrCHF[i] += USDCHF_Slow - USDCHF_Fast;  
                                if On[8]   then 
								   Out[3][period] =  Out[3][period] + Slow[3].DATA[P[3]] - Fast[3].DATA[P[3]]	 ; 	
								end
                                 								
				end
				
				--           1,          2,         3,         4,        5,         6,           7
				--   USD, EUR,        GBP,       CHF,       AUD,       CAD,       JPY,        NZD; 
                --   Fast[1].DATA[P[1]] /  Fast[2].DATA[P[2]] -   Slow[1].DATA[P[1]] /  Slow[2].DATA[P[2]];	
				 --   Slow[1].DATA[P[1]] /  Slow[2].DATA[P[2]] -   Fast[1].DATA[P[1]] /  Fast[2].DATA[P[2]];
                --   Fast[1].DATA[P[1]] * Fast[3].DATA[P[3]] - Slow[1].DATA[P[1]] * Slow[3].DATA[P[3]];	
				--   Slow[1].DATA[P[1]] * Slow[3].DATA[P[3]] - Fast[1].DATA[P[1]] * Fast[3].DATA[P[3]];	
                -- Fast[1].DATA[P[1]] - Slow[1].DATA[P[1]]		
                -- Slow[1].DATA[P[1]] - Fast[1].DATA[P[1]]		
								
				if On[4] then
							 
							   	--EUR
							  -- arrAUD[i] += EURUSD_Slow / AUDUSD_Slow - EURUSD_Fast / AUDUSD_Fast;
								if On[1]   then
								   Out[4][period]  = Out[4][period]  +  Slow[1].DATA[P[1]] /  Slow[4].DATA[P[4]] -   Fast[1].DATA[P[1]] /  Fast[4].DATA[P[4]]; 	
								end
								
								--GBP;
								--  arrAUD[i] += GBPUSD_Slow / AUDUSD_Slow - GBPUSD_Fast / AUDUSD_Fast;
								if On[2]  then
								   Out[4][period]  =  Out[4][period] +  Slow[2].DATA[P[2]] /  Slow[4].DATA[P[4]] -   Fast[2].DATA[P[2]] /  Fast[4].DATA[P[4]]; 	
								end   
								
								--CHF
								--  arrAUD[i] += AUDUSD_Fast*USDCHF_Fast -AUDUSD_Slow*USDCHF_Slow;
								if On[3]   then
								   Out[4][period] =  Out[4][period] +Fast[4].DATA[P[4]] * Fast[3].DATA[P[3]] - Slow[4].DATA[P[4]] * Slow[3].DATA[P[3]];	
								end
 								
								--AUD
								 
								if On[4]   then
								   Out[4][period] = Out[4][period] ;
								 end 
 								 --CAD
								 --arrAUD[i] += AUDUSD_Fast*USDCAD_Fast - AUDUSD_Slow*USDCAD_Slow;
								if On[5]   then 
								   Out[4][period] =  Out[4][period]+Fast[4].DATA[P[4]] * Fast[5].DATA[P[5]] - Slow[4].DATA[P[4]] * Slow[5].DATA[P[5]];
								end   
								--JPY    
								 -- arrAUD[i] += AUDUSD_Fast*USDJPY_Fast -AUDUSD_Slow*USDJPY_Slow;
								if On[6]   then
								   Out[4][period] = Out[4][period]+Fast[4].DATA[P[4]] * Fast[6].DATA[P[6]]/100 - Slow[4].DATA[P[4]] * Slow[6].DATA[P[6]]/100;
								end  
                                 --NZD		
								-- arrAUD[i] += AUDUSD_Fast / NZDUSD_Fast - AUDUSD_Slow /NZDUSD_Slow;
								if On[7]   then 
								   Out[4][period] = Out[4][period] + Fast[4].DATA[P[4]] /  Fast[7].DATA[P[7]] -   Slow[4].DATA[P[4]] /  Slow[7].DATA[P[7]];	
								end				
								--USD  
								 -- arrAUD[i] += AUDUSD_Fast - AUDUSD_Slow; 
                                if On[8]   then 
								   Out[4][period] = Out[4][period] + Fast[4].DATA[P[4]] - Slow[4].DATA[P[4]];	
								end
                                 								
				end
				
				--           1,          2,         3,         4,        5,         6,           7
				--   USD, EUR,        GBP,       CHF,       AUD,       CAD,       JPY,        NZD; 
                --   Fast[1].DATA[P[1]] /  Fast[2].DATA[P[2]] -   Slow[1].DATA[P[1]] /  Slow[2].DATA[P[2]];	
				 --   Slow[1].DATA[P[1]] /  Slow[2].DATA[P[2]] -   Fast[1].DATA[P[1]] /  Fast[2].DATA[P[2]];
                --   Fast[1].DATA[P[1]] * Fast[3].DATA[P[3]] - Slow[1].DATA[P[1]] * Slow[3].DATA[P[3]];	
				--   Slow[1].DATA[P[1]] * Slow[3].DATA[P[3]] - Fast[1].DATA[P[1]] * Fast[3].DATA[P[3]];	
                -- Fast[1].DATA[P[1]] - Slow[1].DATA[P[1]]		
                -- Slow[1].DATA[P[1]] - Fast[1].DATA[P[1]]
				if On[5] then							 
							   	--EUR
							   -- arrCAD[i] += EURUSD_Slow*USDCAD_Slow -EURUSD_Fast*USDCAD_Fast;
								if On[1]   then
								   Out[5][period]  = Out[5][period] +Slow[1].DATA[P[1]] * Slow[5].DATA[P[5]] - Fast[1].DATA[P[1]] * Fast[5].DATA[P[5]];  	
								end								
								--GBP;
								 -- arrCAD[i] += GBPUSD_Slow*USDCAD_Slow -GBPUSD_Fast*USDCAD_Fast;
								if On[2]  then
								   Out[5][period]  =  Out[5][period]   +Slow[2].DATA[P[2]] * Slow[5].DATA[P[5]] - Fast[2].DATA[P[2]] * Fast[5].DATA[P[5]];  	
								end   								
								--CHF
								-- arrCAD[i] += USDCHF_Fast / USDCAD_Fast -USDCHF_Slow / USDCAD_Slow;
								if On[3]   then
								   Out[5][period] =  Out[5][period] + Fast[3].DATA[P[3]] /  Fast[5].DATA[P[5]] -   Slow[3].DATA[P[3]] /  Slow[5].DATA[P[5]];
								end 								
								--AUD
								 --arrCAD[i] += AUDUSD_Slow*USDCAD_Slow -AUDUSD_Fast*USDCAD_Fast;
								if On[4]   then
								   Out[5][period] = Out[5][period]  +Slow[4].DATA[P[4]] * Slow[5].DATA[P[5]] - Fast[4].DATA[P[4]] * Fast[5].DATA[P[5]];
								 end 
 								 --CAD
								 
								if On[5]   then 
								   Out[5][period] =  Out[5][period];
								end   
								--JPY    
								 --arrCAD[i] += USDJPY_Fast / USDCAD_Fast -USDJPY_Slow / USDCAD_Slow;
								if On[6]   then
								   Out[5][period] = Out[5][period] +(Fast[6].DATA[P[6]]/100) /  Fast[5].DATA[P[5]] -   (Slow[6].DATA[P[6]]/100) /  Slow[5].DATA[P[5]];	
								end  
                                 --NZD		
								 --arrCAD[i] += NZDUSD_Slow*USDCAD_Slow - NZDUSD_Fast*USDCAD_Fast;
								if On[7]   then 
								   Out[5][period] = Out[5][period]+ Slow[7].DATA[P[7]] * Slow[5].DATA[P[5]] - Fast[7].DATA[P[7]] * Fast[5].DATA[P[5]];	
								end				
								--USD  
								-- arrCAD[i] += USDCAD_Slow - USDCAD_Fast; 
                                if On[8]   then 
								   Out[5][period] = Out[5][period]  + Slow[5].DATA[P[5]] - Fast[5].DATA[P[5]];	
								end
                                 								
				end
				
				--           1,          2,         3,         4,        5,         6,           7
				--   USD, EUR,        GBP,       CHF,       AUD,       CAD,       JPY,        NZD; 
                --   Fast[1].DATA[P[1]] /  Fast[2].DATA[P[2]] -   Slow[1].DATA[P[1]] /  Slow[2].DATA[P[2]];	
				 --   Slow[1].DATA[P[1]] /  Slow[2].DATA[P[2]] -   Fast[1].DATA[P[1]] /  Fast[2].DATA[P[2]];
                --   Fast[1].DATA[P[1]] * Fast[3].DATA[P[3]] - Slow[1].DATA[P[1]] * Slow[3].DATA[P[3]];	
				--   Slow[1].DATA[P[1]] * Slow[3].DATA[P[3]] - Fast[1].DATA[P[1]] * Fast[3].DATA[P[3]];	
                -- Fast[1].DATA[P[1]] - Slow[1].DATA[P[1]]		
                -- Slow[1].DATA[P[1]] - Fast[1].DATA[P[1]]				
				if On[6] then							 
							   	--EUR
							 --  arrJPY[i] += EURUSD_Slow*USDJPY_Slow - EURUSD_Fast*USDJPY_Fast;
								if On[1]   then
								   Out[6][period]  = Out[6][period]  + Slow[1].DATA[P[1]] * Slow[6].DATA[P[6]]/100 - Fast[1].DATA[P[1]] * Fast[6].DATA[P[6]]/100; 	
								end								
								--GBP;
								-- arrJPY[i] += GBPUSD_Slow*USDJPY_Slow -GBPUSD_Fast*USDJPY_Fast;
								if On[2]  then
								   Out[6][period]  =  Out[6][period] + Slow[2].DATA[P[2]] * Slow[6].DATA[P[6]]/100 - Fast[2].DATA[P[2]] * Fast[6].DATA[P[6]]/100; 	
								end								
								--CHF
								 -- arrJPY[i] += USDJPY_Slow / USDCHF_Slow -USDJPY_Fast / USDCHF_Fast;
								if On[3]   then
								   Out[6][period] =  Out[6][period] +(Slow[6].DATA[P[6]]/100) /  Slow[3].DATA[P[3]] -   (Fast[6].DATA[P[6]]/100) /  Fast[3].DATA[P[3]]; 
								end 								
								--AUD
								-- arrJPY[i] += AUDUSD_Slow*USDJPY_Slow - AUDUSD_Fast*USDJPY_Fast;
								if On[4]   then
								   Out[6][period] = Out[6][period] + Slow[4].DATA[P[4]]/100 * Slow[6].DATA[P[6]] - Fast[4].DATA[P[4]] * Fast[6].DATA[P[6]]/100;	
								 end 
 								 --CAD
								-- arrJPY[i] += USDJPY_Slow / USDCAD_Slow - USDJPY_Fast / USDCAD_Fast;
								if On[5]   then 
								   Out[6][period] =  Out[6][period]+ (Slow[6].DATA[P[6]]/100) /  Slow[5].DATA[P[5]] -   (Fast[6].DATA[P[6]]/100) /  Fast[5].DATA[P[5]];
								end   
								--JPY    
								 
								if On[6]   then
								   Out[6][period] = Out[6][period];
								end  
                                 --NZD		
								-- arrJPY[i] += NZDUSD_Slow*USDJPY_Slow -NZDUSD_Fast*USDJPY_Fast;
								if On[7]   then 
								   Out[6][period] = Out[6][period] + Slow[7].DATA[P[7]] * Slow[6].DATA[P[6]]/100 - Fast[7].DATA[P[7]] * Fast[6].DATA[P[6]]/100;	 
								end				
								--USD  
								 -- arrJPY[i] += USDJPY_Slow - USDJPY_Fast;
                                if On[8]   then 
								   Out[6][period] = Out[6][period]  +  Slow[6].DATA[P[6]]/100 - Fast[6].DATA[P[6]]/100	;	
								end
                                 								
				end
				
				--           1,          2,         3,         4,        5,         6,           7
				--   USD, EUR,        GBP,       CHF,       AUD,       CAD,       JPY,        NZD; 
                --   Fast[1].DATA[P[1]] /  Fast[2].DATA[P[2]] -   Slow[1].DATA[P[1]] /  Slow[2].DATA[P[2]];	
				 --   Slow[1].DATA[P[1]] /  Slow[2].DATA[P[2]] -   Fast[1].DATA[P[1]] /  Fast[2].DATA[P[2]];
                --   Fast[1].DATA[P[1]] * Fast[3].DATA[P[3]] - Slow[1].DATA[P[1]] * Slow[3].DATA[P[3]];	
				--   Slow[1].DATA[P[1]] * Slow[3].DATA[P[3]] - Fast[1].DATA[P[1]] * Fast[3].DATA[P[3]];	
                -- Fast[1].DATA[P[1]] - Slow[1].DATA[P[1]]		
                -- Slow[1].DATA[P[1]] - Fast[1].DATA[P[1]]					
				if On[7] then							 
							   	--EUR
							    -- arrNZD[i] += EURUSD_Slow / NZDUSD_Slow - EURUSD_Fast /NZDUSD_Fast;
								if On[1]   then
								   Out[7][period]  = Out[7][period]  + Slow[1].DATA[P[1]] /  Slow[7].DATA[P[7]] -   Fast[1].DATA[P[1]] /  Fast[7].DATA[P[7]];	
								end								
								--GBP;
								 -- arrNZD[i] += GBPUSD_Slow / NZDUSD_Slow - GBPUSD_Fast /NZDUSD_Fast;
								if On[2]  then
								   Out[7][period]  =  Out[7][period]  + Slow[2].DATA[P[2]] /  Slow[7].DATA[P[7]] -   Fast[2].DATA[P[2]] /  Fast[7].DATA[P[7]];	
								end  
								--CHF
								 -- arrNZD[i] += NZDUSD_Fast*USDCHF_Fast -NZDUSD_Slow*USDCHF_Slow;
								if On[3]   then
								   Out[7][period] =  Out[7][period] + Fast[7].DATA[P[7]] * Fast[3].DATA[P[3]] - Slow[7].DATA[P[7]] * Slow[3].DATA[P[3]];	
								end
								--AUD
								 --arrNZD[i] += AUDUSD_Slow / NZDUSD_Slow - AUDUSD_Fast /NZDUSD_Fast;
								if On[4]   then
								   Out[7][period] = Out[7][period] + Slow[4].DATA[P[4]] /  Slow[7].DATA[P[7]] -   Fast[4].DATA[P[4]] /  Fast[7].DATA[P[7]];
								 end 
 								 --CAD
								 -- arrNZD[i] += NZDUSD_Fast*USDCAD_Fast -NZDUSD_Slow*USDCAD_Slow;
								if On[5]   then 
								   Out[7][period] =  Out[7][period] +Fast[7].DATA[P[7]] * Fast[5].DATA[P[5]] - Slow[7].DATA[P[7]] * Slow[5].DATA[P[5]];	
								end   
								--JPY    
								--  arrNZD[i] += NZDUSD_Fast*USDJPY_Fast -NZDUSD_Slow*USDJPY_Slow;
								if On[6]   then
								   Out[7][period] = Out[7][period]+ Fast[7].DATA[P[7]] /100* Fast[6].DATA[P[6]] - Slow[7].DATA[P[7]] * Slow[6].DATA[P[6]]/100;	
								end  
								
                                 --NZD								 
								if On[7]   then 
								   Out[7][period] = Out[7][period];
								end				
								--USD  
								-- arrNZD[i] += NZDUSD_Fast - NZDUSD_Slow;
                                if On[8]   then 
								   Out[7][period] = Out[7][period] +Fast[7].DATA[P[7]] - Slow[7].DATA[P[7]]	;	
								end
                                 								
				end

end




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

   local i;
   
    local ItIs= false;
    for i = 1, 7, 1 do
		 
			  if cookie == 100+i then
			  loading[i] = true;
			  ItIs=true;
		      elseif  cookie == 200+i then
			  loading[i] = false;           
			  
			  
			  end
		  
	end    
   
    if not ItIs then
	core.host:execute("setStatus", "Loaded"); 
    instance:updateFrom(0);
	else
	core.host:execute("setStatus", "Loading");
	end
        
     return core.ASYNC_REDRAW;
end

