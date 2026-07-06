-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=73564

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Heikin Ashi Midpoint Pivot");
    indicator:description("EMA Template");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation"); 	 

    indicator.parameters:addString("Price", "Price Source", "", "median");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
    indicator.parameters:addBoolean("Shift", "Shift", "", true);
	
    local TF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1", "Chart"}
	
    indicator.parameters:addString("TF", "Price Time Frame", "", "Chart");
	for i = 1, 14, 1 do
	indicator.parameters:addStringAlternative("TF", TF[i], "", TF[i]);
    end
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
    indicator.parameters:addGroup("Horizontal Line Style");
    indicator.parameters:addBoolean("Chart", "Chart Price", "", true);	
   indicator.parameters:addBoolean("Line1", "Show Indicator Line", "", true);
   indicator.parameters:addBoolean("Line2", "Show Price Line", "", true);   
    indicator.parameters:addColor("Color", "Line Color", "", core.COLOR_LABEL );
	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
	indicator.parameters:addDouble("Size", "Font Size", "", 10);	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Period;
	local first;
	local source = nil;
	local TF; 
	local dayoffset;
	local weekoffset;
	local SourceData;
	local loading = false;   
	local Indicator;
    local Shift;
    local Line = nil;
    local Chart;
-- Routine

function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	Line1 = instance.parameters.Line1;
	Line2 = instance.parameters.Line2;
    Shift = instance.parameters.Shift;
	Price = instance.parameters.Price;
	Chart = instance.parameters.Chart;
	
    Size=instance.parameters.Size;
	Style=instance.parameters.Style;
	Width=instance.parameters.Width;
	Color=instance.parameters.Color;
	
    source = instance.source;
    first = source:first();	
	 
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
	if TF=="Chart" then
	TF=source:barSize()
	end
	
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	 
	
	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), first, 100, 101);
	loading=true;
	
 

     
	    Indicator = core.indicators:create("HA", SourceData );

        Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color, source:first());
		Line:setWidth(instance.parameters.width);
        Line:setStyle(instance.parameters.style);
		
		
	 	instance:ownerDrawn(true);
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

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

        local p =  Initialization(period) 
     
	    if not p 
		or p<=1 
		then
		return;
		end
		
		if Shift then
		p=p-1;
		end
		
		
	
	   Indicator:update(mode); 	
    
	    if Indicator.DATA:hasData(p) then	
			if Price=="median" then
			Line[period] =(Indicator.high[p]+Indicator.low[p])/2;	
			elseif Price=="typical" then
			Line[period] = (Indicator.high[p]+Indicator.low[p]+Indicator.close[p])/3;		
			elseif Price=="weighted" then	
			Line[period] =(Indicator.high[p]+Indicator.low[p]+Indicator.close[p]*2)/4;			
			else		
			Line[period] =Indicator[Price][p];
			end
		end	
  
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
	
	return core.ASYNC_REDRAW ;
end


local init =true;

function Draw(stage, context)
    if stage ~= 2
	
	then
	return;
	end
	

		
		if loading then	
		return;
		end
		
		if init then
		context:createFont (2, "Arial", Size, Size, 0);
	    context:createPen (1, context:convertPenStyle (Style), Width, Color);		
		init=false;
		end
      
	    local x = context:right ()  - (context:right () -context:left ())/3;		
 		    
		
		context:createPen (1, context:convertPenStyle (Style), Width, Color);

        local Last=source:size()-1;
		
        visible, y1= context:pointOfPrice (Line[Last]); 
		
		if Chart then
        visible, y2= context:pointOfPrice (source.close[Last]); 
        else
        visible, y2= context:pointOfPrice (SourceData.close[Last]); 		
        end		
		
	    if Line1 then	 
		context:drawLine (1, context:left(), y1, context:right (), y1);		
        end	
		
	    if Line2 then	 		
		context:drawLine (1, context:left(), y2, context:right (), y2);	
        end

        local Text1=win32.formatNumber(Line[Last], false, source:getPrecision());
		
		
		if Chart then		
        Text2=win32.formatNumber(source.close[Last], false, source:getPrecision());	
        else
        Text2=win32.formatNumber(SourceData.close[Last], false, source:getPrecision());	 		
        end	
		
	


	    if Line1 then
        width1, height1 =context:measureText (2, Text1, 0)		
        context:drawText (2, Text1, Color, -1, context:left() , y1-height1,  context:left()+width1, y1, 0);		
        end
		
	    if Line2 then	
	    width2, height2 =context:measureText (2, Text2, 0)		
		context:drawText (2, Text2, Color, -1, context:right ()-width2, y2-height2, context:right (), y2, 0);
        end		
end			
			
			
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+
 