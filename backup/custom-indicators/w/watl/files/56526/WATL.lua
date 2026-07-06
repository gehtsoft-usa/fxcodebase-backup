-- Id: 8723
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33299

--+------------------------------------------------------------------+
--|                               Copyright � 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- WATL.lua by GitSM(GitSM4@yandex.ru)

function Init()
	indicator:name("WATL");
	indicator:description("Wave auto trend lines");
	indicator:requiredSource(core.Bar);
	indicator:type(core.Indicator);
	indicator:setTag("group", "Swing");

	indicator.parameters:addInteger("HighPeriod",  "High Period Wave", "������ ���� �������� �������", 55, 34, 1000);
	indicator.parameters:addInteger("LowPeriod",   "Low Period Wave",  "������ ���� ������� �������",  21, 34, 1000);
	indicator.parameters:addInteger("TriggerSens", "Trigger Sens",     "����������� �������� ���������� � ������� ����� ������� � ��������� ����������� ��������, ��� ������� �������������� ����� �����",  13,  0, 1000);

	indicator.parameters:addBoolean("DrawHighPeriod",   "Draw High Period",   "���������� �������� �������� �������", true);
	indicator.parameters:addColor("ColorHighPeriod", "High Period Semaphore Color", "���� ��������� �������� �������", core.colors().Red);
	indicator.parameters:addInteger("SizeHighPeriod", "High Period Semaphore Size", "������ ��������� �������� �������", 14, 2, 100);
	indicator.parameters:addBoolean("DrawLowPeriod",    "Draw Low Period",    "���������� �������� ������� �������",  true);
	indicator.parameters:addColor("ColorLowPeriod", "Low Period Semaphore Color", "���� ��������� ������� �������", core.colors().Gold);
	indicator.parameters:addInteger("SizeLowPeriod", "Low Period Semaphore Size", "������ ��������� ������� �������", 11, 2, 100);
	indicator.parameters:addBoolean("DrawLowestPeriod", "Draw Lowest Period", "���������� �������� ������� �������",  true);
	indicator.parameters:addColor("ColorLowestPeriod", "Lowest Period Semaphore Color", "���� ��������� ������� �������", core.colors().DodgerBlue);
	indicator.parameters:addInteger("SizeLowestPeriod", "Lowest Period Semaphore Size", "������ ��������� ������� �������", 7, 2, 100);

	indicator.parameters:addBoolean("DrawHTL",   "Draw High Trend Lines",             "���������� ��������� ����� �������� �������", true);
	indicator.parameters:addColor("ResColorHTL", "High Trend Lines Resistance Color", "���������� ��������� ����� �������� �������", core.colors().Red);
	indicator.parameters:addColor("SupColorHTL", "High Trend Lines Support Color",    "���������� ��������� ����� �������� �������", core.colors().Crimson);
	indicator.parameters:addInteger("WidthHTL",  "Width High Trend Lines",            "������ ��������� ����� �������� �������", 2, 1, 10);
	indicator.parameters:addInteger("StyleHTL",  "Style High Trend Lines",            "����� ��������� ����� �������� �������", core.LINE_DASH, core.LINE_SOLID, core.LINE_DASHDOT);
	indicator.parameters:setFlag("StyleHTL", core.FLAG_LINE_STYLE);
	indicator.parameters:addDouble("LengthHTL",     "Lengthening High Trend Lines",      "����������� ��������� ��������� ����� �������� �������",  1.6,  0.1,  100);
	indicator.parameters:addBoolean("ShowAngleHTL", "Show Angle High Trend Lines",       "���������� ���� ����� ��������� ����� �������� �������", true);

	indicator.parameters:addBoolean("DrawLTL",   "Draw Low Trend Lines",             "���������� ��������� ����� ������� �������", true);
	indicator.parameters:addColor("ResColorLTL", "Low Trend Lines Resistance Color", "���� ���������� ��������� ����� ������� �������", core.colors().Gold);
	indicator.parameters:addColor("SupColorLTL", "Low Trend Lines Support Color",    "���� ��������� ��������� ����� ������� �������",  core.colors().OrangeRed);
	indicator.parameters:addInteger("WidthLTL",  "Width Low Trend Lines",            "������ ��������� ����� ������� �������", 1, 1, 10);
	indicator.parameters:addInteger("StyleLTL",  "Style Low Trend Lines",            "����� ��������� ����� ������� �������", core.LINE_SOLID, core.LINE_SOLID, core.LINE_DASHDOT);
	indicator.parameters:setFlag("StyleLTL", core.FLAG_LINE_STYLE);
	indicator.parameters:addDouble("LengthLTL",  "Lengthening Low Trend Lines",      "����������� ��������� ��������� ����� ������� �������",  1.6,  0.1,  100);
	indicator.parameters:addBoolean("ShowAngleLTL", "Show Angle Low Trend Lines",    "���������� ���� ����� ��������� ����� ������� �������", false);

	indicator.parameters:addBoolean("DrawZigZagHW", "High Wave ZigZag Draw", "���������� ����� �������� ������� � ���� ZigZag", false);
	indicator.parameters:addBoolean("DrawZigZagLW", "Low Wave ZigZag Draw",  "���������� ����� ������� ������� � ���� ZigZag", false);

	indicator.parameters:addString("ToStrategy", "To Strategy", "������������ ������ � �����������, ����� ���������� ������ � ������������ ������.", "No");
	indicator.parameters:addStringAlternative("ToStrategy", "Not save Wave", "�� ������������ ����������", "No");
	indicator.parameters:addStringAlternative("ToStrategy", "Save Wave & Time", "������������ ����������", "Yes");
end

local initUpdate = false;  -- ���� ������� ���������� Update
local source;

local TriggerSens;
local firstPeriod;
local PrevBar;

-- ���������� ��������� ���� �� ������� ����
local currentFindHW, currentFindLW, currentFindLwstW;
-- ������� ��������� ����������� ���������
local iLastShowHW, iLastShowLW, iLastShowLwstW;
-- ������� ��������� ����������� ��������� ����� ����
local iLastShowUpLnHW, iLastShowDnLnHW, iLastShowUpLnLW, iLastShowDnLnLW;
-- ������� ��������� ����������� ����� ZigZag
local iLastShowZzgHW, iLastShowZzgLW;

-- ����� ������������� ����
local useHighWave   = false;
local useLowWave    = false;
local useLowestWave = false;

-- ����� ����������� ����� �����
local ShowAngleLTL, ShowAngleHTL;
local font;

-- ����� ����������� ���� � ���� ZigZag
local DrawZigZagHW, DrawZigZagLW;

-- �������� ���������� WATL
local HighWave   = { Init=false; } -- ����� �������� �������
local LowWave    = { Init=false; } -- ����� ������� �������
local LowestWave = { Init=false; } -- ����� ������� �������. �������� ������ HighWave, LowWave, LowestWave:
--[[ Init;         -- ���� �������� �������������
     Profile       -- ������� ����������
     Params        -- ��������� ����������
     Indicator     -- ������ ����������

     Color         -- ���� �����������
     Size          -- ������ ���������
     Width         -- ������ ��������� �����
     Style         -- ����� �����������

     Count         -- ���������� ����
     LowVal   = {} -- ���������� ��������� ����
     LowTime  = {} -- ���������� ������� ���������
     HighVal  = {} -- ���������� ���������� ����
     HighTime = {} -- ���������� ������� ����������
     Value    = {} -- ���������� ������� ����. ������������� ����� - ���������� �����, ������������� - ���������� 
     Time     = {} -- ���������� ������� ������ �����. ��� ���������� ����� ������������� ������� �������� �����, ��� ���������� �������� ������� ���������

     signOut  = {} -- ������� ��� ����������� ��������� ���� � ���� ��������� ������
     lineOut  = {} -- ������� ��� ����������� ���� � ���� ZigZag
     ResColor;     -- ���� ����� �����
     SupColor;     -- ���� ����� ����
     Width;        -- ������ ����� �����
     Style;        -- ����� ����������� �����
     PrevCount;    -- ������ ����� ������������ ��������� �� ���������� ���� 
]]

-- ������������ ���������� ���������� �������
local HighFastMA   = { Init=false; }
local HighSlowMA   = { Init=false; }
local LowFastMA    = { Init=false; }
local LowSlowMA    = { Init=false; }
local LowestFastMA = { Init=false; }
local LowestSlowMA = { Init=false; } -- �������� ������:
--[[ Init;       -- ���� �������� �������������
     Profile     -- ������� ����������
     Params      -- ��������� ����������
     Indicator   -- ������ ����������

     Data        -- ������ ����������
     Metod       -- ����� ����������
     Period      -- ������
     Price       -- ������������ ���� ������ ��������� �� ������� �������� ���������� �������
     Shift       -- ����� ���������� �������
]]

