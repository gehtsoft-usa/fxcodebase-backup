-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71635

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

--+------------------------------------------------------------------------------------------------+
--|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
--|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
--|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
--|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
--+------------------------------------------------------------------------------------------------+
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters

-- =============================================================================
-- 										Parametres
-- =============================================================================

function Init()
indicator:name("MTD indicateur");
indicator:description("");
indicator:requiredSource(core.Bar);
indicator:type(core.Indicator);
end

-- ======================================================================================================
-- 	Indicator instance initialization routine : Processes indicator parameters and creates output streams
-- ======================================================================================================
	--
	-- Parametres
	--
	local first;
	local source = nil;
	
	--
	-- Calcul
	--
			
		-- CCI
		local cci;
		local CCI;
		
			-- Slow
			local vect_CCI_slow;
			local MA_A_CCI_slow;
			local trend_CCI_slow;
			local SDL_CCI_slow;
			local MA_CCI_slow;
			local MA2_CCI_slow;
			
			-- Fast
			local vect_CCI_fast;
			local MA_A_CCI_fast;
			local trend_CCI_fast;
			local SDL_CCI_fast;
			local MA_CCI_fast;
			local MA2_CCI_fast;			
			
		-- TREND
		local vect_M;
		local MA_A_M;
		local trend_M;
		local SDL_M;
		local MA_M;
		local MA2_M;
		
		-- PRICE BALANCE
		local pbsup500;
		local pbsup450;
		local pbsup400;
		local pbsup350;
		local pbsup300;
		local pbsup250;
		local pbsup200;
		local pbsup150;
		local pbsup100;
		local pbsup50;
		local pb;		
		local pbinf50;
		local pbinf100;
		local pbinf150;
		local pbinf200;
		local pbinf250;
		local pbinf300;
		local pbinf350;
		local pbinf400;
		local pbinf450;
		local pbinf500;
			
-- =============================================================================
-- 										Routines
-- =============================================================================

function Prepare(nameOnly)
--
-- Parametres
--
source = instance.source;



local name = profile:id() .. "(" .. source:name() .. ")";
instance:name(name);
	
if   (nameOnly) then
	return;
end

--
-- Calcul
--
	-- CCI
	cci = core.indicators:create("CCI", source, 100);
	first = cci.DATA:first();
	
	
-- 
-- STYLE
--
	
	-- PRICE BALANCE
	pbsup500 = instance:addStream("500", core.Line, name .. ".500", "500", core.rgb(0, 128, 0), first);
	pbsup500:setWidth(1);
	pbsup500:setStyle(core.LINE_DASHDOT);
	
	pbsup450 = instance:addStream("450", core.Line, name .. ".450", "450", core.rgb(128, 128, 128), first);
	pbsup450:setWidth(1);
	pbsup450:setStyle(core.LINE_DOT);
	
	pbsup400 = instance:addStream("400", core.Line, name .. ".400", "400", core.rgb(0, 160, 0), first);
	pbsup400:setWidth(1);
	pbsup400:setStyle(core.LINE_DASHDOT);
	
	pbsup350 = instance:addStream("350", core.Line, name .. ".350", "350", core.rgb(128, 128, 128), first);
	pbsup350:setWidth(1);
	pbsup350:setStyle(core.LINE_DOT);
	
	pbsup300 = instance:addStream("300", core.Line, name .. ".300", "300", core.rgb(0, 192, 0), first);
	pbsup300:setWidth(1);
	pbsup300:setStyle(core.LINE_DASHDOT);
	
	pbsup250 = instance:addStream("250", core.Line, name .. ".250", "250", core.rgb(128, 128, 128), first);
	pbsup250:setWidth(1);
	pbsup250:setStyle(core.LINE_DOT);

	pbsup200 = instance:addStream("200", core.Line, name .. ".200", "200", core.rgb(0, 224, 0), first);
	pbsup200:setWidth(1);
	pbsup200:setStyle(core.LINE_DASHDOT);
	
	pbsup150 = instance:addStream("150", core.Line, name .. ".150", "150", core.rgb(128, 128, 128), first);
	pbsup150:setWidth(1);
	pbsup150:setStyle(core.LINE_DOT);
	
	pbsup100 = instance:addStream("100", core.Line, name .. ".100", "100", core.rgb(0, 255, 0), first);
	pbsup100:setWidth(1);
	pbsup100:setStyle(core.LINE_DASHDOT);

	pbsup50 = instance:addStream("50", core.Line, name .. ".50", "50", core.rgb(128, 128, 128), first);
	pbsup50:setWidth(1);
	pbsup50:setStyle(core.LINE_DOT);
	
	pb = instance:addStream("PB", core.Line, name .. ".PB", "PB", core.rgb(255, 255, 255), first);
	pb:setWidth(2);
	pb:setStyle(core.LINE_DASHDOT);
	
	pbinf50 = instance:addStream("-50", core.Line, name .. ".-50", "-50", core.rgb(128, 128, 128), first);
	pbinf50:setWidth(1);
	pbinf50:setStyle(core.LINE_DOT);
	
	pbinf100 = instance:addStream("-100", core.Line, name .. ".-100", "-100", core.rgb(255, 0, 0), first);
	pbinf100:setWidth(1);
	pbinf100:setStyle(core.LINE_DASHDOT);
	
	pbinf150 = instance:addStream("-150", core.Line, name .. ".-150", "-150", core.rgb(128, 128, 128), first);
	pbinf150:setWidth(1);
	pbinf150:setStyle(core.LINE_DOT);

	pbinf200 = instance:addStream("-200", core.Line, name .. ".-200", "-200", core.rgb(224, 0, 0), first);
	pbinf200:setWidth(1);
	pbinf200:setStyle(core.LINE_DASHDOT);
	
	pbinf250 = instance:addStream("-250", core.Line, name .. ".-250", "-250", core.rgb(128, 128, 128), first);
	pbinf250:setWidth(1);
	pbinf250:setStyle(core.LINE_DOT);
	
	pbinf300 = instance:addStream("-300", core.Line, name .. ".-300", "-300", core.rgb(192, 0, 0), first);
	pbinf300:setWidth(1);
	pbinf300:setStyle(core.LINE_DASHDOT);
	
	pbinf350 = instance:addStream("-350", core.Line, name .. ".-350", "-350", core.rgb(128, 128, 128), first);
	pbinf350:setWidth(1);
	pbinf350:setStyle(core.LINE_DOT);
	
	pbinf400 = instance:addStream("-400", core.Line, name .. ".-400", "-400", core.rgb(160, 0, 0), first);
	pbinf400:setWidth(1);
	pbinf400:setStyle(core.LINE_DASHDOT);

	pbinf450 = instance:addStream("-450", core.Line, name .. ".-450", "-450", core.rgb(128, 128, 128), first);
	pbinf450:setWidth(1);
	pbinf450:setStyle(core.LINE_DOT);
	
	pbinf500 = instance:addStream("-500", core.Line, name .. ".-500", "-500", core.rgb(128, 0, 0), first);
	pbinf500:setWidth(1);
	pbinf500:setStyle(core.LINE_DASHDOT);
