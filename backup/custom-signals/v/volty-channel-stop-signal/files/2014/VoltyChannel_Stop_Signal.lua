-- Id: 7071
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
    strategy:name("Volty Channel Stop");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");

    strategy.parameters:addInteger("MA_N", "Moving Average Period", "", 1);
    strategy.parameters:addString("MA_M", "Moving Average Method", "The methods marked by an asterisk (*) require the appropriate strategys to be loaded.", "MVA");
    strategy.parameters:addStringAlternative("MA_M", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("MA_M", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("MA_M", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("MA_M", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("MA_M", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("MA_M", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("MA_M", "Wilders*", "", "WMA");
    strategy.parameters:addInteger("ATR_N", "ATR period", "", 10);
    strategy.parameters:addDouble("VF", "Volatility's Factor or Multiplier", "", 4);
    strategy.parameters:addInteger("OF", "Offset factor", "", 0);
    strategy.parameters:addString("P", "Price", "The price to the strategy apply to", "C");
    strategy.parameters:addStringAlternative("P", "Open", "", "O");
    strategy.parameters:addStringAlternative("P", "High", "", "H");
    strategy.parameters:addStringAlternative("P", "Low", "", "L");
    strategy.parameters:addStringAlternative("P", "Close", "", "C");
    strategy.parameters:addStringAlternative("P", "Median", "", "M");
    strategy.parameters:addStringAlternative("P", "Typical", "", "T");
    strategy.parameters:addStringAlternative("P", "Weighted", "", "W");
    strategy.parameters:addBoolean("HiLoE", "Use High/Low envelope", "", false);
    strategy.parameters:addBoolean("HiLoB", "Hi/Lo Break", "", true);

    strategy.parameters:addString("Period", "Time frame", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound file", "", "");
   
   
   strategy.parameters:addGroup("Email Parameters");
   strategy.parameters:addBoolean("SendEmail", "Send email", "", false);
    strategy.parameters:addString("Email", "Email address", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local Email;

local gSource;
local VC, VCU, VCD;

function Prepare()


    local SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
   
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");

    local ShowAlert;

    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    assert(instance.parameters.Period ~= "t1", "Can't be applied on ticks!");
    gSource = ExtSubscribe(1, nil, instance.parameters.Period, true, "bar");

    local iprofile = core.indicators:findIndicator("VOLTYCHANNEL_STOP");
    assert(iprofile ~= nil, "VOLTYCHANNEL_STOP indicator is not installed");
    local iparams = iprofile:parameters();
    iparams:setInteger("MA_N", instance.parameters.MA_N);
    iparams:setString("MA_M", instance.parameters.MA_M);
    iparams:setInteger("ATR_N", instance.parameters.ATR_N);
    iparams:setDouble("VF", instance.parameters.VF);
    iparams:setInteger("OF", instance.parameters.OF);
    iparams:setString("P", instance.parameters.P);
    iparams:setBoolean("HiLoE", instance.parameters.HiLoE);
    iparams:setBoolean("HiLoB", instance.parameters.HiLoB);
    VC = iprofile:createInstance(gSource, iparams);
    VCU = VC:getStream(0);
    VCD = VC:getStream(1);
    local name = profile:id() .. "(" .. gSource:name() .. ", " .. instance.parameters.MA_N .. ", " .. instance.parameters.MA_M .. ", " .. instance.parameters.ATR_N .. ", " .. instance.parameters.VF .. ", " .. instance.parameters.OF .. ", " .. instance.parameters.P .. ")";
    instance:name(name);
end

function ExtUpdate(id, source, period)
    if id == 1 and period > 1 then
        VC:update(core.UpdateLast);
        if not(VCU:hasData(period - 1)) and VCU:hasData(period) then
            ExtSignal(gSource, period, "VoltiChannel Switched", SoundFile);
         
         if Email ~= nil then
            terminal:alertEmail (Email, "Open Short Position ", "Volty Channel Stop Open Short Position")
         end
         
        elseif not(VCD:hasData(period - 1)) and VCD:hasData(period) then
            ExtSignal(gSource, period, "VoltiChannel Switched", SoundFile);
         
         if Email ~= nil then
            terminal:alertEmail (Email, "Open Long Position ", "Volty Channel Stop Open Long Position")
         end
         
         
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");