-- ��������� ���������
local DTm = { OneHour = 0.0416666666666666, OneMin = 0.0006944444444444 };
--[[ TradeDTm;      -- ���. ����� �� ��������� �������. ����� EZT
     strTradeDTm;   -- ��������� ������������� TradeDTm
     CurrentDTmBar; -- ����� ���. ����
     LocalDTm;      -- ���. ����� �� ����������
     strLocalDTm;   -- ��������� ������������� LocalDTm
     OneHour;       -- ��������� �������� � ���� ���
     1.0 = ����
     0.5 = 12 �����
     0.04166666666666666666666666666667 = ���
     0,00069444444444444444444444444444444 = ������
     0,000011574074074074074074074074074074 = �������
     0,000000011574074074074074074074074074074 = ������������
]]

-- �������������
 function Prepare(nameOnly)  
	source = instance.source;
	local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end

	-- ��������� ����������� ���� ������� �������
	if instance.parameters.DrawLowestPeriod then
		LowestWave.Color    = instance.parameters.ColorLowestPeriod; -- ���� ����������� ���������
		LowestWave.Size     = instance.parameters.SizeLowestPeriod;  -- ������ ����������� ���������
		useLowestWave = true;
		-- ����������� ������ � �������� ����� ����� �������� ���������� �����
		firstPeriod = 5;
	end
	-- ��������� ����������� ���� ������� �������
	if instance.parameters.DrawLowPeriod or instance.parameters.DrawLTL then
		LowWave.Color       = instance.parameters.ColorLowPeriod; -- ���� ����������� ���������
		LowWave.Size        = instance.parameters.SizeLowPeriod;  -- ������ ����������� ���������
		LowWave.ResColor    = instance.parameters.ResColorLTL;    -- ���� ����������� ���������� ��������� �����
		LowWave.SupColor    = instance.parameters.SupColorLTL;    -- ���� ����������� ���������� ��������� �����
		LowWave.Style       = instance.parameters.StyleLTL;       -- ����� �����������
		LowWave.Width       = instance.parameters.WidthLTL;       -- ������ �����������
		LowWave.Length      = instance.parameters.LengthLTL;
		useLowWave = true;
		-- ����������� ������ � �������� ����� ����� �������� ���������� �����
		firstPeriod = instance.parameters.LowPeriod;
	end
	-- ��������� ����������� ���� �������� �������
	if instance.parameters.DrawHighPeriod or instance.parameters.DrawHTL then
		HighWave.Color      = instance.parameters.ColorHighPeriod; -- ���� ����������� ���������
		HighWave.Size       = instance.parameters.SizeHighPeriod;  -- ������ ����������� ���������
		HighWave.ResColor   = instance.parameters.ResColorHTL;     -- ���� �����������
		HighWave.SupColor   = instance.parameters.SupColorHTL;     -- ���� �����������
		HighWave.Style      = instance.parameters.StyleHTL;        -- ����� �����������
		HighWave.Width      = instance.parameters.WidthHTL;        -- ������ �����������
		HighWave.Length     = instance.parameters.LengthHTL;
		useHighWave = true;
		-- ����������� ������ � �������� ����� ����� �������� ���������� �����
		firstPeriod = instance.parameters.HighPeriod;
	end

	if instance.parameters.ToStrategy~="No" then
		-- ����� ������ �����������
		if useLowestWave then
			LowestWave.LowVal   = instance:addStream("LwstWLowVal",   core.Line, name .. ".LwstWLowVal",   "LwstWLowVal",   LowestWave.Color, 0); -- ������� �����
			LowestWave.LowTime  = instance:addStream("LwstWLowTime",  core.Line, name .. ".LwstWLowTime",  "LwstWLowTime",  LowestWave.Color, 0); -- ����� �������� �����
			LowestWave.HighVal  = instance:addStream("LwstWHighVal",  core.Line, name .. ".LwstWHighVal",  "LwstWHighVal",  LowestWave.Color, 0); -- �������� �����
			LowestWave.HighTime = instance:addStream("LwstWHighTime", core.Line, name .. ".LwstWHighTime", "LwstWHighTime", LowestWave.Color, 0); -- ����� ��������� �����
			LowestWave.Value    = instance:addStream("LwstWValue",    core.Line, name .. ".LwstWValue",    "LwstWValue",    LowestWave.Color, 0); -- �������� ���� �����
			LowestWave.Time     = instance:addStream("LwstWTime",     core.Line, name .. ".LwstWTime",     "LwstWTime",     LowestWave.Color, 0); -- ����� ������ �����
			LowestWave.Count    = 0; -- ���������� ����
		end
		
		-- ����� ������ �����������
		if useLowWave then
			LowWave.LowVal   = instance:addStream("LWLowVal",   core.Line, name .. ".LWLowVal",   "LWLowVal",   LowWave.Color, 0); -- ������� �����
			LowWave.LowTime  = instance:addStream("LWLowTime",  core.Line, name .. ".LWLowTime",  "LWLowTime",  LowWave.Color, 0); -- ����� �������� �����
			LowWave.HighVal  = instance:addStream("LWHighVal",  core.Line, name .. ".LWHighVal",  "LWHighVal",  LowWave.Color, 0); -- �������� �����
			LowWave.HighTime = instance:addStream("LWHighTime", core.Line, name .. ".LWHighTime", "LWHighTime", LowWave.Color, 0); -- ����� ��������� �����
			LowWave.Value    = instance:addStream("LWValue",    core.Line, name .. ".LWValue",    "LWValue",    LowWave.Color, 0); -- �������� ���� �����
			LowWave.Time     = instance:addStream("LWTime",     core.Line, name .. ".LWTime",     "LWTime",     LowWave.Color, 0); -- ����� ������ �����
			LowWave.Count    = 0; -- ���������� ����
		end
		
		-- ����� ������� �����������
		if useHighWave then
			HighWave.LowVal   = instance:addStream("HWLowVal",   core.Line, name .. ".HWLowVal",   "HWLowVal",   HighWave.Color, 0); -- ������� �����
			HighWave.LowTime  = instance:addStream("HWLowTime",  core.Line, name .. ".HWLowTime",  "HWLowTime",  HighWave.Color, 0); -- ����� �������� �����
			HighWave.HighVal  = instance:addStream("HWHighVal",  core.Line, name .. ".HWHighVal",  "HWHighVal",  HighWave.Color, 0); -- �������� �����
			HighWave.HighTime = instance:addStream("HWHighTime", core.Line, name .. ".HWHighTime", "HWHighTime", HighWave.Color, 0); -- ����� ��������� �����
			HighWave.Value    = instance:addStream("HWValue",    core.Line, name .. ".HWValue",    "HWValue",    HighWave.Color, 0); -- �������� ���� �����
			HighWave.Time     = instance:addStream("HWTime",     core.Line, name .. ".HWTime",     "HWTime",     HighWave.Color, 0); -- ����� ������ �����
			HighWave.Count    = 0; -- ���������� ����
		end
	else
		-- ����� ������ �����������
		if useLowestWave then
			LowestWave.LowVal   = {}; -- ������� �����
			LowestWave.LowTime  = {}; -- ����� �������� �����
			LowestWave.HighVal  = {}; -- �������� �����
			LowestWave.HighTime = {}; -- ����� ��������� �����
			LowestWave.Value    = {}; -- �������� ���� �����
			LowestWave.Time     = {}; -- ����� ������ �����
			LowestWave.Count    = 0;  -- ���������� ����
		end
		
		-- ����� ������ �����������
		if useLowWave then
			LowWave.LowVal   = {}; -- ������� �����
			LowWave.LowTime  = {}; -- ����� �������� �����
			LowWave.HighVal  = {}; -- �������� �����
			LowWave.HighTime = {}; -- ����� ��������� �����
			LowWave.Value    = {}; -- �������� ���� �����
			LowWave.Time     = {}; -- ����� ������ �����
			LowWave.Count    = 0;  -- ���������� ����
		end
		
		-- ����� ������� �����������
		if useHighWave then
			HighWave.LowVal   = {}; -- ������� �����
			HighWave.LowTime  = {}; -- ����� �������� �����
			HighWave.HighVal  = {}; -- �������� �����
			HighWave.HighTime = {}; -- ����� ��������� �����
			HighWave.Value    = {}; -- �������� ���� �����
			HighWave.Time     = {}; -- ����� ������ �����
			HighWave.Count    = 0;  -- ���������� ����
		end
	end

	-- �������������� ������ ���������� �����
	-- ��������� ����������� ���� ������� �������
	if instance.parameters.DrawLowestPeriod then
		LowestWave.signOut = instance:createTextOutput("lowestWave", "lowestW", "Wingdings", LowestWave.Size, core.H_Center, core.V_Center, LowestWave.Color, 0);
	end
	-- ����� ������ �����������
	if useLowWave then
		LowWave.signOut = instance:createTextOutput("lowWave", "lowW", "Wingdings", LowWave.Size, core.H_Center, core.V_Center, LowWave.Color, 0);
		LowWave.lineOut = instance:addStream("lowWaveLn", core.Line, name .. ".lowWaveLn", "lowWaveLn", LowWave.ResColor, 0);
	end
	-- ����� ������� �����������
	if useHighWave then
		HighWave.signOut = instance:createTextOutput("highWave", "highW", "Wingdings", HighWave.Size, core.H_Center, core.V_Center, HighWave.Color, 0);
		HighWave.lineOut = instance:addStream("highWaveLn", core.Line, name .. ".highWaveLn", "highWaveLn", HighWave.ResColor, 0);
	end

	-- �������� ��������� ������
	TriggerSens = instance.parameters.TriggerSens;

	-- �������� ������� ��������� ������������ ��������� � ����
	iLastShowLwstW  = 1;

	iLastShowLW     = 1; -- ����� ������� �������
	iLastShowUpLnLW = 2;
	iLastShowDnLnLW = 2;
	iLastShowZzgLW  = 1;

	iLastShowHW     = 1; -- ����� �������� �������
	iLastShowUpLnHW = 2;
	iLastShowDnLnHW = 2;
	iLastShowZzgHW  = 1;

	DrawZigZagLW = instance.parameters.DrawZigZagLW;
	DrawZigZagHW = instance.parameters.DrawZigZagHW;

	-- ����� ����������� ����� �����
	ShowAngleLTL = instance.parameters.ShowAngleLTL;
	ShowAngleHTL = instance.parameters.ShowAngleHTL;
	font = core.host:execute("createFont", "MS Sans Serif", 6, false, true);

	PrevBar = -1;
