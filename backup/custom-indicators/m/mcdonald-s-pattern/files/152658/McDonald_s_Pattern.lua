-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74191

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+

-- TO DO =====================================================================================
-- To incorporate automatically identifying the 5 points(peaks/troughs) ,,,,, If there exists 
-- a specifications for the depth and width of these 5 peaks/troughs.
-- Instead of parameterizing these 5 points manually.
--============================================================================================

function Init()
    indicator:name("Besier Quadratic Parabola");
    indicator:description("Besier Quadratic Parabola");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

 	indicator.parameters:addInteger("x1", "x1", "x1", 52, 1, 10000)
 	indicator.parameters:addInteger("x2", "x2", "x2", 34, 1, 10000)
 	indicator.parameters:addInteger("x3", "x3", "x3", 20, 1, 10000)
 	indicator.parameters:addInteger("x4", "x4", "x4", 10, 1, 10000)
 	indicator.parameters:addInteger("x5", "x5", "x5", 3, 1, 10000)
end

local	source, period, first, fst, pPrd, x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, McArch

function Prepare()
	source= instance.source
	first= source:first()
	x1= instance.parameters.x1
	x2= instance.parameters.x2 
	x3= instance.parameters.x3 
	x4= instance.parameters.x4 
	x5= instance.parameters.x5 
	fst=true


   local name = profile:id().."(Besier Quadratic Parabola,  ".."x1="..x1.."  x2="..x2.."  x3="..x3.."  x4="..x4.."  x5="..x5..")"
   instance:name(name)

	McArch= instance:addStream("McArch", core.Line, "McArch", "McArch", core.rgb(255,255,0), first)
	McArch:setWidth(4)
end

function Update(period)
	if fst then pPrd=period fst=false end
	if period<first+source:size()-2 or pPrd==period then return end
	
	y1= source.close[period-x1]
	y2= source.close[period-x2]
	y3= source.close[period-x3]
	y4= source.close[period-x4]
	y5= source.close[period-x5]
	
	for i= 0, (x1-x3), 1 do 
		local k1, k2= math.abs(i/(x1-x3)), math.abs((i+1)/(x1-x3))
		local yMc1= math.pow((1-k1), 2)*y1+ (2*(1-k1)*k1)*y2+ math.pow( k1, 2)*y3
		local yMc2= math.pow((1-k2), 2)*y1+ (2*(1-k2)*k2)*y2+ math.pow( k2, 2)*y3
		core.drawLine(McArch, core.range(	period-x1+i, 		period-x1+i+1), 
			yMc1, 							period-x1+i, 
			yMc2, 												period-x1+i+1) 
	end

	for i= 0, (x3-x5), 1 do 
		local k1, k2= math.abs(i/(x3-x5)), math.abs((i+1)/(x3-x5))
		local yMc1= math.pow((1-k1), 2)*y3+ (2*(1-k1)*k1)*y4+ math.pow( k1, 2)*y5
		local yMc2= math.pow((1-k2), 2)*y3+ (2*(1-k2)*k2)*y4+ math.pow( k2, 2)*y5
		core.drawLine(McArch, core.range(	period-x3+i, 		period-x3+i+1), 
			yMc1, 							period-x3+i, 
			yMc2, 												period-x3+i+1) 
	end

	pPrd=period
end


function AsyncOperationFinished(cookie, success, message)
end


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--| USDT Donations                                                                                 |
--+------------------------------------------------+-----------------------------------------------+
--| Network                                        |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--| ERC20 (ETH Ethereum)                           |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--| TRC20 (Tron)                                   |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--| BEP20 (BSC BNB Smart Chain)                    |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--| Matic Polygon                                  |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--| SOL Solana                                     |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--| ARBITRUM Arbitrum One                          |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+