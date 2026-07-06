-- Id: 22143
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66590

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
    indicator:name("CM Sling Shot System");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
	
	indicator.parameters:addBoolean("sae", "Show Aggressive Entry", "", true);
	indicator.parameters:addBoolean("sce", "Show Conservative Entry", "", true);
   
    indicator.parameters:addBoolean("st", "Show Trend Arrows at Top and Bottom of Screen", "", true);

     
    indicator.parameters:addInteger("Period1", "Period", "", 38, 2, 2000);
 
	indicator.parameters:addString("Price1", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("2. MA Calculation"); 
    indicator.parameters:addInteger("Period2", "Period", "", 62, 2, 2000);
 
	indicator.parameters:addString("Price2", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style"); 	
   
	indicator.parameters:addInteger("style1", "Fast MA Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
	
	

	indicator.parameters:addInteger("style2", "Slow MA Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
	
	
	 indicator.parameters:addColor("Up", "Up Trend Line Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Down", "Down Trend Line Color", "", core.rgb(255, 0, 0));
	 	
	  indicator.parameters:addInteger("Transparency", "Transparency", "", 75,0,100);
	  indicator.parameters:addInteger("Size", "Arrow Size", "", 15,0,100);
	  
	  indicator.parameters:addGroup("Candle Style");
	indicator.parameters:addColor("UpCandle", "Up candle color", "", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("DownCandle", "Down candle color", "", core.COLOR_DOWNCANDLE ); 
    indicator.parameters:addColor("NeutralCandle", "Neutral candle color", "", core.rgb(128, 128, 128)); 
	
	
	local colour = core.colors();
	
	indicator.parameters:addColor("AggressiveCandle", "Aggressive candle color", "", colour.Yellow); 
	indicator.parameters:addColor("ConservativeCandle", "Conseervative candle color", "", colour.Aqua); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local UpCandle, DownCandle, NeutralCandle;

local sae, sce;
local st ;
 
local Method1, Price1, Period1;
local Method2, Price2, Period2; 

local first;
local source = nil;
 
local Fast, Slow;  
local MA1, MA2; 
local Transparency;

local Size, Up,Down;

local up, down;

local upTrend, downTrend;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Transparency= instance.parameters.Transparency; 
	Transparency= 100-Transparency;

	sae= instance.parameters.sae;
	sce= instance.parameters.sce;
	st= instance.parameters.st; 
	
	UpCandle= instance.parameters.UpCandle;
	DownCandle= instance.parameters.DownCandle;
	NeutralCandle= instance.parameters.NeutralCandle;
	
	Size= instance.parameters.Size;
	
	 
    Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1;
    Price1 = instance.parameters.Price1;
	
	Period2= instance.parameters.Period2;
    Method2= instance.parameters.Method2;
    Price2 = instance.parameters.Price2; 
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    MA1 = core.indicators:create(Method1, source[Price1], Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
    MA2 = core.indicators:create(Method2, source[Price2], Period2);
    
     first=math.max(source:first(), MA1.DATA:first(), MA2.DATA:first());
	
	  
	
    Fast = instance:addStream("Fast" , core.Line, " Fast"," Fast",instance.parameters.Up, first);
	Fast:setWidth(instance.parameters.width1);
    Fast:setStyle(instance.parameters.style1);
	
	Slow = instance:addStream("Slow" , core.Line, " Slow"," Slow",instance.parameters.Down, first);
	Slow:setWidth(instance.parameters.width2);
    Slow:setStyle(instance.parameters.style2);
	
	
	instance:createChannelGroup("Channel","Channel" , Fast,Slow, instance.parameters.Up, Transparency);
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);
	down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down, 0);
	
 
    instance:ownerDrawn(st);
	 

	 upTrend = instance:addInternalStream(0, 0);
     downTrend = instance:addInternalStream(0, 0);	 
	
end

-- Indicator calculation routine
function Update(period, mode)


    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];

    
	down:setNoData(period);
	up:setNoData(period);
	
	
 
    MA1:update(mode);
    MA2:update(mode);
	
	
	if source.close[period]> source.open[period] then
	open:setColor(period, UpCandle);	
	elseif source.close[period]< source.open[period] then
	open:setColor(period, DownCandle);	
	else
	open:setColor(period, NeutralCandle);	
	end
	
	
    if period < first then 
	return;
	end
	
	
	Fast[period]=MA1.DATA[period];
	Slow[period]=MA2.DATA[period];
   
    --Aggressive Entry or Alert To Potential Trade
   local pullbackUpT= false;

    if MA1.DATA[period] > MA2.DATA[period] and source.close[period] <  MA1.DATA[period]  then
	pullbackUpT=true;
	end
	
	
	local pullbackDnT= false;

    if MA1.DATA[period] < MA2.DATA[period] and source.close[period] >  MA1.DATA[period] then
	pullbackDnT=true;
	end
 
	 --Conservative Entry Code For Highlight Bars
     local entryUpT=false; 
     if  MA1.DATA[period]  > MA2.DATA[period] and source.close[period-1] < MA1.DATA[period] and source.close[period] > MA1.DATA[period]  then
	 entryUpT=true;
	 end
	 
	 local entryDnT=false;	 
      if MA1.DATA[period]  < MA2.DATA[period] and source.close[period-1] > MA1.DATA[period]  and source.close[period] < MA1.DATA[period]  then
	  entryDnT=true;
	  end
	  
	  
	  --Conservative Entry True/False Condition
	  local entryUpTrend=false;
	  
	   if MA1.DATA[period]  > MA2.DATA[period] and source.close[period-1] < MA1.DATA[period]  and source.close[period] > MA1.DATA[period]  then 
	   entryUpTrend=true;
	   end
      
	  local entryDnTrend =false;
	  if  MA1.DATA[period]  < MA2.DATA[period] and source.close[period-1] > MA1.DATA[period]  and source.close[period] < MA1.DATA[period]  then
	  entryDnTrend=true;
	  end
	  
	  
	  --Define Up and Down Trend for Trend Arrows at Top and Bottom of Screen
	  upTrend[period]=0;
	  
      if MA1.DATA[period]  >= MA2.DATA[period] then
	  upTrend[period]=1;
	  end
	  
	  
	  downTrend[period]=0;
	  
      if MA1.DATA[period]  < MA2.DATA[period] then
	  downTrend[period]=1;
	  end
	  
	  
	  --Definition for Conseervative Entry Up and Down PlotArrows
	  
	  local codiff=false;
	  if entryUpTrend then
	  codiff=true;
	  end
	  
	  local codiff2=false;
	  if entryDnTrend then
	  codiff2=true;
	  end
 
      --Color definition for Moving Averages
      if MA1.DATA[period] > MA2.DATA[period]  then
	  Fast:setColor(period, instance.parameters.Up);
	  Slow:setColor(period, instance.parameters.Up);
	  else 
	  Fast:setColor(period, instance.parameters.Down);
	  Slow:setColor(period, instance.parameters.Down);
	  end
	  
	  
	  --Aggressive Entry, Conservative Entry Highlight Bars
	  
	 
	  
	  
	   if sae and (pullbackUpT or pullbackDnT) then
	  open:setColor(period, instance.parameters.AggressiveCandle);
	  end
	  
	  
	   if sce and (entryUpT or entryDnT) then
	  open:setColor(period, instance.parameters.ConservativeCandle);
	  end
 
		

        if codiff then
		  up:set(period , source.low[period], "\217" );
		elseif codiff2 then  
		  down:set(period, source.high[period], "\218" );
		 end  	


      	 
end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
        if not init then
            context:createFont(1, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0); 
            init = true;
        end

		
    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
	
	
	   local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
     
	  width, height = context:measureText (1,  "\108" , 0)	 
	 
	  for index= first, last, 1 do	 
				 
		
		 
		x, x1, x2 =context:positionOfBar (index);				
		
			if upTrend[index] then
			  context:drawText(1,   "\108" , instance.parameters.Up, -1, x-width/2, context:bottom()-height*4, x+width/2,context:bottom()-height*3, 0);	
			elseif downTrend[index] then  
			   context:drawText(1,   "\108" , instance.parameters.Down, -1,  x-width/2, context:top()+height*4   , x+width/2, context:top()+height*5, 0);	
			end	
			

       end

end