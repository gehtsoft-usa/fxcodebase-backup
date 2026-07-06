-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=73655

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
    indicator:name("Zig Zag Price Difference");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P1", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("P2", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("P3", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
    indicator.parameters:addBoolean("Absolute", "Absolute Value", "", false);	
    indicator.parameters:addBoolean("Revers", "Revers", "", false);			
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Positive Difference Bar Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "Negative Difference Bar Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
local first;
local source = nil;
 

local ZigZag;
-- Routine
 function Prepare(nameOnly)    
	local Parameters= "";
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 
	
	Absolute=instance.parameters.Absolute;


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;    
	ZigZag= core.indicators:create("ZIGZAG", source, instance.parameters.P1, instance.parameters.P2,instance.parameters.P3);
	
	first=ZigZag.DATA:first() ; 
 
	Difference = instance:addStream("Difference" , core.Bar, " Difference"," Difference",instance.parameters.color1, first); 
    Difference:setPrecision(math.max(2, source:getPrecision()));
	 
end
local FirstLoad=true;
local Last;
-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:size()-1  
	then
	return;
	end
	
	
	if Last~=source:serial(period) then
	Last=source:serial(period);		
	ZigZag:update(core.UpdateAll); 
	end
	 
	if FirstLoad then
	FirstLoad=false;
	
	
			for i= first, source:size()-1, 1 do 
			 
				  Last= FindLast(i);
				  if Last~=0 then
				  if Revers then
		          Difference[i]= (source.close[i]-ZigZag.DATA[Last])/source:pipSize(); 
				  else
		          Difference[i]= (ZigZag.DATA[Last]-source.close[i])/source:pipSize(); 
                  end				  
					  if Absolute  then
					  Difference[i]=math.abs(Difference[i]) 				  
					  end	
				  end	  
			end 
	else
	
 
	 
			 Last = FindLast(period);
			 

			 if Last~=0 then	 
				 for i= Last, source:size()-1, 1 do	 

                  if Revers then
		          Difference[i]=(source.close[i]-ZigZag.DATA[Last])/source:pipSize(); 
				  else
		          Difference[i]=(ZigZag.DATA[Last]-source.close[i])/source:pipSize(); 				  
				  end

					  if Absolute  then
					  Difference[i]=math.abs(Difference[i]) 			  
					  end
					  
				 end
			 end		
    end   		  
end



function FindLast(period)

		local Return=0;

		for i = period, first, -1 do 
		
		    if ZigZag.DATA:hasData(i) then

					if Return== 0 
					and source.high[i]== ZigZag.DATA[i]
					then
					Return=i;
					end
					
					if Return== 0 
					and source.low[i]== ZigZag.DATA[i]
					then
					Return=i;
					end 

            end			
			
			if Return~=0  then
			break;
			end

		end


   return Return;

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