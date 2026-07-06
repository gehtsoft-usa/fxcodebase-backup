//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73311

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#define TIMER_MINI  // one session at day
#define DAILY_LIMITS
#define CLOSE_ALL_ON

double gd_unused_76 = 0.0;
double gd_unused_84 = 0.0;
double gd_unused_92 = 0.0;
extern double Lots = 0.1;
extern bool AutoLots = TRUE;
extern double Risk = 0.05;
int           magico       = 0;

#ifdef TIMER_MINI
enum enumDays { sunday,
                monday,
                tuesday,
                wednesday,
                thursday,
                friday,
                saturday,
                EA_OFF };
input string T1        = "== Trading Sessions ==";  // ————————————
input string timeStart = "00:00:00";                // Time Start GMT
input string timeEnd   = "23:59:59";                // Time End GMT

class Session
{
  int _iniTime;  // second from 00:00 hr of the day
  int _endTime;
  int _dayNumber;

 public:
  // receive time in format 00:00
  Session(string iniTime, string endTime, int dayNumber = 0)
  {
    _iniTime   = secondsFromZeroHour(iniTime);
    _endTime   = secondsFromZeroHour(endTime);
    _dayNumber = dayNumber;
  };

  ~Session() {}

  int iniTime() { return _iniTime; }
  int endTime() { return _endTime; }
  int dayNumber() { return _dayNumber; }

  int secondsFromZeroHour(string time)
  {
    int hh = (int)StringSubstr(time, 0, 2);
    int mm = (int)StringSubstr(time, 3, 2);

    return (hh * 3600) + (mm * 60);
  }
};
class ScheduleController
{
  Session* schedules[];
  int      _actualIndex;
  Session* _actualSession;
  int      _currentDay;
  double   _timeZone;  // modificador para ajustar GMT

 public:
  ScheduleController()
  {
    setCurrentDay();
  };
  ~ScheduleController()
  {
    ClearShchedules();
  }

  Session* at() { return _actualSession; }

  void setTimeZone(double hs)
  {
    _timeZone = hs * 60 * 60;
  }

  void setCurrentDay()
  {
    _currentDay = TimeDay(TimeGMT() + _timeZone);  // return the day of the month 1-31
  }

  bool isNewDay()
  {
    if (TimeDay(TimeGMT() + _timeZone) != _currentDay)
    {
      setCurrentDay();
      return true;
    }

    return false;
  }

  void setActualSession(int index)
  {
    _actualIndex = index;

    if (index > -1)
    {
      _actualSession = schedules[index];
    }
  }

  int qnt()
  {
    return ArraySize(schedules);
  }

  bool AddSession(string ini, string end, int day = 0)
  {
    Session* sc = new Session(ini, end, day);
    int      t  = qnt();
    if (ArrayResize(schedules, t + 1))
    {
      schedules[t] = sc;
      return true;
    }

    return false;
  }

  bool ClearShchedules()
  {
    for (int i = 0; i < qnt(); i++)
    {
      delete schedules[i];
    }
    ArrayFree(schedules);

    return true;
  }

