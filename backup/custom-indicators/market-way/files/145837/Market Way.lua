-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72128

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



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Market Way");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
 
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("IdMain", "main line", "", 12, 1, 2000);
    indicator.parameters:addInteger("IdBull", "bull line", "", 12, 1, 2000);
    indicator.parameters:addInteger("IdBear", "bear line", "", 12, 1, 2000);
    indicator.parameters:addInteger("IdArray", "all sma line", "", 12, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addInteger("style1", "SMA Line style", "", core.LINE_DASH);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);	
	
	indicator.parameters:addColor("Main", "Main Line Color", "", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("Bull", "Bull Line Color", "", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("Bear", "Bear Line Color", "", core.rgb(255, 0, 0)); 
	
	indicator.parameters:addColor("SMA_Main", "SMA Main Line Color", "", core.rgb(0, 0, 200)); 
	indicator.parameters:addColor("SMA_Bull", "SMA Bull Line Color", "", core.rgb(0, 200, 0)); 
	indicator.parameters:addColor("SMA_Bear", "SMA Bear Line Color", "", core.rgb(200, 0, 0)); 	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local IdMain, IdBull; 
local IdBear, IdArray; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	IdMain=instance.parameters.IdMain;
	IdBull=instance.parameters.IdBull;
	IdBear=instance.parameters.IdBear;
	IdArray=instance.parameters.IdArray;	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  IdMain.. "," ..  IdBull .. "," ..  IdBear.. "," ..  IdArray  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	--Indicator= core.indicators:create("AO", source, Period1, Period2);
	first=source:first() ; 
	
	
	MainSource = instance:addInternalStream(0, 0); 
	BullSource = instance:addInternalStream(0, 0); 
	BearSource = instance:addInternalStream(0, 0); 
	
    main = instance:addStream("Main", core.Line, name, "Main", instance.parameters.Main, first );
    main:setPrecision(math.max(2, instance.source:getPrecision()));
    main:setWidth(instance.parameters.width);
    main:setStyle(instance.parameters.style);
    main:addLevel(0);	
	
    Bull = instance:addStream("Bull", core.Line, name, "Bull", instance.parameters.Bull, first );
    Bull:setPrecision(math.max(2, instance.source:getPrecision()));
    Bull:setWidth(instance.parameters.width);
    Bull:setStyle(instance.parameters.style);
    Bull:addLevel(0);	

    Bear = instance:addStream("Bear", core.Line, name, "Bear", instance.parameters.Bear, first );
    Bear:setPrecision(math.max(2, instance.source:getPrecision()));
    Bear:setWidth(instance.parameters.width);
    Bear:setStyle(instance.parameters.style);
    Bear:addLevel(0);	
	
	
	SMA_main = instance:addStream("SMA_Main", core.Line, name, "SMA_Main", instance.parameters.SMA_Main, first );
    SMA_main:setPrecision(math.max(2, instance.source:getPrecision()));
    SMA_main:setWidth(instance.parameters.width);
    SMA_main:setStyle(instance.parameters.style1);
    SMA_main:addLevel(0);	
	
    SMA_Bull = instance:addStream("SMA_Bull", core.Line, name, "SMA_Bull", instance.parameters.SMA_Bull, first );
    SMA_Bull:setPrecision(math.max(2, instance.source:getPrecision()));
    SMA_Bull:setWidth(instance.parameters.width);
    SMA_Bull:setStyle(instance.parameters.style1);
    SMA_Bull:addLevel(0);	

    SMA_Bear = instance:addStream("SMA_Bear", core.Line, name, "SMA_Bear", instance.parameters.SMA_Bear, first );
    SMA_Bear:setPrecision(math.max(2, instance.source:getPrecision()));
    SMA_Bear:setWidth(instance.parameters.width);
    SMA_Bear:setStyle(instance.parameters.style1);
    SMA_Bear:addLevel(0);	
	
	
	Up = instance:addStream("Up", core.Bar, name, "Up", instance.parameters.Bull, first );
    Up:setPrecision(math.max(2, instance.source:getPrecision()));
    Up:addLevel(0);	

	Down = instance:addStream("Down", core.Bar, name, "Down", instance.parameters.Bear, first );
    Down:setPrecision(math.max(2, instance.source:getPrecision()));
    Down:addLevel(0);	
	
end


function Update(period, mode)

	  --Indicator:update(mode); 
   
    MainSource[period]= source.close[period]-source.open[period];
	
	if MainSource[period] > 0 then
	BullSource[period]=MainSource[period];
	BearSource[period]=0;	
	else
	BearSource[period]=MainSource[period];
	BullSource[period]=0;		
	end
	
	
	
	 if period <= first +IdMain  then
	 return;
	 end
 
     main[period]= mathex.sum(MainSource, period-IdMain+1, period );
 
     if period <= first +IdBull  then
	 return;
	 end
	 
	  Bull[period]= mathex.sum(BullSource, period-IdBull+1, period );

     if period <= first +IdBear  then
	 return;
	 end
	 
 	  Bear[period]= mathex.sum(BearSource, period-IdBear+1, period );      
	  
	  
	 if period <= first +IdMain +IdArray then
	 return;
	 end
 
     SMA_main[period]= mathex.avg(main, period-IdArray+1, period );
 
     if period <= first +IdBull +IdArray  then
	 return;
	 end
	 
     SMA_Bull[period]= mathex.avg(Bull, period-IdArray+1, period );	 

     if period <= first +IdBear +IdArray  then
	 return;
	 end

     SMA_Bear[period]= mathex.avg(Bear, period-IdArray+1, period );	


     Up[period]= Bull[period]- SMA_Bull[period];
     Down[period]=Bear[period]- SMA_Bear[period];	 
end