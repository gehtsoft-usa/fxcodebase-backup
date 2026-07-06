
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4906

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("Two Instrument Stochastic")
	indicator:description("Two Instrument Stochastic")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	Parameters(1, "EUR/USD")
	Parameters(2, "USD/JPY")
 
    indicator.parameters:addGroup("Style");
	
	indicator.parameters:addString("Method", "Method", "Method" , "Arrows");
    indicator.parameters:addStringAlternative("Method", "Arrows", "Arrows" , "Arrows");
    indicator.parameters:addStringAlternative("Method", "Dots", "Dots" , "Dots");
	
	indicator.parameters:addBoolean("Inverse", "Inverse","", false);
     indicator.parameters:addInteger("Size", "Arrow Size","", 15); 
    indicator.parameters:addColor("clrUP", "Up Color","", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", "Down Color","", core.COLOR_DOWNCANDLE);
end
 

function Parameters(id, Instrument)
	indicator.parameters:addGroup(id .. ". Instrument")

	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument)
	indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS)

	indicator.parameters:addInteger("K" .. id, "Number of periods for %K", "", 5, 2, 1000)
	indicator.parameters:addInteger("SD" .. id, "%D slowing periods", "", 3, 2, 1000)
	indicator.parameters:addInteger("D" .. id, "The number of periods for %D.", "", 3, 2, 1000)

	indicator.parameters:addString("KS" .. id, "Smoothing type for %K", "", "MVA")
	indicator.parameters:addStringAlternative("KS" .. id, "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("KS" .. id, "EMA", "", "EMA")
	indicator.parameters:addStringAlternative("KS" .. id, "MT4", "", "FS")

	indicator.parameters:addString("DS" .. id, "Smoothing type for %D", "", "MVA")
	indicator.parameters:addStringAlternative("DS" .. id, "MVA", "", "MVA")
	indicator.parameters:addStringAlternative("DS" .. id, "EMA", "", "EMA")
end


local Method;


local Number = 2
local K = {}
local SD = {}
local D = {}
local KS = {}
local DS = {}
 
local source
local Indicator = {}
local Instrument = {}
local first
local loading = {}
local offset, weekoffset
local SourceData = {}

local up, down;
local clrUP,clrDN, Size;
local Inverse;
local out={};
function Prepare(nameOnly)
	source = instance.source
	first = source:first()
	offset = core.host:execute("getTradingDayOffset")
	weekoffset = core.host:execute("getTradingWeekOffset")
	
	clrUP= instance.parameters.clrUP;
	clrDN= instance.parameters.clrDN;
	Size= instance.parameters.Size;
	Inverse= instance.parameters.Inverse;
	Method= instance.parameters.Method;

	local name = profile:id()

	local i

	for i = 1, 2, 1 do
		Instrument[i] = instance.parameters:getString("Instrument" .. i)
		K[i] = instance.parameters:getInteger("K" .. i)
		SD[i] = instance.parameters:getInteger("SD" .. i)
		D[i] = instance.parameters:getInteger("D" .. i)
		KS[i] = instance.parameters:getString("KS" .. i)
		DS[i] = instance.parameters:getString("DS" .. i)



		name =
			name ..
			", (" .. Instrument[i] .. ", " .. K[i] .. ", " .. SD[i] .. ", " .. D[i] .. ", " .. KS[i] .. ", " .. DS[i] .. " )"
	end

	instance:name(name)
	if nameOnly then
		return;
	end

	for i = 1, 2, 1 do
		Test = core.indicators:create("STOCHASTIC", source.close, K[i], SD[i], D[i], KS[i], DS[i])

		first = Test.DATA:first()

		SourceData[i] =
			core.host:execute(
			"getSyncHistory",
			Instrument[i],
			source:barSize(),
			source:isBid(),
			math.min(first * 2, 300),
			200 + i,
			100 + i
		)
		Indicator[i] = core.indicators:create("STOCHASTIC", SourceData[i], K[i], SD[i], D[i], KS[i], DS[i])
		loading[i] = true
		
		out[i]= instance:addInternalStream(0, 0);

	end
	
	 up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top,  clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom,  clrDN, 0);

 end

function Update(period, mode)

    
	for i = 1, 2, 1 do
		Calculation(i, period, mode)
	end
	
	
	if Method == "Arrows" then
	UpSign="\217";
	DnSign="\218";
	else
	UpSign="\108";
	DnSign="\108";
	end
	
	
	
	up:setNoData(period );
	down:setNoData(period );
	
	if out[1][period]> out[2][period] 
	and out[1][period-1]<= out[2][period-1]
	then
	
	
		if Inverse then
		down:set(period, source.low[period], DnSign, source.low[period ]);
		else	
		up:set(period , source.high[period  ], UpSign, source.high[period  ]);
		end
		
	
	elseif out[1][period]< out[2][period]
	and out[1][period-1]>= out[2][period-1]
	then
		
		if Inverse then		
		up:set(period , source.high[period  ], UpSign, source.high[period  ]);
		else	
		down:set(period, source.low[period], DnSign, source.low[period ]);
		end
	end
	
end

function Calculation(id, period, mode)
	Indicator[id]:update(mode)

	local p = Initialization(period, id)

	if not p then
		return
	end

	out[id][period] = Indicator[id].DATA[p]
end

function Initialization(period, id)
	local Candle
	Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset)

	if loading[id] or SourceData[id]:size() == 0 then
		return false
	end

	if period < source:first() then
		return false
	end

	local P = core.findDate(SourceData[id], Candle, false)

	-- candle is not found
	if P < 0 then
		return false
	else
		return P
	end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	local j
	local Flag = true
	local Count = 0

	for j = 1, Number, 1 do
		if cookie == (100 + j) then
			loading[j] = true
		elseif cookie == (200 + j) then
			loading[j] = false
		end

		if loading[j] then
			Count = Count + 1
			Flag = false
		end
	end

	if Flag then
		core.host:execute("setStatus", " ")
		instance:updateFrom(0)
	else
		core.host:execute("setStatus", " Loading " .. (Number - Count) .. "/" .. Number)
	end

	return core.ASYNC_REDRAW
end
