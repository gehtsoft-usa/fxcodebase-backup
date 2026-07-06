function Init()
indicator:name("anas Bollinger");
indicator:description("Bolinger band the uper band on high the lower on low");
indicator:requiredSource(core.Bar);
indicator:type(core.Indicator);

indicator.parameters:addGroup("Calculation");
indicator.parameters:addInteger("N","number of periods ","number of periods desciption", 20, 1, 10000);
indicator.parameters:addDouble("Dev","standard diviation ","standard diviation", 1.0, 0.0001, 1000.0);
indicator.parameters:addGroup("Style");

indicator.parameters:addColor("clrBBUP", "color of uper band ", "color of uper band", core.rgb(0,255, 0));
indicator.parameters:addColor("clrBBDO", "color of lower band ", "color of lower band", core.rgb(255,0, 0));
indicator.parameters:addColor("clravr", "color of avarage line ", "color of avarage line", core.rgb(255,255,255));

    indicator.parameters:addInteger("widthBBB","width of BB","width of BB", 1, 1, 5);
    indicator.parameters:addInteger("widthBBavr","width of avr line ","width of avr line", 1, 1, 5);
    
    indicator.parameters:addInteger("styleBBB","style of BB","style of BB", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBB", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addInteger("styleBBavr","style of BB avarage line ","style of BB avarage line", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBavr", core.FLAG_LEVEL_STYLE);
       

end
local N;
local D;

local firstPeriod;
local source = nil;
local UL = nil;
local LL = nil;
local AL = nil;

function Prepare()
    N = instance.parameters.N;
    D = instance.parameters.Dev;
    source = instance.source;
    
    firstPeriod = source:first() + N - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. D .. ")";
    instance:name(name);
    
    UL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.clrBBUP, firstPeriod)
    UL:setWidth(instance.parameters.widthBBB);
    UL:setStyle(instance.parameters.styleBBB);
    
    LL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.clrBBDO, firstPeriod)
    LL:setWidth(instance.parameters.widthBBB);
    LL:setStyle(instance.parameters.styleBBB);
              
    AL = instance:addStream("BL", core.Line, name .. ".BL", "BL", instance.parameters.clravr, firstPeriod)
    AL:setWidth(instance.parameters.widthBBavr);
    AL:setStyle(instance.parameters.styleBBavr);
    end
  function Update(period)
  if period >= firstPeriod then
    local ml = mathex.avg(source, period - N + 1, period);
    local mlh = mathex.avg(source.high, period - N + 1, period);
    local mll = mathex.avg(source.low, period - N + 1, period);
    
    
        local dup = mathex.stdev(source.high, period - N + 1, period);
        local ddown = mathex.stdev(source.low, period - N + 1, period);
        
        
       
        UL[period] = mlh + (D * dup);
        LL[period] = mll - (D * ddown);
        AL[period] = ml;
        
  end
  
  
  end
    