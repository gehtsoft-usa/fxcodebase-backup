//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=160164#p160164

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict

#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>

#define EANAME "SDZ_EA"

input string custom_indicator = "Supply-Demand-Zones-b600";

//==========  Entry Settings  ==========
input int     forced_tf            = 0;
input bool    draw_zones           = true;
input bool    solid_zones          = true;
input bool    solid_retouch        = true;
input bool    recolor_retouch      = true;
input bool    recolor_weak_retouch = true;
input bool    zone_strength        = true;
input bool    no_weak_zones        = true;
input bool    draw_edge_price      = true;
input color   edge_price_color     = White;
input int     zone_width           = 1;
input bool    zone_fibs            = false;
input int     fib_style            = 0;
input bool    HUD_on               = false;
input bool    timer_on             = false;
input int     layer_zone           = 0;
input int     layer_HUD            = 20;
input int     corner_HUD           = 2;
input int     pos_x                = 100;
input int     pos_y                = 20;
input bool    alert_on             = true;
input bool    alert_popup          = false;
input string  alert_sound          = "alert.wav";
input color   color_sup_strong     = IndianRed;
input color   color_sup_weak       = Olive;
input color   color_sup_retouch    = Aqua;
input color   color_dem_strong     = SteelBlue;
input color   color_dem_weak       = LightSteelBlue;
input color   color_dem_retouch    = Lime;
input color   color_fib            = DodgerBlue;
input color   color_HUD_tf         = White;
input color   color_arrow_up       = SeaGreen;
input color   color_arrow_dn       = Crimson;
input color   color_timer_back     = DarkGray;
input color   color_timer_bar      = Red;
input color   color_shadow         = DarkSlateGray;

#define CUSTOM_INDICATOR_PARAMS forced_tf, draw_zones, solid_zones, solid_retouch, recolor_retouch, recolor_weak_retouch, zone_strength, no_weak_zones, draw_edge_price, edge_price_color, zone_width, zone_fibs, fib_style, HUD_on, timer_on, layer_zone, layer_HUD, corner_HUD, pos_x, pos_y, alert_on, alert_popup, alert_sound, color_sup_strong, color_sup_weak, color_sup_retouch, color_dem_strong, color_dem_weak, color_dem_retouch, color_fib, color_HUD_tf, color_arrow_up, color_arrow_dn, color_timer_back, color_timer_bar, color_shadow

enum cOpposite
  {
   oppc0 = 0,           // false
   oppc1 = 1            // true
  };
enum eOpposite
  {
   oppe0 = 0,           // false
   oppe1 = 1            // true
  };

enum closeAllBy
  {
   off = 0,             // Off
   pipClose = 1,        // Pip/point (as set in "Pip/Point Mode" setting)
   currency = 2,        // Deposit currency
   percentage = 3       // Percentage of the equity
  };
  enum cMode
    {
     pips = 0,            // Pips
     points = 1           // Points
    };
  enum globalPL
    {
     live = 0,            // Running
     liveGrid = 2,        // Running and closed (from the first opened)
    };
  enum trailingAndBe
    {
     disabled = 0,                             // Off
     normal = 1                                // On
    };
  enum partialClose
    {
     disabledPC = 0,                             // Off
     normalPC = 1                                // On
    };

    enum lMode
    {
     lotMoney = 0,                             // Money (depends on exact SL value)
     lotAccountPercent = 1,                    // Percent of equity (depends on exact SL value)
     lotAccountBalance = 2,                    // Percent of balance (depends on exact SL value)
     lotFixLots = 3,                           // Fixed lots
     lotMoneyMargin = 4,                       // Money / margin requirement
     lotPercentMargin = 5                      // Percent / margin requirement
    };
  enum slMode
    {
     slOff = 0,                                // Don't use (depends on fixed or margin determined lots)
     slMoney = 1,                              // Money (depends on fixed or margin determined lots)
     slAccountPercent = 2,                     // Percent of equity (depends on fixed or margin determined lots)
     slFix = 3,                                // Pip/point (as set in "Pip/Point Mode" setting)
     slAbsolute = 4,                           // Absolute Value (for buy = value, for sell = value 2)
     slATR = 5,                                // ATR (period = value, multiplicator = value 2)
     slBars = 6,                               // Highest/lowest of (value) bars, +/- (value 2) offset pip/point
     slIndicator = 8,                          // Indicator value, +/- (value) offset pip/point
     slPricePercent = 7                        // Percent of price
    };
  enum tpMode
    {
     tpOff = 0,                                // Don't use (depends on fixed or margin determined lots)
     tpMoney = 1,                              // Money (depends on fixed or margin determined lots)
     tpAccountPercent = 2,                     // Percent of equity (depends on fixed or margin determined lots)
     tpFix = 3,                                // Pip/point (as set in "Pip/Point Mode")
     tpPricePercent = 7,                       // Percent of price
     tpAbsolute = 4,                           // Absolute Value (for buy = value, for sell = value 2)
     tpATR = 5,                                // ATR (period = value, multiplicator = value 2)
     tpBars = 6,                               // Highest /lowest of (value) bars, +/- (value 2) offset pip/point
     tpIndicator = 8,                          // Indicator value, +/- (value) offset pip/point
     tpSlRatio = 100                           // Stop loss distance ratio (R:R)
    };

  enum entlogic
  {
   Direct = 0,
   Reversal = 1
  };
