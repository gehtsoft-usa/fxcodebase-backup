
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65092

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
    indicator:name("Very simple Ichimoku indicator");
    indicator:description("When the price gets out of the kumo (top or bottom, not important), got an sound alert.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addString("INDICATOR", "Indicator", "", "ICH");
    indicator.parameters:setFlag("INDICATOR",core.FLAG_INDICATOR);

	indicator.parameters:addString("INDICATOR_TF", "Indicator Time frame", "", "m1");
    indicator.parameters:setFlag("INDICATOR_TF", core.FLAG_PERIODS);
    
    indicator.parameters:addColor("AlertsColor", "Alerts Stream Color", "", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("Size", "Alert Size", "", 20);
        
    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", false);
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addFile("SoundFile", "Sound File", "", "");
    indicator.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);	
end

local source;           -- the indicator source
local other;            -- the additional data stream
local loading;          -- flag indicating the other data stream is being loaded
local load_from;        -- the date/time the data was loaded the last time from
local instrument;       -- the instrument to be loaded
local first;

local PlaySound, SoundFile;
local Alert;
local AlertColor;
local AlertStream;
local IndicatorInstance = nil;
local gFlagInsideCloud = false;
local Size;
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	
	Size = instance.parameters.Size;

    instrument = source:instrument();
    assert(instance.parameters.INDICATOR_TF ~= "t1", "The time frame must not be tick");
    
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

    AlertStream = instance:createTextOutput ("AlertStream", "AlertStream", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.AlertsColor, 0);
    loading = false;
end

function Update(period, mode)
    local from, to;

    if period < first then
        return ;
    end

    if IndicatorInstance ~= nil then
        IndicatorInstance:update(mode);
    end

    if other == nil then
        -- if the data is not loaded yet at all
        -- load the data
        from = source:date(source:first());   -- oldest data to load
        if source:isAlive() then              -- newest data to load or 0 if the source is "alive"
            to = 0;
        else
            to = source:date(source:size() - 1);
        end
        load_from = from;
        loading = true;
        other = core.host:execute("getHistory", 1, source:instrument(), instance.parameters.INDICATOR_TF, from, to, source:isBid());
        
        local indiProfile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
        local params = instance.parameters:getCustomParameters("INDICATOR");	          
        IndicatorInstance = indiProfile:createInstance(other, params);
        first = math.max(IndicatorInstance.SA:first(), IndicatorInstance.SB:first());
        return ;
    end

    if loading then
        return ;
    end
    

    local curr_date = source:date(period);
    if curr_date < load_from then
        -- if the data we are trying to get is oldest than previously loaded
        -- the extend the history to the oldest data we can request
        from = source:date(source:first());     -- load from the oldest data we have in source
        if other:size() > other:first() then
            to = other:date(other:first());     -- to the oldest data we have in other instrument
        else
            to = load_from;
        end
        load_from = from;
        loading = true;
        core.host:execute("extendHistory", 1, other, from, to);
        return ;
    end

    local sa_period = core.findDate(IndicatorInstance.SA, curr_date, false);
    local sb_period = core.findDate(IndicatorInstance.SB, curr_date, false);
    
    
    local value_sa = IndicatorInstance.SA[sa_period];
    local value_sb = IndicatorInstance.SB[sb_period];
    
    local localCloudInside = false;
    
    if value_sa > value_sb then
        if value_sa > source.close[period] and source.close[period] < value_sb then
            localCloudInside = true;
        else
            localCloudInside = false;
        end
    else
        if value_sb > source.close[period] and source.close[period] < value_sa then
            localCloudInside = true;
        else
            localCloudInside = false;
        end
    end
    
    if gFlagInsideCloud ~= localCloudInside  then 
        if gFlagInsideCloud == true then
            AlertStream:set(period, source.close[period], "\217");           
            SendAlert("Price gets out of the kumo");
            SoundAlert(SoundFile);
        else
            AlertStream:set(period, source.close[period], "\218");
        end
        gFlagInsideCloud = localCloudInside;
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

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        loading = false;
        -- update the indicator output when loading is finished
        instance:updateFrom(first);
        return ;
    end
end