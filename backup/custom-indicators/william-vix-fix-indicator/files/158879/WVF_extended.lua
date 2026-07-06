--
-- "WVF_extended.lua"
--

-- Developed further from original indicator here:
-- Id: 4548 http://fxcodebase.com/code/viewtopic.php?f=17&t=6362

--
-- The indicator formula developed by Larry Williams mimics the VIX calculation which measures downside volatility
-- This code extends the idea to include the inverse upside volatility
-- The application can be more suited to markets which may have volatility in both directions such as currency pairs, or commodities 
-- Options are provided to view volatility difference (upside-downside) or average volatility (upside+downside)/2
-- A short term optional RSI is also included
--


-- code version, revision and author - update if you publish changes
local NAME = "WVF Extended"
local DESCRIPTION = "William VIX Fix indicator with extended modes"
local VERSION = 1
local REVISION = 0
local DATE = "06/04/2025"
local REV_AUTHOR = "Steve_W"    -- for this revision
local VERSION_TXT = "v" .. VERSION .. "." .. REVISION .. " " .. DATE

-- revision history - update+add to history if you publish changes, improvements or bug fixes
-- 06/04/2025 v1.0 Steve_W - first release


-- global list constants
local DISPLAY_MODE = {"Downside", "Upside", "Upside-Downside", "Average Upside & Downside"}
local LINE_BAR = {"Line", "Bar"}

-- global constants
local LABEL_COLOUR = core.rgb(192, 255, 0)
local GREY_COLOUR = core.rgb(128, 128, 128)
local BLUE_COLOUR = core.rgb(0, 128, 255)


function Init()
    local param = indicator.parameters
	
	indicator:name(NAME)
    indicator:description(DESCRIPTION)
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)
	
    param:addGroup("Calculation")
    param:addInteger("period", "Lookback Period", "", 22, 0, 1000)
	Add_list("display_mode", "Display Mode", "", "Downside", DISPLAY_MODE)
	param:addBoolean("add_rsi", "Add RSI to Calculation", "volatility output is passed through a RSI", false)
	param:addInteger("rsi_length", "RSI Length", "", 3, 2, 1000)
	
	param:addGroup("Style")
	Add_list("line_bar", "Line or Bar", "", "Line", LINE_BAR)
	param:addInteger("line_width", "Line width", "", 2, 1, 5)
    param:addInteger("line_style", "Line style", "", core.LINE_SOLID)
    param:setFlag("line_style", core.FLAG_LINE_STYLE)
    param:addColor("indicator_colour", "Indicator Colour", "", BLUE_COLOUR)
	param:addInteger("upper_rsi_level", "Upper RSI Level", "", 70, 50, 100)
	param:addInteger("lower_rsi_level", "Lower RSI Level", "", 30, 0, 50)   
    param:addColor("level_colour", "Level Colour", "", GREY_COLOUR)
	
	param:addGroup("About")
    param:addString("version", "Version", "Code for this revision by " .. REV_AUTHOR, VERSION_TXT)
end


-- global variables
local source = {}
local wvf = {}
local wvf_internal = {}	
local rsi_internal = {}
local first


-- initialisation
function Prepare(name_only)
	local param = instance.parameters
 	
	source = instance.source
    first = source:first() + math.max(param.period, param.rsi_length)

    local name = ""
	if param.add_rsi == true then name = "RSI(" end
	name = name .. profile:id() .. "(" .. source:name() .. ", " .. param.display_mode .. ", " .. param.period .. ")"
	if param.add_rsi == true then name = name .. ", " .. param.rsi_length .. ")" end
    instance:name(name)
	if name_only then return end
	
	instance:setLabelColor(LABEL_COLOUR)
	
	wvf_internal = instance:addInternalStream(first, 0)
	if param.add_rsi == true then rsi_internal = core.indicators:create("RSI", wvf_internal, param.rsi_length) end
	
    if param.line_bar == "Line" or param.add_rsi == true then	-- RSI must be line
		wvf = instance:addStream("wvf", core.Line, name, "WVF", param.indicator_colour, first)
		wvf:setWidth(instance.parameters.line_width)
		wvf:setStyle(instance.parameters.line_style)
	elseif param.line_bar == "Bar" then
		wvf = instance:addStream("wvf", core.Bar, name, "WVF", param.indicator_colour, first)
	end
    wvf:setPrecision(2)
	if param.add_rsi == true then
		wvf:addLevel(param.upper_rsi_level, core.LINE_SOLID, param.line_width, param.level_colour)
		wvf:addLevel(param.lower_rsi_level, core.LINE_SOLID, param.line_width, param.level_colour)	
	else
		wvf:addLevel(0, core.LINE_SOLID, param.line_width, param.level_colour)
	end
end


-- calculation
function Update(period, mode)
	local param = instance.parameters
	if period < first  then return end
	
	local downside_vol = ((mathex.max(source.close, period - param.period, period) - source.low[period])	-- Larry Williams original formula
							/ mathex.max(source.close, period - param.period, period)) * 100
	local upside_vol = -((mathex.min(source.close, period - param.period, period) - source.high[period])	-- inverted formula to extend the idea
							/ mathex.min(source.close, period - param.period, period)) * 100

	if param.display_mode == "Upside" then wvf_internal[period] = upside_vol
	elseif param.display_mode == "Downside" then wvf_internal[period] = downside_vol
	elseif param.display_mode == "Upside-Downside" then wvf_internal[period] = upside_vol - downside_vol
	elseif param.display_mode == "Average Upside & Downside" then wvf_internal[period] = (upside_vol + downside_vol) / 2
	end
	
	if param.add_rsi == true then
		rsi_internal:update(mode)
		wvf[period] = rsi_internal.DATA[period]
	else
		wvf[period] = wvf_internal[period]
	end
end


-- add a string list parameter
function Add_list(param, param_txt, param_explain, param_default, param_list)
    indicator.parameters:addString(param, param_txt, param_explain, param_default)
    for i = 1, #param_list, 1 do
        indicator.parameters:addStringAlternative(param, param_list[i], "", param_list[i])
    end
end

