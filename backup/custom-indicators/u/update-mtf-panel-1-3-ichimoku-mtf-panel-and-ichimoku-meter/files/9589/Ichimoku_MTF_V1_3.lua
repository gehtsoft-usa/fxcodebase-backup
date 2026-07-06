-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3890

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+

-- Moved Legend to the middle of the Chart ID greater then 500


-- Available TimeFrames Maximum Time frame will be D1
local TIMEFRAMES={"D1", "H8","H4","H1", "m30","m15","m5","m1"};

function Init()
    indicator:name("Ichimoku MTF Panel V1.3");
    indicator:description("Multi Timeframe Ichimuko Panel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator:setTag("group", "GSL");

	indicator.parameters:addGroup("Ichimoku Parameters");
    indicator.parameters:addInteger("X", "TenkanSen", "", 9);
    indicator.parameters:addInteger("Y", "KijunSen", "", 26);
    indicator.parameters:addInteger("Z", "SenkoSpan", "", 52);
	indicator.parameters:addBoolean("Prev", "Use Previously Bar", "", false);
	
    indicator.parameters:addGroup("Graphics");
	indicator.parameters:addString("Pos", "Position of the Panel", "", "TopRight");
    indicator.parameters:addStringAlternative("Pos", "BottomRight", "", "BottomRight");
	indicator.parameters:addStringAlternative("Pos", "BottomLeft", "", "BottomLeft");
    indicator.parameters:addStringAlternative("Pos", "TopRight", "", "TopRight");
	indicator.parameters:addStringAlternative("Pos", "TopLeft", "", "TopLeft");
	
	
	indicator.parameters:addString("Type","Time Frame Order", "", "Ascending");
    indicator.parameters:addStringAlternative("Type", "Ascending", "", "Ascending");
	indicator.parameters:addStringAlternative("Type", "Decreasing", "", "Decreasing");
	
	indicator.parameters:addBoolean("Legend", "Show Legend", "", false);
	--indicator.parameters:addBoolean("Background", "Show Background", "", false);
	indicator.parameters:addColor("cBackground", "color background", "", core.rgb(0,0,32));
    indicator.parameters:addColor("Text", "color text", "", core.rgb(192, 192, 192));
    indicator.parameters:addColor("Weak", "color Weak", "", core.rgb(255, 255, 0));
    indicator.parameters:addColor("Bear", "color Bearish", "", core.rgb(255, 128, 128));
    indicator.parameters:addColor("StrongBear", "color Strong Bearish", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Bull", "color Bullish", "", core.rgb(128, 255, 128));
    indicator.parameters:addColor("StrongBull", "color Strong Bullish", "", core.rgb(0, 255, 0));

    indicator.parameters:addColor("S1_color", "Color of S1", "Color of S1", core.rgb(255, 0, 0));
    indicator.parameters:addGroup("Show Time Frame");
    local i;
    for i= 1, 8, 1 do	
        indicator.parameters:addBoolean("ON"..i, TIMEFRAMES[i], "", true);
	end

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local S1 = nil;
-- Coding
local ON = nil;

local ONOFF={};

local day_offset, week_offset;
local dummy;
local stream;
local host;

local ICH;
local SL;
local TL;
local CS;
local SA;
local SB;
local stream;
local sW = nil;
local sF = nil;
local bF = nil;
local bb = nil;
local lb = nil;
local cText;
local count = 0;
local Type;
local Label={"TF", "PA", "PK", "TK", "CS", "CK", "CC"};
-- Routine
function Prepare(nameOnly)
    X = instance.parameters.X;
    Y = instance.parameters.Y;
    Z = instance.parameters.Z;
	cBackground = instance.parameters.cBackground;
    Weak = instance.parameters.Weak;
    Bear = instance.parameters.Bear;
    Bull = instance.parameters.Bull;
    StrongBear = instance.parameters.StrongBear;
    StrongBull = instance.parameters.StrongBull;
    cText = instance.parameters.Text;
	Type = instance.parameters.Type;
    source = instance.source;
    first = source:first() + Z;
    host = core.host;
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");

    Legend = instance.parameters.Legend
    local i;
    for i= 1, 8, 1 do	 
        ONOFF[i]=instance.parameters:getBoolean ("ON"..i);
    end	
	
    
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        dummy = instance:addInternalStream(0, 0);
        sW = core.host:execute("createFont","Wingdings",10,false,false);
        sF = core.host:execute("createFont","Consolas",10,false,false);
        bF = core.host:execute("createFont","Consolas",14,false,false);
		bb = core.host:execute("createFont","Wingdings",340,false,false);
        lb = core.host:execute("createFont","Wingdings",400,false,false);
    else
        return;
    end
    count = 0;
	for i= 1, 8, 1 do	 
        if ONOFF[i] then
				count = count+1;
		end
    end	
	
	-- Legend ----------------------------------------------------------------------------------------------------------------
	
	-- Legend ----------------------------------------------------------------------------------------------------------------
	if Legend then
		--if instance.parameters.Background then
			--drwText("n",500,-25,cBackground,lb);
		--end
		drwText("------ Legend MTF -----------" ,501,-170,cText,bF);
		drwText("PA    : Price against Cloud",502,-150,cText,sF);
		drwText("PKS   : Price against KijunSen",503,-135,cText,sF);
		drwText("TSKS  : TenkanSen against KijunSen",504,-120,cText,sF);
		drwText("CS    : Chikou Position",505,-105,cText,sF);
        drwText("CK    : Chikou against KijunSen",506,-90,cText,sF);
        drwText("CC    : Chikou against Cloud",507,-75,cText,sF);
		drwText("----- Options -------------------",508,-55,cText,sF);
		drwText("Use Prev : Signal based on Last Candle",509,-40,cText,sF);
		drwText("Disable TimeFrame removed complete TF Row",510,-25,cText,sF);
		drwText("----- Description -------------------",511,-10,cText,sF);
		drwText("MTF Ichimoku Panel 1.3",512,5,cText,sF);
		drwText("Simple read the Ichimoku Signals",513,20,cText,sF);
		drwText("from different Timeframes",514,35,cText,sF);
		drwText("Written by Gidien @ 2011",515,55,cText,sF);
	end
	
	drwText("----------------------------------",1,-75-15*count,cText,sF);
    drwText(profile:name(),2,-50-15*count,cText,bF);
    drwText("----------------------------------",3,-35-15*count,cText,sF);
	
	if instance.parameters.Pos == "TopRight"  or  instance.parameters.Pos == "TopLeft" then
	 
	y= 15*6; 
	else
	y= -15*9; 
	end
	
	for ID= 1001, 1007,1 do
           if instance.parameters.Pos == "TopRight" or instance.parameters.Pos == "BottomRight"   then       
		   x= -8 *35 +35*(ID-1000);
		   elseif instance.parameters.Pos == "TopLeft"  or  instance.parameters.Pos == "BottomLeft"then
		   x= 35*(ID-1000)-15 ; 
		   end
	
	 
			if ID ==1001 then
				-- Legend
				core.host:execute("drawLabel1", ID,  x, XC(), y, YC(), core.H_Center, core.V_Center, sF, cText, Label[(ID-1000)]);
			elseif ID ==1002 then
				-- Legend
				core.host:execute("drawLabel1", ID, x,XC(), y, YC(), core.H_Center, core.V_Center, sF, cText, Label[(ID-1000)]);
			elseif ID ==1003 then
				-- Legend
				core.host:execute("drawLabel1", ID,  x, XC(), y, YC(), core.H_Center, core.V_Center, sF, cText, Label[(ID-1000)]);
			elseif ID ==1004 then
				-- Legend
				core.host:execute("drawLabel1", ID,  x, XC(), y, YC(), core.H_Center, core.V_Center, sF, cText, Label[(ID-1000)]);

			elseif ID ==1005 then
				-- Legend
				core.host:execute("drawLabel1", ID,  x, XC(), y, YC(), core.H_Center, core.V_Center, sF, cText, Label[(ID-1000)]);
			elseif ID ==1006 then
				-- Legend
				core.host:execute("drawLabel1", ID,  x, XC(), y, YC(), core.H_Center, core.V_Center, sF, cText, Label[(ID-1000)]);

			elseif ID ==1007 then
				-- Legend
				core.host:execute("drawLabel1", ID,  x, XC(), y, YC(), core.H_Center, core.V_Center, sF, cText, Label[(ID-1000)]);
			end	
				
				
	end
	
    drwText("----------------------------------",5,-5-15*count,cText,sF);
    

    
end


function ReleaseInstance()
    core.host:execute("deleteFont", sW);
    core.host:execute("deleteFont", sF);
	core.host:execute("deleteFont", bF);
	core.host:execute("deleteFont", bb);
	core.host:execute("deleteFont", lb);
end
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
local sUP 	= "\233";
local sDN 	= "\234";
local aUP 	= "\236";
local aDN 	= "\238";
local flat 	= "\232";
------------------------------------------------------------------------------------------------------------------------------------------------
local MAX;
function Update(period,mode)

        local i;
		-- Register all Streams
		if 	stream 	== nil then  
		    MAX=0;
            stream	=  {};
            ICH 	=  {};
            SL 		=  {};
            TL 		=  {};
            CS 		=  {};
            SA 		=  {};
            SB 		=  {};
            for i = 1, 8 , 1 do	
                if 	ONOFF[i] 																												then				
                    stream[i] 	= registerStream(i, TIMEFRAMES[i],100);			  
                    ICH[i] 		= core.indicators:create("ICH", stream[i], X,Y,Z);
                    SL[i] 		= ICH[i]:getStream(0);   
                    TL[i] 		= ICH[i]:getStream(1);   
                    CS[i] 		= ICH[i]:getStream(2);   
                    SA[i] 		= ICH[i]:getStream(3);  
                    SB[i] 		= ICH[i]:getStream(4);
					MAX=MAX+1;
                end
            end
        end
		-- End Register all Streams
		----------------------------------------------------------------------------------------------------------------------------------------
		-- Start Signal Part
        local p , loading;
        local c = 0;
        for i = 1, 8 , 1 do
		----------------------------------------------------------------------------------------------------------------------------------------
            if 	ONOFF[i] 																													then
                c=c+1;
				
			if Type == "Ascending" then	
			Shift=10-15*c;
			else
			Shift= 10-15*MAX+ (c-1)*15;
			end
				if i == 1 then drwText("D1 :"    	,6,Shift,cText,sF); end
				if i == 2 then drwText("H8 :"   	,7,Shift,cText,sF); end
				if i == 3 then drwText("H4 :"   	,8,Shift,cText,sF); end
				if i == 4 then drwText("H1 :"    	,9,Shift,cText,sF); end
				if i == 5 then drwText("M30:"    	,10,Shift,cText,sF); end
				if i == 6 then drwText("M15:"    	,11,Shift,cText,sF); end
				if i == 7 then drwText("M5 :"    	,12,Shift,cText,sF); end
				if i == 8 then drwText("M1 :"    	,13,Shift,cText,sF); end
	
			 
			
                p, loading 					= 		getPeriod(i, period);
			------------------------------------------------------------------------------------------------------------------------------------
                if p ~= -1 then
                    ICH[i]:update(mode);
					if 			instance.parameters.Prev 																					then
								p = p - 1;
					end
				--------------------------------------------------------------------------------------------------------------------------------
                    if 			ICH[i].TL:hasData(p)  					and 			ICH[i].TL:hasData(p-Z)								then
						local 		hK 		= 		math.max(SA[i][p],SB[i][p]);
                        local 		lK 		= 		math.min(SA[i][p],SB[i][p]);
					----------------------------------------------------------------------------------------------------------------------------
				-- PA Signal    Price against the Cloud
					----------------------------------------------------------------------------------------------------------------------------
                        if 			stream[i].close[p] 	> 	hK 																				then
									drwText(sUP,	30+i,Shift,StrongBull,sW);																	-- Strong Bullish
                        elseif 		stream[i].close[p] 	< 	lK 																				then
									drwText(sDN,	30+i,Shift,StrongBear,sW);																	-- Strong Bearish
                        else
									drwText(flat,	30+i,Shift,Weak,sW);																			-- PA inside Cloud
                        end
					----------------------------------------------------------------------------------------------------------------------------
				--PKS Signal 	Price against Kijun
					----------------------------------------------------------------------------------------------------------------------------
                        if          stream[i].open[p]	>	TL[i][p] 																		then	-- Bullish
							--------------------------------------------------------------------------------------------------------------------
                            if      TL[i][p] 			> 	hK 																				then 
									drwText(sUP,	40+i,Shift,StrongBull,sW);																	-- Strong Bullish
                            elseif  TL[i][p] 			< 	lK 																				then 	
									drwText(flat,	40+i,Shift,Weak,sW);																			-- Weak Bullish
                            else 
									drwText(aUP,	40+i,Shift,Bull,sW);																			-- Avarages Bullish
                            end
							--------------------------------------------------------------------------------------------------------------------
                        elseif  	stream[i].open[p]	<	TL[i][p] 																		then	-- Bearish
							--------------------------------------------------------------------------------------------------------------------
                            if      TL[i][p] 			< 	lK 																				then 
									drwText(sDN,	40+i,Shift,StrongBear,sW);																	-- Strong Bearish
                            elseif  TL[i][p] 			> 	hK 																				then 	
									drwText(flat,	40+i,Shift,Weak,sW);																			-- Weak Bearish
                            else 
									drwText(aDN,	40+i,Shift,Bear,sW);																			-- Avarages Bearish
                            end
							--------------------------------------------------------------------------------------------------------------------
                        end
					----------------------------------------------------------------------------------------------------------------------------
				--TSKS Signal 		TenkanSen against KijunSen allways check positions of SL and TL to the Cloud
					----------------------------------------------------------------------------------------------------------------------------
                        if          SL[i][p] 			> 	TL[i][p]                                                                        then 	-- Bullish
							--------------------------------------------------------------------------------------------------------------------
                            if      SL[i][p] > hK       and     TL[i][p] > hK                                                               then
                                    drwText(sUP,	50+i,Shift,StrongBull,sW); 																	-- Strong Bullish
                            elseif                                                          SL[i][p] < lK       and     TL[i][p] < lK       then
                                    drwText(flat,	50+i,Shift,Weak,sW); 																			-- Weak Bullish
							elseif  SL[i][p] > hK       and     TL[i][p] < hK        														then
                                    drwText(aUP,	50+i,Shift,Bull,sW); 																			-- Average Bullish
							else
									drwText(aUP,	50+i,Shift,Weak,sW); 																			-- Average Bullish
                            end
							--------------------------------------------------------------------------------------------------------------------
                        elseif  	SL[i][p] 			< 	TL[i][p] 																		then 	-- Bearish
							--------------------------------------------------------------------------------------------------------------------
                            if                                                            	SL[i][p] < lK       and     TL[i][p] < lK       then
                                    drwText(sDN,	50+i,Shift,StrongBear,sW); 																	-- Strong Bearish    
                            elseif  SL[i][p] > hK       and     TL[i][p] > hK 																then
                                    drwText(flat,	50+i,Shift,Weak,sW); 																			-- Weak Bearish
                            elseif  														SL[i][p] < lK       and     TL[i][p] > lK       then
                                    drwText(aDN,	50+i,Shift,Bear,sW); 																			-- Average Bearish
                            else
									drwText(aDN,	50+i,Shift,Weak,sW); 																			-- Average Bearish
                            end
							--------------------------------------------------------------------------------------------------------------------
                        elseif  	SL[i][p] 		== 	TL[i][p] then 																				-- Not Clear
							--------------------------------------------------------------------------------------------------------------------
                            if      SL[i][p] > hK                                                                      						then
                                    drwText(sUP,	50+i,Shift,StrongBull,sW); 																	-- Strong Bullish
                            elseif  SL[i][p] < lK																							then
                                    drwText(sDN,	50+i,Shift,StrongBear,sW); 																	-- Strong Bearish
                            else
                                    drwText(flat,	50+i,Shift,Weak,sW); 																			-- Weak no direction
                            end
							--------------------------------------------------------------------------------------------------------------------
                        end
					----------------------------------------------------------------------------------------------------------------------------
				-- CS Signal		Chikou Span Position   take advantage to the Cloud
					----------------------------------------------------------------------------------------------------------------------------
						local 		chK 		= 		math.max(SA[i][p-Y],SB[i][p-Y]);
                        local 		clK 		= 		math.min(SA[i][p-Y],SB[i][p-Y]);
                        if 			stream[i].close[p] > stream[i].close[p-Y] 																then	-- Bullish
							--------------------------------------------------------------------------------------------------------------------
							if 		stream[i].close[p] > chK																				then
									drwText(sUP,	60+i,Shift,StrongBull,sW);																	-- Strong Bullish
							elseif  stream[i].close[p] < clK																				then
									drwText(flat,	60+i,Shift,Weak,sW);																			-- Weak Bullish
							else
									drwText(aUP,	60+i,Shift,Bull,sW);																			-- Average Bullish
							end
							--------------------------------------------------------------------------------------------------------------------
                        elseif 		stream[i].close[p] < stream[i].close[p-Y] 																then	-- Bearish
							--------------------------------------------------------------------------------------------------------------------
							if 		stream[i].close[p] < clK																				then
									drwText(sDN,	60+i,Shift,StrongBear,sW);  																	-- Strong Bearish
							elseif  stream[i].close[p] > chK																				then
									drwText(flat,	60+i,Shift,Weak,sW);  																		-- Weak Bearish
							else
									drwText(aDN,	60+i,Shift,Bear,sW);  																		-- Average Bearish
							end
							--------------------------------------------------------------------------------------------------------------------
                        end
					----------------------------------------------------------------------------------------------------------------------------
				-- CK Signal		Chikou Span against KijunSen
					----------------------------------------------------------------------------------------------------------------------------
                        if 			stream[i].close[p] > TL[i][p-Y] 																		then
									drwText(sUP,	70+i,Shift,StrongBull,sW);																	-- Strong Bullish
                        elseif 		stream[i].close[p] < TL[i][p-Y] 																		then
									drwText(sDN,	70+i,Shift,StrongBear,sW);																	-- Strong Bearish
						else
									drwText(flat,	70+i,Shift,Weak,sW);																			-- Wait for Signal
                        end
					----------------------------------------------------------------------------------------------------------------------------
				-- CC Signal		Chikou Span against Kumo
					----------------------------------------------------------------------------------------------------------------------------
                        if 			stream[i].close[p] > chK 																				then
									drwText(sUP,	80+i,Shift,StrongBull,sW);																	-- Strong Bullish
                        elseif 		stream[i].close[p] < clK 																				then
									drwText(sDN,	80+i,Shift,StrongBear,sW);																	-- Strong Bearish
                        else
									drwText(flat,	80+i,Shift,Weak,sW);																			-- Weak inside Kumo
                        end
					----------------------------------------------------------------------------------------------------------------------------
                    end
                --------------------------------------------------------------------------------------------------------------------------------
				end
            ------------------------------------------------------------------------------------------------------------------------------------  
            end
        ----------------------------------------------------------------------------------------------------------------------------------------
		end
		-- End Signal Part
		----------------------------------------------------------------------------------------------------------------------------------------
end
------------------------------------------------------------------------------------------------------------------------------------------------

function XC () 

  if instance.parameters.Pos == "BottomRight" then
  return core.CR_RIGHT;
  elseif instance.parameters.Pos == "BottomLeft" then
   return core.CR_LEFT;
  elseif instance.parameters.Pos == "TopRight" then
   return core.CR_RIGHT;
  elseif instance.parameters.Pos == "TopLeft" then
   return core.CR_LEFT;
   end
end

function YC () 

  if instance.parameters.Pos == "BottomRight" then
  return core.CR_BOTTOM;
  elseif instance.parameters.Pos == "BottomLeft" then
   return core.CR_BOTTOM;
  elseif instance.parameters.Pos == "TopRight" then
   return core.CR_TOP;
  elseif instance.parameters.Pos == "TopLeft" then
   return core.CR_TOP;
   end
end


function drwText(text,ID,y,color,f)

 
   if   ID > 1000 then
   return;
   end
   
   
	if ID == 500 then
		-- Legend
		core.host:execute("drawLabel1", ID, -10, core.CR_CENTER, y, core.CR_CENTER, core.H_Center, core.V_Center,
									 f, color, text);
	elseif ID > 500  then
		core.host:execute("drawLabel1", ID, -150, core.CR_CENTER, y, core.CR_CENTER, core.H_Right, core.V_Center,
									 f, color, text);
		-- Legend
	else
	
	     
			 
	
		  if instance.parameters.Pos == "BottomRight" then
			if ID >= 30 and ID < 40 then
				core.host:execute("drawLabel1", ID, -210, core.CR_RIGHT, y, core.CR_BOTTOM, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 40 and ID < 50 then
				core.host:execute("drawLabel1", ID, -175, core.CR_RIGHT, y, core.CR_BOTTOM, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 50 and ID < 60 then
				core.host:execute("drawLabel1", ID, -140, core.CR_RIGHT, y, core.CR_BOTTOM, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 60 and ID < 70 then
				core.host:execute("drawLabel1", ID, -105, core.CR_RIGHT, y, core.CR_BOTTOM, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 70 and ID < 80 then
				core.host:execute("drawLabel1", ID, -70, core.CR_RIGHT, y, core.CR_BOTTOM, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 80 and ID < 90 then
				core.host:execute("drawLabel1", ID, -35, core.CR_RIGHT, y, core.CR_BOTTOM, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID == 200 then --Background
				core.host:execute("drawLabel1", ID, -0, core.CR_RIGHT, y, core.CR_BOTTOM, core.H_Left, core.V_Top,
									 f, color, text);
			else
				core.host:execute("drawLabel1", ID, -250, core.CR_RIGHT, y, core.CR_BOTTOM, core.H_Right, core.V_Top,
									 f, color, text);
			end
		end
			if instance.parameters.Pos == "BottomLeft" then
			if ID >= 30 and ID < 40 then
				core.host:execute("drawLabel1", ID, 50, core.CR_LEFT, y, core.CR_BOTTOM, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 40 and ID < 50 then
				core.host:execute("drawLabel1", ID, 85, core.CR_LEFT, y, core.CR_BOTTOM, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 50 and ID < 60 then
				core.host:execute("drawLabel1", ID, 120, core.CR_LEFT, y, core.CR_BOTTOM, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 60 and ID < 70 then
				core.host:execute("drawLabel1", ID, 155, core.CR_LEFT, y, core.CR_BOTTOM, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 70 and ID < 80 then
				core.host:execute("drawLabel1", ID, 190, core.CR_LEFT, y, core.CR_BOTTOM, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 80 and ID < 90 then
				core.host:execute("drawLabel1", ID, 225, core.CR_LEFT, y, core.CR_BOTTOM, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 200 then --Background
				core.host:execute("drawLabel1", ID, 300, core.CR_LEFT, y, core.CR_BOTTOM, core.H_Left, core.V_Center,
									 f, color, text);
			else
				core.host:execute("drawLabel1", ID, 10, core.CR_LEFT, y, core.CR_BOTTOM, core.H_Right, core.V_Top,
									 f, color, text);
			end
		end
		
		if instance.parameters.Pos == "TopRight" then
			if ID >= 30 and ID < 40 then
				core.host:execute("drawLabel1", ID, -210, core.CR_RIGHT, (225-(15*(8-count))) -math.abs(y), core.CR_TOP, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 40 and ID < 50 then
				core.host:execute("drawLabel1", ID, -175, core.CR_RIGHT, (225-(15*(8-count))) -math.abs(y), core.CR_TOP, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 50 and ID < 60 then
				core.host:execute("drawLabel1", ID, -140, core.CR_RIGHT, (225-(15*(8-count))) -math.abs(y), core.CR_TOP, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 60 and ID < 70 then
				core.host:execute("drawLabel1", ID, -105, core.CR_RIGHT, (225-(15*(8-count))) -math.abs(y), core.CR_TOP, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 70 and ID < 80 then
				core.host:execute("drawLabel1", ID, -70, core.CR_RIGHT,  (225-(15*(8-count))) -math.abs(y), core.CR_TOP, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 80 and ID < 90 then
				core.host:execute("drawLabel1", ID, -35, core.CR_RIGHT,  (225-(15*(8-count))) -math.abs(y), core.CR_TOP, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 200 then 
				core.host:execute("drawLabel1", ID, -300, core.CR_RIGHT,  math.abs(y)+15, core.CR_TOP, core.H_Right, core.V_Center,
									 f, color, text);
			else
				if math.abs(y) > 195 then
					core.host:execute("drawLabel1", ID, -250, core.CR_RIGHT, 215 + 300+y, core.CR_TOP, core.H_Right, core.V_Top,
										 f, color, text);
				else
					core.host:execute("drawLabel1", ID, -250, core.CR_RIGHT, (225-(15*(8-count))) -math.abs(y), core.CR_TOP, core.H_Right, core.V_Top,
										 f, color, text);
				end
			end
		end
		
		if instance.parameters.Pos == "TopLeft" then
			if ID >= 30 and ID < 40 then
				core.host:execute("drawLabel1", ID, 50, core.CR_LEFT, (225-(15*(8-count))) -math.abs(y), core.CR_TOP, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 40 and ID < 50 then
				core.host:execute("drawLabel1", ID, 85, core.CR_LEFT, (225-(15*(8-count))) -math.abs(y), core.CR_TOP, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 50 and ID < 60 then
				core.host:execute("drawLabel1", ID, 120, core.CR_LEFT, (225-(15*(8-count))) -math.abs(y), core.CR_TOP, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 60 and ID < 70 then
				core.host:execute("drawLabel1", ID, 155, core.CR_LEFT, (225-(15*(8-count))) -math.abs(y), core.CR_TOP, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 70 and ID < 80 then
				core.host:execute("drawLabel1", ID, 190, core.CR_LEFT,  (225-(15*(8-count))) -math.abs(y), core.CR_TOP, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 80 and ID < 90 then
				core.host:execute("drawLabel1", ID, 225, core.CR_LEFT,  (225-(15*(8-count))) -math.abs(y), core.CR_TOP, core.H_Right, core.V_Top,
									 f, color, text);
			elseif ID >= 200 then 
				core.host:execute("drawLabel1", ID, 300, core.CR_LEFT,  math.abs(y)+25, core.CR_TOP, core.H_Left, core.V_Center,
									 f, color, text);
			else
				if math.abs(y) > 195 then
					core.host:execute("drawLabel1", ID, 10, core.CR_LEFT, 225 + 300+y, core.CR_TOP, core.H_Right, core.V_Top,
										 f, color, text);
				else
					core.host:execute("drawLabel1", ID, 10, core.CR_LEFT, (225-(15*(8-count))) -math.abs(y), core.CR_TOP, core.H_Right, core.V_Top,
										 f, color, text);
				end
			end
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------
local streams = {}

function getPriceStream(stream, i)
    local s = instance.parameters:getString ("S"..i);
    if s == "open" then
        return stream.open;
    elseif s == "high" then
        return stream.high;
    elseif s == "low" then
        return stream.low;
    elseif s == "close" then
        return stream.close;
    elseif s == "median" then
        return stream.median;
    elseif s == "typical" then
        return stream.typical;
    elseif s == "weighted" then
        return stream.weighted;
    else
        return source.close;
    end
end

-- register stream
-- @param barSize       Stream's bar size
-- @param extent        The size of the required exten
-- @return the stream reference
function registerStream(id, barSize, extent)
    local stream = {};
    local s1, e1, length;
    local from, to;

    s1, e1 = core.getcandle(barSize, core.now(), 0, 0);
    length = math.floor((e1 - s1) * 86400 + 0.5);

    -- the size of the source
    if barSize == source:barSize() then
        stream.data = source;
        stream.barSize = barSize;
        stream.external = false;
        stream.length = length;
        stream.loading = false;
        stream.extent = extent;
        stream.loading = false;
    else
        stream.data = nil;
        stream.barSize = barSize;
        stream.external = true;
        stream.length = length;
        stream.loading = false;
        stream.extent = extent;
        local from, dataFrom
        from, dataFrom = getFrom(barSize, length, extent);
        if (source:isAlive()) then
            to = 0;
        else
            t, to = core.getcandle(barSize, source:date(source:size() - 1), day_offset, week_offset);
        end
        stream.loading = true;
        stream.loadingFrom = from;
        stream.dataFrom = dataFrom;
        stream.data = host:execute("getHistory", id, source:instrument(), barSize, from, to, source:isBid());
        setBookmark(0);
    end
    streams[id] = stream;
    return stream.data;
end

function getPeriod(id, period)
    local stream = streams[id];
    assert(stream ~= nil, "Stream is not registered");
    local candle, from, dataFrom, to;
    if stream.external then
        candle = core.getcandle(stream.barSize, source:date(period), day_offset, week_offset);
        if candle < stream.dataFrom then
            setBookmark(period);
            if stream.loading then
                return -1, true;
            end
            from, dataFrom = getFrom(stream.barSize, stream.length, stream.extent);
            stream.loading = true;
            stream.loadingFrom = from;
            stream.dataFrom = dataFrom;
            host:execute("extendHistory", id, stream.data, from, stream.data:date(0));
            return -1, true;
        end

        if (not(source:isAlive()) and candle > stream.data:date(stream.data:size() - 1)) then
            setBookmark(period);
            if stream.loading then
                return -1, true;
            end
            stream.loading = true;
            from = bf_data:date(bf_data:size() - 1);
            to = candle;
            host:execute("extendHistory", id, stream.data, from, to);
        end

        local p;
        p = findDateFast(stream.data, candle, true);
        return p, stream.loading;
    else
        return period;
    end
end

function setBookmark(period)
    local bm;
    bm = dummy:getBookmark(1);
    if bm < 0 then
        bm = period;
    else
        bm = math.min(period, bm);
    end
    dummy:setBookmark(1, bm);

end

-- get the from date for the stream using bar size and extent and taking the non-trading periods
-- into account
function getFrom(barSize, length, extent)
    local from, loadFrom;
    local nontrading, nontradingend;

    from = core.getcandle(barSize, source:date(source:first()), day_offset, week_offset);
    loadFrom = math.floor(from * 86400 - 2 * length * extent + 0.5) / 86400;
    nontrading, nontradingend = core.isnontrading(from, day_offset);
    if nontrading then
        -- if it is non-trading, shift for two days to skip the non-trading periods
        loadFrom = math.floor((loadFrom - 2) * 86400 - 2 * length * extent + 0.5) / 86400;
    end
    return loadFrom, from;
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;
    local stream = streams[cookie];
    if stream == nil then
        return ;
    end
    stream.loading = false;
    period = dummy:getBookmark(1);
    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end

-- find the date in the stream using binary search algo.
function findDateFast(stream, date, precise)
    local datesec = nil;
    local periodsec = nil;
    local min, max, mid;

    datesec = math.floor(date * 86400 + 0.5)

    min = 0;
    max = stream:size() - 1;

    if max < 1 then
        return -1;
    end

    while true do
        mid = math.floor((min + max) / 2);
        periodsec = math.floor(stream:date(mid) * 86400 + 0.5);
        if datesec == periodsec then
            return mid;
        elseif datesec > periodsec then
            min = mid + 1;
        else
            max = mid - 1;
        end
        if min > max then
            if precise then
                return -1;
            else
                return min - 1;
            end
        end
    end
end