enum ENUM_timeZone
  {
   timeGMT = 0,                              // GMT
   timeLocal = 1,                            // Local
   timeCurrent = 2                           // Server
  };
enum ModeEntry
  {
   Market
  };

//==========  EA Settings  ==========
input string inpEAName = EANAME;             // Custom comment / EA name (max. 16 characters)
string EAName = StringSubstr(inpEAName, 0, 15);
string currentZoneName = ""; // Global variable to store current zone name

input int slp = 30;                          // Slippage in points
input cMode calcMode = 0;                    // Pip/Point mode (for SL, TP, etc.)
input int MagicNumber = 3535;                // Magic number
input bool ecn_broker = false;               // ECN Broker?
input bool alertAlgoOff = true;              // Alert when signal but Auto Trading off
int whenOpen = 0;
int posDir = 0;
input cOpposite closeAtOpposite = true;        // Close position at opposite signal
ModeEntry modeEntry = Market;
bool deletePendingOnCloseAll = false;
int maxPos = 2;                                // Maximum number of positions
int maxSellPos = 1;                            // Maximum number of sell positions
int maxBuyPos = 1;                             // Maximum number of buy positions

//==========  Position Size Settings  ==========
input lMode lotMode = lotFixLots;             // Lot calculation mode
input double Lot = 0.01;                      // Lot value (as set in "Lot calculation mode")
input double maxLot = 1.00;                   // Maximum size of lots (All positions)

//==========  SL / TP Settings  ==========
input slMode SlMode = slIndicator;            // SL by
input double SlVal = 40;                      // SL value
input double SlVal2 = 1;                     // SL value 2 (if required in the "SL by" setting
input double SlMin = 10;                     // Min SL distance pip/point (as set in "Pip/Point mode")
input tpMode TpMode = tpIndicator;            // TP by
input double TpVal = 40;                      // TP value
input double TpVal2 = 1;                     // TP value 2 (if required in the "TP by" setting)
input double TpMin = 10;                     // Min TP distance pip/point (as set in "Pip/Point mode")
input bool addSpread = true;                 // Add current spread to SL/TP calculation

//==========  Trailing Stop  ==========
input trailingAndBe trailing_sl = disabled;   // Trailing stop
input double trailing_stop_start = 20;        // Trailing stop start
input double trailing_stop_dist = 40;         // Trailing stop distance
input double trailing_stop_step = 5;          // Trailing stop step

//==========  Breakeven ==========
input trailingAndBe be = disabled;            // Breakeven
input double be_trigger = 10;                 // Breakeven trigger
input double be_level = 0;                    // Breakeven level

bool initOK = true;
string symbols[];

int   globalCalcMode = 0;
bool  trade = true;

CTrade m_trade;
int    indHandle = INVALID_HANDLE;
CPositionInfo m_position;

double GetATR(const string sym, ENUM_TIMEFRAMES tf, int period, int shift){
   int handle = iATR(sym, tf, period);
   if(handle==INVALID_HANDLE) return 0.0;
   double buf[];
   int copied = CopyBuffer(handle,0,shift,1,buf);
   double v = (copied>0 ? buf[0] : 0.0);
   IndicatorRelease(handle);
   return v;
}

//----------------- Helpers -----------------
int DigitsOf(const string sym){
   int d=(int)SymbolInfoInteger(sym,SYMBOL_DIGITS);
   return d;
}

double PointOf(const string sym){
   double p=SymbolInfoDouble(sym,SYMBOL_POINT);
   return p;
}

double pip(const string sy){
   string s = (sy==""? _Symbol : sy);
   double po = PointOf(s);
   int di   = DigitsOf(s);
   if(calcMode==points) return po;
   return (di%2==1 ? po*10.0 : po);
}

int multi(const string sy){
   string s = (sy==""? _Symbol : sy);
   if(calcMode==points) return 1;
   int di=DigitsOf(s);
   return (di%2==1 ? 10 : 1);
}

bool IsNewBar(){
   static datetime lastbar=0;
   datetime curbar=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
   if(lastbar!=curbar){ lastbar=curbar; return true; }
   return false;
}

int ObjectsTotalAll(){
   return (int)ObjectsTotal(ChartID(),0,-1);
}

string ObjectNameByIndex(const int index){
   string name = ObjectName(ChartID(),index,0);
   return name;
}

int ObjectTypeOf(const string name){
   if(ObjectFind(ChartID(),name)==-1) return -1;
   return (int)ObjectGetInteger(ChartID(),name,OBJPROP_TYPE);
}

