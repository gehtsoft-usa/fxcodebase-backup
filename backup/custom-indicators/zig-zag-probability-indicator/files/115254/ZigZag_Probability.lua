-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65150

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("ZigZag Probability indicator");
    indicator:description("ZigZag Probability indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ZZ_Depth", "ZigZag depth", "", 12);
    indicator.parameters:addInteger("ZZ_Deviation", "ZigZag deviation", "", 5);
    indicator.parameters:addInteger("ZZ_Backstep", "ZigZag backstep", "", 3);

    indicator.parameters:addInteger("StdDev_Period", "Standard deviation period", "", 10);

    indicator.parameters:addDouble("Coeff1", "Zone 1 coeff", "", 1);
    indicator.parameters:addDouble("Coeff2", "Zone 2 coeff", "", 2);
    indicator.parameters:addDouble("Coeff3", "Zone 3 coeff", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "One Standard deviation Color", "One Standard deviation Color", core.rgb(200, 200, 200));
    indicator.parameters:addColor("clr2", "Two Standard deviations Color", "Two Standard deviations Color", core.rgb(150, 150, 150));
    indicator.parameters:addColor("clr3", "Three Standard deviations Color", "Three Standard deviations Color", core.rgb(100, 100, 100));
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 50, 0, 100);
end

local first;
local source = nil;
local ZZ, StdDev;
local transparency;
local Coeff1, Coeff2, Coeff3;

function Prepare(nameOnly)
    source = instance.source;
    Coeff1 = instance.parameters.Coeff1;
    Coeff2 = instance.parameters.Coeff2;
    Coeff3 = instance.parameters.Coeff3;
    first = source:first()+2;
	
	
	assert(core.indicators:findIndicator("STDDEV") ~= nil, "Please, download and install STDDEV.LUA indicator");  
	
    ZZ = core.indicators:create("ZIGZAG", source, instance.parameters.ZZ_Depth, instance.parameters.ZZ_Deviation, instance.parameters.ZZ_Backstep);
    StdDev = core.indicators:create("STDDEV", source.close, instance.parameters.StdDev_Period);
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    instance:ownerDrawn(true);
end

local CurZZPrice;
local SD;

function CalcZZPrice(index)
  local i=index;

  local A, B, C=nil, nil, nil;
  local pA, pB, pC;
  local ZZ_D;

  while i>first and A==nil do
    ZZ_D=ZZ.DATA[i];
    if ZZ_D==source.high[i] or ZZ_D==source.low[i] then
      if C==nil then
        C=i;
      elseif B==nil then
        B=i;
      elseif A==nil then
        A=i;
      end
    end

    i=i-1;
  end

  if A==nil then
    return 0;
  end

  if source.high[C]==ZZ.DATA[C] then
    pA=source.high[A];
    pB=source.low[B];
    pC=source.high[C];
  else
    pA=source.low[A];
    pB=source.high[B];
    pC=source.low[C];
  end

  local k, b, pD, pE, b2, H, pH;

  k=(pA-pC)/(A-C);
  b=pC-C*k;

  pD=B*k+b;
  pE=(pD+pB)/2;
  b2=pE-B*k;
  H=index;
  pH=k*H+b2;

  return pH;
end

function Update(period, mode)
   if period==source:size()-1 then
    ZZ:update(mode);
    StdDev:update(mode);

    CurZZPrice=CalcZZPrice(period);
    SD=StdDev.DATA[period];
   end 
end

local init = false;

function Draw(stage, context)
    if stage == 0 then   
        if not init then
            context:createSolidBrush(1, instance.parameters.clr1);
            context:createSolidBrush(2, instance.parameters.clr2);
            context:createSolidBrush(3, instance.parameters.clr3);
            transparency=context:convertTransparency(instance.parameters.transparency);
            init = true;
        end

        if CurZZPrice==nil or CurZZPrice<=0 or SD==nil or SD<=0 then
          return;
        end

        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());

        local x=context:positionOfBar(source:size()-1);
        local v, y=context:pointOfPrice(CurZZPrice);
        local y1_1, y2_1, y1_2, y2_2, y1_3, y2_3, x1_1, x2_1, x1_2, x2_2, x1_3, x2_3;
        v, y1_1=context:pointOfPrice(CurZZPrice+SD);
        v, y2_1=context:pointOfPrice(CurZZPrice-SD);
        local ySize=math.abs(y1_1-y2_1);

        x1_1=x-Coeff1*ySize/2;
        x2_1=x+Coeff1*ySize/2;
        x1_2=x-Coeff2*ySize/2;
        x2_2=x+Coeff2*ySize/2;
        x1_3=x-Coeff3*ySize/2;
        x2_3=x+Coeff3*ySize/2;

        y1_1=y+Coeff1*ySize/2;
        y2_1=y-Coeff1*ySize/2;
        y1_2=y+Coeff2*ySize/2;
        y2_2=y-Coeff2*ySize/2;
        y1_3=y+Coeff3*ySize/2;
        y2_3=y-Coeff3*ySize/2;

        context:drawEllipse(-1, 3, x1_3, y1_3, x2_3, y2_3, transparency);
        context:drawEllipse(-1, 2, x1_2, y1_2, x2_2, y2_2, transparency);
        context:drawEllipse(-1, 1, x1_1, y1_1, x2_1, y2_1, transparency);

        context:resetClipRectangle();
    end
end
