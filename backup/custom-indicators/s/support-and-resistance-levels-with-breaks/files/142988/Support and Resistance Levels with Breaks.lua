-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71374
 
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

function Init()
    indicator:name("Support and Resistance Levels with Breaks");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addBoolean("toggleBreaks", "Show Breaks", "", false);

	indicator.parameters:addBoolean("Arrows", "Show Arrows", "", true);
	indicator.parameters:addBoolean("Labels", "Show Labels", "", true);
	
	
    indicator.parameters:addInteger("leftBars", "leftBars", "", 15, 1, 2000);
    indicator.parameters:addInteger("rightBars", "rightBars", "", 15, 1, 2000);	
    indicator.parameters:addInteger("volumeThresh", "volumeThresh", "", 20, 1, 2000);
 
	indicator.parameters:addGroup("Arrow Style");  
     indicator.parameters:addColor("clrUP", "Up Arrow Color","", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN", "Down Arrow","", core.COLOR_DOWNCANDLE);
	
	indicator.parameters:addGroup("Line Style"); 	
    indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);


    indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);	
	
	
	indicator.parameters:addGroup("Label Style"); 	
    indicator.parameters:addInteger("Size", "Label Size", "", 10);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local leftBars, rightBars, volumeThresh,toggleBreaks;
local first;
local source = nil;
local Top, Bottom;
local Oscillator;  
local Indicator={};
local Average;
local up, down;
local osc;
local label_up, label_down;
local Shift;
-- Routine
 function Prepare(nameOnly)   
 
 
    leftBars= instance.parameters.leftBars;
    rightBars= instance.parameters.rightBars;
	volumeThresh= instance.parameters.volumeThresh;
	Arrows= instance.parameters.Arrows;
	Labels= instance.parameters.Labels;
	
	local Parameters= leftBars..", "..rightBars..", "..volumeThresh;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

       font = core.host:execute("createFont", "Courier", instance.parameters.Size, false, true);
    
			
    source = instance.source; 
	

	
	
	long = core.indicators:create("EMA", source.volume, 5);
    short = core.indicators:create("EMA", source.volume, 10);
    first=math.max(short.DATA:first(),source:first()+leftBars+rightBars);
	
	
	if Arrows then
	up = instance:createTextOutput ("Up", "Up", "Wingdings", 9, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", 9, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);
	end
    if Labels then
	label_up = instance:createTextOutput ("label_up", "Up", "Arial", 9, core.H_Center, core.V_Top, instance.parameters.clrUP, 0);
	label_down = instance:createTextOutput ("label_down", "Down", "Arial", 9, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0);	
	end
	
	osc= instance:addInternalStream(0, 0);
   
 
 	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.color1, first );
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
    Top:setPrecision(math.max(2, source:getPrecision()));
	
 	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.color2, first );
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
    Bottom:setPrecision(math.max(2, source:getPrecision()));	
end

-- Indicator calculation routine
function Update(period, mode)

	short:update(mode);
	long:update(mode); 
	
	if period <=  first 
	then
	return;
	end 
   
   	Shift=(source:date(period)-source:date(period-1))*20;
   

    osc[period] = 100 * (short.DATA[period] - long.DATA[period]) / long.DATA[period]; 
	 
	pivothigh(period);
	 
    AddLabels(period);
	 
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   