double ObjectPrice1(const string name){
   if(ObjectFind(ChartID(),name)==-1) return 0.0;
   if(ObjectTypeOf(name)==OBJ_ARROW_RIGHT_PRICE)
      return ObjectGetDouble(ChartID(),name,OBJPROP_PRICE,0);
   return ObjectGetDouble(ChartID(),name,OBJPROP_PRICE,0);
}

double ObjectRectPrice1(const string name){
   if(ObjectFind(ChartID(),name)==-1) return 0.0;
   return ObjectGetDouble(ChartID(),name,OBJPROP_PRICE,0);
}

double ObjectRectPrice2(const string name){
   if(ObjectFind(ChartID(),name)==-1) return 0.0;
   return ObjectGetDouble(ChartID(),name,OBJPROP_PRICE,1);
}

datetime ObjectTime1(const string name){
   if(ObjectFind(ChartID(),name)==-1) return 0;
   return (datetime)ObjectGetInteger(ChartID(),name,OBJPROP_TIME,0);
}

// Find current zone bounds from indicator MQ5
bool FindCurrentZoneBounds(const double currentPrice, double &lower, double &upper, bool &isSupply){
   lower=0.0; upper=0.0; isSupply=false;
   int total=ObjectsTotalAll();
   for(int i=0;i<total;i++){
      string obj = ObjectNameByIndex(i);
      if(StringFind(obj,"aII_SupDem"+(string)Period()+"UPZONE",0)>=0 || StringFind(obj,"aII_SupDem"+(string)Period()+"DNZONE",0)>=0){
         if(ObjectTypeOf(obj)==OBJ_RECTANGLE){
            double p1 = ObjectRectPrice1(obj);
            double p2 = ObjectRectPrice2(obj);
            double lo = MathMin(p1,p2);
            double hi = MathMax(p1,p2);
            if(currentPrice>=lo && currentPrice<=hi){
               lower = lo;
               upper = hi;
               isSupply = (StringFind(obj,"UPZONE",0)>=0);
               return true;
            }
         }
      }
   }
   return false;
}

double findNextDemandZone(const double currentPrice){
   double nearest=0.0, minDist=DBL_MAX;
   int total=ObjectsTotalAll();
   for(int i=0;i<total;i++){
      string obj=ObjectNameByIndex(i);
      if(StringFind(obj,"aII_SupDem"+(string)Period()+"DNZONE",0)>=0){
         if(ObjectTypeOf(obj)==OBJ_RECTANGLE){
            double up = ObjectRectPrice1(obj);
            double lo = ObjectRectPrice2(obj);
            if(up<lo){ double t=up; up=lo; lo=t; }
            if(up<currentPrice){
               double d=currentPrice-up;
               if(d<minDist){ minDist=d; nearest=up; }
            }
         }
      }
   }
   return nearest;
}

double findNextSupplyZone(const double currentPrice){
   double nearest=0.0, minDist=DBL_MAX;
   int total=ObjectsTotalAll();
   for(int i=0;i<total;i++){
      string obj=ObjectNameByIndex(i);
      if(StringFind(obj,"aII_SupDem"+(string)Period()+"UPZONE",0)>=0){
         if(ObjectTypeOf(obj)==OBJ_RECTANGLE){
            double up = ObjectRectPrice1(obj);
            double lo = ObjectRectPrice2(obj);
            if(up<lo){ double t=up; up=lo; lo=t; }
            if(lo>currentPrice){
               double d=lo-currentPrice;
               if(d<minDist){ minDist=d; nearest=lo; }
            }
         }
      }
   }
   return nearest;
}

// Has zone been traded (based on position + history orders)
bool hasZoneBeenTraded(const string zoneName){
   if(ObjectTypeOf(zoneName)!=OBJ_RECTANGLE) return false;
   double p1=ObjectRectPrice1(zoneName);
   double p2=ObjectRectPrice2(zoneName);
   double upper=MathMax(p1,p2);
   double lower=MathMin(p1,p2);
   datetime startTime=ObjectTime1(zoneName);
   double tol=PointOf(_Symbol);

   // open positions
   int total=(int)PositionsTotal();
   for(int i=0;i<total;i++){
      if(m_position.SelectByIndex(i)){
         string s=m_position.Symbol();
         long mg=m_position.Magic();
         if(s==_Symbol && mg==MagicNumber){
            double sl=m_position.StopLoss();
            datetime opent=(datetime)m_position.Time();
            if(opent>=startTime && (MathAbs(sl-lower)<tol || MathAbs(sl-upper)<tol))
               return true;
         }
      }
   }
   // history orders
   HistorySelect(startTime,TimeCurrent());
   int htot=(int)HistoryOrdersTotal();
   for(int j=0;j<htot;j++){
      ulong ticket=HistoryOrderGetTicket(j);
      string s=(string)HistoryOrderGetString(ticket,ORDER_SYMBOL);
      long mg=(long)HistoryOrderGetInteger(ticket,ORDER_MAGIC);
      if(s==_Symbol && mg==MagicNumber){
         double sl=(double)HistoryOrderGetDouble(ticket,ORDER_SL);
         if(MathAbs(sl-lower)<tol || MathAbs(sl-upper)<tol) return true;
      }
   }
   return false;
}

