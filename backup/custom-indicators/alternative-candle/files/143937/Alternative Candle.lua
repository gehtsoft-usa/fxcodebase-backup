-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71570

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
function Init()
      indicator:name("Alternative Candle");
    indicator:description("Alternative Candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    --indicator:setTag("replaceSource", "t");
	
      indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("TF"  , "Time Frame ", "", "m1");
    indicator.parameters:setFlag("TF"  , core.FLAG_PERIODS);
 
	
	  indicator.parameters:addGroup("Style");
 
	 indicator.parameters:addInteger("Size", "Open / Close Font Size", "", 10);

	indicator.parameters:addColor("color1", "Up Color", "Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Down Color", "Color", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color3", "Median Color", "Color", core.rgb(0, 0, 255));	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Size;
local source; 
local first;  

local TF;
local loading, Source;

local High=nil;
local Low=nil;

local offset,weekoffset;
local BarSize;
-- Routine
 function Prepare(nameOnly) 
    TF = instance.parameters.TF; 
	Size = instance.parameters.Size;	 
    source = instance.source;
    first = source:first();
	
    local name = profile:id() .. "(" .. source:name()  .. ", " .. TF  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
	
	
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(), offset, weekoffset);
    s2, e2 = core.getcandle(TF, offset, weekoffset);
    assert((e2 - s2) <=(e1 - s1), "The chosen time frame must be smaller than the source time frame");
 
 
  	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 300, 100, 101);
	loading=true;
	
	instance:ownerDrawn(true)
	
 
    High = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    Low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
	High:setStyle(core.LINE_NONE)
	Low:setStyle(core.LINE_NONE)
	
end

local date; 
local Filter;
local FLAG;
-- Indicator calculation routine
function Update(period)  


    if period < first then
    return;
    end	
  
	High[period]= source.high[period];
	Low[period]= source.low[period];	
  
end


local init=false;
function Draw(stage, context)
	if stage ~= 2
	or loading
	then
		return
	end

	-- initialize GDI objects
	if not init then
		context:createPen(1, context:convertPenStyle(instance.parameters.style), instance.parameters.width, instance.parameters.color1) 
		context:createPen(2, context:convertPenStyle(instance.parameters.style), instance.parameters.width, instance.parameters.color2)
	   context:createFont (3, "Wingdings", context:pointsToPixels (instance.parameters.Size),  context:pointsToPixels (instance.parameters.Size), 0); 
		init = true
	end
	
	
 
	Start = math.max(context:firstBar(), first );
	End = math.min(context:lastBar(), source:size() - 1);

    local p;
    local width, height= context:measureText (3, "\108", 0);
 
 
 	
	for p = Start, End, 1 do

	visible, high = context:pointOfPrice(source.high[p]);
	visible, low = context:pointOfPrice(source.low[p]);	
	visible, open = context:pointOfPrice(source.open[p]);
	visible, close = context:pointOfPrice(source.close[p]);	
	visible, median = context:pointOfPrice(source.median[p]);		
	x, x1, x2  = context:positionOfBar  (p); 
	
	

	
	
			if source.close[p]> source.open[p] then
			context:drawText (3, "\108", instance.parameters.color1, -1, x1 , open-height/2 , x1+width, open+height/2 , 0);
			context:drawText (3, "\108", instance.parameters.color1, -1, x2-width , close-height/2 , x2, close+height/2 , 0);	
			context:drawText (3, "\108", instance.parameters.color3, -1, x-width/2 , median-height/2 , x+width/2, median+height/2 , 0);	
 
			context:drawLine(1, x, high, x, low);
	--		Helper(context, p );	
			else
			context:drawText (3, "\108", instance.parameters.color2, -1,  x1  , open-height/2 , x1+width, open+height/2 , 0);
			context:drawText (3, "\108", instance.parameters.color2, -1, x2-width , close-height/2 , x2, close+height/2 , 0);
			context:drawText (3, "\108", instance.parameters.color3, -1, x-width/2 , median-height/2 , x+width/2, median+height/2 , 0);						
			context:drawLine(2, x, high, x, low);	
		--	Helper(context, p );	
			end
	 
	end

	
end

function Helper(context, period )
    
	X1, o, o  =  context:positionOfBar ( period-1 ); 	 
	X2, x1, x2  =  context:positionOfBar ( period ); 		
       local from, to = core.getcandle(TF, source:date(period), offset, weekoffset);  
       local p1 = core.findDate(Source, from, false);
       local p2 = core.findDate(Source, to, false);
	   
	 if p1<0 or p2<0 then
	 return;
	 end
	   
	  
    TheSize=((X2-X1)) /(p2-p1);

    if TheSize> context:pointsToPixels (instance.parameters.Size) then
	TheSize= context:pointsToPixels (instance.parameters.Size);
    end	
	
	
	
	context:createFont (4, "Wingdings", context:pointsToPixels (instance.parameters.Size) ,   context:pointsToPixels (instance.parameters.Size), 0);	   
	local width, height= context:measureText (4, "\115", 0);	


    local Last;
	   
	   for p= p1, p2, 1 do
	   
	   if p == p1 then
	   Last=x1+width;
	   end
	    	   visible, Price = context:pointOfPrice(Source.close[p]);	
			   -- Shift=width*(p-p1);
				if Source.close[p]> Source.open[p] then
				context:drawText (4, "\115", instance.parameters.color1, -1, Last, Price-height/2 , Last+width , Price+height/2 , 0);
				else
				context:drawText (4, "\115", instance.parameters.color2, -1, Last, Price-height/2 ,  Last+width , Price+height/2 , 0);	
				end
				
				
				 Last= Last+width;
			
	   
	   end
	   
	   
end

function AsyncOperationFinished(cookie, success, message)

	   
	    if cookie == 100 then
        loading = false;
        elseif cookie == 101 then
        loading = true;
        end
		
	   
	    if not loading  then
        instance:updateFrom(0);
		end
		
		return core.ASYNC_REDRAW ;
end

 