  bool doSessionControl()  // control day and hours for every session
  {
    Comment("Daily Control - EA OFF");

    int actual = (TimeHour(TimeGMT() + _timeZone) * 3600) + (TimeMinute(TimeGMT() + _timeZone) * 60);

    for (int i = 0; i < qnt(); i++)
    {
      if (schedules[i].dayNumber() == EA_OFF)
      {
        continue;
      }

      if (schedules[i].dayNumber() != 0)
      {
        if (schedules[i].dayNumber() == TimeDayOfWeek(TimeGMT() + _timeZone))
        {
          if ((actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime())
          {
            setActualSession(i);
            Comment("Daily Control - EA ON");
            return true;
          }
        }
      }

      if (schedules[i].dayNumber() == 0)
      {
        if ((actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime())
        {
          setActualSession(i);
          Comment("Daily Control - EA ON");
          return true;
        }
      }
    }

    //---
    setActualSession(-1);
    return false;
  }

  void PrintDays()
  {
    for (int i = 0; i < qnt(); i++)
    {
      PrintDay(i);
    }
  }

  void PrintDay(int i)
  {
    Print("Day Nr: ", schedules[i].dayNumber());
    Print("Day Ini Time: ", schedules[i].iniTime());
    Print("Day End Time: ", schedules[i].endTime());
  }
};
ScheduleController sesionControl;

#endif

#ifdef DAILY_LIMITS
enum DayLimitsMode {
  LimitsByAmount,         // by Amount
  LimitsByAccountPercent  // by Account %
};
input string        Tlimits            = "== Daily Limits Setup ==";  // ————————————
input bool          uDailyProfitOn     = false;                       // Control Daily Profit On:
input DayLimitsMode limitProfitMode    = LimitsByAmount;              // Mode to control daily profit:
input double        uDayLimitProfit    = 2000;                        // Max Daily Profit ($ or %):
input bool          uDailyLossOn       = false;                       // Control Daily Loss On:
input DayLimitsMode limitLossMode      = LimitsByAmount;              // Mode to control daily loss:
input double        uDayLimitLoss      = -1000;                       // Max Daily Loss ($ or %):
input bool          uConsiderFloatting = true;                        // Consider Floating:
input bool          CloseAllWhenDailyLimit = true;                    // Close All When Limit are reached:

interface iConditions
{
  bool evaluate();
};
class DailyProfitCondition : public iConditions
{
  int           _magic;
  double        _limit;
  bool          _considerOpen;  // Considera el flotante profit flotante
  string        _mode;          // loss or profit
  DayLimitsMode _limitMode;     // Amount or AccountPer
 public:
  DailyProfitCondition(double limit, int mag, bool considerOpen, string mode, DayLimitsMode limitMode) : _limit(limit), _magic(mag), _considerOpen(considerOpen), _mode(mode), _limitMode(limitMode) { ; }
  ~DailyProfitCondition() { ; }

  bool evaluate()
  {
    if (_mode == "profit")
    {
      if (TodayProfit() >= Limit())
      {
        Print("DAILY PROFIT REACHED: ", TodayProfit());
        return true;
      }
    }
    if (_mode == "loss")
    {
      if (TodayProfit() <= Limit())
      {
        Print("DAILY LOSS REACHED: ", TodayProfit());
        return true;
      }
    }
    return false;
  }

  double Limit()
  {
    if (_limitMode == LimitsByAmount)
    {
      return _limit;
    }
    if (_limitMode == LimitsByAccountPercent)
    {
      return _limit / 100 * AccountInfoDouble(ACCOUNT_BALANCE);
    }
    return 0;
  }

  double TodayProfit()
  {
    datetime iniDay = iTime(NULL, PERIOD_D1, 0);

    double profit = 0;
    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--)
    {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic && OrderComment()=="EA")
      {
        if (OrderCloseTime() >= iniDay)
        {
          profit += OrderProfit() + OrderSwap() + OrderCommission();
        }
      }
    }

    if (_considerOpen)
    {
      for (int n = OrdersTotal() - 1; n >= 0; n--)
      {
        if (OrderSelect(n, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic && OrderComment()=="EA")
        {
          profit += OrderProfit() + OrderSwap() + OrderCommission();
        }
      }
    }

    return profit;
  }
};

#ifdef DAILY_LIMITS
DailyProfitCondition dailyProfitCondition(uDayLimitProfit, 0, uConsiderFloatting, "profit", limitProfitMode);
DailyProfitCondition dailyLossCondition(uDayLimitLoss, 0, uConsiderFloatting, "loss", limitLossMode);
#endif

#ifdef CLOSE_ALL_ON
enum CloseAllMode {
  CloseByMoney,           // by Money
  CloseByAccountPercent,  // by Account Percent
  CloseByPips             // By Pips
};
string       TtpOptions              = "== Close All Options ==";  // ————————————
bool         closeAllControlON       = false;                      // Close All Control On:
CloseAllMode closeBy                 = CloseByMoney;               // Close All Mode:
double       closeAllMoney           = 100;                        // Close by Money $:
double       closeAllMoneyLoss       = -100;                       // Close by Money Lossing $:
double       accountPerWin           = 1;                          // Account Percent Win:
double       accountPerLos           = -1;                         // Account Percent Loss:
double       closeByPipsWin          = 10;                         // Close Pips Win:
double       closeByPipsLoss         = 10;                         // Close Pips Loss:
#endif

// ------------------------------------------------------------------

interface iActions
{
  bool doAction();
};
class ActionCloseOrdersByType : public iActions
{
  ENUM_ORDER_TYPE _type;
  string          _symbol;
  int             _magic;
  int             _slippage;
  double          _price;

 public:
  ActionCloseOrdersByType(string side, int magic = 0, string symbol = "", int slippage = 10000)
  {
    if (side == "buy") _type = OP_BUY;
    if (side == "sell") _type = OP_SELL;
    if (symbol == "")
    {
      _symbol = Symbol();
    } else
    {
      _symbol = symbol;
    }
    if (magic != 0)
    {
      _magic = magic;
    }
    if (slippage != 10000)
    {
      _slippage = slippage;
    }
  }
  ~ActionCloseOrdersByType() {}

  void setPrice()
  {
    if (_type == OP_BUY)
    {
      _price = SymbolInfoDouble(_symbol, SYMBOL_BID);
    }
    if (_type == OP_SELL)
    {
      _price = SymbolInfoDouble(_symbol, SYMBOL_ASK);
    }
  }

  bool doAction()
  {
    setPrice();
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
      if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic && OrderType() == _type)
      {
        if (!OrderClose(OrderTicket(), OrderLots(), _price, _slippage, clrNONE))
        {
          Print(__FUNCTION__, " ", "can't close Order: ", OrderTicket(), " error: ", GetLastError());
          return false;
        }
      }
    }
    return true;
  }
};
ActionCloseOrdersByType* actionCloseSells;
ActionCloseOrdersByType* actionCloseBuys;


// ------------------------------------------------------------------
bool gi_120 = FALSE;
bool gi_124 = FALSE;
bool gi_128 = FALSE;
bool gi_132 = FALSE;
bool gi_136 = FALSE;
bool gi_140 = FALSE;
bool gi_144 = FALSE;
bool gi_148 = FALSE;
bool gi_152 = FALSE;
bool gi_156 = FALSE;
bool gi_160 = FALSE;
bool gi_164 = TRUE;
bool gi_168 = FALSE;
bool gi_172 = FALSE;
bool gi_176 = FALSE;
bool gi_180 = FALSE;
bool gi_184 = TRUE;
bool gi_188 = FALSE;
bool gi_192 = TRUE;
bool gi_196 = FALSE;
double gd_200 = 3.0;
double gd_208 = 4.0;
int gi_216 = 10;
bool gi_unused_220 = TRUE;
double gd_224 = 23.0;
double gd_232 = 23.0;
double g_slippage_240 = 1.0;
double g_price_248 = 0.0;
double g_price_256 = 0.0;
double gd_264 = 1.0;
double gd_272 = 1.1;
bool gi_280 = TRUE;
double gd_284;
bool gi_292 = FALSE;
bool gi_296 = FALSE;
bool gi_unused_300 = FALSE;
bool gi_unused_304 = FALSE;
double gd_308 = 0.0;
double gd_316 = 0.0;
bool gi_324 = FALSE;
bool gi_328 = FALSE;
double g_period_332 = 1.0;
double g_period_340 = 1.0;
int gi_348 = 0;
bool gi_352 = FALSE;
double gd_unused_356 = 0.0;
double gd_unused_364 = 0.0;
double gd_372;
double gd_380;
double gd_388;
double gd_396;
double gd_unused_404 = 0.0;
double gd_412;
double gd_420;
double gd_428;
double gd_436;
double gd_444;
double gd_452;
double gd_460;
double gd_468;
double gd_476;
double gd_484;
int g_ticket_492;
int g_order_total_496;
int g_pos_500;
double gd_504;
double gd_512;
double gd_520;
double gd_552;
double gd_560;
double gd_568;
double gd_576;
double gd_584;
double gd_592;
double gd_600;
double gd_608;
double gd_616;
double gd_624;
double gd_632;
double gd_640;
double g_low_648;
double g_high_656;
double g_time_664;
double g_bid_672;
double g_ask_680;
double gd_688;
double g_digits_696;
double gd_704;
double gd_712;
double g_lotsize_720;
double g_tickvalue_728;
double g_ticksize_736;
double g_swaplong_744;
double g_swapshort_752;
double g_starting_760;
double g_expiration_768;
double g_tradeallowed_776;
double g_minlot_784;
double g_lotstep_792;

