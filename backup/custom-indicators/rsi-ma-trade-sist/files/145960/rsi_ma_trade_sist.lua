-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72167

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
    indicator:name("RSI MA Trade");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("FastEMA", "FastEMA", "", 5, 1, 2000);
    indicator.parameters:addInteger("SlowEMA", "SlowEMA", "", 12, 1, 2000);
    indicator.parameters:addInteger("RSIPeriod", "RSIPeriod", "", 21, 1, 2000);
    indicator.parameters:addInteger("Shift", "Shift", "", 1, 1, 2000);	
 



	
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0)); 
	 indicator.parameters:addColor("color3", "3. Line Color", "", core.rgb(0, 0, 255)); 
	 
	indicator.parameters:addGroup("Arrow Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local FastEMA, SlowEMA,RSIPeriod,Shift; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	FastEMA=instance.parameters.FastEMA;
	SlowEMA=instance.parameters.SlowEMA;
	RSIPeriod=instance.parameters.RSIPeriod;
	Shift=instance.parameters.Shift;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  FastEMA.. "," ..  SlowEMA.. "," ..  RSIPeriod.. "," ..  Shift   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	RSI= core.indicators:create("RSI", source.close, RSIPeriod);
	MA1= core.indicators:create("EMA", source.close, FastEMA);
	MA2= core.indicators:create("EMA", source.close, SlowEMA);	
	first=math.max(RSI.DATA:first(),MA1.DATA:first(),MA2.DATA:first()) ; 
	
	
	Signal = instance:addInternalStream(0, 0);
 
	
	
    Line1 = instance:addStream("Line1", core.Line, name, "1.  Line", instance.parameters.color1, first );
    Line1:setPrecision(math.max(2, instance.source:getPrecision()));
    Line1:setWidth(instance.parameters.width);
    Line1:setStyle(instance.parameters.style);
    Line1:addLevel(0);	
 
 
    Line2 = instance:addStream("Line2", core.Line, name, "2.  Line", instance.parameters.color2, first );
    Line2:setPrecision(math.max(2, instance.source:getPrecision()));
    Line2:setWidth(instance.parameters.width);
    Line2:setStyle(instance.parameters.style);
    Line2:addLevel(0);	
	
	
	Line3 = instance:addStream("Line3", core.Line, name, "3.  Line", instance.parameters.color3, first );
    Line3:setPrecision(math.max(2, instance.source:getPrecision()));
    Line3:setWidth(instance.parameters.width);
    Line3:setStyle(instance.parameters.style);
    Line3:addLevel(0);	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center,  core.V_Top, instance.parameters.clrDN, 0);
	
end


function Update(period, mode)

	  MA1:update(mode); 
	  MA2:update(mode); 
	  RSI:update(mode); 
	 if period <= first then
	 return;
	 end
	 
	Signal[period]=Signal[period-1]; 
	 
    Line1[period]= MA1.DATA[period];
    Line2[period]= MA2.DATA[period];	
	Line3[period]=MA2.DATA[period] - (50 -RSI.DATA[period])*source:pipSize();
	
	
	local fast_sig = MA1.DATA[period-Shift];
	local slow_sig = MA2.DATA[period-Shift];
	local rsi_sig  = RSI.DATA[period-Shift];

	local fast_sig_prev =MA1.DATA[period-Shift-1];
	local slow_sig_prev = MA2.DATA[period-Shift-1];
	local rsi_sig_prev  =RSI.DATA[period-Shift-1];
	  
	  
	up:setNoData(period);
    down:setNoData(period);	
	
         if(((fast_sig>slow_sig and rsi_sig>50 and fast_sig_prev<=slow_sig_prev)
         or (fast_sig>slow_sig and rsi_sig>50 and rsi_sig_prev<=50)) and Signal[period]~=1 )
	     then
         Signal[period]=1;
         up:set(period, source.low[period], "\217", source.low[period]);			 
         elseif(((fast_sig<slow_sig and rsi_sig<50 and fast_sig_prev>=slow_sig_prev)
         or (fast_sig<slow_sig and rsi_sig<50 and rsi_sig_prev>=50)) and Signal[period]~=-1)
		 then
         Signal[period]=-1;		
         down:set(period, source.high[period], "\218", source.high[period]);			 
		 end
 
	
end