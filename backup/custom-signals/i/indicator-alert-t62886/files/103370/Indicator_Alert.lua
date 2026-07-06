-- Id: 15079
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
    strategy:name("Indicator alert");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Alerts when a certain indicator/oscillator crosses a certain level");

    strategy.parameters:addGroup("Parameters");

    strategy.parameters:addString("Indicator", "Indicator", "", "MVA");
    strategy.parameters:setFlag("Indicator", core.FLAG_INDICATOR);

    strategy.parameters:addInteger("Index", "Index of stream", "The number of the indicator stream (for indicators with more than one output stream, e.g. MACD).", 1, 1, 30);
 
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addDouble("Price","Price Level", "", 0);
    strategy.parameters:setFlag("Price", core.FLAG_PRICE);

    strategy.parameters:addString("Condition", "Condition", "", "C");
    strategy.parameters:addStringAlternative("Condition", "Crosses", "", "C");
    strategy.parameters:addStringAlternative("Condition", "Crosses or touches", "", "CT");
    strategy.parameters:addStringAlternative("Condition", "Crosses above", "", "CA");
    strategy.parameters:addStringAlternative("Condition", "Crosses above or touches", "", "CAT");
    strategy.parameters:addStringAlternative("Condition", "Crosses below", "", "CB");
    strategy.parameters:addStringAlternative("Condition", "Crosses below or touches", "", "CBT");

    strategy.parameters:addString("Period", "Period size", "", "t1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Notification");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false);
    strategy.parameters:addString("Email", "E-mail address", "Note that to recieve e-mails, SMTP settings must be defined (see Signals Options).", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);


end

local SoundFile;
local gSource = nil;        -- the source stream
local indi = nil;

local CT_CROSS = 1;
local CT_CROSSTOUCH = 2;
local CT_CROSSABOVE = 3;
local CT_CROSSABOVETOUCH = 4;
local CT_CROSSBELOW = 4;
local CT_CROSSBELOWTOUCH = 5;
local Price;
local gCondition;
local SendEmail, Email;
local index;
local indiStream;


function Prepare()
    local Condition;

    -- collect parameters
    ShowAlert = instance.parameters.ShowAlert;
    Price = instance.parameters.Price;
    Condition = instance.parameters.Condition;
    local Period = instance.parameters.Period;
    index = instance.parameters.Index;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");

    SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
 
    SIGNAL = "Condition met";

    local indiProfile = core.indicators:findIndicator(instance.parameters.Indicator);

    ExtSetupSignal(indiProfile:name() .. " Alert: ", ShowAlert);

    if indiProfile:requiredSource() == core.Bar and Period == "t1" then
        error(indiProfile:name() .. " cannot be applied on Tick, please change the parameter Period size.");
    end

    if Period == "t1" then
        gSource = ExtSubscribe(1, nil, Period, instance.parameters.Type == "Bid", "close");
    else
        gSource = ExtSubscribe(1, nil, Period, instance.parameters.Type == "Bid", "bar");
    end

	if indiProfile:requiredSource() == core.Bar  and Period ~= "t1" then
    indi = indiProfile:createInstance(gSource, instance.parameters:getCustomParameters("Indicator"));
	else
	 indi = indiProfile:createInstance(gSource.close, instance.parameters:getCustomParameters("Indicator"));
	end
                                                                                                                   	
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. Period  .. ")" .. ", " .. instance.parameters.Indicator .. ")";
    instance:name(name);
    
    local streamCount = indi:getStreamCount();

    assert((index <= streamCount), "Incorrect index of stream. The indicator has only ".. streamCount .. " stream(s).");

    indiStream = indi:getStream(index-1);

    if Condition == "C" then
        gCondition = CT_CROSS;
        SIGNAL = "Indicator crosses the specified level";
    elseif Condition == "CT" then
        gCondition = CT_CROSSTOUCH;
        SIGNAL = "Indicator crosses or touches the specified level";
    elseif Condition == "CA" then
        gCondition = CT_CROSSABOVE;
        SIGNAL = "Indicator crosses above the specified level";
    elseif Condition == "CAT" then
        gCondition = CT_CROSSABOVETOUCH;
        SIGNAL = "Indicator crosses above or touches the specified level";
    elseif Condition == "CB" then
        gCondition = CT_CROSSBELOW;
        SIGNAL = "Indicator crosses below the specified level";
    elseif Condition == "CBT" then
        gCondition = CT_CROSSBELOWTOUCH;
        SIGNAL = "Indicator crosses below or touches the specified level";
    end

   ExtSetupSignalMail(name);
end

-- when tick source is updated
function ExtUpdate(id, source, period)
    -- update indicator

     
        indi:update(core.UpdateLast);
   

    if (indiStream:hasData(period - 1))  then

        if gCondition == CT_CROSS and core.crosses(indiStream, Price, period) then
            ExtSignal(gSource, period, SIGNAL, SoundFile, Email);
        elseif gCondition == CT_CROSSTOUCH and (core.crosses(indiStream, Price, period) or indiStream[period] == Price) then
            ExtSignal(gSource, period, SIGNAL, SoundFile, Email);
        elseif gCondition == CT_CROSSABOVE and core.crossesOver(indiStream, Price, period) then
            ExtSignal(gSource, period, SIGNAL, SoundFile, Email);
        elseif gCondition == CT_CROSSABOVETOUCH and (core.crossesOver(indiStream, Price, period) or indiStream[period] == Price) then
            ExtSignal(gSource, period, SIGNAL, SoundFile, Email);
        elseif gCondition == CT_CROSSBELOW and core.crossesUnder(indiStream, Price, period) then
            ExtSignal(gSource, period, SIGNAL, SoundFile, Email);
        elseif gCondition == CT_CROSSBELOWTOUCH and (core.crossesUnder(indiStream, Price, period) or indiStream[period] == Price) then
            ExtSignal(gSource, period, SIGNAL, SoundFile, Email);
        end
    end

end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
