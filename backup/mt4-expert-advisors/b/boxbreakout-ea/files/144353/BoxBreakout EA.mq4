// More information about this indicator can be found at:
// http://fxcodebase.com/ 

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
//|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
//|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
//|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict


// Schedule Controller
//+------------------------------------------------------------------+
enum enumDays { sunday,
                monday,
                tuesday,
                wednesday,
                thursday,
                friday,
                saturday,
                EA_OFF };

input string   THorarios = "Daily Control";  // ** Daily Control **
input enumDays days0     = sunday;           // Day:
input string   iniTm0    = "00:00";          // Initial Time:
input string   endTm0    = "00:00";          // End Time:
input enumDays days1     = monday;           // Day:
input string   iniTm1    = "09:00";          // Initial Time:
input string   endTm1    = "16:00";          // End Time:
input enumDays days2     = tuesday;          // Day:
input string   iniTm2    = "09:00";          // Initial Time:
input string   endTm2    = "16:00";          // End Time:
input enumDays days3     = wednesday;        // Day:
input string   iniTm3    = "09:00";          // Initial Time:
input string   endTm3    = "16:00";          // End Time:
input enumDays days4     = thursday;         // Day:
input string   iniTm4    = "09:00";          // Initial Time:
input string   endTm4    = "16:00";          // End Time:
input enumDays days5     = friday;           // Day:
input string   iniTm5    = "09:00";          // Initial Time:
input string   endTm5    = "16:00";          // End Time:
input enumDays days6     = saturday;         // Day:
input string   iniTm6    = "09:00";          // Initial Time:
input string   endTm6    = "16:00";          // End Time:

enumDays days[7];
string   iniTm[7];
string   endTm[7];

// Gobal Variables
//+------------------------------------------------------------------+
input string hrIni = "00:00";  // Time Initial Box:
input string hrFin = "04:00";  // Time End Box:

datetime     BoxTime_Start;
datetime     BoxTime_End;
bool   ctrlOpenTrade = true;
input bool   ctrlTradesToday = true;// One Trade a day ?
input bool   ctrlSize      = true;  // Control the Size box?
input int    maxSize       = 500;   // Maximum Size Box:
input int    minSize       = 100;   // Minimum Size Box:
input double userLots      = 0.01;  // Lots:

input double SlPer    = 100;  // Stop Loss percent of the Box:
input int    TpPuntos = 50;   // Take Profit pips:

// precios máximo y minimo:
double maxBox = 0;
double minBox = 0;

bool     ActualizarCaja = true;

// Colores:
input color clrCaja      = Blue;   // Box color:
input int   grosorCaja   = 3;      // Width Border Box:
input bool  rellenoCaja  = false;  // Filling:
// input color clrLineas    = Red;    // Lines color:
// input int   grosorLineas = 3;      // Width Lines:

//--- Magic Number
input int magico = 4321;

//////////////////////////////////////////////////////////////////////
int OnInit()
{
   //--- Set Conditions:
   if (ctrlSize) conditions.AddCondition(condition_SizeBox = new ConditionSizeBox());
   if (ctrlOpenTrade) conditions.AddCondition(condition_OpenTrades = new ConditionOpenTrades());
   if (ctrlTradesToday) conditions.AddCondition(condition_TradesToday = new MadeTradesToday());
   conditionsToBuy.AddCondition(up = new ConditionBreakoutUp() );
   conditionsToSell.AddCondition(down = new ConditionBreakoutDown() );

   //--- Set Schedules:
   setSchedules();

   // Print(__FUNCTION__, " ", "TimeGMT:", " ", TimeGMT());
   getHoras();
   EventSetTimer(1);

   return (INIT_SUCCEEDED);
}


void OnDeinit(const int reason)
{
   CleanChart();
   conditions.releaseConditions();
   conditionsToBuy.releaseConditions();
   conditionsToSell.releaseConditions();
   delete condition_OpenTrades;
   delete condition_TradesToday;
}


