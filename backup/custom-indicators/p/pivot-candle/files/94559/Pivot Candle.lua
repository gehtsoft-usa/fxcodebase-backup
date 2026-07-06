-- Id: 12006
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60830

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Pivot Candle");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addColor("clrUP", "Up Color","", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", "Down Color","", core.COLOR_DOWNCANDLE);
    indicator.parameters:addBoolean("ShowPrice", "Show Price","", false);
    indicator.parameters:addColor("clrPrice", "Label Color","", core.rgb(128, 128, 128));
end

local source;
local up, down;

function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    up = instance:createTextOutput ("Up", "Up", "Wingdings", 9, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", 9, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
    up1 = instance:createTextOutput ("", "UpL", "Verdana", 7, core.H_Right, core.V_Top, instance.parameters.clrPrice, 0);
    down1 = instance:createTextOutput ("", "DnL", "Verdana", 7, core.H_Right, core.V_Bottom, instance.parameters.clrPrice, 0);
end

function Update(period, mode)
 
    if (period < 3) then
	return;
	end
	
	 period = period-1;
	
        local High = source.high[period ];
		local Low = source.low[period ];
		
        if (High > source.high[period +1] and High > source.high[period -1] and
            Low > source.low[period +1] and Low > source.low[period -1]) then
            up:set(period , source.high[period  ], "\217", source.high[period  ]);
            if instance.parameters.ShowPrice then
                up1:set(period  , source.high[period  ], "  " .. source.high[period  ]);
            end
        else
            up:setNoData(period  );
            up1:setNoData(period );
        end
         
        if (High < source.high[period +1] and High < source.high[period -1] and
            Low < source.low[period +1] and Low < source.low[period -1] ) then
            down:set(period  , source.low[period  ], "\218", source.low[period  ]);
            if instance.parameters.ShowPrice then
                down1:set(period  , source.low[period  ], "  " .. source.low[period  ]);
            end
        else
            down:setNoData(period );
             down1:setNoData(period );
        end
    
end