end

-- ���������������
function ReleaseInstance()
	core.host:execute("deleteFont", font);
end

-- �������� ���
function Update(period, mode)
	local i;
	if not(initUpdate) then
		-- ������������� ���� �������� �������
		if useHighWave then
		-- ������������� ������� ���������� ������� ��� ���� �������� ������� HighFastMA
		HighFastMA.Profile = core.indicators:findIndicator("MVA"); -- ���������� ���������� �� ��������� � �������. ��������� ��������: "MVA", "EMA", "LWMA", "TMA", "SMMA", "VIDYA", "VIDYA92", "WMA", "TEMA1"
		if HighFastMA.Profile~=nil and not(HighFastMA.Init) then
			HighFastMA.Period = instance.parameters.HighPeriod / 7; -- ������� ������ ���� �������� �������
			HighFastMA.Metod  = "MVA";                              -- ����� ����������
			HighFastMA.Price  = source.close;                       -- ������������ ����
			
			-- HighFastMA.Params = HighFastMA.Profile:parameters();    -- ���������� ������� ���������� ��� �������� � ������� �������� ������� ���������� profile:createInstance()
			-- HighFastMA.Params:setInteger("N", HighWave.FastPeriod); -- ������
			
    assert(core.indicators:findIndicator(HighFastMA.Metod) ~= nil, HighFastMA.Metod .. " indicator must be installed");
			HighFastMA.Indicator = core.indicators:create(HighFastMA.Metod, HighFastMA.Price, HighFastMA.Period);
			-- HighFastMA.Data = HighFastMA.Indicator:getStream(0);
			
			HighFastMA.Data = HighFastMA.Indicator.DATA;
			HighFastMA.Init = true;
		end

		-- ������������� ��������� ���������� ������� ��� ���� �������� ������� HighSlowMA
		HighSlowMA.Profile = core.indicators:findIndicator("LWMA"); -- ���������� ���������� �� ��������� � �������. ��������� ��������: "MVA", "EMA", "LWMA", "TMA", "SMMA", "VIDYA", "VIDYA92", "WMA", "TEMA1"
		if HighSlowMA.Profile~=nil and not(HighSlowMA.Init) then
			HighSlowMA.Period = instance.parameters.HighPeriod; -- ��������� ������ ���� �������� �������
			HighSlowMA.Metod  = "LWMA";                         -- ����� ����������
			HighSlowMA.Price  = source.weighted;                -- ������������ ����
			
			-- HighSlowMA.Params = HighSlowMA.Profile:parameters();    -- ���������� ������� ���������� ��� �������� � ������� �������� ������� ���������� profile:createInstance()
			-- HighSlowMA.Params:setInteger("N", HighWave.SlowPeriod); -- ������
			
    assert(core.indicators:findIndicator(HighSlowMA.Metod) ~= nil, HighSlowMA.Metod .. " indicator must be installed");
			HighSlowMA.Indicator = core.indicators:create(HighSlowMA.Metod, HighSlowMA.Price, HighSlowMA.Period);
			-- HighSlowMA.Data = HighSlowMA.Indicator:getStream(0);
			
			HighSlowMA.Data = HighSlowMA.Indicator.DATA;
			HighSlowMA.Init = true;
		end
		end

		-- ������������� ���� ������� �������
		if useLowWave then
		-- ������������� ������� ���������� ������� ��� ���� ������� ������� LowFastMA
		LowFastMA.Profile = core.indicators:findIndicator("MVA"); -- ���������� ���������� �� ��������� � �������. ��������� ��������: "MVA", "EMA", "LWMA", "TMA", "SMMA", "VIDYA", "VIDYA92", "WMA", "TEMA1"
		if LowFastMA.Profile~=nil and not(LowFastMA.Init) then
			LowFastMA.Period = instance.parameters.LowPeriod / 5; -- ������� ������ ���� ������� �������
			LowFastMA.Metod  = "MVA";                             -- ����� ����������
			LowFastMA.Price  = source.close;                      -- ������������ ����
			
			-- LowFastMA.Params = LowFastMA.Profile:parameters();     -- ���������� ������� ���������� ��� �������� � ������� �������� ������� ���������� profile:createInstance()
			-- LowFastMA.Params:setInteger("N", HighWave.FastPeriod); -- ������
			
    assert(core.indicators:findIndicator(LowFastMA.Metod) ~= nil, LowFastMA.Metod .. " indicator must be installed");
			LowFastMA.Indicator = core.indicators:create(LowFastMA.Metod, LowFastMA.Price, LowFastMA.Period);
			-- LowFastMA.Data = LowFastMA.Indicator:getStream(0);
			
			LowFastMA.Data = LowFastMA.Indicator.DATA;
			LowFastMA.Init = true;
		end

		-- ������������� ��������� ���������� ������� ��� ���� �������� ������� LowSlowMA
		LowSlowMA.Profile = core.indicators:findIndicator("LWMA"); -- ���������� ���������� �� ��������� � �������. ��������� ��������: "MVA", "EMA", "LWMA", "TMA", "SMMA", "VIDYA", "VIDYA92", "WMA", "TEMA1"
		if LowSlowMA.Profile~=nil and not(LowSlowMA.Init) then
			LowSlowMA.Period = instance.parameters.LowPeriod;  -- ��������� ������ ���� ������� �������
			LowSlowMA.Metod  = "LWMA";                         -- ����� ����������
			LowSlowMA.Price  = source.weighted;                -- ������������ ����
			
			-- LowSlowMA.Params = LowSlowMA.Profile:parameters();     -- ���������� ������� ���������� ��� �������� � ������� �������� ������� ���������� profile:createInstance()
			-- LowSlowMA.Params:setInteger("N", HighWave.SlowPeriod); -- ������
			
    assert(core.indicators:findIndicator(LowSlowMA.Metod) ~= nil, LowSlowMA.Metod .. " indicator must be installed");
			LowSlowMA.Indicator = core.indicators:create(LowSlowMA.Metod, LowSlowMA.Price, LowSlowMA.Period);
			-- LowSlowMA.Data = LowSlowMA.Indicator:getStream(0);
			
			LowSlowMA.Data = LowSlowMA.Indicator.DATA;
			LowSlowMA.Init = true;
		end
		end

		-- ������������� ���� ������� �������
		if useLowestWave then
		-- ������������� ������� ���������� ������� ��� ���� ������� ������� LowestFastMA
		LowestFastMA.Profile = core.indicators:findIndicator("MVA"); -- ���������� ���������� �� ��������� � �������. ��������� ��������: "MVA", "EMA", "LWMA", "TMA", "SMMA", "VIDYA", "VIDYA92", "WMA", "TEMA1"
		if LowestFastMA.Profile~=nil and not(LowestFastMA.Init) then
			LowestFastMA.Period = 2;            -- ������� ������ ���� ������� �������
			LowestFastMA.Metod  = "MVA";        -- ����� ����������
			LowestFastMA.Price  = source.close; -- ������������ ����
			
			-- LowestFastMA.Params = LowestFastMA.Profile:parameters();  -- ���������� ������� ���������� ��� �������� � ������� �������� ������� ���������� profile:createInstance()
			-- LowestFastMA.Params:setInteger("N", HighWave.FastPeriod); -- ������
			
    assert(core.indicators:findIndicator(LowestFastMA.Metod) ~= nil, LowestFastMA.Metod .. " indicator must be installed");
			LowestFastMA.Indicator = core.indicators:create(LowestFastMA.Metod, LowestFastMA.Price, LowestFastMA.Period);
			-- LowestFastMA.Data = LowestFastMA.Indicator:getStream(0);
			
			LowestFastMA.Data = LowestFastMA.Indicator.DATA;
			LowestFastMA.Init = true;
		end

		-- ������������� ��������� ���������� ������� ��� ���� �������� ������� LowestSlowMA
		LowestSlowMA.Profile = core.indicators:findIndicator("LWMA"); -- ���������� ���������� �� ��������� � �������. ��������� ��������: "MVA", "EMA", "LWMA", "TMA", "SMMA", "VIDYA", "VIDYA92", "WMA", "TEMA1"
		if LowestSlowMA.Profile~=nil and not(LowestSlowMA.Init) then
			LowestSlowMA.Period = 5;               -- ��������� ������ ���� ������� �������
			LowestSlowMA.Metod  = "LWMA";          -- ����� ����������
			LowestSlowMA.Price  = source.weighted; -- ������������ ����
			
			-- LowestSlowMA.Params = LowestSlowMA.Profile:parameters();    -- ���������� ������� ���������� ��� �������� � ������� �������� ������� ���������� profile:createInstance()
			-- LowestSlowMA.Params:setInteger("N", HighWave.SlowPeriod); -- ������
			
    assert(core.indicators:findIndicator(LowestSlowMA.Metod) ~= nil, LowestSlowMA.Metod .. " indicator must be installed");
			LowestSlowMA.Indicator = core.indicators:create(LowestSlowMA.Metod, LowestSlowMA.Price, LowestSlowMA.Period);
			-- LowestSlowMA.Data = LowestSlowMA.Indicator:getStream(0);
			
			LowestSlowMA.Data = LowestSlowMA.Indicator.DATA;
			LowestSlowMA.Init = true;
		end
		end

		-- �������� ���� ���������� ������������ Update
		if (HighSlowMA.Init   and HighFastMA.Init)   or ( not(useHighWave)   and not(HighSlowMA.Init)   and not(HighFastMA.Init)   ) then initUpdate = true; end
		if (LowSlowMA.Init    and LowFastMA.Init)    or ( not(useLowWave)    and not(LowSlowMA.Init)    and not(LowFastMA.Init)    ) then initUpdate = true; end
		if (LowestSlowMA.Init and LowestFastMA.Init) or ( not(useLowestWave) and not(LowestSlowMA.Init) and not(LowestFastMA.Init) ) then initUpdate = true; end
		
		if not(initUpdate) then return; end
	end

	if not(initUpdate) then return; end

	-- ��������� �������� ��� ������ ���������
	if period==0 then
		if useHighWave   then HighWave.Count = 0;   HighWave.Value[0] = 0;   end
		if useLowWave    then LowWave.Count = 0;    LowWave.Value[0] = 0;    end
		if useLowestWave then LowestWave.Count = 0; LowestWave.Value[0] = 0; end
	end

	-- ���������� ����������� ���������� �������
	if useHighWave then
		HighFastMA.Indicator:update(mode);
		HighSlowMA.Indicator:update(mode);
	end
	if useLowWave then
		LowFastMA.Indicator:update(mode);
		LowSlowMA.Indicator:update(mode);
	end
	if useLowestWave then
		LowestFastMA.Indicator:update(mode);
		LowestSlowMA.Indicator:update(mode);
	end
	PrevBar = period; -- ����� �������� �� ���������� �� ����� ����

	if period<firstPeriod then return; end

	-- �������� ��������� ������ ������������ �� ������� ������
	if instance.parameters.ToStrategy~="No" then
		if useHighWave then
			HighWave.LowVal:setBreak(period, true);
			HighWave.LowTime:setBreak(period, true);
			HighWave.HighVal:setBreak(period, true);
			HighWave.HighTime:setBreak(period, true);
			HighWave.Value:setBreak(period, true);
			HighWave.Time:setBreak(period, true);
		end
		if useLowWave then
			LowWave.LowVal:setBreak(period, true);
			LowWave.LowTime:setBreak(period, true);
			LowWave.HighVal:setBreak(period, true);
			LowWave.HighTime:setBreak(period, true);
			LowWave.Value:setBreak(period, true);
			LowWave.Time:setBreak(period, true);
		end
		if useLowestWave then
			LowestWave.LowVal:setBreak(period, true);
			LowestWave.LowTime:setBreak(period, true);
			LowestWave.HighVal:setBreak(period, true);
			LowestWave.HighTime:setBreak(period, true);
			LowestWave.Value:setBreak(period, true);
			LowestWave.Time:setBreak(period, true);
		end
	end

	-- ��� ���������� ��������� ���������� ��������� ����� � ������� � � �������, ����� ���������� ������ ��� ������������ period � source:size()-1
	if period<source:size()-1 then return; end

	-- ���������� ����� �� ���������� ������� � �� ���������� ��������� � ��������� �����
	if useLowestWave then
		currentFindLwstW = GetWave(source, LowestSlowMA.Data, LowestFastMA.Data, LowestWave, TriggerSens, period);
		ClearWaveSemaphore(source, LowestWave, LowestWave.signOut, iLastShowLwstW, period);
		iLastShowLwstW = DrawWaveSemaphore(source, LowestWave, LowestWave.signOut, "\140", iLastShowLwstW, period);
	end
	if useLowWave then
		currentFindLW = GetWave(source, LowSlowMA.Data, LowFastMA.Data, LowWave, TriggerSens, period);
		if instance.parameters.DrawLowPeriod then
			ClearWaveSemaphore(source, LowWave, LowWave.signOut, iLastShowLW, period)
			iLastShowLW = DrawWaveSemaphore(source, LowWave, LowWave.signOut, "\141", iLastShowLW, period);
		end
		if instance.parameters.DrawLTL then
			iLastShowUpLnLW = DrawUpTrendLine(source, LowWave, LowWave.SupColor, LowWave.Style, LowWave.Width, LowWave.Length, 200000, iLastShowUpLnLW, ShowAngleLTL, font, period);
			iLastShowDnLnLW = DrawDnTrendLine(source, LowWave, LowWave.ResColor, LowWave.Style, LowWave.Width, LowWave.Length, 200000, iLastShowDnLnLW, ShowAngleLTL, font, period);
		end
		if DrawZigZagLW then iLastShowZzgLW = DrawWaveLine(source, LowWave, LowWave.lineOut, LowWave.ResColor, LowWave.SupColor, iLastShowZzgLW, period); end
	end
	if useHighWave then
		currentFindHW = GetWave(source, HighSlowMA.Data, HighFastMA.Data, HighWave, TriggerSens, period);
		if instance.parameters.DrawHighPeriod then
			ClearWaveSemaphore(source, HighWave, HighWave.signOut, iLastShowHW, period)
			iLastShowHW = DrawWaveSemaphore(source, HighWave, HighWave.signOut, "\142", iLastShowHW, period);
		end
		if instance.parameters.DrawHTL then
			iLastShowUpLnHW = DrawUpTrendLine(source, HighWave, HighWave.SupColor, HighWave.Style, HighWave.Width, HighWave.Length, 300000, iLastShowUpLnHW, ShowAngleHTL, font, period);
			iLastShowDnLnHW = DrawDnTrendLine(source, HighWave, HighWave.ResColor, HighWave.Style, HighWave.Width, HighWave.Length, 300000, iLastShowDnLnHW, ShowAngleHTL, font, period);
		end
		if DrawZigZagHW then iLastShowZzgHW = DrawWaveLine(source, HighWave, HighWave.lineOut, HighWave.ResColor, HighWave.SupColor, iLastShowZzgHW, period); end
	end