double calcLot(const int dir, const string sym, const double priceLotVal){
   string s=sym;
   double tickValue = SymbolInfoDouble(s,SYMBOL_TRADE_TICK_VALUE);
   double step      = SymbolInfoDouble(s,SYMBOL_VOLUME_STEP);
   double poi       = PointOf(s);
   double ask       = SymbolInfoDouble(s,SYMBOL_ASK);
   double bid       = SymbolInfoDouble(s,SYMBOL_BID);
   double minlot    = SymbolInfoDouble(s,SYMBOL_VOLUME_MIN);
   double maxlot    = SymbolInfoDouble(s,SYMBOL_VOLUME_MAX);
   double marginReq = MathMax(SymbolInfoDouble(s,SYMBOL_MARGIN_INITIAL),0.001);
   if(marginReq<=0.0){ double mr=0.0; if(!SymbolInfoDouble(s,SYMBOL_MARGIN_INITIAL,mr)) mr=0.001; marginReq=MathMax(mr,0.001); }
   double maxlotMargin = (AccountInfoDouble(ACCOUNT_EQUITY)/marginReq)*0.95;
   double final_lot=minlot;
   double distance=0.0, risk=0.0;

   if(dir==0){ final_lot = priceLotVal; }
   if(dir==1 || dir==2){
      if(dir==1) distance = (ask - priceLotVal)/poi;
      if(dir==2) distance = (priceLotVal - bid)/poi;
      if(lotMode==lotMoney){ risk=fabs(Lot); final_lot=risk/distance/tickValue; }
      if(lotMode==lotAccountPercent){ risk=AccountInfoDouble(ACCOUNT_EQUITY)*Lot/100.0; final_lot=risk/distance/tickValue; }
      if(lotMode==lotAccountBalance){ risk=AccountInfoDouble(ACCOUNT_BALANCE)*Lot/100.0; final_lot=risk/distance/tickValue; }
      if(lotMode==lotFixLots){ final_lot=Lot; }
      if(lotMode==lotMoneyMargin){ final_lot=Lot/marginReq; }
      if(lotMode==lotPercentMargin){ final_lot=(AccountInfoDouble(ACCOUNT_EQUITY)*Lot/100.0)/marginReq; }
   }
   final_lot = MathMin(final_lot, maxLot);
   final_lot = MathMin(final_lot, maxlotMargin);
   final_lot = MathMax(final_lot, minlot);
   final_lot = MathMin(final_lot, maxlot);
   final_lot = MathRound(final_lot/step)*step;
   return final_lot;
}

double calcSL(const int dir, const double p, const string sym, const double lot){
   int dig=DigitsOf(sym);
   double sLevel = (double)SymbolInfoInteger(sym,SYMBOL_TRADE_STOPS_LEVEL);
   double poi    = PointOf(sym);
   double spread = (SymbolInfoDouble(sym,SYMBOL_ASK)-SymbolInfoDouble(sym,SYMBOL_BID))/poi;
   double tickval = SymbolInfoDouble(sym,SYMBOL_TRADE_TICK_VALUE);
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double val=0.0; int bar=0; double aSpread=0.0;
   if(addSpread) aSpread = spread*poi;

   if(SlMode==slMoney){
      val = MathMax(((SlVal*pip(sym))/(tickval*Lot)), (sLevel+spread+slp)*poi); val=MathMax(SlMin*pip(sym),val)+aSpread;
      if(dir==1) return NormalizeDouble(p-val,dig); if(dir==2) return NormalizeDouble(p+val,dig);
   }
   if(SlMode==slAccountPercent){
      val = MathMax((((eq*SlVal*0.01)*pip(sym))/(tickval*Lot)), (sLevel+spread+slp)*poi); val=MathMax(SlMin*pip(sym),val)+aSpread;
      if(dir==1) return NormalizeDouble(p-val,dig); if(dir==2) return NormalizeDouble(p+val,dig);
   }
   if(SlMode==slFix){
      val = MathMax(SlVal*multi(sym), sLevel+spread+slp)*poi; val=MathMax(SlMin*pip(sym),val)+aSpread;
      if(dir==1) return NormalizeDouble(p-val,dig); if(dir==2) return NormalizeDouble(p+val,dig);
   }
   if(SlMode==slAbsolute){
      if(dir==1) return NormalizeDouble(MathMin(SlVal, p - SlMin*pip(sym)),dig);
      if(dir==2) return NormalizeDouble(MathMax(SlVal, p + SlMin*pip(sym)),dig);
   }
   if(SlMode==slATR){
      val = MathMax(GetATR(sym,(ENUM_TIMEFRAMES)_Period,(int)SlVal,1)*SlVal2,(sLevel+spread+slp)*poi); val=MathMax(SlMin*pip(sym),val)+aSpread;
      if(dir==1) return NormalizeDouble(p-val,dig); if(dir==2) return NormalizeDouble(p+val,dig);
   }
   if(SlMode==slBars){
      if(dir==1){ int b=iLowest(sym,_Period,MODE_LOW,(int)SlVal,0); val=MathMin(p-MathMax((sLevel+spread+slp)*poi,SlMin*pip(sym)), (iLow(sym,_Period,b)+aSpread)-SlVal2*pip(sym)-spread*poi); return NormalizeDouble(val,dig);} 
      if(dir==2){ int b=iHighest(sym,_Period,MODE_HIGH,(int)SlVal,0); val=MathMax(p+MathMax((sLevel+spread+slp)*poi,SlMin*pip(sym)), (iHigh(sym,_Period,b)+aSpread)+SlVal2*pip(sym)+spread*poi); return NormalizeDouble(val,dig);} 
   }
   if(SlMode==slPricePercent){
      val = MathMax((p*(SlVal/100.0))*pip(sym), sLevel+spread+slp)*poi; val=MathMax(SlMin*pip(sym),val)+aSpread;
      if(dir==1) return NormalizeDouble(p-val,dig); if(dir==2) return NormalizeDouble(p+val,dig);
   }
   if(SlMode==slIndicator){
      // Lấy biên vùng hiện tại thay vì buffer indicator
      double lo=0.0, hi=0.0; bool isSup=false; double cp=(SymbolInfoDouble(sym,SYMBOL_BID)+SymbolInfoDouble(sym,SYMBOL_ASK))/2.0;
      if(FindCurrentZoneBounds(cp,lo,hi,isSup)){
         if(dir==1) return NormalizeDouble(lo - SlVal*pip(sym) - aSpread, dig);
         if(dir==2) return NormalizeDouble(hi + SlVal*pip(sym) + aSpread, dig);
      }
   }
   return 0.0;
}