void OnTick()
{
   ReStart();
   if((maxBox==0 || minBox==0) && TimeGMT() > BoxTime_End )
   { 
      SetBox();
      DrawBox();
   }
   
   if (schedule.doDailyControl())
   {
      if (conditions.EvaluateConditions())
      {
         if (conditionsToBuy.EvaluateConditions())
         {
            OpenTrade(0, userLots);
         }
         if (conditionsToSell.EvaluateConditions())
         {
            OpenTrade(1, userLots);
         }
      }
   }
}

void ReStart()
{
   if(schedule.isNewDay())
   {
      CleanChart();
      resetBox();
      getHoras();
      Print(__FUNCTION__, " ", "Start new day:", " ", TimeGMT());
   }
}

void resetBox()
{
   maxBox        = 0;
   minBox        = 0;
   ActualizarCaja = true;
}

void OnTimer(void)
{
}

//////////////////////////////////////////////////////////////////////

void CleanChart()
{
   ObjectDelete(0, "Box");
   ObjectDelete(0, "Max");
   ObjectDelete(0, "Min");
}

//+------------------------------------------------------------------+
void getHoras()
{
   BoxTime_Start = StringToTime(hrIni); 
   BoxTime_End   = StringToTime(hrFin);

   // Print(__FUNCTION__, " ", "BoxTime_Start", " ", BoxTime_Start);
   // Print(__FUNCTION__, " ", "BoxTime_End", " ", BoxTime_End);
}

//+------------------------------------------------------------------+
void SetBox()
{
   double ctrlMax = maxBox;  

   // if (TimeGMT() > BoxTime_End && ActualizarCaja == true)
   if (TimeGMT() > BoxTime_End)
   {
      // buscar max y min:
      int minutos = ((int)BoxTime_End - (int)BoxTime_Start) / 60;
      
      // recorrer todos los minutos desde el fin al inicio de la caja y registrar max y min
      int barIni = iBarShift(NULL, 1, BoxTime_End);

      for (int i = barIni; i < barIni + minutos; i++)
      {
         if (maxBox == 0 || iHigh(NULL, 1, i) > maxBox)
         {
            maxBox = iHigh(NULL, 1, i);
         }
         if (minBox == 0 || iLow(NULL, 1, i) < minBox)
         {
            minBox = iLow(NULL, 1, i);
         }
      }
   }

   if (maxBox != ctrlMax)
   {
      Print(__FUNCTION__, " ", "maxBox", " ", maxBox);
      Print(__FUNCTION__, " ", "minBox", " ", minBox);
   }
}

//+------------------------------------------------------------------+
void DrawBox()
{
   //   ObjectCreate(chart_ID, name, OBJ_RECTANGLE, sub_window, time1, price1, time2, price2);
   ObjectDelete(0, "Box");
   ObjectCreate(0, "Box", OBJ_RECTANGLE, 0, BoxTime_Start, maxBox, BoxTime_End, minBox);
   ObjectSetInteger(0, "Box", OBJPROP_COLOR, clrCaja);
   ObjectSetInteger(0, "Box", OBJPROP_WIDTH, grosorCaja);
   ObjectSetInteger(0, "Box", OBJPROP_FILL, rellenoCaja);
   ObjectSetInteger(0, "Box", OBJPROP_BACK, false);

   // ObjectCreate(0, "Max", OBJ_HLINE, 0, 0, maxBox);
   // ObjectCreate(0, "Min", OBJ_HLINE, 0, 0, minBox);

   // ObjectSetInteger(0, "Max", OBJPROP_COLOR, clrLineas);
   // ObjectSetInteger(0, "Max", OBJPROP_WIDTH, grosorLineas);
   // ObjectSetInteger(0, "Min", OBJPROP_COLOR, clrLineas);
   // ObjectSetInteger(0, "Min", OBJPROP_WIDTH, grosorLineas);
}

bool OpenTrade(int type, double lots)
{
   if (type == OP_BUY)
   {
      int clr = OrderSend(Symbol(), OP_BUY, lots, Ask, 1000, SetSL(Ask, OP_BUY), SetTP(Ask, OP_BUY), NULL, magico, 0, clrNONE);
      if (clr > 0)
      {
         return true;
      }
   }

   if (type == OP_SELL)
   {
      int clr = OrderSend(Symbol(), OP_SELL, lots, Bid, 1000, SetSL(Bid, OP_SELL), SetTP(Bid, OP_SELL), NULL, magico, 0, clrNONE);
      if (clr > 0)
      {
         return true;
      }
   }

   return false;
}

