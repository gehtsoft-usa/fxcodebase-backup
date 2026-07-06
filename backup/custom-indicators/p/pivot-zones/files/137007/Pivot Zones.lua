-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69852

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Pivot Zones");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Support/Resistance");
	
	

    indicator.parameters:addGroup("Parameters");
	
	indicator.parameters:addInteger("Delta", "Zone Delta (in Pips)", "", 11);
	 
	
	
	 local TF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1", "Chart Time Frame"}
     indicator.parameters:addString("BS", "Price Time Frame", "", TF[14]);
	for i = 1, 14, 1 do
	indicator.parameters:addStringAlternative("BS", TF[i], "",  TF[i]);
    end
	
	 

    indicator.parameters:addString("CalcMode", "Calculation Mode", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Pivot", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla");
    indicator.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci");
    indicator.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor");
    indicator.parameters:addStringAlternative("CalcMode", "FibonacciR", "", "FibonacciR");
    indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("Show", "Show Labels", "", true);
	
	
    indicator.parameters:addColor("Color1", "Pivot Line Color","", core.rgb(192, 192, 192));
    indicator.parameters:addColor("Color2","S1 Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Color3", "S2 Line Color","", core.rgb(224, 0, 0));
    indicator.parameters:addColor("Color4","S3 Line Color","", core.rgb(192, 0, 0));
    indicator.parameters:addColor("Color5", "S4 Line Color","", core.rgb(160, 0, 0));
    indicator.parameters:addColor("Color6", "R1 Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Color7", "R2 Line Color","", core.rgb(0, 224, 0));
    indicator.parameters:addColor("Color8", "R3 Line Color","", core.rgb(0, 192, 0));
    indicator.parameters:addColor("Color9", "R4 Pivot Line Line Color","", core.rgb(0, 160, 0));
	
	 indicator.parameters:addColor("LabelColor", "Label Color","", core.COLOR_LABEL );
	
	indicator.parameters:addInteger("transparency", "Transparency", "",50, 0, 100); 
	 indicator.parameters:addBoolean("Automatic", "Automatic Font Size", "", true);
	indicator.parameters:addInteger("FontSize", "Font Size", "",10, 0, 100); 
end
local FontSize , Automatic;
local P;
local H;
local L;
local D;
local source;
local ref;
local instr;
local BS;
local CurrLen;
local BSLen;
local host;
local offset;
local weekoffset;
local Show;
local LabelColor;

local RP = 1;
local S1 = 2;
local S2 = 3;
local S3 = 4;
local S4 = 5;
local R1 = 6;
local R2 = 7;
local R3 = 8;
local R4 = 9;
local PID = 10;
local name = {};
 
local stream = {};
local fibr = {};

local Color={};

local O_PIVOT = 1;
local O_CAM = 2;
local O_WOOD = 3;
local O_FIB = 4;
local O_FLOOR = 5;
local O_FIBR = 6;
local CalcMode;



local eps;
local SameSizeBar = false;
local loading = false;

local d={};
  local Delta;
