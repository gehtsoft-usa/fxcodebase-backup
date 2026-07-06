-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=16319

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

-- ver 2
function Init()
    indicator:name("Horizontal lines for orders");
    indicator:description("Draw horizontal lines for orders and option expiries");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    -- indicator.parameters:addFile("OrdersFile", "Orders File", "", "");
	-- file format: csv
	-- structure: instrument, order type, start date, price
	-- where: 
    --        instrument = name of the instrument as returned by source:name() (e.g., EUR/USD)
    --        order type = SELL,BUY or OPT. SELLs are drawn usually in red, BUYs in blue, OPTs in magenta (i.e., core.rgb(255,0,255))
	--        start date = format MM/DD/YYYY HH:MM, in GMT timezone
	--        price(s) = the price(s) of that order type for instrument separated with "/". E.g., 1.1100/1.1150/1.1200
	-- Lines will end when the market price will hit the line's price.

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("buyclr", "BUY Color", "BUY Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("buythick", "BUY line thickness", "BUY line thickness (0 to hide)", 1, 0, 5);
    indicator.parameters:addInteger("buystyle", "BUY Line style", "BUY Line style", core.LINE_DASH);
    indicator.parameters:setFlag("buystyle", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("sellclr", "SELL Color", "SELL Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("sellthick", "SELL line thickness", "SELL line thickness (0 to hide)", 1, 0, 5);
    indicator.parameters:addInteger("sellstyle", "SELL Line style", "SELL Line style", core.LINE_DASH);
    indicator.parameters:setFlag("sellstyle", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("optclr", "OPT Color", "OPT Color", core.rgb(255, 0, 255));
    indicator.parameters:addInteger("optthick", "OPT line thickness", "OPT line thickness (0 to hide)", 1, 0, 5);
    indicator.parameters:addInteger("optstyle", "OPT Line style", "OPT Line style", core.LINE_DASH);
    indicator.parameters:setFlag("optstyle", core.FLAG_LINE_STYLE);

    indicator.parameters:addString("LabelHPos", "Label Horizontal position", "", "Right");
				indicator.parameters:addStringAlternative("LabelHPos", "Right", "", "Right");
				indicator.parameters:addStringAlternative("LabelHPos", "Left", "", "Left");
				indicator.parameters:addStringAlternative("LabelHPos", "Center", "", "Center");
				indicator.parameters:addStringAlternative("LabelHPos", "AtOrder", "", "At Order");
    indicator.parameters:addString("LabelVPos", "Label Vertical position", "", "Bottom");
				indicator.parameters:addStringAlternative("LabelVPos", "Top", "", "Top");
				indicator.parameters:addStringAlternative("LabelVPos", "Bottom", "", "Bottom");
				indicator.parameters:addStringAlternative("LabelVPos", "Center", "", "Center");
    indicator.parameters:addInteger("FontSize", "Label font size", "Label font size", 10);
	indicator.parameters:addBoolean("lblOldOrd","Show labels for active orders only","If true then will not display labels for the lines which were hit by a candle",true);

	indicator.parameters:addGroup("Data");
	indicator.parameters:addInteger("ordersageActive", "Max age of active orders in days", "Active orders (which were not yet hit by price since their inception) older than this much days will be ignored", 5, 1, 365);
	indicator.parameters:addInteger("ordersagePassed", "Max age of former orders in days", "Former orders (which were already hit by price since their inception) older than this much days will be ignored (0=hide old orders/options immediately after they were fulfilled)", 5, 0, 365);

	indicator.parameters:addGroup("Dbg");
	indicator.parameters:addBoolean("dbgind","Show debug data","Show debug info in Events window",false);
end

local source = nil;
local ask;
local bid;

local font;
local lbHalign, HPos, VPos2;
local LastPeriod;
local lns={}; -- table of lines. The element lns[i] is a table containing {order type, start date, price} for the current instrument
              -- so lns[i][3] is the price, lns[i][2] is the start date in GMT timezone, and lns[i][1] is the order type
local lnsz;
local idBase=9000; -- max 999 objects drawable
local fxorders;

function Prepare(nameOnly)
    source = instance.source;
	ask=source;
	bid=source;
--	if source:isBid() then
--           bid = source;
--           ask = core.host:execute("getAskPrice");
--    else
--           ask = source;
--           bid = core.host:execute("getBidPrice");
--    end
 

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    font = core.host:execute("createFont", "Arial", instance.parameters.FontSize, true, false);
    if instance.parameters.LabelHPos=="Right" then
		lbHalign=core.H_Left;
		HPos=core.CR_RIGHT;
    elseif instance.parameters.LabelHPos=="Left" then
		lbHalign=core.H_Right;
		HPos=core.CR_LEFT;
    elseif instance.parameters.LabelHPos=="Center" then
		lbHalign=core.H_Center;
		HPos=core.CR_CENTER;
	else
		lbHalign=core.H_Left;
		HPos=core.CR_CHART;
    end 
    if instance.parameters.LabelVPos=="Top" then
		VPos2=core.V_Top;
    elseif instance.parameters.LabelVPos=="Bottom" then
		VPos2=core.V_Bottom;
    else
		VPos2=core.V_Center;
    end
    LastPeriod=nil;

	fxorders=core.app_path() .. "\\persistent\\fxorders.txt";

	-- the parsing of the text file is done here. The drawing will be done repeatedly in the Update method.
	-- local handle;
	-- handle=io.open(fxorders,"r");

	local line;
	local T=nil;
	lnsz=0;
	lns={};
	local ddate,ddate1,ddate2,dtime;
	local prices;

	-- structure: instrument, order type, start date, price
	-- where: 
    --        instrument = name of the instrument as returned by source:name() (e.g., EUR/USD)
    --        order type = SELL, BUY or OPT 
	--        start date = format MM/DD/YYYY HH:MM, in GMT timezone
	--        price = the price of that instrument
--	if handle~=nil then
--		for line in handle:lines() do 
		for line in io.lines(fxorders) do 
			if line ~= nil and #line>0 and string.sub(line,1,1)~="#" then
				-- dbg("io.lines=" .. line);
				T=Split(line,","); -- T[1]=instrument,T[2]=order type,T[3]=start date,T[4]=price(s)
				if string.upper(T[1])==string.upper(source:name()) and (string.upper(T[2])=="BUY" or string.upper(T[2])=="SELL" or string.upper(T[2])=="OPT") then
					ddate2=Split(T[3]," "); -- ddate[1]=mm/dd/yyyy, ddate[2]=hh:mm
					ddate1=Split(ddate2[1],"/"); -- mm,dd,yyyy
					dtime=Split(ddate2[2],":");-- hh,mm
					ddate=core.datetime(tonumber(ddate1[3]),tonumber(ddate1[1]),tonumber(ddate1[2]),tonumber(dtime[1]),tonumber(dtime[2]),0);
					ddate=core.host:execute("convertTime", core.TZ_UTC, core.TZ_SERVER, ddate);
					-- early filter out old orders
					corenow=core.host:execute("convertTime", core.TZ_LOCAL, core.TZ_SERVER, core.now());
					if os.difftime(corenow, ddate)<math.max(instance.parameters.ordersageActive, instance.parameters.ordersagePassed) then
						prices=nil;
						if T[4]~=nil then
							if string.find(T[4]," ")~=nil then
								prices=Split(T[4]," ");
							elseif string.find(T[4],"/")~=nil then
								prices=Split(T[4],"/");
							else
								prices={T[4]};
							end
						end
						if prices~=nil then
							for k,v in ipairs(prices) do
								if v~=nil then
									iddate=getNewestOrder(string.upper(T[2]),v);
									if iddate==0 then
										lnsz=lnsz+1;
										-- later, lns[i] may be set to nil for those orders which must not be drawn any more because they are expired.
										lns[lnsz]={string.upper(T[2]), ddate, v, 0}; -- buy/sell/opt, datetime, price, oldflag (calculated: 0=undetermined, 1=active, -1=old)
									elseif ddate>lns[iddate][2] then
										lns[iddate][2]=ddate;
									end
								end
							end
						end
					else
						dbg("early filtering out old order " .. line);
					end
					-- dbg("raw io.line=" .. line .. ", parsed:ordtyp=" .. lns[lnsz][1] .. ", from=" .. dbgDateValue(lns[lnsz][2]) .. ", price=" .. lns[lnsz][3]);
				end
			end
		end
--		handle:close();
--	end
end

function getNewestOrder(typ,price)
	-- searches in lns[] for an order of type "typ" at the price "price"
	-- returns 0 if such an order was not found
	-- returns the index (in the lns table) of that order, if found.
	maxd=0;
	imaxd=0;
	if lnsz>0 and lns~=nil then
		for k,v in ipairs(lns) do
			if v~=nil and maxd<v[2] and typ==v[1] and price==v[3] then
				maxd=v[2];
				imaxd=k;
			end
		end
	end
	return imaxd;
end


function Update(period, mode)
   if period>source:first() and (period==source:size()-1) and LastPeriod~=period then
		LastPeriod=period;

		clearLines();
		local i,j;
		local x,xfind;
		local lnAboveFirst,dfrom,dto;
		local prc3;
		local sdbg;
		
		j=0;
		local flag4; -- if 0 then skip this order
		
		for i=1,lnsz,1 do
			-- if os.difftime(core.now(), lns[i][2]*86400)/86400<instance.parameters.ordersageActive then
			if lns[i]~=nil then
				if lns[i][4]>0 then
					corenow=core.host:execute("convertTime", core.TZ_LOCAL, core.TZ_SERVER, core.now());
					if os.difftime(corenow, lns[i][2])<instance.parameters.ordersageActive then
						flag4=1;
					else
						-- an active order has just become obsolete
						dbgOrder("an active order has just become obsolete: ",lns[i]);
						flag4=0;
					end
				elseif lns[i][4]<0 then
					if instance.parameters.ordersagePassed>0 then
						corenow=core.host:execute("convertTime", core.TZ_LOCAL, core.TZ_SERVER, core.now());
						if os.difftime(corenow, lns[i][2])<instance.parameters.ordersagePassed then
							flag4=1;
						else
							-- an old order has just become obsolete
							dbgOrder("an old order has just become obsolete: ",lns[i]);
							flag4=0;
						end
					else
						dbgOrder("hiding old order because ordersagePassed=0 ",lns[i]);
						flag4=0;
					end
				else
					flag4=1;
				end
				if flag4~=0 then
					xfind=core.findDate(source, lns[i][2], false); -- the index of the candle when this order appeared
					if xfind>=source:first() then
						dfrom=lns[i][2];
						prc3=tonumber(lns[i][3]);
						if lns[i][1]=="BUY" then
							lnAboveFirst=pricelinepos(bid.high[xfind],bid.low[xfind],prc3);
						elseif lns[i][1]=="SELL" then
							lnAboveFirst=pricelinepos(ask.high[xfind],ask.low[xfind],prc3);
						else
							lnAboveFirst=pricelinepos((bid.high[xfind]+ask.high[xfind])/2.0,(bid.low[xfind]+ask.low[xfind])/2.0,prc3);
						end
						if lnAboveFirst>0 then
							-- the "xfind" candle is entirely above horiz line
							dto=source:date(LastPeriod); -- assume that will draw up to the last candle
							pricehit=0;
							for x=xfind+1, LastPeriod, 1 do
								-- scan the rest of the source stream to see if the x-th source candle breaks below the horiz line
								if lns[i][1]=="BUY" then
									xslow=bid.low[x];
								elseif lns[i][1]=="SELL" then
									xslow=ask.low[x];
								else
									xslow=(bid.low[x]+ask.low[x])/2.0;
								end
								if xslow<=prc3 then -- or source.high[x]<=prc3 then
									-- since the price crossed the horiz line, this order is no longer an active order.
									if instance.parameters.ordersagePassed>0 then
										-- line ends here
										dto=source:date(x);
										-- also, now this order has to be tested against the rules for old orders.
										corenow=core.host:execute("convertTime", core.TZ_LOCAL, core.TZ_SERVER, core.now());
										if os.difftime(corenow, lns[i][2])>=instance.parameters.ordersagePassed then
											-- Seems this old order has to be purged.
											if lns[i][4]>0 then
												sdbg="An active order has just became old and purgeable:";
											else
												sdbg="An old order has become purgeable:";
											end
											dbgOrder(sdbg,lns[i]);
											lns[i]=nil;
										else
											if lns[i][4]>0 then
												sdbg="An active order has become old but not old enough yet to be purged:";
											else
												sdbg="An old order is still old (duh) but not old enough yet to be purged:";
											end
											dbgOrder(sdbg,lns[i]);
											-- ... but not old enough yet to be purged.
											lns[i][4]=-1; 
										end
									else
										-- immediately hide the order as soon as it has been fulfilled
										lns[i]=nil;
									end
									pricehit=1;
									break;
								end
							end
							if lns[i]~=nil then
								if lns[i][4]==0 then
									lns[i][4]=1;
								end
								if pricehit==0 and lns[i][4]>0 then
									corenow=core.host:execute("convertTime", core.TZ_LOCAL, core.TZ_SERVER, core.now());
									dbgOrder("active order. But is it enough old to be purged ?os.difftime=" .. tostring(os.difftime(corenow, lns[i][2])), lns[i]);
									if os.difftime(corenow, lns[i][2])>=instance.parameters.ordersageActive then
										dbgOrder("yup. the active order is old enough to be purged:", lns[i]);
										lns[i]=nil;
									end
								end
								if lns[i]~=nil then
									j=j+1;
									if lns[i][4]<0 then
										if instance.parameters.lblOldOrd==true then
											dbgOrder("hiding label for old order ",lns[i]);
											slblOldOrd=nil;
										else
											slblOldOrd=lns[i][1];
										end
									else
										slblOldOrd=lns[i][1];
									end
									DrawLine(idBase+j,lns[i][1],dfrom,dto,prc3,slblOldOrd); -- DrawLine(id,ordtyp,dfrom,dto,ordprice)
								end
							end
						elseif lnAboveFirst<0 then
							-- the "xfind" candle is entirely below horiz line
							dto=source:date(LastPeriod); -- assume that will draw up to the last candle
							pricehit=0;
							for x=xfind+1, LastPeriod, 1 do
								-- scan the rest of the source stream to see if the x-th source candle breaks above the horiz line
								if lns[i][1]=="BUY" then
									xshigh=bid.high[x];
								elseif lns[i][1]=="SELL" then
									xshigh=ask.high[x];
								else
									xshigh=(bid.high[x]+ask.high[x])/2.0;
								end
								if xshigh>=prc3 then -- or source.low[x]>=prc3 then
									if instance.parameters.ordersagePassed>0 then
										-- line ends here
										-- since the price crossed the horiz line, this order is no longer an active order.
										dto=source:date(x);
										-- also, now this order has to be tested against the rules for old orders.
										corenow=core.host:execute("convertTime", core.TZ_LOCAL, core.TZ_SERVER, core.now());
										if os.difftime(corenow, lns[i][2])>=instance.parameters.ordersagePassed then
											-- Seems this old order has to be purged.
											if lns[i][4]>0 then
												sdbg="An active order has just became old and purgeable:";
											else
												sdbg="An old order has become purgeable:";
											end
											dbgOrder(sdbg,lns[i]);
											lns[i]=nil;
										else
											if lns[i][4]>0 then
												sdbg="An active order has become old but not old enough yet to be purged:";
											else
												sdbg="An old order is still old (duh) but not old enough yet to be purged:";
											end
											dbgOrder(sdbg,lns[i]);
											-- ... but not old enough yet to be purged.
											lns[i][4]=-1; 
										end
									else
										-- immediately hide the order as soon as it has been fulfilled
										lns[i]=nil;
									end
									pricehit=1;
									break;
								end
							end
							if lns[i]~=nil then
								if lns[i][4]==0 then
									lns[i][4]=1;
								end
								if pricehit==0 and lns[i][4]>0 then
									corenow=core.host:execute("convertTime", core.TZ_LOCAL, core.TZ_SERVER, core.now());
									dbgOrder("active order. But is it enough old to be purged ?os.difftime=" .. tostring(os.difftime(corenow, lns[i][2])), lns[i]);
									if os.difftime(corenow, lns[i][2])>=instance.parameters.ordersageActive then
										dbgOrder("yup. the active order is old enough to be purged:", lns[i]);
										lns[i]=nil;
									end
								end
								if lns[i]~=nil then
									j=j+1;
									if lns[i][4]<0 then
										if instance.parameters.lblOldOrd==true then
											dbgOrder("hiding label for old order ",lns[i]);
											slblOldOrd=nil;
										else
											slblOldOrd=lns[i][1];
										end
									else
										slblOldOrd=lns[i][1];
									end
									DrawLine(idBase+j,lns[i][1],dfrom,dto,prc3,slblOldOrd); -- DrawLine(id,ordtyp,dfrom,dto,ordprice)
								end
							end
						else
							-- seems that the order was crossed at its very inception. Cannot draw a 1-candle-long horizontal line.
							dbgOrder("seems that the order was crossed by a candle at its very inception. Cannot draw a 1-candle-long horizontal line.", lns[i]);
							lns[i]=nil;
						end
					end
				else
					lns[i]=nil;
				end
			end
		end
   end 
end

function pricelinepos(shigh,slow,prc)
-- returns +1 if the candle [slow,shigh] is entirely above the price
-- returns -1 if entirely below
-- returns 0 otherwise (crossed the price)
	if slow>prc then
		return 1; -- price above the line
	elseif shigh<prc then
		return -1; -- price below the line
	else
		return 0; -- price crossed the line
	end
end

function DrawLine(id,ordtyp,dfrom,dto,ordprice,oldOrdTag)
	local clr,thck,styl,flag;
	flag=0;
	if ordtyp=="BUY" and instance.parameters.buythick>0 then
		clr=instance.parameters.buyclr;
		thck=instance.parameters.buythick;
		styl=instance.parameters.buystyle;
		flag=1;
	elseif ordtyp=="SELL" and instance.parameters.sellthick>0 then
		clr=instance.parameters.sellclr;
		thck=instance.parameters.sellthick;
		styl=instance.parameters.sellstyle;
		flag=1;
	elseif ordtyp=="OPT" and instance.parameters.optthick>0 then
		clr=instance.parameters.optclr;
		thck=instance.parameters.optthick;
		styl=instance.parameters.optstyle;
		flag=1;
	end
	if flag>0 then
		core.host:execute("drawLine", id, dfrom, ordprice, dto, ordprice, clr, styl, thck);
		if oldOrdTag~=nil then
			if HPos==core.CR_CHART then
				xHPos=dfrom;
			else
				xHPos=0;
			end
			--               ("drawLabel1", id, x,    xType,  y,        yType,      halign, valign, font, color, text)
			core.host:execute("drawLabel1", id, xHPos, HPos, ordprice, core.CR_CHART, lbHalign, VPos2, font, clr, ordtyp .. " " .. tostring(ordprice));
		end
	end
end

function clearLines()
	-- dbg("clearing all lines");
	local i;
	for i = idBase, idBase+999, 1 do
		core.host:execute ("removeLine", i);
		core.host:execute ("removeLabel", i);
	end
end

function ReleaseInstance()
	clearLines();
    core.host:execute("deleteFont", font);
end

function Split(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end



function dbg(msg)
	if instance.parameters.dbgind then
		if msg == nil then
			msg="nil";
		elseif #msg==0 then
			msg="''";
		end
		core.host:trace(msg);
	end
end

function dbgValue(var)
	if var ~= nil then
		return tostring(var);
	else
		return "nil";
	end
end

function dbgDateValue(var)
	if var ~= nil then
		local t=core.dateToTable (var);
		return t.year .. "-" .. t.month .. "-" .. t.day .. " " .. t.hour .. ":" .. t.min .. ":" .. t.sec;
	else
		return "nil";
	end
end

function dbgPrice(src,period)
	if src:isBar() then
		return "OHLC=" .. src.open[period] .. ", H=" .. src.high[period] .. ", L=" .. src.low[period] ..
			", C=" .. src.close[period];
	else
		return "Tick=" .. src[period];
	end
end

function dbgOrder(msg,T)
-- expected parameters: lns[i]
	if T~=nil then
		local i4;
		if T[4]==0 then
			i4="undetermined";
		elseif T[4]>0 then
			i4="active";
		else
			i4="old";
		end
		dbg(msg .. string.upper(T[1]) .. "," .. dbgDateValue(T[2]) .. "," .. dbgValue(T[3]) .. "," .. i4); 
	end
end
