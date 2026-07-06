function Init()
    indicator:name("P&F with Pattern on Chart indicator V1.1");
    indicator:description("Point & Figure indicator V1.1");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Type", "Box Size Calculation Method", "" , "Pips");
	indicator.parameters:addStringAlternative("Type", "ATR", "" , "ATR");
    indicator.parameters:addStringAlternative("Type", "Percentage", "" , "Percentage");
    indicator.parameters:addStringAlternative("Type", "Pips", "" , "Pips");

    indicator.parameters:addInteger("BS", "Box Size (in pips)", "", 5, 1, 100000);
	indicator.parameters:addDouble("Percentage", "Box Size (Percentage)", "", 0.2, 0.1 , 20);
    indicator.parameters:addInteger("RS", "Reversal Count (in boxes)", "", 3, 1, 100);
    indicator.parameters:addInteger("ATRFrame", "ATR Period", "", 14, 2, 1000);	
	indicator.parameters:addDouble("Multiplier", "ATR Multiplier", "", 1, 0.1 , 100);
	 
	indicator.parameters:addBoolean("Ignore", "Ignore High/Low", "" ,  false);

    indicator.parameters:addGroup("Signals");
    indicator.parameters:addBoolean("Double", "Double Top Bottom", "Show Double Top Bottom Breakout Pattern" ,  true);
    indicator.parameters:addInteger("DBC", "Double Breakout Box", "", 1, 1, 100000);
    indicator.parameters:addBoolean("Triple", "Triple Top Bottom", "Show Triple Top Bottom Breakout Pattern" ,  true);
    indicator.parameters:addInteger("TBC", "Triple Breakout Box", "", 1, 1, 100000);
    indicator.parameters:addBoolean("STriple", "Spread Triple Top Bottom", "Show Spread Triple Top Bottom Breakout Pattern" ,  true);
    indicator.parameters:addInteger("STBC", "Spread Triple Breakout Box", "", 1, 1, 100000);
    indicator.parameters:addBoolean("Quad", "Quadruple Top Bottom", "Show Quadruple Top Bottom Breakout Pattern" ,  true);
    indicator.parameters:addInteger("QBC", "Quadruple Breakout Box", "", 1, 1, 100000);
    indicator.parameters:addBoolean("ADTriple", "A/D Triple Top Bottom", "Show Ascending/Descending Triple Top Bottom Breakout Pattern" ,  true);
    indicator.parameters:addInteger("ADTBC", "A/D Triple Breakout Box", "", 1, 1, 100000);

	indicator.parameters:addGroup("Debugging");
	indicator.parameters:addBoolean("Debug", "Show Debug on Screen", "" ,  true);
	
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Bull", "Color of Bull", "", core.rgb( 0, 0, 255));
	indicator.parameters:addColor("Bear", "Color of Bear", "", core.rgb( 255, 255, 0));
    indicator.parameters:addColor("TXT",  "Color of TXT", "", core.rgb( 0, 255, 128));
	
end

local point = nil;
local first;
local BS, RS;
local Percentage;
local ATRFrame;
local ATR;
local Ignore;
local Multiplier;
local source_low,source_high;
local Type;
local source = nil;
local i;
local Debug;
local open = nil;
local high = nil;
local low = nil;
local close = nil;
local volume = nil;

local TEST=true;
local lineCount = 0;

local Support;
local Resistance;

local Up={};
local Down={};

-- Signals -------------------
local Triple;
local STriple;
local Double;
local Quad;
local ADTriple;
local DBC;
local TBC;
local STBC;
local QBC;
local ADTBC;
local SigTXT;
-- Style ---------------------
local Bull;
local Bear;
local Transparency;

local sF;

local initFirst = true;

-- New Code
local pf 		= {close={},open={},period=0,swing=nil,flag=nil,update=false,move=false};
local lastPeriod = 0;

