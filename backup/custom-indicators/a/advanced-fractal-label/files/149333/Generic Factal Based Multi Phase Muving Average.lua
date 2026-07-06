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
    indicator:name("Generic Factal Based Multi Phase Muving Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 	indicator.parameters:addGroup("Calculation");	  
	indicator.parameters:addInteger("Period1", "Max Fractal Number", "", 99, 1,1000);
	indicator.parameters:addInteger("Period2", "Averaging Period", "", 99, 1,1000);	
	indicator.parameters:addInteger("Number", "Number Of Averages", "", 4, 1,4);		
	indicator.parameters:addGroup("Line Style");		

    indicator.parameters:addColor("color", "Consolidated fractal color", "Consolidated fractal color", core.rgb(0,0,255));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end
--4
local source;
local up, down;
local Period={}; 
local Line={};
function Prepare(nameOnly)
    source = instance.source;
    Period1=instance.parameters.Period1
    Period2=instance.parameters.Period2  	
	Number=instance.parameters.Number;
    if  (nameOnly)  then
	return;
	end 	


    assert (Period1>Number , "The chosen Max Fractal Number must be bigger than Number Of Averages!");	
  
    local name = profile:id() .. " ( " .. Period1 .. " , " .. Period2.. " , " .. Number .. " )";
    instance:name(name);
	
    assert(core.indicators:findIndicator("ADVANCED FRACTAL PERIOD") ~= nil, "Please, download and install ADVANCED FRACTAL PERIOD.LUA indicator");
	Indicator = core.indicators:create("ADVANCED FRACTAL PERIOD", source, Period1);
	first=source:first()+Period1+Period2;
	
	local Delta=255/Number;
	
	for i= 1, Number, 1 do
    Period[i] = instance:addInternalStream(0, 0);
    Line[i] = instance:addStream("Line".. i, core.Line, name, i .. ". Line", core.rgb(0+Delta*i,255-Delta*i,0), 0 );
    Line[i]:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line[i]:setWidth(instance.parameters.width);
    Line[i]:setStyle(instance.parameters.style); 
	end
	
	
	Consolidated = instance:addStream("Consolidated", core.Line, name,  "Consolidated", instance.parameters.color, 0 );
    Consolidated:setPrecision(math.max(2, instance.source:getPrecision())); 
    Consolidated:setWidth(instance.parameters.width);
    Consolidated:setStyle(instance.parameters.style); 
	
    Consolidated_Period = instance:addInternalStream(0, 0);
end

function Update(period, mode)

 
    Indicator:update(mode);
	
	for i= 1, Number, 1 do
    Period[i][period]=Period[i][period-1];
    end
	
	if period <= first then
	return;
	end
	
	local P={};
	local PC={};	
	for i= 1, Number, 1 do
	P[i]=0
	PC[i]=0
    end
	
	local TheP=0;
	local TheC=0;	
	
	local Range= Period1/Number;
	
	for i= 0, Period2-1, 1 do
	    	for j= 1, Number, 1 do
					if   Indicator.Up:hasData(period-i) then
						if Indicator.Up[period-i]> (j-1)*Range   and Indicator.Up[period-i]<= (j) *Range  then
						PC[j]=PC[j]+1;
						P[j]=P[j]+Indicator.Up[period-i]
						TheP=TheP+Indicator.Up[period-i]
						TheC=TheC+Indicator.Up[period-i]
						end
						
						if  Indicator.Down[period-i]> (j-1)*Range  and Indicator.Down[period-i]<= (j) *Range  then
						PC[j]=PC[j]+1;
						P[j]=P[j]+Indicator.Down[period-i]
						TheP=TheP+Indicator.Down[period-i]
						TheC=TheC+Indicator.Down[period-i]						
						end			
					end
			end 		
	 
	
	end
	
	
	
	for i= 1, Number, 1 do	
		if PC[i]~=0 then
		Period[i][period]=P[i]/PC[i]	
		end
	end
 
	
	if TheC ~=0 then
	Consolidated_Period[period]=(TheP)/(TheC)
    end	
	
 	
	local Flag=false;
	
	for i= 1, Number, 1 do
		if period <=  Period[i][period] then
		Flag=true 
		end
	end
	
	if Flag then
	return;
	end 
	
	for i= 1, Number, 1 do	
	Line[i][period]=mathex.avg(source.close, period- Period[i][period]+1, period);
    end
	
	if period<=Consolidated_Period[period] then
	return;
	end
	
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