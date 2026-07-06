-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58437
-- Id: 9578

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
    indicator:name("Heikin-Ashi Gradient Heatmap");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("TF1", "First time frame for heikin-ashi", "", "m15");
    indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);
    indicator.parameters:addString("TF2", "First time frame for heikin-ashi", "", "m30");
    indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);
    indicator.parameters:addString("TF3", "First time frame for heikin-ashi", "", "H1");
    indicator.parameters:setFlag("TF3", core.FLAG_PERIODS);
    indicator.parameters:addString("TF4", "First time frame for heikin-ashi", "", "H2");
    indicator.parameters:setFlag("TF4", core.FLAG_PERIODS);
    indicator.parameters:addString("TF5", "First time frame for heikin-ashi", "", "H4");
    indicator.parameters:setFlag("TF5", core.FLAG_PERIODS);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("colorU", "Up Color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("colorD", "Down Color", "", core.COLOR_DOWNCANDLE);
    indicator.parameters:addColor("colorN", "No Data Color", "", core.rgb(192, 192, 192));
end

local source = nil;                                                 -- indicator source
local h, l = nil;                                                   -- dummy output streams, are used solely to define boders of the output
local colorU, colorD, colorN;                                       -- colors to fill the heat map

local src = {};                                                     -- sources
local ha = {};                                                      -- autobuffers for HA applied on timeframes
local loading = {};                                                 -- loading flags per each source
local drawData = {};                                                -- draw output streams
local idx = {};                                                     -- streams of the index of the corresponding candle in source
local tf = {};                                                      -- timeframes
local tflen = {};                                                   -- length of the timeframes

local tds, tws;                                                     -- trading day and trading week params
local stf;                                                          -- timeframe of the source
 

-- initializes the instance of the indicator
function Prepare(onlyName)
    -- check time frames
    tflen[1] = check(instance.parameters.TF1);
    tflen[2] = check(instance.parameters.TF2);
    tflen[3] = check(instance.parameters.TF3);
    tflen[4] = check(instance.parameters.TF4);
    tflen[5] = check(instance.parameters.TF5);

    -- standard initialization routine
    source = instance.source;
    stf = source:barSize();
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    tds = core.host:execute("getTradingDayOffset");
    tws = core.host:execute("getTradingWeekOffset");

    -- create sources, HA indicator for each time frame
    create(instance.parameters.TF1, 1);
    create(instance.parameters.TF2, 2);
    create(instance.parameters.TF3, 3);
    create(instance.parameters.TF4, 4);
    create(instance.parameters.TF5, 5);

    -- remember colors
    colorU = instance.parameters.colorU;
    colorD = instance.parameters.colorD;
    colorN = instance.parameters.colorN;

    -- create dummy output streams
    h = instance:addStream("h", core.Line, name .. ".h", "h", colorU, first);
    h:setPrecision(math.max(2, instance.source:getPrecision()));
    l = instance:addStream("l", core.Line, name .. ".l", "l", colorD, first);
    l:setPrecision(math.max(2, instance.source:getPrecision()));
	drawData[1] = instance:addInternalStream(0, 0);
	drawData[2] = instance:addInternalStream(0, 0);
	drawData[3] = instance:addInternalStream(0, 0);
	drawData[4] = instance:addInternalStream(0, 0);
	drawData[5] = instance:addInternalStream(0, 0);
    h:setVisible(false);
    l:setVisible(false);

    -- and finally make the indicator owner-drawn
    instance:ownerDrawn(true);
end

-- checks whether the time frame chosen is the same or shorter than the source time frame
function check(tf)
    local s1, e1;
    s1, e1 = core.getcandle(instance.source:barSize(), 0, 0, 0);
    local s2, e2;
    s2, e2 = core.getcandle(tf, 0, 0, 0);

    assert(e1 - s1 <= e2 - s2, "Chosen timeframe must be the same or longer than the chart timeframe");
    return e2 - s2;
end

-- creates the source and indicator
function create(tf, id)
    check(tf);
	
        src[id] = core.host:execute("getSyncHistory", instance.source:instrument(), tf, instance.source:isBid(), 0, 200 + id, 100 + id);
        loading[id]=true;
		ha[id]=core.indicators:create("HA",src[id]);
end

local any_loading

-- update indicator values and make all appropriate calculations for further "Draw" operation
function Update(period)
    if period >= first then
        -- fill dummy sources
        h[period] = 80;
        l[period] = 0;
		
 
        if loading[1] or loading[2] or loading[3] or loading[4] or loading[5] then
            drawData[1][period] = 0;
            drawData[2][period] = 0;
            drawData[3][period] = 0;
            drawData[4][period] = 0;
            drawData[5][period] = 0;
        else
		
		
		  
			
            
        
            updateOne(1, period);
            updateOne(2, period);
            updateOne(3, period);
            updateOne(4, period);
            updateOne(5, period);
        end
    end
end

-- update and handle each HA indicator

 --updateOne(1, period, alive);
function updateOne(no,  period)

  ha[no]:update(core.UpdateLast);
  
  -- for i = 1, 5,1 do
 --       ha[i]:Update(core.UpdateLast);
  --  end 

    local _drawData = drawData[no];
    local _idx = idx[no];
    local _data = ha[no];
    local _src = src[no]
	
	 p= core.findDate(_src, source:date(period), false);

    -- otherwise update HA indicator

    if p < 0 then
	return;
	end
	
        -- fill the HA candle direction otherwise
        local v;
        if _data.close[p] >= _data.open[p] then
            v = 1;
        else
            v = -1;
        end
        _drawData[period] = v;
       
end
 
 
-- handle notifications that collections are started to be loaded (code 100+) or are finished to be loaded (code 200+)
function AsyncOperationFinished(cookie, success, message)
    if cookie == 101 then
        loading[1] = true;
    elseif cookie == 102 then
        loading[2] = true;
    elseif cookie == 103 then
        loading[3] = true;
    elseif cookie == 104 then
        loading[4] = true;
    elseif cookie == 105 then
        loading[5] = true;
    elseif cookie == 201 then
        loading[1] = false; 
    elseif cookie == 202 then
        loading[2] = false; 
    elseif cookie == 203 then
        loading[3] = false; 
    elseif cookie == 204 then
        loading[4] = false; 
    elseif cookie == 205 then
        loading[5] = false;     
    else
        return 0;
    end
	
	if not ( loading[1]
	or loading[2]
	or loading[3]
	or loading[4]
	or loading[5])	
	then
	instance:updateFrom(0);
	end
	
    return core.ASYNC_REDRAW;
end

-- draw the indicator
function Draw(stage, context)
    if stage == 1 then
        -- draw after prices and indicator contect

        -- calc Y axis values for all 5 lines
        local v, l80, l60, l40, l20, l0;
        v, l80 = context:pointOfPrice(80);
        v, l60 = context:pointOfPrice(60);
        v, l40 = context:pointOfPrice(40);
        v, l20 = context:pointOfPrice(20);
        v, l0 = context:pointOfPrice(0);

        -- clip the output to the chart area
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());

        -- and enumerate the candles visible on the chart
        context:startEnumeration();
        local prevIndex, prevX;
        prevIndex = nil;
        while true do
            local index, x, x1, x2, c1, c2 = context:nextBar();
            if index == nil then
                break;
            end

            -- start drawing from the second candle on the chart
            if prevIndex ~= nil then
                -- and draw four gradient boxes:
                -- TF1 to TF2
                drawOne(context, drawData[1], drawData[2], prevIndex, prevX, index, x, l80, l60);
                -- TF2 to TF3
                drawOne(context, drawData[2], drawData[3], prevIndex, prevX, index, x, l60, l40);
                -- TF3 to TF4
                drawOne(context, drawData[3], drawData[4], prevIndex, prevX, index, x, l40, l20);
                -- TF4 to TF5
                drawOne(context, drawData[4], drawData[5], prevIndex, prevX, index, x, l20, l0);
            end
            prevIndex = index;
            prevX = x;
        end
    end
end

-- draw one gradient box
function drawOne(context, data1, data2, prevIndex, prevX, index, x, upper, lower)
    -- A rectangle and color numeration refering to code below:
    -- Prev  Next
    -- bar   bar
    -- 1 --- 2      TF1
    -- |     |
    -- 3 --- 4      TF2
    --
    color1 = getColor(data1, prevIndex);
    color2 = getColor(data1, index);
    color3 = getColor(data2, prevIndex);
    color4 = getColor(data2, index);
    context:drawGradientRectangle(prevX, upper, color1, x, upper, color2, x, lower, color4, prevX, lower, color3);
end

-- get color by the pre-calculate data
function getColor(data, index)
    if index < data:first() or index >= data:size() or not data:hasData(index) or data[index] == 0 then
        return colorN;
    end

    if data[index] > 0 then
        return colorU;
    else
        return colorD;
    end
end