function Init()
    indicator:name("EntryStop");
    indicator:description("Trade Entry and Stop Loss Planer");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup		("Right Click Chart to Plan Entry and Stop Loss");
    indicator.parameters:addString          ("Account", "Account", "Account.", "");
    indicator.parameters:setFlag            ("Account", core.FLAG_ACCOUNT);
    indicator.parameters:addGroup		("Style");
	indicator.parameters:addColor			("EntryColor", "Entry", "Entry", core.rgb(0, 255, 0));
    indicator.parameters:addColor			("StopColor", "Stop", "Stop", core.rgb(255, 0, 0));
end

local host                                  = nil;
local Account                               = nil;
local AccountRow                            = nil;
local Instrument                            = nil;
local source                                = nil;
local first                                 = nil;
local name                                  = nil;
local db                                    = nil;
local Period								= nil;
local font									= nil;
local EntryColor                            = nil;
local StopColor                             = nil;
local DateFirst                               = nil;
local DateNow                                 = nil;
local PositionEntry                     = nil;
local PositionStop                      = nil;


function Prepare(nameOnly)
    
    if nameOnly then return ; end
    host                                    = core.host;
    source                                  = instance.source;
    first                                   = source:first();
    local name                              = "EntryStop (" .. source:name()  .. ")";
    instance:name(name);
    instance:ownerDrawn(true);
    Account                                 = instance.parameters.Account;
    AccountRow                              = host:findTable("accounts"):find("AccountID", Account);
    ContractSize 							= core.host:findTable("offers"):find("Instrument", source:instrument()).ContractSize;
    EntryColor                              = instance.parameters.EntryColor;
    StopColor                               = instance.parameters.StopColor;
	Size 									= instance.parameters.Size;
	Period 									= instance.parameters.Period;
    font 									= core.host:execute("createFont", "Arial", 8, true, false);

    require("storagedb")
    db  = storagedb.get_db(name);
    db:put(tostring("Selected"), tostring(1));	
    core.host:execute ("addCommand", 1, "Mark Entry", "");	 
    core.host:execute ("addCommand", 2, "Mark Stop", "");
    core.host:execute ("addCommand", 3, "Reset", "");	
    PositionEntry                     = tonumber(db:get (tostring("1Position"), 0));
    PositionStop                      = tonumber(db:get (tostring("2Position"), 0));


end

function Update(period)
    local accounts                          = core.host:findTable("accounts");
    local enum                              = accounts:enumerator();
    local row                               = enum:next();
    DateFirst                               = source:date(first)
    DateNow                                 = source:date(period)
    
    core.host:execute   ("drawLabel1", 11, source:date(period) , core.CR_CHART, PositionEntry, core.CR_CHART, core.H_Right, core.V_Top   ,font, core.COLOR_LABEL, "  Entry "    .. PositionEntry);					
    core.host:execute   ("drawLabel1", 21, source:date(period) , core.CR_CHART, PositionStop,  core.CR_CHART, core.H_Right, core.V_Top   ,font, core.COLOR_LABEL, "  Stop - "   .. PositionStop );					
end

function Draw(stage, context)

    DrawLines()

end

function DrawLines()
    
    core.host:execute   ("drawLine", 10, DateFirst, PositionEntry, DateNow, PositionEntry, instance.parameters.EntryColor);				
    core.host:execute	("drawLine", 20, DateFirst, PositionStop,  DateNow, PositionStop,  instance.parameters.StopColor);				

end
function Parse(message)
    if message == nil then
        return 0, 0;	 
    end
    local level, date;
    level, date = string.match(message, "([^;]*);([^;]*)", 0);
    if level == nil or date == nil then
        return 0, 0;	 
    end
	return tonumber(date),tonumber(level);
end

function AsyncOperationFinished(cookie, success, message)
    if 	cookie < 3 then
        db:put(tostring("Selected"),            tonumber(cookie));
        local Selected                          = tonumber(db:get ("Selected", 0));
        local Date, Level                       = Parse(message);
		db:put(tostring(Selected.."Position"),  tostring(Level));	
	else	 
        db:put(tostring("1Position"),           tostring(0));			  
        db:put(tostring("2Position"),           tostring(0));
    end
    Selected = tonumber(db:get ("Selected", 0));
    PositionEntry                     = tonumber(db:get (tostring("1Position"), 0));
    PositionStop                      = tonumber(db:get (tostring("2Position"), 0));

    return core.ASYNC_REDRAW;
end

function ReleaseInstance()
    core.host:execute("deleteFont", font);
end
