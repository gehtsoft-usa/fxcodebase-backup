-- Indicator distributed by IVTrading.com with alert
-- Modified by Ainelle (V2.6)
-- contact : ainelle75@yahoo.fr
-- Do not distribute without authorization from IVTrading.com

-- V2.2 : change of the default colour of histogram
-- V2.3 : add a choice to change EMA colour
-- V2.4 : add colour on MACD curve
-- V2.5 : add colour on both MACD curve
-- V2.6 : add grey on histogram when MACD curve is not accurate with histogram + alarm when crossing MM9

function Init()
    indicator:name("Zero Lag MACD V2.6");
    indicator:description("Zero Lag MACD with alert (V2.6)");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	indicator:setTag("group", "Interactiv Trading Indicators");

	indicator.parameters:addGroup("Calcul");
    indicator.parameters:addInteger("FMA", "Periode de l'EMA rapide", "", 12, 1, 1000);
    indicator.parameters:addInteger("SMA", "Periode de l'EMA lente", "", 26, 1, 1000);
    indicator.parameters:addInteger("SigMA", "Periode de l'EMA du Signal", "", 9, 1, 1000);
    indicator.parameters:addDouble("HIS_neutral", "Zone Neutre","", 1.0, 0, 100);
    
	indicator.parameters:addGroup("Configuration");
	indicator.parameters:addBoolean("ShowEMA", "Afficher une EMA du MACD ?", "", true);
	indicator.parameters:addInteger("P_EMA", "Periode de cette EMA", "", 9, 1, 1000);
	indicator.parameters:addBoolean("HISTOFILTRE", "Filtrer l'histogramme ?", "Grise l'histogramme si sa couleur ne correspond pas à la couleur de la courbe MACD", true);

	indicator.parameters:addGroup("Couleurs");
    indicator.parameters:addColor("SIG_color", "Couleur de la ligne du Signal", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("HIS_col_pos", "Couleur de l'Histogramme PositiF", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("HIS_col_neg", "Couleur de l'Histogramme Negatif", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("HIS_col_neutral", "Couleur Neutre", "", core.rgb(192, 192, 192));
	indicator.parameters:addColor("EMA_color", "Couleur de la ligne EMA", "", core.rgb(128, 128, 128));

	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
	indicator.parameters:addColor("Bull", "Couleur d'une aile positive", "", core.rgb( 0, 255, 0));
	indicator.parameters:addColor("Bear", "Colour d'une aile negative", "", core.rgb( 255, 0, 0));
	
	Parameters(1, "Croisement de l'Histogramme avec la ligne centrale", false);
	Parameters(2, "Croisement de la ligne MACD avec la MM", false);

	indicator.parameters:addGroup("Choix des alertes");  
    indicator.parameters:addString("ShowOnly", "Show", "", "Les 2");
	indicator.parameters:addStringAlternative("ShowOnly", "Les 2", "", "Both");
    indicator.parameters:addStringAlternative("ShowOnly", "Croisement Positif", "", "CrossOver");
    indicator.parameters:addStringAlternative("ShowOnly", "Croisement Negatif", "", "CrossUnder");

	indicator.parameters:addGroup("Alerts Mode");  
	indicator.parameters:addString("Mode_Alert", "Cloture de bougie / Live", "", "Live");
	indicator.parameters:addStringAlternative("Mode_Alert", "Live", "L'alerte est emise à chaque croisement instantane", "Live");
    indicator.parameters:addStringAlternative("Mode_Alert", "Cloture", "On attend la cloture de la bougie pour alerter", "Cloture");
	
    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addInteger("Size", "Taille de police", "", 10, 1, 100);

	indicator.parameters:addGroup("Alerts Son");   
    indicator.parameters:addBoolean("PlaySound", "Jouer un son ?", "", false);
    indicator.parameters:addBoolean("RecurrentSound", "Mode recurrent ?", "", false);
	
	indicator.parameters:addGroup("Alerts Message");   
    indicator.parameters:addBoolean("Show", "Afficher un Message d'alerte", "", false);

end

function Parameters(id, Label,Flag)
    indicator.parameters:addGroup(Label .. " Alert");
    indicator.parameters:addBoolean("ON" .. id, "Afficher l'alerte de " .. Label, "", Flag);

    indicator.parameters:addFile("Up" .. id, "Fichier son pour Croisement positif", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Down" .. id, "Fichier son pour Croisement negatif", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Label" .. id, "Message", "", Label);
end
local Number = 2;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local FMA;
local SMA;
local SigMA;
local P_EMA;

local FMA_I;
local SMA_I;
local FMA_I2;
local SMA_I2;
local SigMA_I;
local SigMA_I2;

local firstMACD, firstSIG;
local source = nil;

-- Streams block
local MACD = nil;
local MACD_UP = nil;
local MACD_DN = nil;
local SIG = nil;
local SIG_UP = nil;
local SIG_DN = nil;
local EMA = nil
local HIS = nil;
local neutral;
local EMA_2 = nil;

-- Alert
local FIRST={};
local Live;
local Size;
local PlaySound, RecurrentSound ,SoundFile  ;
local Crossover, Crossunder;
local Show;
local ShowOnly;
local Alert;
local Label = {};
local ON = {};
local Up = {};
local Down = {};
local U = {};
local D = {};
local up = {};
local down = {};
local last_MACD_color;

-- DEBUG
local fDebug = nil;
local filename = "Debug.txt"

-- Routine
function Prepare()
	local i;
	
    FMA = instance.parameters.FMA;
    SMA = instance.parameters.SMA;
    SigMA = instance.parameters.SigMA;
    source = instance.source;
	neutral = instance.parameters.HIS_neutral;
	
	for i=1, source:getPrecision() do
		neutral = neutral/10;
	end
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. FMA .. ", " .. SMA .. ", " .. SigMA .. ")";
    instance:name(name);

    FMA_I = core.indicators:create("EMA", source, FMA);
    SMA_I = core.indicators:create("EMA", source, SMA);
    FMA_I2 = core.indicators:create("EMA", FMA_I.DATA, FMA);
    SMA_I2 = core.indicators:create("EMA", SMA_I.DATA, SMA);
	
    firstMACD = math.max(FMA_I2.DATA:first(), SMA_I2.DATA:first());

    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.HIS_col_pos, firstMACD);

	if (instance.parameters:getBoolean("ShowEMA")) then
		P_EMA = instance.parameters.P_EMA;
		EMA_2 = instance:addStream("EMA_2", core.Line, name .. ".EMA_2", "EMA_2", instance.parameters.EMA_color, firstMACD+P_EMA);
	end

    SigMA_I = core.indicators:create("EMA", MACD, SigMA);
    SigMA_I2 = core.indicators:create("EMA", SigMA_I.DATA, SigMA);

    firstSIG = SigMA_I2.DATA:first();
    SIG = instance:addStream("SIG", core.Line, name .. ".SIG", "SIG", instance.parameters.SIG_color, firstSIG);
    HIS = instance:addStream("HISTOGRAM", core.Bar, name .. ".HIS", "HIS", instance.parameters.HIS_col_neutral, firstSIG);

    EMA = instance:addStream("EMA", core.Line, name .. ".EMA", "EMA", instance.parameters.SIG_color, firstSIG);

    MACD_UP = instance:addStream("MACD_UP", core.Line, name .. ".MACD", "MACD", instance.parameters.HIS_col_pos, firstMACD);
    MACD_DN = instance:addStream("MACD_DN", core.Line, name .. ".MACD", "MACD", instance.parameters.HIS_col_neg, firstMACD);
	
	SIG_UP = instance:addStream("SIG_UP", core.Line, name .. ".SIG", "SIG", instance.parameters.SIG_color, firstSIG);
    SIG_DN = instance:addStream("SIG_DN", core.Line, name .. ".SIG", "SIG", instance.parameters.SIG_color, firstSIG);

	instance:createChannelGroup("Gr_UP","Group" , SIG_DN, MACD_UP, instance.parameters.Bull, instance.parameters.Transparency);
	instance:createChannelGroup("Gr_DN","Group" , SIG_UP, MACD_DN, instance.parameters.Bear, instance.parameters.Transparency);

	Init_Alert();

end

function  Init_Alert()
    Size = instance.parameters.Size;
	Live = instance.parameters.Mode_Alert;
    Show = instance.parameters.Show;
	ShowOnly = instance.parameters.ShowOnly;

	local i;
    for i = 1, Number, 1 do
        Label[i] = instance.parameters:getString("Label" .. i);
        ON[i] = instance.parameters:getBoolean("ON" .. i);
    end
	
    PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        for i = 1, Number, 1 do
            Up[i] = instance.parameters:getString("Up" .. i);
            Down[i] = instance.parameters:getString("Down" .. i);
        end
    else
        for i = 1, Number, 1 do
            Up[i] = nil;
            Down[i] = nil;
        end
    end

	    for i = 1, Number, 1 do
        assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen");
        assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
    end

    RecurrentSound = instance.parameters.RecurrentSound;

    for i = 1, Number, 1 do
	    FIRST[i]=0;

        U[i] = nil;
        D[i] = nil;

        if ON[i] then
            up[i] = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.HIS_col_pos, 0);
            down[i] = instance:createTextOutput("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.HIS_col_neg, 0);
        end
    end

end	

-- Indicator calculation routine
function Update(period, mode)
	local histo, prev_histo;
	
    FMA_I:update(mode);
    FMA_I2:update(mode);
    SMA_I:update(mode);
    SMA_I2:update(mode);

    if (period >= firstMACD) then
        MACD[period] = (2 * FMA_I.DATA[period] - FMA_I2.DATA[period]) -
                       (2 * SMA_I.DATA[period] - SMA_I2.DATA[period]);
    end

	if (instance.parameters:getBoolean("ShowEMA")) then
		local precision = source:pipSize();
		local tmp, lasttmp, pente, penteabs;
		local color;

		if (period > firstMACD + P_EMA) then
			tmp = getEMA(MACD, P_EMA, period);
			lasttmp = EMA_2[period-1];

			pente = (tmp - lasttmp)/precision;
			penteabs = P_EMA*math.abs(pente);
			if (penteabs <= neutral/precision) then
				color = instance.parameters.HIS_col_neutral;
			elseif (pente > 0) then
				color = instance.parameters.HIS_col_pos;
			else
				color = instance.parameters.HIS_col_neg;
			end
			EMA_2[period] = tmp;
--			EMA_2:setColor(period,color);

		end
	end
	
    SigMA_I:update(mode);
    SigMA_I2:update(mode);

    if (period >= firstSIG) then
        SIG[period] = 2 * SigMA_I.DATA[period] - SigMA_I2.DATA[period];
		histo = MACD[period] - SIG[period];
		prev_histo = MACD[period-1] - SIG[period-1];
		if (histo  < -neutral) then
			HIS:setColor(period,instance.parameters.HIS_col_neg);
		else
			if (histo> neutral) then
				HIS:setColor(period,instance.parameters.HIS_col_pos);
			else
				HIS:setColor(period,instance.parameters.HIS_col_neutral);
			end
		end
		local pente, tmp, lasttmp;

        HIS[period] = histo;
		MACD_UP:setColor(period,last_MACD_color);
		MACD_DN:setColor(period,last_MACD_color);
		
		if (histo <= 0) then
			SIG_UP[period]=SIG[period];
			MACD_DN[period]=MACD[period];
			if (prev_histo >= 0) then
				SIG_UP[period-1]=MACD[period-1];
				MACD_DN[period-1]=MACD[period-1];

				MACD_UP[period]=MACD[period];
				SIG_DN[period]=MACD[period];
				
			end
			pente = (MACD_DN[period] - MACD_DN[period-1]);
			if (pente > 0) then
				MACD_DN:setColor(period,instance.parameters.HIS_col_pos);
				last_MACD_color = instance.parameters.HIS_col_pos;
				if (instance.parameters.HISTOFILTRE) then
					-- force neutral color on histogram, when it disagrees 'pente'
					HIS:setColor(period,instance.parameters.HIS_col_neutral);
				end
			else
				MACD_DN:setColor(period,instance.parameters.HIS_col_neg);
				last_MACD_color = instance.parameters.HIS_col_neg;
			end
		end

		if (histo >= 0) then
			MACD_UP[period]=MACD[period];
			SIG_DN[period]=SIG[period];

			if (prev_histo <= 0) then
				MACD_UP[period-1]=MACD[period-1];
				SIG_DN[period-1]=MACD[period-1];
				
				SIG_UP[period]=MACD[period];
				MACD_DN[period]=MACD[period];
			end
			pente = (MACD_UP[period] - MACD_UP[period-1]);
			if (pente > 0) then
				MACD_UP:setColor(period,instance.parameters.HIS_col_pos);
				last_MACD_color = instance.parameters.HIS_col_pos;
			else
				MACD_UP:setColor(period,instance.parameters.HIS_col_neg);
				last_MACD_color = instance.parameters.HIS_col_neg;
				if (instance.parameters.HISTOFILTRE) then
					-- force neutral color on histogram, when it disagrees 'pente'
					HIS:setColor(period,instance.parameters.HIS_col_neutral);
				end
			end
		end
		
	end
	-- Alert
	if (period > firstSIG) then
		for i = 1, Number, 1 do
			if (FIRST[i]<period) then
				FIRST[i] = period;
			end
			Activate(i, period);
		end
	end
end

function getEMA(s, n, p)
	local firstP, tmp;
	local k = 2.0 / (n + 1.0);

	firstP = math.floor(n*3);
	tmp = s[p-firstP];

	for i=(firstP-1), 0, -1 do
		tmp = (1-k)*tmp + k*s[p-i];
	end
	
	return tmp

end

function Activate(id, period)
    local Shift = 0;

    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
		for i = 1, Number, 1 do
			FIRST[i] = FIRST[i] - 1;
		end
    end

    if (id==1) and (ON[id])  then
        if ( (HIS[period]>0) 
			and (HIS[period-1]<= 0) 
			and (ShowOnly~="CrossUnder")  
		) then
            up[id]:set(period, 0, "\225");
            if ( (U[id]~=source:serial(period)) 
				and (period==(source:size()-1-Shift))
				and (FIRST[id]==period)
			) then
				U[id] = source:serial(period);
                SoundAlert(Up[id]);
                if (Show) then
                    Pop(Label[id], " Cross Over " );
                end
				FIRST[id] = FIRST[id]+1;
            end
        elseif ( (HIS[period]<0)
			and (HIS[period-1]>=0)
			and (ShowOnly~="CrossOver") )
		then
			down[id]:set(period, 0, "\226");
			if ( (D[id]~=source:serial(period))
				and (period==source:size()-1-Shift)
				and (FIRST[id]==period)
			) then
				D[id] = source:serial(period);
                SoundAlert(Down[id]);
                if (Show) then
                    Pop(Label[id], " Cross Under ");
                end
 				FIRST[id] = FIRST[id]+1;
			end
		end
    end
	if (id==2) and (ON[id])  then
		if ( (MACD[period-2]<=EMA_2[period-2])
			and (MACD[period-1]>EMA_2[period-1])
			and (MACD[period]>EMA_2[period])
			and (MACD[period]<0)
			and (ShowOnly~="CrossUnder")
			and (FIRST[id]==period)
		) then 
			up[id]:set(period, 0, "\225");
			SoundAlert(Up[id]);
            if (Show) then
				Pop(Label[id], " Cross Over " );
			end
			FIRST[id] = FIRST[id]+1;
		elseif ( (MACD[period-2]>=EMA_2[period-2])
			and (MACD[period-1]<EMA_2[period-1])
			and (MACD[period]<EMA_2[period])
			and (MACD[period]>0)
			and (ShowOnly~="CrossOver")
			and (FIRST[id]==period)
		) then 
			down[id]:set(period, 0, "\226");
			SoundAlert(Down[id]);
			if (Show) then
				Pop(Label[id], " Cross Under ");
			end
			FIRST[id] = FIRST[id]+1;
		end
	end
end

function Pop(label , note)

	core.host:execute ("prompt", 1, label ,
		" ( " .. source:instrument()  ..   label .. " : " .. note );

end

function SoundAlert(Sound)

	if not PlaySound then
		return;
	end
	
	terminal:alertSound(Sound, RecurrentSound);
end

function AsyncOperationFinished(cookie, success, message)
end