end

-- ���������� ����� �� �������� ���������� �������
function GetWave(Source, SlowMA, FastMA, Waves, TriggerSens, period)
	local allBars = Source:size();
	local firstBar = SlowMA:first();
	local iLastBar = SlowMA:size() - 1;

	local iStartWave = 0; -- ����� ������ �����
	local iStopWave = 0;  -- ����� ���������� �����
	local TypeWave = -1;  -- ��� �����. ������������ ��������: 1 - ����������, -1 - ����������

	local CountWave;     -- ���������� ���� ����
	local countFindWave; -- ���������� ������������ ����

	local maxWave, imaxWave, minWave, iminWave, valWave, dtmWave;
	local ExistsWave;
	local i;

	-- �������� ������������� ������
	if period<=firstBar then return 0; end

	if Waves.Count~=nil then CountWave = Waves.Count; else CountWave = 0; end -- ���������� ����
	countFindWave = 0; -- ���������� ��������� ���� �� ������� ����� ����������� ����

	-- ������������� ����������� ����. ���� ����� �� ����� �� ������������, �� ������ ����������� ���� �� ��� ���������� Source, ����� ����������� ���������� � ��������� ����������� �����
	if CountWave<=1 then
		
		-- ��������� ��� ����� �� ������� firstBar. ���� ����� ����������, �� ������ ����� ����� ����������, ���� ��� ����������, �� ������ ����� ����������. ����� �������� � ������� ���� ����������
		i = firstBar;
		-- ���� �� firstBar ����������� ������� ����, �� � ���������� ���������
		while i<=iLastBar do
			if not(CheckInZeroZone(FastMA, SlowMA, TriggerSens, i)) then break; end
			i = i + 1;
		end
		if i>iLastBar then return 0; end
		TypeWave = CurrentWaveType(FastMA, SlowMA, i);
		-- ��������� ������ ������ �����
		i = i + 1;
		ExistsWave = false;
		while i<=iLastBar do
			if CurrentWaveType(FastMA, SlowMA, i)~=TypeWave and not(CheckInZeroZone(FastMA, SlowMA, TriggerSens, i)) then
				ExistsWave = true;
				break;
			end
			i = i + 1;
		end
		-- �������� ������� ������������� �����
		if not(ExistsWave) then return 0; end
		-- ���������� ��� ����� �� ��������� ���, ������� ������ ���� ���������������
		TypeWave = TypeWave * (-1);
		-- ��������� ���������� ������ �����
		i = i + 1;
		ExistsWave = false;
		while i<=iLastBar do
			if CurrentWaveType(FastMA, SlowMA, i)~=TypeWave and not(CheckInZeroZone(FastMA, SlowMA, TriggerSens, i)) then
				ExistsWave = true;
				break;
			end
			i = i + 1;
		end
		-- �������� ������� ������������� �����
		if not(ExistsWave) then
			Waves.Count    = 0;
			Waves.Value[0] = 0;
			return 0;
		end
		
		-- ���������� ���� �������� ����������� �������/������ ������ �����
		iStopWave = i - 1;
		
		-- ��������� �������, ������ � �������� ����(���) �����
		if TypeWave>0 then
			-- ���������� ����� �������� ����������� �������/������ ������ �����
			minWave, iStartWave = mathex.min(Source.low, firstBar, iStopWave);
			
			maxWave, imaxWave = mathex.max(Source.high, iStartWave, iStopWave);    -- �������� ���������� ����� - ����� ���������� �����
			minWave, iminWave = mathex.min(Source.low,  Source:first(), imaxWave); -- ������� ���������� ����� - ����� ������ �����
			valWave = maxWave - minWave;
			dtmWave = Source:date(iminWave);
			-- ����� ����� ���������� ��� ������ ��������� �����
			iStartWave = imaxWave;
		else
			-- ���������� ����� �������� ����������� �������/������ ������ �����
			maxWave, iStartWave = mathex.max(Source.high, firstBar, iStopWave);
			
			minWave, iminWave = mathex.min(Source.low,  iStartWave, iStopWave);    -- ������� ���������� ����� - ����� ������ �����
			maxWave, imaxWave = mathex.max(Source.high, Source:first(), iminWave); -- �������� ���������� ����� - ����� ���������� �����
			valWave = minWave - maxWave;
			dtmWave = Source:date(imaxWave);
			-- ����� ����� ���������� ��� ������ ��������� �����
			iStartWave = iminWave;
		end
		
		-- �������� ��������� ������ �����
		CountWave         = 1;
		Waves.LowVal[1]   = minWave;
		Waves.LowTime[1]  = Source:date(iminWave);
		Waves.HighVal[1]  = maxWave;
		Waves.HighTime[1] = Source:date(imaxWave);
		Waves.Value[1]    = valWave;
		Waves.Time[1]     = dtmWave;
		Waves.Value[0]    = CountWave; -- ���������� ���������� ���� � ������� ��� ����������� �������� ������ ������
		Waves.Count       = CountWave;
		
		countFindWave = 1;
		
		TypeWave = TypeWave * (-1); -- ���������� ��� ����� �� ��������� ���, ������� ������ ���� ���������������
		i = i + 1; -- �� ��������� ���
		
	else
		-- �������� �� ������������� ����� � ������������� ��������� �����
		CountWave = CountWave - 1;
		-- ���� ������������� ����� ����������
		if Waves.Value[CountWave]>0 then
			-- ��������� ������ ���������� ������������� ����� � ������ ���������
			iStartWave = core.findDate(Source, Waves.HighTime[CountWave], false) + 1;
			i = iStartWave;
			if period<i then return countFindWave; end
			-- if CurrentWaveType(FastMA, SlowMA, i)<0 then
				-- while i<=iLastBar do
					-- if CurrentWaveType(FastMA, SlowMA, i)>0 then break; end -- and not(CheckInZeroZone(FastMA, SlowMA, TriggerSens, i))
					-- i = i + 1;
				-- end
			-- end
			TypeWave = 1;
		-- ���� ������������� ����� ����������
		else
			-- ��������� ������ ���������� ������������� ����� � ������ ���������
			iStartWave = core.findDate(Source, Waves.LowTime[CountWave], false) + 1;
			i = iStartWave;
			if period<i then return countFindWave; end
			-- if CurrentWaveType(FastMA, SlowMA, i)>0 then
				-- while i<=iLastBar do
					-- if CurrentWaveType(FastMA, SlowMA, i)<0 then break; end -- and not(CheckInZeroZone(FastMA, SlowMA, TriggerSens, i))
					-- i = i + 1;
				-- end
			-- end
			TypeWave = -1;
		end
		-- ��������� ������ ��������� ����� �� ���������� �������
		if TypeWave==CurrentWaveType(FastMA, SlowMA, i) then
			ExistsWave = false;
			while i<=iLastBar do
				if CurrentWaveType(FastMA, SlowMA, i)~=TypeWave and not(CheckInZeroZone(FastMA, SlowMA, TriggerSens, i)) then
					ExistsWave = true;
					break;
				end
				i = i + 1;
			end
		elseif CheckInZeroZone(FastMA, SlowMA, TriggerSens, i) then
			ExistsWave = false;
			while i<=iLastBar do
				if CurrentWaveType(FastMA, SlowMA, i)~=TypeWave and not(CheckInZeroZone(FastMA, SlowMA, TriggerSens, i)) then
					ExistsWave = true;
					break;
				end
				i = i + 1;
			end
		else
			ExistsWave = true;
		end
		-- �������� ������� ������������� �����
		if not(ExistsWave) then
			Waves.Count    = CountWave;
			Waves.Value[0] = CountWave;
			return countFindWave;
		end
		TypeWave = TypeWave * (-1);
		i = i + 1;
	end
	
	-- �������� ���� ����������� ����
	while i<=iLastBar do
		-- ��������� ���������� ������� �����
		ExistsWave = false;
		while i<=iLastBar do
			if CurrentWaveType(FastMA, SlowMA, i)~=TypeWave and not(CheckInZeroZone(FastMA, SlowMA, TriggerSens, i)) then
				ExistsWave = true;
				break;
			end
			i = i + 1;
		end
		-- �������� ������� ������������� �����
		if not(ExistsWave) then
			Waves.Count    = CountWave;
			Waves.Value[0] = CountWave;
			return countFindWave;
		end
		
		-- ���������� ���� �������� ����������� �������/������ ������ �����
		iStopWave = i - 1;
		
		-- ��������� �������, ������ � �������� ����(���) �����
		if TypeWave>0 then
			maxWave, imaxWave = mathex.max(Source.high, iStartWave, iStopWave); -- �������� ���������� ����� - ����� ���������� �����
			minWave  = Waves.LowVal[CountWave]; -- ������� ���������� ����� - ����� ������ ����. �����
			iminWave = iStartWave - 1;
			valWave  = maxWave - minWave;
			dtmWave  = Source:date(iminWave);
			-- ����� ����� ���������� ��� ������ ��������� �����
			iStartWave = imaxWave + 1;
		else
			minWave, iminWave = mathex.min(Source.low,  iStartWave, iStopWave); -- ������� ���������� ����� - ����� ������ �����
			maxWave  = Waves.HighVal[CountWave]; -- �������� ���������� ����� - ����� ���������� ����. �����
			imaxWave = iStartWave - 1;
			valWave  = minWave - maxWave;
			dtmWave  = Source:date(imaxWave);
			-- ����� ����� ���������� ��� ������ ��������� �����
			iStartWave = iminWave + 1;
		end
		
		-- �������� ��������� ������ �����
		CountWave                 = CountWave + 1;
		Waves.LowVal[CountWave]   = minWave;
		Waves.LowTime[CountWave]  = Source:date(iminWave);
		Waves.HighVal[CountWave]  = maxWave;
		Waves.HighTime[CountWave] = Source:date(imaxWave);
		Waves.Value[CountWave]    = valWave;
		Waves.Time[CountWave]     = dtmWave;
		Waves.Value[0]            = CountWave; -- ���������� ���������� ���� � ������� ��� ����������� �������� ������ ������
		Waves.Count               = CountWave;
		
		countFindWave = countFindWave + 1;
		
		-- ���� CountWave ����� ������� ���������� ����, �� ���������� ���������� ���������� ������� ����������
		if CountWave==period then break; end
		
		TypeWave = TypeWave * (-1); -- ���������� ��� ����� �� ��������� ���, ������� ������ ���� ���������������
		i = i + 1; -- �� ��������� ���
	end
	
	return countFindWave; -- ���������� ���������� ��������� ���� �� ������� �����
