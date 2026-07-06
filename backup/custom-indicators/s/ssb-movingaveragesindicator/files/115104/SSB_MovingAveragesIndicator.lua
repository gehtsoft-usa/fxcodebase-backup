-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65119

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("SSB/moving average crossing with alert");
    indicator:description("Indicator with alert that indicates the crossing of a moving average (sma, ema) with the senkou span B.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addString("INDICATOR", "Indicator", "", "ICH");
    indicator.parameters:setFlag("INDICATOR",core.FLAG_INDICATOR);

	indicator.parameters:addString("MA_INDICATOR", "MA Indicator", "", "MVA");
    indicator.parameters:setFlag("MA_INDICATOR",core.FLAG_INDICATOR);
    
--	indicator.parameters:addString("INDICATOR_TF", "Indicator Time frame", "", "m1");
   -- indicator.parameters:setFlag("INDICATOR_TF", core.FLAG_PERIODS);
    
    indicator.parameters:addColor("AlertsColor", "Alerts Stream Color", "", core.rgb(0, 255, 0));
        
    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", false);
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addFile("SoundFile", "Sound File", "", "");
    indicator.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);	
end

local source;
local loading;
local first;

local PlaySound, SoundFile;
local Alert;
local AlertColor;
local AlertStream;
local IndicatorInstance = nil;
local MAIndicatorInstance = nil;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first();

    instrument = source:instrument();
   -- assert(instance.parameters.INDICATOR_TF ~= "t1", "The time frame must not be tick");
    
    local name;
    name = profile:id() .. "(" .. instrument .. ")";
    instance:name(name);
   
   
    if   (nameOnly) then
        return;
    end
	
    
    PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be chosen"); 
    RecurrentSound = instance.parameters.RecurrentSound;

    name = instrument .. "(" .. source:barSize() .. ",";
    if source:isBid() then
        name = name .. "bid" .. ")";
    else
        name = name .. "ask" .. ")";
    end
   
    local indiProfile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
    local params = instance.parameters:getCustomParameters("INDICATOR");	          
    IndicatorInstance = indiProfile:createInstance(source, params);
    
    indiProfile = core.indicators:findIndicator(instance.parameters:getString("MA_INDICATOR"));
    params = instance.parameters:getCustomParameters("MA_INDICATOR");
    MAIndicatorInstance = indiProfile:createInstance(source, params);	  
            
    first = math.max(MAIndicatorInstance.DATA:first(), IndicatorInstance.SB:first());    
    
    AlertStream = instance:createTextOutput ("AlertStream", "AlertStream", "Wingdings 2", 15, core.H_Center, core.V_Top, instance.parameters.AlertsColor, 0);
end

function Update(period, mode)

    MAIndicatorInstance:update(mode);
    IndicatorInstance:update(mode);


    if period > first then
       if core.crosses(MAIndicatorInstance.DATA, IndicatorInstance.SB, period) then
           
        AlertStream:set(period, source.close[period], "\86");           
        SendAlert("Price gets out of the kumo");
        SoundAlert(SoundFile);            
       end
    end
end

function SendAlert(message)
    if not ShowAlert then
        return;
    end
 
    terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end
 
    terminal:alertSound(Sound, RecurrentSound);
end