int f0_14() {
   g_low_648 = MarketInfo(Symbol(), MODE_LOW);
   g_high_656 = MarketInfo(Symbol(), MODE_HIGH);
   g_time_664 = MarketInfo(Symbol(), MODE_TIME);
   g_bid_672 = MarketInfo(Symbol(), MODE_BID);
   g_ask_680 = MarketInfo(Symbol(), MODE_ASK);
   gd_688 = 0.0001;
   g_digits_696 = MarketInfo(Symbol(), MODE_DIGITS);
   gd_704 = 5;
   gd_712 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   g_lotsize_720 = MarketInfo(Symbol(), MODE_LOTSIZE);
   g_tickvalue_728 = MarketInfo(Symbol(), MODE_TICKVALUE);
   g_ticksize_736 = MarketInfo(Symbol(), MODE_TICKSIZE);
   g_swaplong_744 = MarketInfo(Symbol(), MODE_SWAPLONG);
   g_swapshort_752 = MarketInfo(Symbol(), MODE_SWAPSHORT);
   g_starting_760 = MarketInfo(Symbol(), MODE_STARTING);
   g_expiration_768 = MarketInfo(Symbol(), MODE_EXPIRATION);
   g_tradeallowed_776 = MarketInfo(Symbol(), MODE_TRADEALLOWED);
   g_minlot_784 = MarketInfo(Symbol(), MODE_MINLOT);
   g_lotstep_792 = MarketInfo(Symbol(), MODE_LOTSTEP);
   if (gi_128 == TRUE) {
      Print("ModeLow:", g_low_648);
      Print("ModeHigh:", g_high_656);
      Print("ModeTime:", g_time_664);
      Print("ModeBid:", g_bid_672);
      Print("ModeAsk:", g_ask_680);
      Print("ModePoint:", gd_688);
      Print("ModeDigits:", g_digits_696);
      Print("ModeSpread:", gd_704);
      Print("ModeStopLevel:", gd_712);
      Print("ModeLotSize:", g_lotsize_720);
      Print("ModeTickValue:", g_tickvalue_728);
      Print("ModeTickSize:", g_ticksize_736);
      Print("ModeSwapLong:", g_swaplong_744);
      Print("ModeSwapShort:", g_swapshort_752);
      Print("ModeStarting:", g_starting_760);
      Print("ModeExpiration:", g_expiration_768);
      Print("ModeTradeAllowed:", g_tradeallowed_776);
      Print("ModeMinLot:", g_minlot_784);
      Print("ModeLotStep:", g_lotstep_792);
   }
   return (0);
}

int f0_7() {
   double ld_0;
   f0_14();
   if (AutoLots == TRUE) {
      if (gd_264 != OrdersTotal()) ld_0 = (AccountBalance() * Risk - AccountMargin()) * AccountLeverage() / (gd_264 - OrdersTotal());
      else ld_0 = 0;
      if (StringFind(Symbol(), "USD") == -1) {
         if (StringFind(Symbol(), "EUR") == -1) ld_0 = 0;
         else {
            ld_0 /= iClose("EURUSD", PERIOD_M1, 0);
            if (StringFind(Symbol(), "EUR") != 0) ld_0 /= Bid;
         }
      } else
         if (StringFind(Symbol(), "USD") != 0) ld_0 /= Bid;
      ld_0 /= g_lotsize_720;
      ld_0 -= g_minlot_784;
      ld_0 /= g_lotstep_792;
      ld_0 = NormalizeDouble(ld_0, 0);
      ld_0 *= g_lotstep_792;
      ld_0 += g_minlot_784;
      Lots = ld_0;
      if (gi_156 == TRUE) Print("Lots:", Lots);
   }
   return (0);
}

int init() {
     	sesionControl.AddSession(timeStart, timeEnd);	
	 
	 f0_19();
   f0_14();
   gd_444 = g_period_332 * gd_224;
   if (g_period_332 != 0.0) gd_452 = gd_444 / g_period_332;
   f0_13();
   return (0);
}

int f0_13() {
   gd_460 = Ask - Bid;
   return (0);
}