end
--[[ ������� ���������:
Source - �������� ������� ������ �� ������� ���������� ���������� �����. ��� bar_stream
SlowMA - ����� ������ ��������� ���������� �������. ��� tick_stream
FastMA - ����� ������ ������� ���������� �������. ��� tick_stream
Waves  - ������� �������� �����������. �������� ������:
           Count         -- ���������� ����
           LowVal   = {} -- ���������� ��������� ����
           LowTime  = {} -- ���������� ������� ���������
           HighVal  = {} -- ���������� ���������� ����
           HighTime = {} -- ���������� ������� ����������
           Value    = {} -- ���������� ������� ����. ������������� ����� - ���������� �����, ������������� - ���������� 
           Time     = {} -- ���������� ������� ������ �����. ��� ���������� ����� ������������� ������� �������� �����, ��� ���������� �������� ������� ���������
]]

-- ���������� ����������� ����� �� ������� ������� � ��������� ���������� ������� �������� ��� ������������� � ������
function CurrentWaveType(FastMA, SlowMA, index)
	local typeWave = FastMA[index] - SlowMA[index]; -- ��� ����� ������������ �� ��������� ������� ���������� ������� ������������ ���������
	-- ���� ��� ���������� � ������, �� ����� �� ����������
	if typeWave>0 then return  1; end -- ��� ����� ����������
	if typeWave<0 then return -1; end -- ��� ����� ����������
	return 0;
