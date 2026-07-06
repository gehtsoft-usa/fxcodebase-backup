-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69151

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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

function AddAverages(id, name, default)
    indicator.parameters:addString(id, name, "", default);
    indicator.parameters:addStringAlternative(id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative(id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative(id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative(id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative(id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative(id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative(id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative(id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative(id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative(id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative(id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative(id, "T3", "", "T3");
    indicator.parameters:addStringAlternative(id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative(id, "Median", "", "Median");
    indicator.parameters:addStringAlternative(id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative(id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative(id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative(id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative(id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative(id, "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative(id, "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative(id, "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative(id, "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative(id, "HPF", "", "HPF");
    indicator.parameters:addStringAlternative(id, "VAMA", "", "VAMA");
end

function CreateAverages(method, source, period)
    if method == "MVA" or method == "EMA" or method == "ARSI" 
        or method == "KAMA" or method == "LWMA" or method == "SMMA"
        or method == "VIDYA"
    then
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period);
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
    return core.indicators:create("AVERAGES", source, method, period);
end

function Init()
    indicator:name("Averages histogram");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    AddAverages("first_method", "First method", "MVA");
    indicator.parameters:addInteger("first_period", "First period", "", 20);

    AddAverages("second_method", "Second method", "MVA");
    indicator.parameters:addInteger("second_period", "Second period", "", 100);

    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb( 0, 255, 0));
    indicator.parameters:addColor("UpDown", "Color of UpDown", "Color of UpDown", core.rgb(255, 125, 125));
	indicator.parameters:addColor("DownUp", "Color of DownUp", "Color of DownUp", core.rgb(125, 255, 125));
    indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
end

local source, ma1, ma2, out;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    ma2 = CreateAverages(instance.parameters.first_method, source, instance.parameters.first_period);
    ma1 = CreateAverages(instance.parameters.second_method, source, instance.parameters.second_period);

    out = instance:addStream("out", core.Bar, "Histohram", "Histogram", instance.parameters.Up, 0, 0);
end

function Update(period, mode)
    ma1:update(mode);
    ma2:update(mode);
    if not ma1.DATA:hasData(period) or not ma2.DATA:hasData(period) then
        return;
    end

    out[period] =  ma2.DATA[period]-ma1.DATA[period]  ;
	
	
	 if ma1.DATA[period] >= ma2.DATA[period-1]  then
						
						     if ma2.DATA[period] >= ma2.DATA[period-1]then
					          out:setColor(period, instance.parameters.Up); 
					     	 else
						      out:setColor(period, instance.parameters.UpDown); 
							  end
						 
						
	else
						
						      if ma2.DATA[period] >= ma2.DATA[period-1]then
					          out:setColor(period, instance.parameters.DownUp); 
					     	 else
						      out:setColor(period, instance.parameters.Down); 
							  end
						
					   
	end
end