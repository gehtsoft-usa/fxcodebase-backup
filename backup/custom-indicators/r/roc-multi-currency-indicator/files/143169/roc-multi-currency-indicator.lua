-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71411

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
    indicator:name("roc-multi-currency-indicator");
    indicator:description("roc-multi-currency-indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);


	
	indicator.parameters:addGroup("Calculation");   indicator.parameters:addInteger("Period", "Period", "Period", 24);
 
 
	
	local i;
 
	local Indexes={"EUR","USD","JPY","GBP","CHF","CAD","AUD","NZD"};
	
 
	 indicator.parameters:addGroup("Indexes Style");
	 for i = 1 , 8, 1 do

     if i== 1 then
	 AddIndexes(i, Indexes[i],core.rgb(  255 , 0,  0));
     elseif i== 2 then
	 AddIndexes(i, Indexes[i],core.rgb(  0 , 255,  0) );
     elseif i== 3 then
	 AddIndexes(i, Indexes[i],core.rgb(  128 , 128,  128) );	 
     else	 
	 AddIndexes(i, Indexes[i], Coloring((100/8)*(i-1)));
	 end
	end
 
end

function Coloring (value )

	if value < 50 then
	Color = core.rgb(  (255/100) *value*2 , 0,  (255/100) *value   );
	elseif value >= 50 then   
	Color = core.rgb( 0,  (255/100) *((value-50)*2  ) ,  (255/100) *value   );
	end
	
	return Color;
end

function AddIndexes(id, Pair, Color)
 indicator.parameters:addBoolean("On"..id , "Shown ".. Pair, "", true);	 
    indicator.parameters:addColor("Color".. id, Pair .. " Line Color", "", Color);
end 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Indexes={"EUR","USD","JPY","GBP","CHF","CAD","AUD","NZD"};
local first;
local source = nil; 
local Number=28;
local loading={}; 
local SourceData={};
local offset, weekoffset;
local Instruments={};
local TotalDevise=8;
local InstrumentName={"EUR/USD","EUR/JPY","USD/JPY","GBP/USD","EUR/GBP","GBP/JPY","GBP/CHF","CHF/JPY","EUR/CHF","USD/CHF",
	                      "AUD/NZD","NZD/CAD","AUD/CAD","NZD/CHF","AUD/CHF","CAD/CHF","GBP/NZD","GBP/AUD","GBP/CAD","NZD/JPY",
						  "AUD/JPY","CAD/JPY","EUR/CAD","EUR/AUD","EUR/NZD","USD/CAD","AUD/USD","NZD/USD"}; 
local  Point={};	   
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name);  
	
    if(nameOnly) then
        return;
    end
	

    Period = instance.parameters.Period; 
    source = instance.source;
    first = source:first()+2;
   
   
    offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
	
		
    local InstrumentFlag; 
	for i= 1, Number, 1 do	 

            InstrumentFlag  =  FindInstrument( InstrumentName[i] );	 
			assert(  InstrumentFlag , "Please Subscribe to " .. InstrumentName[i] ) ;	 
	 
			SourceData[InstrumentName[i]] = core.host:execute("getSyncHistory",InstrumentName[i], source:barSize(), source:isBid(), math.min(300,Period), 200+i, 100+i);
			loading[InstrumentName[i]]=true;
			Point[InstrumentName[i]]= core.host:findTable("offers"):find("Instrument",InstrumentName[i]).PointSize;	  
		   
	end

 --string host:execute ("getSyncHistory", instrument, barSize, bidOrAsk, barsAtLeft, commandIdSyncComplete, commandIdSyncStarted)
 
	 
	    for i = 1, TotalDevise , 1 do
			if instance.parameters:getBoolean("On" .. i)  then
			    Instruments[i] = instance:addStream("Instruments".. i, core.Line, name,  Indexes[i], instance.parameters:getColor("Color" .. i), source:first());
                Instruments[i]:setPrecision(math.max(2, instance.source:getPrecision()));
			  	
			else
			Instruments[i]= instance:addInternalStream(0, 0);
			end
		end
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 

function Update(period)

   if period <= first then
   return;
   end

  
	local Flag = false;
	
	for i = 1, Number , 1 do
		if loading[InstrumentName[i]] then
		Flag = true;
		end
	end
	
	if Flag then
	return;
	end