double calcTP(const int dir, const double p, const string sym, const double lot, const double slprice){
   int dig=DigitsOf(sym);
   double sLevel = (double)SymbolInfoInteger(sym,SYMBOL_TRADE_STOPS_LEVEL);
   double poi    = PointOf(sym);
   double spread = (SymbolInfoDouble(sym,SYMBOL_ASK)-SymbolInfoDouble(sym,SYMBOL_BID))/poi;
   double tickval = SymbolInfoDouble(sym,SYMBOL_TRADE_TICK_VALUE);
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double val=0.0; double aSpread=0.0; if(addSpread) aSpread=spread*poi;

   if(TpMode==tpMoney){ val=MathMax(((TpVal*pip(sym))/(tickval*Lot)),(sLevel+spread+slp)*poi); val=MathMax(TpMin*pip(sym),val)+aSpread; if(dir==1) return NormalizeDouble(p+val,dig); if(dir==2) return NormalizeDouble(p-val,dig);} 
   if(TpMode==tpAccountPercent){ val=MathMax((((eq*TpVal*0.01)*pip(sym))/(tickval*Lot)),(sLevel+spread+slp)*poi); val=MathMax(TpMin*pip(sym),val)+aSpread; if(dir==1) return NormalizeDouble(p+val,dig); if(dir==2) return NormalizeDouble(p-val,dig);} 
   if(TpMode==tpFix){ val=MathMax(TpVal*multi(sym), sLevel+spread+slp)*poi; val=MathMax(TpMin*pip(sym),val)+aSpread; if(dir==1) return NormalizeDouble(p+val,dig); if(dir==2) return NormalizeDouble(p-val,dig);} 
   if(TpMode==tpAbsolute){ if(dir==1) return NormalizeDouble(TpVal,dig); if(dir==2) return NormalizeDouble(TpVal2,dig);} 
   if(TpMode==tpATR){ val=MathMax(GetATR(sym,(ENUM_TIMEFRAMES)_Period,(int)TpVal,1)*TpVal2,(sLevel+spread+slp)*poi); val=MathMax(TpMin*pip(sym),val+aSpread); if(dir==1) return NormalizeDouble(p+val,dig); if(dir==2) return NormalizeDouble(p-val,dig);} 
   if(TpMode==tpBars){ if(dir==1){ int b=iHighest(sym,_Period,MODE_HIGH,(int)TpVal,0); val=MathMax(p+MathMax((sLevel+spread+slp)*poi,TpMin*pip(sym)), (iHigh(sym,_Period,b)+aSpread)+TpVal2*pip(sym)+spread*poi); return NormalizeDouble(val,dig);} if(dir==2){ int b=iLowest(sym,_Period,MODE_LOW,(int)TpVal,0); val=MathMin(p-MathMax((sLevel+spread+slp)*poi,TpMin*pip(sym)), (iLow(sym,_Period,b)+aSpread)-TpVal2*pip(sym)-spread*poi); return NormalizeDouble(val,dig);} }
   if(TpMode==tpPricePercent){ val=MathMax((p*(TpVal/100.0))*pip(sym), sLevel+spread+slp)*poi; val=MathMax(TpMin*pip(sym),val)+aSpread; if(dir==1) return NormalizeDouble(p+val,dig); if(dir==2) return NormalizeDouble(p-val,dig);} 
   if(TpMode==tpIndicator){
      double lo=0.0, hi=0.0; bool isSup=false; double cp=(SymbolInfoDouble(sym,SYMBOL_BID)+SymbolInfoDouble(sym,SYMBOL_ASK))/2.0;
      if(FindCurrentZoneBounds(cp,lo,hi,isSup)){
         if(dir==1) return NormalizeDouble(hi, dig);
         if(dir==2) return NormalizeDouble(lo, dig);
      }
   }
   if(TpMode==tpSlRatio && slprice>0.0){ if(dir==1) return NormalizeDouble(p + (p-slprice)*TpVal, dig); if(dir==2) return NormalizeDouble(p - (slprice-p)*TpVal, dig);} 
   return 0.0;
}