int f0_1(int ai_0) {
   gd_476 = iClose(Symbol(), PERIOD_M1, g_period_332 * ai_0) - iOpen(Symbol(), PERIOD_M1, g_period_332 * ai_0);
   gd_484 = iClose(Symbol(), PERIOD_M1, g_period_332 * (ai_0 + 1)) - iOpen(Symbol(), PERIOD_M1, g_period_332 * (ai_0 + 1));
   gd_512 = 0;
   gd_504 = 0;
   gd_520 = 0;
   if (gd_476 != 0.0) {
      if (gd_476 > 0.0) {
         if (gd_484 < 0.0) {
            gd_468 = 0;
            gd_504 = 0;
            gd_512 = gd_476;
            gd_520 = 0;
         } else {
            gd_468 = -1;
            gd_520 = gd_476;
            gd_504 = 0;
            gd_512 = 0;
         }
      } else {
         if (gd_484 > 0.0) {
            gd_468 = 1;
            gd_512 = 0;
            gd_520 = 0;
            gd_504 = -1.0 * gd_476;
         } else {
            gd_468 = -1;
            gd_520 = -1.0 * gd_476;
            gd_512 = 0;
            gd_504 = 0;
         }
      }
   } else {
      gd_468 = -1;
      gd_520 = 0;
      gd_512 = 0;
      gd_504 = 0;
   }
   return (gd_468);
}

int f0_2() {
   gd_584 = 0;
   gd_576 = 0;
   gd_592 = 0;
   gd_632 = 0;
   gd_624 = 0;
   gd_640 = 0;
   gd_552 = 0;
   gd_560 = 0;
   gd_568 = 0;
   gd_372 = 0;
   gd_380 = 0;
   gd_388 = 0;
   gd_396 = 0;
   gd_412 = 0;
   gd_420 = 0;
   gd_428 = 0;
   gd_436 = 0;
   for (int count_0 = 0; count_0 < gd_452; count_0++) {
      f0_1(count_0);
      if (gd_468 == 0.0) gd_380++;
      if (gd_468 == 1.0) gd_372++;
      if (gd_468 == -1.0) gd_388++;
      if (gd_504 > gd_460 || gd_512 > gd_460 || gd_520 > gd_460) {
         if (gd_468 == 0.0) gd_420++;
         if (gd_468 == 1.0) gd_412++;
         if (gd_468 == -1.0) gd_428++;
      }
      gd_600 *= gd_632;
      gd_632++;
      gd_600 += gd_504;
      if (gd_632 != 0.0) gd_600 /= gd_632;
      else gd_600 = 0;
      gd_608 *= gd_624;
      gd_624++;
      gd_608 += gd_512;
      if (gd_624 != 0.0) gd_608 /= gd_624;
      else gd_608 = 0;
      gd_616 *= gd_640;
      gd_640++;
      gd_616 += gd_520;
      if (gd_640 != 0.0) gd_616 /= gd_640;
      else gd_616 = 0;
      if (gd_504 > gd_460) {
         gd_552 *= gd_584;
         gd_584++;
         gd_552 += gd_504;
         if (gd_584 != 0.0) gd_552 /= gd_584;
         else gd_552 = 0;
      }
      if (gd_512 > gd_460) {
         gd_560 *= gd_576;
         gd_576++;
         gd_560 += gd_512;
         if (gd_576 != 0.0) gd_560 /= gd_576;
         else gd_560 = 0;
      }
      if (gd_520 > gd_460) {
         gd_568 *= gd_592;
         gd_592++;
         gd_568 += gd_520;
         if (gd_592 != 0.0) {
            gd_568 /= gd_592;
            continue;
         }
         gd_568 = 0;
      }
   }
   if (gd_388 + gd_380 + gd_372 != 0.0) gd_396 = (gd_380 + gd_372) / (gd_388 + gd_380 + gd_372);
   else gd_396 = 0;
   if (gd_428 + gd_420 + gd_412 != 0.0) gd_436 = (gd_420 + gd_412) / (gd_428 + gd_420 + gd_412);
   else gd_436 = 0;
   return (0);
}

int f0_0() {
   if (gi_136 == TRUE) {
      Print("SellPossibilityMid*SellPossibilityQuality:", gd_608 * gd_380);
      Print("BuyPossibilityMid*BuyPossibilityQuality:", gd_600 * gd_372);
      Print("UndefinedPossibilityMid*UndefinedPossibilityQuality:", gd_616 * gd_388);
      Print("UndefinedSucPossibilityQuality:", gd_428);
      Print("SellSucPossibilityQuality:", gd_420);
      Print("BuySucPossibilityQuality:", gd_412);
      Print("UndefinedPossibilityQuality:", gd_388);
      Print("SellPossibilityQuality:", gd_380);
      Print("BuyPossibilityQuality:", gd_372);
      Print("UndefinedSucPossibilityMid:", gd_568);
      Print("SellSucPossibilityMid:", gd_560);
      Print("BuySucPossibilityMid:", gd_552);
      Print("UndefinedPossibilityMid:", gd_616);
      Print("SellPossibilityMid:", gd_608);
      Print("BuyPossibilityMid:", gd_600);
   }
   return (0);
}

int f0_10() {
   f0_2();
   f0_1(0);
   f0_0();
   return (gd_468);
}

int f0_11() {
   gi_324 = FALSE;
   gi_328 = FALSE;
   gi_352 = FALSE;
   gi_292 = FALSE;
   gi_296 = FALSE;
   if (gi_184 == TRUE) f0_17();
   if (gi_176 == TRUE) f0_21();
   if (gi_180 == TRUE) f0_20();
   if (gi_196 == TRUE) f0_16();
   return (0);
}

int f0_16() {
   if ((gd_504 > gd_600 * gd_200 && gd_504 != 0.0 && gd_600 != 0.0) || (gd_512 > gd_608 * gd_200 && gd_512 != 0.0 && gd_608 != 0.0)) {
      if (gi_292 == TRUE) gi_292 = FALSE;
      else gi_292 = TRUE;
      if (gi_296 == TRUE) gi_296 = FALSE;
      else gi_296 = TRUE;
      if (gi_324 == TRUE) gi_324 = FALSE;
      else gi_324 = TRUE;
      if (gi_328 == TRUE) gi_328 = FALSE;
      else gi_328 = TRUE;
   }
   return (0);
}

