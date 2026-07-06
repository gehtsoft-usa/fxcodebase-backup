 
-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71307

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
function Init()
    indicator:name("Other Source MA Phase");
    indicator:description("Other Source MA Phase");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Selector");	
	indicator.parameters:addInteger("Extension", "Extension", "Extension" , 50);	
	
	indicator.parameters:addString("Instrument" , "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("Instrument" , core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addString("TF", "Time Frame", "", "Chart");
	local iTF={"m1","m5","m15","m30","H1","H2","H3","H4","H6","H8", "D1", "W1", "M1", "Chart"};
    for i= 1, 14, 1 do
	    indicator.parameters:addStringAlternative("TF", iTF[i], iTF[i] , iTF[i]);
	end
	
	
	
	indicator.parameters:addGroup("1. MA Calculation");
    indicator.parameters:addInteger("Period1", "MA Period", "Period" , 50);	
	
	
 
	
    indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("2. MA Calculation");
    indicator.parameters:addInteger("Period2", "MA Period", "Period" , 100);	 	
 
	
    indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA"); 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Top Line Color", "Line Color", core.rgb(0, 255, 0)); 
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 

local first;
local source = nil; 
local Extension;
local Top, Bottom; 
local StartPeriodTop=nil;
local EndPeriodTop=nil;

local StartPeriodBottom=nil;
local EndPeriodBottom=nil;

local MA1,MA2;

local TF; 
local Instrument;
local dayoffset;
local weekoffset;
local SourceData;
local loading = false; 
	
function Prepare(nameOnly)
    
    source = instance.source;
	


    local name = profile:id() .. "(" .. source:name()  ..  ")";
    instance:name(name);

    if   (nameOnly)  then
	return;
	end
	
 
	
	Extension=instance.parameters.Extension;
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
	Instrument= instance.parameters.Instrument;
	
	if TF=="Chart" then
	TF= source:barSize();
	end
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
             s2, e2 = core.getcandle(TF      ,      0,                0,                0);
    --core.getcandle               (barSize, datetime, tradingDayOffset, tradingWeekOffset) 
	--local begin = core.getcandle("D1", date, core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"));

	

	
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
 
	SourceData = core.host:execute("getSyncHistory", Instrument, TF, source:isBid(),0, 100, 101);
	loading=true;	
	
	MA1= core.indicators:create(instance.parameters.Method1, SourceData.close,  instance.parameters.Period1);	
	MA2= core.indicators:create(instance.parameters.Method2, SourceData.close,  instance.parameters.Period2);	
	first=source:first(); 
	
    ma1 = instance:addInternalStream(0, 0);
    ma2 = instance:addInternalStream(0, 0);	
	
        Phase = instance:addStream("Phase", core.Line, name, "Phase", instance.parameters.Color, 0,Extension);
        Phase:setPrecision(math.max(2, instance.source:getPrecision()));
		Phase:setWidth(instance.parameters.width);
        Phase:setStyle(instance.parameters.style);
		Phase:addLevel(0);
 
 
		StartPeriodTop=nil;
		EndPeriodTop=nil;		
 
	
	
	core.host:execute("setTimer", 1, 10);
end

function ReleaseInstance()
    core.host:execute("killTimer", 1);
end

 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
 
 
 
 
    MA1:update(mode); 
	MA2:update(mode); 
 
 
    local p =  Initialization(period) 
     
	if not p then
	return;
	end
    	
	ma1[period]=MA1.DATA[p];
	ma2[period]=MA2.DATA[p];	

    if period < source:size()-1 then
	return;
	end	

    if StartPeriodTop==nil
	or  EndPeriodTop==nil
    then
	return;
	end
 
				
	PeriodTop=(EndPeriodTop-StartPeriodTop) ;
 
    for i= first,  StartPeriodTop  ,1 do	
	Phase[i]=nil;
	end
 
 	for i= StartPeriodTop-1, source:size()-1+Extension ,1 do	
		
		if ma1[StartPeriodTop] > ma2[StartPeriodTop] then
		Phase[i] = math.sin(math.pi * ((i-StartPeriodTop)/PeriodTop) );
		else
		Phase[i] =1- math.sin(math.pi * ((i-StartPeriodTop)/PeriodTop) )-1;	
        end		
			
	end
	
	 
end

function AsyncOperationFinished(cookie )


      
     if cookie == 100 then
        loading = false;  
		instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
	

    if cookie== 1 then
	StartPeriodTop, EndPeriodTop= FindLast(source:size()-2)
 
	
	 if StartPeriodTop~= nil and  EndPeriodTop~= nil  
	 then
	 instance:updateFrom(0);
	 end
	 
	end
    

	 
     return core.ASYNC_REDRAW ;
   
	
end	


 function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


function FindLast(period)

   --period == source:size()-2

		local Return={}; 
        local Count=0;
		for i = period, first , -1 do 
		    
		    if  core.crosses (ma1,ma2, i) then 
            Count=Count+1;
			Return[Count]=i;	
             --Return[1]=100;	
             --Return[2]=92;					 
            end			
			
			if Return[1]~=nil and Return[2]~=nil  then
			break;
			end

		end


    return Return[2],Return[1];
 
end
 
 
 