int numberOfPositions(const int dir, const string sym, const int fp=0, const bool pending=false){
   int countPos=0; int total=(int)PositionsTotal();
   for(int i=0;i<total;i++){
      if(m_position.SelectByIndex(i)){
         string s=m_position.Symbol();
         long mg=m_position.Magic();
         if((s==sym || sym=="") && mg==MagicNumber){
            long type=m_position.PositionType();
            string cmt=m_position.Comment();
            bool ok_fp = (fp==0 || StringFind(cmt, "_ip("+(string)fp+")",0)>=0);
            if(!ok_fp) continue;
            if(type==POSITION_TYPE_BUY && (dir==1 || dir==0)) countPos++;
            if(type==POSITION_TYPE_SELL && (dir==2 || dir==0)) countPos++;
         }
      }
   }
   return countPos;
}

datetime lastOpenedPosition(const int dir, const string sym){
   datetime maxDate=0; int total=(int)PositionsTotal();
   for(int i=0;i<total;i++){
      if(m_position.SelectByIndex(i)){
         string s=m_position.Symbol();
         long mg=m_position.Magic();
         if((s==sym || sym=="") && mg==MagicNumber){
            long type=m_position.PositionType();
            datetime openT=(datetime)m_position.Time();
            if(type==POSITION_TYPE_BUY && (dir==1 || dir==0)) maxDate=MathMax(maxDate,openT);
            if(type==POSITION_TYPE_SELL && (dir==2 || dir==0)) maxDate=MathMax(maxDate,openT);
         }
      }
   }
   return maxDate;
}

datetime posLastOpened(const string sym, const int fp=0, const int dir=0){
   datetime maxDate=0; int total=(int)PositionsTotal();
   for(int i=0;i<total;i++){
      if(m_position.SelectByIndex(i)){
         string s=m_position.Symbol();
         long mg=m_position.Magic();
         if(s==sym && mg==MagicNumber){
            long type=m_position.PositionType();
            string cmt=m_position.Comment();
            if(dir==0 || (dir==1 && type==POSITION_TYPE_BUY) || (dir==2 && type==POSITION_TYPE_SELL)){
               if(fp==0 || StringFind(cmt, "_ip("+(string)fp+")",0)>=0){ datetime t=(datetime)m_position.Time(); maxDate=MathMax(maxDate,t); }
            }
         }
      }
   }
   return maxDate;
}

void closeAll(const int dir, const string sym, const int fp=0){
   int total=(int)PositionsTotal();
   for(int i=total-1;i>=0;i--){
      if(m_position.SelectByIndex(i)){
         string s=m_position.Symbol();
         long mg=m_position.Magic();
         if((s==sym || sym=="") && mg==MagicNumber){
            long type=m_position.PositionType();
            string cmt=m_position.Comment();
            if(fp!=0 && StringFind(cmt, "_ip("+(string)fp+")",0)<0) continue;
            if(dir==0 || (dir==1 && type==POSITION_TYPE_BUY) || (dir==2 && type==POSITION_TYPE_SELL)){
               m_trade.PositionClose(s);
            }
         }
      }
   }
}

void SetTrailingStop(){
   int total=(int)PositionsTotal();
   for(int i=0;i<total;i++){
      if(m_position.SelectByIndex(i)){
         if(m_position.Magic()!=MagicNumber) continue;
         string s=m_position.Symbol();
         int dig=DigitsOf(s); double po=PointOf(s);
         long type=m_position.PositionType();
         double open=m_position.PriceOpen();
         double sl=m_position.StopLoss();
         double tp=m_position.TakeProfit();
         double bid=SymbolInfoDouble(s,SYMBOL_BID); double ask=SymbolInfoDouble(s,SYMBOL_ASK);
         double newSL=sl;
         if(type==POSITION_TYPE_BUY){
            double tgt = MathMin(bid - trailing_stop_dist*pip(s), bid - SymbolInfoInteger(s,SYMBOL_TRADE_STOPS_LEVEL)*po);
            tgt = NormalizeDouble(tgt,dig);
            if(tgt - trailing_stop_step*pip(s) > sl && bid - open > trailing_stop_start*pip(s)) newSL = tgt;
         } else if(type==POSITION_TYPE_SELL){
            double tgt = MathMax(ask + trailing_stop_dist*pip(s), ask + SymbolInfoInteger(s,SYMBOL_TRADE_STOPS_LEVEL)*po);
            tgt = NormalizeDouble(tgt,dig);
            if(tgt + trailing_stop_step*pip(s) < (sl==0? open + trailing_stop_dist*pip(s) : sl) && open - ask > trailing_stop_start*pip(s)) newSL = tgt;
         }
         if(newSL!=sl){ m_trade.PositionModify(s,newSL,tp); }
      }
   }
}

