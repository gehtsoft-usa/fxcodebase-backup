--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Strategy profile initialization routine
-- Defines Strategy profile properties and Strategy parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    strategy:name("THREE RABBITS ATR");
    strategy:description("Three rabbits with ATR filter");
    strategy:type(core.Both);
    strategy:setTag("NonOptimizableParameters", "SendEmail,PlaySound,Email,SoundFile,RecurrentSound,ShowAlert");

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "Time frame ('m1', 'm5', etc.)", "", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_BARPERIODS);
    
    strategy.parameters:addGroup("Parameters");
    strategy.parameters:addInteger("P1", "ATR Period", "ATR Period", 14);

    strategy.parameters:addGroup("Notification");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", true);
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", true);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

-- strategy instance initialization routine
-- Processes strategy parameters and creates output streams
-- TODO: Calculate all constants, create instances all necessary indicators and load all required libraries
-- Parameters block
local P1;
local gSource = nil; -- the source stream
local PlaySound;
local RecurrentSound;
local SoundFile;
local Email;
local SendEmail;
local atr;
local first;

--TODO: Add variable(s) for your indicator(s) if needed


-- Routine
function Prepare(nameOnly)
    P1 = instance.parameters.P1;
    TF = instance.parameters.TF;
    
    local name = profile:id() .. "(" .. instance.bid:instrument() .. ", " .. tostring(P1) .. ")";
    instance:name(name);

    if nameOnly then
        return ;
    end

    ShowAlert = instance.parameters.ShowAlert;

    PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        RecurrentSound = instance.parameters.RecurrentSound;
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


    gSource = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar"); 
    --TODO: Find indicator's profile, intialize parameters, and create indicator's instance (if needed)
 
    
    --atr = core.indicators:create("ATR", gSource.close, 14);
	atr = core.indicators:create("ATR", gSource, P1);
    first=atr.DATA:first()+2; 
    
    BUY = ("BUY")
    SELL = ("SELL")
    ExtSetupSignal("xx" ..","..TF.. ":", ShowAlert);
    ExtSetupSignalMail("xx");
    
end

-- strategy calculation routine
-- TODO: Add your code for decision making
-- TODO: Update the instance of your indicator(s) if needed
function Calculation(period)
   
   
            if gSource.close[period]> gSource.open[period] 
                  and gSource.close[period-1]> gSource.open[period-1]
                      and gSource.close[period-2]> gSource.open[period-2] then          
            
               return 1;
            
            elseif gSource.close[period]< gSource.open[period] 
                  and gSource.close[period-1]< gSource.open[period-1]
                      and gSource.close[period-2]< gSource.open[period-2] then          
            
               return -1;
            
            end
end

function ExtUpdate(id, source, period)

if period < first   then
        return ;
    end

atr:update(core.UpdateLast);


    if Calculation(period)== 1 and atr.DATA[period]>= atr.DATA[period-1] then   
         ExtSignal(gSource, period, BUY, SoundFile, Email, RecurrentSound);         
               
   elseif Calculation(period)== -1 and atr.DATA[period]<= atr.DATA[period-1] then   
         ExtSignal(gSource, period, SELL, SoundFile, Email, RecurrentSound);            
         
   end


end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");