function Init()
    indicator:name("Test adv_font_lua");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
end

local font;
local timer;
local phase1, phase2, phase3;

function Prepare(onlyName)
    instance:name(profile:id());
    if onlyName then
        return;
    end

    font = core.host:execute ("createFont", "MarketDings", 16, false, false)

    timer = core.host:execute("setTimer", 1, 1);
    phase1 = 0;
    phase2 = 0;
    phase3 = 0;
end

function Update(period, mode)
end

function AsyncOperationFinished(cookie, success, msg)
    if cookie == 1 then
        core.host:execute("drawLabel1", 1, 0, core.CR_RIGHT, 0, core.CR_TOP, core.H_Left, core.V_Bottom, font, core.rgb(255, 0, 0), string.format("%c", 65 + phase1));
        phase1 = (phase1 + 1) % 24;
        core.host:execute("drawLabel1", 2, 0, core.CR_RIGHT, 16, core.CR_TOP, core.H_Left, core.V_Bottom, font, core.rgb(255, 0, 0), string.format("%c", 89 + phase2));
        phase2 = (phase2 + 1) % 24;
        core.host:execute("drawLabel1", 3, 0, core.CR_RIGHT, 32, core.CR_TOP, core.H_Left, core.V_Bottom, font, core.rgb(255, 0, 0), string.format("%c", 113 + phase3));
        phase3 = (phase3 + 1) % 10;
    end
end

function ReleaseInstance()
    core.host:execute("deleteFont", font);
    core.host:execute("killTimer", timer);
end
