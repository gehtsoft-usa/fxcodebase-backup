-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=883
-- Id: 534

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Sample Day-based oscillator");
    indicator:description("Developed exclusively to show on how to use the Day as the base of the custom indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addString("Mode", "The Indicator Mode", "", "P");
    indicator.parameters:addStringAlternative("Mode", "Net Change", "", "N");
    indicator.parameters:addStringAlternative("Mode", "Percent Change", "", "P");
	
	indicator.parameters:addBoolean("Show", "Show Levels", "", false);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color", "Color of the oscillator line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	
	
	
	
	indicator.parameters:addGroup("Levels");	
	indicator.parameters:addDouble("level1","1. Level","", 0);
	indicator.parameters:addColor("color1", "1. Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width1","1. Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style1", "1. Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addDouble("level2","2. Level","", 0.25);
	indicator.parameters:addColor("color2", "2. Line Color","", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("width2","2. Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style2", "2. Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addDouble("level3","3. Level","", 0.5);
	indicator.parameters:addColor("color3", "3. Line Color","", core.rgb(0, 128, 255));
    indicator.parameters:addInteger("width3","3. Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style3", "3. Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addDouble("level4","4. Level","", 0.75);
	indicator.parameters:addColor("color4", "4. Line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width4","4. Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style4", "4. Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addDouble("level5","5. Level","", 1);
	indicator.parameters:addColor("color5", "5. Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width5","5. Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style5", "5. Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addDouble("level6","6. Level","", 1.25);
	indicator.parameters:addColor("color6", "6. Line Color","", core.rgb(255, 128, 64));
    indicator.parameters:addInteger("width6","6. Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style6", "6. Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addDouble("level7","7. Level","", 1.5);
	indicator.parameters:addColor("color7", "7. Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width7","7. Line width","", 1, 1, 5);
    indicator.parameters:addInteger("style7", "7. Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style7", core.FLAG_LEVEL_STYLE);
	
end

local source;
local Source;
local TF="D1";
local loading;
local host;
local dayoffset;
local weekoffset;
local Mode;
local Show;
-- Day results
local O;            -- open
local OUT = nil;

function Prepare(nameOnly)
    InitDay();

    Mode = instance.parameters.Mode;
	Show = instance.parameters.Show;

    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. Mode .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    OUT = instance:addStream("O", core.Line, name .. ".O", "O", instance.parameters.color, 0);
    OUT:setPrecision(math.max(2, instance.source:getPrecision()));
	OUT:setWidth(instance.parameters.width);
    OUT:setStyle(instance.parameters.style);
	
	if Show then
	OUT:addLevel(instance.parameters.level1, instance.parameters.style1, instance.parameters.width1, instance.parameters.color1);
    OUT:addLevel(-(instance.parameters.level1), instance.parameters.style1, instance.parameters.width1, instance.parameters.color1);
	
	OUT:addLevel(instance.parameters.level2, instance.parameters.style2, instance.parameters.width2, instance.parameters.color2);
    OUT:addLevel(-(instance.parameters.level2), instance.parameters.style2, instance.parameters.width2, instance.parameters.color2);
	
	OUT:addLevel(instance.parameters.level3, instance.parameters.style3, instance.parameters.width3, instance.parameters.color3);
    OUT:addLevel(-(instance.parameters.level3), instance.parameters.style3, instance.parameters.width3, instance.parameters.color3);
	
	
	OUT:addLevel(instance.parameters.level4, instance.parameters.style4, instance.parameters.width4, instance.parameters.color4);
    OUT:addLevel(-(instance.parameters.level4), instance.parameters.style4, instance.parameters.width4, instance.parameters.color4);
	
	OUT:addLevel(instance.parameters.level5, instance.parameters.style5, instance.parameters.width5, instance.parameters.color5);
    OUT:addLevel(-(instance.parameters.level5), instance.parameters.style5, instance.parameters.width5, instance.parameters.color5);
	
	OUT:addLevel(instance.parameters.level6, instance.parameters.style6, instance.parameters.width6, instance.parameters.color6);
    OUT:addLevel(-(instance.parameters.level6), instance.parameters.style6, instance.parameters.width6, instance.parameters.color6);
	
	OUT:addLevel(instance.parameters.level7, instance.parameters.style7, instance.parameters.width7, instance.parameters.color7);
    OUT:addLevel(-(instance.parameters.level7), instance.parameters.style7, instance.parameters.width7, instance.parameters.color7);
	end
	
	
    Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
	loading=true;
end



function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


function Update(period )

     local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		
   
    if Mode == "P" then
        OUT[period] = (source.close[period] - Source.open[p]) / Source.open[p] * 100;
    else
        OUT[period] = (source.close[period] - Source.open[p]) / source:pipSize();
    end
end

function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end

function InitDay()
    host = core.host;
    dayoffset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");

    source = instance.source;
        -- validate
    local l1, l2;
    local s, e;

    s, e = core.getcandle(source:barSize(), core.now(), 0);
    l1 = e - s;
    s, e = core.getcandle(TF, core.now(), 0);
    l2 = e - s;
    assert(l1 <= l2, "The source frame must be shorter or equal to the day timeframe");


end

