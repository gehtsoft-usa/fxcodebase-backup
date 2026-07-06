
local IndicatorName = "CoG indicator (from Belkhayate)";

function Init()
    indicator:name(IndicatorName);
    indicator:description(IndicatorName);
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup(">> " .. IndicatorName  .. " <<");
    ----------------------------------------------------------------------------------------------------
    indicator.parameters:addGroup("BelCoG Parameters");
    indicator.parameters:addInteger("NCoG", "    Number of bars", "", 240, 2, 960);
    indicator.parameters:addInteger("OCoG", "    Order", "", 3, 1, 100);
    indicator.parameters:addDouble("ECoG", "    Ecart value", "", 1.61803399);
    indicator.parameters:addBoolean("eShowCoGLevel", "Show BelCoG Levels", "Show BelCoG Levels", true);
    indicator.parameters:addString("ModeCoG", "Select Dynamic or Static indicator", "Dynamic or Static", "Dynamic");
    indicator.parameters:addStringAlternative("ModeCoG", "Dynamic", "", "Dynamic");
    indicator.parameters:addStringAlternative("ModeCoG", "Static", "", "Static");
	indicator.parameters:addBoolean("eShowCoGSlope", "    Show BelCoG Static Slope", "Show BelCoG Static Slope", false);
        ----------------------------------------------------------------------------------------------------
    indicator.parameters:addGroup("Miscellaneous Parameters");
    --
    indicator.parameters:addString("UseOf", "Use of indicator", "", "Indicator");
    indicator.parameters:addStringAlternative("UseOf", "Indicator (N-1) for closed Bar", "", "Indicator");
    indicator.parameters:addStringAlternative("UseOf", "Indicator (N) for live bar", "", "Live Bar");
    --
    indicator.parameters:addString("CalcNumber", "For Live Bar, calculate", "", "OneTime");
    indicator.parameters:addStringAlternative("CalcNumber", "one Time per Bar", "", "OneTime");
    indicator.parameters:addStringAlternative("CalcNumber", "at each Tick", "", "EachTick");
	
    ----------------------------------------------------------------------------------------------------
    indicator.parameters:addGroup("Interface Parameters");
	--
    indicator.parameters:addInteger("CoGStyleLine", "BelCoG Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("CoGStyleLine", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("CoGWidthLine", "BelCoG Line size", "", 1, 1, 20);
	indicator.parameters:addColor("L1_color", "     Color of L1", "", core.rgb(0, 255, 255));
	indicator.parameters:addColor("L2_color", "     Color of L2", "", core.rgb(127, 127, 127));
	indicator.parameters:addColor("L3_color", "     Color of L3", "", core.rgb(255, 128, 128));
	indicator.parameters:addColor("L4_color", "     Color of L4", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("L5_color", "     Color of L5", "", core.rgb(127, 127, 127));
	indicator.parameters:addColor("L6_color", "     Color of L6", "", core.rgb(128, 255, 128));
	indicator.parameters:addColor("L7_color", "     Color of L7", "", core.rgb(0, 192, 0));
	indicator.parameters:addColor("SlopeUP_color", "     Color of Slope UP", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("SlopeDN_color", "     Color of Slope DN", "", core.rgb(255, 0, 0));
    ----------------------------------------------------------------------------------------------------

end

---------------------------------------------------------------------------------------------

local first;
local source=nil;
local name;
local prevCandle=nil;

local UseOf=0;
local iINFO="";
local MinPeriod=0;

-- BelCoG parameters / variables
local L1 = nil;
local L1Value = nil;
local L2Value = nil;
local L3Value = nil;
local L4Value = nil;
local L5Value = nil;
local L6Value = nil;
local L7Value = nil;

---------------------------------------------------------------------------------------------
--------- Perpare() -------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

function Prepare(onlyName)

    source = instance.source;
    first = source:first();

    if instance.parameters.UseOf == "Indicator" then UseOf = 0; else UseOf = 1; end

	----------------------
    -- Calcul MinPeriod --
	----------------------
	
	MinPeriod = 0;
	
	MinPeriod = math.max(MinPeriod, instance.parameters.NCoG);

	-----------------------------------------------------
    -- Sélection de l'affichage des paramètres choisis --
	-----------------------------------------------------
	
	iINFO = "BelCoG=" .. instance.parameters.NCoG .. ":" .. instance.parameters.OCoG;
	
	--------------------------------------------------
    -- Affichage paramètres choisis de l'indicateur --
	--------------------------------------------------

    name = profile:id() .. "( " .. source:name() .. "." .. source:barSize() .. ">" .. iINFO .. ")";
    instance:name(name);

    if onlyName then
        return;
    end

	-----------------------------------------
    -- Choix des flux affichés ou internes --
	-----------------------------------------

    L1 = instance:addInternalStream(first, 0);
	L1Value = instance:addStream("L1", core.Line, name .. ".L1", "L1", instance.parameters.L1_color, first);
	L1Value:setStyle(instance.parameters.CoGStyleLine);
	L1Value:setWidth(instance.parameters.CoGWidthLine);

    if instance.parameters.eShowCoGLevel == true then
         L2Value = instance:addStream("L2", core.Line, name .. ".L2", "L2", instance.parameters.L2_color, first);
         L3Value = instance:addStream("L3", core.Line, name .. ".L3", "L3", instance.parameters.L3_color, first);
         L4Value = instance:addStream("L4", core.Line, name .. ".L4", "L4", instance.parameters.L4_color, first);
         L5Value = instance:addStream("L5", core.Line, name .. ".L5", "L5", instance.parameters.L5_color, first);
         L6Value = instance:addStream("L6", core.Line, name .. ".L6", "L6", instance.parameters.L6_color, first);
         L7Value = instance:addStream("L7", core.Line, name .. ".L7", "L7", instance.parameters.L7_color, first);
    else
         L2Value = instance:addInternalStream(first, 0);
         L3Value = instance:addInternalStream(first, 0);
         L4Value = instance:addInternalStream(first, 0);
         L5Value = instance:addInternalStream(first, 0);
         L6Value = instance:addInternalStream(first, 0);
         L7Value = instance:addInternalStream(first, 0);
    end

end
-- End of Prepare()

---------------------------------------------------------------------------------------------
--------- Update() --------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

function Update(period, mode)

 ----------------------------------------------------------------------
 -- One calculation at each Bar beginning (1st Tick)
 ----------------------------------------------------------------------

 if UseOf == 1 or (UseOf == 0 and instance.parameters.CalcNumber == "OneTime") then
      if prevCandle ~= nil and source:serial(period) == prevCandle then
           return;
      else
           prevCandle = source:serial(period);
      end
 end

 -------------------
 -- Enough bars ? --
 -------------------
 if period-1+UseOf > first+MinPeriod then

	CalcCog(period-1+UseOf);
	
--	if instance.parameters.UseOf == "Indicator" then
--		L1Value[period] = L1Value[period-1];
--		if instance.parameters.eShowCoGLevel == true then
--			L2Value[period] = L2Value[period-1];
--			L3Value[period] = L3Value[period-1];
--			L4Value[period] = L4Value[period-1];
--			L5Value[period] = L5Value[period-1];
--			L6Value[period] = L6Value[period-1];
--			L7Value[period] = L7Value[period-1];
--		end
--	end

 end
 ------------------------
 -- End of enough bars --
 ------------------------
 
end
-- end of Update()


---------------------------------------------------------------------------------------------
--------- CalcCoG() -------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

function CalcCog (period)

        local s, i, j, k, a1, a2, a3, a4, v1, v2, si, t;

        s = instance.parameters.OCoG + 1;

        -- init arrays
        a1 = {};
        for i = 0, s, 1 do
            a1[i] = {};
        end
        a2 = {};
        a3 = {};
        a4 = {};

        a2[1] = instance.parameters.NCoG + 1;
        for i = 1, (s - 1) * 2, 1 do
            v1 = 0;
            for j = 0, instance.parameters.NCoG, 1 do
                v1 = v1 + (math.pow(j, i));
            end
            a2[i + 1] = v1;
        end

        for j = 1, s, 1 do
            v1 = 0;
            for i = 0, instance.parameters.NCoG, 1 do
                if j == 1 then
                    v1 = v1 + (source.high[period - i] + source.low[period - i]) / 2;
                else
                    v1 = v1 + (source.high[period - i] + source.low[period - i]) / 2 * (math.pow(i, j - 1));
                end
            end
            a3[j] = v1;
        end

        for j = 1, s, 1 do
            for i = 1, s, 1 do
                a1[i][j] = a2[i + j - 1];
            end
        end

        for i = 1, s - 1, 1 do
            si = 0;
            v1 = 0;
            for j = i, s, 1 do
                if math.abs(a1[j][i]) > v1 then
                    v1 = math.abs(a1[j][i]);
                    si = j;
                end
            end
            if si == 0 then
                return ;
            end

            if si ~= i then
                for j = 1, s, 1 do
                    t = a1[i][j];
                    a1[i][j] = a1[si][j];
                    a1[si][j] = t;
                end
                t = a3[i];
                a3[i] = a3[si];
                a3[si] = t;
            end

            for j = i + 1, s, 1 do
                v1 = a1[j][i] / a1[i][i];
                for k = 1, s, 1 do
                    if k == i then
                        a1[j][k] = 0;
                    else
                        a1[j][k] = a1[j][k] - v1 * a1[i][k];
                    end
                end
                a3[j] = a3[j] - v1 * a3[i];
            end
        end

        a4[s] = a3[s] / a1[s][s];

        for i = s - 1, 1, -1 do
            v1 = 0;
            for j = 1, s - i, 1 do
                v1 = v1 + (a1[i][i + j]) * (a4[i + j]);
                a4[i] = 1 / a1[i][i] * (a3[i] - v1);
            end
        end

		if instance.parameters.ModeCoG == "Dynamic" then

			for i = 0, instance.parameters.NCoG, 1 do
				v1 = 0;
				for j = 1, instance.parameters.OCoG, 1 do
					v1 = v1 + (a4[j + 1]) * (math.pow(i, j));
				end
				L1Value[period - i] = a4[1] + v1;
			end
			
			if instance.parameters.eShowCoGLevel == true then
			
				v2 = core.stdev(source.high, core.rangeTo(period, instance.parameters.NCoG)) * instance.parameters.ECoG;

				for i = 0, instance.parameters.NCoG, 1 do
					L4Value[period - i] = L1Value[period - i] + v2;
					L3Value[period - i] = L1Value[period - i] + (L4Value[period - i] - L1Value[period - i]) / 1.382;
					L2Value[period - i] = L1Value[period - i] + (L3Value[period - i] - L1Value[period - i]) / 1.618;
					L7Value[period - i] = L1Value[period - i] - v2;
					L6Value[period - i] = L1Value[period - i] - (L1Value[period - i] - L7Value[period - i]) / 1.382;
					L5Value[period - i] = L1Value[period - i] - (L1Value[period - i] - L6Value[period - i]) / 1.618;
				end
				
			end
				
			for i = instance.parameters.NCoG + 1, instance.parameters.NCoG + 10, 1 do
				j = period - i;
				if j > source:first() then
					L1Value[j] = nil;
					L2Value[j] = nil;
					L3Value[j] = nil;
					L4Value[j] = nil;
					L5Value[j] = nil;
					L6Value[j] = nil;
					L7Value[j] = nil;
				end
			end

		else
		
			for i = 0, instance.parameters.NCoG, 1 do
				v1 = 0;
				for j = 1, instance.parameters.OCoG, 1 do
					v1 = v1 + (a4[j + 1]) * (math.pow(i, j));
				end
				L1[period - i] = a4[1] + v1;
			end
			
			L1Value[period] = L1[period];
			
			if instance.parameters.eShowCoGSlope == true then

				if L1[period] < L1[period-1] then
						L1Value:setColor(period, instance.parameters.SlopeDN_color);
				end
				if L1[period] > L1[period-1] then
						L1Value:setColor(period, instance.parameters.SlopeUP_color);
				end 
			
			end

			if instance.parameters.eShowCoGLevel == true then

				v2 = core.stdev(source.high, core.rangeTo(period, instance.parameters.NCoG)) * instance.parameters.ECoG;

				L4Value[period] = L1Value[period] + v2;
				L3Value[period] = L1Value[period] + (L4Value[period] - L1Value[period]) / 1.382;
				L2Value[period] = L1Value[period] + (L3Value[period] - L1Value[period]) / 1.618;
				L7Value[period] = L1Value[period] - v2;
				L6Value[period] = L1Value[period] - (L1Value[period] - L7Value[period]) / 1.382;
				L5Value[period] = L1Value[period] - (L1Value[period] - L6Value[period]) / 1.618;

			end
		
		end

end

----------------------
-- End of CalcCoG() --
----------------------

---------------------------------------------------------------------------------------------