end

-- ��������� ���������� �� ��� index � ����� ��������� ������������ ����������� ��������
function CheckInZeroZone(FastMA, SlowMA, TriggerSens, index)
	local digits = FastMA:getPrecision();
	local DifferenceMA = NormalizeToDigit(FastMA[index], digits) - NormalizeToDigit(SlowMA[index], digits);
	return IsInChannel(DifferenceMA, 0, TriggerSens);
end

-- �������� ������� �������� ���� � ������ � ��������� middleLevel � ������� 2*TriggerSens
function IsInChannel(Difference, middleLevel, TriggerSens)
	local upLevel = middleLevel + TriggerSens;
	local dnLevel = middleLevel - TriggerSens;
	if Difference<=upLevel and Difference>=dnLevel then
		return true;
	else
		return false;
	end
end
--[[ ������� ���������:
Difference  - ���������� ����� � ���� �� ������ middleLevel
middleLevel - ������� ������� ������
TriggerSens - ����������� ��������� ���������� ����� � ���� �� ������ middleLevel
]]

-- ������� ����� ����������� �������� �� ������� ���� Waves ������� � ����� iStartClear
function ClearWaveSemaphore(Source, Waves, outBuffer, iStartClear, period)
	local i = iStartClear - 1;
	if Waves.Count>0 then
		if iStartClear>1 and iStartClear<=Waves.Count then
			i = iStartClear - 1;
		elseif iStartClear<=1 then
			i = 0;
		elseif iStartClear>Waves.Count then
			if Waves.Count>1 then
				i = Waves.Count - 1;
			else
				i = 0;
			end
		end
		if i>0 then
			if Waves.Value[i]>0 then
				i = core.findDate(Source, Waves.HighTime[i], false) + 1;
			else
				i = core.findDate(Source, Waves.LowTime[i], false) + 1;
			end
		end
	else
		i = 0;
	end
	if i>period then return; end

	while i<=period do
		outBuffer:setNoData(i);
		i = i + 1;
	end
end
--[[ ������� ���������:
Source        - �������� ������� ������ ��������������� �������. ��� bar_stream
Waves         - ������� ����. �������� ������:
                  Count         -- ���������� ����
                  LowVal   = {} -- ���������� ��������� ����
                  LowTime  = {} -- ���������� ������� ���������
                  HighVal  = {} -- ���������� ���������� ����
                  HighTime = {} -- ���������� ������� ����������
                  Value    = {} -- ���������� ������� ����. ������������� ����� - ���������� �����, ������������� - ���������� 
                  Time     = {} -- ���������� ������� ������ �����. ��� ���������� ����� ������������� ������� �������� �����, ��� ���������� �������� ������� ���������
outBuffer     - ��������� ����� ��������������� �������. ��� text_output 
countLastShow - ���������� ������������ ���� � �����
]]

-- ���������� �������� �� ������� ���� Waves � ���������� countLastShow
function DrawWaveSemaphore(Source, Waves, outBuffer, symbol, iStartShow, period)
	local i;
	if Waves.Count>=1 then
		if iStartShow>1 and iStartShow<=Waves.Count then
			i = iStartShow - 1;
		elseif iStartShow<=1 then
			i = 1;
		elseif iStartShow>Waves.Count then
			if Waves.Count>1 then
				i = Waves.Count - 1;
			else
				i = 1;
			end
		end
		
		local index;
		while i<=Waves.Count do
			if Waves.Value[i]>0 then
				index = core.findDate(Source, Waves.HighTime[i], false);
				if index>period then break; end
				outBuffer:set(index, Waves.HighVal[i], symbol, Waves.HighVal[i]);
			else
				index = core.findDate(Source, Waves.LowTime[i], false);
				if index>period then break; end
				outBuffer:set(index, Waves.LowVal[i], symbol, Waves.LowVal[i]);
			end
			i = i + 1;
		end
		
		if i>1 then return i-1; else return 1; end
	else
		return 1;
	end
end
--[[ ������� ���������:
Source     - �������� ������� ������ ��������������� �������. ��� bar_stream
Waves      - ������� ����. �������� ������:
               Count         -- ���������� ����
               LowVal   = {} -- ���������� ��������� ����
               LowTime  = {} -- ���������� ������� ���������
               HighVal  = {} -- ���������� ���������� ����
               HighTime = {} -- ���������� ������� ����������
               Value    = {} -- ���������� ������� ����. ������������� ����� - ���������� �����, ������������� - ���������� 
               Time     = {} -- ���������� ������� ������ �����. ��� ���������� ����� ������������� ������� �������� �����, ��� ���������� �������� ������� ���������
outBuffer  - ��������� ����� ��������������� �������. ��� text_output 
symbol     - ������, ������������ ������� ����/��� �����
iStartShow - � ����� ����� �������� ���������� ��������
period     - ������� ������ ���� �� �������
]]

-- ������������ �����
function NormalizeToDigit(value, digits)
	local retValue = value;
	for i=1,digits,1 do
		retValue = 10.0 * retValue;
	end
	return retValue;
end

