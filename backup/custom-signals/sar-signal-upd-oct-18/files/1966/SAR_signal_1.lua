-- Id: 2008
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    strategy:name("Simple SAR signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signals when SAR changes the direction");

    strategy.parameters:addGroup("SAR parameters");
    strategy.parameters:addDouble("Step", "Step", "", 0.02, 0.001, 1);
    strategy.parameters:addDouble("Max", "Max", "", 0.2, 0.001, 10);

    strategy.parameters:addGroup("Price parameters");
    strategy.parameters:addString("Period", "Time frame", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signal parameters");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound file", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("Recurrent", "RecurrentSound", "", false);

    strategy.parameters:addGroup("Email Parameters");
    strategy.parameters:addBoolean("SendEmail", "Send email", "", false);
    strategy.parameters:addString("Email", "Email address", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SAR;
local gSource;

local SoundFile;
local RecurrentSound;
local Email;
local ShowAlert;
local name;


-- Routine
function Prepare(onlyName)
    local Step;
    local Max;
    local ExplosionPower;

    Step = instance.parameters.Step;
    Max = instance.parameters.Max;

    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");

    RecurrentSound = instance.parameters.Recurrent;
    local SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");


    name = profile:id() .. "(" .. instance.bid:instrument()  .. "," .. Step .. "," .. Max .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    assert(instance.parameters.Period ~= "t1", "Can't be applied on ticks!");

    gSource = ExtSubscribe(1, nil, instance.parameters.Period, true, "bar");
    SAR = core.indicators:create("SAR", gSource, Step, Max);
end

function ExtUpdate(id, source, period)
    if id == 1 then
        SAR:update(core.UpdateLast);
        if period >= SAR.DATA:first() + 1 then
            local message = nil;

            if not(SAR.DN:hasData(period - 1)) and SAR.DN:hasData(period) then
                message = "SAR switched down";
            elseif not(SAR.UP:hasData(period - 1)) and SAR.UP:hasData(period) then
                message = "SAR switched up";
            end

            if message ~= nil then
               if ShowAlert then
                   terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], message, instance.bid:date(NOW));
               end

               if SoundFile ~= nil then
                   terminal:alertSound(SoundFile, RecurrentSound);
               end

               if Email ~= nil then
                   terminal:alertEmail(Email, name, name .. "(" .. core.formatDate(instance.bid:date(NOW)) .. ") : " .. message);
               end
            end
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
