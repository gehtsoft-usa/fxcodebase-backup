-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=11079&p=116472#p116472

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("Candle LookBack Period");
    indicator:description("The indicator draws three vertical lines for the specified Candles");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("1. Line Parameters");
	indicator.parameters:addInteger("minute1", "LookBack Period", "", 9);
	 	 
	indicator.parameters:addGroup("2. Line Parameters");  
	indicator.parameters:addInteger("minute2", "LookBack Period", "", 13);
		 
	indicator.parameters:addGroup("3. Line Parameters");
	indicator.parameters:addInteger("minute3", "LookBack Period", "", 21);	  
	  
    indicator.parameters:addGroup("1. Line Style");
    indicator.parameters:addColor("clr1", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("width1", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	 indicator.parameters:addGroup("2. Line Style");
    indicator.parameters:addColor("clr2", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("width2", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
	 indicator.parameters:addGroup("3. Line Style");
    indicator.parameters:addColor("clr3", "Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addInteger("width3", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);
end

local source;
local host;
local clr1, clr2, clr3, width, style;
local minute1, minute2, minute3;
local Size;

function Prepare(onlyname)
    source = instance.source;
    clr1 = instance.parameters.clr1;
    width1 = instance.parameters.width1;
    style1 = instance.parameters.style1;
	
	minute1 = - (instance.parameters.minute1);
	minute2 = -( instance.parameters.minute2);
	minute3 = -(instance.parameters.minute3);
	
	clr2 = instance.parameters.clr2;
    width2 = instance.parameters.width2;
    style2 = instance.parameters.style2;
	
	clr3 = instance.parameters.clr3;
    width3 = instance.parameters.width3;
    style3 = instance.parameters.style3;

	
    host = core.host;

    local s, e = core.getcandle(source:barSize(), 0, host:execute("getTradingDayOffset"), 0);
    Size = e-s;

    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. minute1 .. "," .. minute2 .. "," .. minute3 .. ")";
    instance:name(name);

    if onlyname then
        return ;
    end


 
end

local last_s = nil;


function Update(period, mode)


    -- calculation restarted
    if period == 0 then
        host:execute("removeAll");       
    end

    local s = source:serial(period);

    if last_s ~= nil and s == last_s then
        return ;
    end

    last_s = s;	
   
        
		if minute1 < 0 then		
        host:execute("drawLine", 1, source:date(source:size()-1  + minute1 ), 0, source:date(source:size()-1  + minute1 ), 100000, clr1, style1, width1, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, source:date(source:size()-1  + minute1 ))));      
        else
		host:execute("drawLine", 1, source:date(source:size()-1  ) + minute1*Size , 0, source:date(source:size()-1  ) + minute1*Size, 100000, clr1, style1, width1, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, source:date(source:size()-1   ) + minute1*Size)));      
        end
		if minute2 < 0 then		
		host:execute("drawLine", 2, source:date(source:size()-1  + minute2 ), 0, source:date(source:size()-1  + minute2 ), 100000, clr2, style2, width2, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, source:date(source:size()-1  + minute2 ))));  
        else
		host:execute("drawLine", 2, source:date(source:size()-1   ) + minute2*Size, 0, source:date(source:size()-1  ) + minute2*Size , 100000, clr2, style2, width2, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, source:date(source:size()-1   ) + minute2*Size)));      		
        end
		if minute3 < 0 then		
		host:execute("drawLine", 3, source:date(source:size()-1  + minute3 ), 0, source:date(source:size()-1  + minute3 ), 100000, clr3, style3, width3, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, source:date(source:size()-1  + minute3 ))));
	    else
		host:execute("drawLine", 3, source:date(source:size()-1   ) + minute3*Size, 0, source:date(source:size()-1 ) + minute3*Size, 100000, clr3, style3, width3, core.formatDate(host:execute("convertTime", core.TZ_EST, core.TZ_TS, source:date(source:size()-1  ) + minute3 *Size)))
		end
end