-- ���������� ����� �� ������� Waves � ���� ZigZag
function DrawWaveLine(Source, Waves, Out, UpColor, DnColor, iStartShow, period)
	if Waves.Count>=1 then
		local i, j;
		local l, h; -- ���� � ��� �����
		local iLastShowWave = 1;
		
		if iStartShow>1 and iStartShow<=Waves.Count then
			i = iStartShow - 1;
		elseif iStartShow<=1 then
			i = 1;
		elseif iStartShow>Waves.Count then
			if Waves.Count>1 then
				i = Waves.Count - 1;
			else
				i = 1;
			end
		end
		
		-- �������� ���� ����������� ���� � ���� ZigZag
		while i<=Waves.Count do
			if Waves.LowTime[i]~=Waves.HighTime[i] then
				-- core.host:trace("����������� ����� i = ", i); -- ��� �������
				l = core.findDate(Source, Waves.LowTime[i], true);  -- ��� ������
				h = core.findDate(Source, Waves.HighTime[i], true); -- ��� �������
				
				if period>=l and period>=h then
					if Waves.Value[i]>0 then
						-- ���������� ����� ���������� �����
						core.drawLine(Out, core.range(l, h), Waves.LowVal[i], l, Waves.HighVal[i], h);
						-- ���������� ����� ���������� �����
						j = l + 1;
						while j<=h do Out:setColor(j, UpColor); j = j + 1; end
						iLastShowWave = i;
					else
						-- ���������� ����� ���������� �����
						core.drawLine(Out, core.range(h, l), Waves.HighVal[i], h, Waves.LowVal[i], l);
						-- ���������� ����� ���������� �����
						j = h + 1;
						while j<=l do Out:setColor(j, DnColor); j = j + 1; end
						iLastShowWave = i;
					end
				end
			end
			i = i + 1; -- ��������� � ����. �����
		end
		
		-- ������� ����� ������� �������� ���� ������������
		if h>l then j = h + 1; else j = l + 1; end
		while j<=period do
			Out[j] = nil;
			j = j + 1;
		end
		
		return iLastShowWave; -- ���������� ������ ��������� ������������ �����
	else
		return 1;
	end
end
--[[ ������� ���������:
Source     - �������� ������� ������ ��������������� �������. ��� bar_stream
Waves      - ������� ����. �������� ������:
               Count         -- ���������� ����
               LowVal   = {} -- ���������� ��������� ����
               LowTime  = {} -- ���������� ������� ���������
               HighVal  = {} -- ���������� ���������� ����
               HighTime = {} -- ���������� ������� ����������
               Value    = {} -- ���������� ������� ����. ������������� ����� - ���������� �����, ������������� - ���������� 
               Time     = {} -- ���������� ������� ������ �����. ��� ���������� ����� ������������� ������� �������� �����, ��� ���������� �������� ������� ���������
outBuffer  - ��������� ����� ��������������� �������. ��� text_output
UpColor    - ���� ���������� ����
DnColor    - ���� ���������� ����
iStartShow - � ����� ����� �������� �����
period     - ������� ������ ���� �� �������
]]

