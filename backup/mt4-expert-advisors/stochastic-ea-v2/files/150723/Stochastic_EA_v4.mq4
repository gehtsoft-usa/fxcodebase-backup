//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=73610

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
#property strict
#property version                                                              "1.0"
#property link                                                                 "https://www.mql5.com/en/users/wahoo"
#property copyright                                                            "Generated with Bots Builder: 2023.04.11 07:26:43"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//#define DEBUG_TRACEERRORS
//#define DEBUG_ASSERTIONS
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eTradeType
  {
   TRADETYPE_BUY,                                          // Buy
   TRADETYPE_SELL                                          // Sell
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eError
  {
   ERROR_NOERROR,                                          // No error
   ERROR_UNKNOWN,                                          // Unknown error
   ERROR_NUMBER,                                           // Error number
   ERROR_TERMINALDISCONNECTED,                             // Terminal disconnected!
   ERROR_AUTOTRADINGNOTALLOWED,                            // AutoTrading disabled!
   ERROR_OPERATIONISNOTALLOWED,                            // Operation is not allowed
   ERROR_POINTERINVALID,                                   // Pointer invalid
   ERROR_MISSINGSWITCHCASE,                                // Missing case
   ERROR_EMPTYBODYMETHODCALL,                              // Empty body method call
   ERROR_FAILEDTOSETTIMER,                                 // Failed to set timer
   ERROR_INVALIDVALUE,                                     // Invalid value!
   ERROR_INVALIDCHARACTER,                                 // Invalid character!
   ERROR_NOINPUTSTOARRANGE,                                // There is no inputs to arrange!
   ERROR_NOENDSTOARRANGE,                                  // There is no ends to arrange!
   ERROR_NOLEVELSINGRID,                                   // There is no levels in grid!
   ERROR_MASTERIDALREADYEXIST,                             // Master ID already exist!
   ERROR_INVALIDMASTERID,                                  // Invalid master ID!
   ERROR_FAILEDTOWRITEEXCHANGEFILE,                        // Failed to write exchange file!
   ERROR_FAILEDTOREADEXCHANGEFILE,                         // Failed to read exchange file!
   ERROR_EXCHANGEFILEDOESNOTEXIST,                         // Exchange file does not exist!
   ERROR_NOTENOUGHHISTORYDATA,                             // Not enough history!
   RETCODE_ORDERCHECKFAILED,                               // OrderCheck() failed
   RETCODE_NOFREEMARGIN,                                   // No free margin
   RETCODE_OPENINGNOTALLOWED,                              // Opening not allowed
   RETCODE_CLOSINGNOTALLOWED,                              // Closing not allowed
   RETCODE_TRADETYPENOTALLOWED,                            // Trade type not allowed
   RETCODE_MAXORDERS,                                      // Max orders
   RETCODE_WRONGVOLUME,                                    // Invalid volume
   RETCODE_MAXVOLUME,                                      // Max volume
   RETCODE_WRONGSTOPS,                                     // Invalid stops
   RETCODE_TRADENOTFOUND,                                  // Trade not found
   RETCODE_WRONGORDERPRICE,                                // Invalid order price
   RETCODE_ALREADYPLACED,                                  // Already placed
   RETCODE_NOTICKDATA                                      // No tick data
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eAllowedTrades
  {
   ALLOWEDTRADES_ALL,                                      // ALL
   ALLOWEDTRADES_BUYONLY,                                  // BUY Only
   ALLOWEDTRADES_SELLONLY,                                 // SELL Only
   ALLOWEDTRADES_NONE                                      // NONE
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ePendingOrderType
  {
   PENDINGORDERTYPE_BUYSTOP,                               // Buy Stop
   PENDINGORDERTYPE_SELLSTOP,                              // Sell Stop
   PENDINGORDERTYPE_BUYLIMIT,                              // Buy Limit
   PENDINGORDERTYPE_SELLLIMIT                              // Sell Limit
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eRelationType
  {
   RELATIONTYPE_GTEATER,                                   // Greater
   RELATIONTYPE_GTEATEROREQUAL,                            // Greater or Equal
   RELATIONTYPE_EQUAL,                                     // Equal
   RELATIONTYPE_LESS,                                      // Less
   RELATIONTYPE_LESSOREQUAL                                // Less or Equal
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eTradeStatus
  {
   TRADESTATUS_ALL,                                        // All
   TRADESTATUS_CURRENT,                                    // Current
   TRADESTATUS_HISTORY                                     // History
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ePendingOrderStatus
  {
   ORDERSTATUS_ALL,                                        // All
   ORDERSTATUS_PENDING,                                    // Pending
   ORDERSTATUS_HISTORY                                     // History
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eTradeInfo
  {
   TRADEINFO_TYPE,                                         // Type
   TRADEINFO_STATUS,                                       // Status
   TRADEINFO_TICKET,                                       // Ticket
   TRADEINFO_IDENTIFIER,                                   // Identifier
   TRADEINFO_SYMBOL,                                       // Symbol
   TRADEINFO_MAGIC,                                        // Magic
   TRADEINFO_COMMENT,                                      // Comment
   TRADEINFO_PROFITMONEY,                                  // Profit in Money
   TRADEINFO_COMMISSION,                                   // Commission
   TRADEINFO_SWAP,                                         // Swap
   TRADEINFO_PROFITPOINTS,                                 // Profit in Points
   TRADEINFO_LOTS,                                         // Lots
   TRADEINFO_OPENPRICE,                                    // Open Price
   TRADEINFO_CLOSEPRICE,                                   // Close Price
   TRADEINFO_STOPLOSS,                                     // Stop Loss
   TRADEINFO_TAKEPROFIT,                                   // Take Profit
   TRADEINFO_OPENTIME,                                     // Open Time
   TRADEINFO_CLOSETIME                                     // Close Time
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ePendingOrderInfo
  {
   PENDINGORDERINFO_TYPE,                                  // Type
   PENDINGORDERINFO_STATUS,                                // Status
   PENDINGORDERINFO_TICKET,                                // Ticket
   PENDINGORDERINFO_SYMBOL,                                // Symbol
   PENDINGORDERINFO_MAGIC,                                 // Magic
   PENDINGORDERINFO_COMMENT,                               // Comment
   PENDINGORDERINFO_LOTS,                                  // Lots
   PENDINGORDERINFO_OPENPRICE,                             // Open Price
   PENDINGORDERINFO_STOPLOSS,                              // Stop Loss
   PENDINGORDERINFO_TAKEPROFIT,                            // Take Profit
   PENDINGORDERINFO_EXPIRATION,                            // Expiration Time
   PENDINGORDERINFO_OPENTIME,                              // Open Time
   PENDINGORDERINFO_CLOSETIME                              // Close Time
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eTradesGroupInfo
  {
   TRADESGROUPINFO_TRADESNUMBER,                           // Trades Number
   TRADESGROUPINFO_PROFITMONEY,                            // Profit in Money
   TRADESGROUPINFO_PROFITPOINTS,                           // Profit in Points
   TRADESGROUPINFO_TOTALLOTS,                              // Total Lots
   TRADESGROUPINFO_AVERAGEPRICE,                           // Average Price
   TRADESGROUPINFO_LOWESTOPENPRICETRADETICKET,             // Lowest Open Price Trade Ticket
   TRADESGROUPINFO_HIGHESTOPENPRICETRADETICKET,            // Highest Open Price Trade Ticket
   TRADESGROUPINFO_LOWESTCLOSEPRICETRADETICKET,            // Lowest Close Price Trade Ticket
   TRADESGROUPINFO_HIGHESTCLOSEPRICETRADETICKET,           // Highest Close Price Trade Ticket
   TRADESGROUPINFO_EARLIESTOPENTIMETRADETICKET,            // Earliest Open Time Trade Ticket
   TRADESGROUPINFO_LATESTOPENTIMETRADETICKET,              // Latest Open Time Trade Ticket
   TRADESGROUPINFO_EARLIESTCLOSETIMETRADETICKET,           // Earliest Close Time Trade Ticket
   TRADESGROUPINFO_LATESTCLOSETIMETRADETICKET,             // Latest Close Time Trade Ticket
   TRADESGROUPINFO_MAXPROFITMONEYTRADETICKET,              // Max Profit Money Trade Ticket
   TRADESGROUPINFO_MINPROFITMONEYTRADETICKET,              // Min Profit Money Trade Ticket
   TRADESGROUPINFO_MAXPROFITPOINTSTRADETICKET,             // Max Profit Points Trade Ticket
   TRADESGROUPINFO_MINPROFITPOINTSTRADETICKET,             // Min Profit Points Trade Ticket
   TRADESGROUPINFO_MAXLOTTRADETICKET,                      // Max Lot Trade Ticket
   TRADESGROUPINFO_MINLOTTRADETICKET,                      // Min Lot Trade Ticket
   TRADESGROUPINFO_SYMBOLSNUMBER                           // Symbols Number
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ePendingOrdersGroupInfo
  {
   PENDINGSGROUPINFO_ORDERSNUMBER,                         // Orders Number
   PENDINGSGROUPINFO_TOTALLOTS,                            // Total Lots
   PENDINGSGROUPINFO_AVERAGEPRICE,                         // Average Price
   PENDINGSGROUPINFO_LOWESTOPENPRICEORDERTICKET,           // Lowest Open Price Order Ticket
   PENDINGSGROUPINFO_HIGHESTOPENPRICEORDERTICKET,          // Highest Open Price Order Ticket
   PENDINGSGROUPINFO_EARLIESTOPENTIMEORDERTICKET,          // Earliest Open Time Order Ticket
   PENDINGSGROUPINFO_LATESTOPENTIMEORDERTICKET,            // Latest Open Time Order Ticket
   PENDINGSGROUPINFO_EARLIESTCLOSETIMEORDERTICKET,         // Earliest Close Time Order Ticket
   PENDINGSGROUPINFO_LATESTCLOSETIMEORDERTICKET,           // Latest Close Time Order Ticket
   PENDINGSGROUPINFO_MAXLOTORDERTICKET,                    // Max Lots Order Ticket
   PENDINGSGROUPINFO_MINLOTORDERTICKET,                    // Min Lots Order Ticket
   PENDINGSGROUPINFO_SYMBOLSNUMBER                         // Symbols Number
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eIndicatorLine
  {
   INDICATORLINE_MAIN,                                     // Main
   INDICATORLINE_SIGNAL,                                   // Signal
   INDICATORLINE_UPPER,                                    // Upper
   INDICATORLINE_LOWER,                                    // Lower
   INDICATORLINE_PLUSDI,                                   // Plus Di
   INDICATORLINE_MINUSDI,                                  // Minus Di
   INDICATORLINE_GATORJAW,                                 // Jaw
   INDICATORLINE_GATORTEETH,                               // Teeth
   INDICATORLINE_GATORLIPS,                                // Lips
   INDICATORLINE_BASE,                                     // Base
   INDICATORLINE_TENKANSEN,                                // Tenkan Sen
   INDICATORLINE_KIJUNSEN,                                 // Kijun Sen
   INDICATORLINE_SENKOUSPANA,                              // Senkou Span A
   INDICATORLINE_SENKOUSPANB,                              // Senkou Span B
   INDICATORLINE_CHIKOUSPAN                                // Chikou Span
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eTimeComponent
  {
   TIMECOMPONENT_YEAR,                                     // Year
   TIMECOMPONENT_MONTH,                                    // Month
   TIMECOMPONENT_DAYOFWEEK,                                // Day of week
   TIMECOMPONENT_DAYOFMONTH,                               // Day of month
   TIMECOMPONENT_DAYOFYEAR,                                // Day of year
   TIMECOMPONENT_HOUR,                                     // Hour
   TIMECOMPONENT_MINUTE,                                   // Minute
   TIMECOMPONENT_SECOND                                    // Seconds
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eMathOperation
  {
   MATHOPERATION_SUM,                                      // Sum
   MATHOPERATION_ADD,                                      // Add
   MATHOPERATION_PROPORTIONALTOBALANCE,                    // Proportional (Balance)
   MATHOPERATION_PROPORTIONALTOEQUITY,                     // Proportional (Equity)
   MATHOPERATION_SUBTRACT,                                 // Subtract
   MATHOPERATION_DIVIDE,                                   // Divide
   MATHOPERATION_REMAINDER,                                // Remainder
   MATHOPERATION_MULTIPLY,                                 // Multiply
   MATHOPERATION_POWER,                                    // Power
   MATHOPERATION_MAXIMUM,                                  // Maximum
   MATHOPERATION_MINIMUM,                                  // Minimum
   MATHOPERATION_ROUND,                                    // Round
   MATHOPERATION_ABSOLUTE,                                 // Absolute
   MATHOPERATION_SQUAREROOT,                               // Square Root
   MATHOPERATION_LOGARITHM,                                // Logarithm
   MATHOPERATION_EXPONENT,                                 // Exponent
   MATHOPERATION_FLOOR,                                    // Floor
   MATHOPERATION_CEIL,                                     // Ceil
   MATHOPERATION_PRICETOPOINTS,                            // Price to Points
   MATHOPERATION_POINTSTOPRICE,                            // Points to Price
   MATHOPERATION_DONTSYNC,                                 // Don't sync
   MATHOPERATION_SYNCLEVELS,                               // Sync Levels
   MATHOPERATION_SYNCPOINTS,                               // Sync Points
   MATHOPERATION_OVERWRITEWITH,                            // Overwrite
   MATHOPERATION_OVERWRITEPOINTS,                          // Overwrite Points
   MATHOPERATION_KEEPORIGINAL                              // Keep original
  };


// ------------------------------------------------------------------
// v4 agrego el timer
// ------------------------------------------------------------------
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


void CheckearOrdernesyGenerarGrids()
{
  if (mainOrders.qnt() == 1)
  {
    if (mainOrders.last().type() == OP_BUY && CheckPointer(gridBuy) == POINTER_INVALID)
    {
      gridBuy = new Grid(_Symbol, "buy", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico);
    }
    if (mainOrders.last().type() == OP_SELL && CheckPointer(gridSell) == POINTER_INVALID)
    {
      gridSell = new Grid(_Symbol, "sell", mainOrders.last().price(), GridUser_gap, GridUser_multiplier, GridUser_maxCount, GridUser_maxLot, mainOrders.last().lot(), magico);
    }
  }
  if (mainOrders.qnt() == 0)
  {
    deleteGrid();
  }
}

void deleteGrid()
{
  if (CheckPointer(gridSell) != POINTER_INVALID)
  {
    delete gridSell;
  }
  if (CheckPointer(gridBuy) != POINTER_INVALID)
  {
    delete gridBuy;
  }
}

// clang-format off

void CloseAtFirstChance_Grid()
{	
	// close at first chance:
	bool   closeAtFirstChanceON = Inp_element_2975096;
	int    AfterSeconds         = Inp_element_2979904;
	double minProfit            = Inp_element_2995331;

	if(applied_first_chance_to_grid)
	{
		// si se cierra alguna orden, cerrar todo:
	
		if(CheckPointer(gridBuy) != POINTER_INVALID)
		{
	   	if (gridBuy.gridOrders.qnt() == 0) { return; }

	    for (int i = 0; i < gridBuy.gridOrders.qnt(); i++)
	    {
      	if (gridBuy.gridOrders.isClose(i)) { if(CheckPointer(gridBuy) != POINTER_INVALID) { gridBuy.closeGrid(); delete gridBuy; return;} }
	    }
		}
		if(CheckPointer(gridSell) != POINTER_INVALID)
		{
	   	if (gridSell.gridOrders.qnt() == 0) { return; }

	    for (int i = 0; i < gridSell.gridOrders.qnt(); i++)
	    {
      	if (gridSell.gridOrders.isClose(i)) { if(CheckPointer(gridSell) != POINTER_INVALID) { gridSell.closeGrid(); delete gridSell; return;} }
	    }
		}

  }
}

void doCloseGridControl()
{ 

   if(closeGridTP>0)
   {
      if(CheckPointer(gridBuy) != POINTER_INVALID)
      if(gridBuy.profit() >= closeGridTP) {gridBuy.closeGrid(); delete gridBuy; }
      if(CheckPointer(gridSell) != POINTER_INVALID)
      if(gridSell.profit() >= closeGridTP) {gridSell.closeGrid(); delete gridSell; }
   }

   if(closeGridSL<0)
   {
      if(CheckPointer(gridBuy) != POINTER_INVALID)
      if(gridBuy.profit() <= closeGridSL) {gridBuy.closeGrid(); delete gridBuy; }
      if(CheckPointer(gridSell) != POINTER_INVALID)
      if(gridSell.profit() <= closeGridSL) {gridSell.closeGrid(); delete gridSell; }
   }
}
// clang-format on




// NOTE: inputs

sinput string                                       Inp_element_875620         = "=== Fixed Lot ===";                            // === Fixed Lot ===
input bool                                          Inp_element_869616         = true;                                           // Use Fixed Lot
input double                                        Inp_element_889504         = 0.01;                                           // Fixed Lot Value
sinput string                                       Inp_element_6116877        = "=== TRADE ===";                                // === TRADE ===
input double                                        Inp_element_6118035        = 0.01;                                           // Min Trade Lot
input double                                        Inp_element_6106882        = 1;                                              // Max Trade Lot
input #ifdef __MQL4__ int #else long #endif         Inp_element_6110776        = 57575;                                          // Magic
int                                                 magico                     = Inp_element_6110776;
sinput string                                       Inp_element_6115363        = "Comment";                                      // Comment
sinput string                                       Inp_element_7468959        = "=== RSI Signal ===";                           // === RSI Signal ===
input bool                                          Inp_element_7465986        = true;                                           // Use RSI For Entry
input bool                                          Inp_element_7450142        = false;                                          // Use RSI For Exit
input bool                                          Inp_element_7452116        = false;                                          // Crossover Only
input #ifdef __MQL4__ int #else long #endif         Inp_element_7472078        = 14;                                             // RSI Period
input #ifdef __MQL4__ int #else long #endif         Inp_element_7443007        = 70;                                             // Over Bought Level
input #ifdef __MQL4__ int #else long #endif         Inp_element_7465679        = 30;                                             // Over Sold Level
sinput string                                       Inp_element_7400956        = "=== Stochastic Signal ===";                    // === Stochastic Signal ===
input bool                                          Inp_element_7412347        = true;                                           // Use Stochastic For Entry
input bool                                          Inp_element_7388977        = false;                                          // Use Stochastic For Exit
input bool                                          Inp_element_7393349        = false;                                          // Crossover Only
input #ifdef __MQL4__ int #else long #endif         Inp_element_7394140        = 5;                                              // K Period
input #ifdef __MQL4__ int #else long #endif         Inp_element_7394136        = 3;                                              // D Period
input #ifdef __MQL4__ int #else long #endif         Inp_element_7398339        = 3;                                              // Slowing
input ENUM_MA_METHOD                                Inp_element_7407110        = MODE_SMA;                                       // MA Type
sinput string                                       Inp_element_5343185        = "=== Max Trades Filter ===";                    // === Max Trades  Filter ===
input bool                                          Inp_element_5353704        = true;                                           // Use Max Trades Filter
input #ifdef __MQL4__ int #else long #endif         Inp_element_5353969        = 1;                                              // Max Total Trades
input #ifdef __MQL4__ int #else long #endif         Inp_element_5333629        = 1;                                              // Max Buy Trades
input #ifdef __MQL4__ int #else long #endif         Inp_element_5330247        = 1;                                              // Max Sell Trades
sinput string                                       Inp_element_3738477        = "=== SL & TP $$$ ===";                          // === SL & TP $$$ ===
input bool                                          Inp_element_3746915        = false;                                           // Use SL & TP $$$
input double                                        Inp_element_3737483        = 0;                                              // Stop Loss, $$$
input double                                        Inp_element_3749000        = 0;                                              // Take Profit, $$$
sinput string                                       Inp_element_2992560        = "=== Close at First Chance ===";                // === Close at First Chance ===
input bool                                          Inp_element_2975096        = false;                                           // Use Close at First Chance
input bool applied_first_chance_to_grid = true; // Applie "Close at First Chance" to Grid ?
input #ifdef __MQL4__ int #else long #endif         Inp_element_2979904        = 3600;                                           // First Chance After, seconds
input double                                        Inp_element_2995331        = 0;                                              // Min Profit, money

input string tGrid               = "== Grid Setup ==";  // ————————————
input bool   GridON              = true;               // Grid On:
input int    GridUser_maxCount   = 5;                   // Max attempts:
input double GridUser_maxLot     = 10;                  // Max lot value:
input double GridUser_multiplier = 1.5;                 // Multiplier:
input int    GridUser_gap        = 30;                  // Gap betwen orders (pips):
input bool   closeGridOn         = true;                // Use Close Grid?
input double closeGridTP         = 100;                 // Take Profit Grid $
input double closeGridSL         = -100;                // Stop Loss Grid -$

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//===============
// Forward Declaration
//===============
/*                                                             */class cInfo;
//
/*                   = final = public cInfo =                          */class cTradeInfo;
/*                   = final = public cInfo =                          */class cPendingOrderInfo;
//
/*                                                             */class cGroupInfo;
//
/*                   = final = public cGroupInfo =                     */class cTradesGroupInfo;
/*                   = final = public cGroupInfo =                     */class cPendingOrdersGroupInfo;
//
/*                                                             */class cFilter;
//
/*                   = final = public cFilter =                        */class cTradesFilter;
/*                   = final = public cFilter =                        */class cPendingOrdersFilter;
//
/*                   = final =                                 */class cTrade;
/*                   = final =                                 */class cPointer;
/*                   = final =                                 */class cArray;
/*                   = final =                                 */class cRunner;
/*                   = final =                                 */class cExecutableParameter;
//
/*                                                             */class cObject;
//
/*                   = final = public cObject    */template<typename T>class cVariable;
//
/*                                                             */class cExecutable;
/*                   = final = public cExecutable =                    */class cExecutableInputLongValue;
/*                   = final = public cExecutable =                    */class cExecutableInputBoolValue;
/*                   = final = public cExecutable =                    */class cExecutableInputDoubleValue;
/*                   = final = public cExecutable =                    */class cExecutableInputStringValue;
/*                   = final = public cExecutable =                    */class cExecutableInputMAMethodValue;
/*                           = public cExecutable =                    */class cExecutableOpen;
/*                   = final = public cExecutableOpen =                        */class cExecutableOpenTrade;
/*                           = public cExecutable =                    */class cExecutableModify;
/*                           = public cExecutableModify =                      */class cExecutableModifyCurrent;
/*                           = public cExecutableModify =                      */class cExecutableModifyPending;
/*                   = final = public cExecutableModifyCurrent =                       */class cExecutableModifyTradesGroup;
/*                   = final = public cExecutable =                    */class cExecutableCloseTradesGroup;
/*                           = public cExecutable =                    */class cExecutableTrades;
/*                   = final = public cExecutableTrades =                      */class cExecutableTradesGroup;
/*                   = final = public cExecutableTrades =                      */class cExecutableCombineTradesGroups;
/*                           = public cExecutable =                    */class cExecutableTradesGroupInfo;
/*                   = final = public cExecutableTradesGroupInfo =             */class cExecutableTradesGroupInfoInteger;
/*                   = final = public cExecutable =                    */class cExecutableArithmetic;
/*                   = final = public cExecutable =                    */class cExecutableAnd;
/*                   = final = public cExecutable =                    */class cExecutableOr;
/*                   = final = public cExecutable =                    */class cExecutableCompare;
/*                           = public cExecutable =                    */class cExecutableVariable;
/*                   = final = public cExecutableVariable =                    */class cExecutableVariableBool;
/*                   = final = public cExecutableVariable =                    */class cExecutableVariableDouble;
/*                   = final = public cExecutable =                    */class cExecutableLastServerTime;
/*                   = final = public cExecutable =                    */class cExecutableTimeModify;
/*                   = final = public cExecutable =                    */class cExecutableIndicatorValue;
/*                           = public cExecutable =                    */class cExecutableIndicator;
/*                   = final = public cExecutableIndicator =                   */class cExecutableIndicatorRSI;
/*                   = final = public cExecutableIndicator =                   */class cExecutableIndicatorStochastic;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eParameter
  {
   PARAMETER_TRIGGER,                                      // Trigger
   PARAMETER_LONGVALUE,                                    // Value (Integer)
   PARAMETER_DOUBLEVALUE,                                  // Value (Decimal)
   PARAMETER_BOOLVALUE,                                    // Logical True/False
   PARAMETER_STRINGVALUE,                                  // Value (String)
   PARAMETER_TIMEVALUE,                                    // Value (Time)
   PARAMETER_CONDITION,                                    // Condition
   PARAMETER_ORDERPRICE,                                   // Order Price
   PARAMETER_EXPIRATION,                                   // Expiration
   PARAMETER_CLOSEBY,                                      // Close By
   PARAMETER_TIGHTENSTOPSONLY,                             // Tighten Stops Only
   PARAMETER_INDICATOR,                                    // Indicator
   PARAMETER_TRADESGROUP,                                  // Trades
   PARAMETER_INDICATORPERIOD,                              // Indicator Period
   PARAMETER_KPERIOD,                                      // K Period
   PARAMETER_DPERIOD,                                      // D Period
   PARAMETER_SLOWING,                                      // Slowing
   PARAMETER_BARNUMBER,                                    // Bar Number
   PARAMETER_MAGIC,                                        // Magic
   PARAMETER_STOPLOSSPOINTS,                               // Stop Loss (Points)
   PARAMETER_TAKEPROFITPOINTS,                             // Take Profit (Points)
   PARAMETER_TICKETGREATEROREQUALTHAN,                     // Ticket Greater or Equal than
   PARAMETER_TICKETLESSOREQUALTHAN,                        // Ticket Less or Equal than
   PARAMETER_SLIPPAGE,                                     // Slippage
   PARAMETER_SYMBOLNAME,                                   // Symbol Name
   PARAMETER_COMMENT,                                      // Comment
   PARAMETER_EXACTCOMMENT,                                 // Exact Comment
   PARAMETER_COMMENTPARTIAL,                               // Partial Comment
   PARAMETER_OPENTIMEGREATEROREQUALTHAN,                   // Open Time Greater or Equal than
   PARAMETER_OPENTIMELESSOREQUALTHAN,                      // Open Time Less or Equal than
   PARAMETER_CLOSETIMEGREATEROREQUALTHAN,                  // Close Time Greater or Equal than
   PARAMETER_CLOSETIMELESSOREQUALTHAN,                     // Close Time Less or Equal than
   PARAMETER_STOPLOSSPRICE,                                // Stop Loss (Price)
   PARAMETER_STOPLOSSMONEY,                                // Stop Loss (Money)
   PARAMETER_TAKEPROFITPRICE,                              // Take Profit (Price)
   PARAMETER_TAKEPROFITMONEY,                              // Take Profit (Money)
   PARAMETER_DOUBLEVALUE1,                                 // Value #1
   PARAMETER_DOUBLEVALUE2,                                 // Value #2
   PARAMETER_PROFITGREATEROREQUALTHAN,                     // Profit Greater or Equal than
   PARAMETER_PROFITLESSOREQUALTHAN,                        // Profit Less or Equal than
   PARAMETER_OPENPRICEGREATEROREQUALTHAN,                  // Open Price Greater or Equal than
   PARAMETER_OPENPRICELESSOREQUALTHAN,                     // Open Price Less or Equal than
   PARAMETER_CLOSEPRICEGREATEROREQUALTHAN,                 // Close Price Greater or Equal than
   PARAMETER_CLOSEPRICELESSOREQUALTHAN,                    // Close Price Less or Equal than
   PARAMETER_LOTSGREATEROREQUALTHAN,                       // Lots Greater or Equal than
   PARAMETER_LOTSLESSOREQUALTHAN,                          // Lots Less or Equal than
   PARAMETER_LOTS,                                         // Lots
   PARAMETER_TIMEFRAME,                                    // Time Frame
   PARAMETER_MAMETHOD,                                     // Moving Average Method
   PARAMETER_APPLIEDPRICE,                                 // Applied Price
   PARAMETER_STOPRICE,                                     // Price Type
   PARAMETER_OUTPUTLINETYPE,                               // Line Type
   PARAMETER_TIMECOMPONENT,                                // Time Component
   PARAMETER_TRADETYPE,                                    // Trade Type
   PARAMETER_TRADESGROUPINFO,                              // Trades Information
   PARAMETER_RELATIONTYPE,                                 // Relation Type
   PARAMETER_TRADESTATUS,                                  // Trade Status
   PARAMETER_MATHOPERATION                                 // Math Operation
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define OUTPUTNONE 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define OUTPUTLONG \
   long              OutputValue;\
   virtual bool      OutPutValueGet(long &to)override final const{to=this.OutputValue;return(true);}\
   virtual bool      OutPutValueGet(double &to)override final const{to=(double)this.OutputValue;return(true);}\
   virtual bool      OutPutValueGet(string &to)override final const{to=(string)this.OutputValue;return(true);}\
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define OUTPUTBOOL \
   bool              OutputValue;\
   virtual bool      OutPutValueGet(long &to)override final const{to=(long)this.OutputValue;return(true);}\
   virtual bool      OutPutValueGet(double &to)override final const{to=(double)this.OutputValue;return(true);}\
   virtual bool      OutPutValueGet(string &to)override final const{to=(string)this.OutputValue;return(true);}\
   virtual bool      OutPutValueGet(bool &to)override final const{to=this.OutputValue;return(true);}\
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define OUTPUTDOUBLE \
   double            OutputValue;\
   virtual bool      OutPutValueGet(double &to)override final const{to=this.OutputValue;return(true);}\
   virtual bool      OutPutValueGet(string &to)override final const{to=(string)this.OutputValue;return(true);}\
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define OUTPUTSTRING \
   string            OutputValue;\
   virtual bool      OutPutValueGet(string &to)override final const{to=this.OutputValue;return(true);}\
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define OUTPUTDATETIME \
   datetime          OutputValue;\
   virtual bool      OutPutValueGet(datetime &to)override final const{to=this.OutputValue;return(true);}\
   virtual bool      OutPutValueGet(string &to)override final const{to=::TimeToString(this.OutputValue,TIME_DATE|TIME_MINUTES|TIME_SECONDS);return(true);}\
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define OUTPUTENUM(enumname) \
   enumname          OutputValue;\
   virtual bool      OutPutValueGet(enumname &to)override final const{to=this.OutputValue;return(true);}\
   virtual bool      OutPutValueGet(string &to)override final const{to=::EnumToString(this.OutputValue);return(true);}\
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define OUTPUTPOINTER \
   virtual bool      OutPutValueGet(const cExecutable *&to)const{to=::GetPointer(this);return(true);}\
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define VERTICALBAR             " | "
#define TOSTRING(expression) (#expression +" = " + (string)(expression))
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//===============
//===============
#ifdef  DEBUG_TRACEERRORS
//===============
//===============
#define TRACEERRORS_START \
int lasterror=::GetLastError();\
if(lasterror>0)\
  {\
  ::Alert("!!! TRACE ERRORS !!! (START): ",lasterror,VERTICALBAR,__FUNCSIG__,VERTICALBAR,__FILE__,VERTICALBAR,__LINE__);\
  ::DebugBreak();\
  ::ResetLastError();\
  }
//===============
//===============
#define TRACEERRORS_END \
lasterror=::GetLastError();\
if(lasterror>0)\
  {\
  string errordescription=(string)lasterror;\
  if(lasterror>=ERR_USER_ERROR_FIRST)errordescription="CUSTOM: "+(string)(lasterror-ERR_USER_ERROR_FIRST);\
  ::Alert("!!! TRACE ERRORS !!! (END): ",errordescription,VERTICALBAR,__FUNCSIG__,VERTICALBAR,__FILE__,VERTICALBAR,__LINE__);\
  ::DebugBreak();\
  ::ResetLastError();\
  }
//===============
//===============
#else
//===============
//===============
#define TRACEERRORS_START
#define TRACEERRORS_END
//===============
//===============
#endif
//===============
//===============
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//===============
//===============
#ifdef DEBUG_ASSERTIONS
//===============
//===============
#define ASSERT(executebefore,condition,skipped,executeiffailed) \
{executebefore}\
if(!(condition))\
  {\
  ::Alert("!!! ASSERT <<",#condition,">> FAILED !!! Function ",((skipped)?"Execution Skipped!!!":"Executed => "),VERTICALBAR,\
  __FUNCSIG__,VERTICALBAR,__FILE__,VERTICALBAR,__LINE__);\
  ::DebugBreak();\
  {executeiffailed}\
  }
//===============
//===============
#else
//===============
//===============
#define ASSERT(executebefore,condition,skipped,executeiffailed)
//===============
//===============
#endif
//===============
//===============
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
cRunner *Runner;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============
 
//===============
   Runner=new cRunner;
//===============
 
//===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(Runner),true,{})
//===============
 
//===============
   if(!cPointer::Valid(Runner))return(INIT_FAILED);
//===============
 
//===============
// Element: === Fixed Lot ===
//===============
   cExecutableInputStringValue *const element_875620 = new cExecutableInputStringValue;
//===============
   Runner.Add(element_875620,true);
//===============
   element_875620.ParameterAdd((string)Inp_element_875620,PARAMETER_STRINGVALUE,0,true);
//===============
 
//===============
// Element: Use Fixed Lot
//===============
   cExecutableInputBoolValue *const element_869616 = new cExecutableInputBoolValue;
//===============
   Runner.Add(element_869616,false);
//===============
   element_869616.ParameterAdd((bool)Inp_element_869616,PARAMETER_BOOLVALUE,0,true);
//===============
 
//===============
// Element: Fixed Lot Value
//===============
   cExecutableInputDoubleValue *const element_889504 = new cExecutableInputDoubleValue;
//===============
   Runner.Add(element_889504,false);
//===============
   element_889504.ParameterAdd((double)Inp_element_889504,PARAMETER_DOUBLEVALUE,0,true);
//===============
 
//===============
// Element: === TRADE ===
//===============
   cExecutableInputStringValue *const element_6116877 = new cExecutableInputStringValue;
//===============
   Runner.Add(element_6116877,true);
//===============
   element_6116877.ParameterAdd((string)Inp_element_6116877,PARAMETER_STRINGVALUE,0,true);
//===============
 
//===============
// Element: Min Trade Lot
//===============
   cExecutableInputDoubleValue *const element_6118035 = new cExecutableInputDoubleValue;
//===============
   Runner.Add(element_6118035,false);
//===============
   element_6118035.ParameterAdd((double)Inp_element_6118035,PARAMETER_DOUBLEVALUE,0,true);
//===============
 
//===============
// Element: Max Trade Lot
//===============
   cExecutableInputDoubleValue *const element_6106882 = new cExecutableInputDoubleValue;
//===============
   Runner.Add(element_6106882,false);
//===============
   element_6106882.ParameterAdd((double)Inp_element_6106882,PARAMETER_DOUBLEVALUE,0,true);
//===============
 
//===============
// Element: Magic
//===============
   cExecutableInputLongValue *const element_6110776 = new cExecutableInputLongValue;
//===============
   Runner.Add(element_6110776,false);
//===============
   element_6110776.ParameterAdd((long)Inp_element_6110776,PARAMETER_LONGVALUE,0,true);
//===============
 
//===============
// Element: Comment
//===============
   cExecutableInputStringValue *const element_6115363 = new cExecutableInputStringValue;
//===============
   Runner.Add(element_6115363,false);
//===============
   element_6115363.ParameterAdd((string)Inp_element_6115363,PARAMETER_STRINGVALUE,0,true);
//===============
 
//===============
// Element: === RSI Signal ===
//===============
   cExecutableInputStringValue *const element_7468959 = new cExecutableInputStringValue;
//===============
   Runner.Add(element_7468959,true);
//===============
   element_7468959.ParameterAdd((string)Inp_element_7468959,PARAMETER_STRINGVALUE,0,true);
//===============
 
//===============
// Element: Use RSI For Entry
//===============
   cExecutableInputBoolValue *const element_7465986 = new cExecutableInputBoolValue;
//===============
   Runner.Add(element_7465986,false);
//===============
   element_7465986.ParameterAdd((bool)Inp_element_7465986,PARAMETER_BOOLVALUE,0,true);
//===============
 
//===============
// Element: Use RSI For Exit
//===============
   cExecutableInputBoolValue *const element_7450142 = new cExecutableInputBoolValue;
//===============
   Runner.Add(element_7450142,false);
//===============
   element_7450142.ParameterAdd((bool)Inp_element_7450142,PARAMETER_BOOLVALUE,0,true);
//===============
 
//===============
// Element: Crossover Only
//===============
   cExecutableInputBoolValue *const element_7452116 = new cExecutableInputBoolValue;
//===============
   Runner.Add(element_7452116,false);
//===============
   element_7452116.ParameterAdd((bool)Inp_element_7452116,PARAMETER_BOOLVALUE,0,true);
//===============
 
//===============
// Element: RSI Period
//===============
   cExecutableInputLongValue *const element_7472078 = new cExecutableInputLongValue;
//===============
   Runner.Add(element_7472078,false);
//===============
   element_7472078.ParameterAdd((long)Inp_element_7472078,PARAMETER_LONGVALUE,0,true);
//===============
 
//===============
// Element: Over Bought Level
//===============
   cExecutableInputLongValue *const element_7443007 = new cExecutableInputLongValue;
//===============
   Runner.Add(element_7443007,false);
//===============
   element_7443007.ParameterAdd((long)Inp_element_7443007,PARAMETER_LONGVALUE,0,true);
//===============
 
//===============
// Element: Over Sold Level
//===============
   cExecutableInputLongValue *const element_7465679 = new cExecutableInputLongValue;
//===============
   Runner.Add(element_7465679,false);
//===============
   element_7465679.ParameterAdd((long)Inp_element_7465679,PARAMETER_LONGVALUE,0,true);
//===============
 
//===============
// Element: === Stochastic Signal ===
//===============
   cExecutableInputStringValue *const element_7400956 = new cExecutableInputStringValue;
//===============
   Runner.Add(element_7400956,true);
//===============
   element_7400956.ParameterAdd((string)Inp_element_7400956,PARAMETER_STRINGVALUE,0,true);
//===============
 
//===============
// Element: Use Stochastic For Entry
//===============
   cExecutableInputBoolValue *const element_7412347 = new cExecutableInputBoolValue;
//===============
   Runner.Add(element_7412347,false);
//===============
   element_7412347.ParameterAdd((bool)Inp_element_7412347,PARAMETER_BOOLVALUE,0,true);
//===============
 
//===============
// Element: Use Stochastic For Exit
//===============
   cExecutableInputBoolValue *const element_7388977 = new cExecutableInputBoolValue;
//===============
   Runner.Add(element_7388977,false);
//===============
   element_7388977.ParameterAdd((bool)Inp_element_7388977,PARAMETER_BOOLVALUE,0,true);
//===============
 
//===============
// Element: Crossover Only
//===============
   cExecutableInputBoolValue *const element_7393349 = new cExecutableInputBoolValue;
//===============
   Runner.Add(element_7393349,false);
//===============
   element_7393349.ParameterAdd((bool)Inp_element_7393349,PARAMETER_BOOLVALUE,0,true);
//===============
 
//===============
// Element: K Period
//===============
   cExecutableInputLongValue *const element_7394140 = new cExecutableInputLongValue;
//===============
   Runner.Add(element_7394140,false);
//===============
   element_7394140.ParameterAdd((long)Inp_element_7394140,PARAMETER_LONGVALUE,0,true);
//===============
 
//===============
// Element: D Period
//===============
   cExecutableInputLongValue *const element_7394136 = new cExecutableInputLongValue;
//===============
   Runner.Add(element_7394136,false);
//===============
   element_7394136.ParameterAdd((long)Inp_element_7394136,PARAMETER_LONGVALUE,0,true);
//===============
 
//===============
// Element: Slowing
//===============
   cExecutableInputLongValue *const element_7398339 = new cExecutableInputLongValue;
//===============
   Runner.Add(element_7398339,false);
//===============
   element_7398339.ParameterAdd((long)Inp_element_7398339,PARAMETER_LONGVALUE,0,true);
//===============
 
//===============
// Element: MA Type
//===============
   cExecutableInputMAMethodValue *const element_7407110 = new cExecutableInputMAMethodValue;
//===============
   Runner.Add(element_7407110,false);
//===============
   element_7407110.ParameterAdd((ENUM_MA_METHOD)Inp_element_7407110,PARAMETER_MAMETHOD,0,true);
//===============
 
//===============
// Element: === Max Trades  Filter ===
//===============
   cExecutableInputStringValue *const element_5343185 = new cExecutableInputStringValue;
//===============
   Runner.Add(element_5343185,true);
//===============
   element_5343185.ParameterAdd((string)Inp_element_5343185,PARAMETER_STRINGVALUE,0,true);
//===============
 
//===============
// Element: Use Max Trades Filter
//===============
   cExecutableInputBoolValue *const element_5353704 = new cExecutableInputBoolValue;
//===============
   Runner.Add(element_5353704,false);
//===============
   element_5353704.ParameterAdd((bool)Inp_element_5353704,PARAMETER_BOOLVALUE,0,true);
//===============
 
//===============
// Element: Max Total Trades
//===============
   cExecutableInputLongValue *const element_5353969 = new cExecutableInputLongValue;
//===============
   Runner.Add(element_5353969,false);
//===============
   element_5353969.ParameterAdd((long)Inp_element_5353969,PARAMETER_LONGVALUE,0,true);
//===============
 
//===============
// Element: Max Buy Trades
//===============
   cExecutableInputLongValue *const element_5333629 = new cExecutableInputLongValue;
//===============
   Runner.Add(element_5333629,false);
//===============
   element_5333629.ParameterAdd((long)Inp_element_5333629,PARAMETER_LONGVALUE,0,true);
//===============
 
//===============
// Element: Max Sell Trades
//===============
   cExecutableInputLongValue *const element_5330247 = new cExecutableInputLongValue;
//===============
   Runner.Add(element_5330247,false);
//===============
   element_5330247.ParameterAdd((long)Inp_element_5330247,PARAMETER_LONGVALUE,0,true);
//===============
 
//===============
// Element: === SL & TP $$$ ===
//===============
   cExecutableInputStringValue *const element_3738477 = new cExecutableInputStringValue;
//===============
   Runner.Add(element_3738477,true);
//===============
   element_3738477.ParameterAdd((string)Inp_element_3738477,PARAMETER_STRINGVALUE,0,true);
//===============
 
//===============
// Element: Use SL & TP $$$
//===============
   cExecutableInputBoolValue *const element_3746915 = new cExecutableInputBoolValue;
//===============
   Runner.Add(element_3746915,false);
//===============
   element_3746915.ParameterAdd((bool)Inp_element_3746915,PARAMETER_BOOLVALUE,0,true);
//===============
 
//===============
// Element: Stop Loss, $$$
//===============
   cExecutableInputDoubleValue *const element_3737483 = new cExecutableInputDoubleValue;
//===============
   Runner.Add(element_3737483,false);
//===============
   element_3737483.ParameterAdd((double)Inp_element_3737483,PARAMETER_DOUBLEVALUE,0,true);
//===============
 
//===============
// Element: Take Profit, $$$
//===============
   cExecutableInputDoubleValue *const element_3749000 = new cExecutableInputDoubleValue;
//===============
   Runner.Add(element_3749000,false);
//===============
   element_3749000.ParameterAdd((double)Inp_element_3749000,PARAMETER_DOUBLEVALUE,0,true);
//===============
 
//===============
// Element: === Close at First Chance ===
//===============
   cExecutableInputStringValue *const element_2992560 = new cExecutableInputStringValue;
//===============
   Runner.Add(element_2992560,true);
//===============
   element_2992560.ParameterAdd((string)Inp_element_2992560,PARAMETER_STRINGVALUE,0,true);
//===============
 
//===============
// Element: Use Close at First Chance
//===============
   cExecutableInputBoolValue *const element_2975096 = new cExecutableInputBoolValue;
//===============
   Runner.Add(element_2975096,false);
//===============
   element_2975096.ParameterAdd((bool)Inp_element_2975096,PARAMETER_BOOLVALUE,0,true);
//===============
 
//===============
// Element: First Chance After, seconds
//===============
   cExecutableInputLongValue *const element_2979904 = new cExecutableInputLongValue;
//===============
   Runner.Add(element_2979904,false);
//===============
   element_2979904.ParameterAdd((long)Inp_element_2979904,PARAMETER_LONGVALUE,0,true);
//===============
 
//===============
// Element: Min Profit, money
//===============
   cExecutableInputDoubleValue *const element_2995331 = new cExecutableInputDoubleValue;
//===============
   Runner.Add(element_2995331,false);
//===============
   element_2995331.ParameterAdd((double)Inp_element_2995331,PARAMETER_DOUBLEVALUE,0,true);
//===============
 
//===============
// Element: Close Buys
//===============
   cExecutableCloseTradesGroup *const element_6122480 = new cExecutableCloseTradesGroup;
//===============
   Runner.Add(element_6122480,true);
//===============
   element_6122480.ParameterAdd((bool)false,PARAMETER_CLOSEBY,2,true);
//===============
   element_6122480.ParameterAdd((long)30,PARAMETER_SLIPPAGE,3,true);
//===============
 
//===============
// Element: Close Sells
//===============
   cExecutableCloseTradesGroup *const element_6109893 = new cExecutableCloseTradesGroup;
//===============
   Runner.Add(element_6109893,true);
//===============
   element_6109893.ParameterAdd((bool)false,PARAMETER_CLOSEBY,2,true);
//===============
   element_6109893.ParameterAdd((long)30,PARAMETER_SLIPPAGE,3,true);
//===============
 
//===============
// Element: Open Buy
//===============
   cExecutableOpenTrade *const element_6105181 = new cExecutableOpenTrade;
//===============
   Runner.Add(element_6105181,true);
//===============
   element_6105181.ParameterAdd((string)::Symbol(),PARAMETER_SYMBOLNAME,1,true);
//===============
   element_6105181.ParameterAdd((eTradeType)TRADETYPE_BUY,PARAMETER_TRADETYPE,2,true);
//===============
   element_6105181.ParameterAdd((long)0,PARAMETER_STOPLOSSPOINTS,6,false);
//===============
   element_6105181.ParameterAdd((long)0,PARAMETER_TAKEPROFITPOINTS,7,false);
//===============
   element_6105181.ParameterAdd((double)0.0,PARAMETER_STOPLOSSMONEY,8,false);
//===============
   element_6105181.ParameterAdd((double)0.0,PARAMETER_TAKEPROFITMONEY,9,false);
//===============
   element_6105181.ParameterAdd((double)0.0,PARAMETER_STOPLOSSPRICE,10,false);
//===============
   element_6105181.ParameterAdd((double)0.0,PARAMETER_TAKEPROFITPRICE,11,false);
//===============
   element_6105181.ParameterAdd((long)30,PARAMETER_SLIPPAGE,12,true);
//===============
 
//===============
// Element: Open Sell
//===============
   cExecutableOpenTrade *const element_6122434 = new cExecutableOpenTrade;
//===============
   Runner.Add(element_6122434,true);
//===============
   element_6122434.ParameterAdd((string)::Symbol(),PARAMETER_SYMBOLNAME,1,true);
//===============
   element_6122434.ParameterAdd((eTradeType)TRADETYPE_SELL,PARAMETER_TRADETYPE,2,true);
//===============
   element_6122434.ParameterAdd((long)0,PARAMETER_STOPLOSSPOINTS,6,false);
//===============
   element_6122434.ParameterAdd((long)0,PARAMETER_TAKEPROFITPOINTS,7,false);
//===============
   element_6122434.ParameterAdd((double)0.0,PARAMETER_STOPLOSSMONEY,8,false);
//===============
   element_6122434.ParameterAdd((double)0.0,PARAMETER_TAKEPROFITMONEY,9,false);
//===============
   element_6122434.ParameterAdd((double)0.0,PARAMETER_STOPLOSSPRICE,10,false);
//===============
   element_6122434.ParameterAdd((double)0.0,PARAMETER_TAKEPROFITPRICE,11,false);
//===============
   element_6122434.ParameterAdd((long)30,PARAMETER_SLIPPAGE,12,true);
//===============
 
//===============
// Element: Set SL and TP
//===============
   cExecutableModifyTradesGroup *const element_3752709 = new cExecutableModifyTradesGroup;
//===============
   Runner.Add(element_3752709,true);
//===============
   element_3752709.ParameterAdd((bool)true,PARAMETER_TIGHTENSTOPSONLY,2,true);
//===============
   element_3752709.ParameterAdd((long)0,PARAMETER_STOPLOSSPOINTS,3,false);
//===============
   element_3752709.ParameterAdd((long)0,PARAMETER_TAKEPROFITPOINTS,4,false);
//===============
   element_3752709.ParameterAdd((double)0.0,PARAMETER_STOPLOSSPRICE,7,false);
//===============
   element_3752709.ParameterAdd((double)0.0,PARAMETER_TAKEPROFITPRICE,8,false);
//===============
 
//===============
// Element: Close Trades at First Chance
//===============
   cExecutableCloseTradesGroup *const element_2976086 = new cExecutableCloseTradesGroup;
//===============
   Runner.Add(element_2976086,true);
//===============
   element_2976086.ParameterAdd((bool)false,PARAMETER_CLOSEBY,2,true);
//===============
   element_2976086.ParameterAdd((long)30,PARAMETER_SLIPPAGE,3,true);
//===============
 
//===============
// Element: Buy Trades
//===============
   cExecutableTradesGroup *const element_6118190 = new cExecutableTradesGroup;
//===============
   Runner.Add(element_6118190,false);
//===============
   element_6118190.ParameterAdd((eTradeStatus)TRADESTATUS_CURRENT,PARAMETER_TRADESTATUS,0,true);
//===============
   element_6118190.ParameterAdd((string)::Symbol(),PARAMETER_SYMBOLNAME,1,true);
//===============
   element_6118190.ParameterAdd((eTradeType)TRADETYPE_BUY,PARAMETER_TRADETYPE,3,true);
//===============
   element_6118190.ParameterAdd((string)"Comment",PARAMETER_EXACTCOMMENT,4,false);
//===============
   element_6118190.ParameterAdd((string)"Comment",PARAMETER_COMMENTPARTIAL,5,false);
//===============
   element_6118190.ParameterAdd((double)0.0,PARAMETER_PROFITGREATEROREQUALTHAN,6,false);
//===============
   element_6118190.ParameterAdd((double)0.0,PARAMETER_PROFITLESSOREQUALTHAN,7,false);
//===============
   element_6118190.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_OPENTIMEGREATEROREQUALTHAN,8,false);
//===============
   element_6118190.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_OPENTIMELESSOREQUALTHAN,9,false);
//===============
   element_6118190.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_CLOSETIMEGREATEROREQUALTHAN,10,false);
//===============
   element_6118190.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_CLOSETIMELESSOREQUALTHAN,11,false);
//===============
   element_6118190.ParameterAdd((double)0.0,PARAMETER_OPENPRICEGREATEROREQUALTHAN,12,false);
//===============
   element_6118190.ParameterAdd((double)0.0,PARAMETER_OPENPRICELESSOREQUALTHAN,13,false);
//===============
   element_6118190.ParameterAdd((double)0.0,PARAMETER_CLOSEPRICEGREATEROREQUALTHAN,14,false);
//===============
   element_6118190.ParameterAdd((double)0.0,PARAMETER_CLOSEPRICELESSOREQUALTHAN,15,false);
//===============
   element_6118190.ParameterAdd((double)0.0,PARAMETER_LOTSGREATEROREQUALTHAN,16,false);
//===============
   element_6118190.ParameterAdd((double)0.0,PARAMETER_LOTSLESSOREQUALTHAN,17,false);
//===============
   element_6118190.ParameterAdd((long)0,PARAMETER_TICKETGREATEROREQUALTHAN,18,false);
//===============
   element_6118190.ParameterAdd((long)0,PARAMETER_TICKETLESSOREQUALTHAN,19,false);
//===============
 
//===============
// Element: Sell Trades
//===============
   cExecutableTradesGroup *const element_6116897 = new cExecutableTradesGroup;
//===============
   Runner.Add(element_6116897,false);
//===============
   element_6116897.ParameterAdd((eTradeStatus)TRADESTATUS_CURRENT,PARAMETER_TRADESTATUS,0,true);
//===============
   element_6116897.ParameterAdd((string)::Symbol(),PARAMETER_SYMBOLNAME,1,true);
//===============
   element_6116897.ParameterAdd((eTradeType)TRADETYPE_SELL,PARAMETER_TRADETYPE,3,true);
//===============
   element_6116897.ParameterAdd((string)"Comment",PARAMETER_EXACTCOMMENT,4,false);
//===============
   element_6116897.ParameterAdd((string)"Comment",PARAMETER_COMMENTPARTIAL,5,false);
//===============
   element_6116897.ParameterAdd((double)0.0,PARAMETER_PROFITGREATEROREQUALTHAN,6,false);
//===============
   element_6116897.ParameterAdd((double)0.0,PARAMETER_PROFITLESSOREQUALTHAN,7,false);
//===============
   element_6116897.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_OPENTIMEGREATEROREQUALTHAN,8,false);
//===============
   element_6116897.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_OPENTIMELESSOREQUALTHAN,9,false);
//===============
   element_6116897.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_CLOSETIMEGREATEROREQUALTHAN,10,false);
//===============
   element_6116897.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_CLOSETIMELESSOREQUALTHAN,11,false);
//===============
   element_6116897.ParameterAdd((double)0.0,PARAMETER_OPENPRICEGREATEROREQUALTHAN,12,false);
//===============
   element_6116897.ParameterAdd((double)0.0,PARAMETER_OPENPRICELESSOREQUALTHAN,13,false);
//===============
   element_6116897.ParameterAdd((double)0.0,PARAMETER_CLOSEPRICEGREATEROREQUALTHAN,14,false);
//===============
   element_6116897.ParameterAdd((double)0.0,PARAMETER_CLOSEPRICELESSOREQUALTHAN,15,false);
//===============
   element_6116897.ParameterAdd((double)0.0,PARAMETER_LOTSGREATEROREQUALTHAN,16,false);
//===============
   element_6116897.ParameterAdd((double)0.0,PARAMETER_LOTSLESSOREQUALTHAN,17,false);
//===============
   element_6116897.ParameterAdd((long)0,PARAMETER_TICKETGREATEROREQUALTHAN,18,false);
//===============
   element_6116897.ParameterAdd((long)0,PARAMETER_TICKETLESSOREQUALTHAN,19,false);
//===============
 
//===============
// Element: Buy Trades
//===============
   cExecutableTradesGroup *const element_5337260 = new cExecutableTradesGroup;
//===============
   Runner.Add(element_5337260,false);
//===============
   element_5337260.ParameterAdd((eTradeStatus)TRADESTATUS_CURRENT,PARAMETER_TRADESTATUS,0,true);
//===============
   element_5337260.ParameterAdd((string)::Symbol(),PARAMETER_SYMBOLNAME,1,true);
//===============
   element_5337260.ParameterAdd((eTradeType)TRADETYPE_BUY,PARAMETER_TRADETYPE,3,true);
//===============
   element_5337260.ParameterAdd((string)"Comment",PARAMETER_EXACTCOMMENT,4,false);
//===============
   element_5337260.ParameterAdd((string)"Comment",PARAMETER_COMMENTPARTIAL,5,false);
//===============
   element_5337260.ParameterAdd((double)0.0,PARAMETER_PROFITGREATEROREQUALTHAN,6,false);
//===============
   element_5337260.ParameterAdd((double)0.0,PARAMETER_PROFITLESSOREQUALTHAN,7,false);
//===============
   element_5337260.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_OPENTIMEGREATEROREQUALTHAN,8,false);
//===============
   element_5337260.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_OPENTIMELESSOREQUALTHAN,9,false);
//===============
   element_5337260.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_CLOSETIMEGREATEROREQUALTHAN,10,false);
//===============
   element_5337260.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_CLOSETIMELESSOREQUALTHAN,11,false);
//===============
   element_5337260.ParameterAdd((double)0.0,PARAMETER_OPENPRICEGREATEROREQUALTHAN,12,false);
//===============
   element_5337260.ParameterAdd((double)0.0,PARAMETER_OPENPRICELESSOREQUALTHAN,13,false);
//===============
   element_5337260.ParameterAdd((double)0.0,PARAMETER_CLOSEPRICEGREATEROREQUALTHAN,14,false);
//===============
   element_5337260.ParameterAdd((double)0.0,PARAMETER_CLOSEPRICELESSOREQUALTHAN,15,false);
//===============
   element_5337260.ParameterAdd((double)0.0,PARAMETER_LOTSGREATEROREQUALTHAN,16,false);
//===============
   element_5337260.ParameterAdd((double)0.0,PARAMETER_LOTSLESSOREQUALTHAN,17,false);
//===============
   element_5337260.ParameterAdd((long)0,PARAMETER_TICKETGREATEROREQUALTHAN,18,false);
//===============
   element_5337260.ParameterAdd((long)0,PARAMETER_TICKETLESSOREQUALTHAN,19,false);
//===============
 
//===============
// Element: Sell Trades
//===============
   cExecutableTradesGroup *const element_5339705 = new cExecutableTradesGroup;
//===============
   Runner.Add(element_5339705,false);
//===============
   element_5339705.ParameterAdd((eTradeStatus)TRADESTATUS_CURRENT,PARAMETER_TRADESTATUS,0,true);
//===============
   element_5339705.ParameterAdd((string)::Symbol(),PARAMETER_SYMBOLNAME,1,true);
//===============
   element_5339705.ParameterAdd((eTradeType)TRADETYPE_SELL,PARAMETER_TRADETYPE,3,true);
//===============
   element_5339705.ParameterAdd((string)"Comment",PARAMETER_EXACTCOMMENT,4,false);
//===============
   element_5339705.ParameterAdd((string)"Comment",PARAMETER_COMMENTPARTIAL,5,false);
//===============
   element_5339705.ParameterAdd((double)0.0,PARAMETER_PROFITGREATEROREQUALTHAN,6,false);
//===============
   element_5339705.ParameterAdd((double)0.0,PARAMETER_PROFITLESSOREQUALTHAN,7,false);
//===============
   element_5339705.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_OPENTIMEGREATEROREQUALTHAN,8,false);
//===============
   element_5339705.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_OPENTIMELESSOREQUALTHAN,9,false);
//===============
   element_5339705.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_CLOSETIMEGREATEROREQUALTHAN,10,false);
//===============
   element_5339705.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_CLOSETIMELESSOREQUALTHAN,11,false);
//===============
   element_5339705.ParameterAdd((double)0.0,PARAMETER_OPENPRICEGREATEROREQUALTHAN,12,false);
//===============
   element_5339705.ParameterAdd((double)0.0,PARAMETER_OPENPRICELESSOREQUALTHAN,13,false);
//===============
   element_5339705.ParameterAdd((double)0.0,PARAMETER_CLOSEPRICEGREATEROREQUALTHAN,14,false);
//===============
   element_5339705.ParameterAdd((double)0.0,PARAMETER_CLOSEPRICELESSOREQUALTHAN,15,false);
//===============
   element_5339705.ParameterAdd((double)0.0,PARAMETER_LOTSGREATEROREQUALTHAN,16,false);
//===============
   element_5339705.ParameterAdd((double)0.0,PARAMETER_LOTSLESSOREQUALTHAN,17,false);
//===============
   element_5339705.ParameterAdd((long)0,PARAMETER_TICKETGREATEROREQUALTHAN,18,false);
//===============
   element_5339705.ParameterAdd((long)0,PARAMETER_TICKETLESSOREQUALTHAN,19,false);
//===============
 
//===============
// Element: Trades To Close
//===============
   cExecutableTradesGroup *const element_2988541 = new cExecutableTradesGroup;
//===============
   Runner.Add(element_2988541,false);
//===============
   element_2988541.ParameterAdd((eTradeStatus)TRADESTATUS_CURRENT,PARAMETER_TRADESTATUS,0,true);
//===============
   element_2988541.ParameterAdd((string)::Symbol(),PARAMETER_SYMBOLNAME,1,true);
//===============
   element_2988541.ParameterAdd((eTradeType)TRADETYPE_BUY,PARAMETER_TRADETYPE,3,false);
//===============
   element_2988541.ParameterAdd((string)"Comment",PARAMETER_EXACTCOMMENT,4,false);
//===============
   element_2988541.ParameterAdd((string)"Comment",PARAMETER_COMMENTPARTIAL,5,false);
//===============
   element_2988541.ParameterAdd((double)0.0,PARAMETER_PROFITLESSOREQUALTHAN,7,false);
//===============
   element_2988541.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_OPENTIMEGREATEROREQUALTHAN,8,false);
//===============
   element_2988541.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_CLOSETIMEGREATEROREQUALTHAN,10,false);
//===============
   element_2988541.ParameterAdd((datetime)D'1970.01.01 00:00:00',PARAMETER_CLOSETIMELESSOREQUALTHAN,11,false);
//===============
   element_2988541.ParameterAdd((double)0.0,PARAMETER_OPENPRICEGREATEROREQUALTHAN,12,false);
//===============
   element_2988541.ParameterAdd((double)0.0,PARAMETER_OPENPRICELESSOREQUALTHAN,13,false);
//===============
   element_2988541.ParameterAdd((double)0.0,PARAMETER_CLOSEPRICEGREATEROREQUALTHAN,14,false);
//===============
   element_2988541.ParameterAdd((double)0.0,PARAMETER_CLOSEPRICELESSOREQUALTHAN,15,false);
//===============
   element_2988541.ParameterAdd((double)0.0,PARAMETER_LOTSGREATEROREQUALTHAN,16,false);
//===============
   element_2988541.ParameterAdd((double)0.0,PARAMETER_LOTSLESSOREQUALTHAN,17,false);
//===============
   element_2988541.ParameterAdd((long)0,PARAMETER_TICKETGREATEROREQUALTHAN,18,false);
//===============
   element_2988541.ParameterAdd((long)0,PARAMETER_TICKETLESSOREQUALTHAN,19,false);
//===============
 
//===============
// Element: Trades
//===============
   cExecutableCombineTradesGroups *const element_3734769 = new cExecutableCombineTradesGroups;
//===============
   Runner.Add(element_3734769,false);
//===============
 
//===============
// Element: Buy Trades Number
//===============
   cExecutableTradesGroupInfoInteger *const element_5325323 = new cExecutableTradesGroupInfoInteger;
//===============
   Runner.Add(element_5325323,false);
//===============
   element_5325323.ParameterAdd((eTradesGroupInfo)TRADESGROUPINFO_TRADESNUMBER,PARAMETER_TRADESGROUPINFO,1,true);
//===============
 
//===============
// Element: Sell Trades Number
//===============
   cExecutableTradesGroupInfoInteger *const element_5332221 = new cExecutableTradesGroupInfoInteger;
//===============
   Runner.Add(element_5332221,false);
//===============
   element_5332221.ParameterAdd((eTradesGroupInfo)TRADESGROUPINFO_TRADESNUMBER,PARAMETER_TRADESGROUPINFO,1,true);
//===============
 
//===============
// Element: Total Trades Number
//===============
   cExecutableArithmetic *const element_5338513 = new cExecutableArithmetic;
//===============
   Runner.Add(element_5338513,false);
//===============
   element_5338513.ParameterAdd((bool)true,PARAMETER_TRIGGER,0,true);
//===============
   element_5338513.ParameterAdd((eMathOperation)MATHOPERATION_SUM,PARAMETER_MATHOPERATION,2,true);
//===============
 
//===============
// Element: Valid Buy Lot
//===============
   cExecutableAnd *const element_6124632 = new cExecutableAnd;
//===============
   Runner.Add(element_6124632,false);
//===============
 
//===============
// Element: Valid Sell Lot
//===============
   cExecutableAnd *const element_6108016 = new cExecutableAnd;
//===============
   Runner.Add(element_6108016,false);
//===============
 
//===============
// Element: Buy Trigger
//===============
   cExecutableAnd *const element_6101078 = new cExecutableAnd;
//===============
   Runner.Add(element_6101078,false);
//===============
 
//===============
// Element: Sell Trigger
//===============
   cExecutableAnd *const element_6098915 = new cExecutableAnd;
//===============
   Runner.Add(element_6098915,false);
//===============
 
//===============
// Element: RSI Close Sell Signal
//===============
   cExecutableAnd *const element_7440357 = new cExecutableAnd;
//===============
   Runner.Add(element_7440357,false);
//===============
 
//===============
// Element: RSI Close Buy Signal
//===============
   cExecutableAnd *const element_7462330 = new cExecutableAnd;
//===============
   Runner.Add(element_7462330,false);
//===============
 
//===============
// Element: RSI Buy
//===============
   cExecutableAnd *const element_7470568 = new cExecutableAnd;
//===============
   Runner.Add(element_7470568,false);
//===============
 
//===============
// Element: RSI Sell
//===============
   cExecutableAnd *const element_7450338 = new cExecutableAnd;
//===============
   Runner.Add(element_7450338,false);
//===============
 
//===============
// Element: Stochastic Close Buy Signal
//===============
   cExecutableAnd *const element_7410053 = new cExecutableAnd;
//===============
   Runner.Add(element_7410053,false);
//===============
 
//===============
// Element: Stochastic Close Sell Signal
//===============
   cExecutableAnd *const element_7395738 = new cExecutableAnd;
//===============
   Runner.Add(element_7395738,false);
//===============
 
//===============
// Element: Stochastic Buy
//===============
   cExecutableAnd *const element_7414899 = new cExecutableAnd;
//===============
   Runner.Add(element_7414899,false);
//===============
 
//===============
// Element: Stochastic Sell
//===============
   cExecutableAnd *const element_7414632 = new cExecutableAnd;
//===============
   Runner.Add(element_7414632,false);
//===============
 
//===============
// Element: Buy Filter
//===============
   cExecutableAnd *const element_5351843 = new cExecutableAnd;
//===============
   Runner.Add(element_5351843,false);
//===============
 
//===============
// Element: Sell Filter
//===============
   cExecutableAnd *const element_5340816 = new cExecutableAnd;
//===============
   Runner.Add(element_5340816,false);
//===============
 
//===============
// Element: Enabled Signals
//===============
   cExecutableOr *const element_6110695 = new cExecutableOr;
//===============
   Runner.Add(element_6110695,false);
//===============
 
//===============
// Element: Close Sell Trigger
//===============
   cExecutableOr *const element_6118956 = new cExecutableOr;
//===============
   Runner.Add(element_6118956,false);
//===============
 
//===============
// Element: Close Buy Trigger
//===============
   cExecutableOr *const element_6115054 = new cExecutableOr;
//===============
   Runner.Add(element_6115054,false);
//===============
 
//===============
// Element: Crossover
//===============
   cExecutableOr *const element_7440510 = new cExecutableOr;
//===============
   Runner.Add(element_7440510,false);
//===============
 
//===============
// Element: Crossover
//===============
   cExecutableOr *const element_7465982 = new cExecutableOr;
//===============
   Runner.Add(element_7465982,false);
//===============
 
//===============
// Element: Crossover
//===============
   cExecutableOr *const element_7420193 = new cExecutableOr;
//===============
   Runner.Add(element_7420193,false);
//===============
 
//===============
// Element: Crossover
//===============
   cExecutableOr *const element_7402083 = new cExecutableOr;
//===============
   Runner.Add(element_7402083,false);
//===============
 
//===============
// Element: Lot Below Min
//===============
   cExecutableCompare *const element_6103246 = new cExecutableCompare;
//===============
   Runner.Add(element_6103246,false);
//===============
   element_6103246.ParameterAdd((eRelationType)RELATIONTYPE_LESS,PARAMETER_RELATIONTYPE,1,true);
//===============
 
//===============
// Element: Lot Below Min
//===============
   cExecutableCompare *const element_6108115 = new cExecutableCompare;
//===============
   Runner.Add(element_6108115,false);
//===============
   element_6108115.ParameterAdd((eRelationType)RELATIONTYPE_LESS,PARAMETER_RELATIONTYPE,1,true);
//===============
 
//===============
// Element: Lot Above Max
//===============
   cExecutableCompare *const element_6099990 = new cExecutableCompare;
//===============
   Runner.Add(element_6099990,false);
//===============
   element_6099990.ParameterAdd((eRelationType)RELATIONTYPE_GTEATER,PARAMETER_RELATIONTYPE,1,true);
//===============
 
//===============
// Element: Lot Above Max
//===============
   cExecutableCompare *const element_6114859 = new cExecutableCompare;
//===============
   Runner.Add(element_6114859,false);
//===============
   element_6114859.ParameterAdd((eRelationType)RELATIONTYPE_GTEATER,PARAMETER_RELATIONTYPE,1,true);
//===============
 
//===============
// Element: Valid Value
//===============
   cExecutableCompare *const element_7443955 = new cExecutableCompare;
//===============
   Runner.Add(element_7443955,false);
//===============
   element_7443955.ParameterAdd((eRelationType)RELATIONTYPE_GTEATER,PARAMETER_RELATIONTYPE,1,true);
//===============
   element_7443955.ParameterAdd((double)0.0,PARAMETER_DOUBLEVALUE2,2,true);
//===============
 
//===============
// Element: Valid Value
//===============
   cExecutableCompare *const element_7467706 = new cExecutableCompare;
//===============
   Runner.Add(element_7467706,false);
//===============
   element_7467706.ParameterAdd((eRelationType)RELATIONTYPE_GTEATER,PARAMETER_RELATIONTYPE,1,true);
//===============
   element_7467706.ParameterAdd((double)0.0,PARAMETER_DOUBLEVALUE2,2,true);
//===============
 
//===============
// Element: OverBought Previous
//===============
   cExecutableCompare *const element_7453309 = new cExecutableCompare;
//===============
   Runner.Add(element_7453309,false);
//===============
   element_7453309.ParameterAdd((eRelationType)RELATIONTYPE_GTEATER,PARAMETER_RELATIONTYPE,1,true);
//===============
 
//===============
// Element: OverSold Previous
//===============
   cExecutableCompare *const element_7457979 = new cExecutableCompare;
//===============
   Runner.Add(element_7457979,false);
//===============
   element_7457979.ParameterAdd((eRelationType)RELATIONTYPE_LESS,PARAMETER_RELATIONTYPE,1,true);
//===============
 
//===============
// Element: OverSold Now
//===============
   cExecutableCompare *const element_7450439 = new cExecutableCompare;
//===============
   Runner.Add(element_7450439,false);
//===============
   element_7450439.ParameterAdd((eRelationType)RELATIONTYPE_LESS,PARAMETER_RELATIONTYPE,1,true);
//===============
 
//===============
// Element: OverBought Now
//===============
   cExecutableCompare *const element_7448505 = new cExecutableCompare;
//===============
   Runner.Add(element_7448505,false);
//===============
   element_7448505.ParameterAdd((eRelationType)RELATIONTYPE_GTEATER,PARAMETER_RELATIONTYPE,1,true);
//===============
 
//===============
// Element: Main > Signal Current
//===============
   cExecutableCompare *const element_7415065 = new cExecutableCompare;
//===============
   Runner.Add(element_7415065,false);
//===============
   element_7415065.ParameterAdd((eRelationType)RELATIONTYPE_GTEATER,PARAMETER_RELATIONTYPE,1,true);
//===============
 
//===============
// Element: Main > Signal Previous
//===============
   cExecutableCompare *const element_7414315 = new cExecutableCompare;
//===============
   Runner.Add(element_7414315,false);
//===============
   element_7414315.ParameterAdd((eRelationType)RELATIONTYPE_GTEATER,PARAMETER_RELATIONTYPE,1,true);
//===============
 
//===============
// Element: Buys < Max Buys
//===============
   cExecutableCompare *const element_5350187 = new cExecutableCompare;
//===============
   Runner.Add(element_5350187,false);
//===============
   element_5350187.ParameterAdd((eRelationType)RELATIONTYPE_LESS,PARAMETER_RELATIONTYPE,1,true);
//===============
 
//===============
// Element: Total < Max Total
//===============
   cExecutableCompare *const element_5342438 = new cExecutableCompare;
//===============
   Runner.Add(element_5342438,false);
//===============
   element_5342438.ParameterAdd((eRelationType)RELATIONTYPE_LESS,PARAMETER_RELATIONTYPE,1,true);
//===============
 
//===============
// Element: Sells < Max Sells
//===============
   cExecutableCompare *const element_5339212 = new cExecutableCompare;
//===============
   Runner.Add(element_5339212,false);
//===============
   element_5339212.ParameterAdd((eRelationType)RELATIONTYPE_LESS,PARAMETER_RELATIONTYPE,1,true);
//===============
 
//===============
// Element: RSI Buy Signal
//===============
   cExecutableVariableBool *const element_7463454 = new cExecutableVariableBool;
//===============
   Runner.Add(element_7463454,false);
//===============
   element_7463454.ParameterAdd((bool)false,PARAMETER_BOOLVALUE,0,true);
//===============
   element_7463454.ParameterAdd((bool)true,PARAMETER_BOOLVALUE,4,true);
//===============
 
//===============
// Element: RSI Sell Signal
//===============
   cExecutableVariableBool *const element_7468066 = new cExecutableVariableBool;
//===============
   Runner.Add(element_7468066,false);
//===============
   element_7468066.ParameterAdd((bool)false,PARAMETER_BOOLVALUE,0,true);
//===============
   element_7468066.ParameterAdd((bool)true,PARAMETER_BOOLVALUE,4,true);
//===============
 
//===============
// Element: Stochastic Sell Signal
//===============
   cExecutableVariableBool *const element_7416807 = new cExecutableVariableBool;
//===============
   Runner.Add(element_7416807,false);
//===============
   element_7416807.ParameterAdd((bool)false,PARAMETER_BOOLVALUE,0,true);
//===============
   element_7416807.ParameterAdd((bool)true,PARAMETER_BOOLVALUE,4,true);
//===============
 
//===============
// Element: Stochastic Buy Signal
//===============
   cExecutableVariableBool *const element_7392732 = new cExecutableVariableBool;
//===============
   Runner.Add(element_7392732,false);
//===============
   element_7392732.ParameterAdd((bool)false,PARAMETER_BOOLVALUE,0,true);
//===============
   element_7392732.ParameterAdd((bool)true,PARAMETER_BOOLVALUE,4,true);
//===============
 
//===============
// Element: Max Trades Filter Sell
//===============
   cExecutableVariableBool *const element_5350434 = new cExecutableVariableBool;
//===============
   Runner.Add(element_5350434,false);
//===============
   element_5350434.ParameterAdd((bool)false,PARAMETER_BOOLVALUE,0,true);
//===============
   element_5350434.ParameterAdd((bool)true,PARAMETER_BOOLVALUE,4,true);
//===============
 
//===============
// Element: Max Trades Filter Buy
//===============
   cExecutableVariableBool *const element_5350640 = new cExecutableVariableBool;
//===============
   Runner.Add(element_5350640,false);
//===============
   element_5350640.ParameterAdd((bool)false,PARAMETER_BOOLVALUE,0,true);
//===============
   element_5350640.ParameterAdd((bool)true,PARAMETER_BOOLVALUE,4,true);
//===============
 
//===============
// Element: Buy Lot Value
//===============
   cExecutableVariableDouble *const element_6109408 = new cExecutableVariableDouble;
//===============
   Runner.Add(element_6109408,false);
//===============
   element_6109408.ParameterAdd((double)0.01,PARAMETER_DOUBLEVALUE,0,true);
//===============
 
//===============
// Element: Sell Lot Value
//===============
   cExecutableVariableDouble *const element_6118457 = new cExecutableVariableDouble;
//===============
   Runner.Add(element_6118457,false);
//===============
   element_6118457.ParameterAdd((double)0.01,PARAMETER_DOUBLEVALUE,0,true);
//===============
 
//===============
// Element: Final Buy Lot
//===============
   cExecutableVariableDouble *const element_6113038 = new cExecutableVariableDouble;
//===============
   Runner.Add(element_6113038,false);
//===============
   element_6113038.ParameterAdd((double)0.01,PARAMETER_DOUBLEVALUE,0,true);
//===============
 
//===============
// Element: Final Sell Lot
//===============
   cExecutableVariableDouble *const element_6109456 = new cExecutableVariableDouble;
//===============
   Runner.Add(element_6109456,false);
//===============
   element_6109456.ParameterAdd((double)0.01,PARAMETER_DOUBLEVALUE,0,true);
//===============
 
//===============
// Element: Current Time
//===============
   cExecutableLastServerTime *const element_2975457 = new cExecutableLastServerTime;
//===============
   Runner.Add(element_2975457,false);
//===============
 
//===============
// Element: Trades Opened Before Time
//===============
   cExecutableTimeModify *const element_2995604 = new cExecutableTimeModify;
//===============
   Runner.Add(element_2995604,false);
//===============
   element_2995604.ParameterAdd((eMathOperation)MATHOPERATION_SUBTRACT,PARAMETER_MATHOPERATION,1,true);
//===============
   element_2995604.ParameterAdd((eTimeComponent)TIMECOMPONENT_SECOND,PARAMETER_TIMECOMPONENT,2,true);
//===============
 
//===============
// Element: RSI Previous
//===============
   cExecutableIndicatorValue *const element_7450160 = new cExecutableIndicatorValue;
//===============
   Runner.Add(element_7450160,false);
//===============
   element_7450160.ParameterAdd((long)2,PARAMETER_BARNUMBER,1,true);
//===============
 
//===============
// Element: RSI Current
//===============
   cExecutableIndicatorValue *const element_7471515 = new cExecutableIndicatorValue;
//===============
   Runner.Add(element_7471515,false);
//===============
   element_7471515.ParameterAdd((long)1,PARAMETER_BARNUMBER,1,true);
//===============
 
//===============
// Element: Main Current
//===============
   cExecutableIndicatorValue *const element_7414942 = new cExecutableIndicatorValue;
//===============
   Runner.Add(element_7414942,false);
//===============
   element_7414942.ParameterAdd((long)1,PARAMETER_BARNUMBER,1,true);
//===============
 
//===============
// Element: Signal Current
//===============
   cExecutableIndicatorValue *const element_7396802 = new cExecutableIndicatorValue;
//===============
   Runner.Add(element_7396802,false);
//===============
   element_7396802.ParameterAdd((long)1,PARAMETER_BARNUMBER,1,true);
//===============
 
//===============
// Element: Main Previous
//===============
   cExecutableIndicatorValue *const element_7420015 = new cExecutableIndicatorValue;
//===============
   Runner.Add(element_7420015,false);
//===============
   element_7420015.ParameterAdd((long)2,PARAMETER_BARNUMBER,1,true);
//===============
 
//===============
// Element: Signal Previous
//===============
   cExecutableIndicatorValue *const element_7403267 = new cExecutableIndicatorValue;
//===============
   Runner.Add(element_7403267,false);
//===============
   element_7403267.ParameterAdd((long)2,PARAMETER_BARNUMBER,1,true);
//===============
 
//===============
// Element: RSI
//===============
   cExecutableIndicatorRSI *const element_7440729 = new cExecutableIndicatorRSI;
//===============
   Runner.Add(element_7440729,false);
//===============
   element_7440729.ParameterAdd((string)::Symbol(),PARAMETER_SYMBOLNAME,0,true);
//===============
   element_7440729.ParameterAdd((ENUM_TIMEFRAMES)::Period(),PARAMETER_TIMEFRAME,1,true);
//===============
   element_7440729.ParameterAdd((ENUM_APPLIED_PRICE)PRICE_CLOSE,PARAMETER_APPLIEDPRICE,3,true);
//===============
 
//===============
// Element: Stochastic Signal
//===============
   cExecutableIndicatorStochastic *const element_7396242 = new cExecutableIndicatorStochastic;
//===============
   Runner.Add(element_7396242,false);
//===============
   element_7396242.ParameterAdd((string)::Symbol(),PARAMETER_SYMBOLNAME,0,true);
//===============
   element_7396242.ParameterAdd((ENUM_TIMEFRAMES)::Period(),PARAMETER_TIMEFRAME,1,true);
//===============
   element_7396242.ParameterAdd((ENUM_STO_PRICE)STO_LOWHIGH,PARAMETER_STOPRICE,6,true);
//===============
   element_7396242.ParameterAdd((eIndicatorLine)INDICATORLINE_SIGNAL,PARAMETER_OUTPUTLINETYPE,7,true);
//===============
 
//===============
// Element: Stochastic Main
//===============
   cExecutableIndicatorStochastic *const element_7396445 = new cExecutableIndicatorStochastic;
//===============
   Runner.Add(element_7396445,false);
//===============
   element_7396445.ParameterAdd((string)::Symbol(),PARAMETER_SYMBOLNAME,0,true);
//===============
   element_7396445.ParameterAdd((ENUM_TIMEFRAMES)::Period(),PARAMETER_TIMEFRAME,1,true);
//===============
   element_7396445.ParameterAdd((ENUM_STO_PRICE)STO_LOWHIGH,PARAMETER_STOPRICE,6,true);
//===============
   element_7396445.ParameterAdd((eIndicatorLine)INDICATORLINE_MAIN,PARAMETER_OUTPUTLINETYPE,7,true);
//===============
 
//===============
// Link: Magic => Sell Trades
//===============
   element_5339705.LinkAdd(element_6110776,PARAMETER_MAGIC,false,2,true);
//===============

//===============
// Link: Magic => Buy Trades
//===============
   element_5337260.LinkAdd(element_6110776,PARAMETER_MAGIC,false,2,true);
//===============

//===============
// Link: Fixed Lot Value => Sell Lot Value
//===============
   element_6118457.LinkAdd(element_889504,PARAMETER_DOUBLEVALUE,false,2,true);
//===============

//===============
// Link: Use Fixed Lot => Sell Lot Value
//===============
   element_6118457.LinkAdd(element_869616,PARAMETER_CONDITION,false,1,true);
//===============

//===============
// Link: Fixed Lot Value => Buy Lot Value
//===============
   element_6109408.LinkAdd(element_889504,PARAMETER_DOUBLEVALUE,false,2,true);
//===============

//===============
// Link: Use Fixed Lot => Buy Lot Value
//===============
   element_6109408.LinkAdd(element_869616,PARAMETER_CONDITION,false,1,true);
//===============

//===============
// Link: Max Trades Filter Sell => Sell Trigger
//===============
   element_6098915.LinkAdd(element_5350434,PARAMETER_BOOLVALUE,false,4,true);
//===============

//===============
// Link: Max Trades Filter Buy => Buy Trigger
//===============
   element_6101078.LinkAdd(element_5350640,PARAMETER_BOOLVALUE,false,4,true);
//===============

//===============
// Link: Stochastic Close Sell Signal => Close Sell Trigger
//===============
   element_6118956.LinkAdd(element_7395738,PARAMETER_BOOLVALUE,false,1,true);
//===============

//===============
// Link: Stochastic Close Buy Signal => Close Buy Trigger
//===============
   element_6115054.LinkAdd(element_7410053,PARAMETER_BOOLVALUE,false,1,true);
//===============

//===============
// Link: Stochastic Sell Signal => Sell Trigger
//===============
   element_6098915.LinkAdd(element_7416807,PARAMETER_BOOLVALUE,false,3,true);
//===============

//===============
// Link: Stochastic Buy Signal => Buy Trigger
//===============
   element_6101078.LinkAdd(element_7392732,PARAMETER_BOOLVALUE,false,3,true);
//===============

//===============
// Link: Use Stochastic For Entry => Enabled Signals
//===============
   element_6110695.LinkAdd(element_7412347,PARAMETER_BOOLVALUE,false,1,true);
//===============

//===============
// Link: RSI Close Sell Signal => Close Sell Trigger
//===============
   element_6118956.LinkAdd(element_7440357,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: RSI Close Buy Signal => Close Buy Trigger
//===============
   element_6115054.LinkAdd(element_7462330,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: RSI Sell Signal => Sell Trigger
//===============
   element_6098915.LinkAdd(element_7468066,PARAMETER_BOOLVALUE,false,2,true);
//===============

//===============
// Link: RSI Buy Signal => Buy Trigger
//===============
   element_6101078.LinkAdd(element_7463454,PARAMETER_BOOLVALUE,false,2,true);
//===============

//===============
// Link: Use RSI For Entry => Enabled Signals
//===============
   element_6110695.LinkAdd(element_7465986,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: Sell Trades => Trades
//===============
   element_3734769.LinkAdd(element_6116897,PARAMETER_TRADESGROUP,false,1,true);
//===============

//===============
// Link: Buy Trades => Trades
//===============
   element_3734769.LinkAdd(element_6118190,PARAMETER_TRADESGROUP,false,0,true);
//===============

//===============
// Link: Magic => Trades To Close
//===============
   element_2988541.LinkAdd(element_6110776,PARAMETER_MAGIC,false,2,true);
//===============

//===============
// Link: Sell Trades Number => Total Trades Number
//===============
   element_5338513.LinkAdd(element_5332221,PARAMETER_DOUBLEVALUE2,false,3,true);
//===============

//===============
// Link: Use Max Trades Filter => Max Trades Filter Sell
//===============
   element_5350434.LinkAdd(element_5353704,PARAMETER_CONDITION,true,3,true);
//===============

//===============
// Link: Use Max Trades Filter => Max Trades Filter Sell
//===============
   element_5350434.LinkAdd(element_5353704,PARAMETER_CONDITION,false,1,true);
//===============

//===============
// Link: Total < Max Total => Sell Filter
//===============
   element_5340816.LinkAdd(element_5342438,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: Max Sell Trades => Sells < Max Sells
//===============
   element_5339212.LinkAdd(element_5330247,PARAMETER_DOUBLEVALUE2,false,2,true);
//===============

//===============
// Link: Sell Trades => Sell Trades Number
//===============
   element_5332221.LinkAdd(element_5339705,PARAMETER_TRADESGROUP,false,0,true);
//===============

//===============
// Link: Sell Trades Number => Sells < Max Sells
//===============
   element_5339212.LinkAdd(element_5332221,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: Sells < Max Sells => Sell Filter
//===============
   element_5340816.LinkAdd(element_5339212,PARAMETER_BOOLVALUE,false,1,true);
//===============

//===============
// Link: Sell Filter => Max Trades Filter Sell
//===============
   element_5350434.LinkAdd(element_5340816,PARAMETER_BOOLVALUE,false,2,true);
//===============

//===============
// Link: Total < Max Total => Buy Filter
//===============
   element_5351843.LinkAdd(element_5342438,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: Total Trades Number => Total < Max Total
//===============
   element_5342438.LinkAdd(element_5338513,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: Buy Trades Number => Total Trades Number
//===============
   element_5338513.LinkAdd(element_5325323,PARAMETER_DOUBLEVALUE1,false,1,true);
//===============

//===============
// Link: Max Total Trades => Total < Max Total
//===============
   element_5342438.LinkAdd(element_5353969,PARAMETER_DOUBLEVALUE2,false,2,true);
//===============

//===============
// Link: Buy Filter => Max Trades Filter Buy
//===============
   element_5350640.LinkAdd(element_5351843,PARAMETER_BOOLVALUE,false,2,true);
//===============

//===============
// Link: Buys < Max Buys => Buy Filter
//===============
   element_5351843.LinkAdd(element_5350187,PARAMETER_BOOLVALUE,false,1,true);
//===============

//===============
// Link: Buy Trades Number => Buys < Max Buys
//===============
   element_5350187.LinkAdd(element_5325323,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: Use Max Trades Filter => Max Trades Filter Buy
//===============
   element_5350640.LinkAdd(element_5353704,PARAMETER_CONDITION,false,1,true);
//===============

//===============
// Link: Buy Trades => Buy Trades Number
//===============
   element_5325323.LinkAdd(element_5337260,PARAMETER_TRADESGROUP,false,0,true);
//===============

//===============
// Link: Max Buy Trades => Buys < Max Buys
//===============
   element_5350187.LinkAdd(element_5333629,PARAMETER_DOUBLEVALUE2,false,2,true);
//===============

//===============
// Link: Use Max Trades Filter => Max Trades Filter Buy
//===============
   element_5350640.LinkAdd(element_5353704,PARAMETER_CONDITION,true,3,true);
//===============

//===============
// Link: Final Sell Lot => Open Sell
//===============
   element_6122434.LinkAdd(element_6109456,PARAMETER_LOTS,false,3,true);
//===============

//===============
// Link: Max Trade Lot => Lot Above Max
//===============
   element_6114859.LinkAdd(element_6106882,PARAMETER_DOUBLEVALUE2,false,2,true);
//===============

//===============
// Link: Min Trade Lot => Lot Below Min
//===============
   element_6103246.LinkAdd(element_6118035,PARAMETER_DOUBLEVALUE2,false,2,true);
//===============

//===============
// Link: Lot Above Max => Final Sell Lot
//===============
   element_6109456.LinkAdd(element_6114859,PARAMETER_CONDITION,false,3,true);
//===============

//===============
// Link: Sell Lot Value => Lot Above Max
//===============
   element_6114859.LinkAdd(element_6118457,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: Lot Below Min => Final Sell Lot
//===============
   element_6109456.LinkAdd(element_6103246,PARAMETER_CONDITION,false,1,true);
//===============

//===============
// Link: Sell Lot Value => Lot Below Min
//===============
   element_6103246.LinkAdd(element_6118457,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: Lot Below Min => Valid Sell Lot
//===============
   element_6108016.LinkAdd(element_6103246,PARAMETER_BOOLVALUE,true,0,true);
//===============

//===============
// Link: Lot Above Max => Valid Sell Lot
//===============
   element_6108016.LinkAdd(element_6114859,PARAMETER_BOOLVALUE,true,1,true);
//===============

//===============
// Link: Valid Sell Lot => Final Sell Lot
//===============
   element_6109456.LinkAdd(element_6108016,PARAMETER_CONDITION,false,5,true);
//===============

//===============
// Link: Sell Lot Value => Final Sell Lot
//===============
   element_6109456.LinkAdd(element_6118457,PARAMETER_DOUBLEVALUE,false,6,true);
//===============

//===============
// Link: Buy Lot Value => Final Buy Lot
//===============
   element_6113038.LinkAdd(element_6109408,PARAMETER_DOUBLEVALUE,false,6,true);
//===============

//===============
// Link: Valid Buy Lot => Final Buy Lot
//===============
   element_6113038.LinkAdd(element_6124632,PARAMETER_CONDITION,false,5,true);
//===============

//===============
// Link: Lot Above Max => Valid Buy Lot
//===============
   element_6124632.LinkAdd(element_6099990,PARAMETER_BOOLVALUE,true,0,true);
//===============

//===============
// Link: Lot Below Min => Valid Buy Lot
//===============
   element_6124632.LinkAdd(element_6108115,PARAMETER_BOOLVALUE,true,1,true);
//===============

//===============
// Link: Close Buy Trigger => Close Buys
//===============
   element_6122480.LinkAdd(element_6115054,PARAMETER_TRIGGER,false,0,true);
//===============

//===============
// Link: Close Sell Trigger => Close Sells
//===============
   element_6109893.LinkAdd(element_6118956,PARAMETER_TRIGGER,false,0,true);
//===============

//===============
// Link: Final Buy Lot => Open Buy
//===============
   element_6105181.LinkAdd(element_6113038,PARAMETER_LOTS,false,3,true);
//===============

//===============
// Link: Magic => Buy Trades
//===============
   element_6118190.LinkAdd(element_6110776,PARAMETER_MAGIC,false,2,true);
//===============

//===============
// Link: Magic => Sell Trades
//===============
   element_6116897.LinkAdd(element_6110776,PARAMETER_MAGIC,false,2,true);
//===============

//===============
// Link: Buy Trigger => Open Buy
//===============
   element_6105181.LinkAdd(element_6101078,PARAMETER_TRIGGER,false,0,true);
//===============

//===============
// Link: Magic => Open Buy
//===============
   element_6105181.LinkAdd(element_6110776,PARAMETER_MAGIC,false,4,true);
//===============

//===============
// Link: Sell Trigger => Open Sell
//===============
   element_6122434.LinkAdd(element_6098915,PARAMETER_TRIGGER,false,0,true);
//===============

//===============
// Link: Magic => Open Sell
//===============
   element_6122434.LinkAdd(element_6110776,PARAMETER_MAGIC,false,4,true);
//===============

//===============
// Link: Sell Trades => Close Sells
//===============
   element_6109893.LinkAdd(element_6116897,PARAMETER_TRADESGROUP,false,1,true);
//===============

//===============
// Link: Buy Trades => Close Buys
//===============
   element_6122480.LinkAdd(element_6118190,PARAMETER_TRADESGROUP,false,1,true);
//===============

//===============
// Link: Comment => Open Buy
//===============
   element_6105181.LinkAdd(element_6115363,PARAMETER_COMMENT,false,5,true);
//===============

//===============
// Link: Comment => Open Sell
//===============
   element_6122434.LinkAdd(element_6115363,PARAMETER_COMMENT,false,5,true);
//===============

//===============
// Link: Enabled Signals => Buy Trigger
//===============
   element_6101078.LinkAdd(element_6110695,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: Enabled Signals => Sell Trigger
//===============
   element_6098915.LinkAdd(element_6110695,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: Close Buy Trigger => Buy Trigger
//===============
   element_6101078.LinkAdd(element_6115054,PARAMETER_BOOLVALUE,true,1,true);
//===============

//===============
// Link: Close Sell Trigger => Sell Trigger
//===============
   element_6098915.LinkAdd(element_6118956,PARAMETER_BOOLVALUE,true,1,true);
//===============

//===============
// Link: Buy Lot Value => Lot Below Min
//===============
   element_6108115.LinkAdd(element_6109408,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: Min Trade Lot => Lot Below Min
//===============
   element_6108115.LinkAdd(element_6118035,PARAMETER_DOUBLEVALUE2,false,2,true);
//===============

//===============
// Link: Lot Below Min => Final Buy Lot
//===============
   element_6113038.LinkAdd(element_6108115,PARAMETER_CONDITION,false,1,true);
//===============

//===============
// Link: Min Trade Lot => Final Buy Lot
//===============
   element_6113038.LinkAdd(element_6118035,PARAMETER_DOUBLEVALUE,false,2,true);
//===============

//===============
// Link: Buy Lot Value => Lot Above Max
//===============
   element_6099990.LinkAdd(element_6109408,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: Max Trade Lot => Lot Above Max
//===============
   element_6099990.LinkAdd(element_6106882,PARAMETER_DOUBLEVALUE2,false,2,true);
//===============

//===============
// Link: Lot Above Max => Final Buy Lot
//===============
   element_6113038.LinkAdd(element_6099990,PARAMETER_CONDITION,false,3,true);
//===============

//===============
// Link: Max Trade Lot => Final Buy Lot
//===============
   element_6113038.LinkAdd(element_6106882,PARAMETER_DOUBLEVALUE,false,4,true);
//===============

//===============
// Link: Min Trade Lot => Final Sell Lot
//===============
   element_6109456.LinkAdd(element_6118035,PARAMETER_DOUBLEVALUE,false,2,true);
//===============

//===============
// Link: Max Trade Lot => Final Sell Lot
//===============
   element_6109456.LinkAdd(element_6106882,PARAMETER_DOUBLEVALUE,false,4,true);
//===============

//===============
// Link: Take Profit, $$$ => Set SL and TP
//===============
   element_3752709.LinkAdd(element_3749000,PARAMETER_TAKEPROFITMONEY,false,6,true);
//===============

//===============
// Link: Stop Loss, $$$ => Set SL and TP
//===============
   element_3752709.LinkAdd(element_3737483,PARAMETER_STOPLOSSMONEY,false,5,true);
//===============

//===============
// Link: Trades => Set SL and TP
//===============
   element_3752709.LinkAdd(element_3734769,PARAMETER_TRADESGROUP,false,1,true);
//===============

//===============
// Link: Use SL & TP $$$ => Set SL and TP
//===============
   element_3752709.LinkAdd(element_3746915,PARAMETER_TRIGGER,false,0,true);
//===============

//===============
// Link: Trades To Close => Close Trades at First Chance
//===============
   element_2976086.LinkAdd(element_2988541,PARAMETER_TRADESGROUP,false,1,true);
//===============

//===============
// Link: Use Close at First Chance => Close Trades at First Chance
//===============
   element_2976086.LinkAdd(element_2975096,PARAMETER_TRIGGER,false,0,true);
//===============

//===============
// Link: Trades Opened Before Time => Trades To Close
//===============
   element_2988541.LinkAdd(element_2995604,PARAMETER_OPENTIMELESSOREQUALTHAN,false,9,true);
//===============

//===============
// Link: Current Time => Trades Opened Before Time
//===============
   element_2995604.LinkAdd(element_2975457,PARAMETER_TIMEVALUE,false,0,true);
//===============

//===============
// Link: First Chance After, seconds => Trades Opened Before Time
//===============
   element_2995604.LinkAdd(element_2979904,PARAMETER_LONGVALUE,false,3,true);
//===============

//===============
// Link: Min Profit, money => Trades To Close
//===============
   element_2988541.LinkAdd(element_2995331,PARAMETER_PROFITGREATEROREQUALTHAN,false,6,true);
//===============

//===============
// Link: Crossover => Stochastic Sell
//===============
   element_7414632.LinkAdd(element_7420193,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: Crossover Only => Crossover
//===============
   element_7420193.LinkAdd(element_7393349,PARAMETER_BOOLVALUE,true,0,true);
//===============

//===============
// Link: Main > Signal Previous => Crossover
//===============
   element_7420193.LinkAdd(element_7414315,PARAMETER_BOOLVALUE,false,1,true);
//===============

//===============
// Link: Main > Signal Current => Stochastic Sell
//===============
   element_7414632.LinkAdd(element_7415065,PARAMETER_BOOLVALUE,true,1,true);
//===============

//===============
// Link: Crossover => Stochastic Buy
//===============
   element_7414899.LinkAdd(element_7402083,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: Main > Signal Previous => Crossover
//===============
   element_7402083.LinkAdd(element_7414315,PARAMETER_BOOLVALUE,true,0,true);
//===============

//===============
// Link: Crossover Only => Crossover
//===============
   element_7402083.LinkAdd(element_7393349,PARAMETER_BOOLVALUE,true,1,true);
//===============

//===============
// Link: Use Stochastic For Entry => Stochastic Sell Signal
//===============
   element_7416807.LinkAdd(element_7412347,PARAMETER_CONDITION,true,3,true);
//===============

//===============
// Link: Use Stochastic For Entry => Stochastic Buy Signal
//===============
   element_7392732.LinkAdd(element_7412347,PARAMETER_CONDITION,true,3,true);
//===============

//===============
// Link: Stochastic Sell => Stochastic Close Buy Signal
//===============
   element_7410053.LinkAdd(element_7414632,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: Stochastic Buy => Stochastic Close Sell Signal
//===============
   element_7395738.LinkAdd(element_7414899,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: Use Stochastic For Exit => Stochastic Close Sell Signal
//===============
   element_7395738.LinkAdd(element_7388977,PARAMETER_BOOLVALUE,false,1,true);
//===============

//===============
// Link: Use Stochastic For Exit => Stochastic Close Buy Signal
//===============
   element_7410053.LinkAdd(element_7388977,PARAMETER_BOOLVALUE,false,1,true);
//===============

//===============
// Link: Main Current => Main > Signal Current
//===============
   element_7415065.LinkAdd(element_7414942,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: Signal Current => Main > Signal Current
//===============
   element_7415065.LinkAdd(element_7396802,PARAMETER_DOUBLEVALUE2,false,2,true);
//===============

//===============
// Link: Main Previous => Main > Signal Previous
//===============
   element_7414315.LinkAdd(element_7420015,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: Signal Previous => Main > Signal Previous
//===============
   element_7414315.LinkAdd(element_7403267,PARAMETER_DOUBLEVALUE2,false,2,true);
//===============

//===============
// Link: Main > Signal Current => Stochastic Buy
//===============
   element_7414899.LinkAdd(element_7415065,PARAMETER_BOOLVALUE,false,1,true);
//===============

//===============
// Link: Use Stochastic For Entry => Stochastic Buy Signal
//===============
   element_7392732.LinkAdd(element_7412347,PARAMETER_CONDITION,false,1,true);
//===============

//===============
// Link: Stochastic Buy => Stochastic Buy Signal
//===============
   element_7392732.LinkAdd(element_7414899,PARAMETER_BOOLVALUE,false,2,true);
//===============

//===============
// Link: Use Stochastic For Entry => Stochastic Sell Signal
//===============
   element_7416807.LinkAdd(element_7412347,PARAMETER_CONDITION,false,1,true);
//===============

//===============
// Link: Stochastic Sell => Stochastic Sell Signal
//===============
   element_7416807.LinkAdd(element_7414632,PARAMETER_BOOLVALUE,false,2,true);
//===============

//===============
// Link: Stochastic Main => Main Current
//===============
   element_7414942.LinkAdd(element_7396445,PARAMETER_INDICATOR,false,0,true);
//===============

//===============
// Link: Stochastic Main => Main Previous
//===============
   element_7420015.LinkAdd(element_7396445,PARAMETER_INDICATOR,false,0,true);
//===============

//===============
// Link: Stochastic Signal => Signal Current
//===============
   element_7396802.LinkAdd(element_7396242,PARAMETER_INDICATOR,false,0,true);
//===============

//===============
// Link: Stochastic Signal => Signal Previous
//===============
   element_7403267.LinkAdd(element_7396242,PARAMETER_INDICATOR,false,0,true);
//===============

//===============
// Link: K Period => Stochastic Main
//===============
   element_7396445.LinkAdd(element_7394140,PARAMETER_KPERIOD,false,2,true);
//===============

//===============
// Link: D Period => Stochastic Main
//===============
   element_7396445.LinkAdd(element_7394136,PARAMETER_DPERIOD,false,3,true);
//===============

//===============
// Link: Slowing => Stochastic Main
//===============
   element_7396445.LinkAdd(element_7398339,PARAMETER_SLOWING,false,4,true);
//===============

//===============
// Link: K Period => Stochastic Signal
//===============
   element_7396242.LinkAdd(element_7394140,PARAMETER_KPERIOD,false,2,true);
//===============

//===============
// Link: D Period => Stochastic Signal
//===============
   element_7396242.LinkAdd(element_7394136,PARAMETER_DPERIOD,false,3,true);
//===============

//===============
// Link: Slowing => Stochastic Signal
//===============
   element_7396242.LinkAdd(element_7398339,PARAMETER_SLOWING,false,4,true);
//===============

//===============
// Link: MA Type => Stochastic Main
//===============
   element_7396445.LinkAdd(element_7407110,PARAMETER_MAMETHOD,false,5,true);
//===============

//===============
// Link: MA Type => Stochastic Signal
//===============
   element_7396242.LinkAdd(element_7407110,PARAMETER_MAMETHOD,false,5,true);
//===============

//===============
// Link: Valid Value => RSI Sell
//===============
   element_7450338.LinkAdd(element_7467706,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: Valid Value => RSI Buy
//===============
   element_7470568.LinkAdd(element_7467706,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: Valid Value => RSI Sell
//===============
   element_7450338.LinkAdd(element_7443955,PARAMETER_BOOLVALUE,false,1,true);
//===============

//===============
// Link: Valid Value => RSI Buy
//===============
   element_7470568.LinkAdd(element_7443955,PARAMETER_BOOLVALUE,false,1,true);
//===============

//===============
// Link: RSI Previous => Valid Value
//===============
   element_7467706.LinkAdd(element_7450160,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: RSI Current => Valid Value
//===============
   element_7443955.LinkAdd(element_7471515,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: Crossover => RSI Sell
//===============
   element_7450338.LinkAdd(element_7440510,PARAMETER_BOOLVALUE,false,2,true);
//===============

//===============
// Link: OverBought Previous => Crossover
//===============
   element_7440510.LinkAdd(element_7453309,PARAMETER_BOOLVALUE,true,0,true);
//===============

//===============
// Link: Crossover => RSI Buy
//===============
   element_7470568.LinkAdd(element_7465982,PARAMETER_BOOLVALUE,false,2,true);
//===============

//===============
// Link: OverSold Previous => Crossover
//===============
   element_7465982.LinkAdd(element_7457979,PARAMETER_BOOLVALUE,true,0,true);
//===============

//===============
// Link: Crossover Only => Crossover
//===============
   element_7465982.LinkAdd(element_7452116,PARAMETER_BOOLVALUE,true,1,true);
//===============

//===============
// Link: Crossover Only => Crossover
//===============
   element_7440510.LinkAdd(element_7452116,PARAMETER_BOOLVALUE,true,1,true);
//===============

//===============
// Link: RSI Buy => RSI Close Sell Signal
//===============
   element_7440357.LinkAdd(element_7470568,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: Use RSI For Exit => RSI Close Sell Signal
//===============
   element_7440357.LinkAdd(element_7450142,PARAMETER_BOOLVALUE,false,1,true);
//===============

//===============
// Link: RSI Sell => RSI Close Buy Signal
//===============
   element_7462330.LinkAdd(element_7450338,PARAMETER_BOOLVALUE,false,0,true);
//===============

//===============
// Link: Use RSI For Exit => RSI Close Buy Signal
//===============
   element_7462330.LinkAdd(element_7450142,PARAMETER_BOOLVALUE,false,1,true);
//===============

//===============
// Link: RSI Period => RSI
//===============
   element_7440729.LinkAdd(element_7472078,PARAMETER_INDICATORPERIOD,false,2,true);
//===============

//===============
// Link: RSI => RSI Current
//===============
   element_7471515.LinkAdd(element_7440729,PARAMETER_INDICATOR,false,0,true);
//===============

//===============
// Link: RSI => RSI Previous
//===============
   element_7450160.LinkAdd(element_7440729,PARAMETER_INDICATOR,false,0,true);
//===============

//===============
// Link: RSI Current => OverSold Now
//===============
   element_7450439.LinkAdd(element_7471515,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: Over Sold Level => OverSold Now
//===============
   element_7450439.LinkAdd(element_7465679,PARAMETER_DOUBLEVALUE2,false,2,true);
//===============

//===============
// Link: RSI Previous => OverSold Previous
//===============
   element_7457979.LinkAdd(element_7450160,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: Over Sold Level => OverSold Previous
//===============
   element_7457979.LinkAdd(element_7465679,PARAMETER_DOUBLEVALUE2,false,2,true);
//===============

//===============
// Link: OverSold Now => RSI Buy
//===============
   element_7470568.LinkAdd(element_7450439,PARAMETER_BOOLVALUE,false,3,true);
//===============

//===============
// Link: RSI Current => OverBought Now
//===============
   element_7448505.LinkAdd(element_7471515,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: Over Bought Level => OverBought Now
//===============
   element_7448505.LinkAdd(element_7443007,PARAMETER_DOUBLEVALUE2,false,2,true);
//===============

//===============
// Link: RSI Previous => OverBought Previous
//===============
   element_7453309.LinkAdd(element_7450160,PARAMETER_DOUBLEVALUE1,false,0,true);
//===============

//===============
// Link: Over Bought Level => OverBought Previous
//===============
   element_7453309.LinkAdd(element_7443007,PARAMETER_DOUBLEVALUE2,false,2,true);
//===============

//===============
// Link: OverBought Now => RSI Sell
//===============
   element_7450338.LinkAdd(element_7448505,PARAMETER_BOOLVALUE,false,3,true);
//===============

//===============
// Link: Use RSI For Entry => RSI Buy Signal
//===============
   element_7463454.LinkAdd(element_7465986,PARAMETER_CONDITION,false,1,true);
//===============

//===============
// Link: RSI Buy => RSI Buy Signal
//===============
   element_7463454.LinkAdd(element_7470568,PARAMETER_BOOLVALUE,false,2,true);
//===============

//===============
// Link: Use RSI For Entry => RSI Sell Signal
//===============
   element_7468066.LinkAdd(element_7465986,PARAMETER_CONDITION,false,1,true);
//===============

//===============
// Link: RSI Sell => RSI Sell Signal
//===============
   element_7468066.LinkAdd(element_7450338,PARAMETER_BOOLVALUE,false,2,true);
//===============

//===============
// Link: Use RSI For Entry => RSI Buy Signal
//===============
   element_7463454.LinkAdd(element_7465986,PARAMETER_CONDITION,true,3,true);
//===============

//===============
// Link: Use RSI For Entry => RSI Sell Signal
//===============
   element_7468066.LinkAdd(element_7465986,PARAMETER_CONDITION,true,3,true);
//===============

//===============
   Runner.OnInit();
//===============
 
//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
 
	// ------------------------------------------------------------------
	// v4 timer
	// ------------------------------------------------------------------
	sesionControl.AddSession(timeStart, timeEnd);
	// ------------------------------------------------------------------


//===============
   return(INIT_SUCCEEDED);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {
	
	// ------------------------------------------------------------------
	// v4 timer
	// ------------------------------------------------------------------
		if (!sesionControl.doSessionControl()) { return; }
	// ------------------------------------------------------------------


//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============
 
//===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(Runner),true,{})
//===============
 
//===============
   if(!cPointer::Valid(Runner))::ExpertRemove();
//===============
 
//===============
   Runner.OnTick();
//===============

	
	
	mainOrders.cleanCloseOrders();
  mainOrders.GetMarketOrders();
	CheckearOrdernesyGenerarGrids();

 // NOTE: ontick
	if (GridON == true && CheckPointer(gridSell) != POINTER_INVALID)
  {
    gridSell.doGrid();
    mainOrders.GetMarketOrders();
  }
  if (GridON == true && CheckPointer(gridBuy) != POINTER_INVALID)
  {
    gridBuy.doGrid();
    mainOrders.GetMarketOrders();
  }
  if (GridON == true && closeGridOn == true)
  {
    doCloseGridControl();
  }
	
	if (GridON == true){ CloseAtFirstChance_Grid(); }

//===============
	

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============
 
//===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(Runner),true,{})
//===============
 
//===============
   if(!cPointer::Valid(Runner))return;
//===============
 
//===============
   Runner.OnDeinit();
//===============
 
//===============
   cPointer::Delete(Runner);
//===============
 

	
//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cPointer final
  {
   //====================
private:
   //====================
   //===============
   //===============
   void              cPointer(void){}
   virtual void     ~cPointer(void){}
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   static bool       Valid(const void *const pointer){return(::CheckPointer(pointer)!=POINTER_INVALID);}
   //===============
   //===============
   static void       Delete(void *pointer);
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cPointer::Delete(void *pointer)
  {
//===============
/* DEBUG ASSERTION */ASSERT({},::CheckPointer(pointer)==POINTER_DYNAMIC,true,{})
//===============

//===============
   if(::CheckPointer(pointer)!=POINTER_DYNAMIC)return;
//===============

//===============
   delete pointer;
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cArray final
  {
   //====================
private:
   //====================
   //===============
   //===============
   void              cArray(void){}
   virtual void     ~cArray(void){}
   //===============
   //===============
   static void       Sort(int &indexes[],int &sortingvalues[],int &beg,int &end);
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   template<typename T>
   static void       AddLast(T &to[],T item,const int reservesize);
   //===============
   //===============
   template<typename T>
   static bool       ValueExist(const T &array[],const T value);
   //===============
   //===============
   template<typename T>
   static void       Free(T &array[]){::ArrayFree(array);}
   template<typename T>
   static void       Initialize(T &array[],const T value){::ArrayInitialize(array,value);}
   template<typename T>
   static int        Size(T &array[]){return(::ArraySize(array));}
   template<typename T>
   static bool       Resize(T &array[],const int size,const int reserve);
   //===============
   //===============
   static void       SortAscend(int &indexes[],const int &sortingvalues[]);
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
static void cArray::AddLast(T &to[],T item,const int reservesize)
  {
//===============
   const int size=cArray::Size(to);
//===============

//===============
   if(!cArray::Resize(to,size+1,reservesize))return;
//===============

//===============
   to[size]=item;
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
static bool cArray::ValueExist(const T &array[],const T value)
  {
//===============
   bool result=false;
//===============

//===============
   const int size=cArray::Size(array);
//===============
   for(int i=0;i<size;i++)
     {
      //===============
      if(array[i]!=value)continue;
      //===============

      //===============
      result=true;
      //===============

      //===============
      break;
      //===============
     }
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
static bool cArray::Resize(T &array[],const int size,const int reserve)
  {
//===============
   const int arrayresizeresult=::ArrayResize(array,size,reserve);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},arrayresizeresult==size,false,::Print(TOSTRING(arrayresizeresult));)
//===============

//===============
   return(arrayresizeresult==size);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cArray::SortAscend(int &indexes[],const int &sortingvalues[])
  {
//===============
   const int size=cArray::Size(sortingvalues);
//===============

//===============
   cArray::Free(indexes);
//===============
   cArray::Resize(indexes,size,0);
//===============

//===============  
   for(int cnt=0;cnt<size;cnt++)indexes[cnt]=cnt;
//===============

//===============
   int tosort[];
//===============
   cArray::Free(tosort);
//===============
   cArray::Resize(tosort,size,0);
//===============

//===============  
   for(int cnt=0;cnt<size;cnt++)tosort[cnt]=sortingvalues[cnt];
//===============

//===============
   int beg=0;
   int end=size-1;
//===============

//===============
   cArray::Sort(indexes,tosort,beg,end);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cArray::Sort(int &indexes[],int &sortingvalues[],int &beg,int &end)
  {
//===============
   if(beg<0 || end<0)return;
//===============

//===============
   int tempdatavalue=0;
   int refvalue=0;
//===============

//===============
   int i           = beg;
   int j           = end;
//===============

//===============
   const int size=cArray::Size(sortingvalues);
//===============

//===============
   int tempindex=0;
//===============

//===============
   while(i<end)
     {
      //===============
      refvalue=sortingvalues[(beg+end)>>1];
      //===============
      while(i<j)
        {
         //===============
         while(sortingvalues[i]<refvalue)
           {
            //===============
            if(i==size-1)break;
            //===============
            i++;
            //===============
           }
         //===============

         //===============
         while(sortingvalues[j]>refvalue)
           {
            //===============
            if(j==0)break;
            //===============
            j--;
            //===============
           }
         //===============

         //===============
         if(i<=j)
           {
            //===============
            if(sortingvalues[i]!=sortingvalues[j])
              {
               //===============
               tempdatavalue=sortingvalues[i];
               tempindex=indexes[i];
               sortingvalues[i]=sortingvalues[j];
               indexes[i]=indexes[j];
               sortingvalues[j]=tempdatavalue;
               indexes[j]=tempindex;
               //===============
              }
            //===============

            //===============
            if(j==0)
              {
               //===============
               i++;
               //===============
               break;
               //===============
              }
            //===============

            //===============
            i++;
            j--;
            //===============
           }
         //===============
        }
      //===============

      //===============
      if(beg<j)cArray::Sort(indexes,sortingvalues,beg,j);
      //===============

      //===============
      beg=i;
      j=end;
      //===============
     }
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cObject
  {
   //====================
public:
   //====================
   //===============
   //===============
   void              cObject(void){}
   virtual void     ~cObject(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
class cVariable final : public cObject
  {
   //====================
private:
   //====================
   //===============
   //===============
   T                 Value;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cVariable(void){}
   virtual void     ~cVariable(void){}
   //===============
   //===============
   T                 Get(void)const{return(this.Value);}
   void              Set(const T value){this.Value=value;}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cRunner final
  {
   //====================
private:
   //====================
   //===============
   //===============
   cExecutable      *Elements[];
   cExecutable      *EndElements[];
   //===============
   //===============
   void              Clear(void);
   //===============
   //===============
   void              Run(void)const;
   void              SortParameters(void)const;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cRunner(void){cArray::Free(this.Elements);cArray::Free(this.EndElements);}
   virtual void     ~cRunner(void){this.Clear();}
   //===============
   //===============
   void              Add(cExecutable *const element,const bool isend);
   //===============
   //===============
   void              OnDeinit(void);
   void              OnTick(void)const{this.Run();}
   void              OnInit(void)const{this.SortParameters();}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cRunner::Run(void)const
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const int elements=cArray::Size(this.Elements);
//===============
   for(int i=0;i<elements;i++)
     {
      //===============
      bool valid=false;
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT(valid=cPointer::Valid(this.Elements[i]);,
                      valid,true,
                      continue;)
      //===============

      //===============
      this.Elements[i].ReFreshEnable();
      //===============
     }
//===============

//===============
   const int endelements=cArray::Size(this.EndElements);
//===============
   for(int i=0;i<endelements;i++)
     {
      //===============
      bool valid=false;
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT(valid=cPointer::Valid(this.EndElements[i]);,
                      valid,true,
                      continue;)
      //===============

      //===============
      this.EndElements[i].StartExecutionThread(false);
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cRunner::SortParameters(void)const
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const int elements=cArray::Size(this.Elements);
//===============
   for(int i=0;i<elements;i++)
     {
      //===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(this.Elements[i]),true,{})
      //===============

      //===============
      if(!cPointer::Valid(this.Elements[i]))continue;
      //===============

      //===============
      this.Elements[i].SortParameters();
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cRunner::Add(cExecutable *const element,const bool isend)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(element),true,{})
//===============

//===============
   if(!cPointer::Valid(element))return;
//===============

//===============
   cArray::AddLast(this.Elements,element,0);
//===============

//===============
   if(isend)cArray::AddLast(this.EndElements,element,0);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cRunner::OnDeinit(void)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   this.Clear();
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cRunner::Clear(void)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const int size=cArray::Size(this.Elements);
//===============
   for(int i=0;i<size;i++)
     {
      //===============
      cPointer::Delete(this.Elements[i]);
      //===============
     }
//===============

//===============
   cArray::Free(this.Elements);
//===============
   cArray::Free(this.EndElements);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//===============
//#defines
//===============
//===============
#define TSLSTEPPOINTS                  5
//===============
#define SEARCHTO                       "to #"
#define SEARCHFROM                     "from #"
#define SEARCHBY                       "by #"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cInfo
  {
   //====================
protected:
   //====================
   //===============
   //===============
   string            Symbol;
   string            Comment;
   datetime          OpenTime;
   datetime          CloseTime;
   double            Lots;
   double            OpenPrice;
   double            StopLoss;
   double            TakeProfit;
   long              Ticket;
   long              Magic;
   //===============
   //===============
   virtual void      ReSet(void);
   //===============
   //===============
   void              cInfo(void){this.ReSet();}
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   virtual void     ~cInfo(void){}
   //===============
   //===============
   string            SymbolGet(void)const{return(this.Symbol);}
   string            CommentGet(void)const{return(this.Comment);}
   double            LotsGet(void)const{return(this.Lots);}
   double            OpenPriceGet(void)const{return(this.OpenPrice);}
   double            StopLossGet(void)const{return(this.StopLoss);}
   double            TakeProfitGet(void)const{return(this.TakeProfit);}
   long              TicketGet(void)const{return(this.Ticket);}
   long              MagicGet(void)const{return(this.Magic);}
   datetime          OpenTimeGet(void)const{return(this.OpenTime);}
   datetime          CloseTimeGet(void)const{return(this.CloseTime);}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cInfo::ReSet(void)
  {
//===============
   this.Symbol       = NULL;
   this.Comment      = NULL;
   this.Lots         = 0.0;
   this.OpenPrice    = 0.0;
   this.StopLoss     = 0.0;
   this.OpenTime     = 0;
   this.CloseTime    = 0;
   this.TakeProfit   = 0.0;
   this.Ticket       = -1;
   this.Magic        = -1;
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cTradeInfo final : public cInfo
  {
   //====================
private:
   //====================
   //===============
   //===============
   double            ProfitMoney;
   double            Commission;
   double            Swap;
   double            ClosePrice;
   long              ProfitPoints;
   long              Identifier;
   eTradeType        Type;
   eTradeStatus      Status;
   //===============
   //===============
   bool              SetFromCurrent(const long ticket,const bool countcommissions);
   bool              SetFromHistory(const long positionID);
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cTradeInfo(void){this.ReSet();}
   virtual void     ~cTradeInfo(void){}
   //===============
   //===============
   double            ProfitMoneyGet(void)const{return(this.ProfitMoney);}
   double            CommissionGet(void)const{return(this.Commission);}
   double            SwapGet(void)const{return(this.Swap);}
   double            ClosePriceGet(void)const{return(this.ClosePrice);}
   long              ProfitPointsGet(void)const{return(this.ProfitPoints);}
   long              IdentifierGet(void)const{return(this.Identifier);}
   eTradeType        TypeGet(void)const{return(this.Type);}
   eTradeStatus      StatusGet(void)const{return(this.Status);}
   //===============
   //===============
   void              Update(const long ticket,const bool includehistory,const bool countcommissions,const bool searchoriginalticket);
   void              Update(const long ticket,const long identifier,const eTradeType type,const eTradeStatus status,const string symbol,
                            const long magic,const string comment,const double lots,const double openprice,const double stoploss,
                            const double takeprofit,const datetime opentime);
   //===============
   //===============
   virtual void      ReSet(void)override final;
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cTradeInfo::SetFromCurrent(const long ticket,const bool countcommissions)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   if(ticket<=0)return(false);
//===============

//===============
   bool result=false;
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   result=::PositionSelectByTicket(ticket);
//===============

//===============
   if(!result)
     {
      //===============
      ::ResetLastError();
      //===============

      //===============
      return(false);
      //===============
     }
//===============

//===============
   this.Ticket       = ::PositionGetInteger(POSITION_TICKET);
   this.Identifier   = ::PositionGetInteger(POSITION_IDENTIFIER);
   this.Status       = TRADESTATUS_CURRENT;
   this.Symbol       = ::PositionGetString(POSITION_SYMBOL);
   this.Magic        = ::PositionGetInteger(POSITION_MAGIC);
   this.Comment      = ::PositionGetString(POSITION_COMMENT);
   this.Lots         = ::PositionGetDouble(POSITION_VOLUME);
   this.OpenPrice    = ::PositionGetDouble(POSITION_PRICE_OPEN);
   this.ClosePrice   = ::PositionGetDouble(POSITION_PRICE_CURRENT);
   this.StopLoss     = ::PositionGetDouble(POSITION_SL);
   this.TakeProfit   = ::PositionGetDouble(POSITION_TP);
   this.ProfitMoney  = ::PositionGetDouble(POSITION_PROFIT);
   this.Swap         = ::PositionGetDouble(POSITION_SWAP);
   this.OpenTime     = (datetime)::PositionGetInteger(POSITION_TIME);
   this.CloseTime    = 0;
//=============== 
   const ENUM_POSITION_TYPE positiontype=(ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE);
//===============
   if(positiontype==POSITION_TYPE_BUY)
     {
      //===============
      this.Type=TRADETYPE_BUY;
      //===============
     }
   else if(positiontype==POSITION_TYPE_SELL)
     {
      //===============
      this.Type=TRADETYPE_SELL;
      //===============
     }
//=============== 
   this.ProfitPoints=cTrade::ProfitPointsGet(this.Type,this.OpenPrice,this.ClosePrice,this.Symbol);
//===============
   if(countcommissions)this.Commission=cTrade::CommissionGet(::PositionGetInteger(POSITION_IDENTIFIER));
//===============    

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============
/* DEBUG ASSERTION */ASSERT({},false,true,{})
//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cTradeInfo::SetFromHistory(const long positionID)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   if(positionID<=0)return(false);
//===============

//===============
   bool result=false;
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   result=::HistorySelectByPosition(positionID);
//===============

//===============
   if(!result)
     {
      //===============
      ::ResetLastError();
      //===============

      //===============
      return(false);
      //===============
     }
//===============

//===============
   this.Ticket            = positionID;
   this.Identifier        = positionID;
   this.Status            = TRADESTATUS_HISTORY;
//===============

//===============
   const int deals=::HistoryDealsTotal();
//===============

//===============  
   for(int i=0;i<deals && !::IsStopped();i++)
     {
      //===============
      const ulong dealticket=::HistoryDealGetTicket(i);
      //===============
      const ENUM_DEAL_ENTRY entrytype=(ENUM_DEAL_ENTRY)::HistoryDealGetInteger(dealticket,DEAL_ENTRY);
      //===============
      const ENUM_DEAL_TYPE dealtype=(ENUM_DEAL_TYPE)::HistoryDealGetInteger(dealticket,DEAL_TYPE);
      //===============

      //===============
      if(entrytype==DEAL_ENTRY_IN)
        {
         //===============
         this.Symbol       = ::HistoryDealGetString(dealticket,DEAL_SYMBOL);
         this.Magic        = ::HistoryDealGetInteger(dealticket,DEAL_MAGIC);
         this.Comment      = ::HistoryDealGetString(dealticket,DEAL_COMMENT);
         this.Lots        += ::HistoryDealGetDouble(dealticket,DEAL_VOLUME);
         this.OpenPrice    = ::HistoryDealGetDouble(dealticket,DEAL_PRICE);
         this.OpenTime     = (datetime)::HistoryDealGetInteger(dealticket,DEAL_TIME);
         //===============

         //===============
         if(dealtype==DEAL_TYPE_BUY)
           {
            //===============
            this.Type=TRADETYPE_BUY;
            //===============
           }
         else if(dealtype==DEAL_TYPE_SELL)
           {
            //===============
            this.Type=TRADETYPE_SELL;
            //===============
           }
         //===============
        }
      //===============

      //===============
      if(entrytype==DEAL_ENTRY_OUT || entrytype==DEAL_ENTRY_OUT_BY || entrytype==DEAL_ENTRY_INOUT)
        {
         //===============
         this.CloseTime     = (datetime)::HistoryDealGetInteger(dealticket,DEAL_TIME);
         this.ClosePrice    = ::HistoryDealGetDouble(dealticket,DEAL_PRICE);
         //===============
        }
      //===============

      //===============
      this.Commission  += ::HistoryDealGetDouble(dealticket,DEAL_COMMISSION);
      this.Swap        += ::HistoryDealGetDouble(dealticket,DEAL_SWAP);
      this.ProfitMoney += ::HistoryDealGetDouble(dealticket,DEAL_PROFIT);
      //===============
     }
//===============

//=============== 
   this.ProfitPoints=cTrade::ProfitPointsGet(this.Type,this.OpenPrice,this.ClosePrice,this.Symbol);
//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============
/* DEBUG ASSERTION */ASSERT({},false,true,{})
//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cTradeInfo::Update(const long ticket,const bool includehistory,const bool countcommissions,const bool searchoriginalticket)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   this.ReSet();
//===============

//===============
   if(ticket<=0)return;
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   const bool setfromcurrent=this.SetFromCurrent(ticket,countcommissions);
//===============

//===============
   if(!setfromcurrent && includehistory)
     {
      //===============
      ::ResetLastError();
      //===============

      //===============
      this.SetFromHistory(ticket);
      //=============== 
     }
//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============

//===============
   if(::OrderSelect((int)ticket,SELECT_BY_TICKET) && (::OrderType()==OP_BUY || ::OrderType()==OP_SELL))
     {
      //===============
      if(::OrderCloseTime()==0)
        {
         //===============
         this.Status=TRADESTATUS_CURRENT;
         //===============
        }
      //===============
      else if(::OrderCloseTime()>0)
        {
         //===============
         if(!includehistory)return;
         //===============

         //===============
         this.Status=TRADESTATUS_HISTORY;
         //===============
        }
      //===============

      //===============
      if(::OrderType()==OP_BUY)
        {
         //===============
         this.Type=TRADETYPE_BUY;
         //===============
        }
      else if(::OrderType()==OP_SELL)
        {
         //===============
         this.Type=TRADETYPE_SELL;
         //===============
        }
      //===============

      //===============
      this.Ticket       = (long)::OrderTicket();
      this.Symbol       = ::OrderSymbol();
      this.Magic        = (long)::OrderMagicNumber();
      this.Comment      = ::OrderComment();
      this.Lots         = ::OrderLots();
      this.OpenPrice    = ::OrderOpenPrice();
      this.ClosePrice   = ::OrderClosePrice();
      this.StopLoss     = ::OrderStopLoss();
      this.TakeProfit   = ::OrderTakeProfit();
      this.ProfitMoney  = ::OrderProfit();
      this.Swap         = ::OrderSwap();
      this.OpenTime     = ::OrderOpenTime();
      this.CloseTime    = ::OrderCloseTime();
      this.Commission   = ::OrderCommission();
      //===============

      //=============== 
      this.ProfitPoints=cTrade::ProfitPointsGet(this.Type,this.OpenPrice,this.ClosePrice,this.Symbol);
      //===============

      //===============
      if(searchoriginalticket)cTrade::GetOriginalTicket(this.Ticket,this.Comment);
      //===============

      //===============
      this.Identifier=this.Ticket;
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cTradeInfo::Update(const long ticket,const long identifier,const eTradeType type,const eTradeStatus status,const string symbol,
                        const long magic,const string comment,const double lots,const double openprice,const double stoploss,
                        const double takeprofit,const datetime opentime)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   this.ReSet();
//===============

//===============
   this.Ticket       = ticket;
   this.Identifier   = identifier;
   this.Type         = type;
   this.Status       = status;
   this.Symbol       = symbol;
   this.Magic        = magic;
   this.Comment      = comment;
   this.Lots         = lots;
   this.OpenPrice    = openprice;
   this.StopLoss     = stoploss;
   this.TakeProfit   = takeprofit;
   this.OpenTime     = opentime;
//=============== 

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cTradeInfo::ReSet(void)override final
  {
//===============
   cInfo::ReSet();
//===============

//===============
   this.ProfitMoney  = 0.0;
   this.Commission   = 0.0;
   this.Swap         = 0.0;
   this.ClosePrice   = 0.0;
   this.ProfitPoints = 0;
   this.Identifier   = -1;
   this.Type         = WRONG_VALUE;
   this.Status       = WRONG_VALUE;
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cPendingOrderInfo final : public cInfo
  {
   //====================
private:
   //====================
   //===============
   //===============
   datetime          Expiration;
   ePendingOrderType Type;
   ePendingOrderStatus Status;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cPendingOrderInfo(void){this.ReSet();}
   virtual void     ~cPendingOrderInfo(void){}
   //===============
   //===============
   datetime          ExpirationGet(void)const{return(this.Expiration);}
   ePendingOrderType TypeGet(void)const{return(this.Type);}
   ePendingOrderStatus StatusGet(void)const{return(this.Status);}
   //===============
   //===============
   void              Update(const long ticket);
   void              Update(const long ticket,const ePendingOrderType type,const ePendingOrderStatus status,const string symbol,const long magic,
                            const string comment,const double lots,const double openprice,const double stoploss,const double takeprofit,
                            const datetime expiration,const datetime opentime);
   //===============
   //===============
   virtual void      ReSet(void)override final;
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cPendingOrderInfo::Update(const long ticket)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   this.ReSet();
//===============

//===============
   if(ticket<=0)return;
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   ENUM_ORDER_TYPE ordertype=WRONG_VALUE;
//===============

//===============
// Check Current 
//===============
   if(::OrderSelect((ulong)ticket))
     {
      //=============== 
      ordertype=(ENUM_ORDER_TYPE)::OrderGetInteger(ORDER_TYPE);
      //===============
      if(ordertype==ORDER_TYPE_BUY_STOP || ordertype==ORDER_TYPE_BUY_LIMIT ||
         ordertype==ORDER_TYPE_SELL_STOP || ordertype==ORDER_TYPE_SELL_LIMIT)
        {
         //===============
         this.Ticket       = ::OrderGetInteger(ORDER_TICKET);
         this.Status       = ORDERSTATUS_PENDING;
         this.Symbol       = ::OrderGetString(ORDER_SYMBOL);
         this.Magic        = ::OrderGetInteger(ORDER_MAGIC);
         this.Comment      = ::OrderGetString(ORDER_COMMENT);
         this.Lots         = ::OrderGetDouble(ORDER_VOLUME_CURRENT);
         this.OpenPrice    = ::OrderGetDouble(ORDER_PRICE_OPEN);
         this.StopLoss     = ::OrderGetDouble(ORDER_SL);
         this.TakeProfit   = ::OrderGetDouble(ORDER_TP);
         this.OpenTime     = (datetime)::OrderGetInteger(ORDER_TIME_SETUP);
         this.Expiration   = (datetime)::OrderGetInteger(ORDER_TIME_EXPIRATION);
         this.CloseTime    = 0;
         //===============
        }
      else
        {
         //=============== 
         ordertype=WRONG_VALUE;
         //=============== 
        }
      //=============== 
     }
//===============
// Check History
//===============
   else if(::HistoryOrderSelect((ulong)ticket))
     {
      //===============
      ::ResetLastError();
      //===============

      //=============== 
      ordertype=(ENUM_ORDER_TYPE)::HistoryOrderGetInteger((ulong)ticket,ORDER_TYPE);
      //===============
      if(ordertype==ORDER_TYPE_BUY_STOP || ordertype==ORDER_TYPE_BUY_LIMIT ||
         ordertype==ORDER_TYPE_SELL_STOP || ordertype==ORDER_TYPE_SELL_LIMIT)
        {
         //=============== 
         this.Ticket       = ::HistoryOrderGetInteger((ulong)ticket,ORDER_TICKET);
         this.Status       = ORDERSTATUS_HISTORY;
         this.Symbol       = ::HistoryOrderGetString((ulong)ticket,ORDER_SYMBOL);
         this.Magic        = ::HistoryOrderGetInteger((ulong)ticket,ORDER_MAGIC);
         this.Comment      = ::HistoryOrderGetString((ulong)ticket,ORDER_COMMENT);
         this.Lots         = ::HistoryOrderGetDouble((ulong)ticket,ORDER_VOLUME_CURRENT);
         this.OpenPrice    = ::HistoryOrderGetDouble((ulong)ticket,ORDER_PRICE_OPEN);
         this.StopLoss     = ::HistoryOrderGetDouble((ulong)ticket,ORDER_SL);
         this.TakeProfit   = ::HistoryOrderGetDouble((ulong)ticket,ORDER_TP);
         this.OpenTime     = (datetime)::HistoryOrderGetInteger((ulong)ticket,ORDER_TIME_SETUP);
         this.Expiration   = (datetime)::HistoryOrderGetInteger((ulong)ticket,ORDER_TIME_EXPIRATION);
         this.CloseTime    = (datetime)::HistoryOrderGetInteger((ulong)ticket,ORDER_TIME_DONE);
         //=============== 
        }
      else
        {
         //=============== 
         ordertype=WRONG_VALUE;
         //=============== 
        }
      //=============== 
     }
//=============== 

//===============
   if(ordertype==ORDER_TYPE_BUY_STOP)
     {
      //===============
      this.Type=PENDINGORDERTYPE_BUYSTOP;
      //===============
     }
   else if(ordertype==ORDER_TYPE_BUY_LIMIT)
     {
      //===============
      this.Type=PENDINGORDERTYPE_BUYLIMIT;
      //===============
     }
   else if(ordertype==ORDER_TYPE_SELL_LIMIT)
     {
      //===============
      this.Type=PENDINGORDERTYPE_SELLLIMIT;
      //===============
     }
   else if(ordertype==ORDER_TYPE_SELL_STOP)
     {
      //===============
      this.Type=PENDINGORDERTYPE_SELLSTOP;
      //===============
     }
//=============== 

//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============

//===============
   if(::OrderSelect((int)ticket,SELECT_BY_TICKET) && 
      (::OrderType()==OP_BUYSTOP || ::OrderType()==OP_SELLSTOP || ::OrderType()==OP_BUYLIMIT || ::OrderType()==OP_SELLLIMIT))
     {
      //===============
      if(::OrderCloseTime()==0)
        {
         //===============
         this.Status=ORDERSTATUS_PENDING;
         //===============
        }
      //===============
      else if(::OrderCloseTime()>0)
        {
         //===============
         this.Status=ORDERSTATUS_HISTORY;
         //===============
        }
      //===============

      //===============
      const int ordertype=::OrderType();
      //===============
      if(ordertype==OP_BUYSTOP)
        {
         //===============
         this.Type=PENDINGORDERTYPE_BUYSTOP;
         //===============
        }
      else if(ordertype==OP_BUYLIMIT)
        {
         //===============
         this.Type=PENDINGORDERTYPE_BUYLIMIT;
         //===============
        }
      else if(ordertype==OP_SELLLIMIT)
        {
         //===============
         this.Type=PENDINGORDERTYPE_SELLLIMIT;
         //===============
        }
      else if(ordertype==OP_SELLSTOP)
        {
         //===============
         this.Type=PENDINGORDERTYPE_SELLSTOP;
         //===============
        }
      //===============
      this.Ticket       = (long)::OrderTicket();
      this.Symbol       = ::OrderSymbol();
      this.Magic        = (long)::OrderMagicNumber();
      this.Comment      = ::OrderComment();
      this.Lots         = ::OrderLots();
      this.OpenPrice    = ::OrderOpenPrice();
      this.StopLoss     = ::OrderStopLoss();
      this.TakeProfit   = ::OrderTakeProfit();
      this.OpenTime     = ::OrderOpenTime();
      this.CloseTime    = ::OrderCloseTime();
      this.Expiration   = ::OrderExpiration();
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cPendingOrderInfo::Update(const long ticket,const ePendingOrderType type,const ePendingOrderStatus status,const string symbol,const long magic,
                               const string comment,const double lots,const double openprice,const double stoploss,const double takeprofit,
                               const datetime expiration,const datetime opentime)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   this.ReSet();
//===============

//===============
   this.Ticket       = ticket;
   this.Type         = type;
   this.Status       = status;
   this.Symbol       = symbol;
   this.Magic        = magic;
   this.Comment      = comment;
   this.Lots         = lots;
   this.OpenPrice    = openprice;
   this.StopLoss     = stoploss;
   this.TakeProfit   = takeprofit;
   this.Expiration   = expiration;
   this.OpenTime     = opentime;
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cPendingOrderInfo::ReSet(void)override final
  {
//===============
   cInfo::ReSet();
//===============

//===============
   this.Expiration  = 0;
   this.Type        = WRONG_VALUE;
   this.Status      = WRONG_VALUE;
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cGroupInfo
  {
   //====================
protected:
   //====================
   //===============
   //===============
   double            TotalLots;
   double            AveragePrice;
   long              ItemsNumber;
   long              SymbolsNumber;
   long              MaxLotsTicket;
   long              MinLotsTicket;
   long              LowestOpenPriceTicket;
   long              HighestOpenPriceTicket;
   long              EarliestOpenTimeTicket;
   long              LatestOpenTimeTicket;
   long              EarliestCloseTimeTicket;
   long              LatestCloseTimeTicket;
   //===============
   //===============
   virtual void      ReSet(void);
   //===============
   //===============
   void              cGroupInfo(void){this.ReSet();}
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   virtual void     ~cGroupInfo(void){}
   //===============
   //===============
   double            TotalLotsGet(void)const{return(this.TotalLots);}
   double            AveragePriceGet(void)const{return(this.AveragePrice);}
   long              ItemsNumberGet(void)const{return(this.ItemsNumber);}
   long              SymbolsNumberGet(void)const{return(this.SymbolsNumber);}
   long              MaxLotsTicketGet(void)const{return(this.MaxLotsTicket);}
   long              MinLotsTicketGet(void)const{return(this.MinLotsTicket);}
   long              LowestOpenPriceTicketGet(void)const{return(this.LowestOpenPriceTicket);}
   long              HighestOpenPriceTicketGet(void)const{return(this.HighestOpenPriceTicket);}
   long              EarliestOpenTimeTicketGet(void)const{return(this.EarliestOpenTimeTicket);}
   long              LatestOpenTimeTicketGet(void)const{return(this.LatestOpenTimeTicket);}
   long              EarliestCloseTimeTicketGet(void)const{return(this.EarliestCloseTimeTicket);}
   long              LatestCloseTimeTicketGet(void)const{return(this.LatestCloseTimeTicket);}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cGroupInfo::ReSet(void)
  {
//===============
   this.TotalLots               = 0.0;
   this.AveragePrice            = 0.0;
   this.ItemsNumber             = 0;
   this.SymbolsNumber           = 0;
   this.MaxLotsTicket           = -1;
   this.MinLotsTicket           = -1;
   this.LowestOpenPriceTicket   = -1;
   this.HighestOpenPriceTicket  = -1;
   this.EarliestOpenTimeTicket  = -1;
   this.LatestOpenTimeTicket    = -1;
   this.EarliestCloseTimeTicket = -1;
   this.LatestCloseTimeTicket   = -1;
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cTradesGroupInfo final : public cGroupInfo
  {
   //====================
private:
   //====================
   //===============
   //===============
   double            ProfitMoney;
   long              ProfitPoints;
   long              MaxProfitMoneyTicket;
   long              MinProfitMoneyTicket;
   long              MaxProfitPointsTicket;
   long              MinProfitPointsTicket;
   long              LowestClosePriceTicket;
   long              HighestClosePriceTicket;
   //===============
   //===============
   virtual void      ReSet(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cTradesGroupInfo(void){this.ReSet();}
   virtual void     ~cTradesGroupInfo(void){}
   //===============
   //===============
   double            ProfitMoneyGet(void)const{return(this.ProfitMoney);}
   long              ProfitPointsGet(void)const{return(this.ProfitPoints);}
   long              MaxProfitMoneyTicketGet(void)const{return(this.MaxProfitMoneyTicket);}
   long              MinProfitMoneyTicketGet(void)const{return(this.MinProfitMoneyTicket);}
   long              MaxProfitPointsTicketGet(void)const{return(this.MaxProfitPointsTicket);}
   long              MinProfitPointsTicketGet(void)const{return(this.MinProfitPointsTicket);}
   long              LowestClosePriceTicketGet(void)const{return(this.LowestClosePriceTicket);}
   long              HighestClosePriceTicketGet(void)const{return(this.HighestClosePriceTicket);}
   //===============
   //===============
   void              Update(const long &tickets[]);
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cTradesGroupInfo::Update(const long &tickets[])
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   this.ReSet();
//===============

//===============
   cTradeInfo trades[];
//===============

//===============
   cArray::Free(trades);
//===============

//===============
   const int size=cArray::Size(tickets);
//===============
   cArray::Resize(trades,size,0);
//===============

//===============
   for(int i=0;i<size && !::IsStopped();i++)
     {
      //===============
      trades[i].Update(tickets[i],true,true,false);
      //===============
     }
//===============

//===============
   string symbols[];
//===============

//===============
   cArray::Free(symbols);
//===============

//===============
   for(int i=0;i<size && !::IsStopped();i++)
     {
      //===============
      if(trades[i].TicketGet()<=0)continue;
      //===============

      //===============
      this.ItemsNumber++;
      this.TotalLots+=trades[i].LotsGet();
      this.ProfitMoney+=trades[i].ProfitMoneyGet()+trades[i].SwapGet()+trades[i].CommissionGet();
      this.ProfitPoints+=trades[i].ProfitPointsGet();
      //===============

      //===============
      if(!cArray::ValueExist(symbols,trades[i].SymbolGet()))cArray::AddLast(symbols,trades[i].SymbolGet(),size);
      //===============
     }
//===============

//===============
   this.SymbolsNumber=cArray::Size(symbols);
//===============

//===============
   double lowestopenprice      = DBL_MAX;
   double highestopenprice     = DBL_MIN;
   double lowestcloseprice     = DBL_MAX;
   double highestcloseprice    = DBL_MIN;
   double minlots              = DBL_MAX;
   double maxlots              = DBL_MIN;
   double maxprofitmoney       = DBL_MIN;
   double minprofitmoney       = DBL_MAX;
//===============
   long   maxprofitpoints      = LONG_MIN;
   long   minprofitpoints      = LONG_MIN;
//=============== 
   datetime earliestopentime   = INT_MAX;
   datetime latestopentime     = INT_MIN;
   datetime earliestclosetime  = INT_MAX;
   datetime latestclosetime    = INT_MIN;
//===============

//===============
   for(int i=0;i<size && !::IsStopped();i++)
     {
      //===============
      if(trades[i].TicketGet()<=0)continue;
      //===============

      //===============
      if(this.TotalLots!=0)this.AveragePrice+=trades[i].LotsGet()*trades[i].OpenPriceGet()/this.TotalLots;
      //===============

      //===============
      const long ticket=trades[i].TicketGet();
      //===============
      const double openprice=trades[i].OpenPriceGet();
      //===============
      const double closeprice=trades[i].ClosePriceGet();
      //===============
      const double lots=trades[i].LotsGet();
      //===============
      const double profitmoney=trades[i].ProfitMoneyGet();
      //===============
      const long profitpoints=trades[i].ProfitPointsGet();
      //===============
      const datetime opentime=trades[i].OpenTimeGet();
      //===============
      const datetime closetime=trades[i].CloseTimeGet();
      //===============

      //===============
      if(profitpoints<minprofitpoints)
        {
         //===============
         this.MinProfitPointsTicket=ticket;
         //===============
         minprofitpoints=profitpoints;
         //===============
        }
      //===============

      //===============
      if(profitpoints>maxprofitpoints)
        {
         //===============
         this.MaxProfitPointsTicket=ticket;
         //===============
         maxprofitpoints=profitpoints;
         //===============
        }
      //===============

      //===============
      if(profitmoney<minprofitmoney)
        {
         //===============
         this.MinProfitMoneyTicket=ticket;
         //===============
         minprofitmoney=profitmoney;
         //===============
        }
      //===============

      //===============
      if(profitmoney>maxprofitmoney)
        {
         //===============
         this.MaxProfitMoneyTicket=ticket;
         //===============
         maxprofitmoney=profitmoney;
         //===============
        }
      //===============

      //===============
      if(lots<minlots)
        {
         //===============
         this.MinLotsTicket=ticket;
         //===============
         minlots=lots;
         //===============
        }
      //===============

      //===============
      if(lots>maxlots)
        {
         //===============
         this.MaxLotsTicket=ticket;
         //===============
         maxlots=lots;
         //===============
        }
      //===============

      //===============
      if(openprice<lowestopenprice)
        {
         //===============
         this.LowestOpenPriceTicket=ticket;
         //===============
         lowestopenprice=openprice;
         //===============
        }
      //===============

      //===============
      if(openprice>highestopenprice)
        {
         //===============
         this.HighestOpenPriceTicket=ticket;
         //===============
         highestopenprice=openprice;
         //===============
        }
      //===============

      //===============
      if(closeprice<lowestcloseprice)
        {
         //===============
         this.LowestClosePriceTicket=ticket;
         //===============
         lowestcloseprice=closeprice;
         //===============
        }
      //===============

      //===============
      if(closeprice>highestcloseprice)
        {
         //===============
         this.HighestClosePriceTicket=ticket;
         //===============
         highestcloseprice=closeprice;
         //===============
        }
      //===============

      //===============
      if(opentime<earliestopentime)
        {
         //===============
         this.EarliestOpenTimeTicket=ticket;
         //===============
         earliestopentime=opentime;
         //===============
        }
      //===============

      //===============
      if(opentime>latestopentime)
        {
         //===============
         this.LatestOpenTimeTicket=ticket;
         //===============
         latestopentime=opentime;
         //===============
        }
      //===============

      //===============
      if(closetime<earliestclosetime)
        {
         //===============
         this.EarliestCloseTimeTicket=ticket;
         //===============
         earliestclosetime=closetime;
         //===============
        }
      //===============

      //===============
      if(closetime>latestclosetime)
        {
         //===============
         this.LatestCloseTimeTicket=ticket;
         //===============
         latestclosetime=closetime;
         //===============
        }
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cTradesGroupInfo::ReSet(void)override final
  {
//===============
   cGroupInfo::ReSet();
//===============

//===============
   this.ProfitMoney             = 0.0;
   this.ProfitPoints            = 0;
   this.MaxProfitMoneyTicket    = -1;
   this.MinProfitMoneyTicket    = -1;
   this.MaxProfitPointsTicket   = -1;
   this.MinProfitPointsTicket   = -1;
   this.LowestClosePriceTicket  = -1;
   this.HighestClosePriceTicket = -1;
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cPendingOrdersGroupInfo final : public cGroupInfo
  {
   //====================
private:
   //====================
   //===============
   //===============
   virtual void      ReSet(void)override final{cGroupInfo::ReSet();}
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cPendingOrdersGroupInfo(void){this.ReSet();}
   virtual void     ~cPendingOrdersGroupInfo(void){}
   //===============
   //===============
   void              Update(const long &tickets[]);
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cPendingOrdersGroupInfo::Update(const long &tickets[])
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   this.ReSet();
//===============

//===============
   cPendingOrderInfo orders[];
//===============

//===============
   cArray::Free(orders);
//===============

//===============
   const int size=cArray::Size(tickets);
//===============
   cArray::Resize(orders,size,0);
//===============

//===============
   for(int i=0;i<size && !::IsStopped();i++)
     {
      //===============
      orders[i].Update(tickets[i]);
      //===============
     }
//===============

//===============
   string symbols[];
//===============

//===============
   cArray::Free(symbols);
//===============

//===============
   for(int i=0;i<size && !::IsStopped();i++)
     {
      //===============
      if(orders[i].TicketGet()<=0)continue;
      //===============

      //===============
      this.ItemsNumber++;
      this.TotalLots+=orders[i].LotsGet();
      //===============

      //===============
      if(!cArray::ValueExist(symbols,orders[i].SymbolGet()))cArray::AddLast(symbols,orders[i].SymbolGet(),size);
      //===============
     }
//===============

//===============
   this.SymbolsNumber=cArray::Size(symbols);
//===============

//===============
   double lowestopenprice      = DBL_MAX;
   double highestopenprice     = DBL_MIN;
   double minlots              = DBL_MAX;
   double maxlots              = DBL_MIN;
//===============
   datetime earliestopentime   = INT_MAX;
   datetime latestopentime     = INT_MIN;
   datetime earliestclosetime  = INT_MAX;
   datetime latestclosetime    = INT_MIN;
//===============

//===============
   for(int i=0;i<size && !::IsStopped();i++)
     {
      //===============
      if(orders[i].TicketGet()<=0)continue;
      //===============

      //===============
      if(this.TotalLots!=0)this.AveragePrice+=orders[i].LotsGet()*orders[i].OpenPriceGet()/this.TotalLots;
      //===============

      //===============
      const long ticket=orders[i].TicketGet();
      //===============
      const double lots=orders[i].LotsGet();
      //===============
      const double openprice=orders[i].OpenPriceGet();
      //===============
      const datetime opentime=orders[i].OpenTimeGet();
      //===============
      const datetime closetime=orders[i].CloseTimeGet();
      //===============

      //===============
      if(lots<minlots)
        {
         //===============
         this.MinLotsTicket=ticket;
         //===============
         minlots=lots;
         //===============
        }
      //===============

      //===============
      if(lots>maxlots)
        {
         //===============
         this.MaxLotsTicket=ticket;
         //===============
         maxlots=lots;
         //===============
        }
      //===============

      //===============
      if(openprice<lowestopenprice)
        {
         //===============
         this.LowestOpenPriceTicket=ticket;
         //===============
         lowestopenprice=openprice;
         //===============
        }
      //===============

      //===============
      if(openprice>highestopenprice)
        {
         //===============
         this.HighestOpenPriceTicket=ticket;
         //===============
         highestopenprice=openprice;
         //===============
        }
      //===============

      //===============
      if(opentime<earliestopentime)
        {
         //===============
         this.EarliestOpenTimeTicket=ticket;
         //===============
         earliestopentime=opentime;
         //===============
        }
      //===============

      //===============
      if(opentime>latestopentime)
        {
         //===============
         this.LatestOpenTimeTicket=ticket;
         //===============
         latestopentime=opentime;
         //===============
        }
      //===============

      //===============
      if(closetime<earliestclosetime)
        {
         //===============
         this.EarliestCloseTimeTicket=ticket;
         //===============
         earliestclosetime=closetime;
         //===============
        }
      //===============

      //===============
      if(closetime>latestclosetime)
        {
         //===============
         this.LatestCloseTimeTicket=ticket;
         //===============
         latestclosetime=closetime;
         //===============
        }
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cFilter
  {
   //====================
protected:
   //====================
   //===============
   //===============
   bool              FilterByMagic;
   long              Magic;
   bool              FilterBySymbol;
   string            Symbol;
   bool              FilterByType;
   bool              FilterByTicketGreaterOrEqualThan;
   long              TicketGreaterOrEqualThan;
   bool              FilterByTicketLessOrEqualThan;
   long              TicketLessOrEqualThan;
   bool              FilterByExactComment;
   string            ExactComment;
   bool              FilterByCommentPartial;
   string            CommentPartial;
   bool              FilterByOpenPriceGreaterOrEqualThan;
   double            OpenPriceGreaterOrEqualThan;
   bool              FilterByOpenPriceLessOrEqualThan;
   double            OpenPriceLessOrEqualThan;
   bool              FilterByOpenTimeGreaterOrEqualThan;
   datetime          OpenTimeGreaterOrEqualThan;
   bool              FilterByOpenTimeLessOrEqualThan;
   datetime          OpenTimeLessOrEqualThan;
   bool              FilterByCloseTimeGreaterOrEqualThan;
   datetime          CloseTimeGreaterOrEqualThan;
   bool              FilterByCloseTimeLessOrEqualThan;
   datetime          CloseTimeLessOrEqualThan;
   bool              FilterByLotsGreaterOrEqualThan;
   double            LotsGreaterOrEqualThan;
   bool              FilterByLotsLessOrEqualThan;
   double            LotsLessOrEqualThan;
   //===============
   //===============
   virtual void      ReSet(void);
   //===============
   //===============
   void              cFilter(void){this.ReSet();}
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   virtual void     ~cFilter(void){}
   //===============
   //===============
   void              FilterByMagicSet(const bool filterbymagic){this.FilterByMagic=filterbymagic;}
   void              MagicSet(const long magic){this.Magic=magic;}
   void              FilterBySymbolSet(const bool filterbysymbol){this.FilterBySymbol=filterbysymbol;}
   void              SymbolSet(const string symbol){this.Symbol=symbol;}
   void              FilterByTypeSet(const bool filterbytype){this.FilterByType=filterbytype;}
   void              FilterByTicketGreaterSet(const bool filterbyticketgreater){this.FilterByTicketGreaterOrEqualThan=filterbyticketgreater;}
   void              TicketGreaterSet(const long ticketgreater){this.TicketGreaterOrEqualThan=ticketgreater;}
   void              FilterByTicketLessSet(const bool filterbyticketless){this.FilterByTicketLessOrEqualThan=filterbyticketless;}
   void              TicketLessSet(const long ticketless){this.TicketLessOrEqualThan=ticketless;}
   void              FilterByExactCommentSet(const bool filterbyexactcomment){this.FilterByExactComment=filterbyexactcomment;}
   void              ExactCommentSet(const string exactcomment){this.ExactComment=exactcomment;}
   void              FilterByCommentPartialSet(const bool filterbycommentpartial){this.FilterByCommentPartial=filterbycommentpartial;}
   void              CommentPartialSet(const string commentpartial){this.CommentPartial=commentpartial;}
   void              FilterByOpenPriceGreaterSet(const bool filterbyopenpricegreater){this.FilterByOpenPriceGreaterOrEqualThan=filterbyopenpricegreater;}
   void              OpenPriceGreaterSet(const double openpricegreater){this.OpenPriceGreaterOrEqualThan=openpricegreater;}
   void              FilterByOpenPriceLessSet(const bool filterbyopenpriceless){this.FilterByOpenPriceLessOrEqualThan=filterbyopenpriceless;}
   void              OpenPriceLessSet(const double openpriceless){this.OpenPriceLessOrEqualThan=openpriceless;}
   void              FilterByOpenTimeGreaterSet(const bool filterbyopentimegreater){this.FilterByOpenTimeGreaterOrEqualThan=filterbyopentimegreater;}
   void              OpenTimeGreaterSet(const datetime opentimegreater){this.OpenTimeGreaterOrEqualThan=opentimegreater;}
   void              FilterByOpenTimeLessSet(const bool filterbyopentimeless){this.FilterByOpenTimeLessOrEqualThan=filterbyopentimeless;}
   void              OpenTimeLessSet(const datetime opentimeless){this.OpenTimeLessOrEqualThan=opentimeless;}
   void              FilterByCloseTimeGreaterSet(const bool filterbyclosetimegreater){this.FilterByCloseTimeGreaterOrEqualThan=filterbyclosetimegreater;}
   void              CloseTimeGreaterSet(const datetime closetimegreater){this.CloseTimeGreaterOrEqualThan=closetimegreater;}
   void              FilterByCloseTimeLessSet(const bool filterbyclosetimeless){this.FilterByCloseTimeLessOrEqualThan=filterbyclosetimeless;}
   void              CloseTimeLessSet(const datetime closetimeless){this.CloseTimeLessOrEqualThan=closetimeless;}
   void              FilterByLotsGreaterSet(const bool filterbylotsgreater){this.FilterByLotsGreaterOrEqualThan=filterbylotsgreater;}
   void              LotsGreaterSet(const double lotsgreater){this.LotsGreaterOrEqualThan=lotsgreater;}
   void              FilterByLotsLessSet(const bool filterbylotsless){this.FilterByLotsLessOrEqualThan=filterbylotsless;}
   void              LotsLessSet(const double lotsless){this.LotsLessOrEqualThan=lotsless;}
   //===============
   //===============
   bool              SelectHistory(void)const;
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cFilter::SelectHistory(void)const
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   bool result=false;
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   datetime fromtime1 = 0;
   datetime fromtime2 = 0;
   datetime tilltime1 = ::TimeCurrent()+60;
   datetime tilltime2 = ::TimeCurrent()+60;
//===============
   if(this.FilterByOpenTimeGreaterOrEqualThan)fromtime1=this.OpenTimeGreaterOrEqualThan-60;
   if(this.FilterByOpenTimeLessOrEqualThan)tilltime1=this.OpenTimeLessOrEqualThan+60;
   if(this.FilterByCloseTimeGreaterOrEqualThan)fromtime2=this.CloseTimeGreaterOrEqualThan-60;
   if(this.FilterByCloseTimeLessOrEqualThan)tilltime2=this.CloseTimeLessOrEqualThan+60;
//===============

//===============
   const datetime fromtime=(datetime)::MathMin(fromtime1,fromtime2);
//===============
   const datetime tilltime=(datetime)::MathMax(tilltime1,tilltime2);
//===============

//===============
   result=::HistorySelect(fromtime,tilltime);
//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============
/* DEBUG ASSERTION */ASSERT({},false,true,{})
//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cFilter::ReSet(void)
  {
//===============
   this.FilterByMagic                        = false;
   this.Magic                                = -1;
   this.FilterBySymbol                       = false;
   this.Symbol                               = NULL;
   this.FilterByType                         = false;
   this.FilterByTicketGreaterOrEqualThan     = false;
   this.TicketGreaterOrEqualThan             = -1;
   this.FilterByTicketLessOrEqualThan        = false;
   this.TicketLessOrEqualThan                = -1;
   this.FilterByExactComment                 = false;
   this.ExactComment                         = NULL;
   this.FilterByCommentPartial               = false;
   this.CommentPartial                       = NULL;
   this.FilterByOpenPriceGreaterOrEqualThan  = false;
   this.OpenPriceGreaterOrEqualThan          = 0.0;
   this.FilterByOpenPriceLessOrEqualThan     = false;
   this.OpenPriceLessOrEqualThan             = 0.0;
   this.FilterByOpenTimeGreaterOrEqualThan   = false;
   this.OpenTimeGreaterOrEqualThan           = 0;
   this.FilterByOpenTimeLessOrEqualThan      = false;
   this.OpenTimeLessOrEqualThan              = 0;
   this.FilterByCloseTimeGreaterOrEqualThan  = false;
   this.CloseTimeGreaterOrEqualThan          = 0;
   this.FilterByCloseTimeLessOrEqualThan     = false;
   this.CloseTimeLessOrEqualThan             = 0;
   this.FilterByLotsGreaterOrEqualThan       = false;
   this.LotsGreaterOrEqualThan               = 0.0;
   this.FilterByLotsLessOrEqualThan          = false;
   this.LotsLessOrEqualThan                  = 0.0;
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cTradesFilter final : public cFilter
  {
   //====================
private:
   //====================
   //===============
   //===============
   eTradeStatus      Status;
   eTradeType        Type;
   bool              FilterByProfitGreaterOrEqualThan;
   double            ProfitGreaterOrEqualThan;
   bool              FilterByProfitLessOrEqualThan;
   double            ProfitLessOrEqualThan;
   bool              FilterByClosePriceGreaterOrEqualThan;
   double            ClosePriceGreaterOrEqualThan;
   bool              FilterByClosePriceLessOrEqualThan;
   double            ClosePriceLessOrEqualThan;
   //===============
   //===============
   virtual void      ReSet(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cTradesFilter(void){this.ReSet();}
   virtual void     ~cTradesFilter(void){}
   //===============
   //===============
   void              StatusSet(const eTradeStatus status){this.Status=status;}
   void              TypeSet(const eTradeType type){this.Type=type;}
   void              FilterByProfitGreaterSet(const bool filterbyprofitgreater){this.FilterByProfitGreaterOrEqualThan=filterbyprofitgreater;}
   void              ProfitGreaterSet(const double profitgreater){this.ProfitGreaterOrEqualThan=profitgreater;}
   void              FilterByProfitLessSet(const bool filterbyprofitless){this.FilterByProfitLessOrEqualThan=filterbyprofitless;}
   void              ProfitLessSet(const double profitless){this.ProfitLessOrEqualThan=profitless;}
   void              FilterByClosePriceGreaterSet(const bool filterbyclosepricegreater){this.FilterByClosePriceGreaterOrEqualThan=filterbyclosepricegreater;}
   void              ClosePriceGreaterSet(const double closepricegreater){this.ClosePriceGreaterOrEqualThan=closepricegreater;}
   void              FilterByClosePriceLessSet(const bool filterbyclosepriceless){this.FilterByClosePriceLessOrEqualThan=filterbyclosepriceless;}
   void              ClosePriceLessSet(const double closepriceless){this.ClosePriceLessOrEqualThan=closepriceless;}
   //===============
   //===============
   eTradeStatus      StatusGet(void)const{return(this.Status);}
   //===============
   //===============
   bool              Passed(const cTradeInfo &trade)const;
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cTradesFilter::Passed(const cTradeInfo &trade)const
  {
//===============
   if(trade.TicketGet()<=0)return(false);
//===============

//===============
   if(this.FilterByMagic && trade.MagicGet()!=this.Magic)return(false);
//===============

//===============
   if(this.FilterBySymbol && trade.SymbolGet()!=this.Symbol)return(false);
//===============

//===============
   if(this.Status!=TRADESTATUS_ALL && trade.StatusGet()!=this.Status)return(false);
//===============

//===============
   if(this.FilterByType && trade.TypeGet()!=this.Type)return(false);
//===============

//===============
   if(this.FilterByTicketGreaterOrEqualThan && trade.TicketGet()<this.TicketGreaterOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByTicketLessOrEqualThan && trade.TicketGet()>this.TicketLessOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByExactComment && trade.CommentGet()!=this.ExactComment)return(false);
//===============

//===============
   if(this.FilterByCommentPartial && ::StringFind(trade.CommentGet(),this.CommentPartial,0)<0)return(false);
//===============

//===============
   if(this.FilterByOpenPriceGreaterOrEqualThan && trade.OpenPriceGet()<this.OpenPriceGreaterOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByOpenPriceLessOrEqualThan && trade.OpenPriceGet()>this.OpenPriceLessOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByClosePriceGreaterOrEqualThan && trade.ClosePriceGet()<this.ClosePriceGreaterOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByClosePriceLessOrEqualThan && trade.ClosePriceGet()>this.ClosePriceLessOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByLotsGreaterOrEqualThan && trade.LotsGet()<this.LotsGreaterOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByLotsLessOrEqualThan && trade.LotsGet()>this.LotsLessOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByOpenTimeGreaterOrEqualThan && trade.OpenTimeGet()<this.OpenTimeGreaterOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByOpenTimeLessOrEqualThan && trade.OpenTimeGet()>this.OpenTimeLessOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByCloseTimeGreaterOrEqualThan && trade.CloseTimeGet()<this.CloseTimeGreaterOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByCloseTimeLessOrEqualThan && trade.CloseTimeGet()>this.CloseTimeLessOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByProfitGreaterOrEqualThan && trade.ProfitMoneyGet()<this.ProfitGreaterOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByProfitLessOrEqualThan && trade.ProfitMoneyGet()>this.ProfitLessOrEqualThan)return(false);
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cTradesFilter::ReSet(void)override final
  {
//===============
   cFilter::ReSet();
//===============

//===============
   this.Status                               = WRONG_VALUE;
   this.Type                                 = WRONG_VALUE;
   this.FilterByProfitGreaterOrEqualThan     = false;
   this.ProfitGreaterOrEqualThan             = 0.0;
   this.FilterByProfitLessOrEqualThan        = false;
   this.ProfitLessOrEqualThan                = 0.0;
   this.FilterByClosePriceGreaterOrEqualThan = false;
   this.ClosePriceGreaterOrEqualThan         = 0.0;
   this.FilterByClosePriceLessOrEqualThan    = false;
   this.ClosePriceLessOrEqualThan            = 0.0;
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cPendingOrdersFilter final : public cFilter
  {
   //====================
private:
   //====================
   //===============
   //===============
   ePendingOrderStatus Status;
   ePendingOrderType Type;
   //===============
   //===============
   virtual void      ReSet(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cPendingOrdersFilter(void){this.ReSet();}
   virtual void     ~cPendingOrdersFilter(void){}
   //===============
   //===============
   void              StatusSet(const ePendingOrderStatus status){this.Status=status;}
   void              TypeSet(const ePendingOrderType type){this.Type=type;}
   //===============
   //===============
   ePendingOrderStatus StatusGet(void)const{return(this.Status);}
   //===============
   //===============
   bool              Passed(const cPendingOrderInfo &order)const;
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cPendingOrdersFilter::Passed(const cPendingOrderInfo &order)const
  {
//===============
   if(order.TicketGet()<=0)return(false);
//===============

//===============
   if(this.FilterByMagic && order.MagicGet()!=this.Magic)return(false);
//===============

//===============
   if(this.FilterBySymbol && order.SymbolGet()!=this.Symbol)return(false);
//===============

//===============
   if(this.Status!=ORDERSTATUS_ALL && order.StatusGet()!=this.Status)return(false);
//===============

//===============
   if(this.FilterByType && order.TypeGet()!=this.Type)return(false);
//===============

//===============
   if(this.FilterByTicketGreaterOrEqualThan && order.TicketGet()<this.TicketGreaterOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByTicketLessOrEqualThan && order.TicketGet()>this.TicketLessOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByExactComment && order.CommentGet()!=this.ExactComment)return(false);
//===============

//===============
   if(this.FilterByCommentPartial && ::StringFind(order.CommentGet(),this.CommentPartial,0)<0)return(false);
//===============

//===============
   if(this.FilterByOpenPriceGreaterOrEqualThan && order.OpenPriceGet()<this.OpenPriceGreaterOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByOpenPriceLessOrEqualThan && order.OpenPriceGet()>this.OpenPriceLessOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByOpenTimeGreaterOrEqualThan && order.OpenTimeGet()<this.OpenTimeGreaterOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByOpenTimeLessOrEqualThan && order.OpenTimeGet()>this.OpenTimeLessOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByCloseTimeGreaterOrEqualThan && (order.CloseTimeGet()==0 || order.CloseTimeGet()<this.CloseTimeGreaterOrEqualThan))return(false);
//===============

//===============
   if(this.FilterByCloseTimeLessOrEqualThan && (order.CloseTimeGet()==0 || order.CloseTimeGet()>this.CloseTimeLessOrEqualThan))return(false);
//===============

//===============
   if(this.FilterByLotsGreaterOrEqualThan && order.LotsGet()<this.LotsGreaterOrEqualThan)return(false);
//===============

//===============
   if(this.FilterByLotsLessOrEqualThan && order.LotsGet()>this.LotsLessOrEqualThan)return(false);
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cPendingOrdersFilter::ReSet(void)override final
  {
//===============
   cFilter::ReSet();
//===============

//===============
   this.Status                               = WRONG_VALUE;
   this.Type                                 = WRONG_VALUE;
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cTrade final
  {
   //====================
private:
   //====================
   //===============
   //===============
   void              cTrade(void){}
   virtual void     ~cTrade(void){}
   //===============
   //===============
   static void       AddCurrentTrades(const cTradesFilter &filter,long &tickets[]);
   static void       AddCurrentOrders(const cPendingOrdersFilter &filter,long &tickets[]);
   static void       AddHistoryTrades(const cTradesFilter &filter,long &tickets[]);
   static void       AddHistoryOrders(const cPendingOrdersFilter &filter,long &tickets[]);
   //===============
   //===============
   static double     ExistingVolume(const string symbol,const eTradeType type);
   //===============
   //===============
   static bool       CheckMaxOrders(void);
   static bool       CheckMaxVolume(const string symbol,const eTradeType type,const double volume);
   static bool       CheckPlaced(const string symbol,const eTradeType type,const long magic);
   static bool       CheckMargin(const string symbol,const double volume,const eTradeType type,const double price);
   static bool       CheckOrderPrice(const string symbol,const ePendingOrderType type,const double price);
   static bool       CheckStops(const string symbol,const eTradeType type,const bool istrade,const double entrylevel,
                                const double stoploss,const double takeprofit);
   //===============
   //===============
   static bool       CheckFreezed(const string symbol,const eTradeType type,const double stoploss,const double takeprofit);
   static bool       CheckFreezed(const string symbol,const ePendingOrderType type,const double entryprice);
   //===============
   //===============
   static int        GetMatch(const cTradeInfo &trades[],const int forindex,long &matched[]);
   static void       TradesCloseBy(const long &tickets[],const bool slippageenabled,const long slippage);
   //===============
   //===============
   static void       CloseBy(const long ticket1,const long ticket2);
   //===============
   //===============
   static void       CalculateSLandTP(const string symbol,const eTradeType type,const double entrylevel,const double lots,
                                      const bool slpointsenabled,const long slpoints,const bool tppointsenabled,const long tppoints,
                                      const bool slmoneyenabled,const double slmoney,const bool tpmoneyenabled,const double tpmoney,
                                      const bool slpriceenabled,const double slprice,const bool tppriceenabled,const double tpprice,
                                      double &sllevel,double &tplevel);
   //===============
   //===============
   static bool       OpeningAllowed(const string symbol,const eTradeType type);
   static bool       ClosingAllowed(const string symbol);
   //===============
   //===============
   static void       NettPosition(const cTradeInfo &trades[],cTradeInfo &tradesnetted[]);
   static void       GetSymbols(const cTradeInfo &trades[],string &symbols[]);
   static void       GetSymbolTrades(const cTradeInfo &trades[],const string symbol,cTradeInfo &symboltrades[]);
   static bool       GetDealAsTradeFromSelectedHistory(const long ticket,cTradeInfo &trade);
   //===============
   //===============
   static bool       CanTrade(void);
   //===============
   //===============
#ifdef __MQL5__
   static ENUM_ORDER_TYPE_FILLING GetFilling(const string symbol);
   static ENUM_ORDER_TYPE_TIME GetExpirationType(const string symbol);
#endif
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   static bool       IsNettingAccount(void);
   //===============
   //===============
   static void       GetPositionAsDeals(const long ticket,cTradeInfo &trades[],const bool searchoriginalticket);
   static void       GetDealAsTrade(const long ticket,cTradeInfo &trade);
   //===============
   //===============
   static void       GetOriginalTicket(long &originalticket,const string currentcomment);
   //===============
   //===============
   static void       NettTrades(const cTradeInfo &trades[],cTradeInfo &tradesnetted[]);
   //===============
   //===============
   static long       ProfitPointsGet(const eTradeType type,const double openprice,const double closeprice,const string symbol);
   static double     CommissionGet(const long positionID);
   //===============
   //===============
   static double     PointPrice(const string symbol);
   //===============
   //===============
   static void       GetFilteredTradesTickets(const cTradesFilter &filter,long &tickets[]);
   static void       GetFilteredPendingOrdersTickets(const cPendingOrdersFilter &filter,long &tickets[]);
   //===============
   //===============
   static bool       TradeTypeAllowed(const eAllowedTrades allowed,const eTradeType type);
   //===============
   //===============
   static double     CheckLot(const string symbol,const double lots);
   static double     GetLot(const string symbol,const long slpoints,const double moneyrisk);
   static double     CalculateLot(const string symbol,const eTradeType type,const double requiredbelevel,const double dealprice,
                                  const double lotsnow,const double belevelnow);
   //===============
   //===============
   static long       OpenTrade(const string symbol,const eTradeType type,const double lots,const long magic,const string comment,
                               const long slippage,const bool checkplaced,uint &retcode,eError &myretcode);
   static long       OpenTrade(const string symbol,const eTradeType type,const double lots,const long magic,const string comment,
                               const bool slpointsenabled,const long slpoints,const bool tppointsenabled,const long tppoints,
                               const bool slmoneyenabled,const double slmoney,const bool tpmoneyenabled,const double tpmoney,
                               const bool slpriceenabled,const double slprice,const bool tppriceenabled,const double tpprice,
                               const bool slippageenabled,const long slippage,const bool checkplaced,uint &retcode,eError &myretcode);
   //===============
   //===============
   static long       PlacePendingOrder(const string symbol,const double price,const ePendingOrderType type,const double lots,
                                       const long magic,const string comment,const datetime expiration,uint &retcode,eError &myretcode);
   static long       PlacePendingOrder(const string symbol,const double price,const ePendingOrderType type,const double lots,
                                       const long magic,const string comment,
                                       const bool slpointsenabled,const long slpoints,const bool tppointsenabled,const long tppoints,
                                       const bool slmoneyenabled,const double slmoney,const bool tpmoneyenabled,const double tpmoney,
                                       const bool slpriceenabled,const double slprice,const bool tppriceenabled,const double tpprice,
                                       const bool expirationenabled,const datetime expiration,uint &retcode,eError &myretcode);
   //===============
   //===============
   static bool       ModifyTrade(const long ticket,const double newsl,const double newtp,uint &retcode,eError &myretcode);
   static bool       ModifyTrade(const long ticket,const bool tightenstopsonly,
                                 const bool slpointsenabled,const long slpoints,const bool tppointsenabled,const long tppoints,
                                 const bool slmoneyenabled,const double slmoney,const bool tpmoneyenabled,const double tpmoney,
                                 const bool slpriceenabled,const double slprice,const bool tppriceenabled,const double tpprice,
                                 uint &retcode,eError &myretcode);
   static void       ModifyTrades(const long &tickets[],const bool tightenstopsonly,
                                  const bool slpointsenabled,const long slpoints,const bool tppointsenabled,const long tppoints,
                                  const bool slmoneyenabled,const double slmoney,const bool tpmoneyenabled,const double tpmoney,
                                  const bool slpriceenabled,const double slprice,const bool tppriceenabled,const double tpprice);
   //===============
   //===============
   static bool       ModifyPendingOrder(const long ticket,const double newprice,const double newsl,const double newtp,
                                        const datetime newexpiration,uint &retcode,eError &myretcode);
   static void       ModifyPendingOrder(const long ticket,const bool priceenabled,const double price,const bool tightenstopsonly,
                                        const bool slpointsenabled,const long slpoints,const bool tppointsenabled,const long tppoints,
                                        const bool slmoneyenabled,const double slmoney,const bool tpmoneyenabled,const double tpmoney,
                                        const bool slpriceenabled,const double slprice,const bool tppriceenabled,const double tpprice,
                                        const bool expirationenabled,const datetime expiration);
   static void       ModifyPendingOrders(const long &tickets[],const bool priceenabled,const double price,const bool tightenstopsonly,
                                         const bool slpointsenabled,const long slpoints,const bool tppointsenabled,const long tppoints,
                                         const bool slmoneyenabled,const double slmoney,const bool tpmoneyenabled,const double tpmoney,
                                         const bool slpriceenabled,const double slprice,const bool tppriceenabled,const double tpprice,
                                         const bool expirationenabled,const datetime expiration);
   //===============
   //===============
   static bool       CloseTrade(const long ticket,const bool slippageenabled,const long slippage,const double lots,uint &retcode,eError &myretcode);
   static void       CloseTrades(const long &tickets[],const bool closeby,const bool slippageenabled,const long slippage);
   //===============
   //===============
   static bool       DeletePendingOrder(const long ticket,uint &retcode,eError &myretcode);
   static void       DeletePendingOrders(const long &tickets[]);
   //===============
   //===============
   static bool       BreakEven(const long ticket,const long belevel,const long beprofit,uint &retcode,eError &myretcode);
   static bool       TrailingStop(const long ticket,const long tslstart,const long tsldistance,const bool tsllevelenabled,
                                  const double tsllevel,uint &retcode,eError &myretcode);
   //===============
   //===============
   static void       BreakEven(const long &tickets[],const long belevel,const long beprofit);
   static void       TrailingStop(const long &tickets[],const long tslstart,const long tsldistance,const bool tsllevelenabled,const double tsllevel);
   //===============
   //===============
   static ePendingOrderType OrderTypeFromTradeType(const eTradeType tradetype,const double orderprice,const string symbol);
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::CheckMaxOrders(void)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   static const int maxallowed = (int)::AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   const int existing          = #ifdef __MQL5__ ::PositionsTotal() + ::OrdersTotal() #endif #ifdef __MQL4__ ::OrdersTotal() #endif;
//===============

//===============
   if(existing>=maxallowed && maxallowed!=0)return(false);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static double cTrade::ExistingVolume(const string symbol,const eTradeType type)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   double result=0;
//===============

//===============
#ifdef __MQL5__
//===============
   const int tradesnumber=::PositionsTotal();
//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============
   const int tradesnumber=::OrdersTotal();
//===============
#endif 
//===============

//===============
   for(int i=0;i<tradesnumber && !::IsStopped();i++)
     {
      //===============
#ifdef __MQL5__
      //===============
      const long ticket=(long)::PositionGetTicket(i);
      //===============
#endif 
      //===============

      //===============
#ifdef __MQL4__
      //===============
      if(!::OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
      //===============
      const int ordertype=::OrderType();
      //===============
      if(ordertype!=OP_BUY && ordertype!=OP_SELL)continue;
      //===============
      const long ticket=(long)::OrderTicket();
      //===============
#endif 
      //===============

      //===============
      cTradeInfo trade;
      //===============

      //===============
      trade.Update(ticket,false,false,false);
      //===============

      //===============
      if(trade.SymbolGet()!=symbol || trade.TypeGet()!=type)continue;
      //===============

      //===============
      result+=trade.LotsGet();
      //===============
     }
//===============

//===============
   const int ordersnumber=::OrdersTotal();
//===============

//===============
   for(int i=0;i<ordersnumber && !::IsStopped();i++)
     {
      //===============
#ifdef __MQL5__
      //===============
      const long ticket=(long)::OrderGetTicket(i);
      //===============
      const ENUM_ORDER_TYPE ordertype=(ENUM_ORDER_TYPE)::OrderGetInteger(ORDER_TYPE);
      //===============
      if(ordertype!=ORDER_TYPE_BUY_STOP && ordertype!=ORDER_TYPE_BUY_LIMIT &&
         ordertype!=ORDER_TYPE_SELL_STOP && ordertype!=ORDER_TYPE_SELL_LIMIT)continue;
      //===============
#endif 
      //===============

      //===============
#ifdef __MQL4__
      //===============
      if(!::OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
      //===============
      const int ordertype=::OrderType();
      //===============
      if(ordertype!=OP_BUYSTOP && ordertype!=OP_BUYLIMIT && ordertype!=OP_SELLSTOP && ordertype!=OP_SELLLIMIT)continue;
      //===============
      const long ticket=(long)::OrderTicket();
      //===============
#endif 
      //===============

      //===============
      cPendingOrderInfo order;
      //===============

      //===============
      order.Update(ticket);
      //===============

      //===============
      const eTradeType side=(order.TypeGet()==PENDINGORDERTYPE_BUYLIMIT || order.TypeGet()==PENDINGORDERTYPE_BUYSTOP)?TRADETYPE_BUY:TRADETYPE_SELL;
      //===============

      //===============
      if(order.SymbolGet()!=symbol || side!=type)continue;
      //===============

      //===============
      result+=order.LotsGet();
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::CheckMaxVolume(const string symbol,const eTradeType type,const double volume)
  {
//===============
#ifdef __MQL4__ return(true); #endif
//===============

//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const double maxallowedvolume=::SymbolInfoDouble(symbol,SYMBOL_VOLUME_LIMIT);
//===============

//===============
   if(maxallowedvolume<=0)return(true);
//===============

//===============
   const double existingvolume=cTrade::ExistingVolume(symbol,type);
//===============

//===============
   if(volume+existingvolume>maxallowedvolume)return(false);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::CheckPlaced(const string symbol,const eTradeType type,const long magic)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   static const bool istesting=(bool)::MQLInfoInteger(MQL_TESTER);
//===============

//===============
   if(istesting)return(true);
//===============

//===============
   const int ordersnumber=::OrdersTotal();
//===============

//===============
   for(int i=0;i<ordersnumber && !::IsStopped();i++)
     {
      //===============
      const long ticket=(long)::OrderGetTicket(i);
      //===============

      //===============
      const ENUM_ORDER_TYPE ordertype=(ENUM_ORDER_TYPE)::OrderGetInteger(ORDER_TYPE);
      //===============

      //===============
      const long ordermagic=::OrderGetInteger(ORDER_MAGIC);
      //===============

      //===============
      const string ordersymbol=::OrderGetString(ORDER_SYMBOL);
      //===============

      //===============
      if(ordertype!=ORDER_TYPE_BUY && ordertype!=ORDER_TYPE_SELL)continue;
      //===============

      //===============
      if(ordermagic!=magic)continue;
      //===============

      //===============
      if(ordersymbol!=symbol)continue;
      //===============

      //===============
      if(::OrderGetInteger(ORDER_POSITION_ID)>0)continue;
      //===============

      //===============
      if(type==TRADETYPE_BUY && ordertype==ORDER_TYPE_BUY)return(false);
      //===============

      //===============
      if(type==TRADETYPE_SELL && ordertype==ORDER_TYPE_SELL)return(false);
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::CheckMargin(const string symbol,const double volume,const eTradeType type,const double price)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   if(::SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE)!=SYMBOL_CALC_MODE_FOREX)return(true);
//===============

//===============
   const ENUM_ORDER_TYPE ordertype=(type==TRADETYPE_BUY?ORDER_TYPE_BUY:ORDER_TYPE_SELL);
//===============

//===============
   double init  = 0.0;
   double main  = 0.0;
   double order = 0.0;
//===============

//===============
   const double tickvalue = ::SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   const double ticksize  = ::SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   const int    leverage  = (int)::AccountInfoInteger(ACCOUNT_LEVERAGE);
//===============

//===============
   const bool getrate=::SymbolInfoMarginRate(symbol,ordertype,init,main);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},getrate,false,{})
//===============

//===============
   if(!getrate || ticksize*leverage==0)
     {
      //===============
      const bool calculate=::OrderCalcMargin(ordertype,symbol,volume,price,order);
      //===============
/* DEBUG ASSERTION */ASSERT({},calculate,false,{})
      //===============
     }
//===============

//===============
   const double marginrequired=(getrate && ticksize*leverage!=0)?(init*price*volume*tickvalue/(ticksize*leverage)):order;
//===============
   const double freemargin=::AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//===============
   const bool result=((marginrequired<=0 || marginrequired<freemargin) && freemargin>0);
//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============

//===============
   const double marginrequired=::MarketInfo(symbol,MODE_MARGINREQUIRED)*volume;
//===============

//===============
   const bool result=(marginrequired<=0 || marginrequired<::AccountInfoDouble(ACCOUNT_MARGIN_FREE));
//===============

//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static ePendingOrderType cTrade::OrderTypeFromTradeType(const eTradeType tradetype,const double orderprice,const string symbol)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   ePendingOrderType result=WRONG_VALUE;
//===============

//===============
   MqlTick tick={0};
   if(!::SymbolInfoTick(symbol,tick) || tick.ask<=0 || tick.bid<=0)return(WRONG_VALUE);
//===============

//===============
   if(tradetype==TRADETYPE_BUY)
     {
      //===============
      if(orderprice>tick.ask)result=PENDINGORDERTYPE_BUYSTOP;
      else result=PENDINGORDERTYPE_BUYLIMIT;
      //===============
     }
   else if(tradetype==TRADETYPE_SELL)
     {
      //===============
      if(orderprice>tick.bid)result=PENDINGORDERTYPE_SELLLIMIT;
      else result=PENDINGORDERTYPE_SELLSTOP;
      //===============
     }
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},result!=WRONG_VALUE,false,{})
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::CheckOrderPrice(const string symbol,const ePendingOrderType type,const double price)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   if(price<=0)return(false);
//===============

//===============
   MqlTick lasttick;
//===============
   ::ZeroMemory(lasttick);
//===============
   const bool gettick=::SymbolInfoTick(symbol,lasttick);
//===============
/* DEBUG ASSERTION */ASSERT({},gettick,true,{})
//===============
   if(!gettick)return(false);
//===============

//===============
   const int    stopslevel  = (int)::SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);
   const double point       = ::SymbolInfoDouble(symbol,SYMBOL_POINT);
   const double mindistance = (stopslevel>0?(stopslevel*point):(2.0*(lasttick.ask-lasttick.bid)));
//===============

//===============
   switch(type)
     {
      //===============
      case  PENDINGORDERTYPE_BUYSTOP        :   if((price-lasttick.ask)<=mindistance)return(false);     break;
      case  PENDINGORDERTYPE_BUYLIMIT       :   if((lasttick.ask-price)<=mindistance)return(false);     break;
      case  PENDINGORDERTYPE_SELLSTOP       :   if((lasttick.bid-price)<=mindistance)return(false);     break;
      case  PENDINGORDERTYPE_SELLLIMIT      :   if((price-lasttick.bid)<=mindistance)return(false);     break;
      //===============
      default                   :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::CheckFreezed(const string symbol,const eTradeType type,const double stoploss,const double takeprofit)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   if(takeprofit==0 && stoploss==0)return(false);
//===============

//===============
   MqlTick lasttick;
//===============
   ::ZeroMemory(lasttick);
//===============
   const bool gettick=::SymbolInfoTick(symbol,lasttick);
//===============
/* DEBUG ASSERTION */ASSERT({},gettick,true,{})
//===============
   if(!gettick)return(true);
//===============

//===============
   const int    freezelevel  = (int)::SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   const double point        = ::SymbolInfoDouble(symbol,SYMBOL_POINT);
   const double mindistance  = freezelevel*point;
//===============

//===============
   if(freezelevel==0)return(false);
//===============

//===============
   if(takeprofit>0)
     {
      //===============
      switch(type)
        {
         //===============
         case TRADETYPE_BUY        :      if(takeprofit-lasttick.bid<=mindistance)return(true); break;
         case TRADETYPE_SELL       :      if(lasttick.ask-takeprofit<=mindistance)return(true); break;
         //===============
         default                 :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
         //=============== 
        }
      //===============
     }
//===============

//===============
   if(stoploss>0)
     {
      //===============
      switch(type)
        {
         //===============
         case TRADETYPE_BUY        :      if(lasttick.bid-stoploss<=mindistance)return(true); break;
         case TRADETYPE_SELL       :      if(stoploss-lasttick.ask<=mindistance)return(true); break;
         //===============
         default                 :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
         //=============== 
        }
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(false);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::CheckFreezed(const string symbol,const ePendingOrderType type,const double entryprice)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   MqlTick lasttick;
//===============
   ::ZeroMemory(lasttick);
//===============
   const bool gettick=::SymbolInfoTick(symbol,lasttick);
//===============
/* DEBUG ASSERTION */ASSERT({},gettick,true,{})
//===============
   if(!gettick)return(true);
//===============

//===============
   const int    freezelevel  = (int)::SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   const double point        = ::SymbolInfoDouble(symbol,SYMBOL_POINT);
   const double mindistance  = freezelevel*point;
//===============

//===============
   if(freezelevel==0)return(false);
//===============

//===============
   switch(type)
     {
      //===============
      case PENDINGORDERTYPE_BUYLIMIT        :      if(lasttick.ask-entryprice<=mindistance)return(true); break;
      case PENDINGORDERTYPE_BUYSTOP         :      if(entryprice-lasttick.ask<=mindistance)return(true); break;
      case PENDINGORDERTYPE_SELLLIMIT       :      if(entryprice-lasttick.bid<=mindistance)return(true); break;
      case PENDINGORDERTYPE_SELLSTOP        :      if(lasttick.bid-entryprice<=mindistance)return(true); break;
      //===============
      default                 :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //=============== 
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(false);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::CheckStops(const string symbol,const eTradeType type,const bool istrade,const double entrylevel,
                               const double stoploss,const double takeprofit)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   if(stoploss==0 && takeprofit==0)return(true);
//===============

//===============
   if(stoploss<0 || takeprofit<0)return(false);
//===============

//===============
   MqlTick lasttick;
//===============
   ::ZeroMemory(lasttick);
//===============
   const bool gettick=::SymbolInfoTick(symbol,lasttick);
//===============
/* DEBUG ASSERTION */ASSERT({},gettick,true,{})
//===============
   if(!gettick)return(false);
//===============

//===============
   const int    stopslevel  = (int)::SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL);
   const double point       = ::SymbolInfoDouble(symbol,SYMBOL_POINT);
   const double mindistance = (stopslevel>0?(stopslevel*point):(2.0*(lasttick.ask-lasttick.bid)));
//===============

//===============
   if(type==TRADETYPE_BUY)
     {
      //===============
      if(!istrade && stoploss>0 && (entrylevel-stoploss)<=mindistance)return(false);
      if(istrade && stoploss>0 && (lasttick.bid-stoploss)<=mindistance)return(false);
      //===============

      //===============
      if(!istrade && takeprofit>0 && (takeprofit-entrylevel)<=mindistance)return(false);
      if(istrade && takeprofit>0 && (takeprofit-lasttick.bid)<=mindistance)return(false);
      //===============
     }
//===============

//===============
   if(type==TRADETYPE_SELL)
     {
      //===============
      if(!istrade && stoploss>0 && (stoploss-entrylevel)<=mindistance)return(false);
      if(istrade && stoploss>0 && (stoploss-lasttick.ask)<=mindistance)return(false);
      //===============

      //===============
      if(!istrade && takeprofit>0 && (entrylevel-takeprofit)<=mindistance)return(false);
      if(istrade && takeprofit>0 && (lasttick.ask-takeprofit)<=mindistance)return(false);
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static int cTrade::GetMatch(const cTradeInfo &trades[],const int forindex,long &matched[])
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   if(trades[forindex].TicketGet()<=0 || trades[forindex].StatusGet()!=TRADESTATUS_CURRENT)return(-1);
//===============

//===============
#ifdef __MQL5__
//===============
   const int ordermode=(int)::SymbolInfoInteger(trades[forindex].SymbolGet(),SYMBOL_ORDER_MODE);
//===============
   const bool orderallowed=((SYMBOL_ORDER_CLOSEBY&ordermode)==SYMBOL_ORDER_CLOSEBY);
//===============
/* DEBUG ASSERTION */ASSERT({},orderallowed,true,{})
//===============
   if(!orderallowed)return(-1);
//===============
#endif 
//===============

//===============
   int result=-1;
//===============

//===============
   const int size=cArray::Size(trades);
//===============

//===============
   for(int i=forindex+1;i<size;i++)
     {
      //===============
      if(trades[i].TicketGet()<=0 || trades[i].StatusGet()!=TRADESTATUS_CURRENT)continue;
      //===============

      //===============
      if(cArray::ValueExist(matched,trades[i].TicketGet()))continue;
      //===============

      //===============
      if(trades[forindex].SymbolGet()!=trades[i].SymbolGet())continue;
      //===============

      //===============
      if(trades[forindex].TypeGet()==trades[i].TypeGet())continue;
      //===============

      //===============
      if(trades[forindex].LotsGet()!=trades[i].LotsGet())continue;
      //===============

      //===============
      result=i;
      //===============

      //===============
      break;
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::TradesCloseBy(const long &tickets[],const bool slippageenabled,const long slippage)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const int size=cArray::Size(tickets);
//===============

//===============
   if(size<=0)return;
//===============

//===============
   cTradeInfo trades[];
//===============
   cArray::Resize(trades,size,0);
//===============

//===============
   for(int i=0;i<size;i++)
     {
      //===============
      trades[i].Update(tickets[i],false,false,false);
      //===============
     }
//===============

//===============
   long tickets1[];
   long tickets2[];
   long nomatch[];
//===============
   cArray::Free(tickets1);
   cArray::Free(tickets2);
   cArray::Free(nomatch);
//===============

//===============
   for(int i=0;i<size;i++)
     {
      //===============
      if(cArray::ValueExist(tickets2,tickets[i]))continue;
      //===============

      //===============
      const int matchedindex=cTrade::GetMatch(trades,i,tickets2);
      //===============

      //===============
      if(matchedindex>0)
        {
         //===============
         cArray::AddLast(tickets1,tickets[i],size);
         //===============

         //===============
         cArray::AddLast(tickets2,tickets[matchedindex],size);
         //===============
        }
      else
        {
         //===============
         cArray::AddLast(nomatch,tickets[i],size);
         //===============
        }
      //===============
     }
//===============

//===============
   const int size1       = cArray::Size(tickets1);
   const int size2       = cArray::Size(tickets2);
   const int nomatchsize = cArray::Size(nomatch);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},size1==size2,false,{})
//===============
/* DEBUG ASSERTION */ASSERT({},size1+size2+nomatchsize==size,false,{})
//===============

//===============
   for(int i=0;i<size1;i++)
     {
      //===============
      cTrade::CloseBy(tickets1[i],tickets2[i]);
      //===============
     }
//===============

//===============
   cTrade::CloseTrades(nomatch,false,slippageenabled,slippage);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::IsNettingAccount(void)
  {
//===============
#ifdef __MQL4__
//===============
   return(false);
//===============
#endif
//===============

//===============
#ifdef __MQL5__
//===============
   return((ENUM_ACCOUNT_MARGIN_MODE)::AccountInfoInteger(ACCOUNT_MARGIN_MODE)!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
//===============
#endif
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::GetDealAsTrade(const long ticket,cTradeInfo &trade)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   trade.ReSet();
//===============

//===============
   if(ticket<=0)return;
//===============

//===============
// Hedging Accounts
//===============
   if(!cTrade::IsNettingAccount())return;
//===============

//===============
// Netting Accounts
//===============     

//===============
#ifdef __MQL5__
//===============

//===============
   if(!::HistorySelect(0,::TimeCurrent()+60))return;
//===============

//===============
   cTrade::GetDealAsTradeFromSelectedHistory(ticket,trade);
//===============

//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::GetOriginalTicket(long &originalticket,const string currentcomment)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
#ifdef __MQL4__
//===============

//===============
   if(currentcomment=="" || currentcomment==NULL)return;
//===============

//===============
   const int searchfromresult = ::StringFind(currentcomment,SEARCHFROM,0);
   const int searchtoresult   = ::StringFind(currentcomment,SEARCHTO,0);
//===============

//===============
   if(searchfromresult>=0)
     {
      //===============
      const int ticket=(int)::StringToInteger(::StringSubstr(currentcomment,searchfromresult+::StringLen(SEARCHFROM)));
      //===============

      //===============
      const int tradesnumber=::OrdersHistoryTotal();
      //===============

      //===============
      // Check for closeby scenario
      //===============
      for(int i=0;i<tradesnumber && !::IsStopped();i++)
        {
         //===============
         if(!::OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))continue;
         //===============

         //===============
         const int ordertype=::OrderType();
         //===============
         if(ordertype!=OP_BUY && ordertype!=OP_SELL)continue;
         //===============

         //===============
         const string comment=::OrderComment();
         //===============

         //===============
         if(comment=="" || comment==NULL)continue;
         //===============

         //===============
         const int found=::StringFind(comment,SEARCHBY+(string)ticket,0);
         //===============

         //===============
         if(found>=0)
           {
            //===============
            originalticket=::OrderTicket();
            //===============

            //===============
            return;
            //===============
           }
         //===============
        }
      //===============

      //===============
      if(!::OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY))return;
      //===============

      //===============
      originalticket=ticket;
      //===============

      //===============
      cTrade::GetOriginalTicket(originalticket,::OrderComment());
      //===============

      //===============
      return;
      //===============
     }
//===============

//===============
   if(searchtoresult>=0)
     {
      //===============
      const int tradesnumber=::OrdersHistoryTotal();
      //===============

      //===============
      for(int i=0;i<tradesnumber && !::IsStopped();i++)
        {
         //===============
         if(!::OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))continue;
         //===============

         //===============
         const int ordertype=::OrderType();
         //===============
         if(ordertype!=OP_BUY && ordertype!=OP_SELL)continue;
         //===============

         //===============
         const string comment=::OrderComment();
         //===============

         //===============
         if(comment=="" || comment==NULL)continue;
         //===============

         //===============
         const int found=::StringFind(comment,SEARCHTO+(string)originalticket,0);
         //===============

         //===============
         if(found>=0)
           {
            //===============
            originalticket=::OrderTicket();
            //===============

            //===============
            cTrade::GetOriginalTicket(originalticket,comment);
            //===============

            //===============
            return;
            //===============
           }
         //===============
        }
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::GetDealAsTradeFromSelectedHistory(const long ticket,cTradeInfo &trade)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   const int dealstotal=::HistoryDealsTotal();
//===============

//===============  
   for(int i=dealstotal-1;i>=0 && !::IsStopped();i--)
     {
      //===============
      const ulong dealticket = ::HistoryDealGetTicket(i);
      const long  dealorder  = ::HistoryDealGetInteger(dealticket,DEAL_ORDER);
      //===============

      //===============
      if(dealorder!=ticket)continue;
      //===============

      //===============
      const long identifier     =::HistoryDealGetInteger(dealticket,DEAL_POSITION_ID);
      const datetime opentime   = (datetime)::HistoryDealGetInteger(dealticket,DEAL_TIME);
      const long     magic      = ::HistoryDealGetInteger(dealticket,DEAL_MAGIC);
      const string   comment    = ::HistoryDealGetString(dealticket,DEAL_COMMENT);
      const string   symbol     = ::HistoryDealGetString(dealticket,DEAL_SYMBOL);
      const double   lots       = ::HistoryDealGetDouble(dealticket,DEAL_VOLUME);
      const double   openprice  = ::HistoryDealGetDouble(dealticket,DEAL_PRICE);
      const ENUM_DEAL_TYPE type = (ENUM_DEAL_TYPE)::HistoryDealGetInteger(dealticket,DEAL_TYPE);
      //===============

      //===============
      trade.Update(dealorder,identifier,type==DEAL_TYPE_BUY?TRADETYPE_BUY:TRADETYPE_SELL,TRADESTATUS_CURRENT,symbol,
                   magic,comment,lots,openprice,0,0,opentime);
      //===============

      //===============
      return(true);
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(false);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::GetPositionAsDeals(const long ticket,cTradeInfo &trades[],const bool searchoriginalticket)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   cArray::Free(trades);
//===============

//===============
// Hedging Accounts
//===============
   if(!cTrade::IsNettingAccount())
     {
      //===============
      cArray::Resize(trades,1,0);
      //===============

      //===============
      trades[0].Update(ticket,false,false,searchoriginalticket);
      //===============
     }
//===============
// Netting Accounts
//===============     
   else
     {
      //===============
#ifdef __MQL5__
      //===============

      //===============
      const bool select=::PositionSelectByTicket(ticket);
      //===============

      //===============
      if(!select)return;
      //===============

      //===============
      const long identifier   = ::PositionGetInteger(POSITION_IDENTIFIER);
      const double takeprofit = ::PositionGetDouble(POSITION_TP);
      const double stoploss   = ::PositionGetDouble(POSITION_SL);
      const string symbol     = ::PositionGetString(POSITION_SYMBOL);
      //===============

      //===============
      if(::HistorySelectByPosition(identifier))
        {
         //===============
         const int deals=::HistoryDealsTotal();
         //===============

         //===============
         cArray::Resize(trades,deals,0);
         //=============== 

         //===============  
         for(int i=0;i<deals && !::IsStopped();i++)
           {
            //===============
            const ulong dealticket        = ::HistoryDealGetTicket(i);
            const ENUM_DEAL_REASON reason = (ENUM_DEAL_REASON)::HistoryDealGetInteger(dealticket,DEAL_REASON);
            //===============

            //===============
            if(reason==DEAL_REASON_ROLLOVER)continue;
            //===============

            //===============
            const datetime opentime       = (datetime)::HistoryDealGetInteger(dealticket,DEAL_TIME);
            const long     magic          = ::HistoryDealGetInteger(dealticket,DEAL_MAGIC);
            const long     order          = ::HistoryDealGetInteger(dealticket,DEAL_ORDER);
            const string   comment        = ::HistoryDealGetString(dealticket,DEAL_COMMENT);
            const double   lots           = ::HistoryDealGetDouble(dealticket,DEAL_VOLUME);
            const double   openprice      = ::HistoryDealGetDouble(dealticket,DEAL_PRICE);
            const ENUM_DEAL_TYPE type     = (ENUM_DEAL_TYPE)::HistoryDealGetInteger(dealticket,DEAL_TYPE);
            //===============

            //===============
            trades[i].Update(order,identifier,type==DEAL_TYPE_BUY?TRADETYPE_BUY:TRADETYPE_SELL,TRADESTATUS_CURRENT,symbol,
                             magic,comment,lots,openprice,stoploss,takeprofit,opentime);
            //===============
           }
         //===============
        }
      //===============

      //===============
#endif 
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::GetSymbols(const cTradeInfo &trades[],string &symbols[])
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   cArray::Free(symbols);
//===============

//===============
   const int size=cArray::Size(trades);
//===============

//===============
   for(int i=0;i<size;i++)
     {
      //===============
      const string symbol=trades[i].SymbolGet();
      //===============

      //===============
      if(cArray::ValueExist(symbols,symbol))continue;
      //===============

      //===============
      cArray::AddLast(symbols,symbol,size);
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::GetSymbolTrades(const cTradeInfo &trades[],const string symbol,cTradeInfo &symboltrades[])
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   cArray::Free(symboltrades);
//===============

//===============
   const int size=cArray::Size(trades);
//===============

//===============
   for(int i=0;i<size;i++)
     {
      //===============
      if(trades[i].SymbolGet()!=symbol)continue;
      //===============

      //===============
      const int newsize=cArray::Size(symboltrades)+1;
      //===============

      //===============
      cArray::Resize(symboltrades,newsize,size);
      //===============

      //===============
      symboltrades[newsize-1]=trades[i];
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::NettTrades(const cTradeInfo &trades[],cTradeInfo &tradesnetted[])
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   cArray::Free(tradesnetted);
//===============

//===============
   string symbols[];
//===============

//===============
   cTradeInfo symboltrades[];
//===============

//===============
   cTrade::GetSymbols(trades,symbols);
//===============

//===============
   const int size=cArray::Size(symbols);
//===============
   for(int i=0;i<size;i++)
     {
      //===============
      cTrade::GetSymbolTrades(trades,symbols[i],symboltrades);
      //===============

      //===============
      cTrade::NettPosition(symboltrades,tradesnetted);
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::NettPosition(const cTradeInfo &trades[],cTradeInfo &tradesnetted[])
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const int size=cArray::Size(trades);
//===============

//===============
// Id only trades of the same type => No netting required, just copy as is
//===============
   bool neednetting     = false;
   eTradeType prevtype  = WRONG_VALUE;
   string     symbol    = NULL;
//===============
   for(int i=0;i<size;i++)
     {
      //===============
      if(symbol==NULL)symbol=trades[i].SymbolGet();
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT({},symbol==trades[i].SymbolGet(),false,{})
      //===============

      //===============
      if(prevtype!=WRONG_VALUE && prevtype!=trades[i].TypeGet()){neednetting=true;break;}
      //===============

      //===============
      prevtype=trades[i].TypeGet();
      //===============
     }
//===============
   if(!neednetting)
     {
      //===============
      for(int i=0;i<size;i++)
        {
         //===============
         const int newsize=cArray::Size(tradesnetted)+1;
         //===============

         //===============
         cArray::Resize(tradesnetted,newsize,size);
         //===============

         //===============
         tradesnetted[newsize-1]=trades[i];
         //===============
        }
      //===============

      //===============
      return;
      //===============
     }
//===============

//===============
   bool closed[];
//===============
   cArray::Resize(closed,size,0);
//===============
   for(int i=0;i<size;i++)closed[i]=false;
//===============

//===============
   cTradeInfo temptrades[];
//===============
   cArray::Resize(temptrades,size,0);
//===============
   for(int i=0;i<size;i++)temptrades[i]=trades[i];
//===============

//===============
   double netlots=0;
//===============

//===============
// Netting trades using FIFO approach
//===============
   for(int i=0;i<size;i++)
     {
      //===============
      const double lot      = temptrades[i].LotsGet();
      const eTradeType type = temptrades[i].TypeGet();
      //===============

      //===============
      if((netlots>0 && type==TRADETYPE_SELL) || (netlots<0 && type==TRADETYPE_BUY))
        {
         //===============
         // OUT SCENARIO
         //===============
         if(lot<::MathAbs(netlots))
           {
            //===============
            double closedlots=0;
            //===============

            //===============
            // Check what should be closed before
            //===============
            for(int j=0;j<i;j++)
              {
               //===============
               if(closed[j])continue;
               //===============

               //===============
               if(type==temptrades[j].TypeGet())continue;
               //===============

               //===============
               const double contrlot=temptrades[j].LotsGet();
               //===============

               //===============
               // Full Closure
               //===============
               if(contrlot<=lot-closedlots)
                 {
                  //===============
                  closed[j]=true;
                  //===============
                 }
               //===============
               // Partial Closure
               //===============  
               else
                 {
                  //===============
                  // Update remaining trade volume and REASSIGNING TICKET to the closed one          
                  //===============
                  temptrades[j].Update(temptrades[i].TicketGet(),temptrades[j].IdentifierGet(),temptrades[j].TypeGet(),temptrades[j].StatusGet(),
                                       temptrades[j].SymbolGet(),temptrades[j].MagicGet(),temptrades[j].CommentGet(),(contrlot-(lot-closedlots)),
                                       temptrades[j].OpenPriceGet(),temptrades[j].StopLossGet(),temptrades[j].TakeProfitGet(),
                                       temptrades[j].OpenTimeGet());
                  //===============
                 }
               //===============

               //===============
               closedlots+=contrlot;
               //===============

               //===============
               if(closedlots>=lot)break;
               //===============
              }
            //===============

            //===============
            // Closing a trade
            //===============
            closed[i]=true;
            //===============
           }
         //===============
         // INOUT SCENARIO
         //===============
         else
           {
            //===============
            // Close everything before
            //===============
            for(int j=0;j<i;j++)closed[j]=true;
            //===============
            // Update resulting trade volume          
            //===============
            temptrades[i].Update(temptrades[i].TicketGet(),temptrades[i].IdentifierGet(),temptrades[i].TypeGet(),temptrades[i].StatusGet(),
                                 temptrades[i].SymbolGet(),temptrades[i].MagicGet(),temptrades[i].CommentGet(),(lot-::MathAbs(netlots)),
                                 temptrades[i].OpenPriceGet(),temptrades[i].StopLossGet(),temptrades[i].TakeProfitGet(),
                                 temptrades[i].OpenTimeGet());
            //===============
           }
        }
      //===============

      //===============
      netlots+=(type==TRADETYPE_BUY?(1):(-1))*lot;
      //===============
     }
//===============

//===============
// Copy results into resulting array
//===============
   for(int i=0;i<size;i++)
     {
      //===============
      if(closed[i])continue;
      //===============

      //===============
      const int newsize=cArray::Size(tradesnetted)+1;
      //===============

      //===============
      cArray::Resize(tradesnetted,newsize,size);
      //===============

      //===============
      tradesnetted[newsize-1]=temptrades[i];
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static double cTrade::PointPrice(const string symbol)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const double point     = ::SymbolInfoDouble(symbol,SYMBOL_POINT);
   const double ticksize  = ::SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   const double tickvalue = ::SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
//===============

//===============
   if(ticksize<=0 || point<=0)return(0);
//===============

//===============
   const double pointprice=(tickvalue/(ticksize/point));
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(pointprice);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static double cTrade::GetLot(const string symbol,const long slpoints,const double moneyrisk)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   if(slpoints<=0 || moneyrisk<=0)return(0.0);
//===============

//===============
   const double pointprice=cTrade::PointPrice(symbol);
//===============

//===============
   if(pointprice==0)return(0);
//===============

//===============
   const double result=(moneyrisk/slpoints)/pointprice;
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::CalculateSLandTP(const string symbol,const eTradeType type,const double entrylevel,const double lots,
                                     const bool slpointsenabled,const long slpoints,const bool tppointsenabled,const long tppoints,
                                     const bool slmoneyenabled,const double slmoney,const bool tpmoneyenabled,const double tpmoney,
                                     const bool slpriceenabled,const double slprice,const bool tppriceenabled,const double tpprice,
                                     double &sllevel,double &tplevel)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   sllevel = 0;
   tplevel = 0;
//===============

//===============
   const bool changesl=((slpointsenabled && slpoints>0) || (slpriceenabled && slprice>0) || (slmoneyenabled && slmoney>0));
   const bool changetp=((tppointsenabled && tppoints>0) || (tppriceenabled && tpprice>0) || (tpmoneyenabled && tpmoney>0));
//===============

//===============
   if(!changesl && !changetp)return;
//===============

//===============
   const double point    = ::SymbolInfoDouble(symbol,SYMBOL_POINT);
   const int    digits   = (int)::SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   const double ticksize = ::SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
//===============

//===============
   const double pointprice=lots*cTrade::PointPrice(symbol);
//===============

//===============
   if(slpointsenabled && slpoints>0)sllevel=(type==TRADETYPE_BUY?(entrylevel-slpoints*point):(entrylevel+slpoints*point));
   if(tppointsenabled && tppoints>0)tplevel=(type==TRADETYPE_BUY?(entrylevel+tppoints*point):(entrylevel-tppoints*point));
//===============

//===============
   if(slpriceenabled && slprice>0)sllevel=(type==TRADETYPE_BUY?(::MathMax(sllevel,slprice)):(sllevel>0?(::MathMin(sllevel,slprice)):slprice));
   if(tppriceenabled && tpprice>0)tplevel=(type==TRADETYPE_BUY?(tplevel>0?(::MathMin(tplevel,tpprice)):tpprice):(::MathMax(tplevel,tpprice)));
//===============

//===============
   if(pointprice!=0)
     {
      //===============
      const double slmoneyprice = point*slmoney/pointprice;
      const double tpmoneyprice = point*tpmoney/pointprice;
      //===============

      //===============
      if(slmoneyenabled && slmoney>0)sllevel=(type==TRADETYPE_BUY?(::MathMax(sllevel,entrylevel-slmoneyprice)):
         (sllevel>0?(::MathMin(sllevel,entrylevel+slmoneyprice)):entrylevel+slmoneyprice));
      if(tpmoneyenabled && tpmoney>0)tplevel=(type==TRADETYPE_BUY?(tplevel>0?(::MathMin(tplevel,entrylevel+tpmoneyprice)):entrylevel+tpmoneyprice):
         (::MathMax(tplevel,entrylevel-tpmoneyprice)));
      //===============
     }
//===============

//===============
   sllevel = ::NormalizeDouble(sllevel,digits);
   tplevel = ::NormalizeDouble(tplevel,digits);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::TrailingStop(const long ticket,const long tslstart,const long tsldistance,
                                 const bool tsllevelenabled,const double tsllevel,uint &retcode,eError &myretcode)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const bool cantrade=cTrade::CanTrade();
//===============
/* DEBUG ASSERTION */ASSERT({},cantrade,true,{})
//===============
   if(!cantrade)return(false);
//===============

//===============
   cTradeInfo trade;
//===============
   trade.Update(ticket,false,false,false);
//===============

//===============
   if(trade.TicketGet()<=0 || trade.StatusGet()!=TRADESTATUS_CURRENT)return(false);
//===============

//===============
   if(trade.ProfitPointsGet()<tslstart)return(false);
//===============

//===============
   double reference=0;
//===============

//===============
   const double point  = ::SymbolInfoDouble(trade.SymbolGet(),SYMBOL_POINT);
   const int    digits = (int)::SymbolInfoInteger(trade.SymbolGet(),SYMBOL_DIGITS);
//===============

//===============
   MqlTick lasttick;
//===============
   const bool gettick=::SymbolInfoTick(trade.SymbolGet(),lasttick);
//===============
/* DEBUG ASSERTION */ASSERT({},gettick,true,{})
//===============
   if(!gettick)return(false);
//===============

//===============
   double sllevel=0;
//===============

//===============
   bool result=false;
//===============

//===============
   if(trade.TypeGet()==TRADETYPE_BUY)
     {
      //===============
      reference=tsllevelenabled?tsllevel:lasttick.bid;
      //===============

      //===============
      sllevel=reference-tsldistance*point;
      //===============
      sllevel=::NormalizeDouble(sllevel,digits);
      //===============

      //===============
      if(sllevel>trade.StopLossGet()+TSLSTEPPOINTS*point)
        {
         //===============
         result=cTrade::ModifyTrade(ticket,sllevel,trade.TakeProfitGet(),retcode,myretcode);
         //===============
        }
      //===============
     }
//===============

//===============
   if(trade.TypeGet()==TRADETYPE_SELL)
     {
      //===============
      reference=tsllevelenabled?tsllevel:lasttick.ask;
      //===============

      //===============
      sllevel=reference+tsldistance*point;
      //===============
      sllevel=::NormalizeDouble(sllevel,digits);
      //===============

      //===============
      if(sllevel<trade.StopLossGet()-TSLSTEPPOINTS*point || trade.StopLossGet()==0)
        {
         //===============
         result=cTrade::ModifyTrade(ticket,sllevel,trade.TakeProfitGet(),retcode,myretcode);
         //===============
        }
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::BreakEven(const long ticket,const long belevel,const long beprofit,uint &retcode,eError &myretcode)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const bool cantrade=cTrade::CanTrade();
//===============
/* DEBUG ASSERTION */ASSERT({},cantrade,true,{})
//===============
   if(!cantrade)return(false);
//===============

//===============
   cTradeInfo trade;
//===============
   trade.Update(ticket,false,false,false);
//===============

//===============
   if(trade.TicketGet()<=0 || trade.StatusGet()!=TRADESTATUS_CURRENT)return(false);
//===============

//===============
   if(trade.ProfitPointsGet()<belevel)return(false);
//===============

//===============
   const double point  = ::SymbolInfoDouble(trade.SymbolGet(),SYMBOL_POINT);
   const int    digits = (int)::SymbolInfoInteger(trade.SymbolGet(),SYMBOL_DIGITS);
//===============

//===============
   double sllevel=0;
//===============

//===============
   bool result=false;
//===============

//===============
   if(trade.TypeGet()==TRADETYPE_BUY)
     {
      //===============
      sllevel=trade.OpenPriceGet()+beprofit*point;
      //===============
      sllevel=::NormalizeDouble(sllevel,digits);
      //===============

      //===============
      if(sllevel>trade.StopLossGet())
        {
         //===============
         result=cTrade::ModifyTrade(ticket,sllevel,trade.TakeProfitGet(),retcode,myretcode);
         //===============
        }
      //===============
     }
//===============

//===============
   if(trade.TypeGet()==TRADETYPE_SELL)
     {
      //===============
      sllevel=trade.OpenPriceGet()-beprofit*point;
      //===============
      sllevel=::NormalizeDouble(sllevel,digits);
      //===============

      //===============
      if(sllevel<trade.StopLossGet() || trade.StopLossGet()==0)
        {
         //===============
         result=cTrade::ModifyTrade(ticket,sllevel,trade.TakeProfitGet(),retcode,myretcode);
         //===============
        }
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#ifdef __MQL5__
//
static ENUM_ORDER_TYPE_FILLING cTrade::GetFilling(const string symbol)// Big thanks to fxsaber!!!
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   static ENUM_ORDER_TYPE_FILLING result=ORDER_FILLING_FOK;
//===============

//===============
   static string lastsymbol=NULL;
//===============

//===============
   const bool differentsymbol=(lastsymbol!=symbol);
//===============

//===============
   const uint defaultfilling=ORDER_FILLING_FOK;
//===============

//===============
   if(differentsymbol)
     {
      //===============
      lastsymbol=symbol;
      //===============

      //===============
      const ENUM_SYMBOL_TRADE_EXECUTION executionmode=(ENUM_SYMBOL_TRADE_EXECUTION)::SymbolInfoInteger(symbol,SYMBOL_TRADE_EXEMODE);
      const int fillingmode=(int)::SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
      //===============

      //===============
      result=(!fillingmode || (defaultfilling>=ORDER_FILLING_RETURN) || ((fillingmode &(defaultfilling+1))!=defaultfilling+1)) ?
             (((executionmode==SYMBOL_TRADE_EXECUTION_EXCHANGE) || (executionmode==SYMBOL_TRADE_EXECUTION_INSTANT)) ?
             ORDER_FILLING_RETURN :((fillingmode==SYMBOL_FILLING_IOC) ? ORDER_FILLING_IOC : ORDER_FILLING_FOK)) :
             (ENUM_ORDER_TYPE_FILLING)defaultfilling;
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static ENUM_ORDER_TYPE_TIME cTrade::GetExpirationType(const string symbol)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   static ENUM_ORDER_TYPE_TIME result=ORDER_TIME_GTC;
//===============

//===============
   static string lastsymbol=NULL;
//===============

//===============
   const bool differentsymbol=(lastsymbol!=symbol);
//===============

//===============
   const uint defaulttype=ORDER_TIME_GTC;
//===============

//===============
   if(differentsymbol)
     {
      //===============
      lastsymbol=symbol;
      //===============

      //===============
      const int expirationmode=(int)::SymbolInfoInteger(symbol,SYMBOL_EXPIRATION_MODE);
      //===============

      //===============
      uint expiration=defaulttype;
      //===============

      //===============
      if((expiration>ORDER_TIME_SPECIFIED_DAY) || (!((expirationmode>>expiration) &1)))
        {
         //===============
         if((expiration<ORDER_TIME_SPECIFIED) || (expirationmode<SYMBOL_EXPIRATION_SPECIFIED))
            expiration=ORDER_TIME_GTC;
         else if(expiration>ORDER_TIME_DAY)
            expiration=ORDER_TIME_SPECIFIED;
         //===============

         //===============
         uint i=1<<expiration;
         //===============

         //===============
         while((expiration<=ORDER_TIME_SPECIFIED_DAY) && ((expirationmode  &i)!=i))
           {
            //===============
            i<<=1;
            expiration++;
            //===============
           }
         //===============
        }
      //===============

      //===============
      result=(ENUM_ORDER_TYPE_TIME)expiration;
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//
#endif
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::CanTrade(void)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   static const bool istesting=(bool)::MQLInfoInteger(MQL_TESTER);
//===============

//===============
   if(istesting)return(true);
//===============

//===============
   const bool result=(::TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && 
                      ::MQLInfoInteger(MQL_TRADE_ALLOWED) &&
                      ::AccountInfoInteger(ACCOUNT_TRADE_EXPERT) &&
                      ::AccountInfoInteger(ACCOUNT_TRADE_ALLOWED) &&
                      ::TerminalInfoInteger(TERMINAL_CONNECTED));
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::ClosingAllowed(const string symbol)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   const ENUM_SYMBOL_TRADE_MODE trademode=(ENUM_SYMBOL_TRADE_MODE)::SymbolInfoInteger(symbol,SYMBOL_TRADE_MODE);
//===============

//===============
   if(trademode==SYMBOL_TRADE_MODE_DISABLED)return(false);
//===============

//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::OpeningAllowed(const string symbol,const eTradeType type)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   const ENUM_SYMBOL_TRADE_MODE trademode=(ENUM_SYMBOL_TRADE_MODE)::SymbolInfoInteger(symbol,SYMBOL_TRADE_MODE);
//===============

//===============
   switch(trademode)
     {
      case SYMBOL_TRADE_MODE_DISABLED       :                                 return(false);
      case SYMBOL_TRADE_MODE_LONGONLY       :                                 return(type==TRADETYPE_BUY);
      case SYMBOL_TRADE_MODE_SHORTONLY      :                                 return(type==TRADETYPE_SELL);
      case SYMBOL_TRADE_MODE_CLOSEONLY      :                                 return(false);
      case SYMBOL_TRADE_MODE_FULL           :                                 return(true);
      //===============
      default                 :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //=============== 
     }
//===============

//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::TradeTypeAllowed(const eAllowedTrades allowed,const eTradeType type)
  {
//===============
   switch(allowed)
     {
      case ALLOWEDTRADES_ALL       :                                 return(true);
      case ALLOWEDTRADES_NONE      :                                 return(false);
      case ALLOWEDTRADES_BUYONLY   :                                 return(type==TRADETYPE_BUY);
      case ALLOWEDTRADES_SELLONLY  :                                 return(type==TRADETYPE_SELL);
      //===============
      default                 :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //=============== 
     }
//===============

//===============
   return(false);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static double cTrade::CalculateLot(const string symbol,const eTradeType type,const double requiredbelevel,const double dealprice,
                                   const double lotsnow,const double belevelnow)
  {
//===============
   const double difference=::MathAbs(dealprice-requiredbelevel);
//===============

//===============
   double requiredlot=(difference!=0?(lotsnow*::MathAbs(requiredbelevel-belevelnow)/difference):0);
//===============

//===============
   if(type==TRADETYPE_BUY && requiredbelevel>belevelnow)requiredlot=0;
//===============

//===============
   if(type==TRADETYPE_SELL && requiredbelevel<belevelnow)requiredlot=0;
//===============

//===============
   return(cTrade::CheckLot(symbol,requiredlot));
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static double cTrade::CheckLot(const string symbol,const double lots)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   double result=lots;
//===============

//===============
   const double min    = ::SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   const double max    = ::SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   const double step   = ::SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
//===============

//===============
   if(step!=0)result=::MathRound(result/step)*step;
//===============

//===============
   if(result<min)result=min;
//===============
   if(result>max)result=max;
//===============

//===============
   result=::NormalizeDouble(result,2);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(min==0?::MathMax(result,0.01):result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static long cTrade::OpenTrade(const string symbol,const eTradeType type,const double lots,const long magic,const string comment,
                              const long slippage,const bool checkplaced,uint &retcode,eError &myretcode)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const long ticket=cTrade::OpenTrade(symbol,type,lots,magic,comment,
                                       false,0,false,0,false,0,false,0,false,0,false,0,
                                       (slippage>0),slippage,checkplaced,retcode,myretcode);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(ticket);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static long cTrade::OpenTrade(const string symbol,const eTradeType type,const double lots,const long magic,const string comment,
                              const bool slpointsenabled,const long slpoints,const bool tppointsenabled,const long tppoints,
                              const bool slmoneyenabled,const double slmoney,const bool tpmoneyenabled,const double tpmoney,
                              const bool slpriceenabled,const double slprice,const bool tppriceenabled,const double tpprice,
                              const bool slippageenabled,const long slippage,const bool checkplaced,uint &retcode,eError &myretcode)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const bool cantrade=cTrade::CanTrade();
//===============
/* DEBUG ASSERTION */ASSERT({},cantrade,true,{})
//===============
   if(!cantrade){myretcode=ERROR_AUTOTRADINGNOTALLOWED;return(-1);}
//===============

//===============
   const bool openingallowed=cTrade::OpeningAllowed(symbol,type);
//===============
/* DEBUG ASSERTION */ASSERT({},openingallowed,true,{})
//===============
   if(!openingallowed){myretcode=RETCODE_OPENINGNOTALLOWED;return(-1);}
//===============

//===============
   if(checkplaced)
     {
      //===============
      const bool noplaced=cTrade::CheckPlaced(symbol,type,magic);
      //===============
/* DEBUG ASSERTION */ASSERT({},noplaced,true,{})
      //===============
      if(!noplaced){myretcode=RETCODE_ALREADYPLACED;return(-1);}
      //===============
     }
//===============

//===============
   const bool maxorders=cTrade::CheckMaxOrders();
//===============
/* DEBUG ASSERTION */ASSERT({},maxorders,true,{})
//===============
   if(!maxorders){myretcode=RETCODE_MAXORDERS;return(-1);}
//===============

//===============
   const double volume=cTrade::CheckLot(symbol,lots);
//===============
   const bool volumeok=(volume>0);
//===============
/* DEBUG ASSERTION */ASSERT({},volumeok,true,{})
//===============
   if(!volumeok){myretcode=RETCODE_WRONGVOLUME;return(-1);}
//===============

//===============
   const bool maxvolume=cTrade::CheckMaxVolume(symbol,type,volume);
//===============
/* DEBUG ASSERTION */ASSERT({},maxvolume,true,{})
//===============
   if(!maxvolume){myretcode=RETCODE_MAXVOLUME;return(-1);}
//===============

//===============
   MqlTick lasttick;
//===============
   const bool gettick=::SymbolInfoTick(symbol,lasttick);
//===============
/* DEBUG ASSERTION */ASSERT({},gettick,true,{})
//===============
   if(!gettick){myretcode=RETCODE_NOTICKDATA;return(-1);}
//===============

//===============
   double sllevel=0;
//===============
   double tplevel=0;
//===============

//===============
   const double price=(type==TRADETYPE_BUY?lasttick.ask:lasttick.bid);
//===============

//===============
   cTrade::CalculateSLandTP(symbol,type,price,volume,
                            slpointsenabled,slpoints,tppointsenabled,tppoints,
                            slmoneyenabled,slmoney,tpmoneyenabled,tpmoney,
                            slpriceenabled,slprice,tppriceenabled,tpprice,sllevel,tplevel);
//===============

//===============
   const bool stopsok=cTrade::CheckStops(symbol,type,true,price,sllevel,tplevel);
//===============
/* DEBUG ASSERTION */ASSERT({},stopsok,true,{})
//===============
   if(!stopsok){myretcode=RETCODE_WRONGSTOPS;return(-1);}
//===============

//===============
   long ticket=-1;
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   const int ordermode=(int)::SymbolInfoInteger(symbol,SYMBOL_ORDER_MODE);
//===============
   const bool orderallowed=((SYMBOL_ORDER_MARKET&ordermode)==SYMBOL_ORDER_MARKET);
//===============
/* DEBUG ASSERTION */ASSERT({},orderallowed,true,{})
//===============
   if(!orderallowed){myretcode=RETCODE_TRADETYPENOTALLOWED;return(-1);}
//===============

//===============
   MqlTradeRequest      openrequest;
   MqlTradeCheckResult  opencheckresult;
   MqlTradeResult       openresult;
//===============
   ::ZeroMemory(openrequest);
   ::ZeroMemory(opencheckresult);
   ::ZeroMemory(openresult);
//===============

//===============
   const ENUM_ORDER_TYPE_FILLING filling=cTrade::GetFilling(symbol);
//===============

//===============
   openrequest.action       = TRADE_ACTION_DEAL;
   openrequest.magic        = magic;
   openrequest.symbol       = symbol;
   openrequest.volume       = volume;
   openrequest.type         = (type==TRADETYPE_BUY?ORDER_TYPE_BUY:ORDER_TYPE_SELL);
   openrequest.deviation    = (slippageenabled?(int)slippage:0);
   openrequest.comment      = comment;
   openrequest.type_filling = filling;
   openrequest.price        = ::NormalizeDouble(price,(int)::SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   openrequest.sl           = sllevel;
   openrequest.tp           = tplevel;
//===============

//===============
   const bool marginok=cTrade::CheckMargin(symbol,volume,type,openrequest.price);
//===============
/* DEBUG ASSERTION */ASSERT({},marginok,true,{})
//===============
   if(!marginok){myretcode=RETCODE_NOFREEMARGIN;return(-1);}
//===============

//===============
   const bool check=::OrderCheck(openrequest,opencheckresult);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},check && opencheckresult.retcode==0,false,::Print(TOSTRING(opencheckresult.retcode));)
//===============

//===============
   retcode=opencheckresult.retcode;
//===============

//===============
   if(check && opencheckresult.retcode==0)
     {
      //===============
      const bool send=::OrderSend(openrequest,openresult);
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT({},send && (openresult.deal>0 || openresult.order>0),false,::Print(TOSTRING(openresult.retcode));)
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT({},openresult.deal<=0 || openresult.order>0,false,::Print(TOSTRING(openresult.deal),VERTICALBAR,TOSTRING(openresult.order));)
      //===============

      //===============
      ticket=(long)openresult.order;
      //===============

      //===============
      retcode=openresult.retcode;
      //===============
     }
   else
     {
      //===============
      retcode=RETCODE_ORDERCHECKFAILED;
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============

//===============
   const bool marginok=cTrade::CheckMargin(symbol,volume,type,price);
//===============
/* DEBUG ASSERTION */ASSERT({},marginok,true,{})
//===============
   if(!marginok){myretcode=RETCODE_NOFREEMARGIN;return(-1);}
//===============

//===============
   const int    cmd=(type==TRADETYPE_BUY?OP_BUY:OP_SELL);
//===============

//===============
   ::ResetLastError();
//===============

//===============
   const int send=::OrderSend(symbol,cmd,volume,::NormalizeDouble(price,(int)::SymbolInfoInteger(symbol,SYMBOL_DIGITS)),
                              (slippageenabled?(int)slippage:0),sllevel,tplevel,comment,(int)magic,0,clrNONE);
//===============

//===============
   retcode=::GetLastError();
//===============

//===============
   ticket=send;
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},send>0,false,::Print(TOSTRING(retcode));)
//===============

//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(ticket);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static long cTrade::PlacePendingOrder(const string symbol,const double price,const ePendingOrderType type,const double lots,
                                      const long magic,const string comment,const datetime expiration,uint &retcode,eError &myretcode)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const long ticket=cTrade::PlacePendingOrder(symbol,price,type,lots,magic,comment,
                                               false,0,false,0,
                                               false,0,false,0,
                                               false,0,false,0,
                                               (expiration>0),expiration,retcode,myretcode);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(ticket);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static long cTrade::PlacePendingOrder(const string symbol,const double price,const ePendingOrderType type,const double lots,
                                      const long magic,const string comment,
                                      const bool slpointsenabled,const long slpoints,const bool tppointsenabled,const long tppoints,
                                      const bool slmoneyenabled,const double slmoney,const bool tpmoneyenabled,const double tpmoney,
                                      const bool slpriceenabled,const double slprice,const bool tppriceenabled,const double tpprice,
                                      const bool expirationenabled,const datetime expiration,uint &retcode,eError &myretcode)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const bool cantrade=cTrade::CanTrade();
//===============
/* DEBUG ASSERTION */ASSERT({},cantrade,true,{})
//===============
   if(!cantrade){myretcode=ERROR_AUTOTRADINGNOTALLOWED;return(-1);}
//===============

//===============
   const eTradeType side=(type==PENDINGORDERTYPE_BUYLIMIT || type==PENDINGORDERTYPE_BUYSTOP)?TRADETYPE_BUY:TRADETYPE_SELL;
//===============

//===============
   const bool openingallowed=cTrade::OpeningAllowed(symbol,side);
//===============
/* DEBUG ASSERTION */ASSERT({},openingallowed,true,{})
//===============
   if(!openingallowed){myretcode=RETCODE_OPENINGNOTALLOWED;return(-1);}
//===============

//===============
   const bool maxorders=cTrade::CheckMaxOrders();
//===============
/* DEBUG ASSERTION */ASSERT({},maxorders,true,{})
//===============
   if(!maxorders){myretcode=RETCODE_MAXORDERS;return(-1);}
//===============

//===============
   const double volume=cTrade::CheckLot(symbol,lots);
//===============
   const bool volumeok=(volume>0);
//===============
/* DEBUG ASSERTION */ASSERT({},volumeok,true,{})
//===============
   if(!volumeok){myretcode=RETCODE_WRONGVOLUME;return(-1);}
//===============

//===============
   const bool maxvolume=cTrade::CheckMaxVolume(symbol,side,volume);
//===============
/* DEBUG ASSERTION */ASSERT({},maxvolume,true,{})
//===============
   if(!maxvolume){myretcode=RETCODE_MAXVOLUME;return(-1);}
//===============

//===============
   double sllevel=0;
//===============
   double tplevel=0;
//===============

//===============
   cTrade::CalculateSLandTP(symbol,side,price,volume,
                            slpointsenabled,slpoints,tppointsenabled,tppoints,
                            slmoneyenabled,slmoney,tpmoneyenabled,tpmoney,
                            slpriceenabled,slprice,tppriceenabled,tpprice,sllevel,tplevel);
//===============

//===============
   const bool stopsok=cTrade::CheckStops(symbol,side,false,price,sllevel,tplevel);
//===============
/* DEBUG ASSERTION */ASSERT({},stopsok,true,{})
//===============
   if(!stopsok){myretcode=RETCODE_WRONGSTOPS;return(-1);}
//===============

//===============
   const bool orderpriceok=cTrade::CheckOrderPrice(symbol,type,price);
//===============
/* DEBUG ASSERTION */ASSERT({},orderpriceok,true,{})
//===============
   if(!orderpriceok){myretcode=RETCODE_WRONGORDERPRICE;return(-1);}
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   const int ordermode=(int)::SymbolInfoInteger(symbol,SYMBOL_ORDER_MODE);
//===============
   bool orderallowed=((SYMBOL_ORDER_LIMIT&ordermode)==SYMBOL_ORDER_LIMIT);
//===============
/* DEBUG ASSERTION */ASSERT({},orderallowed,true,{})
//===============
   if(!orderallowed){myretcode=RETCODE_TRADETYPENOTALLOWED;return(-1);}
//===============
   orderallowed=((SYMBOL_ORDER_STOP&ordermode)==SYMBOL_ORDER_STOP);
//===============
/* DEBUG ASSERTION */ASSERT({},orderallowed,true,{})
//===============
   if(!orderallowed){myretcode=RETCODE_TRADETYPENOTALLOWED;return(-1);}
//===============

//===============
   MqlTradeRequest      openrequest;
   MqlTradeCheckResult  opencheckresult;
   MqlTradeResult       openresult;
//===============
   ::ZeroMemory(openrequest);
   ::ZeroMemory(opencheckresult);
   ::ZeroMemory(openresult);
//===============

//===============
   const ENUM_ORDER_TYPE_FILLING filling=cTrade::GetFilling(symbol);
//===============

//===============
   openrequest.action       = TRADE_ACTION_PENDING;
   openrequest.magic        = magic;
   openrequest.symbol       = symbol;
   openrequest.volume       = volume;
   openrequest.comment      = comment;
   openrequest.type_filling = filling;
   openrequest.price        = ::NormalizeDouble(price,(int)::SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   openrequest.sl           = sllevel;
   openrequest.tp           = tplevel;
   openrequest.type_time    = cTrade::GetExpirationType(symbol);
//===============

//===============
   if((openrequest.type_time==ORDER_TIME_SPECIFIED || openrequest.type_time==ORDER_TIME_SPECIFIED_DAY) && expirationenabled)openrequest.expiration=expiration;
//===============

//===============
// Fix for MOEX etc
//===============
   if(::SymbolInfoInteger(symbol,SYMBOL_EXPIRATION_MODE)==10)
     {
      //===============
      openrequest.type_filling  = ORDER_FILLING_RETURN;
      openrequest.type_time     = ORDER_TIME_SPECIFIED_DAY;
      openrequest.expiration    =  expiration;
      //===============
     }
//===============

//===============
   switch(type)
     {
      //===============
      case  PENDINGORDERTYPE_BUYLIMIT          :   openrequest.type=ORDER_TYPE_BUY_LIMIT;                                 break;
      case  PENDINGORDERTYPE_BUYSTOP           :   openrequest.type=ORDER_TYPE_BUY_STOP;                                  break;
      case  PENDINGORDERTYPE_SELLLIMIT         :   openrequest.type=ORDER_TYPE_SELL_LIMIT;                                break;
      case  PENDINGORDERTYPE_SELLSTOP          :   openrequest.type=ORDER_TYPE_SELL_STOP;                                 break;
      //===============
      default                   :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //===============
     }
//===============

//===============
   const bool marginok=cTrade::CheckMargin(symbol,volume,side,openrequest.price);
//===============
/* DEBUG ASSERTION */ASSERT({},marginok,true,{})
//===============
   if(!marginok){myretcode=RETCODE_NOFREEMARGIN;return(-1);}
//===============

//===============
   const bool check=::OrderCheck(openrequest,opencheckresult);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},check && opencheckresult.retcode==0,false,::Print(TOSTRING(opencheckresult.retcode));)
//===============

//===============
   retcode=opencheckresult.retcode;
//===============

//===============
   if(check && opencheckresult.retcode==0)
     {
      //===============
      const bool send=::OrderSend(openrequest,openresult);
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT({},send && openresult.order>0,false,::Print(TOSTRING(openresult.retcode));)
      //===============

      //===============
      retcode=openresult.retcode;
      //===============

      //===============
      return((long)openresult.order);
      //===============
     }
   else
     {
      //===============
      myretcode=RETCODE_ORDERCHECKFAILED;
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============

//===============
   const bool marginok=cTrade::CheckMargin(symbol,volume,side,price);
//===============
/* DEBUG ASSERTION */ASSERT({},marginok,true,{})
//===============
   if(!marginok){myretcode=RETCODE_NOFREEMARGIN;return(-1);}
//===============

//===============
   int    cmd=-1;
//===============

//===============
   switch(type)
     {
      //===============
      case  PENDINGORDERTYPE_BUYLIMIT          :   cmd=OP_BUYLIMIT;                                 break;
      case  PENDINGORDERTYPE_BUYSTOP           :   cmd=OP_BUYSTOP;                                  break;
      case  PENDINGORDERTYPE_SELLLIMIT         :   cmd=OP_SELLLIMIT;                                break;
      case  PENDINGORDERTYPE_SELLSTOP          :   cmd=OP_SELLSTOP;                                 break;
      //===============
      default                   :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //===============
     }
//===============

//===============
   ::ResetLastError();
//===============

//===============
   const int send=::OrderSend(symbol,cmd,volume,::NormalizeDouble(price,(int)::SymbolInfoInteger(symbol,SYMBOL_DIGITS)),0,
                              sllevel,tplevel,comment,(int)magic,(expirationenabled?expiration:0),clrNONE);
//===============

//===============
   retcode=::GetLastError();;
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},send>0,false,::Print(TOSTRING(retcode));)
//===============

//===============
   return(send);
//===============

//===============
#endif 
//===============

//===============
   return(-1);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::ModifyTrade(const long ticket,const double newsl,const double newtp,uint &retcode,eError &myretcode)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const bool cantrade=cTrade::CanTrade();
//===============
/* DEBUG ASSERTION */ASSERT({},cantrade,true,{})
//===============
   if(!cantrade){myretcode=ERROR_AUTOTRADINGNOTALLOWED;return(false);}
//===============

//===============
   cTradeInfo trade;
//===============
   trade.Update(ticket,false,false,false);
//===============

//===============
   const string symbol = trade.SymbolGet();
   const int    digits = (int)::SymbolInfoInteger(symbol,SYMBOL_DIGITS);
//===============
   const double SL=::NormalizeDouble(newsl,digits);
   const double TP=::NormalizeDouble(newtp,digits);
//===============

//===============
   const bool sameSL = (SL==trade.StopLossGet());
   const bool sameTP = (TP==trade.TakeProfitGet());
//===============

//===============
   if(sameSL && sameTP)return(false);
//===============

//===============
   const bool stopsok=cTrade::CheckStops(symbol,trade.TypeGet(),true,trade.OpenPriceGet(),sameSL?0:SL,sameTP?0:TP);
//===============
/* DEBUG ASSERTION */ASSERT({},stopsok,true,{})
//===============
   if(!stopsok){myretcode=RETCODE_WRONGSTOPS;return(false);}
//===============

//===============
   const bool isfreezed=cTrade::CheckFreezed(trade.SymbolGet(),trade.TypeGet(),trade.StopLossGet(),trade.TakeProfitGet());
//===============
   if(isfreezed)return(false);
//===============

//===============
   bool result=false;
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   if(!::PositionSelectByTicket(ticket))
     {
      //===============
      ::ResetLastError();
      //===============

      //===============
      myretcode=RETCODE_TRADENOTFOUND;
      //===============

      //===============
      return(false);
      //===============
     }
//===============

//===============
   const int ordermode=(int)::SymbolInfoInteger(symbol,SYMBOL_ORDER_MODE);
//===============
   bool orderallowed=((SYMBOL_ORDER_SL&ordermode)==SYMBOL_ORDER_SL);
//===============
/* DEBUG ASSERTION */ASSERT({},orderallowed,true,{})
//===============
   if(!orderallowed){myretcode=RETCODE_TRADETYPENOTALLOWED;return(false);}
//===============
   orderallowed=((SYMBOL_ORDER_TP&ordermode)==SYMBOL_ORDER_TP);
//===============
/* DEBUG ASSERTION */ASSERT({},orderallowed,true,{})
//===============
   if(!orderallowed){myretcode=RETCODE_TRADETYPENOTALLOWED;return(false);}
//===============

//===============
   MqlTradeRequest     modifyrequest;
   MqlTradeResult      modifyresult;
   MqlTradeCheckResult modifycheckresult;
//===============
   ::ZeroMemory(modifyrequest);
   ::ZeroMemory(modifyresult);
   ::ZeroMemory(modifycheckresult);
//===============

//===============
   modifyrequest.action       = TRADE_ACTION_SLTP;
   modifyrequest.position     = ticket;
   modifyrequest.symbol       = symbol;
   modifyrequest.sl           = SL;
   modifyrequest.tp           = TP;
//===============

//===============
   const bool check=::OrderCheck(modifyrequest,modifycheckresult);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},check && modifycheckresult.retcode==0,false,::Print(TOSTRING(modifycheckresult.retcode));)
//===============

//===============
   retcode=modifycheckresult.retcode;
//===============

//===============
   if(check && modifycheckresult.retcode==0)
     {
      //===============
      const bool send=::OrderSend(modifyrequest,modifyresult);
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT({},send && modifyresult.retcode==TRADE_RETCODE_DONE,false,::Print(TOSTRING(modifyresult.retcode));)
      //===============

      //===============
      retcode=modifyresult.retcode;
      //===============

      //===============
      if(send && modifyresult.retcode==TRADE_RETCODE_DONE)
        {
         //===============
         result=true;
         //===============

         //===============
         retcode=0;
         //===============
        }
      //===============
     }
   else
     {
      //===============
      myretcode=RETCODE_ORDERCHECKFAILED;
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============

//===============
   if(!::OrderSelect((int)ticket,SELECT_BY_TICKET,MODE_TRADES) || ::OrderCloseTime()>0){myretcode=RETCODE_TRADENOTFOUND;return(false);}
//===============

//===============
   if(::OrderType()!=OP_BUY && ::OrderType()!=OP_SELL){myretcode=RETCODE_TRADENOTFOUND;return(false);}
//===============

//===============
   ::ResetLastError();
//===============

//===============
   result=::OrderModify((int)ticket,::OrderOpenPrice(),SL,TP,0,clrNONE);
//===============

//===============
   retcode=::GetLastError();
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},result,false,::Print(TOSTRING(retcode));)
//===============

//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::ModifyPendingOrder(const long ticket,const double newprice,const double newsl,const double newtp,
                                       const datetime newexpiration,uint &retcode,eError &myretcode)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const bool cantrade=cTrade::CanTrade();
//===============
/* DEBUG ASSERTION */ASSERT({},cantrade,true,{})
//===============
   if(!cantrade){myretcode=ERROR_AUTOTRADINGNOTALLOWED;return(false);}
//===============

//===============
   cPendingOrderInfo order;
//===============
   order.Update(ticket);
//===============

//===============
   if(order.TicketGet()<=0 || order.StatusGet()!=ORDERSTATUS_PENDING){myretcode=RETCODE_TRADENOTFOUND;return(false);}
//===============

//===============
   const bool isfreezed=cTrade::CheckFreezed(order.SymbolGet(),order.TypeGet(),order.OpenPriceGet());
//===============
   if(isfreezed)return(false);
//===============

//===============
   const string symbol = order.SymbolGet();
   const int    digits = (int)::SymbolInfoInteger(symbol,SYMBOL_DIGITS);
//===============
   const double PRICE  = ::NormalizeDouble(newprice,digits);
   const double SL     = ::NormalizeDouble(newsl,digits);
   const double TP     = ::NormalizeDouble(newtp,digits);
//===============

//===============
   const bool sameSL = (SL==order.StopLossGet());
   const bool sameTP = (TP==order.TakeProfitGet());
//===============

//===============
   if(sameSL && sameTP && PRICE==order.OpenPriceGet() && newexpiration==order.ExpirationGet())return(false);
//===============

//===============
   const eTradeType side=(order.TypeGet()==PENDINGORDERTYPE_BUYLIMIT || order.TypeGet()==PENDINGORDERTYPE_BUYSTOP)?TRADETYPE_BUY:TRADETYPE_SELL;
//===============

//===============
   const bool stopsok=cTrade::CheckStops(symbol,side,false,PRICE,sameSL?0:SL,sameTP?0:TP);
//===============
/* DEBUG ASSERTION */ASSERT({},stopsok,true,{})
//===============
   if(!stopsok){myretcode=RETCODE_WRONGSTOPS;return(false);}
//===============

//===============
   const bool orderpriceok=cTrade::CheckOrderPrice(symbol,order.TypeGet(),PRICE);
//===============
/* DEBUG ASSERTION */ASSERT({},orderpriceok,true,{})
//===============
   if(!orderpriceok){myretcode=RETCODE_WRONGORDERPRICE;return(false);}
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   if(!::OrderSelect(ticket))
     {
      //===============
      ::ResetLastError();
      //===============

      //===============
      myretcode=RETCODE_TRADENOTFOUND;
      //===============

      //===============
      return(false);
      //===============
     }
//===============

//===============
   MqlTradeRequest     modifyrequest;
   MqlTradeResult      modifyresult;
   MqlTradeCheckResult modifycheckresult;
//===============
   ::ZeroMemory(modifyrequest);
   ::ZeroMemory(modifyresult);
   ::ZeroMemory(modifycheckresult);
//===============

//===============
   modifyrequest.action       = TRADE_ACTION_MODIFY;
   modifyrequest.order        = ticket;
   modifyrequest.price        = PRICE;
   modifyrequest.sl           = SL;
   modifyrequest.tp           = TP;
   modifyrequest.type_time    = (ENUM_ORDER_TYPE_TIME)::OrderGetInteger(ORDER_TYPE_TIME);
//===============

//===============
   if(modifyrequest.type_time==ORDER_TIME_SPECIFIED || modifyrequest.type_time==ORDER_TIME_SPECIFIED_DAY)modifyrequest.expiration=newexpiration;
//===============

//===============
   const bool check=::OrderCheck(modifyrequest,modifycheckresult);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},check && modifycheckresult.retcode==0,false,::Print(TOSTRING(modifycheckresult.retcode));)
//===============

//===============
   retcode=modifycheckresult.retcode;
//===============

//===============
   if(check && modifycheckresult.retcode==0)
     {
      //===============
      const bool send=::OrderSend(modifyrequest,modifyresult);
      //===============

      //===============
      retcode=(modifyresult.retcode==TRADE_RETCODE_DONE?0:modifyresult.retcode);
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT({},send && modifyresult.retcode==TRADE_RETCODE_DONE,false,::Print(TOSTRING(modifyresult.retcode));)
      //===============

      //===============
      if(send && modifyresult.retcode==TRADE_RETCODE_DONE)return(true);
      //===============
     }
   else
     {
      //===============
      myretcode=RETCODE_ORDERCHECKFAILED;
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============

//===============
   if(!::OrderSelect((int)ticket,SELECT_BY_TICKET,MODE_TRADES) || ::OrderCloseTime()>0){myretcode=RETCODE_TRADENOTFOUND;return(false);}
//===============

//===============
   if(::OrderType()!=OP_BUYSTOP && ::OrderType()!=OP_SELLSTOP && ::OrderType()!=OP_BUYLIMIT && ::OrderType()!=OP_SELLLIMIT)
     {
      //===============
      myretcode=RETCODE_TRADENOTFOUND;
      //===============

      //===============
      return(false);
      //===============
     }
//===============

//===============
   ::ResetLastError();
//===============

//===============
   const bool modify=::OrderModify((int)ticket,PRICE,SL,TP,newexpiration,clrNONE);
//===============

//===============
   retcode=::GetLastError();
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},modify,false,::Print(TOSTRING(retcode));)
//===============

//===============
   return(modify);
//===============

//===============
#endif 
//===============

//===============
   return(false);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::ModifyTrade(const long ticket,const bool tightenstopsonly,
                                const bool slpointsenabled,const long slpoints,const bool tppointsenabled,const long tppoints,
                                const bool slmoneyenabled,const double slmoney,const bool tpmoneyenabled,const double tpmoney,
                                const bool slpriceenabled,const double slprice,const bool tppriceenabled,const double tpprice,
                                uint &retcode,eError &myretcode)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const bool changesl=(slpointsenabled || slpriceenabled || slmoneyenabled);
   const bool changetp=(tppointsenabled || tppriceenabled || tpmoneyenabled);
//===============

//===============
   if(!changesl && !changetp)return(false);
//===============

//===============
   const bool cantrade=cTrade::CanTrade();
//===============
/* DEBUG ASSERTION */ASSERT({},cantrade,true,{})
//===============
   if(!cantrade)return(false);
//===============

//===============
   double sllevel=0;
//===============
   double tplevel=0;
//===============

//===============
   cTradeInfo trade;
//===============
   trade.Update(ticket,false,false,false);
//===============

//===============
   if(trade.TicketGet()<=0 || trade.StatusGet()!=TRADESTATUS_CURRENT)return(false);
//===============

//===============
   cTrade::CalculateSLandTP(trade.SymbolGet(),trade.TypeGet(),trade.OpenPriceGet(),trade.LotsGet(),
                            slpointsenabled,slpoints,tppointsenabled,tppoints,
                            slmoneyenabled,slmoney,tpmoneyenabled,tpmoney,
                            slpriceenabled,slprice,tppriceenabled,tpprice,sllevel,tplevel);
//===============

//===============
   if(tightenstopsonly)
     {
      //===============
      if(trade.TypeGet()==TRADETYPE_BUY)
        {
         //===============
         if(trade.StopLossGet()>0)sllevel=::MathMax(sllevel,trade.StopLossGet());
         //===============

         //===============
         if(trade.TakeProfitGet()>0)tplevel=::MathMin(tplevel,trade.TakeProfitGet());
         //===============
        }
      //===============

      //===============
      if(trade.TypeGet()==TRADETYPE_SELL)
        {
         //===============
         if(trade.StopLossGet()>0)sllevel=::MathMin(sllevel,trade.StopLossGet());
         //===============

         //===============
         if(trade.TakeProfitGet()>0)tplevel=::MathMax(tplevel,trade.TakeProfitGet());
         //===============
        }
      //===============
     }
//===============

//===============
   const bool result=cTrade::ModifyTrade(ticket,
                                         changesl?sllevel:trade.StopLossGet(),changetp?tplevel:trade.TakeProfitGet(),
                                         retcode,myretcode);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::ModifyPendingOrder(const long ticket,const bool priceenabled,const double price,const bool tightenstopsonly,
                                       const bool slpointsenabled,const long slpoints,const bool tppointsenabled,const long tppoints,
                                       const bool slmoneyenabled,const double slmoney,const bool tpmoneyenabled,const double tpmoney,
                                       const bool slpriceenabled,const double slprice,const bool tppriceenabled,const double tpprice,
                                       const bool expirationenabled,const datetime expiration)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const bool changesl=(slpointsenabled || slpriceenabled || slmoneyenabled);
   const bool changetp=(tppointsenabled || tppriceenabled || tpmoneyenabled);
//===============

//===============
   if(!changesl && !changetp && !priceenabled && !expirationenabled)return;
//===============

//===============
   const bool cantrade=cTrade::CanTrade();
//===============
/* DEBUG ASSERTION */ASSERT({},cantrade,true,{})
//===============
   if(!cantrade)return;
//===============

//===============
   double sllevel=0;
//===============
   double tplevel=0;
//===============

//===============
   cPendingOrderInfo order;
//===============
   order.Update(ticket);
//===============

//===============
   if(order.TicketGet()<=0 || order.StatusGet()!=ORDERSTATUS_PENDING)return;
//===============

//===============
   const eTradeType side=(order.TypeGet()==PENDINGORDERTYPE_BUYLIMIT || order.TypeGet()==PENDINGORDERTYPE_BUYSTOP)?TRADETYPE_BUY:TRADETYPE_SELL;
//===============

//===============
   cTrade::CalculateSLandTP(order.SymbolGet(),side,priceenabled?price:order.OpenPriceGet(),order.LotsGet(),
                            slpointsenabled,slpoints,tppointsenabled,tppoints,
                            slmoneyenabled,slmoney,tpmoneyenabled,tpmoney,
                            slpriceenabled,slprice,tppriceenabled,tpprice,sllevel,tplevel);
//===============

//===============
   if(tightenstopsonly)
     {
      //===============
      if(side==TRADETYPE_BUY)
        {
         //===============
         if(order.StopLossGet()>0)sllevel=::MathMax(sllevel,order.StopLossGet());
         //===============

         //===============
         if(order.TakeProfitGet()>0)tplevel=::MathMin(tplevel,order.TakeProfitGet());
         //===============
        }
      //===============

      //===============
      if(side==TRADETYPE_SELL)
        {
         //===============
         if(order.StopLossGet()>0)sllevel=::MathMin(sllevel,order.StopLossGet());
         //===============

         //===============
         if(order.TakeProfitGet()>0)tplevel=::MathMax(tplevel,order.TakeProfitGet());
         //===============
        }
      //===============
     }
//===============

//===============
   uint retcode       = 0;
   eError myretcode   = WRONG_VALUE;
//===============

//===============
   cTrade::ModifyPendingOrder(ticket,priceenabled?price:order.OpenPriceGet(),
                              changesl?sllevel:order.StopLossGet(),
                              changetp?tplevel:order.TakeProfitGet(),
                              expirationenabled?expiration:order.ExpirationGet(),retcode,myretcode);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::CloseTrade(const long ticket,const bool slippageenabled,const long slippage,const double lots,uint &retcode,eError &myretcode)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const bool cantrade=cTrade::CanTrade();
//===============
/* DEBUG ASSERTION */ASSERT({},cantrade,true,{})
//===============
   if(!cantrade){myretcode=ERROR_AUTOTRADINGNOTALLOWED;return(false);}
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   if(!::PositionSelectByTicket(ticket))
     {
      //===============
      ::ResetLastError();
      //===============

      //===============
      myretcode=RETCODE_TRADENOTFOUND;
      //===============

      //===============
      return(false);
      //===============
     }
//===============

//===============
   MqlTradeRequest     closerequest;
   MqlTradeResult      closeresult;
   MqlTradeCheckResult closecheckresult;
//===============
   ::ZeroMemory(closerequest);
   ::ZeroMemory(closeresult);
   ::ZeroMemory(closecheckresult);
//===============

//===============
   const ENUM_ORDER_TYPE_FILLING filling=cTrade::GetFilling(::PositionGetString(POSITION_SYMBOL));
//===============

//===============
   closerequest.action       = TRADE_ACTION_DEAL;
   closerequest.position     = ticket;
   closerequest.magic        = ::PositionGetInteger(POSITION_MAGIC);
   closerequest.symbol       = ::PositionGetString(POSITION_SYMBOL);
   closerequest.price        = ::PositionGetDouble(POSITION_PRICE_CURRENT);
   closerequest.sl           = 0;
   closerequest.tp           = 0;
   closerequest.volume       = ((lots<=0)?(::PositionGetDouble(POSITION_VOLUME)):(cTrade::CheckLot(closerequest.symbol,lots)));
   closerequest.type         = ((ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY?ORDER_TYPE_SELL:ORDER_TYPE_BUY);
   closerequest.deviation    = (slippageenabled?slippage:0);
   closerequest.comment      = ::PositionGetString(POSITION_COMMENT);
   closerequest.type_filling = filling;
//===============

//===============
   const bool closingallowed=cTrade::ClosingAllowed(closerequest.symbol);
//===============
/* DEBUG ASSERTION */ASSERT({},closingallowed,true,{})
//===============
   if(!closingallowed){myretcode=RETCODE_CLOSINGNOTALLOWED;return(false);}
//===============

//===============
   const bool check=::OrderCheck(closerequest,closecheckresult);
//===============

//===============
   retcode=closecheckresult.retcode;
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},check && closecheckresult.retcode==0,false,::Print(TOSTRING(closecheckresult.retcode));)
//===============

//===============
   if(check && closecheckresult.retcode==0)
     {
      //===============
      const bool send=::OrderSend(closerequest,closeresult);
      //===============

      //===============
      retcode=closeresult.retcode;
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT({},send && (closeresult.deal>0 || closeresult.order>0),false,::Print(TOSTRING(closeresult.retcode));)
      //===============

      //===============
      if(send && (closeresult.deal>0 || closeresult.order>0))return(true);
      //===============
     }
   else
     {
      //===============
      myretcode=RETCODE_ORDERCHECKFAILED;
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============

//===============
   if(!::OrderSelect((int)ticket,SELECT_BY_TICKET,MODE_TRADES) || ::OrderCloseTime()>0){myretcode=RETCODE_TRADENOTFOUND;return(false);}
//===============

//===============
   const bool closingallowed=cTrade::ClosingAllowed(::OrderSymbol());
//===============
/* DEBUG ASSERTION */ASSERT({},closingallowed,true,{})
//===============
   if(!closingallowed){myretcode=RETCODE_CLOSINGNOTALLOWED;return(false);}
//===============

//===============
   if(::OrderType()!=OP_BUY && ::OrderType()!=OP_SELL){myretcode=RETCODE_TRADENOTFOUND;return(false);}
//===============

//===============
   ::ResetLastError();
//===============

//===============
   const double closelots=((lots<=0)?(::OrderLots()):(cTrade::CheckLot(::OrderSymbol(),lots)));
//===============

//===============
   const bool close=::OrderClose(::OrderTicket(),closelots,::OrderClosePrice(),(slippageenabled?(int)slippage:0),clrNONE);
//===============

//===============
   retcode=::GetLastError();
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},close,false,::Print(TOSTRING(retcode));)
//===============

//===============
   return(close);
//===============

//===============
#endif 
//===============

//===============
   return(false);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::CloseBy(const long ticket1,const long ticket2)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const bool cantrade=cTrade::CanTrade();
//===============
/* DEBUG ASSERTION */ASSERT({},cantrade,true,{})
//===============
   if(!cantrade)return;
//===============

//===============
   cTradeInfo trade1;
   cTradeInfo trade2;
//===============
   trade1.Update(ticket1,false,false,false);
   trade2.Update(ticket2,false,false,false);
//===============

//===============
   const bool closingallowed=cTrade::ClosingAllowed(trade1.SymbolGet());
//===============
/* DEBUG ASSERTION */ASSERT({},closingallowed,true,{})
//===============
   if(!closingallowed)return;
//===============

//===============
   if(trade1.TicketGet()<=0 || trade1.StatusGet()!=TRADESTATUS_CURRENT ||
      trade2.TicketGet()<=0 || trade2.StatusGet()!=TRADESTATUS_CURRENT ||
      trade1.TypeGet()==trade2.TypeGet() || 
      trade1.SymbolGet()!=trade2.SymbolGet() || 
      trade1.LotsGet()!=trade2.LotsGet())
     {
      //===============
      return;
      //===============
     }
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   const int ordermode=(int)::SymbolInfoInteger(trade1.SymbolGet(),SYMBOL_ORDER_MODE);
//===============
   const bool orderallowed=((SYMBOL_ORDER_CLOSEBY&ordermode)==SYMBOL_ORDER_CLOSEBY);
//===============
/* DEBUG ASSERTION */ASSERT({},orderallowed,true,{})
//===============
   if(!orderallowed)return;
//===============

//===============
   if(!::PositionSelectByTicket(ticket1) || !::PositionSelectByTicket(ticket2))
     {
      //===============
      ::ResetLastError();
      //===============

      //===============
      return;
      //===============
     }
//===============

//===============
   MqlTradeRequest     closerequest;
   MqlTradeResult      closeresult;
   MqlTradeCheckResult closecheckresult;
//===============
   ::ZeroMemory(closerequest);
   ::ZeroMemory(closeresult);
   ::ZeroMemory(closecheckresult);
//===============

//===============
   const ENUM_ORDER_TYPE_FILLING filling=cTrade::GetFilling(trade1.SymbolGet());
//===============

//===============
   closerequest.action       = TRADE_ACTION_CLOSE_BY;
   closerequest.position     = ticket1;
   closerequest.position_by  = ticket2;
   closerequest.magic        = trade1.MagicGet();
   closerequest.symbol       = trade1.SymbolGet();
   closerequest.comment      = trade1.CommentGet();
   closerequest.type_filling = filling;
//===============

//===============
   const bool check=::OrderCheck(closerequest,closecheckresult);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},check && closecheckresult.retcode==0,false,::Print(TOSTRING(closecheckresult.retcode));)
//===============

//===============
   if(check && closecheckresult.retcode==0)
     {
      //===============
      const bool send=::OrderSend(closerequest,closeresult);
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT({},send && (closeresult.deal>0 || closeresult.order>0),false,::Print(TOSTRING(closeresult.retcode));)
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============

//===============
   if(!::OrderSelect((int)ticket1,SELECT_BY_TICKET,MODE_TRADES) || ::OrderCloseTime()>0)return;
//===============

//===============
   if(::OrderType()!=OP_BUY && ::OrderType()!=OP_SELL)return;
//===============

//===============
   if(!::OrderSelect((int)ticket2,SELECT_BY_TICKET,MODE_TRADES) || ::OrderCloseTime()>0)return;
//===============

//===============
   if(::OrderType()!=OP_BUY && ::OrderType()!=OP_SELL)return;
//===============

//===============
   const bool close=::OrderCloseBy((int)ticket1,(int)ticket2,clrNONE);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},close,false,::Print(TOSTRING(::GetLastError()));)
//===============

//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static bool cTrade::DeletePendingOrder(const long ticket,uint &retcode,eError &myretcode)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const bool cantrade=cTrade::CanTrade();
//===============
/* DEBUG ASSERTION */ASSERT({},cantrade,true,{})
//===============
   if(!cantrade){myretcode=ERROR_AUTOTRADINGNOTALLOWED;return(false);}
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   if(!::OrderSelect(ticket))
     {
      //===============
      ::ResetLastError();
      //===============

      //===============
      myretcode=RETCODE_TRADENOTFOUND;
      //===============

      //===============
      return(false);
      //===============
     }
//===============

//===============
   MqlTradeRequest     deleterequest;
   MqlTradeResult      deleteresult;
   MqlTradeCheckResult deletecheckresult;
//===============
   ::ZeroMemory(deleterequest);
   ::ZeroMemory(deleteresult);
   ::ZeroMemory(deletecheckresult);
//===============

//===============
   deleterequest.action      = TRADE_ACTION_REMOVE;
   deleterequest.order       = ticket;
//===============

//===============
   const bool check=::OrderCheck(deleterequest,deletecheckresult);
//===============

//===============
   retcode=deletecheckresult.retcode;
//===============

//===============
   if(check && deletecheckresult.retcode==0)
     {
      //===============
      const bool send=::OrderSend(deleterequest,deleteresult);
      //===============

      //===============
      retcode=(deleteresult.retcode==TRADE_RETCODE_DONE?0:deleteresult.retcode);
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT({},send && deleteresult.retcode==TRADE_RETCODE_DONE,false,::Print(TOSTRING(deleteresult.retcode));)
      //===============

      //===============
      if(send && deleteresult.retcode==TRADE_RETCODE_DONE)return(true);
      //===============
     }
   else
     {
      //===============
      myretcode=RETCODE_ORDERCHECKFAILED;
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============

//===============
   if(!::OrderSelect((int)ticket,SELECT_BY_TICKET,MODE_TRADES) || ::OrderCloseTime()>0){myretcode=RETCODE_TRADENOTFOUND;return(false);}
//===============

//===============
   if(::OrderType()!=OP_BUYSTOP && ::OrderType()!=OP_SELLSTOP && ::OrderType()!=OP_BUYLIMIT && ::OrderType()!=OP_SELLLIMIT)
     {
      //===============
      myretcode=RETCODE_TRADENOTFOUND;
      //===============

      //===============
      return(false);
      //===============
     }
//===============

//===============
   ::ResetLastError();
//===============

//===============
   const bool deleteorder=::OrderDelete(OrderTicket(),clrNONE);
//===============

//===============
   retcode=::GetLastError();
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},deleteorder,false,::Print(TOSTRING(retcode));)
//===============

//===============
   return(deleteorder);
//===============

//===============
#endif 
//===============

//===============
   return(false);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::AddCurrentTrades(const cTradesFilter &filter,long &tickets[])
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
#ifdef __MQL5__
//===============
   const int tradesnumber=::PositionsTotal();
//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============
   const int tradesnumber=::OrdersTotal();
//===============
#endif 
//===============

//===============
   for(int i=0;i<tradesnumber && !::IsStopped();i++)
     {
      //===============
#ifdef __MQL5__
      //===============
      const long ticket=(long)::PositionGetTicket(i);
      //===============
#endif 
      //===============

      //===============
#ifdef __MQL4__
      //===============
      if(!::OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
      //===============
      const int ordertype=::OrderType();
      //===============
      if(ordertype!=OP_BUY && ordertype!=OP_SELL)continue;
      //===============
      const long ticket=(long)::OrderTicket();
      //===============
#endif 
      //===============

      //===============
      cTradeInfo trade;
      //===============

      //===============
      trade.Update(ticket,true,true,false);
      //===============

      //===============
      if(!filter.Passed(trade))continue;
      //===============

      //===============
      cArray::AddLast(tickets,ticket,tradesnumber);
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::AddCurrentOrders(const cPendingOrdersFilter &filter,long &tickets[])
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const int ordersnumber=::OrdersTotal();
//===============

//===============
   for(int i=0;i<ordersnumber && !::IsStopped();i++)
     {
      //===============
#ifdef __MQL5__
      //===============
      const long ticket=(long)::OrderGetTicket(i);
      //===============
      const ENUM_ORDER_TYPE ordertype=(ENUM_ORDER_TYPE)::OrderGetInteger(ORDER_TYPE);
      //===============
      if(ordertype!=ORDER_TYPE_BUY_STOP && ordertype!=ORDER_TYPE_BUY_LIMIT &&
         ordertype!=ORDER_TYPE_SELL_STOP && ordertype!=ORDER_TYPE_SELL_LIMIT)continue;
      //===============
#endif 
      //===============

      //===============
#ifdef __MQL4__
      //===============
      if(!::OrderSelect(i,SELECT_BY_POS,MODE_TRADES))continue;
      //===============
      const int ordertype=::OrderType();
      //===============
      if(ordertype!=OP_BUYSTOP && ordertype!=OP_BUYLIMIT && ordertype!=OP_SELLSTOP && ordertype!=OP_SELLLIMIT)continue;
      //===============
      const long ticket=(long)::OrderTicket();
      //===============
#endif 
      //===============

      //===============
      cPendingOrderInfo order;
      //===============

      //===============
      order.Update(ticket);
      //===============

      //===============
      if(!filter.Passed(order))continue;
      //===============

      //===============
      cArray::AddLast(tickets,ticket,ordersnumber);
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::AddHistoryTrades(const cTradesFilter &filter,long &tickets[])
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   if(!filter.SelectHistory())return;
//===============

//===============
   const int dealsnumber=::HistoryDealsTotal();
//===============

//===============
   long tmptickets[];
//===============
   cArray::Free(tmptickets);
//===============

//===============
   for(int i=0;i<dealsnumber && !::IsStopped();i++)
     {
      //===============
      const ulong dealticket=::HistoryDealGetTicket(i);
      //===============
      const ENUM_DEAL_ENTRY entrytype=(ENUM_DEAL_ENTRY)::HistoryDealGetInteger(dealticket,DEAL_ENTRY);
      //===============

      //===============
      if(entrytype!=DEAL_ENTRY_OUT && entrytype!=DEAL_ENTRY_INOUT && entrytype!=DEAL_ENTRY_OUT_BY)continue;
      //===============

      //===============
      const long positionID=::HistoryDealGetInteger(dealticket,DEAL_POSITION_ID);
      //===============

      //===============
      if(cArray::ValueExist(tmptickets,positionID))continue;
      //===============

      //===============
      cArray::AddLast(tmptickets,positionID,dealsnumber);
      //===============
     }
//===============

//===============
   const int positionssnumber=cArray::Size(tmptickets);
//===============
   for(int i=0;i<positionssnumber && !::IsStopped();i++)
     {
      //===============
      cTradeInfo trade;
      //===============

      //===============
      trade.Update(tmptickets[i],true,true,false);
      //===============

      //===============
      if(!filter.Passed(trade))continue;
      //===============

      //===============
      cArray::AddLast(tickets,tmptickets[i],positionssnumber);
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============

//===============
   const int tradesnumber=::OrdersHistoryTotal();
//===============

//===============
   for(int i=0;i<tradesnumber && !::IsStopped();i++)
     {
      //===============
      if(!::OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))continue;
      //===============

      //===============
      const int ordertype=::OrderType();
      //===============
      if(ordertype!=OP_BUY && ordertype!=OP_SELL)continue;
      //===============

      //===============
      const long ticket=(long)::OrderTicket();
      //===============

      //===============
      cTradeInfo trade;
      //===============

      //===============
      trade.Update(ticket,true,true,false);
      //===============

      //===============
      if(!filter.Passed(trade))continue;
      //===============

      //===============
      cArray::AddLast(tickets,ticket,tradesnumber);
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::AddHistoryOrders(const cPendingOrdersFilter &filter,long &tickets[])
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   if(!filter.SelectHistory())return;
//===============

//===============
   const int ordersnumber=::HistoryOrdersTotal();
//===============

//===============
   long tmptickets[];
//===============
   cArray::Free(tmptickets);
//===============

//===============
   for(int i=0;i<ordersnumber && !::IsStopped();i++)
     {
      //===============
      const long ticket=(long)::HistoryOrderGetTicket(i);
      //===============
      const ENUM_ORDER_TYPE ordertype=(ENUM_ORDER_TYPE)::HistoryOrderGetInteger(ticket,ORDER_TYPE);
      //===============
      if(ordertype!=ORDER_TYPE_BUY_STOP && ordertype!=ORDER_TYPE_BUY_LIMIT &&
         ordertype!=ORDER_TYPE_SELL_STOP && ordertype!=ORDER_TYPE_SELL_LIMIT)continue;
      //===============

      //===============
      cArray::AddLast(tmptickets,ticket,ordersnumber);
      //===============
     }
//===============

//===============
   const int pendingsnumber=cArray::Size(tmptickets);
//===============
   for(int i=0;i<pendingsnumber && !::IsStopped();i++)
     {
      //===============
      cPendingOrderInfo order;
      //===============

      //===============
      order.Update(tmptickets[i]);
      //===============

      //===============
      if(!filter.Passed(order))continue;
      //===============

      //===============
      cArray::AddLast(tickets,tmptickets[i],pendingsnumber);
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============

//===============
   const int ordersnumber=::OrdersHistoryTotal();
//===============

//===============
   for(int i=0;i<ordersnumber && !::IsStopped();i++)
     {
      //===============
      if(!::OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))continue;
      //===============

      //===============
      const int ordertype=::OrderType();
      //===============
      if(ordertype!=OP_BUYSTOP && ordertype!=OP_BUYLIMIT && ordertype!=OP_SELLSTOP && ordertype!=OP_SELLLIMIT)continue;
      //===============

      //===============
      const long ticket=(long)::OrderTicket();
      //===============

      //===============
      cPendingOrderInfo order;
      //===============

      //===============
      order.Update(ticket);
      //===============

      //===============
      if(!filter.Passed(order))continue;
      //===============

      //===============
      cArray::AddLast(tickets,ticket,ordersnumber);
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::GetFilteredTradesTickets(const cTradesFilter &filter,long &tickets[])
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   cArray::Free(tickets);
//===============

//===============
   switch(filter.StatusGet())
     {
      //===============
      case  TRADESTATUS_CURRENT        :   cTrade::AddCurrentTrades(filter,tickets);                                               break;
      case  TRADESTATUS_HISTORY        :   cTrade::AddHistoryTrades(filter,tickets);                                               break;
      case  TRADESTATUS_ALL            :   cTrade::AddCurrentTrades(filter,tickets);   cTrade::AddHistoryTrades(filter,tickets);   break;
      //===============
      default                   :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::GetFilteredPendingOrdersTickets(const cPendingOrdersFilter &filter,long &tickets[])
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   cArray::Free(tickets);
//===============

//===============
   switch(filter.StatusGet())
     {
      //===============
      case  ORDERSTATUS_PENDING        :   cTrade::AddCurrentOrders(filter,tickets);                                               break;
      case  ORDERSTATUS_HISTORY        :   cTrade::AddHistoryOrders(filter,tickets);                                               break;
      case  ORDERSTATUS_ALL            :   cTrade::AddCurrentOrders(filter,tickets);   cTrade::AddHistoryOrders(filter,tickets);   break;
      //===============
      default                   :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static long cTrade::ProfitPointsGet(const eTradeType type,const double openprice,const double closeprice,const string symbol)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const double difference=(type==TRADETYPE_BUY?(closeprice-openprice):(openprice-closeprice));
//===============

//===============
   const double point=::SymbolInfoDouble(symbol,SYMBOL_POINT);
//===============

//===============
   const long result=((point!=0)?(long)(difference/point):0);
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static double cTrade::CommissionGet(const long positionID)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   double result=0.0;
//===============

//===============
#ifdef __MQL5__
//===============

//===============
   if(::HistorySelectByPosition(positionID))
     {
      //===============
      const int deals=::HistoryDealsTotal();
      //===============

      //===============  
      for(int i=0;i<deals && !::IsStopped();i++)
        {
         //===============
         const ulong ticket=::HistoryDealGetTicket(i);
         //===============

         //===============
         result+=::HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         //===============
        }
      //===============
     }
//===============

//===============
#endif 
//===============

//===============
#ifdef __MQL4__
//===============
/* DEBUG ASSERTION */ASSERT({},false,true,{})
//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::CloseTrades(const long &tickets[],const bool closeby,
                                const bool slippageenabled,const long slippage)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const int size=cArray::Size(tickets);
//===============

//===============
   uint retcode       = 0;
   eError myretcode   = WRONG_VALUE;
//===============

//===============
   if(!closeby || size<=1)
     {
      //===============
      for(int i=0;i<size && !::IsStopped();i++)
        {
         //===============
         cTrade::CloseTrade(tickets[i],slippageenabled,slippage,0,retcode,myretcode);
         //===============
        }
      //===============
     }
   else
     {
      //===============
      cTrade::TradesCloseBy(tickets,slippageenabled,slippage);
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::DeletePendingOrders(const long &tickets[])
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const int size=cArray::Size(tickets);
//===============

//===============
   uint retcode       = 0;
   eError myretcode   = WRONG_VALUE;
//===============

//===============
   for(int i=0;i<size && !::IsStopped();i++)
     {
      //===============
      cTrade::DeletePendingOrder(tickets[i],retcode,myretcode);
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::ModifyTrades(const long &tickets[],const bool tightenstopsonly,
                                 const bool slpointsenabled,const long slpoints,const bool tppointsenabled,const long tppoints,
                                 const bool slmoneyenabled,const double slmoney,const bool tpmoneyenabled,const double tpmoney,
                                 const bool slpriceenabled,const double slprice,const bool tppriceenabled,const double tpprice)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   uint retcode       = 0;
   eError myretcode   = WRONG_VALUE;
//===============

//===============
   const int size=cArray::Size(tickets);
//===============

//===============
   for(int i=0;i<size && !::IsStopped();i++)
     {
      //===============
      cTrade::ModifyTrade(tickets[i],tightenstopsonly,
                          slpointsenabled,slpoints,tppointsenabled,tppoints,
                          slmoneyenabled,slmoney,tpmoneyenabled,tpmoney,
                          slpriceenabled,slprice,tppriceenabled,tpprice,
                          retcode,myretcode);
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::ModifyPendingOrders(const long &tickets[],const bool priceenabled,const double price,const bool tightenstopsonly,
                                        const bool slpointsenabled,const long slpoints,const bool tppointsenabled,const long tppoints,
                                        const bool slmoneyenabled,const double slmoney,const bool tpmoneyenabled,const double tpmoney,
                                        const bool slpriceenabled,const double slprice,const bool tppriceenabled,const double tpprice,
                                        const bool expirationenabled,const datetime expiration)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const int size=cArray::Size(tickets);
//===============

//===============
   for(int i=0;i<size && !::IsStopped();i++)
     {
      //===============
      cTrade::ModifyPendingOrder(tickets[i],priceenabled,price,tightenstopsonly,
                                 slpointsenabled,slpoints,tppointsenabled,tppoints,
                                 slmoneyenabled,slmoney,tpmoneyenabled,tpmoney,
                                 slpriceenabled,slprice,tppriceenabled,tpprice,
                                 expirationenabled,expiration);
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::BreakEven(const long &tickets[],const long belevel,const long beprofit)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   const int size=cArray::Size(tickets);
//===============

//===============
   uint retcode       = 0;
   eError myretcode   = WRONG_VALUE;
//===============

//===============
   for(int i=0;i<size && !::IsStopped();i++)
     {
      //===============
      cTrade::BreakEven(tickets[i],belevel,beprofit,retcode,myretcode);
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static void cTrade::TrailingStop(const long &tickets[],const long tslstart,const long tsldistance,const bool tsllevelenabled,const double tsllevel)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   uint retcode       = 0;
   eError myretcode   = WRONG_VALUE;
//===============

//===============
   const int size=cArray::Size(tickets);
//===============

//===============
   for(int i=0;i<size && !::IsStopped();i++)
     {
      //===============
      cTrade::TrailingStop(tickets[i],tslstart,tsldistance,tsllevelenabled,tsllevel,retcode,myretcode);
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableParameter final
  {
   //====================
private:
   //====================
   //===============
   //===============
   cExecutable *const In;
   cObject          *OutputValue;
   //===============
   //===============
   const eParameter Type;
   const bool        Reversed;
   const int         Order;
   const bool        Enabled;
   //===============
   //===============
   const bool        Connected;
   //===============
   //===============
   template<typename T>
   void              Reverse(T &to)const{}
   void              Reverse(bool &to)const{if(this.Reversed)to=!to;}
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //=============== 
   template<typename T>
   void              cExecutableParameter(const eParameter type,const T value,const int order,const bool enabled);
   void              cExecutableParameter(const eParameter type,cExecutable *const in,const bool reversed,const int order,const bool enabled);
   virtual void     ~cExecutableParameter(void){if(cPointer::Valid(this.OutputValue))cPointer::Delete(this.OutputValue);}
   //===============
   //===============
   void              StartExecutionThread(void)const;
   //===============
   //===============
   eParameter TypeGet(void)const{return(this.Type);}
   //===============
   //===============
   bool              EnabledGet(void)const{return(this.Enabled);}
   //===============
   //===============
   int               OrderGet(void)const{return(this.Order);}
   //===============
   //===============
   template<typename T>
   bool              ValueGet(T &to)const;
   bool              ValueGet(const cExecutable *&to)const;
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutableParameter::cExecutableParameter(const eParameter type,cExecutable *const in,
                                                const bool reversed,const int order,const bool enabled):
                                                //===============
                                                Reversed(reversed),
                                                In(in),
                                                OutputValue(NULL),
                                                Type(type),
                                                Order(order),
                                                Enabled(enabled),
                                                Connected(true)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
void cExecutableParameter::cExecutableParameter(const eParameter type,
                                                const T value,const int order,const bool enabled):
                                                //===============
                                                Reversed(false),
                                                In(NULL),
                                                Type(type),
                                                Order(order),
                                                Enabled(enabled),
                                                Connected(false)
  {
//===============
   cVariable<T>*const variable=new cVariable<T>;
//===============
   variable.Set(value);
//===============

//===============
   this.OutputValue=variable;
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutableParameter::StartExecutionThread(void)const
  {
//===============
   if(!this.Connected)return;
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(this.In),true,
                         return;)
//===============

//===============
   this.In.StartExecutionThread(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableParameter::ValueGet(const cExecutable *&to)const
  {
//===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(this.In),true,{})
//===============

//===============
   if(!cPointer::Valid(this.In))return(false);
//===============

//===============
   const bool result=this.In.GetOutPutValue(to);
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
bool cExecutableParameter::ValueGet(T &to)const
  {
//===============
   if(!this.Connected)
     {
      //===============
      bool valid=false;
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT(valid=cPointer::Valid(this.OutputValue);,
                      valid,true,
                      return(false);)
      //===============

      //===============
      cVariable<T>*const variable=dynamic_cast<cVariable<T>*>(this.OutputValue);
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT(valid=cPointer::Valid(variable);,
                      valid,true,
                      return(false);)
      //===============

      //===============
      to=variable.Get();
      //===============

      //===============
      return(true);
      //===============
     }
//===============

//===============
   if(this.Connected)
     {
      //===============
      bool valid=false;
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT(valid=cPointer::Valid(this.In);,
                      valid,true,
                      return(false);)
      //===============

      //===============
      const bool result=this.In.GetOutPutValue(to);
      //===============

      //===============
      this.Reverse(to);
      //===============

      //===============
      return(result);
      //===============
     }
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},false,false,::Print(TOSTRING(cPointer::Valid(this.OutputValue)),VERTICALBAR,TOSTRING(cPointer::Valid(this.In)));)
//===============

//===============
   return(false);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   cExecutableParameter *Parameters[];
   //===============
   //===============
   int               ParametersIndexes[];
   bool              ParametersEnabled[];
   //===============
   //===============
   bool              Triggered;
   bool              Refreshed;
   bool              Executed;
   bool              ExecutionStarted;
   //===============
   //===============
   bool              HasTrigger;
   //===============
   //===============
   int               ParameterIndexSlow(const eParameter parametertype)const;
   int               ParameterIndex(const eParameter parametertype)const;
   int               ParametersNumber(const eParameter parametertype)const;
   //===============
   //===============
   bool              ParameterEnabledSlow(const eParameter parametertype)const;
   //===============
   //===============
   void              CheckTrigger(void);
   //===============
   //===============
   virtual bool      OutPutValueGet(long &to)const{return(false);}
   virtual bool      OutPutValueGet(double &to)const{return(false);}
   virtual bool      OutPutValueGet(string &to)const{return(false);}
   virtual bool      OutPutValueGet(bool &to)const{return(false);}
   virtual bool      OutPutValueGet(datetime &to)const{return(false);}
   virtual bool      OutPutValueGet(ENUM_TIMEFRAMES &to)const{return(false);}
   virtual bool      OutPutValueGet(ENUM_MA_METHOD &to)const{return(false);}
   virtual bool      OutPutValueGet(ENUM_APPLIED_PRICE &to)const{return(false);}
   virtual bool      OutPutValueGet(eRelationType &to)const{return(false);}
   virtual bool      OutPutValueGet(eTradeType &to)const{return(false);}
   virtual bool      OutPutValueGet(ePendingOrderType &to)const{return(false);}
   virtual bool      OutPutValueGet(const cExecutable *&to)const{return(false);}
   template<typename T>
   bool              OutPutValueGet(T &to)const{return(false);}
   //===============
   //===============
   //====================
protected:
   //====================
   //===============
   //===============
   bool              ParameterEnabled(const eParameter parametertype)const;
   //===============
   //===============
   template<typename T>
   bool              ParameterValueGet(const eParameter parametertype,T &to)const;
   template<typename T>
   bool              ParameterValuesGet(const eParameter parametertype,T &to[])const;
   //===============
   //===============
   void              TriggeredSet(void){this.Triggered=true;}
   bool              TriggeredGet(void)const{return(this.Triggered);}
   //===============
   //===============
   virtual void      OnTrigger(void){this.TriggeredSet();}
   //===============
   //===============
   virtual bool      ReFreshState(void){if(this.Refreshed)return(false);this.Refreshed=true;return(true);}
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutable(void);
   //===============
   //===============
   virtual void     ~cExecutable(void);
   //===============
   //===============
   template<typename T>
   bool              GetOutPutValue(T &to)const;
   //===============
   //===============
   void              SortParameters(void);
   //===============
   //===============
   template<typename T>
   void              ParameterAdd(const T value,const eParameter type,const int parameterorder,const bool enabled);
   void              LinkAdd(cExecutable *const from,const eParameter type,const bool reversed,const int parameterorder,const bool enabled);
   //===============
   //===============
   void              StartExecutionThread(const bool fullcheck);
   void              ReFreshEnable(void){this.Refreshed=false;this.Triggered=false;this.Executed=false;this.ExecutionStarted=false;}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutable::cExecutable(void):Triggered(false),Refreshed(false),Executed(false),HasTrigger(false)
  {
//===============
   cArray::Free(this.Parameters);
//===============

//===============
   cArray::Free(this.ParametersIndexes);
//===============

//===============
   cArray::Free(this.ParametersEnabled);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutable::SortParameters(void)
  {
//===============
   const int size=cArray::Size(this.Parameters);
//===============

//===============
   cExecutableParameter *temp[];
//===============
   cArray::Free(temp);
//===============   
   cArray::Resize(temp,size,0);
//===============

//===============
   int indexes[];
//===============
   int orders[];
//===============
   cArray::Free(orders);
//===============   
   cArray::Resize(orders,size,0);
//===============

//===============
   for(int i=0;i<size;i++)
     {
      //===============
      if(!cPointer::Valid(this.Parameters[i]))continue;
      //===============

      //===============
      temp[i]=this.Parameters[i];
      //===============

      //===============
      orders[i]=temp[i].OrderGet();
      //===============
     }
//===============

//===============
   cArray::SortAscend(indexes,orders);
//===============

//===============
   int maxparametertype=-1;
//===============

//===============
   for(int i=0;i<size;i++)
     {
      //===============
      int index=indexes[i];
      //===============

      //===============
      if(!cPointer::Valid(temp[index]))continue;
      //===============

      //===============
      this.Parameters[i]=temp[index];
      //===============

      //===============
      const eParameter type=this.Parameters[i].TypeGet();
      //===============

      //===============
      if((int)type>maxparametertype)maxparametertype=(int)type;
      //===============
     }
//===============

//===============
   cArray::Resize(this.ParametersIndexes,maxparametertype+1,0);
//===============

//===============
   cArray::Resize(this.ParametersEnabled,maxparametertype+1,0);
//===============

//===============
   cArray::Initialize(this.ParametersIndexes,-1);
//===============

//===============
   cArray::Initialize(this.ParametersEnabled,false);
//===============

//===============
   for(int i=0;i<=maxparametertype;i++)
     {
      //===============
      if(this.ParametersNumber((eParameter)i)!=1)continue;
      //===============

      //===============
      const eParameter type=(eParameter)i;
      //===============

      //===============
      this.ParametersIndexes[i]=this.ParameterIndexSlow(type);
      //===============

      //===============
      this.ParametersEnabled[i]=this.ParameterEnabledSlow(type);
      //===============
     }
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutable::~cExecutable(void)
  {
//===============
   const int size=cArray::Size(this.Parameters);
//===============

//===============
   for(int i=0;i<size;i++)
     {
      //===============
      if(!cPointer::Valid(this.Parameters[i]))continue;
      //===============

      //===============
      cPointer::Delete(this.Parameters[i]);
      //===============
     }
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int cExecutable::ParameterIndex(const eParameter parametertype)const
  {
//===============
   const int position=(int)parametertype;
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},position>=0 && position<cArray::Size(this.ParametersIndexes),true,
                         ::Print(TOSTRING(position),VERTICALBAR,::EnumToString(parametertype)););
//===============

//===============
   const int index=this.ParametersIndexes[position];
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},index>=0,true,::Print(TOSTRING(index),VERTICALBAR,::EnumToString(parametertype)););
//===============

//===============
   return(index);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int cExecutable::ParameterIndexSlow(const eParameter parametertype)const
  {
//===============
   int index=-1;
//===============

//===============
   bool valid=false;
//===============

//===============
   const int size=cArray::Size(this.Parameters);
//===============
   for(int i=0;i<size;i++)
     {
      //===============
/* DEBUG ASSERTION */ASSERT(valid=cPointer::Valid(this.Parameters[i]);,
                      valid,false,
                      continue;)
      //===============

      //===============
      if(this.Parameters[i].TypeGet()!=parametertype)continue;
      //===============

      //===============
      index=i;
      //===============

      //===============
      break;
      //===============
     }
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},index>=0 && index<cArray::Size(this.Parameters),true,::Print(TOSTRING(index),VERTICALBAR,::EnumToString(parametertype)););
//===============

//===============
   if(index<0 || index>=cArray::Size(this.Parameters))return(-1);
//===============

//===============
/* DEBUG ASSERTION */ASSERT(valid=cPointer::Valid(this.Parameters[index]);,
                         valid,true,
                         return(-1);)
//===============

//===============
   return(index);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutable::ParameterEnabledSlow(const eParameter parametertype)const
  {
//===============
   int parametersnumber=0;
//===============

//===============
/* DEBUG ASSERTION */ASSERT(parametersnumber=this.ParametersNumber(parametertype);,
                         parametersnumber==1,true,
                         ::Print(TOSTRING(parametersnumber),VERTICALBAR,::EnumToString(parametertype));
                         return(false);
                         );
//===============

//===============
   const int index=this.ParameterIndex(parametertype);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},index>=0,true,::Print(TOSTRING(index),VERTICALBAR,::EnumToString(parametertype)););
//===============

//===============
   if(index<0)return(false);
//===============

//===============
   return(this.Parameters[index].EnabledGet());
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutable::ParameterEnabled(const eParameter parametertype)const
  {
//===============
   const int position=(int)parametertype;
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},position>=0 && position<cArray::Size(this.ParametersIndexes),true,
                         ::Print(TOSTRING(position),VERTICALBAR,::EnumToString(parametertype)););
//===============

//===============
   const bool result=this.ParametersEnabled[position];
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
bool cExecutable::ParameterValueGet(const eParameter parametertype,T &to)const
  {
//===============
   int parametersnumber=0;
//===============

//===============
/* DEBUG ASSERTION */ASSERT(parametersnumber=this.ParametersNumber(parametertype);,
                         parametersnumber==1,true,
                         ::Print(TOSTRING(parametersnumber),VERTICALBAR,::EnumToString(parametertype));
                         return(false);
                         );
//===============

//===============
   const int index=this.ParameterIndex(parametertype);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},index>=0,true,::Print(TOSTRING(index),VERTICALBAR,::EnumToString(parametertype)););
//===============

//===============
   if(index<0)return(false);
//===============

//===============
   return(this.Parameters[index].ValueGet(to));
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
bool cExecutable::ParameterValuesGet(const eParameter parametertype,T &to[])const
  {
//===============
   cArray::Free(to);
//===============

//===============
   bool result=true;
//===============

//===============
   const int size=cArray::Size(this.Parameters);
//===============
   for(int i=0;i<size;i++)
     {
      //===============
      bool valid=false;
      //===============

      //===============
/* DEBUG ASSERTION */ASSERT(valid=cPointer::Valid(this.Parameters[i]);,
                      valid,false,
                      continue;)
      //===============

      //===============
      if(this.Parameters[i].TypeGet()!=parametertype)continue;
      //===============

      //===============
      T value=NULL;
      //===============

      //===============
      if(!this.Parameters[i].ValueGet(value))result=false;
      //===============

      //===============
      cArray::AddLast(to,value,size);
      //===============
     }
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
bool cExecutable::GetOutPutValue(T &to)const
  {
//===============
   const bool result=this.OutPutValueGet(to);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},result,false,{})
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
void cExecutable::ParameterAdd(const T value,const eParameter type,const int parameterorder,const bool enabled)
  {
//===============
   if(type==PARAMETER_TRIGGER)this.HasTrigger=true;
//===============

//===============
   cExecutableParameter *parameter=new cExecutableParameter(type,value,parameterorder,enabled);
//===============

//===============
   cArray::AddLast(this.Parameters,parameter,0);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutable::LinkAdd(cExecutable *const from,const eParameter type,const bool reversed,const int parameterorder,const bool enabled)
  {
//===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(from),true,::Print(::EnumToString(type));)
//===============

//===============
   if(!cPointer::Valid(from))return;
//===============

//===============
   if(type==PARAMETER_TRIGGER)this.HasTrigger=true;
//===============

//===============
   cExecutableParameter *parameter=new cExecutableParameter(type,from,reversed,parameterorder,enabled);
//===============

//===============
   cArray::AddLast(this.Parameters,parameter,0);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutable::StartExecutionThread(const bool fullcheck)
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   if(this.Executed)return;
//===============

//===============
   if(this.ExecutionStarted)return;
//===============

//===============
   this.ExecutionStarted=true;
//===============

//===============
   const int size=cArray::Size(this.Parameters);
//===============

//===============
   bool runfullthread=true;
//===============

//===============
   if(this.HasTrigger && !fullcheck)
     {
      //===============
      const int index=this.ParameterIndex(PARAMETER_TRIGGER);
      //===============

      //===============
      this.Parameters[index].StartExecutionThread();
      //===============

      //===============
      this.ParameterValueGet(PARAMETER_TRIGGER,runfullthread);
      //===============
     }
//===============

//===============
   if(runfullthread)
     {
      for(int i=0;i<size;i++)
        {
         //===============
         bool valid=false;
         //===============

         //===============
/* DEBUG ASSERTION */ASSERT(valid=cPointer::Valid(this.Parameters[i]);,
                   valid,true,
                   continue;)
         //===============

         //===============
         this.Parameters[i].StartExecutionThread();
         //===============
        }
     }
//===============

//===============
   this.ReFreshState();
//===============

//===============
   this.CheckTrigger();
//===============

//===============
   this.Executed=true;
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int cExecutable::ParametersNumber(const eParameter parametertype)const
  {
//===============
   int result=0;
//===============

//===============
   const int size=cArray::Size(this.Parameters);
//===============
   for(int i=0;i<size;i++)
     {
      //===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(this.Parameters[i]),false,{})
      //===============

      //===============
      if(!cPointer::Valid(this.Parameters[i]))continue;
      //===============

      //===============
      if(this.Parameters[i].TypeGet()!=parametertype)continue;
      //===============

      //===============
      result++;
      //===============
     }
//===============

//===============
   return(result);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutable::CheckTrigger(void)
  {
//===============
   if(!this.HasTrigger)return;
//===============

//===============
   if(this.TriggeredGet())return;
//===============

//===============
   bool shouldtrigger=false;
//===============

//===============
   const bool triggerget=this.ParameterValueGet(PARAMETER_TRIGGER,shouldtrigger);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},triggerget,true,{})
//===============

//===============
   if(!triggerget)return;
//===============

//===============
   if(shouldtrigger)this.OnTrigger();
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableInputLongValue final : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTLONG
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableInputLongValue(void):OutputValue(0){}
   virtual void     ~cExecutableInputLongValue(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableInputLongValue::ReFreshState(void)override final
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   const bool get=this.ParameterValueGet(PARAMETER_LONGVALUE,this.OutputValue);
//===============
/* DEBUG ASSERTION */ASSERT({},get,false,{})
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableInputBoolValue final : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTBOOL
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableInputBoolValue(void):OutputValue(false){}
   virtual void     ~cExecutableInputBoolValue(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableInputBoolValue::ReFreshState(void)override final
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   const bool get=this.ParameterValueGet(PARAMETER_BOOLVALUE,this.OutputValue);
//===============
/* DEBUG ASSERTION */ASSERT({},get,false,{})
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableInputDoubleValue final : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTDOUBLE
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableInputDoubleValue(void):OutputValue(0.0){}
   virtual void     ~cExecutableInputDoubleValue(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableInputDoubleValue::ReFreshState(void)override final
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   const bool get=this.ParameterValueGet(PARAMETER_DOUBLEVALUE,this.OutputValue);
//===============
/* DEBUG ASSERTION */ASSERT({},get,false,{})
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableInputStringValue final : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTSTRING
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableInputStringValue(void):OutputValue(NULL){}
   virtual void     ~cExecutableInputStringValue(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableInputStringValue::ReFreshState(void)override final
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   const bool get=this.ParameterValueGet(PARAMETER_STRINGVALUE,this.OutputValue);
//===============
/* DEBUG ASSERTION */ASSERT({},get,false,{})
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableInputMAMethodValue final : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTENUM(ENUM_MA_METHOD)
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableInputMAMethodValue(void):OutputValue(WRONG_VALUE){}
   virtual void     ~cExecutableInputMAMethodValue(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableInputMAMethodValue::ReFreshState(void)override final
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   const bool get=this.ParameterValueGet(PARAMETER_MAMETHOD,this.OutputValue);
//===============
/* DEBUG ASSERTION */ASSERT({},get,false,{})
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableOpen : public cExecutable
  {
   //====================
protected:
   //====================
   //===============
   //===============
   string            Symbol;
   double            Lots;
   long              Magic;
   string            Comment;
   long              SLPoints;
   bool              SLPointsEnabled;
   double            SLPrice;
   bool              SLPriceEnabled;
   double            SLMoney;
   bool              SLMoneyEnabled;
   long              TPPoints;
   bool              TPPointsEnabled;
   double            TPPrice;
   bool              TPPriceEnabled;
   double            TPMoney;
   bool              TPMoneyEnabled;
   //===============
   //===============
   void              cExecutableOpen(void){}
   //===============
   //===============
   virtual bool      ReFreshState(void)override;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   virtual void     ~cExecutableOpen(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableOpen::ReFreshState(void)override
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   this.Symbol          = NULL;
   this.Lots            = 0.0;
   this.Magic           = -1;
   this.Comment         = NULL;
   this.SLPoints        = 0;
   this.SLPointsEnabled = false;
   this.SLPrice         = 0.0;
   this.SLPriceEnabled  = false;
   this.SLMoney         = 0.0;
   this.SLMoneyEnabled  = false;
   this.TPPoints        = 0;
   this.TPPointsEnabled = false;
   this.TPPrice         = 0.0;
   this.TPPriceEnabled  = false;
   this.TPMoney         = 0.0;
   this.TPMoneyEnabled  = false;
//===============

//===============
   const bool symbolget=this.ParameterValueGet(PARAMETER_SYMBOLNAME,this.Symbol);
//===============
/* DEBUG ASSERTION */ASSERT({},symbolget,false,{})
//===============

//===============
   const bool lotsget=this.ParameterValueGet(PARAMETER_LOTS,this.Lots);
//===============
/* DEBUG ASSERTION */ASSERT({},lotsget,false,{})
//===============

//===============
   const bool magicget=this.ParameterValueGet(PARAMETER_MAGIC,this.Magic);
//===============
/* DEBUG ASSERTION */ASSERT({},magicget,false,{})
//===============

//===============
   const bool commentget=this.ParameterValueGet(PARAMETER_COMMENT,this.Comment);
//===============
/* DEBUG ASSERTION */ASSERT({},commentget,false,{})
//===============

//===============
   const bool slpointsget=this.ParameterValueGet(PARAMETER_STOPLOSSPOINTS,this.SLPoints);
//===============
/* DEBUG ASSERTION */ASSERT({},slpointsget,false,{})
//===============
   this.SLPointsEnabled=this.ParameterEnabled(PARAMETER_STOPLOSSPOINTS);
//===============

//===============
   const bool slpriceget=this.ParameterValueGet(PARAMETER_STOPLOSSPRICE,this.SLPrice);
//===============
/* DEBUG ASSERTION */ASSERT({},slpriceget,false,{})
//===============
   this.SLPriceEnabled=this.ParameterEnabled(PARAMETER_STOPLOSSPRICE);
//===============

//===============
   const bool slmoneyget=this.ParameterValueGet(PARAMETER_STOPLOSSMONEY,this.SLMoney);
//===============
/* DEBUG ASSERTION */ASSERT({},slmoneyget,false,{})
//===============
   this.SLMoneyEnabled=this.ParameterEnabled(PARAMETER_STOPLOSSMONEY);
//===============

//===============
   const bool tppointsget=this.ParameterValueGet(PARAMETER_TAKEPROFITPOINTS,this.TPPoints);
//===============
/* DEBUG ASSERTION */ASSERT({},tppointsget,false,{})
//===============
   this.TPPointsEnabled=this.ParameterEnabled(PARAMETER_TAKEPROFITPOINTS);
//===============

//===============
   const bool tppriceget=this.ParameterValueGet(PARAMETER_TAKEPROFITPRICE,this.TPPrice);
//===============
/* DEBUG ASSERTION */ASSERT({},tppriceget,false,{})
//===============
   this.TPPriceEnabled=this.ParameterEnabled(PARAMETER_TAKEPROFITPRICE);
//===============

//===============
   const bool tpmoneyget=this.ParameterValueGet(PARAMETER_TAKEPROFITMONEY,this.TPMoney);
//===============
/* DEBUG ASSERTION */ASSERT({},tpmoneyget,false,{})
//===============
   this.TPMoneyEnabled=this.ParameterEnabled(PARAMETER_TAKEPROFITMONEY);
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableOpenTrade final : public cExecutableOpen
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTNONE
   //===============
   //===============
   eTradeType        Type;
   long              Slippage;
   bool              SlippageEnabled;
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableOpenTrade(void){}
   virtual void     ~cExecutableOpenTrade(void){}
   //===============
   //===============
   virtual void      OnTrigger(void)override final;
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutableOpenTrade::OnTrigger(void)override final
  {
//===============
   uint retcode       = 0;
   eError myretcode   = WRONG_VALUE;
//===============

//===============
   cTrade::OpenTrade(this.Symbol,this.Type,this.Lots,this.Magic,this.Comment,
                     this.SLPointsEnabled,this.SLPoints,this.TPPointsEnabled,this.TPPoints,
                     this.SLMoneyEnabled,this.SLMoney,this.TPMoneyEnabled,this.TPMoney,
                     this.SLPriceEnabled,this.SLPrice,this.TPPriceEnabled,this.TPPrice,
                     this.SlippageEnabled,this.Slippage,true,retcode,myretcode);
//===============

//===============
   cExecutableOpen::OnTrigger();
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableOpenTrade::ReFreshState(void)override final
  {
//===============
   if(!cExecutableOpen::ReFreshState())return(false);
//===============

//===============
   this.Type            = WRONG_VALUE;
   this.Slippage        = 0;
   this.SlippageEnabled = false;
//===============

//===============
   const bool typeget=this.ParameterValueGet(PARAMETER_TRADETYPE,this.Type);
//===============
/* DEBUG ASSERTION */ASSERT({},typeget,false,{})
//===============

//===============
   const bool slippageget=this.ParameterValueGet(PARAMETER_SLIPPAGE,this.Slippage);
//===============
/* DEBUG ASSERTION */ASSERT({},slippageget,false,{})
//===============
   this.SlippageEnabled=this.ParameterEnabled(PARAMETER_SLIPPAGE);
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableModify : public cExecutable
  {
   //====================
protected:
   //====================
   //===============
   //===============
   bool              TightenStopsOnly;
   long              SLPoints;
   bool              SLPointsEnabled;
   double            SLPrice;
   bool              SLPriceEnabled;
   double            SLMoney;
   bool              SLMoneyEnabled;
   long              TPPoints;
   bool              TPPointsEnabled;
   double            TPPrice;
   bool              TPPriceEnabled;
   double            TPMoney;
   bool              TPMoneyEnabled;
   //===============
   //===============
   void              cExecutableModify(void){}
   //===============
   //===============
   virtual bool      ReFreshState(void)override;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   virtual void     ~cExecutableModify(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableModify::ReFreshState(void)override
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   this.TightenStopsOnly = false;
   this.SLPoints         = 0;
   this.SLPointsEnabled  = false;
   this.SLPrice          = 0.0;
   this.SLPriceEnabled   = false;
   this.SLMoney          = 0.0;
   this.SLMoneyEnabled   = false;
   this.TPPoints         = 0;
   this.TPPointsEnabled  = false;
   this.TPPrice          = 0.0;
   this.TPPriceEnabled   = false;
   this.TPMoney          = 0.0;
   this.TPMoneyEnabled   = false;
//===============

//===============
   const bool tightenonlyget=this.ParameterValueGet(PARAMETER_TIGHTENSTOPSONLY,this.TightenStopsOnly);
//===============
/* DEBUG ASSERTION */ASSERT({},tightenonlyget,false,{})
//===============

//===============
   const bool slpointsget=this.ParameterValueGet(PARAMETER_STOPLOSSPOINTS,this.SLPoints);
//===============
/* DEBUG ASSERTION */ASSERT({},slpointsget,false,{})
//===============
   this.SLPointsEnabled=this.ParameterEnabled(PARAMETER_STOPLOSSPOINTS);
//===============

//===============
   const bool slpriceget=this.ParameterValueGet(PARAMETER_STOPLOSSPRICE,this.SLPrice);
//===============
/* DEBUG ASSERTION */ASSERT({},slpriceget,false,{})
//===============
   this.SLPriceEnabled=this.ParameterEnabled(PARAMETER_STOPLOSSPRICE);
//===============

//===============
   const bool slmoneyget=this.ParameterValueGet(PARAMETER_STOPLOSSMONEY,this.SLMoney);
//===============
/* DEBUG ASSERTION */ASSERT({},slmoneyget,false,{})
//===============
   this.SLMoneyEnabled=this.ParameterEnabled(PARAMETER_STOPLOSSMONEY);
//===============

//===============
   const bool tppointsget=this.ParameterValueGet(PARAMETER_TAKEPROFITPOINTS,this.TPPoints);
//===============
/* DEBUG ASSERTION */ASSERT({},tppointsget,false,{})
//===============
   this.TPPointsEnabled=this.ParameterEnabled(PARAMETER_TAKEPROFITPOINTS);
//===============

//===============
   const bool tppriceget=this.ParameterValueGet(PARAMETER_TAKEPROFITPRICE,this.TPPrice);
//===============
/* DEBUG ASSERTION */ASSERT({},tppriceget,false,{})
//===============
   this.TPPriceEnabled=this.ParameterEnabled(PARAMETER_TAKEPROFITPRICE);
//===============

//===============
   const bool tpmoneyget=this.ParameterValueGet(PARAMETER_TAKEPROFITMONEY,this.TPMoney);
//===============
/* DEBUG ASSERTION */ASSERT({},tpmoneyget,false,{})
//===============
   this.TPMoneyEnabled=this.ParameterEnabled(PARAMETER_TAKEPROFITMONEY);
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableModifyCurrent : public cExecutableModify
  {
   //====================
protected:
   //====================
   //===============
   //===============
   void              cExecutableModifyCurrent(void){}
   //===============
   //===============
   virtual bool      ReFreshState(void)override;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   virtual void     ~cExecutableModifyCurrent(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableModifyCurrent::ReFreshState(void)override
  {
//===============
   if(!cExecutableModify::ReFreshState())return(false);
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableModifyPending : public cExecutableModify
  {
   //====================
protected:
   //====================
   //===============
   //===============
   double            Price;
   bool              PriceEnabled;
   datetime          Expiration;
   bool              ExpirationEnabled;
   //===============
   //===============
   void              cExecutableModifyPending(void){}
   //===============
   //===============
   virtual bool      ReFreshState(void)override;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   virtual void     ~cExecutableModifyPending(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableModifyPending::ReFreshState(void)override
  {
//===============
   if(!cExecutableModify::ReFreshState())return(false);
//===============

//===============
   this.Price             = 0;
   this.PriceEnabled      = false;
   this.Expiration        = 0;
   this.ExpirationEnabled = false;
//===============

//===============
   const bool priceget=this.ParameterValueGet(PARAMETER_ORDERPRICE,this.Price);
//===============
/* DEBUG ASSERTION */ASSERT({},priceget,false,{})
//===============
   this.PriceEnabled=this.ParameterEnabled(PARAMETER_ORDERPRICE);
//===============

//===============
   const bool expirationget=this.ParameterValueGet(PARAMETER_EXPIRATION,this.Expiration);
//===============
/* DEBUG ASSERTION */ASSERT({},expirationget,false,{})
//===============
   this.ExpirationEnabled=this.ParameterEnabled(PARAMETER_EXPIRATION);
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableModifyTradesGroup final : public cExecutableModifyCurrent
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTNONE
   //===============
   //===============
   long              Tickets[];
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableModifyTradesGroup(void){cArray::Free(this.Tickets);}
   virtual void     ~cExecutableModifyTradesGroup(void){}
   //===============
   //===============
   virtual void      OnTrigger(void)override final;
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutableModifyTradesGroup::OnTrigger(void)override final
  {
//===============
   cTrade::ModifyTrades(this.Tickets,this.TightenStopsOnly,
                        this.SLPointsEnabled,this.SLPoints,this.TPPointsEnabled,this.TPPoints,
                        this.SLMoneyEnabled,this.SLMoney,this.TPMoneyEnabled,this.TPMoney,
                        this.SLPriceEnabled,this.SLPrice,this.TPPriceEnabled,this.TPPrice);
//===============

//===============
   cExecutableModifyCurrent::OnTrigger();
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableModifyTradesGroup::ReFreshState(void)override final
  {
//===============
   if(!cExecutableModifyCurrent::ReFreshState())return(false);
//===============

//===============
   const cExecutable *executable=NULL;
//===============
   const bool executableget=this.ParameterValueGet(PARAMETER_TRADESGROUP,executable);
//===============
/* DEBUG ASSERTION */ASSERT({},executableget,false,{})
//===============

//===============
   const cExecutableTrades *const trades=dynamic_cast<const cExecutableTrades *>(executable);
//===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(trades),true,{})
//===============
   if(!cPointer::Valid(trades))return(true);
//===============

//===============
   cArray::Free(this.Tickets);
//===============
   trades.AddTicketsToArray(this.Tickets);
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableCloseTradesGroup final : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTNONE
   //===============
   //===============
   long              Tickets[];
   bool              CloseBy;
   long              Slippage;
   bool              SlippageEnabled;
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableCloseTradesGroup(void):CloseBy(false){cArray::Free(this.Tickets);}
   virtual void     ~cExecutableCloseTradesGroup(void){}
   //===============
   //===============
   virtual void      OnTrigger(void)override final;
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutableCloseTradesGroup::OnTrigger(void)override final
  {
//===============
   cTrade::CloseTrades(this.Tickets,this.CloseBy,this.SlippageEnabled,this.Slippage);
//===============

//===============
   cExecutable::OnTrigger();
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableCloseTradesGroup::ReFreshState(void)override final
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   this.Slippage        = 0;
   this.SlippageEnabled = false;
   this.CloseBy         = false;
//===============

//===============
   const cExecutable *executable=NULL;
//===============
   const bool executableget=this.ParameterValueGet(PARAMETER_TRADESGROUP,executable);
//===============
/* DEBUG ASSERTION */ASSERT({},executableget,false,{})
//===============

//===============
   const cExecutableTrades *const trades=dynamic_cast<const cExecutableTrades *>(executable);
//===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(trades),true,{})
//===============
   if(!cPointer::Valid(trades))return(true);
//===============

//===============
   cArray::Free(this.Tickets);
//===============
   trades.AddTicketsToArray(this.Tickets);
//===============

//===============
   const bool closebyget=this.ParameterValueGet(PARAMETER_CLOSEBY,this.CloseBy);
//===============
/* DEBUG ASSERTION */ASSERT({},closebyget,false,{})
//===============

//===============
   const bool slippageget=this.ParameterValueGet(PARAMETER_SLIPPAGE,this.Slippage);
//===============
/* DEBUG ASSERTION */ASSERT({},slippageget,false,{})
//===============
   this.SlippageEnabled=this.ParameterEnabled(PARAMETER_SLIPPAGE);
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableTrades : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTPOINTER
   //===============
   //===============
   cTradesGroupInfo  TradesInfo;
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   virtual void      UpdateTicketsArray(void)=NULL;
   //===============
   //===============
   //====================
protected:
   //====================
   //===============
   //===============
   long              Tickets[];
   //===============
   //===============  
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableTrades(void){}
   virtual void     ~cExecutableTrades(void){}
   //===============
   //===============
   void              ValueGet(double &value,const eTradesGroupInfo infotype)const;
   void              ValueGet(long &value,const eTradesGroupInfo infotype)const;
   //===============
   //===============
   void              AddTicketsToArray(long &array[])const;
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutableTrades::AddTicketsToArray(long &array[])const
  {
//===============
   const int size=cArray::Size(this.Tickets);
//===============
   const int reserve=cArray::Size(array)+size;
//===============
   for(int i=0;i<size;i++)
     {
      //===============
      if(cArray::ValueExist(array,this.Tickets[i]))continue;
      //===============

      //===============
      cArray::AddLast(array,this.Tickets[i],reserve);
      //===============
     }
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableTrades::ReFreshState(void)override final
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   cArray::Free(this.Tickets);
//===============

//===============
   this.UpdateTicketsArray();
//===============

//===============
   this.TradesInfo.Update(this.Tickets);
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutableTrades::ValueGet(double &value,const eTradesGroupInfo infotype)const
  {
//===============
   switch(infotype)
     {
      //===============
      case  TRADESGROUPINFO_PROFITMONEY       :   value=this.TradesInfo.ProfitMoneyGet();                                     break;
      case  TRADESGROUPINFO_TOTALLOTS         :   value=this.TradesInfo.TotalLotsGet();                                       break;
      case  TRADESGROUPINFO_AVERAGEPRICE      :   value=this.TradesInfo.AveragePriceGet();                                    break;
      //===============
      default                   :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //===============
     }
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutableTrades::ValueGet(long &value,const eTradesGroupInfo infotype)const
  {
//===============
   switch(infotype)
     {
      //===============
      case  TRADESGROUPINFO_TRADESNUMBER                    :   value=this.TradesInfo.ItemsNumberGet();                       break;
      case  TRADESGROUPINFO_PROFITPOINTS                    :   value=this.TradesInfo.ProfitPointsGet();                      break;
      case  TRADESGROUPINFO_MAXLOTTRADETICKET               :   value=this.TradesInfo.MaxLotsTicketGet();                     break;
      case  TRADESGROUPINFO_MINLOTTRADETICKET               :   value=this.TradesInfo.MinLotsTicketGet();                     break;
      case  TRADESGROUPINFO_MAXPROFITMONEYTRADETICKET       :   value=this.TradesInfo.MaxProfitMoneyTicketGet();              break;
      case  TRADESGROUPINFO_MINPROFITMONEYTRADETICKET       :   value=this.TradesInfo.MinProfitMoneyTicketGet();              break;
      case  TRADESGROUPINFO_MAXPROFITPOINTSTRADETICKET      :   value=this.TradesInfo.MaxProfitPointsTicketGet();             break;
      case  TRADESGROUPINFO_MINPROFITPOINTSTRADETICKET      :   value=this.TradesInfo.MinProfitPointsTicketGet();             break;
      case  TRADESGROUPINFO_LOWESTOPENPRICETRADETICKET      :   value=this.TradesInfo.LowestOpenPriceTicketGet();             break;
      case  TRADESGROUPINFO_HIGHESTOPENPRICETRADETICKET     :   value=this.TradesInfo.HighestOpenPriceTicketGet();            break;
      case  TRADESGROUPINFO_LOWESTCLOSEPRICETRADETICKET     :   value=this.TradesInfo.LowestClosePriceTicketGet();            break;
      case  TRADESGROUPINFO_HIGHESTCLOSEPRICETRADETICKET    :   value=this.TradesInfo.HighestClosePriceTicketGet();           break;
      case  TRADESGROUPINFO_EARLIESTOPENTIMETRADETICKET     :   value=this.TradesInfo.EarliestOpenTimeTicketGet();            break;
      case  TRADESGROUPINFO_LATESTOPENTIMETRADETICKET       :   value=this.TradesInfo.LatestOpenTimeTicketGet();              break;
      case  TRADESGROUPINFO_EARLIESTCLOSETIMETRADETICKET    :   value=this.TradesInfo.EarliestCloseTimeTicketGet();           break;
      case  TRADESGROUPINFO_LATESTCLOSETIMETRADETICKET      :   value=this.TradesInfo.LatestCloseTimeTicketGet();             break;
      case  TRADESGROUPINFO_SYMBOLSNUMBER                   :   value=this.TradesInfo.SymbolsNumberGet();                     break;
      //===============
      default                   :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //===============
     }
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableTradesGroup final : public cExecutableTrades
  {
   //====================
private:
   //====================
   //===============
   //===============
   virtual void      UpdateTicketsArray(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableTradesGroup(void){}
   virtual void     ~cExecutableTradesGroup(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutableTradesGroup::UpdateTicketsArray(void)override final
  {
//===============
   cTradesFilter filter;
//===============

//===============
   eTradeStatus status=WRONG_VALUE;
//===============
   const bool statusget=this.ParameterValueGet(PARAMETER_TRADESTATUS,status);
//===============
/* DEBUG ASSERTION */ASSERT({},statusget,false,{})
//===============
   filter.StatusSet(status);
//===============

//===============
   const bool magicenabled=this.ParameterEnabled(PARAMETER_MAGIC);
//===============
   if(magicenabled)
     {
      //===============
      long magic=-1;
      //===============
      const bool magicget=this.ParameterValueGet(PARAMETER_MAGIC,magic);
      //===============
/* DEBUG ASSERTION */ASSERT({},magicget,false,{})
      //===============
      filter.FilterByMagicSet(magicenabled);
      //===============
      filter.MagicSet(magic);
      //===============
     }
//===============

//===============
   const bool symbolenabled=this.ParameterEnabled(PARAMETER_SYMBOLNAME);
//===============
   if(symbolenabled)
     {
      //===============
      string symbol=NULL;
      //===============
      const bool symbolget=this.ParameterValueGet(PARAMETER_SYMBOLNAME,symbol);
      //===============
/* DEBUG ASSERTION */ASSERT({},symbolget,false,{})
      //===============
      filter.FilterBySymbolSet(symbolenabled);
      //===============
      filter.SymbolSet(symbol);
      //===============
     }
//===============

//===============
   const bool typeenabled=this.ParameterEnabled(PARAMETER_TRADETYPE);
//===============
   if(typeenabled)
     {
      //===============
      eTradeType type=WRONG_VALUE;
      //===============
      const bool typeget=this.ParameterValueGet(PARAMETER_TRADETYPE,type);
      //===============
/* DEBUG ASSERTION */ASSERT({},typeget,false,{})
      //===============
      filter.FilterByTypeSet(typeenabled);
      //===============
      filter.TypeSet(type);
      //===============
     }
//===============

//===============
   const bool ticketgreaterenabled=this.ParameterEnabled(PARAMETER_TICKETGREATEROREQUALTHAN);
//===============
   if(ticketgreaterenabled)
     {
      //===============
      long ticketgreater=-1;
      //===============
      const bool ticketgreaterget=this.ParameterValueGet(PARAMETER_TICKETGREATEROREQUALTHAN,ticketgreater);
      //===============
/* DEBUG ASSERTION */ASSERT({},ticketgreaterget,false,{})
      //===============
      filter.FilterByTicketGreaterSet(ticketgreaterenabled);
      //===============
      filter.TicketGreaterSet(ticketgreater);
      //===============
     }
//===============

//===============
   const bool ticketlessenabled=this.ParameterEnabled(PARAMETER_TICKETLESSOREQUALTHAN);
//===============
   if(ticketlessenabled)
     {
      //===============
      long ticketless=-1;
      //===============
      const bool ticketlessget=this.ParameterValueGet(PARAMETER_TICKETLESSOREQUALTHAN,ticketless);
      //===============
/* DEBUG ASSERTION */ASSERT({},ticketlessget,false,{})
      //===============
      filter.FilterByTicketLessSet(ticketlessenabled);
      //===============
      filter.TicketLessSet(ticketless);
      //===============
     }
//===============

//===============
   const bool opentimegreaterenabled=this.ParameterEnabled(PARAMETER_OPENTIMEGREATEROREQUALTHAN);
//===============
   if(opentimegreaterenabled)
     {
      //===============
      datetime opentimegreater=0;
      //===============
      const bool opentimegreaterget=this.ParameterValueGet(PARAMETER_OPENTIMEGREATEROREQUALTHAN,opentimegreater);
      //===============
/* DEBUG ASSERTION */ASSERT({},opentimegreaterget,false,{})
      //===============
      filter.FilterByOpenTimeGreaterSet(opentimegreaterenabled);
      //===============
      filter.OpenTimeGreaterSet(opentimegreater);
      //===============
     }
//===============

//===============
   const bool opentimelessenabled=this.ParameterEnabled(PARAMETER_OPENTIMELESSOREQUALTHAN);
//===============
   if(opentimelessenabled)
     {
      //===============
      datetime opentimeless=0;
      //===============
      const bool opentimelessget=this.ParameterValueGet(PARAMETER_OPENTIMELESSOREQUALTHAN,opentimeless);
      //===============
/* DEBUG ASSERTION */ASSERT({},opentimelessget,false,{})
      //===============
      filter.FilterByOpenTimeLessSet(opentimelessenabled);
      //===============
      filter.OpenTimeLessSet(opentimeless);
      //===============
     }
//===============

//===============
   const bool closetimegreaterenabled=this.ParameterEnabled(PARAMETER_CLOSETIMEGREATEROREQUALTHAN);
//===============
   if(closetimegreaterenabled)
     {
      //===============
      datetime closetimegreater=0;
      //===============
      const bool closetimegreaterget=this.ParameterValueGet(PARAMETER_CLOSETIMEGREATEROREQUALTHAN,closetimegreater);
      //===============
/* DEBUG ASSERTION */ASSERT({},closetimegreaterget,false,{})
      //===============
      filter.FilterByCloseTimeGreaterSet(closetimegreaterenabled);
      //===============
      filter.CloseTimeGreaterSet(closetimegreater);
      //===============
     }
//===============

//===============
   const bool closetimelessenabled=this.ParameterEnabled(PARAMETER_CLOSETIMELESSOREQUALTHAN);
//===============
   if(closetimelessenabled)
     {
      //===============
      datetime closetimeless=0;
      //===============
      const bool closetimelessget=this.ParameterValueGet(PARAMETER_CLOSETIMELESSOREQUALTHAN,closetimeless);
      //===============
/* DEBUG ASSERTION */ASSERT({},closetimelessget,false,{})
      //===============
      filter.FilterByCloseTimeLessSet(closetimelessenabled);
      //===============
      filter.CloseTimeLessSet(closetimeless);
      //===============
     }
//===============

//===============
   const bool profitgreaterenabled=this.ParameterEnabled(PARAMETER_PROFITGREATEROREQUALTHAN);
//===============
   if(profitgreaterenabled)
     {
      //===============
      double profitgreater=0;
      //===============
      const bool profitgreaterget=this.ParameterValueGet(PARAMETER_PROFITGREATEROREQUALTHAN,profitgreater);
      //===============
/* DEBUG ASSERTION */ASSERT({},profitgreaterget,false,{})
      //===============
      filter.FilterByProfitGreaterSet(profitgreaterenabled);
      //===============
      filter.ProfitGreaterSet(profitgreater);
      //===============
     }
//===============

//===============
   const bool profitlessenabled=this.ParameterEnabled(PARAMETER_PROFITLESSOREQUALTHAN);
//===============
   if(profitlessenabled)
     {
      //===============
      double profitless=0;
      //===============
      const bool profitlessget=this.ParameterValueGet(PARAMETER_PROFITLESSOREQUALTHAN,profitless);
      //===============
/* DEBUG ASSERTION */ASSERT({},profitlessget,false,{})
      //===============
      filter.FilterByProfitLessSet(profitlessenabled);
      //===============
      filter.ProfitLessSet(profitless);
      //===============
     }
//===============

//===============
   const bool exactcommentenabled=this.ParameterEnabled(PARAMETER_EXACTCOMMENT);
//===============
   if(exactcommentenabled)
     {
      //===============
      string exactcomment=NULL;
      //===============
      const bool exactcommentget=this.ParameterValueGet(PARAMETER_EXACTCOMMENT,exactcomment);
      //===============
/* DEBUG ASSERTION */ASSERT({},exactcommentget,false,{})
      //===============
      filter.FilterByExactCommentSet(exactcommentenabled);
      //===============
      filter.ExactCommentSet(exactcomment);
      //===============
     }
//===============

//===============
   const bool commentpartialenabled=this.ParameterEnabled(PARAMETER_COMMENTPARTIAL);
//===============
   if(commentpartialenabled)
     {
      //===============
      string commentpartial=NULL;
      //===============
      const bool commentpartialget=this.ParameterValueGet(PARAMETER_COMMENTPARTIAL,commentpartial);
      //===============
/* DEBUG ASSERTION */ASSERT({},commentpartialget,false,{})
      //===============
      filter.FilterByCommentPartialSet(commentpartialenabled);
      //===============
      filter.CommentPartialSet(commentpartial);
      //===============
     }
//===============

//===============
   const bool openpricegreaterenabled=this.ParameterEnabled(PARAMETER_OPENPRICEGREATEROREQUALTHAN);
//===============
   if(openpricegreaterenabled)
     {
      //===============
      double openpricegreater=0;
      //===============
      const bool openpricegreaterget=this.ParameterValueGet(PARAMETER_OPENPRICEGREATEROREQUALTHAN,openpricegreater);
      //===============
/* DEBUG ASSERTION */ASSERT({},openpricegreaterget,false,{})
      //===============
      filter.FilterByOpenPriceGreaterSet(openpricegreaterenabled);
      //===============
      filter.OpenPriceGreaterSet(openpricegreater);
      //===============
     }
//===============

//===============
   const bool openpricelessenabled=this.ParameterEnabled(PARAMETER_OPENPRICELESSOREQUALTHAN);
//===============
   if(openpricelessenabled)
     {
      //===============
      double openpriceless=0;
      //===============
      const bool openpricelessget=this.ParameterValueGet(PARAMETER_OPENPRICELESSOREQUALTHAN,openpriceless);
      //===============
/* DEBUG ASSERTION */ASSERT({},openpricelessget,false,{})
      //===============
      filter.FilterByOpenPriceLessSet(openpricelessenabled);
      //===============
      filter.OpenPriceLessSet(openpriceless);
      //===============
     }
//===============

//===============
   const bool closepricegreaterenabled=this.ParameterEnabled(PARAMETER_CLOSEPRICEGREATEROREQUALTHAN);
//===============
   if(closepricegreaterenabled)
     {
      //===============
      double closepricegreater=0;
      //===============
      const bool closepricegreaterget=this.ParameterValueGet(PARAMETER_CLOSEPRICEGREATEROREQUALTHAN,closepricegreater);
      //===============
/* DEBUG ASSERTION */ASSERT({},closepricegreaterget,false,{})
      //===============
      filter.FilterByClosePriceGreaterSet(closepricegreaterenabled);
      //===============
      filter.ClosePriceGreaterSet(closepricegreater);
      //===============
     }
//===============

//===============
   const bool closepricelessenabled=this.ParameterEnabled(PARAMETER_CLOSEPRICELESSOREQUALTHAN);
//===============
   if(closepricelessenabled)
     {
      //===============
      double closepriceless=0;
      //===============
      const bool closepricelessget=this.ParameterValueGet(PARAMETER_CLOSEPRICELESSOREQUALTHAN,closepriceless);
      //===============
/* DEBUG ASSERTION */ASSERT({},closepricelessget,false,{})
      //===============
      filter.FilterByClosePriceLessSet(closepricelessenabled);
      //===============
      filter.ClosePriceLessSet(closepriceless);
      //===============
     }
//===============

//===============
   const bool lotsgreaterenabled=this.ParameterEnabled(PARAMETER_LOTSGREATEROREQUALTHAN);
//===============
   if(lotsgreaterenabled)
     {
      //===============
      double lotsgreater=0;
      //===============
      const bool lotsgreaterget=this.ParameterValueGet(PARAMETER_LOTSGREATEROREQUALTHAN,lotsgreater);
      //===============
/* DEBUG ASSERTION */ASSERT({},lotsgreaterget,false,{})
      //===============
      filter.FilterByLotsGreaterSet(lotsgreaterenabled);
      //===============
      filter.LotsGreaterSet(lotsgreater);
      //===============
     }
//===============

//===============
   const bool lotslessenabled=this.ParameterEnabled(PARAMETER_LOTSLESSOREQUALTHAN);
//===============
   if(lotslessenabled)
     {
      //===============
      double lotsless=0;
      //===============
      const bool lotslessget=this.ParameterValueGet(PARAMETER_LOTSLESSOREQUALTHAN,lotsless);
      //===============
/* DEBUG ASSERTION */ASSERT({},lotslessget,false,{})
      //===============
      filter.FilterByLotsLessSet(lotslessenabled);
      //===============
      filter.LotsLessSet(lotsless);
      //===============
     }
//===============

//===============
   cTrade::GetFilteredTradesTickets(filter,this.Tickets);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableCombineTradesGroups final : public cExecutableTrades
  {
   //====================
private:
   //====================
   //===============
   //===============
   virtual void      UpdateTicketsArray(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableCombineTradesGroups(void){}
   virtual void     ~cExecutableCombineTradesGroups(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutableCombineTradesGroups::UpdateTicketsArray(void)override final
  {
//===============
   const cExecutable *executables[];
//===============
   cArray::Free(executables);
//===============
   const bool executablesget=this.ParameterValuesGet(PARAMETER_TRADESGROUP,executables);
//===============
/* DEBUG ASSERTION */ASSERT({},executablesget,false,{})
//===============

//===============
   const int size=cArray::Size(executables);
//===============
   for(int i=0;i<size;i++)
     {
      //===============
      const cExecutableTrades *tradesgroup=dynamic_cast<const cExecutableTrades *>(executables[i]);
      //===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(tradesgroup),true,{})
      //===============
      if(!cPointer::Valid(tradesgroup))continue;
      //===============

      //===============
      tradesgroup.AddTicketsToArray(this.Tickets);
      //===============
     }
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableTradesGroupInfo : public cExecutable
  {
   //====================
protected:
   //====================
   //===============
   //===============
   void              cExecutableTradesGroupInfo(void):InfoType(WRONG_VALUE),TradesGroup(NULL){}
   //===============
   //===============
   eTradesGroupInfo  InfoType;
   const cExecutableTrades *TradesGroup;
   //===============
   //===============
   virtual bool      ReFreshState(void)override;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   virtual void     ~cExecutableTradesGroupInfo(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableTradesGroupInfo::ReFreshState(void)override
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   const cExecutable *executable=NULL;
//===============
   const bool executableget=this.ParameterValueGet(PARAMETER_TRADESGROUP,executable);
//===============
/* DEBUG ASSERTION */ASSERT({},executableget,false,{})
//===============

//===============
   this.TradesGroup=dynamic_cast<const cExecutableTrades *>(executable);
//===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(this.TradesGroup),false,{})
//===============

//===============
   const bool infotypeget=this.ParameterValueGet(PARAMETER_TRADESGROUPINFO,this.InfoType);
//===============
/* DEBUG ASSERTION */ASSERT({},infotypeget,false,{})
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableTradesGroupInfoInteger final : public cExecutableTradesGroupInfo
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTLONG
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableTradesGroupInfoInteger(void):OutputValue(0){}
   virtual void     ~cExecutableTradesGroupInfoInteger(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableTradesGroupInfoInteger::ReFreshState(void)override final
  {
//===============
   if(!cExecutableTradesGroupInfo::ReFreshState())return(false);
//===============

//===============
   this.OutputValue=0;
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(this.TradesGroup),true,{})
//===============

//===============
   if(!cPointer::Valid(this.TradesGroup))return(true);
//===============

//===============
   this.TradesGroup.ValueGet(this.OutputValue,this.InfoType);
//===============

//===============
   return(true);
//===============
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableArithmetic final : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   double            Value1;
   double            Value2;
   eMathOperation    Operation;
   //===============
   //===============
   OUTPUTDOUBLE
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableArithmetic(void):OutputValue(0.0),Value1(0.0),Value2(0.0),Operation(WRONG_VALUE){}
   virtual void     ~cExecutableArithmetic(void){}
   //===============
   //===============
   virtual void      OnTrigger(void)override final;
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableArithmetic::ReFreshState(void)override final
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   const bool value1get=this.ParameterValueGet(PARAMETER_DOUBLEVALUE1,this.Value1);
//===============
/* DEBUG ASSERTION */ASSERT({},value1get,false,{})
//===============

//===============
   const bool value2get=this.ParameterValueGet(PARAMETER_DOUBLEVALUE2,this.Value2);
//===============
/* DEBUG ASSERTION */ASSERT({},value2get,false,{})
//===============

//===============
   const bool operationget=this.ParameterValueGet(PARAMETER_MATHOPERATION,this.Operation);
//===============
/* DEBUG ASSERTION */ASSERT({},operationget,false,{})
//===============

//===============
   this.OutputValue=this.Value1;
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutableArithmetic::OnTrigger(void)override final
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   this.OutputValue=0.0;
//===============

//===============
   switch(this.Operation)
     {
      //===============
      case  MATHOPERATION_SUM             :   this.OutputValue=this.Value1+this.Value2;                                                 break;
      case  MATHOPERATION_SUBTRACT        :   this.OutputValue=this.Value1-this.Value2;                                                 break;
      case  MATHOPERATION_DIVIDE          :   if(this.Value2==0)break;this.OutputValue=this.Value1/this.Value2;                         break;
      case  MATHOPERATION_REMAINDER       :   if(this.Value2==0)break;this.OutputValue=(double)((long)this.Value1%(long)this.Value2);   break;
      case  MATHOPERATION_MULTIPLY        :   this.OutputValue=this.Value1*this.Value2;                                                 break;
      case  MATHOPERATION_POWER           :   this.OutputValue=::MathPow(this.Value1,this.Value2);                                      break;
      case  MATHOPERATION_MAXIMUM         :   this.OutputValue=::MathMax(this.Value1,this.Value2);                                      break;
      case  MATHOPERATION_MINIMUM         :   this.OutputValue=::MathMin(this.Value1,this.Value2);                                      break;
      //===============
      default                   :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //===============
     }
//===============

//===============
   cExecutable::OnTrigger();
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableAnd final : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTBOOL
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableAnd(void):OutputValue(false){}
   virtual void     ~cExecutableAnd(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableAnd::ReFreshState(void)override final
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   this.OutputValue=false;
//===============

//===============
   bool values[];
//===============
   cArray::Free(values);
//===============
   const bool parametersget=this.ParameterValuesGet(PARAMETER_BOOLVALUE,values);
//===============
/* DEBUG ASSERTION */ASSERT({},parametersget,false,{})
//===============

//===============
   const int parametersnumber=cArray::Size(values);
//===============

//===============
   if(parametersnumber==0)return(true);
//===============

//===============
   bool result=true;
//===============

//===============
   for(int i=0;i<parametersnumber;i++)
     {
      //===============
      if(values[i])continue;
      //===============

      //===============
      result=false;
      //===============

      //===============
      break;
      //===============
     }
//===============

//===============
   this.OutputValue=result;
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableOr final : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTBOOL
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableOr(void):OutputValue(false){}
   virtual void     ~cExecutableOr(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableOr::ReFreshState(void)override final
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   this.OutputValue=false;
//===============

//===============
   bool values[];
//===============
   cArray::Free(values);
//===============
   const bool parametersget=this.ParameterValuesGet(PARAMETER_BOOLVALUE,values);
//===============
/* DEBUG ASSERTION */ASSERT({},parametersget,false,{})
//===============

//===============
   const int parametersnumber=cArray::Size(values);
//===============

//===============
   if(parametersnumber==0)return(true);
//===============

//===============
   bool result=false;
//===============

//===============
   for(int i=0;i<parametersnumber;i++)
     {
      //===============
      if(!values[i])continue;
      //===============

      //===============
      result=true;
      //===============

      //===============
      break;
      //===============
     }
//===============

//===============
   this.OutputValue=result;
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableCompare final : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTBOOL
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableCompare(void):OutputValue(false){}
   virtual void     ~cExecutableCompare(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableCompare::ReFreshState(void)override final
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   this.OutputValue=false;
//===============

//===============
   double value1=0.0;
//===============
   const bool value1get=this.ParameterValueGet(PARAMETER_DOUBLEVALUE1,value1);
//===============
/* DEBUG ASSERTION */ASSERT({},value1get,false,{})
//===============

//===============
   double value2=0.0;
//===============
   const bool value2get=this.ParameterValueGet(PARAMETER_DOUBLEVALUE2,value2);
//===============
/* DEBUG ASSERTION */ASSERT({},value2get,false,{})
//===============

//===============
   eRelationType relation=WRONG_VALUE;
//===============
   const bool relationget=this.ParameterValueGet(PARAMETER_RELATIONTYPE,relation);
//===============
/* DEBUG ASSERTION */ASSERT({},relationget,false,{})
//===============

//===============
   const double difference=value1-value2;
//===============

//===============
   switch(relation)
     {
      //===============
      case  RELATIONTYPE_GTEATER          :   this.OutputValue=(difference>=DBL_EPSILON);           break;
      case  RELATIONTYPE_GTEATEROREQUAL   :   this.OutputValue=(difference>-DBL_EPSILON);           break;
      case  RELATIONTYPE_EQUAL            :   this.OutputValue=(::fabs(difference)<=DBL_EPSILON);   break;
      case  RELATIONTYPE_LESS             :   this.OutputValue=(difference<-DBL_EPSILON);           break;
      case  RELATIONTYPE_LESSOREQUAL      :   this.OutputValue=(difference<=DBL_EPSILON);           break;
      //===============
      default                 :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //===============
     }
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableVariable : public cExecutable
  {
   //====================
protected:
   //====================
   //===============
   //===============
   bool              Init;
   //===============
   //===============
   template<typename T>
   void              Refresh(T &value,const eParameter parametertype);
   //===============
   //===============
   void              cExecutableVariable(void):Init(false){}
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   virtual void     ~cExecutableVariable(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
void cExecutableVariable::Refresh(T &value,const eParameter parametertype)
  {
//===============
   T values[];
//===============
   cArray::Free(values);
//===============
   const bool valuesget=this.ParameterValuesGet(parametertype,values);
//===============
/* DEBUG ASSERTION */ASSERT({},valuesget,false,{})
//===============

//===============
   bool conditions[];
//===============
   cArray::Free(conditions);
//===============
   const bool conditionsget=this.ParameterValuesGet(PARAMETER_CONDITION,conditions);
//===============
/* DEBUG ASSERTION */ASSERT({},conditionsget,false,{})
//===============

//===============
   if(!this.Init && cArray::Size(values)>0)
     {
      //===============
      value=values[0];
      //===============

      //===============
      this.Init=true;
      //===============
     }
//===============

//===============
   const int conditionssize=cArray::Size(conditions);
//===============
   const int valuessize=cArray::Size(values);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},valuessize==conditionssize+1,true,{})
//===============

//===============
   if(valuessize!=conditionssize+1)return;
//===============

//===============
   for(int i=0;i<conditionssize;i++)
     {
      //===============
      if(!conditions[i])continue;
      //===============

      //===============
      value=values[i+1];
      //===============
     }
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableVariableBool final : public cExecutableVariable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTBOOL
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableVariableBool(void):OutputValue(false){}
   virtual void     ~cExecutableVariableBool(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableVariableBool::ReFreshState(void)override final
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   this.Refresh(this.OutputValue,PARAMETER_BOOLVALUE);
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableVariableDouble final : public cExecutableVariable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTDOUBLE
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableVariableDouble(void):OutputValue(0.0){}
   virtual void     ~cExecutableVariableDouble(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableVariableDouble::ReFreshState(void)override final
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   this.Refresh(this.OutputValue,PARAMETER_DOUBLEVALUE);
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableLastServerTime final : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTDATETIME
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableLastServerTime(void):OutputValue(0){}
   virtual void     ~cExecutableLastServerTime(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableLastServerTime::ReFreshState(void)override final
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   this.OutputValue=::TimeCurrent();
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableTimeModify final : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTDATETIME
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableTimeModify(void):OutputValue(0){}
   virtual void     ~cExecutableTimeModify(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableTimeModify::ReFreshState(void)override final
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   this.OutputValue=0;
//===============

//===============
   datetime time=0;
//===============
   const bool gettime=this.ParameterValueGet(PARAMETER_TIMEVALUE,time);
//===============
/* DEBUG ASSERTION */ASSERT({},gettime,false,{})
//===============

//===============
   eMathOperation operation=WRONG_VALUE;
//===============
   const bool getoperation=this.ParameterValueGet(PARAMETER_MATHOPERATION,operation);
//===============
/* DEBUG ASSERTION */ASSERT({},getoperation,false,{})
//===============

//===============
   eTimeComponent timecomponent=WRONG_VALUE;
//===============
   const bool gettimecomp=this.ParameterValueGet(PARAMETER_TIMECOMPONENT,timecomponent);
//===============
/* DEBUG ASSERTION */ASSERT({},gettimecomp,false,{})
//===============

//===============
   long value=0;
//===============
   const bool valueget=this.ParameterValueGet(PARAMETER_LONGVALUE,value);
//===============
/* DEBUG ASSERTION */ASSERT({},valueget,false,{})
//===============

//===============
   switch(timecomponent)
     {
      //===============
      case  TIMECOMPONENT_HOUR         :   value*=3600;           break;
      case  TIMECOMPONENT_MINUTE       :   value*=60;             break;
      case  TIMECOMPONENT_SECOND       :                          break;
      //===============
      default                   :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //===============
     }
//===============

//===============
   switch(operation)
     {
      //===============
      case  MATHOPERATION_SUM          :   this.OutputValue=time+(int)value;       break;
      case  MATHOPERATION_SUBTRACT     :   this.OutputValue=time-(int)value;       break;
      //===============
      default                   :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //===============
     }
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableIndicatorValue final : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTDOUBLE
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableIndicatorValue(void):OutputValue(0.0){}
   virtual void     ~cExecutableIndicatorValue(void){}
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableIndicatorValue::ReFreshState(void)override final
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   this.OutputValue=0.0;
//===============

//===============
   const cExecutable *executable=NULL;
//===============
   const bool getexecutable=this.ParameterValueGet(PARAMETER_INDICATOR,executable);
//===============
/* DEBUG ASSERTION */ASSERT({},executable,false,{})
//===============

//===============
   const cExecutableIndicator *const indicator=dynamic_cast<const cExecutableIndicator *>(executable);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},cPointer::Valid(indicator),true,{})
//===============

//===============
   if(!cPointer::Valid(indicator))return(true);
//===============

//===============
   long barnumber=-1;
//===============
   const bool getbarnumber=this.ParameterValueGet(PARAMETER_BARNUMBER,barnumber);
//===============
/* DEBUG ASSERTION */ASSERT({},getbarnumber,false,{})
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},barnumber>=0,true,{})
//===============

//===============
   if(barnumber<0)return(true);
//===============

//===============
   this.OutputValue=indicator.ValueGet(barnumber);
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableIndicator : public cExecutable
  {
   //====================
private:
   //====================
   //===============
   //===============
   OUTPUTPOINTER
   //===============
   //===============
   //====================
protected:
   //====================
   //===============
   //===============
   void              cExecutableIndicator(void):Symbol(NULL),TimeFrame(WRONG_VALUE),Handle(INVALID_HANDLE),Line(0){}
   //===============
   //===============
   int               Handle;
   long              Line;
   //===============
   //===============
   string            Symbol;
   ENUM_TIMEFRAMES   TimeFrame;
   //===============
   //===============
   double            GetBufferValue(const int barnumber)const;
   //===============
   //===============
   virtual bool      ReFreshState(void)override;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              ValuesGet(const int barfromnumber,const int bartillnumber,double &values[])const;
   //===============
   //===============
   virtual void     ~cExecutableIndicator(void){}
   //===============
   //===============
   virtual void      HandleCreate(void)=NULL;
   //===============
   //===============
   virtual double    ValueGet(const long barnumber)const=NULL;
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableIndicator::ReFreshState(void)override
  {
//===============
   if(!cExecutable::ReFreshState())return(false);
//===============

//===============
   const bool getsymbol=this.ParameterValueGet(PARAMETER_SYMBOLNAME,this.Symbol);
//===============
/* DEBUG ASSERTION */ASSERT({},getsymbol,false,{})
//===============

//===============
   const bool gettimeframe=this.ParameterValueGet(PARAMETER_TIMEFRAME,this.TimeFrame);
//===============
/* DEBUG ASSERTION */ASSERT({},gettimeframe,false,{})
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutableIndicator::ValuesGet(const int barfromnumber,const int bartillnumber,double &values[])const
  {
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
   cArray::Free(values);
//===============

//===============
   const int size=barfromnumber-bartillnumber+1;
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},size>0,true,{})
//===============

//===============
   if(size<=0)return;
//===============

//===============
#ifdef __MQL5__
//===============
/* DEBUG ASSERTION */ASSERT({},this.Handle!=INVALID_HANDLE,true,{})
//===============

//===============
   if(this.Handle==INVALID_HANDLE)return;
//===============

//===============
   const int result=::CopyBuffer(this.Handle,(int)this.Line,bartillnumber,size,values);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},result==size,false,{})
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   if(result!=size)
     {
      //===============
      cArray::Free(values);
      //===============
     }
//===============

//===============
   return;
//===============
#endif
//===============

//===============
#ifdef __MQL4__
//===============
   for(long i=barfromnumber;i>=bartillnumber;i--)
     {
      //===============
      cArray::AddLast(values,this.ValueGet(i),size);
      //===============
     }
//===============
#endif 
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
double cExecutableIndicator::GetBufferValue(const int barnumber)const
  {
//===============
#ifdef __MQL5__
//===============
/* DEBUG MACROS' START */TRACEERRORS_START
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},this.Handle!=INVALID_HANDLE,true,{})
//===============

//===============
   if(this.Handle==INVALID_HANDLE)return(0.0);
//===============

//===============
   double buffer[];
//===============
   cArray::Free(buffer);
//===============

//===============
   const int result=::CopyBuffer(this.Handle,(int)this.Line,barnumber,1,buffer);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},result==1,false,{})
//===============

//===============
/* DEBUG MACROS' END */TRACEERRORS_END
//===============

//===============
   if(result!=1)return(0.0);
//===============

//===============
   return(buffer[0]);
//===============
#endif
//===============

//===============
   return(0.0);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableIndicatorRSI final : public cExecutableIndicator
  {
   //====================
private:
   //====================
   //===============
   //===============
   long              RSIPeriod;
   ENUM_APPLIED_PRICE AppliedPrice;
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableIndicatorRSI(void):RSIPeriod(-1),AppliedPrice(WRONG_VALUE){}
   virtual void     ~cExecutableIndicatorRSI(void){}
   //===============
   //===============
   virtual void      HandleCreate(void)override final;
   //===============
   //===============
   virtual double    ValueGet(const long barnumber)override final const;
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableIndicatorRSI::ReFreshState(void)override final
  {
//===============
   if(!cExecutableIndicator::ReFreshState())return(false);
//===============

//===============
   if(this.Handle!=INVALID_HANDLE)return(true);
//===============

//===============
   const bool getperiod=this.ParameterValueGet(PARAMETER_INDICATORPERIOD,this.RSIPeriod);
//===============
/* DEBUG ASSERTION */ASSERT({},getperiod,false,{})
//===============

//===============
   const bool getappliedprice=this.ParameterValueGet(PARAMETER_APPLIEDPRICE,this.AppliedPrice);
//===============
/* DEBUG ASSERTION */ASSERT({},getappliedprice,false,{})
//===============

//===============
   this.HandleCreate();
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutableIndicatorRSI::HandleCreate(void)override final
  {
//===============
#ifdef __MQL5__
//===============
   this.Handle=::iRSI(this.Symbol,this.TimeFrame,(int)this.RSIPeriod,this.AppliedPrice);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},this.Handle!=INVALID_HANDLE,false,{})
//===============
#endif
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cExecutableIndicatorRSI::ValueGet(const long barnumber)override final const
  {
//===============
#ifdef __MQL5__
//===============
   return(this.GetBufferValue((int)barnumber));
//===============
#endif
//===============

//===============
#ifdef __MQL4__
//===============
   return(::iRSI(this.Symbol,this.TimeFrame,(int)this.RSIPeriod,this.AppliedPrice,(int)barnumber));
//===============
#endif
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cExecutableIndicatorStochastic final : public cExecutableIndicator
  {
   //====================
private:
   //====================
   //===============
   //===============
   long              KPeriod;
   long              DPeriod;
   long              Slowing;
   ENUM_MA_METHOD    MAMethod;
   ENUM_STO_PRICE    StoPrice;
   eIndicatorLine    StoLine;
   //===============
   //===============
   virtual bool      ReFreshState(void)override final;
   //===============
   //===============
   //====================
public:
   //====================
   //===============
   //===============
   void              cExecutableIndicatorStochastic(void):KPeriod(-1),DPeriod(-1),Slowing(-1),MAMethod(WRONG_VALUE),StoPrice(WRONG_VALUE),
                                                              StoLine(WRONG_VALUE){}
   virtual void     ~cExecutableIndicatorStochastic(void){}
   //===============
   //===============
   virtual void      HandleCreate(void)override final;
   //===============
   //===============
   virtual double    ValueGet(const long barnumber)override final const;
   //===============
   //===============
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool cExecutableIndicatorStochastic::ReFreshState(void)override final
  {
//===============
   if(!cExecutableIndicator::ReFreshState())return(false);
//===============

//===============
   if(this.Handle!=INVALID_HANDLE)return(true);
//===============

//===============
   const bool getKperiod=this.ParameterValueGet(PARAMETER_KPERIOD,this.KPeriod);
//===============
/* DEBUG ASSERTION */ASSERT({},getKperiod,false,{})
//===============

//===============
   const bool getDperiod=this.ParameterValueGet(PARAMETER_DPERIOD,this.DPeriod);
//===============
/* DEBUG ASSERTION */ASSERT({},getDperiod,false,{})
//===============

//===============
   const bool getslowing=this.ParameterValueGet(PARAMETER_SLOWING,this.Slowing);
//===============
/* DEBUG ASSERTION */ASSERT({},getslowing,false,{})
//===============

//===============
   const bool getmamethod=this.ParameterValueGet(PARAMETER_MAMETHOD,this.MAMethod);
//===============
/* DEBUG ASSERTION */ASSERT({},getmamethod,false,{})
//===============

//===============
   const bool getstoprice=this.ParameterValueGet(PARAMETER_STOPRICE,this.StoPrice);
//===============
/* DEBUG ASSERTION */ASSERT({},getstoprice,false,{})
//===============

//===============
   const bool getline=this.ParameterValueGet(PARAMETER_OUTPUTLINETYPE,this.StoLine);
//===============
/* DEBUG ASSERTION */ASSERT({},getline,false,{})
//===============

//===============
   switch(this.StoLine)
     {
      //===============
      case  INDICATORLINE_MAIN          :   this.Line = #ifdef __MQL5__ MAIN_LINE #endif #ifdef __MQL4__ MODE_MAIN #endif;      break;
      case  INDICATORLINE_SIGNAL        :   this.Line = #ifdef __MQL5__ SIGNAL_LINE #endif #ifdef __MQL4__ MODE_SIGNAL #endif;    break;
      //===============
      default                   :/* DEBUG ASSERTION */ASSERT({},false,false,{}) break;
      //===============
     }
//===============

//===============
   this.HandleCreate();
//===============

//===============
   return(true);
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cExecutableIndicatorStochastic::HandleCreate(void)override final
  {
//===============
#ifdef __MQL5__
//===============
   this.Handle=::iStochastic(this.Symbol,this.TimeFrame,(int)this.KPeriod,(int)this.DPeriod,(int)this.Slowing,this.MAMethod,this.StoPrice);
//===============

//===============
/* DEBUG ASSERTION */ASSERT({},this.Handle!=INVALID_HANDLE,false,{})
//===============
#endif
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cExecutableIndicatorStochastic::ValueGet(const long barnumber)override final const
  {
//===============
#ifdef __MQL5__
//===============
   return(this.GetBufferValue((int)barnumber));
//===============
#endif
//===============

//===============
#ifdef __MQL4__
//===============
   return(::iStochastic(this.Symbol,this.TimeFrame,(int)this.KPeriod,(int)this.DPeriod,(int)this.Slowing,this.MAMethod,this.StoPrice,
          (int)this.Line,(int)barnumber));
//===============
#endif
//===============
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+




// ------------------------------------------------------------------
// ------------------------------------------------------------------


//+------------------------------------------------------------------+
// NOTE: clases
//+------------------------------------------------------------------+
interface IOrders
{
 public:
  virtual void Add()     = 0;
  virtual void Release() = 0;

  virtual bool AddOrder()    = 0;
  virtual bool DeleteOrder() = 0;
  virtual bool Select()      = 0;
};
class Order
{
  int      _id;
  string   _symbol;
  double   _price;
  double   _sl;
  double   _tp;
  double   _lot;
  int      _type;
  int      _magic;
  string   _comment;
  string   _strategy;
  datetime _expireTime;
  datetime _signalTime;
  double   _profit;
  double   _tslNext;
  bool     _bkvWasDoIt;
  int      _countPartials;

 public:
  Order(
      int      id,
      string   symbol,
      double   price,
      double   sl,
      double   tp,
      double   lot,
      int      type,
      int      magic,
      string   comment,
      string   strategy,
      datetime expireTime,
      datetime signalTime,
      double   profit,
      double   bkvWasDoIt,
      int      countPartials) : _id(id),
                           _symbol(symbol),
                           _price(price),
                           _sl(sl),
                           _tp(tp),
                           _lot(lot),
                           _type(type),
                           _magic(magic),
                           _comment(comment),
                           _strategy(strategy),
                           _expireTime(expireTime),
                           _signalTime(signalTime),
                           _profit(profit),
                           _bkvWasDoIt(bkvWasDoIt),
                           _countPartials(countPartials) {}

  Order() {}
  ~Order() {}

  // clang-format off
	Order* id(int id){_id=id; return &this;}
	Order* symbol(string symbol){_symbol=symbol; return &this;}
	Order* price(double price){_price=price; return &this;}
	Order* sl(double sl){_sl=sl; return &this;}
	Order* tp(double tp){_tp=tp; return &this;}
	Order* lot(double lot){_lot=lot; return &this;}
	Order* type(int type){_type=type; return &this;}
	Order* magic(int magic){_magic=magic; return &this;}
	Order* comment(string comment){_comment=comment; return &this;}
	Order* expireTime(datetime expireTm){_expireTime=expireTm; return &this;}
	Order* signalTime(datetime signalTm){_signalTime=signalTm; return &this;}
	Order* profit(double profit){_profit=profit; return &this;}
	Order* strategy(string strategy){_strategy=strategy; return &this;}
	Order* tslNext(double tslNext){_tslNext=tslNext; return &this;}
	Order* breakevenWasDoIt(bool bkvWasDoIt){_bkvWasDoIt=bkvWasDoIt; return &this;}
	Order* countPartials(int count){_countPartials=_countPartials + count; return &this;}

   int            id()               { return _id; }
   string         symbol()           { return _symbol; }
   double         price()            { return _price; }
   double         sl()               { return _sl; }
   double         tp()               { return _tp; }
   double         lot()              { return _lot; }
   int            type()             { return _type; }
   int            magic()            { return _magic; }
   string         comment()          { return _comment; }
   string         strategy()         { return _strategy; }
   datetime       expireTime()       { return _expireTime; }
   datetime       signalTime()       { return _signalTime; }
   double         profit()           { if (OrderSelect(_id, SELECT_BY_TICKET)) return OrderProfit(); return -1; }
   double         tslNext()          { return _tslNext; }
   double         breakevenWasDoIt() { return _bkvWasDoIt; }
   int            countPartials()    { return _countPartials; }
};
class FilterBySymbols
{
   string _symbols[];

  public:
   FilterBySymbols(string userSymbols) { getSymbols(userSymbols); }
   ~FilterBySymbols() { ; }

   void getSymbols(string userSymbols)
   {
      string Simbolos[];
      string sep = ",";
      ushort u_sep;
      u_sep = StringGetCharacter(sep, 0);
      int k = StringSplit(userSymbols, u_sep, Simbolos);
      ArrayResize(_symbols, ArrayRange(Simbolos, 0), 0);
      for (int i = 0; i < ArrayRange(Simbolos, 0); i++)
      {
         _symbols[i] = Simbolos[i];
      }
      printSymbols();
   }

   bool control(const string symbolToControl)
   {
      if (ArraySize(_symbols) > 0)
      {
         for (int i = 0; i < ArraySize(_symbols); i++)
         {
            if (_symbols[i] == symbolToControl)
            {
               return true;
            }
         }
      }

      return false;
   }

   void printSymbols()
   {
      for (int i = 0; i < ArraySize(_symbols); i++)
      {
         Print(_symbols[i]);
      }
   }

   //---
};
class FilterByMagics
{
   int _magics[];

  public:
   FilterByMagics(string userMagics) { getMagics(userMagics); }
   ~FilterByMagics() { ; }

   void getMagics(string userMagics)
   {
      string Magicos[];
      string sep = ",";
      ushort u_sep;
      u_sep = StringGetCharacter(sep, 0);
      int k = StringSplit(userMagics, u_sep, Magicos);
      ArrayResize(_magics, ArrayRange(Magicos, 0), 0);
      for (int i = 0; i < ArrayRange(Magicos, 0); i++)
      {
         _magics[i] = (int)Magicos[i];
      }
      if (ArrayRange(_magics, 0) > 0)
      {
         ArraySort(_magics, WHOLE_ARRAY, 0, MODE_ASCEND);
      }
      printMagics();
   }

   bool control(const int magicToControl)
   {
      if (ArraySize(_magics) > 0)
      {			
         int p = ArrayBsearch(_magics, magicToControl, WHOLE_ARRAY, 0, MODE_ASCEND);
			if (_magics[p] == magicToControl)
         {
            return true;
         }
      }

      return false;
   }

   void printMagics()
   {
      for (int i = 0; i < ArraySize(_magics); i++)
      {
         Print(_magics[i]);
      }
   }
  
  
   //---
};
class OrdersList
{
   Order*          orders[];
   bool            _filterByMagicOn;
   bool            _filterBySymbolsOn;
   FilterByMagics* _magics;
   FilterBySymbols* _symbols;

  public:
  OrdersList(){;}
   OrdersList(bool uFilterByMagicOn, string uMagics, bool uFilterBySymbolsOn, string uSymbols)
   {
		_filterByMagicOn = uFilterByMagicOn;
		_filterBySymbolsOn = uFilterBySymbolsOn;
      _magics = new FilterByMagics(uMagics);
      _symbols = new FilterBySymbols(uSymbols);

      Print("New OrderList Created");
   }
   ~OrdersList() 
	{ 
		delete _magics;
		delete _symbols;
		clearList(); 
	}

   // ——————————————————————————————————————————————————————————————————

void setOrdersList(bool magicOn, string magics, bool symbolsOn, string symbols)
{
		_filterByMagicOn = magicOn;
		_filterBySymbolsOn = symbolsOn;
      _magics = new FilterByMagics(magics);
      _symbols = new FilterBySymbols(symbols);

}

   bool AddOrder(Order* order)
   {
      int t = ArraySize(orders);
      if (ArrayResize(orders, t + 1))
      {
         orders[t] = order;
         return true;
      }

      return false;
   }

   // recorrer las ordenes de mercado y agregar las que no estén en el array
   // ——————————————————————————————————————————————————————————————————
   void GetMarketOrders()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (_filterByMagicOn) if (!_magics.control(OrderMagicNumber())) { continue; }
            if (_filterBySymbolsOn) if (!_symbols.control(OrderSymbol())) { continue; }

            if (exist(OrderTicket()) == true) { continue; }

            Order* newOrder = new Order();
            newOrder
                .id(OrderTicket())
                .symbol(OrderSymbol())
                .price(OrderOpenPrice())
                .sl(OrderStopLoss())
                .tp(OrderTakeProfit())
                .lot(OrderLots())
                .type(OrderType())
                .magic(OrderMagicNumber())
                .comment(OrderComment())
                .expireTime(OrderExpiration())
                .profit(OrderProfit())
                .breakevenWasDoIt(false)
                .countPartials(0);

            if (AddOrder(newOrder))
            {
               PrintOrder(i);
            }
         }
      }
   }

   // agrega la última orden si no está en el array
   // ——————————————————————————————————————————————————————————————————
   bool GetLastMarketOrder()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         {
            if (_filterByMagicOn) if(!_magics.control(OrderMagicNumber())) { continue; }
            if (_filterBySymbolsOn) if (!_symbols.control(OrderSymbol())) { continue; }
            if (exist(OrderTicket()) == true) { continue; }

            Order* newOrder = new Order();
            newOrder
                .id(OrderTicket())
                .symbol(OrderSymbol())
                .price(OrderOpenPrice())
                .sl(OrderStopLoss())
                .tp(OrderTakeProfit())
                .lot(OrderLots())
                .type(OrderType())
                .magic(OrderMagicNumber())
                .comment(OrderComment())
                .expireTime(OrderExpiration())
                .profit(OrderProfit())
                .breakevenWasDoIt(false)
                .countPartials(0);

            if (AddOrder(newOrder))
            {
                  Print(__FUNCTION__," ","* Nueva Orden De Mercado * ",id(i), "magic: ",magic(i));
                  // PrintOrder(i);
                  return true;
            }
         }
         return false;
      }
      return false;
   }

   // controlar si el id ya está adentro del array
   // ——————————————————————————————————————————————————————————————————
   bool exist(int id)
   {
      for (int i = qnt() - 1; i >= 0; i--)
      {
         if (id(i) == id)
         {
            return true;
         }
      }
      return false;
   }

   // borra una orden en la posición indicada y acomoda el array
   // ——————————————————————————————————————————————————————————————————
   bool deleteOrder(int index)
   {
      if (notOverFlow(index))
      {
         delete orders[index];
      }

      if (qnt() > index)
      {
         for (int i = index; i < qnt() - 1; i++)
         {
            orders[i] = orders[i + 1];
         }
         ArrayResize(orders, qnt() - 1);
         return true;
      }

      return false;
   }

   // borra todos los elementos de la lista
   // ——————————————————————————————————————————————————————————————————
   void clearList()
   {
      for (int i = 0; i < qnt(); i++)
      {
         if (CheckPointer(orders[i]) != POINTER_INVALID)
         {
            deleteOrder(i);
         }
      }
   }

   // devuelve el puntero a la última orden
   Order* last()
   {
      int lastIndex = ArraySize(orders) - 1;
      if (lastIndex == -1)
      {
         return NULL;
      }
      return GetPointer(orders[lastIndex]);
   }

   Order* index(int in)
   {
      return GetPointer(orders[in]);
   }

   int lastId()
   {
      int lastIndex = ArraySize(orders) - 1;
      return orders[lastIndex].id();
   }

   // ——————————————————————————————————————————————————————————————————
   bool notOverFlow(int index)
   {
      if (index > ArraySize(orders) - 1) return false;
      if (index < 0) return false;
      if (CheckPointer(orders[index]) == POINTER_INVALID) return false;

      return true;
   }

   // cantidad de ordenes guardadas
   // ——————————————————————————————————————————————————————————————————
   int qnt()
   {
      return ArraySize(orders);
   }

   // clang-format off
   // Metodos para acceder a información de cada trade mediante su index:
   // ——————————————————————————————————————————————————————————————————
   int id(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].id();
      }
      return -1;
   }
   string symbol(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].symbol();
      }
      return "";
   }
   double price(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].price();
      }
      return -1;
   }
   double sl(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].sl();
      }
      return -1;
   }
   double tp(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].tp();
      }
      return -1;
   }
   double lot(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].lot();
      }
      return -1;
   }
   int magic(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].magic();
      }
      return -1;
   }
   datetime expire(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].expireTime();
      }
      return -1;
   }
   datetime signalTime(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].signalTime();
      }
      return -1;
   }
   string comment(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].comment();
      }
      return "";
   }
   ENUM_ORDER_TYPE type(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].type();
      }
      return -1;
   }
   double profit(int index)
   {
      if (notOverFlow(index))
      {
         return orders[index].profit();
      }
      return -1;
   }

  // clang-format on

  // comprueba si la orden está cerrada
  // ——————————————————————————————————————————————————————————————————
  bool isClose(int index)
  {
    if (notOverFlow(index))
    {
      if (OrderSelect(id(index), SELECT_BY_TICKET))
      {
        if (OrderCloseTime() != 0) return true;
      }
    }
    return false;
  }

  // borra de la lista los trades cerrados
  // ——————————————————————————————————————————————————————————————————
  void cleanCloseOrders()
  {
    if (qnt() == 0)
    {
      return;
    }

    for (int i = 0; i < qnt(); i++)
    {
      if (isClose(i))
      {
        deleteOrder(i);
      }
    }
  }

  // cierra todas las ordenes en la lista y la limpia, te retorna la cantidad de errores
  int closeAllInList()
  {
    cleanCloseOrders();
    int errors = 0;

    for (int i = 0; i < ArraySize(orders); i++)
    {
      int tk;
      if (isClose(i))
      {
        continue;
      }
      if (CheckPointer(orders[i]) != POINTER_INVALID)
      {
        tk = orders[i].id();
      } else
      {
        continue;
      }
      if (OrderSelect(tk, SELECT_BY_TICKET))
      {
        double ask        = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK);
        double bid        = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID);
        double closePrice = OrderType() == OP_BUY ? bid : ask;
        if (!OrderClose(OrderTicket(), OrderLots(), closePrice, 1000, clrNONE))
        {
          Print(__FUNCTION__, " ", "Error in close order ", orders[i].id(), ": ", GetLastError());
          errors++;
        }
      }
    }

    cleanCloseOrders();

    return errors;
  }

  // ——————————————————————————————————————————————————————————————————
  void PrintOrder(const int index)
  {
    if (!notOverFlow(index))
    {
      return;
    }
    if (CheckPointer(orders[index]) == POINTER_INVALID)
    {
      return;
    }
    // clang-format off
      Print("Order ", index, " id: ",          orders[index].id());
      Print("Order ", index, " symbol: ",      orders[index].symbol());
      Print("Order ", index, " type: ",        orders[index].type());
      Print("Order ", index, " lot: ",         orders[index].lot());
      Print("Order ", index, " price: ",       orders[index].price());
      Print("Order ", index, " sl: ",          orders[index].sl());
      Print("Order ", index, " tp: ",          orders[index].tp());
      Print("Order ", index, " magic: ",       orders[index].magic());
      Print("Order ", index, " comment: ",     orders[index].comment());
      Print("Order ", index, " strategy: ",    orders[index].strategy());
      Print("Order ", index, " expire time: ", orders[index].expireTime());
      Print("Order ", index, " signal time: ", orders[index].signalTime());
      Print("Order ", index, " profit: ",      orders[index].profit());
      Print("Order ", index, " countPartials: ", orders[index].countPartials());
    // clang-format on
  }
  // ——————————————————————————————————————————————————————————————————
  void PrintList()
  {
    for (int i = 0; i < qnt(); i++)
    {
      PrintOrder(i);
    }
  }
};
OrdersList mainOrders(true, (string)magico, true, Symbol());

interface iConditions
{
  bool evaluate();
};
class ConcurrentConditions
{
 protected:
  iConditions* _conditions[];

 public:
  ConcurrentConditions(void) {}
  ~ConcurrentConditions(void) { releaseConditions(); }

  // ——————————————————————————————————————————————————————————————————
  void releaseConditions()
  {
    for (int i = 0; i < ArraySize(_conditions); i++)
    {
      delete _conditions[i];
    }
    ArrayFree(_conditions);
  }
  // ——————————————————————————————————————————————————————————————————
  void AddCondition(iConditions* condition)
  {
    int t = ArraySize(_conditions);
    ArrayResize(_conditions, t + 1);
    _conditions[t] = condition;
  }

  // ——————————————————————————————————————————————————————————————————
  bool EvaluateConditions(void)
  {
    for (int i = 0; i < ArraySize(_conditions); i++)
    {
      if (!_conditions[i].evaluate())
      {
        return false;
      }
    }
    return true;
  }
};
class ConditionMatchPrice : public iConditions
{
  string _symbol;
  string _side;
  double _price;
  int    _mode;  // 0: Ask>=Price & Bid <=Price , 1: Ask <= Price && Bid >= Price

 public:
  ConditionMatchPrice(string Symbol, string Side, double Price, int Mode)
  {
    _symbol = Symbol;
    _side   = Side;
    _price  = Price;
    _mode   = Mode;
  }
  ~ConditionMatchPrice() { ; }

  void   side(string inpside) { _side = inpside; }
  string side(void) { return _side; }
  void   symbol(string inpsymbol) { _symbol = inpsymbol; }
  string symbol(void) { return _symbol; }
  void   price(double inpprice) { _price = inpprice; }
  double price(void) { return _price; }
  void   mode(int inpmode) { _mode = inpmode; }
  int    mode(void) { return _mode; }

  bool evaluate()
  {
    double ask = SymbolInfoDouble(_symbol, SYMBOL_ASK);
    double bid = SymbolInfoDouble(_symbol, SYMBOL_BID);

    if (_mode == 0)
    {
      if (_side == "buy")
      {
        if (ask >= _price)
        {
          return true;
        }
        return false;
      }
      if (_side == "sell")
      {
        if (bid <= _price)
        {
          return true;
        }
        return false;
      }
    }

    if (_mode == 1)
    {
      if (_side == "buy")
      {
        if (ask <= _price)
        {
          return true;
        }
        return false;
      }
      if (_side == "sell")
      {
        if (bid >= _price)
        {
          return true;
        }
        return false;
      }
    }
    return false;
  }
};
class ConditionMaxLot : public iConditions
{
  double _maxLot;
  double _lot;

 public:
  ConditionMaxLot(double MaxLot, double Lot)
  {
    _maxLot = MaxLot;
    _lot    = Lot;
  }
  ~ConditionMaxLot() { ; }
  void lot(double inplot) { _lot = inplot; }

  bool evaluate()
  {
    if (_maxLot >= _lot)
    {
      return true;
    }
    return false;
  }
};
class ConditionOrderCount : public iConditions
{
  OrdersList* _orders;
  int         _maxQnt;

 public:
  ConditionOrderCount(OrdersList* Orders, int MaxQnt)
  {
    _orders = Orders;
    _maxQnt = MaxQnt;
  }
  ~ConditionOrderCount() { ; }

  bool evaluate()
  {
    if (_orders.qnt() < _maxQnt)
    {
      return true;
    }
    return false;
  }
};

interface iActions
{
  bool doAction();
};

class MoveSL : public iActions
{
  Order* _order;
  double _newSL;

 public:
  MoveSL() { ; }
  ~MoveSL() { ; }

  MoveSL* order(Order* or)
  {
    _order = or ;
    return &this;
  }
  MoveSL* newSL(double newSL)
  {
    _newSL = newSL;
    return &this;
  }

  bool controlPointer(Order* or)
  {
    if (CheckPointer(or))
    {
      return true;
    } else
    {
      Print("Order Pointer Invalid");
      return false;
    }
  }

  bool doAction()
  {
    if (!controlPointer(_order))
    {
      Print(__FUNCTION__, " ", "Can't Move Stop Loss");
      return false;
    }
    if (OrderSelect(_order.id(), SELECT_BY_TICKET))
    {
      if (OrderCloseTime() > 0)
      {
        Print(__FUNCTION__, " ", "Order are closed ", _order.id());
        return false;
      }

      if (OrderModify(_order.id(), OrderOpenPrice(), _newSL, OrderTakeProfit(), OrderExpiration(), clrNONE))
      {
        _order.sl(_newSL);
        _order.breakevenWasDoIt(true);
        Print(__FUNCTION__, " ", _order.id(), " Modify: new SL: ", _newSL);
        return true;
      }

    } else
    {
      Print(__FUNCTION__, " ", "Can't Select the order ", _order.id());
    }

    return false;
  }
};
MoveSL* breackevenAction;

class PartialClose : public iActions
{
  Order* _order;
  double _percentToClose;

 public:
  PartialClose() { ; }
  ~PartialClose() { ; }

  PartialClose* order(Order* or)
  {
    _order = or ;
    return &this;
  }
  PartialClose* percent(double percentToClose)
  {
    _percentToClose = percentToClose;
    return &this;
  }

  bool controlPointer(Order* or)
  {
    if (CheckPointer(or))
    {
      return true;
    } else
    {
      Print("Order Pointer Invalid");
      return false;
    }
  }

  double lots()
  {
    // hay que ajustar el lotaje para volverlo al original
    int n = _order.countPartials();
    if (n > 0)
    {
      double originalLots = _order.lot() / (1 - (NormalizeDouble(_percentToClose / 100, 2) * n));
      return NormalizeDouble((originalLots * _percentToClose / 100), 2);
    }

    return NormalizeDouble((_order.lot() * _percentToClose / 100), 2);
  }

  double price()
  {
    double ask = SymbolInfoDouble(_order.symbol(), SYMBOL_ASK);
    double bid = SymbolInfoDouble(_order.symbol(), SYMBOL_BID);

    if (_order.type() == OP_BUY)
    {
      return bid;
    }
    if (_order.type() == OP_SELL)
    {
      return ask;
    }
    return 0;
  }

  bool doAction()
  {
    if (!controlPointer(_order))
    {
      Print(__FUNCTION__, " ", "Can't Take Partial");
      return false;
    }
    if (OrderSelect(_order.id(), SELECT_BY_TICKET))
    {
      if (OrderCloseTime() > 0)
      {
        Print(__FUNCTION__, " ", "Order are closed ", _order.id());
        return false;
      }

      if (OrderClose(_order.id(), lots(), price(), 10000, clrNONE))
      {
        // aumenta el contador de parciales
        _order.countPartials(1);

        // remplazar el tk por el nuevo tk
        changeTk(_order.id());

        Print(__FUNCTION__, " ", _order.id(), " Partial TP taked ");
        return true;
      }

    } else
    {
      Print(__FUNCTION__, " ", "Can't Select the order ", _order.id());
    }

    return false;
  }

  void changeTk(int tk)
  {
    if (OrderSelect(tk, SELECT_BY_TICKET))
    {
      datetime dt     = OrderCloseTime();
      string   coment = OrderComment();
      int      pos    = StringFind(coment, "#") + 1;
      string   newId  = StringSubstr(coment, pos, StringLen(coment));
      _order.id((int)newId);
    }
  }
};
PartialClose* partialCloseAction;

class SendNewOrder : public iActions
{
 private:
  Order* newOrder;

 public:
  SendNewOrder(string side, double lots, string symbol = "", double price = 0, double sl = 0, double tp = 0, int magic = 0, string coment = "", datetime expire = 0)
  {
    string _symbol = setSymbol(symbol);
    double _price  = setPrice(side, price, _symbol);
    int    _type   = SetType(side, price, _symbol);
    if (_type == -1)
    {
      Print(__FUNCTION__, " ", "Imposible to set OrderType");
      return;
    }

    newOrder = new Order();

    newOrder
        .id(OrderTicket())
        .symbol(_symbol)
        .type(_type)
        .price(_price)
        .sl(sl)
        .tp(tp)
        .lot(lots)
        .magic(magic)
        .comment(coment)
        .expireTime(expire)
        .profit(0);
  }

  ~SendNewOrder()
  {
    delete newOrder;
  }

  string setSymbol(string sim)
  {
    if (sim == "")
    {
      return Symbol();
    }
    return sim;
  }

  double setPrice(string side, double pr, string sym)
  {
    if (pr == 0)
    {
      if (side == "buy")
      {
        return SymbolInfoDouble(sym, SYMBOL_ASK);
      }
      if (side == "sell")
      {
        return SymbolInfoDouble(sym, SYMBOL_BID);
      }
    }

    return pr;
  }

  int SetType(string side, double priceClient, string sym)
  {
    double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
    double bid = SymbolInfoDouble(sym, SYMBOL_BID);

    if (priceClient == 0)
    {
      if (side == "buy")
      {
        return (int)OP_BUY;
      }
      if (side == "sell")
      {
        return (int)OP_SELL;
      }
    } else
    {
      if (side == "buy")
      {
        if (priceClient > ask)
        {
          return (int)OP_BUYSTOP;
        }
        if (priceClient < ask)
        {
          return (int)OP_BUYLIMIT;
        }
      }
      if (side == "sell")
      {
        if (priceClient > bid)
        {
          return (int)OP_SELLLIMIT;
        }
        if (priceClient < bid)
        {
          return (int)OP_SELLSTOP;
        }
      }
    }

    return -1;
  }

  bool doAction()
  {
    int tk = OrderSend(newOrder.symbol(), newOrder.type(), newOrder.lot(), newOrder.price(), 1000, newOrder.sl(), newOrder.tp(), newOrder.comment(), newOrder.magic(), newOrder.expireTime(), clrNONE);

    if (tk < 0)
    {
      Print(__FUNCTION__, " ", "Connot Send Order, error: ", GetLastError());
      return false;
    }

    return true;
  }

  Order* lastOrder()
  {
    return GetPointer(newOrder);
  }
};
SendNewOrder* actionSendOrder;

// GRID
// ——————————————————————————————————————————————————————————————————
class Grid
{
  ConcurrentConditions conditionsToOpenNewTrade;
  ConcurrentConditions conditionsToCloseGrid;
  ConditionMatchPrice* cdMatchPrice;
  ConditionOrderCount* cdMaxOrders;
  ConditionMaxLot*     cdMaxLot;
  SendNewOrder*        openTrade;
  // ActionCloseOrdersByType* actionCloseGrid;
  string     _symbol;
  string     _side;
  double     _nextPrice;
  double     _lastPrice;
  double     _gap;
  double     _multiplier;
  int        _maxQnt;
  double     _maxLot;
  double     _initialLot;
  double     _nextLot;
  int        _qnt;
  bool       _active;
  int        _magico;
 public:
  OrdersList gridOrders;

 public:
  Grid(string Symbol, string Side, double LastPrice, double Gap, double Multiplier, int MaxQnt, double MaxLot, double InitialLot, int magic, bool simbolFilterOn = true, bool magicFilterOn = true)
  {
    _symbol     = Symbol;
    _side       = Side;
    _lastPrice  = LastPrice;
    _gap        = Gap;
    _nextPrice  = nextPrice(LastPrice);
    _multiplier = Multiplier;
    _maxQnt     = MaxQnt + 1;
    _maxLot     = MaxLot;
    _initialLot = InitialLot;
    _nextLot    = nextLot();
    _magico     = magic;

    Print(_symbol);
    Print(_side);
    Print(_lastPrice);
    Print(_nextPrice);
    Print(_gap);
    Print(_multiplier);
    Print(_maxQnt);
    Print(_maxLot);
    Print(_initialLot);
    Print(_nextLot);

    gridOrders.setOrdersList(magicFilterOn, IntegerToString(_magico), simbolFilterOn, _symbol);
    gridOrders.GetLastMarketOrder();

    // Set Conditions:
    cdMatchPrice = new ConditionMatchPrice(_symbol, _side, _nextPrice, 1);
    cdMaxOrders  = new ConditionOrderCount(GetPointer(gridOrders), _maxQnt);
    cdMaxLot     = new ConditionMaxLot(_maxLot, _nextLot);

    cdMaxLot.lot(_nextLot);
    cdMatchPrice.price(_nextPrice);

    conditionsToOpenNewTrade.AddCondition(cdMatchPrice);
    conditionsToOpenNewTrade.AddCondition(cdMaxOrders);
    conditionsToOpenNewTrade.AddCondition(cdMaxLot);
  }
  ~Grid()
  {
    delete cdMatchPrice;
    delete cdMaxOrders;
    delete cdMaxLot;
    delete openTrade;
  }

  void lastPrice(int inplastPrice) { _lastPrice = inplastPrice; }
  bool active(void)
  {
    // si la primer orden está en perdidas:
    if (gridOrders.profit(0) < 0)
    {
      _active = true;
    } else
    {
      _active = false;
    }
    return _active;
  }
  double nextPrice(double inpLastPrice)
  {
    double mPoint = MarketInfo(_symbol, MODE_POINT);

    if (_side == "buy") _nextPrice = inpLastPrice - (_gap * mPoint * 10);
    if (_side == "sell") _nextPrice = inpLastPrice + (_gap * mPoint * 10);

    return _nextPrice;
  }
  void   gap(double inpGap) { _gap = inpGap; }
  void   multiplier(double inpmultiplier) { _multiplier = inpmultiplier; }
  void   maxQnt(int inpmaxQnt) { _maxQnt = inpmaxQnt; }
  void   maxLot(double inpmaxLot) { _maxLot = inpmaxLot; }
  double maxLot() { return _maxLot; }
  void   side(string inpside) { _side = inpside; }
  void   symbol(string inpsymbol) { _symbol = inpsymbol; }
  int    qnt()
  {
    return gridOrders.qnt();
  }
  double nextLot(void)
  {
    return NormalizeDouble(_initialLot * pow(_multiplier, qnt()), 2);
  };

  double profit()
  {
    double gridResult = 0;
    Print(__FUNCTION__, " ", "qnt()", " ", qnt());

    for (int i = 0; i < qnt(); i++)
    {
      if (CheckPointer(gridOrders.index(i)) != POINTER_INVALID)
        gridResult += gridOrders.profit(i);

      Print(__FUNCTION__, " ", "gridResult", " ", gridResult);
    }
    return gridResult;
  }

  void doGrid()
  {
    if (conditionsToOpenNewTrade.EvaluateConditions())
    {
      if (_side == "buy")
      {
        openTrade = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), _magico);
        if (openTrade.doAction())
        {
          Print("pointer de la ultima orden: ", openTrade.lastOrder());
          // if (gridOrders.AddOrder(openTrade.lastOrder()))
          if (gridOrders.GetLastMarketOrder())
            setNextTrade();
        }
        delete openTrade;
      }

      if (_side == "sell")
      {
        openTrade = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), _magico);
        if (openTrade.doAction())
        {
          // Print("pointer de la ultima orden: ", openTrade.lastOrder());
          // if (gridOrders.AddOrder(openTrade.lastOrder()))
          if (gridOrders.GetLastMarketOrder())
            setNextTrade();
        }
        delete openTrade;
      }
    }
  }

  void setNextTrade()
  {
    nextPrice(gridOrders.last().price());
    // Print(__FUNCTION__, " ", "nextPrice: ", " ", _nextPrice);
    cdMaxLot.lot(nextLot());
    // Print(__FUNCTION__, " ", "nextLot()", " ", nextLot());
    cdMatchPrice.price(_nextPrice);
  }

  double Lots()
  {
    return nextLot();
  }

  double SL(string side)
  {
    return 0;
  }
  double TP(string side)
  {
    return 0;
  }

  void closeGrid()
  {
    gridOrders.cleanCloseOrders();
    if (qnt() == 0)
    {
      return;
    }

    int attempts = 0;
    while (gridOrders.closeAllInList() != 0 || attempts < 10)
    {
      attempts++;
    }
  }
};
Grid* gridBuy;
Grid* gridSell;



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