int f0_17() {
   if (g_period_332 > g_period_340) {
      if (gd_608 * gd_380 > gd_600 * gd_372) {
         gi_292 = FALSE;
         gi_296 = TRUE;
         gi_328 = TRUE;
         if (gd_560 * gd_420 > gd_552 * gd_412) gi_292 = TRUE;
      }
      if (gd_608 * gd_380 < gd_600 * gd_372) {
         gi_292 = TRUE;
         gi_296 = FALSE;
         gi_324 = TRUE;
         if (gd_560 * gd_420 < gd_552 * gd_412) gi_296 = TRUE;
      }
   }
   if (g_period_332 < g_period_340) {
      if (gd_608 * gd_380 > gd_600 * gd_372) {
         gi_292 = TRUE;
         gi_296 = TRUE;
      }
      if (gd_608 * gd_380 < gd_600 * gd_372) {
         gi_292 = TRUE;
         gi_296 = TRUE;
      }
   }
   if (gd_608 * gd_380 == gd_600 * gd_372) {
      gi_292 = TRUE;
      gi_296 = TRUE;
      gi_352 = FALSE;
   }
   if (gd_512 > 2.0 * gd_560 && gd_560 > 0.0) {
      gi_292 = TRUE;
      gi_324 = TRUE;
   }
   if (gd_504 > 2.0 * gd_552 && gd_552 > 0.0) {
      gi_296 = TRUE;
      gi_328 = TRUE;
   }
   if (gi_144 == TRUE) {
      if (gi_292 == TRUE) Print("", gd_608 * gd_380);
      else Print("", gd_608 * gd_380);
      if (gi_296 == TRUE) Print("", gd_600 * gd_372);
      else Print("", gd_600 * gd_372);
   }
   if (gi_140 == TRUE) {
      if (gd_468 == 0.0) Print(" ", gd_476);
      if (gd_468 == 1.0) Print(" ", gd_476);
      if (gd_468 == -1.0) Print(" ", gd_476);
   }
   return (0);
}

int f0_20() {
   if (iMA(Symbol(), PERIOD_M1, g_period_332, 0, MODE_EMA, PRICE_CLOSE, 0) > iMA(Symbol(), PERIOD_M1, g_period_332, 0, MODE_EMA, PRICE_CLOSE, 1)) {
      gi_292 = TRUE;
      gi_324 = TRUE;
   }
   if (iMA(Symbol(), PERIOD_M1, g_period_332, 0, MODE_EMA, PRICE_CLOSE, 0) < iMA(Symbol(), PERIOD_M1, g_period_332, 0, MODE_EMA, PRICE_CLOSE, 1)) {
      gi_296 = TRUE;
      gi_328 = TRUE;
   }
   return (0);
}

int f0_21() {
   double ld_unused_0 = 0;
   double ld_8 = 0;
   double ld_16 = 0;
   double ld_unused_24 = 0;
   double ld_unused_32 = 0;
   double ld_unused_40 = 0;
   double ld_unused_48 = 0;
   gi_352 = FALSE;
   gi_324 = FALSE;
   gi_328 = FALSE;
   gi_296 = FALSE;
   gi_292 = FALSE;
   gi_168 = FALSE;
   gi_172 = FALSE;
   for (int li_56 = 0; li_56 < gi_216; li_56++) {
      if (iMACD(Symbol(), MathPow(2, li_56), 2, 4, 1, PRICE_CLOSE, MODE_MAIN, 0) < iMACD(Symbol(), MathPow(2, li_56), 2, 4, 1, PRICE_CLOSE, MODE_MAIN, 1)) ld_8 += iMACD(Symbol(), MathPow(2, li_56), 2, 4, 1, PRICE_CLOSE, MODE_MAIN, 0);
      if (iMACD(Symbol(), MathPow(2, li_56), 2, 4, 1, PRICE_CLOSE, MODE_MAIN, 0) > iMACD(Symbol(), MathPow(2, li_56), 2, 4, 1, PRICE_CLOSE, MODE_MAIN, 1)) ld_16 += iMACD(Symbol(), MathPow(2, li_56), 2, 4, 1, PRICE_CLOSE, MODE_MAIN, 0);
   }
   if (ld_8 > ld_16) {
      gi_296 = TRUE;
      gi_328 = TRUE;
   }
   if (ld_8 < ld_16) {
      gi_292 = TRUE;
      gi_324 = TRUE;
   }
   return (0);
}