-- ���������� ���������� ��������� ����� ���� �� ������� Waves
function DrawUpTrendLine(Source, Waves, Color, Style, Width, Length, idStart, iStartShow, ShowAngle, font, period)
	if Waves.Count>=2 then
		local a, b, c, k;
		local i, id;
		local x1, y1, x2, y2, y3; -- ���� � ��� �����
		local ix1, ix2, ix3;
		local newLength;
		local iLastShowWave = 1;
		local angle;

		if iStartShow>1 and iStartShow<=Waves.Count then
			i = iStartShow;
		elseif iStartShow<=1 then
			i = 2;
		elseif iStartShow>Waves.Count then
			if Waves.Count>1 then
				i = Waves.Count;
			else
				return 2;
			end
		end
		
		-- �������� ���� ����������� ��������� �����
		while i<=Waves.Count do
			x1 = Waves.LowTime[i-1]; y1 = Waves.LowVal[i-1];
			x2 = Waves.LowTime[i];   y2 = Waves.LowVal[i];
			if x1<x2 and y1<y2 then
				ix1 = core.findDate(Source, x1, false); -- ��� x1
				ix2 = core.findDate(Source, x2, false); -- ��� x2
				-- ���� ���������� �� ������� �����
				if Length~=1 then
					a, b, c, k = GetLineEquationABCK(ix1, y1, ix2, y2);
					newLength = math.ceil(Length * (ix2 - ix1));
					if ix1+newLength<=period then
						y2 = GetYofABCLine(ix1+newLength, a, b, c);
						x2 = Source:date(ix1+newLength);
					else
						local dtmStartBar, dtmStopBar = core.getcandle(Source:barSize(), Source:date(source:size()-1), core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"));
						local dtmIntervalBar = dtmStopBar - dtmStartBar;
						y2 = GetYofABCLine(ix1+newLength, a, b, c);
						x2 = AddToTimeBarsFromExitDays(source, x1, newLength, dtmIntervalBar, true, period);
					end
				end
				id = idStart + i; -- ��������� ���������� id ��������� ����� �� ������� ������� � idStart
				-- ���������� ����� ���������� �����
				core.host:execute("drawLine", id, x1, y1, x2, y2, Color, Style, Width);
				iLastShowWave = i;
				
				-- ����� ���� ������� ��������� �������� �����
				if ShowAngle then
					ix3 = core.findDate(Source, Waves.HighTime[i], false);
					y3 = Waves.HighVal[i];
					angle = GetAngleTrendLineWave(ix1, y1, ix3, y3, ix2, y2);
					core.host:execute("drawLabel1", id, x2, core.CR_CHART, y2, core.CR_CHART, core.H_Right, core.V_Center, font, Color, string.format("%.1f", angle) .. "\176");
				end
			end
			i = i + 1; -- ��������� � ����. �����
		end
		
		return iLastShowWave; -- ���������� ������ ��������� ������������ �����
	else
		return 2;
	end
end
--[[ ������� ���������:
Source     - �������� ������� ������ ��������������� �������. ��� bar_stream
Waves      - ������� ����. �������� ������:
               Count         -- ���������� ����
               LowVal   = {} -- ���������� ��������� ����
               LowTime  = {} -- ���������� ������� ���������
               HighVal  = {} -- ���������� ���������� ����
               HighTime = {} -- ���������� ������� ����������
               Value    = {} -- ���������� ������� ����. ������������� ����� - ���������� �����, ������������� - ���������� 
               Time     = {} -- ���������� ������� ������ �����. ��� ���������� ����� ������������� ������� �������� �����, ��� ���������� �������� ������� ���������
Color      - ���� ��������� �����
Style      - ����� ��������� �����
Width      - ������ ��������� �����
Length     - ����������� ��������� ��������� �����
idStart    - ������ ��������� ��������� ��� �������������� �����
iStartShow - � ����� ����� �������� �����. ��������� ������ � ������� Waves
ShowAngle  - ���� ����������� ���� �����
font       - ������������ ����� ��� ����������� ���� �����
period     - ������� ������ ���� �� �������
]]

-- ���������� ���������� ��������� ����� ���� �� ������� Waves
function DrawDnTrendLine(Source, Waves, Color, Style, Width, Length, idStart, iStartShow, ShowAngle, font, period)
	if Waves.Count>=2 then
		local a, b, c, k;
		local i, id;
		local x1, y1, x2, y2, y3; -- ���� � ��� �����
		local ix1, ix2, ix3;
		local newLength;
		local iLastShowWave = 1;
		local angle;
		
		if iStartShow>1 and iStartShow<=Waves.Count then
			i = iStartShow;
		elseif iStartShow<=1 then
			i = 2;
		elseif iStartShow>Waves.Count then
			if Waves.Count>1 then
				i = Waves.Count;
			else
				return 2;
			end
		end
		
		-- �������� ���� ����������� ��������� �����
		while i<=Waves.Count do
			x1 = Waves.HighTime[i-1]; y1 = Waves.HighVal[i-1];
			x2 = Waves.HighTime[i];   y2 = Waves.HighVal[i];
			if x1<x2 and y1>y2 then
				ix1 = core.findDate(Source, x1, false); -- ��� x1
				ix2 = core.findDate(Source, x2, false); -- ��� x2
				-- ���� ���������� �� ������� �����
				if Length~=1 then
					a, b, c, k = GetLineEquationABCK(ix1, y1, ix2, y2);
					newLength = math.ceil(Length * (ix2 - ix1)); -- 163
					if ix1+newLength<=period then
						y2 = GetYofABCLine(ix1+newLength, a, b, c);
						x2 = Source:date(ix1+newLength);
					else
						local dtmStartBar, dtmStopBar = core.getcandle(Source:barSize(), Source:date(source:size()-1), core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"));
						local dtmIntervalBar = dtmStopBar - dtmStartBar;
						y2 = GetYofABCLine(ix1+newLength, a, b, c);
						x2 = AddToTimeBarsFromExitDays(source, x1, newLength, dtmIntervalBar, true, period);
					end
				end
				id = idStart + i; -- ��������� ���������� id ��������� ����� �� ������� ������� � idStart
				-- ���������� ����� ���������� �����
				-- core.host:trace("id = " .. id .. "; x1 = " .. core.formatDate(x1) .. "; x2 = " .. core.formatDate(x2));
				core.host:execute("drawLine", id, x1, y1, x2, y2, Color, Style, Width);
				iLastShowWave = i;
				
				-- ����� ���� ������� ��������� �������� �����
				if ShowAngle then
					ix3 = core.findDate(Source, Waves.LowTime[i], false);
					y3 = Waves.LowVal[i];
					angle = GetAngleTrendLineWave(ix1, y1, ix3, y3, ix2, y2);
					core.host:execute("drawLabel1", id, x2, core.CR_CHART, y2, core.CR_CHART, core.H_Right, core.V_Center, font, Color, string.format("%.1f", angle) .. "\176");
				end
			end
			i = i + 1; -- ��������� � ����. �����
		end
		
		return iLastShowWave; -- ���������� ������ ��������� ������������ �����
	else
		return 2;
	end
end
--[[ ������� ���������:
Source     - �������� ������� ������ ��������������� �������. ��� bar_stream
Waves      - ������� ����. �������� ������:
               Count         -- ���������� ����
               LowVal   = {} -- ���������� ��������� ����
               LowTime  = {} -- ���������� ������� ���������
               HighVal  = {} -- ���������� ���������� ����
               HighTime = {} -- ���������� ������� ����������
               Value    = {} -- ���������� ������� ����. ������������� ����� - ���������� �����, ������������� - ���������� 
               Time     = {} -- ���������� ������� ������ �����. ��� ���������� ����� ������������� ������� �������� �����, ��� ���������� �������� ������� ���������
Color      - ���� ��������� �����
Style      - ����� ��������� �����
Width      - ������ ��������� �����
Length     - ����������� ��������� ��������� �����
idStart    - ������ ��������� ��������� ��� �������������� �����
iStartShow - � ����� ����� �������� �����. ��������� ������ � ������� Waves
ShowAngle  - ���� ����������� ���� �����
font       - ������������ ����� ��� ����������� ���� �����
period     - ������� ������ ���� �� �������
]]

-- ��������� ���� ������� barTimePeriod � ���������� countBars � ��������� ������� datetime � ������ �������� �������� ����
function AddToTimeBarsFromExitDays(source, datetime, countBars, barTimePeriod, ignoreAbovePeriod, period)
	if barTimePeriod==nil or barTimePeriod==0 then return nil; end
	local dtm = datetime;
	local countExitDays = 0;  -- ���������� ������������ �������� �������� (� ����� ������� 2 ���)
	local ExitDays = false;  -- ���� �������������� ��������� ������� � �������� ����
	local startTimeExitDays; -- ����� ������ �������� ����, � ���������� ������� ������ ����������� �����
	local dtmIndex = core.findDate(source, dtm, false); -- ������ dtm � source
	local i = 1;
	while i<countBars do
		if ignoreAbovePeriod then
			if dtmIndex+i<=period then
				ExitDays, startTimeExitDays = core.isnontrading(dtm, core.host:execute("getTradingDayOffset"));
			else
				ExitDays = false;
			end
		else
			ExitDays, startTimeExitDays = core.isnontrading(dtm, core.host:execute("getTradingDayOffset"));
		end
		if ExitDays then
			countExitDays = countExitDays + 1;
			dtm = startTimeExitDays + 2;
		end
		dtm = dtm + barTimePeriod;
		i = i + 1;
	end
	return dtm, countExitDays;
end
--[[ ������� ���������:
source            - ����� ������� ������ � ������� ������� ����������� ��������
datetime          - ����� � �������� ���������� ��������� ��������� ��������� ��������������� ������ � ���������� countBars
countBars         - ���������� ����� ������� ���������� ��������� �� ������� datetime
barTimePeriod     - ������ ����, ���������� � ������� ����� �������� ����� ���� � ��� ������
ignoreAbovePeriod - �� ��������� �������� ��� ����� ������� period
period            - ������� ������ �� �������
���������� ��� ��������:
1 - ����� ���������� � ���������� ����������� countBars-����� � �������� barTimePeriod �� ������� datetime � ������ �������� �������� ����
2 - ���������� ������������ �������� ��������
]]

-- ���������� ���������� �������� �������� ����� ����� ����������� �������. �� ���� �������� ������ ������ ��������� ������ ������� � �����������
function CheckExitDays(startTime, stopTime, interval)
	if interval==nil or interval==0 then return nil; end
	local dtm;
	local countExitDays = 0; -- ���������� ������������ �������� �������� (� ����� ������� 2 ���)
	local ExitDays = false;  -- ���� �������������� ��������� ������� � �������� ����
	local startTimeExitDays; -- ����� ������ �������� ����, � ���������� ������� ������ ����������� �����
	dtm = startTime;
	while dtm<=stopTime do
		ExitDays, startTimeExitDays = core.isnontrading(dtm, core.host:execute("getTradingDayOffset"));
		if ExitDays then
			countExitDays = countExitDays + 1;
			dtm = startTimeExitDays + 2;
		else
			dtm = dtm + interval;
		end
	end
	return ExitDays;
end
--[[ ������� ���������:
startTime - ����� �� �������� �������� ������ �������� �������
stopTime  - ����� �� ������� ���������� ��������� ����� �������� ��������
interval  - ��� � ������� ���������� ���������� �� ������� startTime �� ������� stopTime. �� ������ ������������� ������� ���� ����������� �� �������� �������� 
���������� ���������� �������� ��������
]]

-- ���������� k(������� �����������),a,b,� ������ ���������� ����� �������� ��� �����
function GetLineEquationABCK(x1, y1, x2, y2)
	local deltaX, deltaY; -- �������� ��������� �� ������ � �� ��������
	local a, b, c, k;     -- ������������ ��������� ������ � ������� �����������

	deltaX = x2 - x1;                  -- �������� ���������� �� X
	deltaY = y2 - y1;                  -- �������� ���������� �� Y
	a = deltaY;                        -- ���������� a
	b = -deltaX;                       -- b
	c = ( y2*deltaX ) - ( x2*deltaY ); -- c
	k = -a / b;                        -- �������� ������� ����������� ... ����������� �������� ����� ������� �� ��������
	
	return a, b, c, k;
end
--[[ ������� ���������:
x1 - ����� ��� ������ ������ �����
y1 - �������� ������ �����
x2 - ����� ��� ������ ������ �����
y2 - �������� ������ �����
���������� �������� ������������� a, b, c �� ������ ��������� ������ A*x+B*y+C=0 � ������� ����������� k = (y2-y1)/(x2-x1)
]]

-- ������ ���������� Y �� ��������� ������������� �� ������ ��������� ������ A, B, C
function GetYofABCLine(X, a, b, c)
	return (-a * X - c) / b;
end
--[[ ������� ���������:
X - ���������� �� ��� ������
a, b, c - ������������ �� ������ ��������� ������ a*x+b*y+c=0
]]

--  ��������� ����������� ���� ������� ������ (��������� �����) �������������� ���� ������� (���� �����) ����� �� ������ ��������� � �����. �� ������� �� ������������������ �������
function GetAngleTrendLineWave(x1, y1, x2, y2, x3, y3)
	local length  = math.abs(x3 - x1);               -- ��������� ���������� �����
	local correct = math.abs(y2-y3)/math.abs(y2-y1); -- ��������� �������� ���������
	local kF = 1 / math.pow(1.18, length/13);         -- ��������� ����������� ������������
	local angle = 90 * (1-correct) * kF;             -- ����������� ������� ��������� � ������������ ����� � ���� �������
	if y1>y3 then angle = angle * (-1); end
	return angle;
end
--[[ ������� ���������:
x1 - ���������� ������ ����� ����� ���������� �������� ���� ����� ������� ���������� ������
y1 - �������� ������ ����� �����
x2 - ���������� ����� ����� ���������� �������� ���� � ������� ����� �������� ������������� �������
y2 - �������� ����� � ������� ����� �������� ������������� �������
x3 - ���������� ������ ����� ����� ���������� �������� ���� ����� ������� ���������� ������
y3 - �������� ������ ����� �����
]]