--"mCADCHF" 
--"mCHFCAD" 
     local mEURUSD=Calculate(period, InstrumentName[1]);
     local mEURJPY=Calculate(period, InstrumentName[2]);
     local mUSDJPY=Calculate(period, InstrumentName[3]);
     local mGBPUSD=Calculate(period, InstrumentName[4]);
	 local mEURGBP=Calculate(period, InstrumentName[5]);
     local mGBPJPY=Calculate(period,  InstrumentName[6]);
     local mGBPCHF=Calculate(period,  InstrumentName[7]);	 
     local mCHFJPY=Calculate(period,  InstrumentName[8]);
     local mEURCHF=Calculate(period, InstrumentName[9]);	 
     local mUSDCHF=Calculate(period,  InstrumentName[10]); 
	 
     local mAUDNZD=Calculate(period,  InstrumentName[11]);
     local mNZDCAD=Calculate(period,  InstrumentName[12]);	
	 
	 
     local mAUDCAD=Calculate(period,  InstrumentName[13]);
     local mNZDCHF=Calculate(period,  InstrumentName[14]);
     local mAUDCHF=Calculate(period,  InstrumentName[15]);	 
     local mCADCHF=Calculate(period,  InstrumentName[16]);
     local mGBPNZD=Calculate(period,  InstrumentName[17]);
     local mGBPAUD=Calculate(period,  InstrumentName[18]);
	 local mGBPCAD=Calculate(period,  InstrumentName[19]); 

     local mNZDJPY=Calculate(period,  InstrumentName[20]);
     local mAUDJPY=Calculate(period,  InstrumentName[21]);	 
     local mCADJPY=Calculate(period,  InstrumentName[22]);
     local mEURCAD=Calculate(period,  InstrumentName[23]);
     local mEURAUD=Calculate(period,  InstrumentName[24]);
     local mEURNZD=Calculate(period,  InstrumentName[25]);
     local mUSDCAD=Calculate(period,  InstrumentName[26]);
     local mAUDUSD=Calculate(period,  InstrumentName[27]);
     local mNZDUSD =Calculate(period,  InstrumentName[28]);

 
     Instruments[1][period]=(Instruments[1][period-1]+Instruments[1][period-2]+((mEURUSD+mEURJPY+mEURGBP+mEURCHF+mEURCAD+mEURAUD+mEURNZD)/(TotalDevise-1)))/7;
     Instruments[2][period]=(Instruments[2][period-1]+Instruments[2][period-2]+((mUSDJPY-mEURUSD-mGBPUSD+mUSDCHF+mUSDCAD- mAUDUSD - mNZDUSD   )/(TotalDevise-1)))/7;
     Instruments[3][period]=(Instruments[3][period-1]+Instruments[3][period-2]+((mEURJPY-mUSDJPY-mGBPJPY-mCHFJPY-mCADJPY-mAUDJPY -mNZDJPY)/(TotalDevise-1)))/7;  
     Instruments[4][period]=(Instruments[4][period-1]+Instruments[4][period-2]+((mEURGBP+mGBPJPY+mGBPUSD+mGBPCHF+mGBPCAD+mGBPAUD  +mGBPNZD  )/(TotalDevise-1)))/7; 
     Instruments[5][period]=(Instruments[5][period-1]+Instruments[5][period-2]+((mCHFJPY-mGBPCHF-mUSDCHF-mEURCHF+mCADCHF-mAUDCHF  +mNZDCHF)/(TotalDevise-1)))/7; 
	 Instruments[6][period]=(Instruments[6][period-1]+Instruments[6][period-2]+((mCADJPY-mGBPCAD-mUSDCAD-mEURCAD-mAUDCAD  -mNZDCAD+mCADCHF)/(TotalDevise-1)))/7;
     Instruments[7][period]=(Instruments[7][period-1]+Instruments[7][period-2]+((mAUDJPY-mGBPAUD   -mEURAUD + mAUDUSD + mAUDCHF - mNZDCAD +mAUDCAD )/(TotalDevise-1)))/7; 
     Instruments[8][period]=(Instruments[8][period-1]+Instruments[8][period-2]+((mNZDUSD -mEURNZD-mGBPNZD+ mNZDJPY+  mNZDCHF +mNZDCAD - mAUDNZD)/(TotalDevise-1)))/7;
	 
	 
end

function Calculate(period, InternalInstrumentName )

local p= Initialization(period,InternalInstrumentName);
local Return=0;


if not p then
return Return;
end

if  p <= Period then
return Return;
end

 

 Return= (SourceData[InternalInstrumentName][p] - SourceData[InternalInstrumentName][p-Period+1])/Point[InternalInstrumentName];
 
 return Return;

end
 

function   Initialization(period,InternalInstrumentName)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
    if loading[InternalInstrumentName] or SourceData[InternalInstrumentName]:size() == 0  then
        return false;
    end
--i
    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(SourceData[InternalInstrumentName], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	


function AsyncOperationFinished(cookie)
     local j;	 
	local Count=0;	
	local Flag=false;
	
    for j = 1, Number, 1 do
		
			  if cookie == (100 +j) then
			  Flag=true;
			  loading[InstrumentName[j]] = true;
			  Count=Count+1;
		      elseif  cookie == (200+j) then
			  loading[InstrumentName[j]] = false;               		 
              end  
			  
	end   
	
		        if Flag then
				core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
				else
				core.host:execute ("setStatus","Loaded");	 
		        end
 
   
     	if not Flag then 	
		instance:updateFrom(0);	 
		end
		
        
		return core.ASYNC_REDRAW ;
end
--253
function FindInstrument(Instrument)
  
   
    local row, enum;   
	local Flag= false;
   
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
       
        if Instrument == row.Instrument then
		Flag= true;
		break;
		end
         row = enum:next(); 
    end

    return Flag;
end