function Prepare(onlyName)
    host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
   
   
    Delta = instance.parameters.Delta;
	Show= instance.parameters.Show;
	
	FontSize= instance.parameters.FontSize;
	Automatic= instance.parameters.Automatic;
	
    source = instance.source;
	
    instr = source:instrument();
    BS = instance.parameters.BS;
	
	if BS== "Chart Time Frame" then
	BS=source:barSize();
	end
	
	LabelColor= instance.parameters.LabelColor;
   
    local precision = source:getPrecision();
    if precision > 0 then
        eps = math.pow(10, -precision);
    else
        eps = 1;
    end

    name[RP] = "P";
    name[S1] = "S1";
    name[S2] = "S2";
    name[S3] = "S3";
    name[S4] = "S4";
    name[R1] = "R1";
    name[R2] = "R2";
    name[R3] = "R3";
    name[R4] = "R4";


    fibr[S4] = -0.272;
    fibr[S3] = 0;
    fibr[S2] = 0.236;
    fibr[S1] = 0.382;
    fibr[R1] = 0.618;
    fibr[R2] = 0.764;
    fibr[R3] = 1;
    fibr[R4] = 1.272;

    -- validate
    local l1, l2;
    local s, e;

    s, e = core.getcandle(source:barSize(), core.now(), 0);
    l1 = e - s;
    s, e = core.getcandle(BS, core.now(), 0);
    l2 = e - s;
    BSLen = l2; -- remember length of the period
    CurrLen = l1;

    if source:barSize() == BS then
        SameSizeBar = true;
    end

 

    if instance.parameters.CalcMode == "Pivot" then
        CalcMode = O_PIVOT;
    elseif instance.parameters.CalcMode == "Camarilla" then
        CalcMode = O_CAM;
    elseif instance.parameters.CalcMode == "Woodie" then
        CalcMode = O_WOOD;
    elseif instance.parameters.CalcMode == "Fibonacci" then
        CalcMode = O_FIB;
    elseif instance.parameters.CalcMode == "Floor" then
        CalcMode = O_FLOOR;
    elseif instance.parameters.CalcMode == "FibonacciR" then
        CalcMode = O_FIBR;
        if ShowMode == O_TODAY then
            name[S1] = tostring(fibr[S1]);
            name[S2] = tostring(fibr[S2]);
            name[S3] = tostring(fibr[S3]);
            name[S4] = tostring(fibr[S4]);
            name[R1] = tostring(fibr[R1]);
            name[R2] = tostring(fibr[R2]);
            name[R3] = tostring(fibr[R3]);
            name[R4] = tostring(fibr[R4]);
            name[RP] = "0.5";
        end
   
    end


    
   Color[1]=instance.parameters.Color1;
   Color[2]=instance.parameters.Color2;
   Color[3]=instance.parameters.Color3;
   Color[4]=instance.parameters.Color4;
   Color[5]=instance.parameters.Color5;
   Color[6]=instance.parameters.Color6;
   Color[7]=instance.parameters.Color7;
   Color[8]=instance.parameters.Color8;
   Color[9]=instance.parameters.Color9;
   

    -- create streams
    local sname;
    sname = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.CalcMode .. ")";
    instance:name(sname);

    if onlyName then
        assert(l1 <= l2, "Chosen base period for the pivot calculation must be equal to or longer than the chart period.");
        assert(BS ~= "t1", "Chosen base period for the pivot calculation must not be a tick period");
        return;
    end

    -- pivot
    
     
     
    P = instance:addInternalStream(0, 0);
    
    -- range
    H = instance:addInternalStream(0, 0);
    L = instance:addInternalStream(0, 0);
    
     
	 
    ref = core.host:execute("getSyncHistory", source:instrument(), BS, source:isBid(), 10, 100, 101);
   

    loading = true;
	
	instance:ownerDrawn(true);
end


local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	
	
	local  Transparency = context:convertTransparency (instance.parameters.transparency);
	 
	 for i =1, 9 ,1 do 
	 context:createSolidBrush(i, Color[i]);      
      end  

		
	for i =1, 9 ,1 do 
	    AddZone(i,  context, Transparency);
	end

end


function  AddZone(i,  context, Transparency  )
    
   
    if d[i]== nil then
	return;
	end
	
	local style = context.SINGLELINE + context.CENTER + context.VCENTER;
   
     visible, Y1 = context:pointOfPrice (d[i]+Delta*source:pipSize());
	 visible, Y2 = context:pointOfPrice (d[i]-Delta*source:pipSize());
     context:drawRectangle (-1, i, context:left(), Y1, context:right(),Y2, Transparency );	
        
	if Show then	 
	
 
	 if Automatic then
    context:createFont(10, "Arial", Y2-Y1, Y2-Y1, context.NORMAL);
	else
	 context:createFont(10, "Arial", context:pointsToPixels (FontSize), context:pointsToPixels (FontSize), context.NORMAL);
	end
	 width, height = context:measureText (10,  name[i] , style)	 
	context:drawText(10,  name[i] , LabelColor, -1, context:right() - width, Y1,context:right(),Y2, style);
    end   
end


local pday = nil;
 
local canWork = nil;
 