end

-- =============================================================================
-- 						Indicator calculation routine
-- =============================================================================

local Id;
function Update(period, mode)
--
-- CCI
--
	-- Parametres
    cci:update(mode);
	
	-- Calcul
	
		-- CCI
		if period >= first then
			local from = period - 100 + 1;
			local to = period;
			local mean = mathex.avg(source, from, to);
			local meandev = mathex.meandev(source, from, to);
						
			if (meandev == 0) then
				pb[period] = 0;
			end
		end
		
 
--
-- PRICE BALANCE
--
	-- calcul
	if period >= first then
		local from = period - 100 + 1;
		local to = period;
		local mean = mathex.avg(source, from, to);
		local meandev = mathex.meandev(source, from, to);
					
		if (meandev == 0) then
			pb[period] = 0;
		else
	
			pbsup500[period] = mean + (( 500) * (0.015 * meandev))
			pbsup450[period] = mean + (( 450) * (0.015 * meandev))
			pbsup400[period] = mean + (( 400) * (0.015 * meandev))
			pbsup350[period] = mean + (( 350) * (0.015 * meandev))
			pbsup300[period] = mean + (( 300) * (0.015 * meandev))
			pbsup250[period] = mean + (( 250) * (0.015 * meandev))
			pbsup200[period] = mean + (( 200) * (0.015 * meandev))
			pbsup150[period] = mean + (( 150) * (0.015 * meandev))
			pbsup100[period] = mean + (( 100) * (0.015 * meandev))
			pbsup50[period] = mean + (( 50) * (0.015 * meandev))
			pb[period] = mean + (  (0.015 * meandev))
			pbinf50[period] = mean + (( - 50) * (0.015 * meandev))
			pbinf100[period] = mean + (( - 100) * (0.015 * meandev))
			pbinf150[period] = mean + (( - 150) * (0.015 * meandev))
			pbinf200[period] = mean + (( - 200) * (0.015 * meandev))
			pbinf250[period] = mean + (( - 250) * (0.015 * meandev))
			pbinf300[period] = mean + (( - 300) * (0.015 * meandev))
			pbinf350[period] = mean + (( - 350) * (0.015 * meandev))
			pbinf400[period] = mean + (( - 400) * (0.015 * meandev))
			pbinf450[period] = mean + (( - 450) * (0.015 * meandev))
			pbinf500[period] = mean + (( - 500) * (0.015 * meandev))
			
			Id=0;
            for i= 1,11 , 1 do 
			AddLevels (i, meandev, mean); 
			end  
		end
	end
	
	
	
	-- Style
		-- Up
		if pb[period] > pb[period-1]
			then pb:setColor(period, core.rgb(0, 255, 0));
								
		-- Down	
		elseif pb[period] < pb[period-1]
			then pb:setColor(period, core.rgb(255, 0, 0));
		end
		
 
end

local Label={"0", "50", "100", "150", "200", "250", "300", "350", "400", "450", "500"};

function AddLevels (i, meandev, mean)

local period=source:size()-1;

if i == 1 then

	local text=Label[i].. " : " .. tostring( win32.formatNumber(mean, false, source:getPrecision())); 
	Id=Id+1;
	core.host:execute ("drawLabel", Id, source:date(period), mean , text);
else

	local 	Level =  ((  50*(i-1)) * (0.015 * meandev));

	local text=Label[i].. " : " .. tostring( win32.formatNumber(mean+Level, false, source:getPrecision())); 
	Id=Id+1;
	core.host:execute ("drawLabel", Id, source:date(period), mean+ Level , text);


	local text=Label[i].. " : " .. tostring( win32.formatNumber(mean-Level, false, source:getPrecision())); 
	Id=Id+1;
	core.host:execute ("drawLabel", Id, source:date(period), mean- Level , text);
end

end

