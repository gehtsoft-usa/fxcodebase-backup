-- Id: 20397
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65652 

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Adaptable Moving Average RSI");
    indicator:description("Adaptable Moving Average RSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
	
	

 
    indicator.parameters:addInteger("RSI_Period", "RSI_Period", "", 14);
	
	indicator.parameters:addGroup("1. Line Calculation");
	indicator.parameters:addInteger("Forward1", "Forward Period or Period for Regulat MA", "", 7);
	indicator.parameters:addInteger("Backward1", "Backward Period", "", 7);
	
		
	indicator.parameters:addString("Method1", "MA Method", "Method" , "AMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	 indicator.parameters:addStringAlternative("Method1", "AMA", "AMA" , "AMA")
	
	indicator.parameters:addGroup("2. Line Calculation");
	indicator.parameters:addInteger("Forward2", "Forward Period or Period for Regulat MA", "", 14);
	indicator.parameters:addInteger("Backward2", "Backward Period", "", 14);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "AMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	 indicator.parameters:addStringAlternative("Method2", "AMA", "AMA" , "AMA")
	
	indicator.parameters:addGroup("3. Line Calculation");
	indicator.parameters:addInteger("Forward3", "Forward Period or Period for Regulat MA", "", 21);
	indicator.parameters:addInteger("Backward3", "Backward Period", "", 21);
	
	indicator.parameters:addString("Method3", "MA Method", "Method" , "AMA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	 indicator.parameters:addStringAlternative("Method3", "AMA", "AMA" , "AMA")
	
	indicator.parameters:addGroup("4. Line Calculation");
	indicator.parameters:addInteger("Forward4", "Forward Period or Period for Regulat MA", "", 34);
	indicator.parameters:addInteger("Backward4", "Backward Period", "", 34);
	
	indicator.parameters:addString("Method4", "MA Method", "Method" , "AMA");
    indicator.parameters:addStringAlternative("Method4", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method4", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method4", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method4", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method4", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method4", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method4", "WMA", "WMA" , "WMA");
	 indicator.parameters:addStringAlternative("Method4", "AMA", "AMA" , "AMA")
	 
 

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "RSI Line Color", "RSI Line Color", core.rgb(128, 128, 128));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 LineStyle(1, core.rgb(0, 255, 0));
	 LineStyle(2, core.rgb(255, 0, 0));
	 LineStyle(3, core.rgb(0, 0, 255));
	 LineStyle(4, core.rgb(128, 0, 255));
	 
	 
	 for i= 1, 11 , 1 do
	 Horizontal_Style(i, core.rgb(225, 225, 128));
	 end
	 
	 
 
end

function Horizontal_Style(id, linecolor)


    indicator.parameters:addGroup(id ..". Horizontal Line Style");
    indicator.parameters:addColor("Horizontal_line_color"..id, "Line Color", "Line Color", linecolor);
	
	if id == 4 or id == 8 then
	indicator.parameters:addInteger("Horizontal_line_width"..id, "Line width", "", 3, 1, 5);
	else
	indicator.parameters:addInteger("Horizontal_line_width"..id, "Line width", "", 1, 1, 5);
	end
	
    indicator.parameters:addInteger("Horizontal_line_style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Horizontal_line_style"..id, core.FLAG_LINE_STYLE);
end	

function LineStyle(id, linecolor)


    indicator.parameters:addGroup(id ..". Line Style");
    indicator.parameters:addColor("line_color"..id, "Line Color", "Line Color", linecolor);
	
	indicator.parameters:addInteger("line_width"..id, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("line_style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("line_style"..id, core.FLAG_LINE_STYLE);
end	

local Method;
local first;
local source = nil;
local RSI_Period;
local rsi, RSI=nil;
local Method={};
local Line={};
local MA={};


 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 
    source = instance.source; 
    RSI_Period=instance.parameters.RSI_Period;
  
   
   Method[1]=instance.parameters.Method1;
    Method[2]=instance.parameters.Method2;
	 Method[3]=instance.parameters.Method3;
	  Method[4]=instance.parameters.Method4;
  
 
    rsi = core.indicators:create("RSI", source, RSI_Period);
	for i=1, 4, 1 do
	
	 assert(core.indicators:findIndicator(Method[i]) ~= nil, "Please, download and install " .. Method[i] ..".LUA indicator");
    assert(core.indicators:findIndicator(Method[i]) ~= nil, Method[i] .. " indicator must be installed");
	MA[i] =core.indicators:create(Method[i], rsi.DATA , instance.parameters:getInteger("Forward" .. i), instance.parameters:getInteger("Backward" .. i));
	end
	
    
	first = rsi.DATA:first();
   
    RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.color, rsi.DATA:first());
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
	RSI:setWidth(instance.parameters.width);
    RSI:setStyle(instance.parameters.style);
	
	for i=1, 4, 1 do
	Line[i] = instance:addStream("Line"..i, core.Line, name .. ".Line"..i, "Line"..i, instance.parameters:getColor("line_color" .. i), MA[i].DATA:first());
    Line[i]:setPrecision(math.max(2, instance.source:getPrecision()));
	Line[i]:setWidth(instance.parameters:getInteger("line_width" .. i));
    Line[i]:setStyle(instance.parameters:getInteger("line_style" .. i));

    end
	
	for i= 1, 11 , 1 do
	RSI:addLevel( (i-1)*10, instance.parameters:getInteger("Horizontal_line_style" .. i),instance.parameters:getInteger("Horizontal_line_width" .. i) , instance.parameters:getColor("Horizontal_line_color" .. i));
	end
	
end

function Update(period, mode)
 
    
      rsi:update(mode); 
	 
	 if (period<rsi.DATA:first()) then
	 return;
	 end
	 
     RSI[period]=rsi.DATA[period]; 
	
	
	 for i=1, 4, 1 do
	  MA[i]:update(mode);
	  
	   if (period>=MA[i].DATA:first()) then
	  Line[i][period]=MA[i].DATA[period];
	  end
    
	  end
    
   
   
end

