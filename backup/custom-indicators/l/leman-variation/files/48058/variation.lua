-- Id: 8040
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("variation");
    indicator:description("variation");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    
	
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("N", "Period", "Period", 20);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("Algorithm", "Smoothing Algorithm", "Smoothing Algorithm", 0);
	indicator.parameters:addIntegerAlternative("Algorithm", "Don't Use something", "", 0);
	indicator.parameters:addIntegerAlternative("Algorithm", " Use  1. something Algorithm", "", 1);
	indicator.parameters:addIntegerAlternative("Algorithm", " Use  2. something Algorithm", "", 2);
	indicator.parameters:addIntegerAlternative("Algorithm", " Use  3. something Algorithm", "", 3);
	indicator.parameters:addIntegerAlternative("Algorithm", " Use  4. something Algorithm", "", 4);
	indicator.parameters:addIntegerAlternative("Algorithm", " Use  5. something Algorithm", "", 5);
	indicator.parameters:addIntegerAlternative("Algorithm", " Use  6. something Algorithm", "", 6);
	indicator.parameters:addIntegerAlternative("Algorithm", " Use  7. something Algorithm", "", 7);
	indicator.parameters:addIntegerAlternative("Algorithm", " Use  8. something Algorithm", "", 8);
	indicator.parameters:addIntegerAlternative("Algorithm", " Use  9. something Algorithm", "", 9);
	indicator.parameters:addIntegerAlternative("Algorithm", " Use  10. something Algorithm", "", 10);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("variation_color", "Color of variation", "Color of variation", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N;
local Algorithm;

local first;
local source = nil;
local MA1,MA2;
-- Streams block
local variation = nil;
local B1, B2;
local Method;
-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
	Method = instance.parameters.Method;
    Algorithm = instance.parameters.Algorithm;
    source = instance.source;
    
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA1 = core.indicators:create(Method, source, N);	
	B2 = instance:addInternalStream(0, 0);
	MA2 = core.indicators:create(Method, B2, N);	
	B1 = instance:addInternalStream(0, 0);
	
	first = MA2.DATA:first()+51;
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(N) .. ", " .. tostring(Algorithm) .. ", " .. tostring(Method).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        variation = instance:addStream("variation", core.Line, name, "variation", instance.parameters.variation_color, first);
    variation:setPrecision(math.max(2, instance.source:getPrecision()));
		variation:setWidth(instance.parameters.width);
        variation:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
  
	
	 --double ma = iMA(NULL,0,N,0,MODE_SMA,PRICE_CLOSE,i);
	MA1:update(mode);	
		 
	 --B2[i] = Close[i]-ma;
	 
	 if period  < MA1.DATA:first() then
	 return;
	 end
	 
     B2[period] = source[period]-MA1.DATA[period];
	

	
	 --double vr=iMAOnArray(B2,Bars,N,0,MODE_SMA,i);
	 	MA2:update(mode);	
		
     if period  < MA2.DATA:first() then
	 return;
	 end
	 
     -- double mov=iMA(NULL,0,N,0,MODE_SMA,PRICE_CLOSE,i);
	 
	 
     -- B1[i]=1000*(Close[i]-(mov+vr)); 
	 B1[period]= 1000*(source[period] - (MA1.DATA[period]+MA2.DATA[period]))
	
	
	  if period  < first then
	 return;
	 end
	
	  Smoothing(period);
    
end


function Smoothing(period)

if Algorithm == 0 then
variation[period]= B1[period]

elseif Algorithm == 1 then
variation[period]= 
  0.2926875484300*B1[period]
 +0.2698679548204*B1[period-1]
 +0.2277786802786*B1[period-2]
 +0.1726588586020*B1[period-3]
 +0.1124127695806*B1[period-4]
 +0.0550645669333*B1[period-5]
 +0.00733791069745*B1[period-6]
 -0.02637426808863*B1[period-7]
 -0.0445334647733*B1[period-8]
 -0.0483673837716*B1[period-9]
 -0.0412219004631*B1[period-10]
 -0.02759007317598*B1[period-11]
 -0.01206738017651*B1[period-12]
 +0.001567315986223*B1[period-13]
 +0.01094916192054*B1[period-14]
 +0.01530469318242*B1[period-15]
 +0.01532526278128*B1[period-16]
 +0.01296015381098*B1[period-17]
 +0.01157140552294*B1[period-18]
 -0.00533181209765*B1[period-19] 
 
elseif Algorithm == 2 then
variation[period]= 
  0.2447098565978*B1[period]
 +0.2313977400697*B1[period-1]
 +0.2061379694732*B1[period-2]
 +0.1716623034064*B1[period-3]
 +0.1314690790360*B1[period-4]
 +0.0895038754956*B1[period-5]
 +0.0496009165125*B1[period-6]
 +0.01502270569607*B1[period-7]
 -0.01188033734430*B1[period-8]
 -0.02989873856137*B1[period-9]
 -0.0389896710490*B1[period-10]
 -0.0401411362639*B1[period-11]
 -0.0351196808580*B1[period-12]
 -0.02611613850342*B1[period-13]
 -0.01539056955666*B1[period-14]
 -0.00495353651394*B1[period-15]
 +0.00368588764825*B1[period-16]
 +0.00963614049782*B1[period-17]
 +0.01265138888314*B1[period-18]
 +0.01307496106868*B1[period-19]
 +0.01169702291063*B1[period-20]
 +0.00974841844086*B1[period-21]
 +0.00898900012545*B1[period-22]
 -0.00649745721156*B1[period-23] 
 
elseif Algorithm == 3 then
variation[period]=
  0.2101888714743*B1[period]
 +0.2017361306871*B1[period-1]
 +0.1854987469779*B1[period-2]
 +0.1627557943437*B1[period-3]
 +0.1352455218956*B1[period-4]
 +0.1049955517302*B1[period-5]
 +0.0741580960823*B1[period-6]
 +0.0448262586090*B1[period-7]
 +0.01870440453637*B1[period-8]
 -0.002814841280245*B1[period-9]
 -0.01891352345654*B1[period-10]
 -0.02929206622741*B1[period-11]
 -0.0341888300133*B1[period-12]
 -0.0342703255777*B1[period-13]
 -0.03055656616909*B1[period-14]
 -0.02422648959598*B1[period-15]
 -0.01651476470542*B1[period-16]
 -0.00857503584404*B1[period-17]
 -0.001351831295525*B1[period-18]
 +0.00448511071596*B1[period-19]
 +0.00855374511399*B1[period-20]
 +0.01076725654789*B1[period-21]
 +0.01131091969998*B1[period-22]
 +0.01057394212462*B1[period-23]
 +0.00912947281517*B1[period-24]
 +0.00771484446233*B1[period-25]
 +0.00732318993223*B1[period-26]
 -0.00726358358348*B1[period-27] 
 
elseif Algorithm == 4 then
variation[period]=
  0.1841600001487*B1[period]
 +0.1784754786728*B1[period-1]
 +0.1674508960246*B1[period-2]
 +0.1517504699970*B1[period-3]
 +0.1323034848757*B1[period-4]
 +0.1102401824660*B1[period-5]
 +0.0867964146007*B1[period-6]
 +0.0632389269284*B1[period-7]
 +0.0407389647190*B1[period-8]
 +0.02035075474450*B1[period-9]
 +0.002915227087755*B1[period-10]
 -0.01100443994875*B1[period-11]
 -0.02116075293157*B1[period-12]
 -0.02747786871251*B1[period-13]
 -0.03024034479978*B1[period-14]
 -0.02988490637108*B1[period-15]
 -0.02702558542347*B1[period-16]
 -0.02236077351054*B1[period-17]
 -0.01662176948519*B1[period-18]
 -0.01050105629699*B1[period-19]
 -0.00460605501191*B1[period-20]
 +0.000582766458037*B1[period-21]
 +0.00473324688655*B1[period-22]
 +0.00766855376673*B1[period-23]
 +0.00936273985238*B1[period-24]
 +0.00991966879705*B1[period-25]
 +0.00955690928799*B1[period-26]
 +0.00857195408578*B1[period-27]
 +0.00734849040305*B1[period-28]
 +0.00634910972836*B1[period-29]
 +0.00617002099346*B1[period-30]
 -0.00780070803276*B1[period-31] 
 
elseif Algorithm == 5 then
variation[period]=
  0.1638504429550*B1[period]
 +0.1598485090620*B1[period-1]
 +0.1520285056667*B1[period-2]
 +0.1407759621461*B1[period-3]
 +0.1266145946036*B1[period-4]
 +0.1101999467868*B1[period-5]
 +0.0922810246421*B1[period-6]
 +0.0736414430377*B1[period-7]
 +0.0550613836268*B1[period-8]
 +0.0372780690048*B1[period-9]
 +0.02094281812508*B1[period-10]
 +0.00658930585105*B1[period-11]
 -0.00538855535197*B1[period-12]
 -0.01474498292814*B1[period-13]
 -0.02139199173398*B1[period-14]
 -0.02541417253316*B1[period-15]
 -0.02702341057229*B1[period-16]
 -0.02647614727071*B1[period-17]
 -0.02421775125345*B1[period-18]
 -0.02065411010395*B1[period-19]
 -0.01625074823286*B1[period-20]
 -0.01145130552469*B1[period-21]
 -0.00665356586398*B1[period-22]
 -0.002196710270528*B1[period-23]
 +0.001656596678561*B1[period-24]
 +0.00473296009497*B1[period-25]
 +0.00694308970535*B1[period-26]
 +0.00827947138512*B1[period-27]
 +0.00880879507493*B1[period-28]
 +0.00865791955067*B1[period-29]
 +0.00800414344065*B1[period-30]
 +0.00706330074106*B1[period-31]
 +0.00608814048308*B1[period-32]
 +0.00538380036114*B1[period-33]
 +0.00532891349043*B1[period-34]
 -0.00819568487412*B1[period-35] 
 
elseif Algorithm == 6 then
variation[period]=
  0.1475657670368*B1[period]
 +0.1446405411673*B1[period-1]
 +0.1389042575727*B1[period-2]
 +0.1305751002746*B1[period-3]
 +0.1199864911731*B1[period-4]
 +0.1075255410806*B1[period-5]
 +0.0936615730647*B1[period-6]
 +0.0788949093050*B1[period-7]
 +0.0637465101034*B1[period-8]
 +0.0487276238639*B1[period-9]
 +0.0343174315294*B1[period-10]
 +0.02094370638877*B1[period-11]
 +0.00896531966221*B1[period-12]
 -0.001341999129024*B1[period-13]
 -0.00978712653663*B1[period-14]
 -0.01627791183058*B1[period-15]
 -0.02080151436502*B1[period-16]
 -0.02343895781894*B1[period-17]
 -0.02435214700067*B1[period-18]
 -0.02376786389147*B1[period-19]
 -0.02193912806308*B1[period-20]
 -0.01912053352973*B1[period-21]
 -0.01567028095913*B1[period-22]
 -0.01183273845729*B1[period-23]
 -0.00790611190014*B1[period-24]
 -0.00412385952442*B1[period-25]
 -0.000685399211775*B1[period-26]
 +0.002260911767506*B1[period-27]
 +0.00461801537249*B1[period-28]
 +0.00633741616229*B1[period-29]
 +0.00741961543986*B1[period-30]
 +0.00790789206069*B1[period-31]
 +0.00788111695823*B1[period-32]
 +0.00745129870298*B1[period-33]
 +0.00674985662064*B1[period-34]
 +0.00593128562366*B1[period-35]
 +0.00517071741994*B1[period-36]
 +0.00467211882117*B1[period-37]
 +0.00468906740665*B1[period-38]
 -0.00849851236070*B1[period-39] 
 
elseif Algorithm == 7 then
variation[period]=
  0.1342157583828*B1[period]
 +0.1320168704847*B1[period-1]
 +0.1276873471586*B1[period-2]
 +0.1213643729739*B1[period-3]
 +0.1132520713460*B1[period-4]
 +0.1036083698498*B1[period-5]
 +0.0927280425508*B1[period-6]
 +0.0809406915977*B1[period-7]
 +0.0686105258715*B1[period-8]
 +0.0560701395588*B1[period-9]
 +0.0436869941553*B1[period-10]
 +0.0317716835118*B1[period-11]
 +0.02062340027452*B1[period-12]
 +0.01049287508919*B1[period-13]
 +0.001578073235404*B1[period-14]
 -0.00597507422440*B1[period-15]
 -0.01207707288043*B1[period-16]
 -0.01669798399142*B1[period-17]
 -0.01986198555101*B1[period-18]
 -0.02164119825031*B1[period-19]
 -0.02215230961811*B1[period-20]
 -0.02155191142867*B1[period-21]
 -0.02002808597329*B1[period-22]
 -0.01778220203770*B1[period-23]
 -0.01500325973440*B1[period-24]
 -0.01187583268349*B1[period-25]
 -0.00865026821576*B1[period-26]
 -0.00543510816909*B1[period-27]
 -0.002420531056597*B1[period-28]
 +0.0002889057085442*B1[period-29]
 +0.002599652575601*B1[period-30]
 +0.00445344386830*B1[period-31]
 +0.00582556501823*B1[period-32]
 +0.00671941035514*B1[period-33]
 +0.00716358274204*B1[period-34]
 +0.00721108593431*B1[period-35]
 +0.00693382886173*B1[period-36]
 +0.00641737976071*B1[period-37]
 +0.00576046002138*B1[period-38]
 +0.00507417448638*B1[period-39]
 +0.00448195239124*B1[period-40]
 +0.00412727462648*B1[period-41]
 +0.00418669196944*B1[period-42]
 -0.00873780054566*B1[period-43] 
 
elseif Algorithm == 8 then
variation[period]=
  0.1230811432921*B1[period]
 +0.1213830265980*B1[period-1]
 +0.1180348688628*B1[period-2]
 +0.1131248477390*B1[period-3]
 +0.1067888736447*B1[period-4]
 +0.0991886630563*B1[period-5]
 +0.0905283970643*B1[period-6]
 +0.0810323992972*B1[period-7]
 +0.0709406523601*B1[period-8]
 +0.0605028783409*B1[period-9]
 +0.0499660517196*B1[period-10]
 +0.0395768971912*B1[period-11]
 +0.02956612933181*B1[period-12]
 +0.02012982828450*B1[period-13]
 +0.01146221166452*B1[period-14]
 +0.00369983285522*B1[period-15]
 -0.003038977187834*B1[period-16]
 -0.00868021984873*B1[period-17]
 -0.01318508621117*B1[period-18]
 -0.01655096644715*B1[period-19]
 -0.01881253249101*B1[period-20]
 -0.02003063357865*B1[period-21]
 -0.02029727780544*B1[period-22]
 -0.01972188576919*B1[period-23]
 -0.01843477354910*B1[period-24]
 -0.01658081992154*B1[period-25]
 -0.01430671529886*B1[period-26]
 -0.01175302972849*B1[period-27]
 -0.00904320119485*B1[period-28]
 -0.00630514721661*B1[period-29]
 -0.00369357675439*B1[period-30]
 -0.001242693518572*B1[period-31]
 +0.000926258391563*B1[period-32]
 +0.002776968147451*B1[period-33]
 +0.00426926013496*B1[period-34]
 +0.00538851571708*B1[period-35]
 +0.00613947934547*B1[period-36]
 +0.00654179765073*B1[period-37]
 +0.00663281051554*B1[period-38]
 +0.00645954126814*B1[period-39]
 +0.00608069576729*B1[period-40]
 +0.00556313321406*B1[period-41]
 +0.00497954512068*B1[period-42]
 +0.00441241979276*B1[period-43]
 +0.00395101867555*B1[period-44]
 +0.00369891645504*B1[period-45]
 +0.00378072162625*B1[period-46]
 -0.00893024660315*B1[period-47] 
 
elseif Algorithm == 9 then
variation[period]=
  0.1136491141667*B1[period]
 +0.1123130870080*B1[period-1]
 +0.1096691394261*B1[period-2]
 +0.1057837207790*B1[period-3]
 +0.1007420961698*B1[period-4]
 +0.0946599675379*B1[period-5]
 +0.0876755484183*B1[period-6]
 +0.0799429655454*B1[period-7]
 +0.0716292336416*B1[period-8]
 +0.0629123835413*B1[period-9]
 +0.0539767262326*B1[period-10]
 +0.0450048491714*B1[period-11]
 +0.0361703734359*B1[period-12]
 +0.02763520549089*B1[period-13]
 +0.01955011451800*B1[period-14]
 +0.01205357915205*B1[period-15]
 +0.00525211553366*B1[period-16]
 -0.000770477101024*B1[period-17]
 -0.00593916191975*B1[period-18]
 -0.01022805895137*B1[period-19]
 -0.01361544672818*B1[period-20]
 -0.01611640231317*B1[period-21]
 -0.01776260795296*B1[period-22]
 -0.01860554342447*B1[period-23]
 -0.01871505916941*B1[period-24]
 -0.01817487448682*B1[period-25]
 -0.01707856129273*B1[period-26]
 -0.01552770218471*B1[period-27]
 -0.01362988259084*B1[period-28]
 -0.01149332680480*B1[period-29]
 -0.00921892385382*B1[period-30]
 -0.00689459719023*B1[period-31]
 -0.00459651305691*B1[period-32]
 -0.002411870743968*B1[period-33]
 -0.000431732873329*B1[period-34]
 +0.001353807064687*B1[period-35]
 +0.002857282707287*B1[period-36]
 +0.00408190921586*B1[period-37]
 +0.00501143566228*B1[period-38]
 +0.00565074521587*B1[period-39]
 +0.00601564306030*B1[period-40]
 +0.00613066979989*B1[period-41]
 +0.00602923574050*B1[period-42]
 +0.00575258932729*B1[period-43]
 +0.00534744169195*B1[period-44]
 +0.00486457915178*B1[period-45]
 +0.00435951288835*B1[period-46]
 +0.00389329662905*B1[period-47]
 +0.00353234960893*B1[period-48]
 +0.00335331131328*B1[period-49]
 +0.00344636014208*B1[period-50]
 -0.00908964634931*B1[period-51] 
 
elseif Algorithm == 10 then
 variation[period]=
  0.363644232288*B1[period]
 +0.319961361319*B1[period-1]
 +0.2429021537279*B1[period-2]
 +0.1499479402208*B1[period-3]
 +0.0606476023757*B1[period-4]
 -0.00876136797274*B1[period-5]
 -0.0492967601969*B1[period-6]
 -0.0606402244647*B1[period-7]
 -0.0496978153976*B1[period-8]
 -0.02724932305397*B1[period-9]
 -0.00400372352396*B1[period-10]
 +0.01244416185618*B1[period-11]
 +0.01927941647120*B1[period-12]
 +0.01821767237980*B1[period-13]
 +0.01598780862402*B1[period-14]
 -0.00338313465225*B1[period-15];     
  end
 
end