int f0_3() {
   if (gi_348 == FALSE) {
      gd_308 = iHigh(Symbol(), PERIOD_M1, 0) - iLow(Symbol(), PERIOD_M1, 0);
      if (gd_468 == 0.0) {
         if ((iClose(Symbol(), PERIOD_M1, 0) - iClose(Symbol(), PERIOD_M1, g_period_332)) / gd_208 >= gd_560 && gd_560 != 0.0 && gi_192 == TRUE) {
            gd_704 += 1.0;
            if (Bid - gd_560 * gd_272 - gd_704 * Point > Bid - gd_712 * gd_688 - gd_704 * Point) g_price_248 = Bid - gd_712 * gd_688 - gd_704 * Point - gd_308;
            else {
               if (gd_560 != 0.0) g_price_248 = Bid - gd_560 * gd_272 - gd_704 * Point - gd_308;
               else g_price_248 = Bid - gd_712 * gd_688 - gd_704 * Point - gd_308;
            }
            if (gi_152 == TRUE) return (0);
            gd_284 = g_price_248;
            Print("", gd_284);
            if (gi_160 == TRUE) g_price_248 = 0;
            g_price_248 = NormalizeDouble(g_price_248, 4);
            g_ticket_492 = OrderSend(Symbol(), OP_BUY, Lots, Ask, g_slippage_240, 0, g_price_256, "EA", 0, 0, Blue);
            OrderModify(g_ticket_492, OrderOpenPrice(), g_price_248, 0, 0, Blue);
            if (g_ticket_492 > 0) {
               if (OrderSelect(g_ticket_492, SELECT_BY_TICKET, MODE_TRADES)) Print(" ", OrderOpenPrice());
            } else {
               Print(" ", GetLastError());
               f0_4();
            }
            return (0);
         }
      }
      if (gd_468 == 1.0) {
         if ((iClose(Symbol(), PERIOD_M1, g_period_332) - iClose(Symbol(), PERIOD_M1, 0)) / gd_208 >= gd_552 && gd_552 != 0.0 && gi_192 == TRUE) {
            gd_704 += 1.0;
            if (Ask + gd_552 * gd_272 + gd_704 * Point < Ask + gd_712 * gd_688 + gd_704 * Point) g_price_248 = Ask + gd_712 * gd_688 + gd_704 * Point + gd_308;
            else {
               if (gd_552 != 0.0) g_price_248 = Ask + gd_552 * gd_272 + gd_704 * Point + gd_308;
               else g_price_248 = Ask + gd_712 * gd_688 + gd_704 * Point + gd_308;
            }
            if (gi_148 == TRUE) return (0);
            gd_284 = g_price_248;
            Print("", gd_284);
            if (gi_160 == TRUE) g_price_248 = 0;
            g_price_248 = NormalizeDouble(g_price_248, 4);
            g_ticket_492 = OrderSend(Symbol(), OP_SELL, Lots, Bid, g_slippage_240, 0, g_price_256, "EA", 0, 0, Green);
            OrderModify(g_ticket_492, OrderOpenPrice(), g_price_248, 0, 0, Blue);
            if (g_ticket_492 > 0) {
               if (OrderSelect(g_ticket_492, SELECT_BY_TICKET, MODE_TRADES)) Print(" ", OrderOpenPrice());
            } else {
               Print("", GetLastError());
               f0_4();
            }
            return (0);
         }
      }
   }
   return (0);
}

int f0_22() {
   if (Lots == 0.0) return (0);
   if (gi_120 == FALSE) {
      if (gi_348 == FALSE) {
         gd_308 = iHigh(Symbol(), PERIOD_M1, 0) - iLow(Symbol(), PERIOD_M1, 0);
         if (gd_468 == 0.0) {
            if (gd_512 >= gd_560) {
               if (Ask + gd_552 * gd_272 + gd_704 * Point < Ask + gd_712 * gd_688 + gd_704 * Point) g_price_248 = Ask + gd_712 * gd_688 + gd_704 * Point + gd_308;
               else {
                  if (gd_552 != 0.0) g_price_248 = Ask + gd_552 * gd_272 + gd_704 * Point + gd_308;
                  else g_price_248 = Ask + gd_712 * gd_688 + gd_704 * Point + gd_308;
               }
               if (gi_292 == TRUE) return (0);
               if (gi_148 == TRUE) return (0);
               gd_284 = g_price_248;
               Print("", gd_284);
               if (gi_160 == TRUE) g_price_248 = 0;
               g_price_248 = NormalizeDouble(g_price_248, 4);
               g_ticket_492 = OrderSend(Symbol(), OP_SELL, Lots, Bid, g_slippage_240, 0, g_price_256, "EA", 0, 0, Green);
               OrderModify(g_ticket_492, OrderOpenPrice(), g_price_248, 0, 0, Blue);
               if (g_ticket_492 > 0) {
                  if (OrderSelect(g_ticket_492, SELECT_BY_TICKET, MODE_TRADES)) Print(" ", OrderOpenPrice());
               } else {
                  Print(" ", GetLastError());
                  f0_4();
               }
               return (0);
            }
         }
         if (gd_468 == 1.0) {
            if (gd_504 >= gd_552) {
               if (Bid - gd_560 * gd_272 - gd_704 * Point > Bid - gd_712 * gd_688 - gd_704 * Point) g_price_248 = Bid - gd_712 * gd_688 - gd_704 * Point - gd_308;
               else {
                  if (gd_560 != 0.0) g_price_248 = Bid - gd_560 * gd_272 - gd_704 * Point - gd_308;
                  else g_price_248 = Bid - gd_712 * gd_688 - gd_704 * Point - gd_308;
               }
               if (gi_296 == TRUE) return (0);
               if (gi_152 == TRUE) return (0);
               gd_284 = g_price_248;
               Print("", gd_284);
               if (gi_160 == TRUE) g_price_248 = 0;
               g_price_248 = NormalizeDouble(g_price_248, 4);
               g_ticket_492 = OrderSend(Symbol(), OP_BUY, Lots, Ask, g_slippage_240, 0, g_price_256, "EA", 0, 0, Blue);
               OrderModify(g_ticket_492, OrderOpenPrice(), g_price_248, 0, 0, Blue);
               if (g_ticket_492 > 0) {
                  if (OrderSelect(g_ticket_492, SELECT_BY_TICKET, MODE_TRADES)) Print("", OrderOpenPrice());
               } else {
                  Print(" ", GetLastError());
                  f0_4();
               }
               return (0);
            }
         }
      }
   }
   return (0);
}

int f0_12() {
   gi_348 = FALSE;
   g_order_total_496 = OrdersTotal();
   for (g_pos_500 = 0; g_pos_500 < g_order_total_496; g_pos_500++) {
      OrderSelect(g_pos_500, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         gi_348 = TRUE;
         break;
      }
      gd_284 = 0;
      g_price_248 = 0;
   }
   return (0);
}

