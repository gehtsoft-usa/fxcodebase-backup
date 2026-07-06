-- Id: 14557

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62412

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Short-term Volume and Price Oscillator with Real volume/Transactions");
    indicator:description("Short-term Volume and Price Oscillator with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
  indicator.parameters:addInteger("period", "Period", "", 8);
  indicator.parameters:addDouble("cutoff", "Cutoff", "", 1);
 indicator.parameters:addDouble("devH", "Standard Deviation High", "", 1.5);
  indicator.parameters:addDouble("devL", "Standard Deviation Low", "", 1.3);
 indicator.parameters:addInteger("stdevper", "Standard Deviation Period", "",100);

    indicator.parameters:addGroup("SPAVO Line Style Options");	 
	indicator.parameters:addInteger("widthS", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleS", "Style", " ", core.LINE_SOLID);
	 indicator.parameters:setFlag("styleS", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SPAVO_color", "Color of SPAVO Line", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("Bands Lines Style Options");	 
	indicator.parameters:addBoolean("Show", "Show Bands", "", true);
	indicator.parameters:addInteger("widthB", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleB", "Style", " ", core.LINE_SOLID);
	 indicator.parameters:setFlag("styleB", core.FLAG_LINE_STYLE);
	 indicator.parameters:addColor("Up_color", "Color of upper SD Line", "", core.rgb(0, 255, 0));
	  indicator.parameters:addColor("Down_color", "Color of  lower SD Line", "", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local period,cutoff,devH,devL,stdevper;
local haopen,haclose,LinReg;
local first;
local source = nil;
local EMA1, EMA2, EMA3,AVG;
local EMAA, EMAB, EMAC;
local EMAX, EMAY, EMAZ;
local haC,vtr, calc1; 
local  SVAPOBase;
-- Streams block
local SPAVO = nil;
local Show;
local upperSDLine, lowerSDLine;
local Ind;

local FirstStart;
local LastTime;

-- Routine
function Prepare(nameOnly)
    stdevper = instance.parameters.stdevper;
    devH = instance.parameters.devH;
	devL = instance.parameters.devL;
    cutoff = instance.parameters.cutoff;
    period = instance.parameters.period;
    source = instance.source;
	Show = instance.parameters.Show;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(period).. ", " .. tostring( cutoff) .. ", " .. tostring(devH).. ", " .. tostring( devL).. ", " .. tostring( stdevper).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
	haopen =  instance:addInternalStream(0, 0);
	haclose =instance:addInternalStream(0, 0);
    LinReg =instance:addInternalStream(0, 0);
	haC =instance:addInternalStream(0, 0);
	vtr =instance:addInternalStream(0, 0);
	calc1 =instance:addInternalStream(0, 0);
	SVAPOBase =instance:addInternalStream(0, 0);
	
	EMA1 = core.indicators:create("EMA", haclose,  period/1.6);
	EMA2 = core.indicators:create("EMA", EMA1.DATA,  period/1.6);
	EMA3 = core.indicators:create("EMA", EMA2.DATA,  period/1.6);
	
	EMAA = core.indicators:create("EMA", LinReg,  period);
	EMAB = core.indicators:create("EMA", EMAA.DATA,  period);
	EMAC = core.indicators:create("EMA", EMAB.DATA,  period);
	
	EMAX = core.indicators:create("EMA", SVAPOBase,  period);
	EMAY = core.indicators:create("EMA", EMAA.DATA,  period);
	EMAZ = core.indicators:create("EMA", EMAB.DATA,  period);

     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;
	
	
	AVG = core.indicators:create("MVA", Ind.DATA,  period * 5);
	
	first = math.max(EMA3.DATA:first(), AVG.DATA:first()+1, EMAZ.DATA:first(), EMAC.DATA:first());

    

    if (not (nameOnly)) then
        SPAVO = instance:addStream("SPAVO", core.Line, name, "SPAVO", instance.parameters.SPAVO_color, EMAZ.DATA:first() );
    SPAVO:setPrecision(math.max(2, instance.source:getPrecision()));
		SPAVO:setWidth(instance.parameters.widthS);
	    SPAVO:setStyle(instance.parameters.styleS);
		if Show then
		upperSDLine = instance:addStream("UPSD", core.Line, name, "upperSD", instance.parameters.Up_color, EMAZ.DATA:first() + stdevper);
    upperSDLine:setPrecision(math.max(2, instance.source:getPrecision()));
		lowerSDLine = instance:addStream("DOWNSD", core.Line, name, "upperSD", instance.parameters.Down_color, EMAZ.DATA:first() + stdevper);
    lowerSDLine:setPrecision(math.max(2, instance.source:getPrecision()));
		upperSDLine:setWidth(instance.parameters.widthB);
	    upperSDLine:setStyle(instance.parameters.styleB);
		lowerSDLine:setWidth(instance.parameters.widthB);
	    lowerSDLine:setStyle(instance.parameters.styleB);
		end
    end
end

function AsyncOperationFinished(cookie, success, message)

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(p, mode)
  
	
	haopen[p] = ((source.open[p-1] + source.high[p-1] + source.low[p-1] + source.close[p-1]) / 4 + haopen[p-1]) / 2;
	haclose[p] = ((source.open[p] + source.high[p] + source.low[p] + source.close[p]) / 4 + haopen[p] + math.max(source.high[p], haopen[p]) + math.min(source.low[p], haopen[p])) / 4;

	local period=p;

        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(first);    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end
	
	 EMA1:update(mode);
	 EMA2:update(mode);
     EMA3:update(mode);
	 AVG:update(mode);
	 
    if p < EMA3.DATA:first()
	or p < (AVG.DATA:first() + 1)
	then
    return;
	end		 
	 
	haC[p] = 3 * EMA1.DATA[p] - 3 * EMA2.DATA[p] + EMA3.DATA[p];
	
	local vave = AVG.DATA[p-1];
	local vmax = vave * 2;
	
	local  vc; 
	
	if Ind.DATA[p] < vmax
	then 
	vc=  Ind.DATA[p];
	else 
	vc= vmax 
	end
	
	LinReg[p] =  LinRegSlope(p, Ind.DATA);	 
	
   
	
	EMAA:update(mode);
	EMAB:update(mode);
    EMAC:update(mode);
	
	if p < EMAC.DATA:first()
	then
    return;
	end		 
	
	vtr[p]=  3 * EMAA.DATA[p] - 3 * EMAB.DATA[p] + EMAC.DATA[p];
	
	-- SPAVO[p] = vtr[p]
	
	if vc== nil then
	vc=0;
	end
 
  if haC[p] > haC[p-1]*(1+cutoff/1000) and vtr[p] >= vtr[p-1] and vtr[p-1] > vtr[p-2] then
  calc1[p]= vc 
 elseif haC[p] < haC[p-1]*(1-cutoff/1000) and vtr[p] >= vtr[p-1] and vtr[p-1] > vtr[p-2] then
  calc1[p]= -vc
 else 
 calc1[p]=0;
 end
	
   SVAPOBase[p] = mathex.sum (calc1,p-period+1, p) /(vave+1);	
   
    EMAX:update(mode);
	EMAY:update(mode);
    EMAZ:update(mode);
	
	if p < EMAZ.DATA:first()
	then
    return;
	end		
   
  SPAVO[p] = 3 * EMAX.DATA[p] - 3 * EMAY.DATA[p] + EMAZ.DATA[p];
  
	  if Show then
			   if p < EMAZ.DATA:first() + stdevper
				then
				return;
				end		
			  
			   upperSDLine[p] = devH*mathex.stdev (SPAVO,p-stdevper+1, p);
			   lowerSDLine[p] = -devL*mathex.stdev (SPAVO,p-stdevper+1, p); 
	   end   
   
end

function LinRegSlope(p,data)

local b =0;
local c =0;
local petlja =0;
local test=0;
local y=0;
local xy=0;
local x=0;
local x2=0;
										
								for petlja = (p-period), p, 1 do
								
									if petlja == (p-period) then
									test=1;
									y = data[petlja];
									xy=data[petlja]*test;
									x=test;
									x2=test*test;
									else
									test=test+1;													
								    y = y + data[petlja];
								    xy=xy+(data[petlja]*test);
								    x=x+test;
								    x2=x2+(test*test);
									end
							
					   end
    		                  
            c=x2*(test)-x*x;
		    b=(xy*(test)-x*y)/c;			
	        return b;
	
	  
 end

