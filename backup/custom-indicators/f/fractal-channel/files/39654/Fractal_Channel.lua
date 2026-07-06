-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23005
-- Id: 7290

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Fractal channel indicator");
    indicator:description("Fractal channel indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Frame", "Number of fractals (Odd)", "Number of fractals (Odd)", 5, 3,99);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Uclr", "Upper channel color", "Upper channel color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Lclr", "Lower channel color", "Lower channel color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Cloud Style");
	indicator.parameters:addBoolean("Lines", "Show Lines", "" , true); 
	indicator.parameters:addBoolean("Cloud", "Show Cloud", "" , true);
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
	 
	 indicator.parameters:addColor("Color", "Color", "Color", core.rgb(128, 128, 128));
end

local first;
local source = nil;
local UpperChannel=nil;
local LowerChannel=nil;
local Frame;
local Shift;
local Cloud, Lines;
local Transparency;
local Color;
function Prepare(nameOnly)
    source = instance.source;
   
    Frame = instance.parameters.Frame;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Frame .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	Cloud= instance.parameters.Cloud;
	Lines= instance.parameters.Lines;
	Color= instance.parameters.Color;
	Transparency= instance.parameters.Transparency;
   
    Shift=(Frame-1)/2;
	first = source:first()+Shift;
	
	if Lines then
		UpperChannel = instance:addStream("Upper", core.Line, name .. ".Upper", "Upper", instance.parameters.Uclr, first);
		LowerChannel = instance:addStream("Lower", core.Line, name .. ".Lower", "Lower", instance.parameters.Lclr, first);
		UpperChannel:setWidth(instance.parameters.widthLinReg);
		UpperChannel:setStyle(instance.parameters.styleLinReg);
		LowerChannel:setWidth(instance.parameters.widthLinReg);
		LowerChannel:setStyle(instance.parameters.styleLinReg);
	else
	    UpperChannel = instance:addInternalStream(0, 0);
		LowerChannel = instance:addInternalStream(0, 0);
	end
	 
	 
	 if Cloud then
	 instance:createChannelGroup("Group","Group" , UpperChannel, LowerChannel,  Color, Transparency);
	 end
	 
	 
	UpperChannel:setPrecision(math.max(2, instance.source:getPrecision()));
	LowerChannel:setPrecision(math.max(2, instance.source:getPrecision()));	
end

function Update(period, mode)
   if (period<=first) then
   return;
   end
   
    local UpFr=true;
    local DnFr=true;
    local i;
    for i=1,Shift,1 do
     if source.high[period-Shift]<=source.high[period-Shift+i] or source.high[period-Shift]<=source.high[period-Shift-i] then
      UpFr=false;
     end
     if source.low[period-Shift]>=source.low[period-Shift+i] or source.low[period-Shift]>=source.low[period-Shift-i] then
      DnFr=false;
     end
    end
    if UpFr then
     for i=0,Shift,1 do
      UpperChannel[period-Shift+i]=source.high[period-Shift];
     end
    else
     for i=0,Shift,1 do
      UpperChannel[period-Shift+i]=UpperChannel[period-Shift-1+i];
     end 
    end
    if DnFr then
     for i=0,Shift,1 do
      LowerChannel[period-Shift+i]=source.low[period-Shift];
     end
    else
     for i=0,Shift,1 do
      LowerChannel[period-Shift+i]=LowerChannel[period-Shift-1+i];
     end 
    end
 
end


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

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

