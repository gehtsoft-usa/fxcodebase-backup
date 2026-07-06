-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72730

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

function Init()
    indicator:name("FingerTrap indicator");
    indicator:description("FingerTrap indicator to review best ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Valid Trading conditions");
    indicator.parameters:addString("tfVTC", "Time frame", "", "H1");
    indicator.parameters:setFlag("tfVTC", core.FLAG_PERIODS);
    indicator.parameters:addInteger("lsVTC", "Live style", "", core.LINE_DASH);
    indicator.parameters:setFlag("lsVTC", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("lwVTC", "Line Width", "", 3, 1, 3);

    indicator.parameters:addInteger("nVTCfast", "Periods for fast EMA", "", 8, 5, 34);
    indicator.parameters:addColor("lcVTCfast", "Color of fast EMA", "", core.rgb(82, 165, 165));

    indicator.parameters:addInteger("nVTCslow", "Periods for slow EMA", "", 34, 5, 144);
    indicator.parameters:addColor("lcVTCslow", "Color of slow EMA", "", core.rgb(223, 0, 0));

    indicator.parameters:addGroup("Trade Entry indicator");
    indicator.parameters:addInteger("nTEfast", "Periods for fast EMA for Trade Entry", "", 8, 5, 34);
    indicator.parameters:addInteger("lsTEfast", "Trade Entry Fast EMA Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("lsTEfast", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("lwTEfast", "Trade Entry Fast EMA Line Width", "", 3, 1, 3);
    indicator.parameters:addColor("lcTEfast", "Trade Entry Fast EMA Color", "", core.rgb(0, 128, 255));

    indicator.parameters:addInteger("nTEslow", "Periods for slow EMA for Trade Entry", "", 34, 5, 34);
    indicator.parameters:addInteger("lsTEslow", "Trade Entry Slow EMA Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("lsTEslow", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("lwTEslow", "Trade Entry Slow EMA Line Width", "", 2, 1, 3);
    indicator.parameters:addColor("lcTEslow", "Trade Entry EMA Slow Color", "", core.rgb(255, 128, 0));

    indicator.parameters:addInteger("nTEmva", "Periods for MVA for Trade Entry", "", 200, 100, 300);
    indicator.parameters:addInteger("lsTEmva", "Trade Entry Fast EMA Style", "", core.LINE_DASHDOT );
    indicator.parameters:setFlag("lsTEmva", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("lwTEmva", "Trade Entry Fast EMA Line Width", "", 3, 1, 3);
    indicator.parameters:addColor("lcTEmva", "Trade Entry Fast EMA Color", "", core.rgb(128, 128, 128));

    indicator.parameters:addGroup("Bias Indication");
    indicator.parameters:addDouble("biasSize", "Bias indication size", "", 3, 1, 50);
    indicator.parameters:addColor("biasLong", "Bias long Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("biasShort", "Bias short Color", "", core.rgb(255, 0, 0));

    indicator.parameters:addGroup("Trades");
    indicator.parameters:addDouble("ArrowSize", "ArrowSize", "", 25, 5, 50);
    indicator.parameters:addColor("UP", "Up color", "Up color", core.rgb(128, 255, 255));
    indicator.parameters:addColor("DOWN", "Down color", "Down color", core.rgb(255, 0, 128));
    indicator.parameters:addColor("CLS", "Close color", "Close color", core.rgb(0, 0, 0));

    indicator.parameters:addGroup("Trade Parameters");
    indicator.parameters:addDouble("trailStopPips", "Trailing Stop Pips", "", 25, 5, 50);
end

local streamVTCf, streamVTCs;
local indVTCfast, indVTCslow -- indicator for trading condition
local indTEslow, indTEfast, indTEmva; -- indicator for trade entry
local indTElong, dotTElong, nLong;
local indTEshort, dotTEshort, nshort;
local lineVTCfast, lineVTCslow, lineTEfast, lineTEslow, lineTEmva;
local sigUp, sigDn, sigCl, sigCurr;

local source;
local day_offset, week_offset; 
local host;
local alive;
local first;

local loading={};
local TF={};
local SourceData={};

function Prepare()
    local name;
    name = profile:id() .. "(" .. instance.source:name() .. 
			" - Entry:" .. instance.parameters.nTEfast .. "/" .. instance.parameters.nTEslow .. "/" .. instance.parameters.nTEmva .. 
			" (Valid:" .. instance.parameters.nVTCfast .. "/" .. instance.parameters.nVTCslow  .. "-" .. instance.parameters.tfVTC .. ")";
    instance:name(name);

    source = instance.source;
    host = core.host;
	first= source:first();

    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    alive = source:isAlive();

    local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(instance.parameters.tfVTC, core.now(), 0, 0);

    assert ((e - s) <= (e1 - s1), "Valid Trading condition time frame must be bigger than the chart entry frame!");

 

    indTEfast = core.indicators:create("EMA", source.close, instance.parameters.nTEfast);
    indTEslow = core.indicators:create("EMA", source.close, instance.parameters.nTEslow);
    indTEmva = core.indicators:create("MVA", source.close, instance.parameters.nTEmva);

    
	TF[1]=instance.parameters.tfVTC;
	  
	SourceData[1] = core.host:execute("getSyncHistory", source:instrument(),  TF[1], source:isBid(), math.min(300,first), 100, 101);
	loading[1]=true;
	
    indVTCfast = core.indicators:create("EMA", SourceData[1].close, instance.parameters.nVTCfast); 
    indVTCslow = core.indicators:create("EMA", SourceData[1].close, instance.parameters.nVTCslow);


    lineTEfast = instance:addStream("emaTEfast", core.Line, name .. ".EMAtradeF", "EMA fast TE",instance.parameters.lcTEfast, 0, 0);
    lineTEfast:setWidth(instance.parameters.lwTEfast);
    lineTEfast:setStyle(instance.parameters.lsTEfast);

    lineTEslow = instance:addStream("emaTEslow", core.Line, name .. ".EMAtradeS", "EMA slow TE",instance.parameters.lcTEslow, 0, 0);
    lineTEslow:setWidth(instance.parameters.lwTEslow);
    lineTEslow:setStyle(instance.parameters.lsTEslow);

    lineTEmva = instance:addStream("mvaTE200", core.Line, name .. ".MVAtrade", "MVA TE",instance.parameters.lcTEmva, 0, 0);
    lineTEmva:setWidth(instance.parameters.lwTEmva);
    lineTEmva:setStyle(instance.parameters.lsTEmva);

    dotTEshort = instance:addStream("dotTEshort", core.Dot, name .. ".short", "TE short", instance.parameters.biasShort, 0, 0);
	dotTEshort:setWidth(instance.parameters.biasSize);
    dotTElong = instance:addStream("dotTElong", core.Dot, name .. ".long", "TE long", instance.parameters.biasLong, 0, 0);
	dotTElong:setWidth(instance.parameters.biasSize);

    lineVTCfast = instance:addStream("emaVTCfast", core.Line, name .. ".EMAfastV", "EMA fast VT", instance.parameters.lcVTCfast, 0, 0);
    lineVTCfast:setWidth(instance.parameters.lwVTC);
    lineVTCfast:setStyle(instance.parameters.lsVTC);

    lineVTCslow = instance:addStream("emaVTCslow", core.Line, name .. ".EMAslowV", "EMA slow VT", instance.parameters.lcVTCslow, 0, 0);
    lineVTCslow:setWidth(instance.parameters.lwVTC);
    lineVTCslow:setStyle(instance.parameters.lsVTC);

    sigUp = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.UP, 0);
    sigDn = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.DOWN, 0);
    sigCl = instance:createTextOutput ("Cl", "Cl", "Wingdings", instance.parameters.ArrowSize, core.H_Center, core.V_Top, instance.parameters.CLS, 0);
    sigCurr = 0;

end

function   getPeriod(id, period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), day_offset, week_offset);

  
    if loading[id] or SourceData[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

function Update(period, mode)

    -- wait for main chart data to be received
    if period <  first or not source:hasData(period) then
        return;
	end

    indTEfast:update(mode);
    if indTEfast.DATA:hasData(period) then
        lineTEfast[period] = indTEfast.DATA[period];
 
    end

    indTEslow:update(mode);
    if indTEslow.DATA:hasData(period) then
        lineTEslow[period] = indTEslow.DATA[period];
 
    end

    indTEmva:update(mode);
    if indTEmva.DATA:hasData(period) then
        lineTEmva[period] = indTEmva.DATA[period];
    end
 

   
    indVTCfast:update(mode);
    indVTCslow:update(mode);
 	
		
    local p = getPeriod(1, period);
	
    if p == false
    or p<= indVTCfast.DATA:first()  	
    or p<= indVTCslow.DATA:first() 		
	then
	return;
	end

		
        if indVTCfast.DATA:hasData(p) then
            lineVTCfast[period] = indVTCfast.DATA[p];
 
        end

        if indVTCslow.DATA:hasData(p) then
            lineVTCslow[period] = indVTCslow.DATA[p];
 
        end

		dotTEshort[period] = 0;
		dotTElong[period] = 0;
        if indTEfast.DATA:hasData(p) and indTEslow.DATA:hasData(p) and indVTCfast.DATA:hasData(p) and indVTCslow.DATA:hasData(p) then
			if	lineVTCslow[period-2] < lineVTCfast[period-2] 
			and lineTEmva[period-2] < lineTEfast[period-2] and lineTEslow[period-2] < lineTEfast[period-2]
			then
				dotTElong[period] = lineTEslow[period];
			elseif	lineVTCslow[period-2] > lineVTCfast[period-2] 
				and lineTEmva[period-2] > lineTEfast[period-2] and lineTEslow[period-2] > lineTEfast[period-2] 
			then
				dotTEshort[period] = lineTEslow[period];
            end
        end

        -- Check for signal trigger
        if indTEfast.DATA:hasData(p) and indTEslow.DATA:hasData(p) and indVTCfast.DATA:hasData(p) and indVTCslow.DATA:hasData(p) then
			if sigCurr <= 0 
				and lineVTCslow[period-2] < lineVTCfast[period-2] 
				and lineTEmva[period-2] < lineTEfast[period-2] and lineTEslow[period-2] < lineTEfast[period-2] 
				and lineTEfast[period-2] < source.close[period-1] and source.open[period-1] < source.close[period-1] 
				and source.low[period-1] - instance.parameters.trailStopPips < lineTEfast[period-2]
			then
				sigCurr = 1;
				sigUp:set(period, lineTEslow[period], "\225"); 
			elseif sigCurr >= 0 
				and lineVTCslow[period-2] > lineVTCfast[period-2] 
				and lineTEmva[period-2] > lineTEfast[period-2] and lineTEslow[period-2] > lineTEfast[period-2] 
		 		and lineTEfast[period-2] > source.close[period-1] and source.open[period-1] > source.close[period-1] 
				and source.low[period-1] + instance.parameters.trailStopPips > lineTEfast[period-2]
			then
				sigCurr = -1;
				sigDn:set(period, lineTEslow[period], "\226"); 
            end
        end
 
   
   
end
 
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading[1] = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading[1] = true;
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