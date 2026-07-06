-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=73632

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
    indicator:name("Zig zag based ABCD Histogram");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P1", "Depth", "the minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("P2", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("P3", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
		
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "AB Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color2", "BC Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("color3", "CD Line Color", "", core.rgb(0, 0, 255));
	
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


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;    
	ZigZag= core.indicators:create("ZIGZAG", source, instance.parameters.P1, instance.parameters.P2,instance.parameters.P3);
	
	first=ZigZag.DATA:first() ; 
 
	AB = instance:addStream("AB" , core.Line, " AB"," AB",instance.parameters.color1, first); 
    AB:setPrecision(math.max(2, source:getPrecision()));
	
	BC = instance:addStream("BC" , core.Line, " BC"," BC",instance.parameters.color2, first); 
    BC:setPrecision(math.max(2, source:getPrecision()));

	CD = instance:addStream("CD" , core.Line, " CD"," CD",instance.parameters.color3, first); 
    CD:setPrecision(math.max(2, source:getPrecision()));	
end
local FirstLoad=true;
local SecondLoad=true;
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
	
	local FirstPeriod, SecondPeriod;
	
	if FirstLoad then
	FirstLoad=false;
	
	
			for i= first, source:size()-1, 1 do
			
			 
			 
				  A,B,C,D= FindLast(i);
				  if A~=nil and	 B~=nil  and C~=nil and D~=nil then
		          AB[i]= ZigZag.DATA[B]-ZigZag.DATA[A];
		          BC[i]= ZigZag.DATA[C]-ZigZag.DATA[B];
		          CD[i]= ZigZag.DATA[D]-ZigZag.DATA[C];	
                  end				  
					
				 
			end
	
	else
	
 
	 
			 A,B,C,D= FindLast(period);
			 

			 if A~=nil and	 B~=nil  and C~=nil and D~=nil then	
			 Period=math.max(A, B,C,D)
				 for i= Period, source:size()-1, 1 do	 

					  AB[i]= ZigZag.DATA[B]-ZigZag.DATA[A];
					  BC[i]= ZigZag.DATA[C]-ZigZag.DATA[B];
					  CD[i]= ZigZag.DATA[D]-ZigZag.DATA[C];
				 end
			 end
		
    end    
	
	
				
	 
	 
				  
end



function FindLast(period)

		local Return={};
        local Count=0;
		for i = period, first, -1 do 
		
		    if ZigZag.DATA:hasData(i) then

					if  source.high[i]== ZigZag.DATA[i]
					or  source.low[i]== ZigZag.DATA[i]
					then
					Count=Count+1;
					Return[Count]=i;
					end
					
					 

            end			
			
			if Count==4  then
			break;
			end

		end


   return Return[4], Return[3], Return[2], Return[1] ;

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