int f0_18() {
   int count_0 = 0;
   f0_12();
   if (Lots == 0.0) return (0);
   gd_308 = 0;
   if (gi_120 == FALSE) {
      if (gi_348 == FALSE) {
         gd_308 = 0;
         gd_316 = 0;
         for (count_0 = 0; count_0 < g_period_332; count_0++) {
            gd_308 = iHigh(Symbol(), PERIOD_M1, count_0 + 1) - iLow(Symbol(), PERIOD_M1, count_0 + 1);
            if (gd_308 > gd_316) gd_316 = gd_308;
         }
         gd_308 = gd_316 * gd_272;
         if (gd_308 == 0.0) gd_308 = gd_712 * Point;
         for (count_0 = 0; count_0 < g_period_332; count_0++) {
            if (Bid - iClose(Symbol(), PERIOD_M1, count_0 + 1) > gd_560 * (count_0 + 1) && gd_560 != 0.0 && gi_352 == FALSE && gi_324 == FALSE) {
               if (Ask + gd_704 * Point + gd_308 < Ask + gd_712 * gd_688 + gd_704 * Point) g_price_248 = Ask + gd_712 * gd_688 + gd_704 * Point + Point;
               else {
                  if (gd_552 != 0.0) g_price_248 = Ask + gd_704 * Point + gd_308 + Point;
                  else g_price_248 = Ask + gd_712 * gd_688 + gd_704 * Point + Point;
               }
               if (gi_148 == TRUE) return (0);
               if (gi_292 == TRUE) return (0);
               gd_284 = g_price_248;
               Print("", gd_284);
               if (gi_160 == TRUE) g_price_248 = 0;
               g_price_248 = NormalizeDouble(g_price_248, 4);
               g_ticket_492 = OrderSend(Symbol(), OP_SELL, Lots, Bid, g_slippage_240, 0, g_price_256, "EA", 0, 0, Green);
               OrderModify(g_ticket_492, OrderOpenPrice(), g_price_248, 0, 0, Blue);
               if (g_ticket_492 > 0) {
                  if (OrderSelect(g_ticket_492, SELECT_BY_TICKET, MODE_TRADES)) Print("", OrderOpenPrice());
               } else {
                  Print(" ", GetLastError());
                  f0_4();
               }
               return (0);
            }
            if (iClose(Symbol(), PERIOD_M1, count_0 + 1) - Bid > gd_552 * (count_0 + 1) && gd_552 != 0.0 && gi_352 == FALSE && gi_328 == FALSE) {
               if (Bid - gd_704 * Point - gd_308 > Bid - gd_712 * gd_688 - gd_704 * Point) g_price_248 = Bid - gd_712 * gd_688 - gd_704 * Point - Point;
               else {
                  if (gd_560 != 0.0) g_price_248 = Bid - gd_704 * Point - gd_308 - Point;
                  else g_price_248 = Bid - gd_712 * gd_688 - gd_704 * Point - Point;
               }
               if (gi_296 == TRUE) return (0);
               if (gi_152 == TRUE) return (0);
               gd_284 = g_price_248;
               Print("", gd_284);
               if (gi_160 == TRUE) g_price_248 = 0;
               g_price_248 = NormalizeDouble(g_price_248, 4);
               g_ticket_492 = OrderSend(Symbol(), OP_BUY, Lots, Ask, g_slippage_240, 0, g_price_256, "EA", 0, 0, Blue);
               OrderModify(g_ticket_492, OrderOpenPrice(), g_price_248, 0, 0, Blue);
               if (g_ticket_492 > 0) {
                  if (OrderSelect(g_ticket_492, SELECT_BY_TICKET, MODE_TRADES)) Print(" ", OrderOpenPrice());
               } else {
                  Print(" ", GetLastError());
                  f0_4();
               }
               return (0);
            }
         }
      }
   }
   return (0);
}

int f0_6() {
   if (gi_348 == TRUE) {
      if (OrderType() == OP_BUY) {
         if (Bid + 11.0 * Point <= gd_284 && gi_164 == FALSE && gd_284 != 0.0) {
            OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_240, Violet);
            return (0);
         }
         if (gi_172 == TRUE) return (0);
         if (OrderOpenPrice() + 11.0 * Point < Bid) {
            OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_240, Violet);
            return (0);
         }
         if (iClose(Symbol(), PERIOD_M1, 0) - iClose(Symbol(), PERIOD_M1, 1) >= 4.0 * gd_560 && gd_560 > 0.0) return (0);
         if (OrderOpenPrice() + 11.0 * Point < Bid && Bid - OrderOpenPrice() + 11.0 * Point >= gd_560 && gd_560 > 0.0) {
            OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_240, Violet);
            return (0);
         }
         if (OrderOpenPrice() + 11.0 * Point < Bid && Bid - OrderOpenPrice() + 11.0 * Point >= gd_552 && gd_552 > 0.0) {
            OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_240, Violet);
            return (0);
         }
         if (gd_468 == 0.0) {
            if (OrderOpenPrice() + 11.0 * Point < Bid) {
               if (gd_512 >= gd_608 - Point) {
                  OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_240, Violet);
                  return (0);
               }
            }
         }
         if (OrderOpenPrice() + 11.0 * Point < Bid && Bid - OrderOpenPrice() + 11.0 * Point >= gd_616) {
            OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_240, Violet);
            return (0);
         }
         if (gd_468 == 1.0) return (0);
      }
      if (OrderType() == OP_SELL) {
         if (Ask - 11.0 * Point >= gd_284 && gi_164 == FALSE && gd_284 != 0.0) {
            OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_240, Violet);
            return (0);
         }
         if (gi_168 == TRUE) return (0);
         if (OrderOpenPrice() - 11.0 * Point > Ask) {
            OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_240, Violet);
            return (0);
         }
         if (iClose(Symbol(), PERIOD_M1, 1) - iClose(Symbol(), PERIOD_M1, 0) >= 4.0 * gd_552 && gd_552 > 0.0) return (0);
         if (OrderOpenPrice() - 11.0 * Point > Ask && OrderOpenPrice() - 11.0 * Point - Ask >= gd_552 && gd_552 > 0.0) {
            OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_240, Violet);
            return (0);
         }
         if (OrderOpenPrice() - 11.0 * Point > Ask && OrderOpenPrice() - 11.0 * Point - Ask >= gd_560 && gd_560 > 0.0) {
            OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_240, Violet);
            return (0);
         }
         if (gd_468 == 1.0) {
            if (OrderOpenPrice() - 11.0 * Point > Ask) {
               if (gd_504 >= gd_600 - Point) {
                  OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_240, Violet);
                  return (0);
               }
            }
         }
         if (OrderOpenPrice() - 11.0 * Point > Ask && OrderOpenPrice() - 11.0 * Point - Ask >= gd_616) {
            OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_240, Violet);
            return (0);
         }
         if (gd_468 == 0.0) return (0);
      }
   }
   return (0);
}