void SetBreakeven(){
   int total=(int)PositionsTotal();
   for(int i=0;i<total;i++){
      if(m_position.SelectByIndex(i)){
         if(m_position.Magic()!=MagicNumber) continue;
         string s=m_position.Symbol();
         int dig=DigitsOf(s); double po=PointOf(s);
         long type=m_position.PositionType();
         double open=m_position.PriceOpen();
         double sl=m_position.StopLoss();
         double tp=m_position.TakeProfit();
         double bid=SymbolInfoDouble(s,SYMBOL_BID); double ask=SymbolInfoDouble(s,SYMBOL_ASK);
         double newSL=sl;
         if(type==POSITION_TYPE_BUY){
            double tgt = MathMin(open + be_level*pip(s), bid - SymbolInfoInteger(s,SYMBOL_TRADE_STOPS_LEVEL)*po);
            tgt = NormalizeDouble(tgt,dig);
            if(tgt>sl && bid>open + be_trigger*pip(s)) newSL=tgt;
         } else if(type==POSITION_TYPE_SELL){
            double tgt = MathMax(open - be_level*pip(s), ask + SymbolInfoInteger(s,SYMBOL_TRADE_STOPS_LEVEL)*po);
            tgt = NormalizeDouble(tgt,dig);
            if(tgt<sl && ask<open - be_trigger*pip(s)) newSL=tgt;
         }
         if(newSL!=sl){ m_trade.PositionModify(s,newSL,tp); }
      }
   }
}

int checkEntry(const int bar, const string sym){
   double bid=SymbolInfoDouble(sym,SYMBOL_BID); double ask=SymbolInfoDouble(sym,SYMBOL_ASK);
   double currentPrice=(bid+ask)/2.0;
   int total=ObjectsTotalAll();
   for(int i=0;i<total;i++){
      string obj=ObjectNameByIndex(i);
      if(StringFind(obj,"aII_SupDem"+(string)Period()+"UPZONE",0)>=0){
         if(ObjectTypeOf(obj)==OBJ_RECTANGLE){
            double up=ObjectRectPrice1(obj); double lo=ObjectRectPrice2(obj);
            if(up<lo){ double t=up; up=lo; lo=t; }
            if(currentPrice>=lo && currentPrice<=up && !hasZoneBeenTraded(obj)){
               double nextDemandUpper = findNextDemandZone(currentPrice);
               if(nextDemandUpper>0){
                  currentZoneName=obj;
                  // SELL
                  OP(sym,-1,0.0,0.0,(SlMode==slIndicator? up : 0.0),(TpMode==tpIndicator? nextDemandUpper : 0.0));
               }
            }
         }
      } else if(StringFind(obj,"aII_SupDem"+(string)Period()+"DNZONE",0)>=0){
         if(ObjectTypeOf(obj)==OBJ_RECTANGLE){
            double up=ObjectRectPrice1(obj); double lo=ObjectRectPrice2(obj);
            if(up<lo){ double t=up; up=lo; lo=t; }
            if(currentPrice>=lo && currentPrice<=up && !hasZoneBeenTraded(obj)){
               double nextSupplyLower = findNextSupplyZone(currentPrice);
               if(nextSupplyLower>0){
                  currentZoneName=obj;
                  // BUY
                  OP(sym,1,0.0,0.0,(SlMode==slIndicator? lo : 0.0),(TpMode==tpIndicator? nextSupplyLower : 0.0));
                  return 1;
               }
            }
         }
      }
   }
   return 0;
}