function Update(period, mode)
    if canWork == nil then
        if CurrLen > BSLen then
            core.host:execute("setStatus","Chosen base period for the pivot calculation must be equal to or longer than the chart period.");
            canWork = false;
            return ;
        elseif BS == "t1" then
            core.host:execute("setStatus", "Chosen base period for the pivot calculation must not be a tick period");
            canWork = false;
            return ;
        else
            canWork = true;
        end
    elseif not(canWork) then
        return ;
    end

    -- get the previous's candle and load the ref data in case ref data does not exist
    local candle;
    candle = core.getcandle(BS, source:date(period), offset, weekoffset);

    -- if data for the specific candle are still loading
    -- then do nothing
    if loading then
        return ;
    end

    if ref:size() == 0 then
        return;
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (candle < ref:date(0)) then
        return ;
    end

    -- find the lastest completed period which is not saturday's period (to avoid
    -- collecting the saturday's data
    local prev_i = nil;
    local start;

    if (pday == nil) then
        start = 0;
    elseif ref:date(pday) >= candle then
        start = 0;
    else
        start = pday;
    end

    for i = start, ref:size() - 1, 1 do
        local td;
        -- skip nontrading candles
        if BSLen > 1 or not(core.isnontrading(ref:date(i), offset)) then
            if (ref:date(i) >= candle) then
                break;
            else
                prev_i = i;
            end
        end
    end

    if (prev_i == nil) then
        -- assert(false, "prev_i is nil");
        return ;
    end

    pday = prev_i;
    if CalcMode == O_PIVOT or CalcMode == O_FIB or CalcMode == O_FLOOR then
        P[period] = (ref.high[prev_i] + ref.close[prev_i] + ref.low[prev_i]) / 3;
    elseif CalcMode == O_CAM then
        -- P[period] = (ref.high[prev_i] + ref.close[prev_i] + ref.low[prev_i]) / 3;
        P[period] = ref.close[prev_i];
    elseif CalcMode == O_FIBR then
        P[period] = (ref.high[prev_i] + ref.low[prev_i]) / 2;
    elseif CalcMode == O_WOOD then
        local open;
        if (prev_i == ref:size() - 1) then
            -- for a live day take close as open of the next period
            open = ref.open[prev_i];
        else
            open = ref.open[prev_i + 1];
        end
        P[period] = (ref.high[prev_i] + ref.low[prev_i] + open * 2 ) / 4;
    end
    H[period] = ref.high[prev_i];
    L[period] = ref.low[prev_i];


    CalculateLevels(period);
	

 
  
end

function initCalculateLevel(period)

    local h, l, p, r;

    p = P[period];
    h = H[period];
    l = L[period];
    r = h - l;
    return h, l, p, r;
end

 


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        pday = nil;
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


function CalculateLevels(period)
    
    local h, l, p, r = initCalculateLevel(period);

    if CalcMode == O_PIVOT then
        d[R4] = p + r * 3;
        d[R3] = p + r * 2;
        d[R2] = p + r;
        d[R1] = p * 2 - l;

        d[S1] = p * 2 - h;
        d[S2] = p - r;
        d[S3] = p - r * 2;
        d[S4] = p - r * 3;
    elseif CalcMode == O_CAM then
        d[R4] = p + r * 1.1 / 2;
        d[R3] = p + r * 1.1 / 4;
        d[R2] = p + r * 1.1 / 6;
        d[R1] = p + r * 1.1 / 12;

        d[S1] = p - r * 1.1 / 12;
        d[S2] = p - r * 1.1 / 6;
        d[S3] = p - r * 1.1 / 4;
        d[S4] = p - r * 1.1 / 2;
    elseif CalcMode == O_WOOD then
        d[R4] = h + (2 * (p - l) + r);
        d[R3] = h + 2 * (p - l);
        d[R2] = p + r;
        d[R1] = p * 2 - l;

        d[S1] = p * 2 - h;
        d[S2] = p - r;
        d[S3] = l - 2 * (h - p);
        d[S4] = l - (r + 2 * (h - p));
    elseif CalcMode == O_FIB then
        d[R4] = p + 1.618 * (h - l);
        d[R3] = p + 1 * (h - l);
        d[R2] = p + 0.618 * (h - l);
        d[R1] = p + 0.382 * (h - l);

        d[S1] = p - 0.382 * (h - l);
        d[S2] = p - 0.618 * (h - l);
        d[S3] = p - 1 * (h - l);
        d[S4] = p - 1.618 * (h - l);
    elseif CalcMode == O_FLOOR then
        d[R4] = 0;
        d[R3] = h + (p - l) * 2;
        d[R2] = p + r;
        d[R1] = p * 2 - l;

        d[S1] = p * 2 - h;
        d[S2] = p - r;
        d[S3] = l - (h - p) * 2;
        d[S4] = 0;
    elseif CalcMode == O_FIBR then
        d[R4] = l + (h - l) * fibr[R4];
        d[R3] = l + (h - l) * fibr[R3];
        d[R2] = l + (h - l) * fibr[R2];
        d[R1] = l + (h - l) * fibr[R1];

        d[S1] = l + (h - l) * fibr[S1];
        d[S2] = l + (h - l) * fibr[S2];
        d[S3] = l + (h - l) * fibr[S3];
        d[S4] = l + (h - l) * fibr[S4];
    end
	
	 
	 
	 d[RP]=p;

    return ;
end





function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