double SetTP(double entryPrice, ENUM_ORDER_TYPE tipo)
{
   //--- tamaño:
   double mPoint = MarketInfo(Symbol(), MODE_POINT);
   double size   = (maxBox - minBox);

   if (tipo == OP_BUY)
   {
      return entryPrice + TpPuntos * 10 * mPoint;
   }
   if (tipo == OP_SELL)
   {
      return entryPrice - TpPuntos * 10 * mPoint;
   }

   return 0;
}

double SetSL(double entryPrice, ENUM_ORDER_TYPE tipo)
{
   //--- tamaño:
   double mPoint = MarketInfo(Symbol(), MODE_POINT);
   double size   = (maxBox - minBox);

   if (tipo == OP_BUY)
   {
      return NormalizeDouble((maxBox - (size * (SlPer / 100))),_Digits);
   }
   if (tipo == OP_SELL)
   {
      return NormalizeDouble((minBox + (size * (SlPer / 100))),_Digits);
   }

   return 0;
}

////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
// Sessions Controller
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

void setSchedules()
{
   days[0]  = days0;
   iniTm[0] = iniTm0;
   endTm[0] = endTm0;
   days[1]  = days1;
   iniTm[1] = iniTm1;
   endTm[1] = endTm1;
   days[2]  = days2;
   iniTm[2] = iniTm2;
   endTm[2] = endTm2;
   days[3]  = days3;
   iniTm[3] = iniTm3;
   endTm[3] = endTm3;
   days[4]  = days4;
   iniTm[4] = iniTm4;
   endTm[4] = endTm4;
   days[5]  = days5;
   iniTm[5] = iniTm5;
   endTm[5] = endTm5;
   days[6]  = days6;
   iniTm[6] = iniTm6;
   endTm[6] = endTm6;

   for (int i = 0; i < 7; i++)
   {
      int day = (int)days[i];
      schedule.AddSession(day, iniTm[i], endTm[i]);
   }
}

class Session
{
   int _dayNumber;
   int _iniTime;  // second from 00:00 hr of the day
   int _endTime;

  public:
   // receive time in format 00:00
   Session(int dayNumber, string iniTime, string endTime)
   {
      _dayNumber = dayNumber;
      _iniTime   = secondsFromZeroHour(iniTime);
      _endTime   = secondsFromZeroHour(endTime);
   };

   ~Session() {}

   int dayNumber() { return _dayNumber; }
   int iniTime() { return _iniTime; }
   int BoxTime_End() { return _endTime; }

   int secondsFromZeroHour(string time)
   {
      int hh = (int)StringSubstr(time, 0, 2);
      int mm = (int)StringSubstr(time, 3, 2);

      return (hh * 3600) + (mm * 60);
   }
};

//--- v 2.0
class ScheduleController
{
   Session* schedules[];
   int      _actualIndex;
   Session* _actualSession;
   int      _currentDay;
   

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
   
   void setCurrentDay()
   {
      _currentDay = TimeDay(TimeGMT()); // return the day of the month 0-31      
   }


   bool isNewDay()
   {
      if(TimeDay(TimeGMT()) != _currentDay)   
      {
         setCurrentDay();
         return true;
      }

      return false;
   }
   
   
   //+------------------------------------------------------------------+
   void setActualSession(int index)
   {
      _actualIndex = index;

      if (index > -1)
      {
         _actualSession = schedules[index];
      }
   }
   //+------------------------------------------------------------------+
   int qnt()
   {
      return ArraySize(schedules);
   }

   //+------------------------------------------------------------------+
   bool AddSession(int day, string ini, string end)
   {
      Session* sc = new Session(day, ini, end);
      int      t  = qnt();
      if (ArrayResize(schedules, t + 1))
      {
         schedules[t] = sc;
         return true;
      }

      return false;
   }

