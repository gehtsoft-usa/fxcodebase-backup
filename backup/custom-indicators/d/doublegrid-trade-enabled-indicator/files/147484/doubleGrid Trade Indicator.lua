-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=64558

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
 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Double Grid Trade Indicator");
    indicator:description("Double Grid Trade Indicator"); 
    indicator:requiredSource(core.Tick); 
    indicator:type(core.Oscillator);

     indicator.parameters:addGroup("BuySell"); 
	 indicator.parameters:addDouble("gsz", "Grid Pip Size", "", 100, 1, 10000)
     indicator.parameters:addGroup("Style");  
 	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0)); 
 end
 

 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 

	source = instance.source
    if   (nameOnly) then
        return;
    end
 
 
	gsz = instance.parameters.gsz  
	
	Top = instance:addInternalStream(0, 0);
	Bottom	= instance:addInternalStream(0, 0);	 
	
	local name = profile:id().."(".." gsz="..gsz ..")" 
	instance:name(name);
	
	Signal = instance:addStream("Signal", core.Bar, name, name,   instance.parameters.color , source:first());	
end

 



function Update(period)
	
	
	if not source:hasData(period) then
	return;
	end 
	
	if period <= source:first()
	then 
	return;
	end
	
 
	local top = source[period]+ gsz*source:pipSize()
    local bottom= source[period]- gsz*source:pipSize()	
	
	
	if period==first then
	Top[period]=top;
	Bottom[period]=bottom;	
    end			 
	

	
		if source[period]> Top[period-1] 	
		then
		Top[period]=top;	 
		Bottom[period]=bottom;	
		Signal[period]=1;
        elseif  source[period]< Bottom[period-1]
		then
		Top[period]=top;	 
		Bottom[period]=bottom;		
		Signal[period]=-1;	
        else
		Top[period]=Top[period-1];
		Bottom[period]=Bottom[period-1];		
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
