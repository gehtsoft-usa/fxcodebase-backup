-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59688
-- Id: 10250

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
	indicator:name("Since Cross");
	indicator:requiredSource(core.Tick);
	indicator:type(core.Indicator);
	
	 indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addBoolean("Show"  , "Show Labels", "", false);	
	indicator.parameters:addBoolean("Show_MA"  , "Show MA", "", true);	
	indicator.parameters:addInteger("Period","MA Period","",200,1,395);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");	
	indicator.parameters:addColor("CCclr1","Color","",core.rgb(255,0,0));
	indicator.parameters:addColor("Label","Label Color","",core.rgb(0,0,0));
	indicator.parameters:addInteger("Size","Font Size","",10);
end
    local Show_MA;
	local source = nil;
	local first;
	local PipSize;
	local Period;
	local Level;
	local CCclr1;
	local MA = nil;
	local Central = nil;
	local Level1 = nil;
	local Level2 = nil;
	local Count = nil;
	local Tc = nil;
    local font;
    local Show;
	local Size;
	local Method;
function Prepare(onlyName)
	source = instance.source;
 
	PipSize = source:pipSize();
	Period= instance.parameters.Period;
	Size= instance.parameters.Size;
	Show_MA = instance.parameters.Show_MA;
	Show = instance.parameters.Show;
	Method = instance.parameters.Method;
	CCclr1 = instance.parameters.CCclr1;
	
	local name = profile:id() .. "(" .. source:name().. ", " .. Period.. ", " .. Method ..  ")";
	instance:name(name);
	if onlyName then
		return;
	end
	Count = instance:addInternalStream(0,0);
     font = core.host:execute("createFont", "Arial", Size, true, false);

    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method,source,Period);

	if Show_MA then 
	Central = instance:addStream("Central",core.Line,name.."","Central",CCclr1, MA.DATA:first()  )
	else
	Central = instance:addInternalStream(0, 0);
    end
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end

function Update(period,mode)
	MA:update(mode);
	if period <= MA.DATA:first() then
	return;
	end
	Central[period] = MA.DATA[period];
	     
	   
		if source[period] < MA.DATA[period] and source[period-1]>MA.DATA[period-1] then
			Count[period] =  -1;
		elseif source[period] > MA.DATA[period]  and source[period-1] < MA.DATA[period-1]then
			Count[period] = 1; 		
	
		end
		
		
		if math.abs(Count[period]) ~= 1 then
			if source[period]> Central[period] then
			 Count[period] = Count[period-1]+1;
			else
			 Count[period] = Count[period-1]-1;
			end
		end
		
		  if Show    then
	    core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART,MA.DATA[period], core.CR_CHART, core.H_Center, core.V_Center,
                             font, instance.parameters.Label,  string.format("%." .. 0 .. "f", Count[period])  );
	  elseif  math.abs(Count[period-2]) >=  math.abs( Count[period-1]) then
        core.host:execute("drawLabel1", source:serial(period-2), source:date(period-2), core.CR_CHART,MA.DATA[period], core.CR_CHART, core.H_Center, core.V_Center,
                             font, instance.parameters.Label,  string.format("%." .. 0 .. "f", Count[period-2])  );
	  end 

	  
	  if period==source:size()-1 then
	  core.host:execute("drawLabel1", 1, source:date(period), core.CR_CHART,MA.DATA[period], core.CR_CHART, core.H_Center, core.V_Center,
                             font, instance.parameters.Label,  string.format("%." .. 0 .. "f", Count[period])  );
     end
end