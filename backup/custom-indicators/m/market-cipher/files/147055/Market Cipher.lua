-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72618

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
    indicator:name("Market Cipher");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("n1", "Channel Length", "", 10, 1, 2000);
    indicator.parameters:addInteger("n2", "Average Length", "", 21, 1, 2000);
    indicator.parameters:addInteger("n3", "Signal Length", "", 4, 1, 2000); 
	
	
	 indicator.parameters:addGroup("Line Style");	
 	 indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 	 	 
	indicator.parameters:addColor("color1", "1. Channel Color","", core.rgb(0, 255, 0));	 
	indicator.parameters:addColor("color2", "2. Channel Color","", core.rgb(255, 0, 0));	
	indicator.parameters:addColor("color3", "3. Channel Color","", core.rgb(0, 0, 255));	
	indicator.parameters:addColor("color4", "The Line Color","", core.COLOR_LABEL);	
	
	indicator.parameters:addColor("clrUP", "Up Color","", core.rgb(0, 255, 0));	 
	indicator.parameters:addColor("clrDN", "Down Color","", core.rgb(255, 0, 0));	
	
    indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("Level1", "1. Level","", 60);
	indicator.parameters:addDouble("Level2", "2. Level","", 53);
	indicator.parameters:addDouble("Level3", "3. Level","", -60); 
	indicator.parameters:addDouble("Level4", "4. Level","", -53); 	
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);		
	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local n1, n2; 
local Indicator;
	
-- Routine
 function Prepare(nameOnly)   
 
    
	n1=instance.parameters.n1;
	n2=instance.parameters.n2;
	n3=instance.parameters.n3;	
   Transparency= instance.parameters.Transparency;
   Transparency= 100-Transparency;
   
	
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  n1.. "," ..  n2 .. "," ..  n3 .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	EMA1= core.indicators:create("EMA", source, n1);
	first=EMA1.DATA:first() ; 
	
	Last = instance:addInternalStream(0, 0);	
	Period = instance:addInternalStream(0, 0);	
	
	Zero1 = instance:addInternalStream(0, 0);
	Zero2 = instance:addInternalStream(0, 0);
	Zero3 = instance:addInternalStream(0, 0);
	
	d = instance:addInternalStream(0, 0);
	EMA2= core.indicators:create("EMA", d, n1); 
	
	ci = instance:addInternalStream(0, 0);
	EMA3= core.indicators:create("EMA", ci, n2); 	
	
    wt1 = instance:addStream("wt1", core.Line, name, "wt1", instance.parameters.color1, first+n1+n2 );
    wt1:setPrecision(math.max(2, instance.source:getPrecision())); 
    wt1:setStyle(core.LINE_NONE );
    wt1:addLevel(0);	
	
	
	wt1:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	wt1:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	wt1:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	wt1:addLevel(instance.parameters.Level4, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	
	MVA= core.indicators:create("MVA", wt1, n3); 	
    
	wt2 = instance:addStream("wt2", core.Line, name, "wt2", instance.parameters.color2, first+n1+n2+n3  );
    wt2:setPrecision(math.max(2, instance.source:getPrecision())); 
    wt2:setStyle(core.LINE_NONE );
    wt2:addLevel(0);	
	
	
	wt1wt2 = instance:addStream("wt1wt2", core.Line, name, "wt1wt2", instance.parameters.color3, first+n1+n2+n3 );
    wt1wt2:setPrecision(math.max(2, instance.source:getPrecision())); 
    wt1wt2:setStyle(core.LINE_NONE );
    wt1wt2:addLevel(0);	
	
	instance:createChannelGroup("1.Line","1.Line" , Zero1, wt1, instance.parameters.color1, Transparency);
	instance:createChannelGroup("2.Line","2.Line" , Zero2, wt2, instance.parameters.color2, Transparency);
	instance:createChannelGroup("3.Line","3.Line" , Zero3, wt1wt2, instance.parameters.color3, Transparency);
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);	
	
    Line = instance:addStream("Line", core.Line, name, "Line", instance.parameters.color4, first+n1+n2 );
    Line:setPrecision(math.max(2, instance.source:getPrecision())); 
    Line:addLevel(0);		
end


function Update(period, mode)

	Zero1[period]=0;
	Zero2[period]=0;
	Zero3[period]=0;
	
	EMA1:update(mode); 

	if period <= first then
	return;
	end
	
	
    d[period]= math.abs(source[period] - EMA1.DATA[period]);	
	EMA2:update(mode);	
	
	if period <= first +n1  then
	return;
	end
	 
	
    ci[period] = (source[period] -  EMA1.DATA[period]) / (0.015 * EMA2.DATA[period])


 	EMA3:update(mode);
	if period <= first+n1+n2  then
	return;
	end
	
 
   wt1[period] = EMA3.DATA[period];
   
  	MVA:update(mode);
	if period <= first+n1+n2+n3   then
	return;
	end  
	
   wt2[period] = MVA.DATA[period];	 
   
   
   wt1wt2[period]=wt1[period]-wt2[period];
   
   
   Last[period]=Last[period-1];
   Period[period]=Period[period-1];
   
   if wt1wt2[period]> 0 
   and wt1wt2[period-1]<= 0   
   or   
   wt1wt2[period]< 0 
   and wt1wt2[period-1]>= 0
   
   then
   Last[period]=wt2[period];
   Period[period]=period;   
   end
   
   
    up:setNoData(period);
    down:setNoData(period); 
	
    if Last[period]~= Last[period-1] then
			if wt1[period] > wt2[period] then
			up:set(period, Last[period], "\217", Last[period]);	
			else
			down:set(period, Last[period], "\218", Last[period]);	
			end	
			
    core.drawLine(Line, core.range(Period[period-1],  Period[period]),   Last[period-1],Period[period-1], Last[period],Period[period] ,   instance.parameters.color4);		
    --core.drawLine(output, core.range(bar1, bar2), source[bar1], bar1, source[bar2], bar2);	
	end
	
end
 