int f0_9() {
   gd_unused_356 = Bid;
   gd_unused_364 = Ask;
   g_period_340 = g_period_332;
   return (0);
}

int f0_5() {
   f0_12();
   f0_11();
   f0_15();
   if (gi_348 == FALSE) {
      if (gi_192 == TRUE) f0_3();
      if (gi_188 == TRUE) f0_22();
      if (gi_352 == FALSE) f0_18();
   } else f0_6();
   return (0);
}

int f0_19() {
   if (gi_132 == TRUE) {
      Print("AccountBalance:", AccountBalance());
      Print("AccountCompany:", AccountCompany());
      Print("AccountCredit:", AccountCredit());
      Print("AccountCurrency:", AccountCurrency());
      Print("AccountEquity:", AccountEquity());
      Print("AccountFreeMargin:", AccountFreeMargin());
      Print("AccountLeverage:", AccountLeverage());
      Print("AccountMargin:", AccountMargin());
      Print("AccountName:", AccountName());
      Print("AccountNumber:", AccountNumber());
      Print("AccountProfit:", AccountProfit());
   }
   return (0);
}

int f0_8() {
   double ld_0 = (-1.0 * gd_232) * gd_232;
   double ld_ret_8 = 0;
   for (int count_16 = 0; count_16 < gd_232; count_16++) {
      g_period_332 = count_16 + 1;
      gd_224 = 5.0 * g_period_332;
      init();
      f0_2();
      if (gd_436 > ld_0) {
         ld_0 = gd_436;
         ld_ret_8 = count_16 + 1;
      }
   }
   g_period_332 = ld_ret_8;
   init();
   if (gi_124 == TRUE) Print("", ld_ret_8, " ", ld_0);
   return (ld_ret_8);
}

int f0_15() {
   if (gi_280 == TRUE) gd_272 = gd_704;
   return (0);
}

int f0_4() {
   Print("ErrorValues:Symbol=", Symbol(), ",Lots=", Lots, ",Bid=", Bid, ",Ask=", Ask, ",SlipPage=", g_slippage_240, "StopLoss=", g_price_248, ",TakeProfit=", g_price_256);
   return (0);
}

int start() {
   

	if (closeAllControlON) { if (CloseAllControl()) closeAll(); }

  if (uDailyProfitOn)
  {
    if (dailyProfitCondition.evaluate()) 
		{
         if (CloseAllWhenDailyLimit) closeAll();
         return 0;
		}
  }
  if (uDailyLossOn)
  {
    if (dailyLossCondition.evaluate()) 
		{
			if (CloseAllWhenDailyLimit) closeAll();
			return 0;
		}
  }
	if (!sesionControl.doSessionControl()) { return 0; }


	 f0_14();
   f0_7();
   f0_13();
   f0_8();
   f0_10();
   f0_5();
   f0_9();
   
	 return (0);
}

bool CloseAllControl()
{
   switch (closeBy)
   {
      case CloseByMoney:
         if (floatingEA() >= closeAllMoney && closeAllMoney>0) { return true; }
         if (floatingEA() < closeAllMoneyLoss && closeAllMoneyLoss<0) { return true; }
         break;

      case CloseByAccountPercent: 
		{
         double moneyByAccountPerWin = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerWin / 100;
         double moneyByAccountPerLos = AccountInfoDouble(ACCOUNT_BALANCE) * accountPerLos / 100;

         if (floatingEA() >= moneyByAccountPerWin && moneyByAccountPerWin>0) { return true; }
         if (floatingEA() < moneyByAccountPerLos && moneyByAccountPerLos<0) { return true; }
         break;
      }
      case CloseByPips: 
      {
         double moneyLimitWin = openVolume()*closeByPipsWin*10;
         double moneyLimitLoss = -openVolume()*closeByPipsLoss*10;
         if (floatingEA() >=moneyLimitWin) {return true; }
         if (floatingEA() < moneyLimitLoss) { return true; }
         break;
      }
   }
	return false;
}

void closeAll(string side="")
{
  if (side == "buy" || side=="")
  {
    actionCloseBuys = new ActionCloseOrdersByType("buy", magico);
    actionCloseBuys.doAction();

    delete actionCloseBuys;
  }

  if (side == "sell" || side=="")
  {
    actionCloseSells = new ActionCloseOrdersByType("sell", magico);
    actionCloseSells.doAction();
    delete actionCloseSells;
  }
}

double floatingEA()
{
  double profit = 0;
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
    {
      profit += OrderProfit();
    }
  }

  return profit;
}

double openVolume()
{
  double volume = 0;
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
    {
      volume += OrderLots();
    }
  }

  return volume;
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+