function Prepare()
    point           = instance.source:pipSize();
    source          = instance.source;
    first           = source:first()+2;

    Type            = instance.parameters.Type;
    BS              = instance.parameters.BS;
    Percentage      = instance.parameters.Percentage;
	RS              = instance.parameters.RS;
    ATRFrame        = instance.parameters.ATRFrame;
    Multiplier      = instance.parameters.Multiplier;
    Ignore          = instance.parameters.Ignore;
    Triple          = instance.parameters.Triple;
    STriple         = instance.parameters.STriple;
    DBC             = instance.parameters.DBC;
    TBC             = instance.parameters.TBC;
    STBC            = instance.parameters.STBC;
    Double          = instance.parameters.Double;
    Quad            = instance.parameters.Quad;
    QBC             = instance.parameters.QBC;
    ADTriple        = instance.parameters.ADTriple;
    ADTBC           = instance.parameters.ADTBC;
    Bull = instance.parameters.Bull;
    Bear = instance.parameters.Bear;
	Debug 			= instance.parameters.Debug;
    initFirst = true;
    lineCount = 0;
	
	
	pf.period = 0;
	
	
    local name;
    if Type == "Pips" then
        name    =  profile:id() .. "(" .. source:name() .. ", " .. BS ..", " ..RS..", "..Type;
	elseif Type == "Percentage" then
        name    =  profile:id() .. "(" .. source:name() .. ", " .. Percentage ..", " ..RS..", "..Type;
	else
        name    = profile:id() .. "(" .. source:name() .. ", " .. ATRFrame ..", " ..RS..", "..Type..  ", " .. Multiplier;
        ATR     = core.indicators:create("ATR", source, ATRFrame);
        first   = ATR.DATA:first();
	end
    if Double then
        name    = name .. ", Double=ON";
    end
    if Triple then
        name    = name .. ", Triple=ON";
    end
    if STriple then
        name    = name .. ", SpreadTriple=ON";
    end
    if Quad then
        name    = name .. ", Quadruple=ON";
    end
    if ADTriple then
        name    = name .. ", ADTriple=ON";
    end
        name    = name .. ")";
    instance:name(name);

    TEST=true;

    dummy = instance:addStream("dummy", core.Line, name, "", core.rgb(0, 128, 255), first)
    Support = instance:addStream("Bull", core.Line, name .. ".Bull", "Bull", Bull, first)
    Resistance = instance:addStream("Bear", core.Line, name .. ".Bear", "Bear", Bear, first)
    if Ignore then
        source_low=source.close;
        source_high=source.close;
	else
        source_low=source.low;
        source_high=source.high;
	end
    core.host:execute ("removeAll");

    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
	volume = instance:addStream("volume", core.Line, name, "volume", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("", "Point & Figure", open, high, low, close, volume);

    Up["Triple"]    = instance:addStream("UpTriple", core.Bar,     name, "", core.rgb(0, 255, 0), first);
    Down["Triple"]  = instance:addStream("DownTriple", core.Bar,   name, "", core.rgb(0, 255, 0), first);	
    instance:createFromToBarGroup ("", "TripleSignal", Up["Triple"], Down["Triple"], Bull);
    Up["STriple"]    = instance:addStream("UpSTriple", core.Bar,   name, "", core.rgb(0, 255, 0), first);
    Down["STriple"]  = instance:addStream("DownSTriple", core.Bar, name, "", core.rgb(0, 255, 0), first);	
    instance:createFromToBarGroup ("", "STripleSignal", Up["STriple"], Down["STriple"], Bull);
    Up["Double"]    = instance:addStream("UpDouble", core.Bar,     name, "", core.rgb(0, 255, 0), first);
    Down["Double"]  = instance:addStream("DownDouble", core.Bar,   name, "", core.rgb(0, 255, 0), first);	
    instance:createFromToBarGroup ("", "DoubleSignal", Up["Double"], Down["Double"], Bull);
    Up["Quad"]    = instance:addStream("UpQuad", core.Bar,     name, "", core.rgb(0, 255, 0), first);
    Down["Quad"]  = instance:addStream("DownQuad", core.Bar,   name, "", core.rgb(0, 255, 0), first);	
    instance:createFromToBarGroup ("", "QuadSignal", Up["Quad"], Down["Quad"], Bull);
    Up["ADTriple"]    = instance:addStream("UpADTriple", core.Bar,     name, "", core.rgb(0, 255, 0), first);
    Down["ADTriple"]  = instance:addStream("DownADTriple", core.Bar,   name, "", core.rgb(0, 255, 0), first);	
    instance:createFromToBarGroup ("", "ADTripleSignal", Up["ADTriple"], Down["ADTriple"], Bull);

    SigTXT = instance:createTextOutput("Sig", "Sig", "Consolas", 10, core.H_Center, core.V_Center, instance.parameters.TXT, 5);

    sF 		= core.host:execute("createFont","Consolas",10,false,false);
end
function ReleaseInstance()
    core.host:execute("deleteFont", sF);
end

function Update(period, mode)
	if period < first then
		return;
	end
    if TEST and Type ~= "ATR" then
        TEST = false;
        if Type=="Percentage" then
            BS=((source.close[period]/point)/100)*Percentage;
		end
    end

    if Type == "ATR" and TEST  then
        ATR:update(mode);
        if not ATR.DATA:hasData(period) then
            return;
		end
        TEST = false;
        BS= (ATR.DATA[period]*Multiplier)/point;
    end
	-- New Code ----------------------------------------------------------------------------------------------
	if (period==source:size()-1) and period >= first+3 then
		if initFirst then
			-- first load or when extend History
			pf.period = 0;
			for i=first+1,period,1 do
				if pf.period == 0 then
					pf.period = 1;
					pf.close[pf.period] = round(source.open[i],BS);
					pf.open[pf.period] 	= round(source.open[i],BS);
					if pf.open[pf.period] < source.close[i] then
						pf.swing = "Up";
						pf.flag  = "Up";
					else
						pf.swing = "Down";
						pf.flag  = "Down";
					end
				else
					pf.flag="Nothing";
					if 		source.close[i] > pf.close[pf.period] + BS*point then
						pf.flag = "Up";
						if pf.swing == "Up" then
							while source_high[i] >= pf.close[pf.period] + BS*point do
								pf.close[pf.period] = pf.close[pf.period] + BS*point;
							end
						end
					elseif 	source.close[i] < pf.close[pf.period] - BS*point  then
						pf.flag = "Down";
						if pf.swing == "Down" then
							while source_low[i] <= pf.close[pf.period] - BS*point do
								pf.close[pf.period] = pf.close[pf.period] - BS*point;
							end
						end
					end
					if  pf.swing == "Up" and  pf.flag == "Down" and source_low[i] <= pf.close[pf.period] - BS*point*RS then
						pf.period = pf.period + 1;
						pf.swing = "Down";
						pf.open[pf.period] 	= pf.close[pf.period-1] - BS*point;
						pf.close[pf.period] = pf.close[pf.period-1] - BS*point*RS;
					elseif  pf.swing == "Down" and  pf.flag == "Up" and source_high[i] >= pf.close[pf.period] + BS*point*RS then
						pf.period = pf.period + 1;
						pf.swing = "Up";
						pf.open[pf.period] 	= pf.close[pf.period-1] + BS*point;
						pf.close[pf.period] = pf.close[pf.period-1] + BS*point*RS;
					end
				end
			end
			pf.update=true;
			initFirst = false;
		else
			-- history loaded update by realtime data.
			pf.flag="Nothing";
			if 		source.close[period] > pf.close[pf.period] + BS*point then
				pf.flag = "Up";
				if pf.swing == "Up" then
					while source_high[period] >= pf.close[pf.period] + BS*point do
						pf.close[pf.period] = pf.close[pf.period] + BS*point;
						pf.update=true;
					end
				end
			elseif 	source.close[period] < pf.close[pf.period] - BS*point  then
				pf.flag = "Down";
				if pf.swing == "Down" then
					while source_low[period] <= pf.close[pf.period] - BS*point do
						pf.close[pf.period] = pf.close[pf.period] - BS*point;
						pf.update=true;
					end
				end
			end
			if  pf.swing == "Up" and  pf.flag == "Down" and source.close[period] <= pf.close[pf.period] - BS*point*RS then
				pf.period = pf.period + 1;
				pf.swing = "Down";
				pf.open[pf.period] 	= pf.close[pf.period-1] - BS*point;
				pf.close[pf.period] = pf.close[pf.period-1] - BS*point*RS;
				pf.update=true;
			elseif  pf.swing == "Down" and  pf.flag == "Up" and source.close[period] >= pf.close[pf.period] + BS*point*RS then
				pf.period = pf.period + 1;
				pf.swing = "Up";
				pf.open[pf.period] 	= pf.close[pf.period-1] + BS*point;
				pf.close[pf.period] = pf.close[pf.period-1] + BS*point*RS;
				pf.update=true;
			end
			drawDebug(period);
		end
		if (period~=lastPeriod) then -- new Bar on SourceStream update the Candle
			pf.update = true;
			lastPeriod = period;
		end
		if pf.update then
			updatePF(period);
			updateSignal(period);
			pf.update = false;
			return;
		else
			return;
		end
	else
		initFirst = true;
	end
end
function drawDebug(i)
	if not Debug then return; end
			-- For Debugging 
            local PFClose = pf.close[pf.period];
            local dates = source:date(i);
            local x = core.host:execute("convertTime",core.TZ_LOCAL,core.TZ_EST,dates);
            local diff = core.dateToTable(x);
            local TXTs = "";
			if Type == "Pips" then
				TXTs = TXTs ..  " Settings      : " .. source:name() .. ", " .. BS ..", " .. RS .. ", " .. Type ..  "\n";
			elseif Type == "Percentage" then
				TXTs = TXTs ..  " Settings      : " .. source:name() .. ", " .. Percentage .. ", " .. RS .. ", ".. Type ..  "\n";
			else
				TXTs = TXTs ..  " Settings      : " .. source:name() .. ", " .. ATRFrame ..", " .. RS .. ", ".. Type ..  ", " .. Multiplier ..  "\n";
			end
            if pf.swing == "Up" then
				local rows = string.format("%.0f",(PFClose - pf.open[pf.period])/point/BS+1);
                TXTs = TXTs ..  " Column has    : " .. rows .. " of Xs" .. "\n" .. 
                                " Flag          : " .. pf.flag  .. "\n" .. 
                                " Column Close  : " .. string.format("%." .. source:getPrecision()-1 .. "f",PFClose) ..  "\n" ..
								" Next UP       : " .. string.format("%." .. source:getPrecision()-1 .. "f",PFClose + BS*point) ..    " Pips to Next : " .. string.format("%.1f",((PFClose + BS*point) - source.close[i])/point) .. "\n" ..
                                " Next RevDown  : " .. string.format("%." .. source:getPrecision()-1 .. "f",PFClose - BS*point*RS) .. " Pips to Next : " .. string.format("%.1f",(source.close[i] - (PFClose - BS*point*RS))/point) .. "\n";
            end
            if pf.swing == "Down" then
				local rows = string.format("%.0f",(pf.open[pf.period] - PFClose)/point/BS+1);
                TXTs = TXTs ..  " Column has    : " .. rows .. " of Os" .. "\n" .. 
                                " Flag          : " .. pf.flag  .. "\n" .. 
                                " Column Close  : " .. string.format("%." .. source:getPrecision()-1 .. "f",PFClose) ..  "\n" ..
								" Next DN       : " .. string.format("%." .. source:getPrecision()-1 .. "f",PFClose - BS*point) ..    " Pips to Next : " .. string.format("%.1f",(source.close[i] - (PFClose - BS*point))/point) .. "\n" ..
                                " Next RevUp    : " .. string.format("%." .. source:getPrecision()-1 .. "f",PFClose + BS*point*RS) .. " Pips to Next : " .. string.format("%.1f",((PFClose + BS*point*RS) - source.close[i])/point) .. "\n";
            end
                TXTs = TXTs ..  " Source Low    : " .. string.format("%." .. source:getPrecision() .. "f",source_low[i])  ..   "\n" ..
                                " Source High   : " .. string.format("%." .. source:getPrecision() .. "f",source_high[i]) ..   "\n" ..
                                " Source Bar    : " .. string.format("%02d/%02d/%04d %02d:%02d",diff.day,diff.month,diff.year,diff.hour,diff.min) ;
            drwText(TXTs,1,10,00,instance.parameters.TXT,sF);
end
function updateSignal(period)
	local z;
	if pf.period <= 10 then
		return;
	end
	for z=period-pf.period,period,1 do
			if close[z] == nil then return; end
			Up["Triple"][z] = nil;
			Down["Triple"][z] = nil;
			Up["STriple"][z] = nil;
			Down["STriple"][z] = nil;
			Up["Double"][z] = nil;
			Down["Double"][z] = nil;
			Up["Quad"][z] = nil;
			Down["Quad"][z] = nil;
			Up["ADTriple"][z] = nil;
			Down["ADTriple"][z] = nil;
			SigTXT:setNoData(z);
				-- Bull Pattern ----------------------------------------------------------------------------------------------------------
                if open[z] > close[z-1] then
                    if close[z - 2] == close[z - 4] and close[z - 4] == close[z - 6] and close[z - 6] ~= 0 and close[z] >= close[z - 2] + QBC*BS*point and Quad then
                        -- Quadruple -----------------------------------------------------------------------------------------------------
                        Up["Quad"][z] = close[z-6] + QBC*BS*point;--nil;
                        Down["Quad"][z] = close[z-6] + (QBC*BS*point - BS*point);--nil;
                        Up["Quad"]:setColor(z,Bull);
                        Down["Quad"]:setColor(z,Bull);
                        SigTXT:set(z,low[z]-BS*point,"QT","Quadruple Top");
                    elseif close[z - 4] == close[z - 6] and close[z - 4] - close[z - 2] >= BS*point*9/10
                        and close[z - 4] - close[z - 2] <= BS*point*3 and close[z - 6] ~= 0 and close[z] >= close[z - 6] + STBC*BS*point and STriple then
                        -- Spread Triple -------------------------------------------------------------------------------------------------
                        Up["STriple"][z] = close[z-6] + STBC*BS*point;--nil;
                        Down["STriple"][z] = close[z-6] + (STBC*BS*point - BS*point);--nil;
                        Up["STriple"]:setColor(z,Bull);
                        Down["STriple"]:setColor(z,Bull);
                        SigTXT:set(z,low[z]-BS*point,"STT","Spread Triple Top");
                    elseif close[z - 2] == close[z - 4] and close[z - 4] ~= 0 and close[z] >= close[z - 2] + TBC*BS*point and Triple then
                        -- Triple --------------------------------------------------------------------------------------------------------
                        Up["Triple"][z] = close[z-2] + TBC*BS*point;--nil;
                        Down["Triple"][z] = close[z-2] + (TBC*BS*point - BS*point);--nil;
                        Up["Triple"]:setColor(z,Bull);
                        Down["Triple"]:setColor(z,Bull);
                        SigTXT:set(z,low[z]-BS*point,"TT","Triple Top");
                    elseif close[z - 2] == close[z - 4] + BS*point  and close[z - 4] ~= 0 and close[z] >= close[z - 2] + ADTBC*BS*point and ADTriple then
                        -- Ascending Triple ----------------------------------------------------------------------------------------------
                        Up["ADTriple"][z] = close[z-2] + ADTBC*BS*point;--nil;
                        Down["ADTriple"][z] = close[z-2] + (ADTBC*BS*point - BS*point);--nil;
                        Up["ADTriple"]:setColor(z,Bull);
                        Down["ADTriple"]:setColor(z,Bull);
                        SigTXT:set(z,low[z]-BS*point,"ATT","Ascending Triple Top");
                    elseif close[z - 2] ~= 0 and close[z] >= close[z - 2] + DBC*BS*point and Double then
                        -- Double ---------------------------------------------------------------------------------------------------------
                        Up["Double"][z] = close[z-2] + DBC*BS*point;--nil;
                        Down["Double"][z] = close[z-2] + (DBC*BS*point - BS*point);--nil;
                        Up["Double"]:setColor(z,Bull);
                        Down["Double"]:setColor(z,Bull);
                        SigTXT:set(z,low[z]-BS*point,"DT","Double Top");
                    end
                -- Bear Pattern ----------------------------------------------------------------------------------------------------------
                elseif open[z] < close[z-1] then
                    if close[z - 2] == close[z - 4] and close[z - 4] == close[z - 6] and close[z - 6] ~= 0 and close[z] <= close[z - 2] - QBC*BS*point and Quad then
                        -- Triple ---------------------------------------------------------------------------------------------------------
                        Up["Quad"][z] = close[z-2] - (QBC*BS*point - BS*point);--nil;
                        Down["Quad"][z] = close[z-2] - QBC*BS*point;--nil;
                        Up["Quad"]:setColor(z,Bear);
                        Down["Quad"]:setColor(z,Bear);
                        SigTXT:set(z,high[z]+BS*point,"QB","Quadruple Bottom");
                    elseif close[z - 4] == close[z - 6] and close[z - 2] - close[z - 4] >= BS*point*9/10 
                        and close[z - 2] - close[z - 4] <= BS*point*3 and close[z - 6] ~= 0 and close[z] <= close[z - 6] - STBC*BS*point and STriple then
                        -- Spread Triple -------------------------------------------------------------------------------------------------
                        Up["STriple"][z] = close[z-6] - (STBC*BS*point - BS*point);--nil;
                        Down["STriple"][z] = close[z-6] - STBC*BS*point;--nil;
                        Up["STriple"]:setColor(z,Bear);
                        Down["STriple"]:setColor(z,Bear);
                        SigTXT:set(z,high[z]+BS*point,"STB","Spread Triple Bottom");
                    elseif close[z - 2] == close[z - 4] and close[z - 4] ~= 0 and close[z] <= close[z - 2] - TBC*BS*point and Triple then
                        -- Triple ---------------------------------------------------------------------------------------------------------
                        Up["Triple"][z] = close[z-2] - (TBC*BS*point - BS*point);--nil;
                        Down["Triple"][z] = close[z-2] - TBC*BS*point;--nil;
                        Up["Triple"]:setColor(z,Bear);
                        Down["Triple"]:setColor(z,Bear);
                        SigTXT:set(z,high[z]+BS*point,"TB","Triple Bottom");
                    elseif close[z - 2] == close[z - 4] - BS*point  and close[z - 4] ~= 0 and close[z] <= close[z - 2] - ADTBC*BS*point and ADTriple then
                        -- Ascending Triple ----------------------------------------------------------------------------------------------
                        Up["ADTriple"][z] = close[z-2] - (ADTBC*BS*point - BS*point);--nil;
                        Down["ADTriple"][z] = close[z-2] - ADTBC*BS*point;--nil;
                        Up["ADTriple"]:setColor(z,Bear);
                        Down["ADTriple"]:setColor(z,Bear);
                        SigTXT:set(z,high[z]+BS*point,"DTB","Descending Triple Bottom");
                    elseif close[z - 2] ~= 0 and close[z] <= close[z - 2] - DBC*BS*point and Double then
                        -- Double ---------------------------------------------------------------------------------------------------------
                        Up["Double"][z] = close[z-2] - (DBC*BS*point - BS*point);--nil;
                        Down["Double"][z] = close[z-2] - DBC*BS*point;--nil;
                        Up["Double"]:setColor(z,Bear);
                        Down["Double"]:setColor(z,Bear);
                        SigTXT:set(z,high[z]+BS*point,"DB","Double Bottom");
                    end
                end
	end
end
function updatePF(period)
	local z;
	local y = pf.period;
	for z=period,0,-1 do
		if y >= 1 then
			if pf.open[y] < pf.close[y] then
				open[z]=pf.open[y];
				close[z]=pf.close[y];
				high[z]=close[z];
				low[z]=open[z];
				volume[z] = math.modf((close[z] - open[z])/point/BS)+1;
			else
				open[z]=pf.open[y];
				close[z]=pf.close[y];
				high[z]=open[z];
				low[z]=close[z];
				volume[z] = math.modf((open[z] - close[z])/point/BS)+1;
			end
		else
			if open[z] == 0  or close[z] == 0 then 
				return; 
			end
			open[z]		= nil;
			close[z]	= nil;
			high[z]		= nil;
			low[z]		= nil;
			volume[z] 	= nil;
		end
		y = y-1;
	end
end
function drwText(text,ID,x,y,color,f)
    core.host:execute("drawLabel1", ID, x, core.CR_LEFT, y, core.CR_CENTER, core.H_Right, core.V_Center,
									 f, color, text);
end
function round(i,y)
	local decimal = y * point;
    return math.floor(i/decimal)*decimal;
end