   //+------------------------------------------------------------------+
   bool ClearShchedules()
   {
      for (int i = 0; i < qnt(); i++)
      {
         delete schedules[i];
      }
      ArrayFree(schedules);

      return true;
   }

   //+------------------------------------------------------------------+
   bool doDailyControl()
   {
      Comment("Daily Control - EA OFF");

      int actual = (TimeHour(TimeGMT()) * 3600) + (TimeMinute(TimeGMT()) * 60);

      for (int i = 0; i < qnt(); i++)
      {
         if (schedules[i].dayNumber() == EA_OFF)
         {
            return false;
         }

         if (schedules[i].dayNumber() == TimeDayOfWeek(TimeGMT()))
         {
            if ((actual >= schedules[i].iniTime()) && actual <= schedules[i].BoxTime_End())
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

   //+------------------------------------------------------------------+
   void PrintDays()
   {
      for (int i = 0; i < qnt(); i++)
      {
         PrintDay(i);
      }
   }

   //+------------------------------------------------------------------+
   void PrintDay(int i)
   {
      Print("Day Nr: ", schedules[i].dayNumber());
      Print("Day Ini Time: ", schedules[i].iniTime());
      Print("Day End Time: ", schedules[i].BoxTime_End());
   }
};
ScheduleController schedule;


//+------------------------------------------------------------------+
//| Conditions 
//+------------------------------------------------------------------+
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
   ~ConcurrentConditions(void)
   {
      releaseConditions();
   }

//+------------------------------------------------------------------+
void releaseConditions()
{
    for (int i = 0; i < ArraySize(_conditions); i++)
      {
            delete _conditions[i];
            ArrayFree(_conditions);
      }
}
//+------------------------------------------------------------------+
   void AddCondition(iConditions* condition)
   {
      int t = ArraySize(_conditions);
      ArrayResize(_conditions, t + 1);
      _conditions[t] = condition;
   }

//+------------------------------------------------------------------+
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

ConcurrentConditions conditions;
ConcurrentConditions conditionsToBuy;
ConcurrentConditions conditionsToSell;

class ConditionSizeBox : public iConditions
{
  public:
   bool evaluate()
   {
      double mPoint = MarketInfo(Symbol(), MODE_POINT);
      double size   = (maxBox - minBox) / mPoint;
      if (size > maxSize || size < minSize)
      {
         // Print(__FUNCTION__, " ", "SizeBox", " false");
         return false;
      }

      // Print(__FUNCTION__, " ", "SizeBox", " true");
      return true;
   }
};
ConditionSizeBox* condition_SizeBox;

class MadeTradesToday : public iConditions
{
  public:
   bool evaluate()
   {
   for (int i = OrdersHistoryTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _Symbol)
      {
         // si llegó a ordenes de ayer, salir:
         if (TimeDay(OrderOpenTime()) != TimeDay(TimeGMT()))
         {
            break;
         }

         // comparar día,mes,año:
         if ((TimeDay(OrderOpenTime()) == TimeDay(TimeGMT())) && (TimeMonth(OrderOpenTime()) == TimeMonth(TimeGMT())) )
         {
            if (OrderMagicNumber() == magico)
            {
               // Print("today one trade was open");
               return false;
            }
         }
      }
   }

   return true;
   }
};
MadeTradesToday* condition_TradesToday;

class ConditionOpenTrades : public iConditions
{
  public:
   bool evaluate()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
         {
            // Print(__FUNCTION__, " ", "Open trade");
            return false;
         }
      }

      // Print(__FUNCTION__, " ", "NOT Open trades");
      return true;
   }
};
ConditionOpenTrades* condition_OpenTrades;

class ConditionBreakoutUp : public iConditions
{
  public:
   bool evaluate()
   {
      if (Ask > maxBox && (Ask < maxBox + (50 * _Point)))
      {
         return true;
      }

      return false;
   }
};
ConditionBreakoutUp* up;

class ConditionBreakoutDown : public iConditions
{
  public:
   bool evaluate()
   {
      if (Bid < minBox && (Bid > minBox - (50 * _Point)))
      {
         return true;
      }
      return false;
   }
};
ConditionBreakoutDown* down;