function AddLabels (period)

				if not Labels then
				return;
				end
				period= period -rightBars;

				local message_up="";
				local message_down="";
				 

				if source.close[period]< Bottom[period]  and osc[period] > volumeThresh and   source.close[period-1] >= Bottom[period-1]  then   message_up = "Support Broken" end
				if source.close[period]> Top[period]  and osc[period] > volumeThresh and source.close[period-1]<= Top[period-1] then    message_down = "Resistance Broken" end
				 


				if toggleBreaks and source.close[period]> Top[period]  and osc[period] > volumeThresh and not ((source.open[period] - source.close[period]) < (source.high[period] - source.open[period])) and source.close[period-1]< Top[period-1]  then   message_up = "Break" end
				if  toggleBreaks and source.close[period]< Bottom[period]  and osc[period] > volumeThresh and not ((source.open[period] - source.low[period]) < (source.close[period] - source.open[period]))and  source.close[period-1]> Bottom[period-1] then   message_down = "Break" end

				if toggleBreaks and source.close[period]> Top[period]  and osc[period] > volumeThresh and not ((source.open[period] - source.low[period]) < (source.close[period] - source.open[period])) then   message_up = "Bull Wick" end
				if  toggleBreaks and source.close[period]< Bottom[period]  and osc[period] > volumeThresh and not ((source.open[period] - source.close[period]) < (source.high[period] - source.open[period])) then   message_down = "Bear Wick" end
				 
				 
				label_up:setNoData(period  );
				label_down:setNoData(period );
				
				if message_up~=nil then   
				label_up:set(period, source.high[period], message_up, source.high[period]); 
				end
				
				if message_down~=nil then
				label_down:set(period, source.low[period], message_down, source.low[period]);
				end	
      
end


function pivothigh(period)
period= period -rightBars;

Top[period]=Top[period-1];
Bottom[period]=Bottom[period-1];



        if Arrows then
			up:setNoData(period  );
			down:setNoData(period );
        end 

			local max_left=mathex.max(source.high, period-leftBars+1, period);
			local max_right=mathex.max(source.high, period, period+rightBars);

			if max_left<= source.high[period] and max_right <= source.high[period]  then
				 if Arrows then
				up:set(period, source.high[period], "\217", source.high[period]); 
				 end
			core.drawLine (Top, core.range(period, period+rightBars) ,  source.high[period], period,  source.high[period], period+rightBars, instance.parameters.color1);
			end
		
		


local min_left=mathex.min(source.low, period-leftBars+1, period);
local min_right=mathex.min(source.low, period, period+rightBars);

		if min_left>= source.low[period] and min_right >= source.low[period]  then
			if Arrows then
			down:set(period, source.low[period], "\218", source.low[period]); 
			end		
        core.drawLine (Bottom, core.range(period, period+rightBars) ,  source.low[period], period,  source.low[period], period+rightBars, instance.parameters.color2);	 	
		end 
		
 	core.host:execute ("drawLine", 1, source:date(period), Top[period], source:date(period+rightBars), Top[period], instance.parameters.color1, instance.parameters.style1, instance.parameters.width1); 	
 	core.host:execute ("drawLine", 2, source:date(period), Bottom[period], source:date(period+rightBars), Bottom[period], instance.parameters.color2, instance.parameters.style2, instance.parameters.width2); 	
	
	if Bottom[period]~= Bottom[period-1]  then
	Bottom:setBreak (period, true);
	end
	
	if Top[period]~= Top[period-1] then
	Top:setBreak (period, true);
	end	
	
	local TheLabel="";
	
	  if Top[period]~= nil then
	  local Label = win32.formatNumber(Top[period], false, source:getPrecision());
	  core.host:execute("drawLabel1", 3, source:date(period) +Shift , core.CR_CHART, Top[period], core.CR_CHART, core.H_Right, core.V_Top, font,core.COLOR_LABEL , Label);
	  TheLabel="Top:".. Label;
      end	 
	  if Bottom[period]~= nil then	  	
	  local Label = win32.formatNumber(Bottom[period], false, source:getPrecision());							 
	  core.host:execute("drawLabel1", 4, source:date(period) +Shift , core.CR_CHART, Bottom[period], core.CR_CHART, core.H_Right, core.V_Top, font,core.COLOR_LABEL , Label);
	  TheLabel=TheLabel .." Bottom:".. Label;	  
      end	  
	  
	  
	core.host:execute("setStatus", TheLabel);
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