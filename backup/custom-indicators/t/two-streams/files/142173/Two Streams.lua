-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71210

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
    indicator:name("GenericTwo Indicator Cross");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
   indicator.parameters:addGroup("1.Line Calculation"); 
   indicator.parameters:addString("instrument1"  , "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("instrument1" ,  core.FLAG_INSTRUMENTS);
   indicator.parameters:addInteger("Period1", "MA Period", "Period" , 1);
    indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
    
	
	indicator.parameters:addGroup("2.Line Calculation"); 
	indicator.parameters:addString("instrument2"  , "Instrument", "", "AUD/USD");
    indicator.parameters:setFlag("instrument2" ,  core.FLAG_INSTRUMENTS);
   indicator.parameters:addInteger("Period2", "MA Period", "Period" , 1);
    indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");

		
    
	indicator.parameters:addGroup("1.Line Style");  
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    
	indicator.parameters:addGroup("2.Line Style");
	indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
  
end
 
 
local source;

local Indicator1= nil; 
local Indicator2= nil;
 

 
local first; 
 
local dayoffset, weekoffset; 
local Source1, Source2;
 local loading1, loading2; 
local First_Line,Second_Line;

local lastBar, firstBar;
function Prepare(nameOnly)
 
    source = instance.source;	
	first = source:first();

    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	instance:name(name );
	if nameOnly then
		return;
	end
	
		 
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
 
	Raw1 = instance:addInternalStream(0, 0);
	Raw2 = instance:addInternalStream(0, 0);  
	
	Source1 = core.host:execute("getSyncHistory",  instance.parameters.instrument1, source:barSize(), source:isBid(), 300, 100, 101);
	loading1=true;
	
	Source2 = core.host:execute("getSyncHistory", instance.parameters.instrument2, source:barSize(), source:isBid(), 300, 200, 201);
	loading2=true;
	
	
	Indicator1 = core.indicators:create( instance.parameters.Method1, Source1.close,  instance.parameters.Period1);
    Indicator2 = core.indicators:create( instance.parameters.Method2, Source2.close,  instance.parameters.Period2);
 
     First_Line = instance:addStream("First_Line", core.Line, "First_Line", "First_Line", instance.parameters.color1, first);
	 First_Line:setWidth(instance.parameters.width1);
     First_Line:setStyle(instance.parameters.style1);
	 
	 Second_Line = instance:addStream("Second_Line", core.Line, "Second_Line", "Second_Line", instance.parameters.color2, first);
	 
	 Second_Line:setWidth(instance.parameters.width2);
     Second_Line:setStyle(instance.parameters.style2);
	 
	 	instance:ownerDrawn(true);
 
end


function   Initialization1(period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
    if loading1 or Source1:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source1, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


function   Initialization2(period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
    if loading2 or Source2:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source2, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	
local Max,Min;
 
local FirstBar,LastBar;
function Draw(stage, context )
    if stage ~= 2  then
	return;
	end
	 
	 
	 FirstBar=context:firstBar ();
	 LastBar=context:lastBar ();
end	
	
local Ratio1, Ratio2;

local Last=nil;
function Update(period, mode)

 
 
	if period == first then
	Last=period;
		return;
	elseif   period < Last then 
	
	
	 	Last=period;
	  instance:updateFrom(0);
	 
	return;
	end 
	

  
   Indicator1:update(mode);
   Indicator2:update(mode);	
   
   p1= Initialization1(period);   
   p2= Initialization2(period);
   
   if p1== false or p2== false then
   return;
   end
   
   
   
   Raw1[period]=Indicator1.DATA[p1];
   Raw2[period]=Indicator2.DATA[p2];  
 
   
   if FirstBar== nil then
   return;
   end
   
   
   if FirstBar <= first 
   or  FirstBar > source:size()-1 
   then
   return;
   end
   
  
   if period < source:size()-1 then 
   return;
   end
   
   
    local min1,max1=mathex.minmax(Raw1, FirstBar, source:size()-1);
   local min2,max2=mathex.minmax(Raw2, FirstBar, source:size()-1);
   local min,max=mathex.minmax(source, FirstBar, source:size()-1);
   Ratio1=(max-min)/(max1-min1) ;
   Ratio2=(max-min)/ (max2-min2) ;
 
  

   
   
    for i= FirstBar, source:size()-1 ,1 do     
   First_Line[i]= source.close[FirstBar]+(Raw1[i]-Raw1[FirstBar]  )* Ratio1;
   Second_Line[i]= source.close[FirstBar]+ (Raw2[i]-Raw2[FirstBar]  )*Ratio2; 			
   end
	
end
 

  

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading1 = false;
       
    elseif cookie == 101 then
        loading1 = true;
    end
	
	
	 if cookie == 200 then
        loading2 = false;
 
    elseif cookie == 201 then
        loading2 = true;
    end
	
	
 if not  loading1 and not loading2 then instance:updateFrom(0); end
end



	 


  