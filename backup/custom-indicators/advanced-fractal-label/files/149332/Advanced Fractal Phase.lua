-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=73282

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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
    indicator:name("Advanced Fractal Phase");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 	indicator.parameters:addGroup("Calculation");	  
	indicator.parameters:addInteger("Period1", "Max Fractal Number", "", 99, 1,1000);
	indicator.parameters:addInteger("Period2", "Averaging Period", "", 99, 1,1000);	
	
	indicator.parameters:addGroup("Line Style");		
    indicator.parameters:addColor("color1", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("color2", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
    indicator.parameters:addColor("color3", "Consolidated fractal color", "Consolidated fractal color", core.rgb(0,0,255));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local source;
local up, down;
local Period1; 

function Prepare(nameOnly)
    source = instance.source;
    Period1=instance.parameters.Period1
    Period2=instance.parameters.Period2  	
    if  (nameOnly)  then
	return;
	end 		 
  
    local name = profile:id() .. " ( " .. Period1 .. " , " .. Period2 .. " )";
    instance:name(name);
	
    assert(core.indicators:findIndicator("ADVANCED FRACTAL PERIOD") ~= nil, "Please, download and install ADVANCED FRACTAL PERIOD.LUA indicator");
	Indicator = core.indicators:create("ADVANCED FRACTAL PERIOD", source, Period1);
	first=source:first()+Period1+Period2;
	
	
    Fast = instance:addStream("Fast", core.Line, name, "Fast", instance.parameters.color1, first );
    Fast:setPrecision(math.max(2, instance.source:getPrecision())); 
    Fast:setWidth(instance.parameters.width);
    Fast:setStyle(instance.parameters.style);

    Slow = instance:addStream("Slow", core.Line, name, "Slow", instance.parameters.color2, first);
    Slow:setPrecision(math.max(2, instance.source:getPrecision())); 
    Slow:setWidth(instance.parameters.width);
    Slow:setStyle(instance.parameters.style);	
	
    Consolidated = instance:addStream("Consolidated", core.Line, name, "Consolidated", instance.parameters.color3, first);
    Consolidated:setPrecision(math.max(2, instance.source:getPrecision())); 
    Consolidated:setWidth(instance.parameters.width);
    Consolidated:setStyle(instance.parameters.style);	
	
    Fast_Period = instance:addInternalStream(0, 0);
    Slow_Period = instance:addInternalStream(0, 0);
    Consolidated_Period = instance:addInternalStream(0, 0);
end

function Update(period, mode)

 
    Indicator:update(mode);
	
	
    Fast_Period[period]=Fast_Period[period-1];
	Slow_Period[period]=Slow_Period[period-1];	
	Consolidated_Period[period]=Consolidated_Period[period-1];		
	
	if period <= first then
	return;
	end
	
	local P1=0;
	local P2=0;	
	local P1C=0;
	local P2C=0;
	
	
	for i= 0, Period2-1, 1 do
	
	    if   Indicator.Up:hasData(period-i) then
			if Indicator.Up[period-i]> 0  and Indicator.Up[period-i]< Period1/2  then
			P1C=P1C+1;
			P1=P1+Indicator.Up[period-i]
			end
			
			if  Indicator.Up[period-i]> Period1/2 then
			P2C=P2C+1;
			P2=P2+Indicator.Up[period-i]
			end			
	    end
		
	    if   Indicator.Down:hasData(period-i) then	 
			if Indicator.Down[period-i]> 0  and Indicator.Down[period-i]< Period1/2   then
			P1C=P1C+1;
			P1=P1+Indicator.Down[period-i]
			end
			
			if Indicator.Down[period-i]> Period1/2 then
			P2C=P2C+1;
			P2=P2+Indicator.Down[period-i]
			end			
			
		end
	
	end
	
	
	
	
	if P1C~=0 then
    Fast_Period[period]=(P1)/(P1C)		
    end
	
	if P2C ~=0 then
	Slow_Period[period]=(P2)/(P2C)		
    end
	
	if P1C+P2C ~=0 then
	Consolidated_Period[period]=(P1+P2)/(P1C+P2C)
    end	
	
 	
	
	if period <=  Fast_Period[period]
	or  period <= Slow_Period[period] 
	or  period <= Consolidated_Period[period]   
	then
	return;
	end
	
	
	Fast[period]=mathex.avg(source.close, period- Fast_Period[period]+1, period);
	Slow[period]=mathex.avg(source.close, period- Slow_Period[period]+1, period);
    Consolidated[period]=mathex.avg(source.close, period-Consolidated_Period[period]+1, period);
 
 
        
    
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