void OP(const string sym, int entrysig=0, double lot=0.0, double price=0.0, double slPrice=0.0, double tpPrice=0.0){
   if(!trade) return;
   int logic=0; string orderComment=EAName; int entrySignal;
   if(currentZoneName!=""){ orderComment += "_"+currentZoneName; currentZoneName=""; }
   int dig=DigitsOf(sym); double sLevel=(double)SymbolInfoInteger(sym,SYMBOL_TRADE_STOPS_LEVEL); double poi=PointOf(sym);
   double bid=SymbolInfoDouble(sym,SYMBOL_BID); double ask=SymbolInfoDouble(sym,SYMBOL_ASK);
   if(entrysig==0) entrySignal=checkEntry(whenOpen,sym); else entrySignal=entrysig;

   m_trade.SetExpertMagicNumber(MagicNumber);
   m_trade.SetDeviationInPoints(slp);

   // BUY
   if((entrySignal>0 && logic==0) || (entrySignal<0 && logic==1)){
      if(alertAlgoOff && !TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) Alert(EAName+": Auto Trading turned OFF");
      if(posDir==2) return;
      if(numberOfPositions(2,sym, entrySignal*(-1))>0 && closeAtOpposite==oppc1) closeAll(2,sym, entrysig*(-1));
      if(closeAtOpposite==oppc1) closeAll(2,sym);
      if((numberOfPositions(1,sym)<maxBuyPos || maxBuyPos==0) && (numberOfPositions(0,sym)<maxPos || maxPos==0) && lastOpenedPosition(1,sym)<iTime(sym,_Period,0)){
         if(numberOfPositions(0,"")==0) orderComment+="_fp";
         orderComment += "_ip("+(string)entrySignal+")#"+(string)(numberOfPositions(1,sym)+1);
         if(modeEntry==Market) price=ask;
         if(slPrice==0.0) slPrice = calcSL(1, price, sym, Lot); else slPrice = NormalizeDouble(MathMin(slPrice, ask - sLevel*poi), dig);
         if(tpPrice==0.0) tpPrice = calcTP(1, price, sym, Lot, slPrice); else tpPrice = NormalizeDouble(MathMax(tpPrice, ask + sLevel*poi), dig);
         if(lot==0.0) lot = calcLot(1, sym, slPrice); else lot = calcLot(0, sym, lot);
         price = NormalizeDouble(price,dig);
         bool ok=m_trade.Buy(lot, sym, 0.0, slPrice, tpPrice, orderComment);
         if(!ok){ Alert(EAName+": BUY failed #",(string)GetLastError()," lot:",DoubleToString(lot,2)," price:",DoubleToString(ask,dig)," sl:",DoubleToString(slPrice,dig)," tp:",DoubleToString(tpPrice,dig)); }
      }
   }

   // SELL
   if((entrySignal<0 && logic==0) || (entrySignal>0 && logic==1)){
      if(posDir==1) return;
      if(numberOfPositions(1,sym, entrySignal*(-1))>0 && closeAtOpposite==oppc1) closeAll(1,sym, entrysig*(-1));
      if(closeAtOpposite==oppc1) closeAll(1,sym);
      if((numberOfPositions(2,sym)<maxSellPos || maxSellPos==0) && (numberOfPositions(0,sym)<maxPos || maxPos==0) && lastOpenedPosition(2,sym)<iTime(sym,_Period,0)){
         if(numberOfPositions(0,"")==0) orderComment+="_fp";
         orderComment += "_ip("+(string)entrySignal+")#"+(string)(numberOfPositions(2,sym)+1);
         if(modeEntry==Market) price=bid;
         if(slPrice==0.0) slPrice = calcSL(2, price, sym, Lot); else slPrice = NormalizeDouble(MathMax(slPrice, bid + sLevel*poi), dig);
         if(tpPrice==0.0) tpPrice = calcTP(2, price, sym, Lot, slPrice); else tpPrice = NormalizeDouble(MathMin(tpPrice, bid - sLevel*poi), dig);
         if(lot==0.0) lot = calcLot(2, sym, slPrice); else lot = calcLot(0, sym, lot);
         price = NormalizeDouble(price,dig);
         bool ok=m_trade.Sell(lot, sym, 0.0, slPrice, tpPrice, orderComment);
         if(!ok){ Alert(EAName+": SELL failed #",(string)GetLastError()," lot:",DoubleToString(lot,2)," price:",DoubleToString(bid,dig)," sl:",DoubleToString(slPrice,dig)," tp:",DoubleToString(tpPrice,dig)); }
      }
   }
}

int OnInit(){
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) Alert("Automated trading is disabled in the settings.");
   EAName = StringSubstr(inpEAName,0,16);
   ArrayResize(symbols,1); symbols[0]=_Symbol;

   ResetLastError();
   indHandle = iCustom(_Symbol,_Period, custom_indicator, CUSTOM_INDICATOR_PARAMS);
   if(indHandle==INVALID_HANDLE){
      Alert("Please install the: ",custom_indicator," indicator to the MQL5/Indicators folder");
      initOK=false;
   }

   if(lotMode<lotFixLots && SlMode<slFix){
      Alert("Incompatible \"Lot calculation mode\" and \"Stop loss by\" settings. Please check dependencies.");
      initOK=false;
   }

   m_trade.SetExpertMagicNumber(MagicNumber);
   m_trade.SetDeviationInPoints(slp);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
}

void OnTick(){
   if(indHandle!=INVALID_HANDLE){ double tmp[]; CopyBuffer(indHandle,0,0,1,tmp); }
   ChartRedraw(0);
   if(!initOK) return;
   bool newBar = IsNewBar();
   int whenClose = 1;
   if((whenOpen>0 && newBar) || (whenOpen==0 && posLastOpened(_Symbol)<iTime(_Symbol,_Period,0))){
      for(int i=0;i<ArraySize(symbols);i++){
         string sym=symbols[i];
         OP(sym);
      }
   }
   if(trailing_sl>0) SetTrailingStop();
   if(be>0) SetBreakeven();
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=160164#p160164

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+