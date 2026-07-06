-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66885

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

function Init()
    indicator:name("Scalping indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	

	indicator.parameters:addGroup("Calculation"); 
	
	
	indicator.parameters:addInteger("LIN", "LIN", "", 29, 1, 2000);
	indicator.parameters:addInteger("WHB", "WHB", "", 6, 1, 2000);
    indicator.parameters:addInteger("WHS", "WHS", "", 6, 1, 2000);
	indicator.parameters:addInteger("BIB", "BIB", "", 6, 1, 2000);
    indicator.parameters:addDouble("BIS", "BIS", "", 6, 1, 2000);
    indicator.parameters:addDouble("PPKKS", "PPKKS", "", 0.994);
	indicator.parameters:addDouble("PPKKB", "PPKKB", "", 0.994);
	indicator.parameters:addDouble("RES", "RES", "", 3);
	indicator.parameters:addDouble("SUP", "SUP", "", 3); 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Arrow Size", "", 15);
	indicator.parameters:addBoolean("SWITCH", "SWITCH", "", true);
 
 
 
    indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local WHB,WHS,BIB,BIS,PPKKS,PPKKB,RES,SUP,LIN,SWITCH;
local first;
local source = nil;
 
local Size;  
 

local up, down;
local RESISTENCE, SUPPORT;

local whitenoise, whitenoiseB;
local a11,b11, c22,c33 ,c11; 
local a1, b1, c2, c3, c1;

local filtB;
local pkB;
local filt;
local pk;
local resultB;
local resultS;
local   style, width;
-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    LIN = instance.parameters.LIN;
	
	
	local Parameters= LIN;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..   Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	WHB = instance.parameters.WHB;
	WHS = instance.parameters.WHS;
	BIB = instance.parameters.BIB;
	BIS = instance.parameters.BIS;
	PPKKS = instance.parameters.PPKKS;
	PPKKB = instance.parameters.PPKKB;
	RES = instance.parameters.RES;
	SUP = instance.parameters.SUP;
	SWITCH= instance.parameters.SWITCH;
	
	Size = instance.parameters.Size;
	 
	style = instance.parameters.style;
	width = instance.parameters.width;

    
			
    source = instance.source;
	first=source:first()+math.max(WHS,WHB,LIN );
	
	RESISTENCE = RES*source:pipSize();   -- DISTANCE OF THE SEGMENT OF THE RESISTENCE
    SUPPORT = SUP*source:pipSize();   --DISTANCE OF THE SEGMENT OF THE SUPPORT
    
  
   
    whitenoise = instance:addInternalStream(0, 0);
    whitenoiseB = instance:addInternalStream(0, 0);
   
	filtB = instance:addInternalStream(0, 0);
	pkB = instance:addInternalStream(0, 0);
	filt = instance:addInternalStream(0, 0);
	pk = instance:addInternalStream(0, 0);
	
	resultB = instance:addInternalStream(0, 0);
    resultS = instance:addInternalStream(0, 0); 
   
 
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Down, 0);
    
	
	a11= math.exp(-1.414 * 3.14159 / BIS);
    b11= 2*a11 * math.cos(1.414*180 /BIS);
    c22= b11;
    c33= -a11 * a11;
    c11= 1 - c22 - c33;
	
	-- super smoother filter
	 a1= (-1.414 * 3.14159 / BIB);
	 b1= 2*a1 * math.cos(1.414*180 /BIB);
	 c2= b1;
	 c3= -a1 * a1;
	 c1= 1 - c2 - c3;
	 
	 
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    up:setNoData(period);
   down:setNoData(period);
   
   
   if not SWITCH then
   return;
   end
	
	
    if period < first then
	return;
	end
	
		
    whitenoiseB[period]=  source.close[period] - source.close[period-WHS+1];
	whitenoise[period]=  source.close[period] - source.close[period-WHB+1];
	
	
	--MODIFIED UNIVERSAL OSCILLATOR 1 
 
	  filtB[period]= c11 * (whitenoiseB[period] + whitenoiseB[period-1])/2+ c22*filtB[period-1] + c33*filtB[period-1]
	 filt11 = filtB[period]
	 if math.abs(filt11)>pkB[period-1] then
	  pkB[period] = math.abs(filt11)
	 else
	  pkB[period] = PPKKS * pkB[period-1]
	 end
	 if pkB[period]==0 then
	  denomB = -1
	 else
	  denomB = pkB[period]
	 end
	 if denomB == -1 then
	  resultB[period] = resultB[period-1]
	 else
	  resultB[period] = filt11/pkB[period]
	 end
	
	
	-- MODIFIED UNIVERSAL OSCILLATOR 2 
 
 filt[period]= c1 * (whitenoise[period] + whitenoise[period-1])/2+ c2*filt[period-1] + c3*filt[period-1]
 filt1 = filt[period]
 if math.abs(filt1)>pk[period-1] then
  pk[period] = math.abs(filt1)
 else
  pk[period] = PPKKB * pk[period-1]
 end 
 if pk[period]==0 then
  denom = -1
 else
  denom = pk[period]
 end 
 if denomm == -1 then
  resultS[period] = resultS[period-1]
 else
  resultS[period] = filt1/pk[period]
 end 
 
 
 --PATNER UP 1
   if  resultS[period] <-0.5 then
   PrUp01=true;
   else
   PrUp01=false;
   end
   
   
   --PATNER DOWN 1
   
   if  resultS[period] > 0.5 then
   PrDw01=true;
   else
   PrDw01=false;
   end
   
   
   if PrUp01 
   and resultS[period]> resultB[period]
   and resultS[period-1]<= resultB[period-1]
   then
   up:set(period, source.high[period]+source:pipSize(), "\218", source.high[period]);
   core.host:execute ("drawLine", source:serial(period), source:date(period-LIN), source.high[period]+RESISTENCE, source:date(period), source.high[period]+RESISTENCE, instance.parameters.Up, style, width);
   end
   
   if PrDw01 
   and resultS[period]< resultB[period]
   and resultS[period-1]>= resultB[period-1]
   then
   down:set(period, source.low[period]-source:pipSize(), "\217", source.low[period]);
   core.host:execute ("drawLine", source:serial(period), source:date(period-LIN), source.low[period]-SUPPORT, source:date(period), source.low[period]-SUPPORT, instance.parameters.Down, style, width);
   end
   
 
				  
end

  

