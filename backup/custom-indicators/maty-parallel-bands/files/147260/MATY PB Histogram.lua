-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72669

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
--|                                                                       https://mario-jemic.com/ |
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
    indicator:name("MATY PB Histogram");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
    indicator.parameters:addDouble("Increment", "Increment (In Pips)", "", 10, 1, 2000);
	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255)); 
	 indicator.parameters:addColor("Top", "Top Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("Bottom", "Bottom Line Color", "", core.rgb(255, 0, 0)); 	

	indicator.parameters:addInteger("Size1", "Weak Signal Arrow Size", "", 10); 
	indicator.parameters:addInteger("Size2", "Strong Signal Arrow Size", "", 20); 	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local Period, Increment; 
local Indicator;
local Line={};	
-- Routine
 function Prepare(nameOnly)   
 
    

	source = instance.source
	
	Period=instance.parameters.Period;
	Increment=instance.parameters.Increment*source:pipSize();	
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  Period.. "," ..  Increment  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Indicator= core.indicators:create("MVA", source.typical, Period );
	first=Indicator.DATA:first() +1; 
	
	
 
    Cross = instance:addInternalStream(0, 0);
	
	
    Line= instance:addStream("Line", core.Bar, name, "Line", instance.parameters.color, first );
    Line:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line:addLevel(0); 
    Line:addLevel(10,core.LINE_NONE); 
    Line:addLevel(-10,core.LINE_NONE); 
	
    Signal= instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.color, first );
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.width);
    Signal:setStyle(instance.parameters.style);


    WeakUp = instance:createTextOutput ("WeakUp", "WeakUp", "Wingdings", instance.parameters.Size1, core.H_Center, core.V_Bottom, instance.parameters.Top, 0);
    WeakDown = instance:createTextOutput ("WeakDn", "WeakDn", "Wingdings", instance.parameters.Size1, core.H_Center, core.V_Top, instance.parameters.Bottom, 0); 

    StrongUp = instance:createTextOutput ("StrongUp", "StrongUp", "Wingdings", instance.parameters.Size2, core.H_Center, core.V_Bottom, instance.parameters.Top, 0);
    StrongDown = instance:createTextOutput ("StrongDn", "StrongDn", "Wingdings", instance.parameters.Size2, core.H_Center, core.V_Top, instance.parameters.Bottom, 0);
end


function Update(period, mode)

	Indicator:update(mode); 

   
	 if period <= first  then
	 return;
	 end
	 
    Line [period]=Indicator.DATA[period]

    WeakUp:setNoData(period);
    WeakDown:setNoData(period);	 
    StrongUp:setNoData(period);
    StrongDown:setNoData(period);
 
	
		if source.close[period]>Indicator.DATA[period-1]+5*Increment then
		 Line[period]=6
		elseif source.close[period]>Indicator.DATA[period-1]+4*Increment then
		 Line[period]=5
		elseif source.close[period]>Indicator.DATA[period-1]+3*Increment then
		 Line[period]=4
		elseif source.close[period]>Indicator.DATA[period-1]+2*Increment then
		 Line[period]=3
		elseif source.close[period]>Indicator.DATA[period-1]+1*Increment then
		 Line[period]=2
		elseif source.close[period]>Indicator.DATA[period-1]+0*Increment then
		 Line[period]=1
		elseif source.close[period]<Indicator.DATA[period-1]-5*Increment then
		 Line[period]=-6
		elseif source.close[period]<Indicator.DATA[period-1]-4*Increment then
		 Line[period]=-5
		elseif source.close[period]<Indicator.DATA[period-1]-3*Increment then
		 Line[period]=-4
		elseif source.close[period]<Indicator.DATA[period-1]-2*Increment then
		 Line[period]=-3
		elseif source.close[period]<Indicator.DATA[period-1]-1*Increment then
		 Line[period]=-2
		elseif source.close[period]<Indicator.DATA[period-1]-0*Increment then
		 Line[period]=-1
		end
	
    if Line[period]> 0 then
    Line:setColor(period,  instance.parameters.Top);	
	else
    Line:setColor(period,  instance.parameters.Bottom);	
    end	
	
	

	
	
	if  Line[period] > 0 and Line[period-1] <=0
	or Line[period] < 0 and Line[period-1] >=0
	then
	Cross[period]=0;	
	else
	Cross[period]=Cross[period-1]+1;	
	end
	
	local min,max=mathex.minmax(Line, period-Cross[period],period);
	if Line[period]>0 then
	Signal[period]= max;
	else
	Signal[period]= min;	
	end
 	
	  
	local Strength=math.abs(Signal[period] - Line[period]); 
	
	if   Signal[period]> 0 and Strength == 2 then
    WeakDown:set(period, 5, "\218" );		
	elseif   Signal[period]> 0 and Strength == 3 then	
    StrongDown:set(period, 5, "\218" );		
	elseif   Signal[period]< 0 and Strength == 2 then
    WeakUp:set(period, -5, "\217" );	
	elseif   Signal[period]< 0 and Strength == 3 then 
    StrongUp:set(period, -5, "\217" );	
	end
	
	 
end

 

