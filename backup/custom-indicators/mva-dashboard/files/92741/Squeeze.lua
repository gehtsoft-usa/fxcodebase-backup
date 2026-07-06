-- Id: 11157
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams


function Init()
	indicator:name("Squeeze_DB");
	indicator:description("Squeeze_DB");
	indicator:requiredSource(core.Bar);
	indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("BP", "Bollinger Period", " ", 20);
	indicator.parameters:addDouble("BD", "Bollinger Deviations", " ", 2);
	
	indicator.parameters:addInteger("KP", "Keltner Period", " ", 20);
	indicator.parameters:addDouble("KF", "Keltner Factor", " ", 1.5);
	
	-- ========================= Style ============================= --
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("labelColor", "Labels color", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("yes", "Squeeze Color", " ", core.rgb(0, 0, 255));
	indicator.parameters:addColor("no", "No Squeeze Color", " ", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("Size", "Font Size", " ", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries

-- Parameters block
local BP,BD,KP,KF;
local Size;
local first;
local source = nil;
local yes,no;
local bubble,normal;

-- Streams block
local BBS = nil;

-- Routine
function Prepare(nameOnly)
	BP = instance.parameters.BP;
	BD = instance.parameters.BD;
	KP = instance.parameters.KP;
	KF = instance.parameters.KF;
	Size= instance.parameters.Size;
	source = instance.source;

	

	local name = profile:id() .. "(" .. source:name() .. ", " .. BP  .. ", " .. BD .. ", " .. KP .. ", " .. KF .. ", " .. ")";
	instance:name(name);
	
    if   (nameOnly) then
        return;
    end
	
	normal = core.host:execute("createFont", "Courier", 12, false, false);
    bubble = core.host:execute("createFont", "Wingdings", Size, false, false);
	 
	first = math.max(BP, KP);

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
	local sq;
	
	if period < first or not source:hasData(period) then
		return;
	end
	 
	local Dev = mathex.stdev(source.close, period - BP + 1, period);
	local ATR = core.indicators:create("ATR", source, KP);

	ATR:update(mode);
	
	sq = (Dev * BD) / (ATR.DATA[period] * KF)

	if  (Dev * BD) / (ATR.DATA[period] * KF) < 1 then
    core.host:execute("drawLabel1", 400, 50, core.CR_LEFT, 40, core.CR_TOP, core.H_Right, core.V_Center,
    		bubble, instance.parameters.yes, "\108");
	else
    core.host:execute("drawLabel1", 400, 50, core.CR_LEFT, 40, core.CR_TOP, core.H_Right, core.V_Center,
    		bubble, instance.parameters.no, "\108");
	end
	   
    
end

function ReleaseInstance()
  core.host:execute("deleteFont", normal);
	core.host:execute("deleteFont", bubble);
end
