-- Id: 21570
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66192

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
    indicator:name("Other Time Frame RSI");
    indicator:description("Other Time Frame RSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	

	
	
	indicator.parameters:addString("Type", "Type", "", "Line");
    indicator.parameters:addStringAlternative("Type", "Bar", "", "Bar");
    indicator.parameters:addStringAlternative("Type", "Line", "", "Line");
	
	indicator.parameters:addGroup("Calculation");
	
	
	local iTF={"Chart", "m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1","W1", "M1"};
	
	indicator.parameters:addString("TF", "Time frame", "", "Chart");
	
	for i= 1, 14, 1  do
	indicator.parameters:addStringAlternative("TF", iTF[i], iTF[i] , iTF[i]);
	end 
	

	
    indicator.parameters:addInteger("Period", "RSI Period", "", 14);

	
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(255, 128, 0));
    indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	

	indicator.parameters:addGroup("OB/OS Levels");	
	
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
	 indicator.parameters:addColor("background_color", "Background Color","",core.COLOR_BACKGROUND);
	 
	 
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	    indicator.parameters:addColor("level_overboughtsold_color1", "OB Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("level_overboughtsold_width1","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style1", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style1", core.FLAG_LEVEL_STYLE);
  
  
    indicator.parameters:addColor("level_overboughtsold_color2", "OS Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("level_overboughtsold_width2","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style2", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style2", core.FLAG_LEVEL_STYLE);
 
 
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE); 
	

	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SN,LN,IN;
local background_color;
local first;
local source = nil; 
local RSI,rsi;
local TF;
local weekoffset, dayoffset;
local loading;
local SourceData;
local S1, S2, S3;

local Type;

local Bottom=nil;
local Top=nil;
local Line1=nil;
local Line2=nil;
local Transparency;
-- Routine
function Prepare(nameOnly)  

    source = instance.source;
   
    Type=instance.parameters.Type;
	TF=instance.parameters.TF; 
	Period = instance.parameters.Period; 
	
	background_color = instance.parameters.background_color;
	
	S1= instance.parameters.S1;
	S2= instance.parameters.S2;
	S3= instance.parameters.S3;
	
	
	TF= instance.parameters.TF;
	if TF=="Chart" then
	TF=source:barSize();
	end
		 
     local name = profile:id() .. "(" .. source:name() .. ", " .. TF.. ", " .. Period.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

 
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	

    local precision = math.max(2, source:getPrecision());

	if TF ~= "Chart"then
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	end
	
	if TF ~= source:barSize() then 
    SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
    loading=true;
	
	rsi = core.indicators:create("RSI", SourceData.close, Period);  	
	first = rsi.DATA:first();
	
	else
	
	rsi = core.indicators:create("RSI", source, Period);  	
	first = rsi.DATA:first();
	
	end

			if Type == "Bar" then
			RSI = instance:addStream("RSI", core.Bar, name .. ".RSI", "RSI", instance.parameters.color1, first); 
			else
			RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.color1, first); 
			RSI:setWidth(instance.parameters.width1);
			RSI:setStyle(instance.parameters.style1);
			end
    RSI:setPrecision(precision);
  
    RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style1, instance.parameters.level_overboughtsold_width1, instance.parameters.level_overboughtsold_color1);
	RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style2, instance.parameters.level_overboughtsold_width2, instance.parameters.level_overboughtsold_color2);
	RSI:addLevel(50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	RSI:addLevel(100, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	RSI:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	

	Top=instance:addStream("Top", core.Line, name, "Top", core.rgb( 128, 128, 128), first);
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
    Bottom=instance:addStream("Bottom", core.Line, name, "Bottom", core.rgb( 128, 128, 128), first);
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
	Line1=instance:addStream("Line1", core.Line, name, "Bottom", core.rgb( 128, 128, 128), first);
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
	Line2=instance:addStream("Line2", core.Line, name, "Bottom", core.rgb( 128, 128, 128), first);
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
	
	Top:setStyle(core.LINE_NONE);
    Bottom:setStyle(core.LINE_NONE);
	
	Line1:setStyle(core.LINE_NONE);
    Line2:setStyle(core.LINE_NONE);
    
	Transparency= instance.parameters.Transparency;
	Transparency= 100-Transparency;
	
	instance:createChannelGroup("UpGroup","Cloud" , Top, Line1, instance.parameters.level_overboughtsold_color1, Transparency);
	instance:createChannelGroup("UpGroup","Cloud" , Bottom, Line2, instance.parameters.level_overboughtsold_color2, Transparency);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
  
	
    rsi:update(mode); 
	
	Top[period]=instance.parameters.overbought;
	Bottom[period]=instance.parameters.oversold;
	
	if period <first then
	return;
	end
	
	 if TF ~= "Chart" and  TF ~=  source:barSize()  then
	 local p =  Initialization(period) 
     
        if not p then
        return;
        end
		
		
			RSI[period]=rsi.DATA[p] ;
			
	 
	 else
	    
		
		 
			RSI[period]=rsi.DATA[period] ;
			
			
	 end		
	 
	 
	         Line1[period]=RSI[period];
			Line2[period]=RSI[period];
			
			if RSI[period] < instance.parameters.overbought then
			Top:setColor(period, background_color ); 
			else
			Top:setColor(period,instance.parameters.level_overboughtsold_color1 ); 
			end
			
			 if RSI[period] > instance.parameters.oversold then
			Bottom:setColor(period, background_color ); 
			else
			Bottom:setColor(period, instance.parameters.level_overboughtsold_color2 ); 
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


