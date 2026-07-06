// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73818

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
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
//--- indicator buffers
double ArrowUp [];
double ArrowDn [];

enum SignalType
{
    Buy, Sell
};
// ------------------------------------------------------------------
input string T0        = "== Trading Sessions ==";  // ————————————
input double   uTimeZone  = 0;                         // Set your GMT zone:
input string timeStart = "16:50";                // Signal Time GMT:
input SignalType signal = Buy; // Signal Mode:
// string timeEnd = "23:59";                // Time End GMT
input string T1 = "== Notifications ==";  // ————————————
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications
input string T2 = "== Set Arrows ==";     // ————————————
input bool   ArrowsOn = true;                   // Arrows On?
input color  ArrowUpClr = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr = clrRed;                 // Arrow Down Color:
// ------------------------------------------------------------------

class CNewCandle
{
    private:
    int    _initialCandles;
    string _symbol;
    int    _tf;

    public:
    CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
    CNewCandle()
    {
        // toma los valores del chart actual
        _initialCandles = iBars(Symbol(), Period());
        _symbol = Symbol();
        _tf = Period();
    }
    ~CNewCandle() { ; }

    bool IsNewCandle()
    {
        int _currentCandles = iBars(_symbol, _tf);
        if(_currentCandles > _initialCandles)
        {
            _initialCandles = _currentCandles;
            return true;
        }

        return false;
    }
};
CNewCandle newCandle();

#define __timer
#ifdef __timer
enum enumDays {
    sunday,
                monday,
                tuesday,
                wednesday,
                thursday,
                friday,
                saturday,
                EA_OFF };

class Session
{
   int _iniTime;  // second from 00:00:00 hr of the day
   int _endTime;
   int _dayNumber;

  public:
   // receive time in format 00:00:00
   Session(string iniTime, string endTime, int dayNumber = 0)
   {
      _iniTime   = secondsFromZeroHour(iniTime);
      Print(__FUNCTION__," _iniTime: ",_iniTime);
      _endTime   = secondsFromZeroHour(endTime)+60;
      Print(__FUNCTION__," _endTime: ",_endTime);
      _dayNumber = dayNumber;
   };

   ~Session() {}

   int iniTime()   { return _iniTime; }
   int endTime()   { return _endTime; }
   int dayNumber() { return _dayNumber; }

   int secondsFromZeroHour(string time)
   {
      int hh = (int)StringSubstr(time, 0, 2);
      int mm = (int)StringSubstr(time, 3, 2);
      int ss = (int)StringSubstr(time, 6, 2);

      return (hh * 3600) + (mm * 60) + (ss);
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

   bool AddSession(string ini, string end, int day = -1)
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
      datetime eaTime = TimeGMT() + _timeZone;
      Comment(eaTime + " Timer Control - EA OFF");

      int actual = TimeHour(eaTime) * 3600 + TimeMinute(eaTime) * 60 + TimeSeconds(eaTime);

      for (int i = 0; i < qnt(); i++)
      {
         if (schedules[i].dayNumber() == EA_OFF)
         {
            continue;
         }

         if (schedules[i].dayNumber() != -1)
         {
            if (schedules[i].dayNumber() == TimeDayOfWeek(TimeGMT() + _timeZone))
            {
               if ((actual >= schedules[i].iniTime()) && actual < schedules[i].endTime())
               {
                  setActualSession(i);
                  Comment(eaTime + " Timer Control - EA ON");
                  return true;
               }
            }
         }

         if (schedules[i].dayNumber() == -1)
         {
            if ((actual >= schedules[i].iniTime()) && actual < schedules[i].endTime())
            {
               setActualSession(i);
               Comment(eaTime + " Timer Control - EA ON");
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

// ------------------------------------------------------------------
int OnInit()
{
    EventSetTimer(1);
    //--- indicator buffers mapping
    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(1, 234);
    if(!ArrowsOn)
    {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }

    //---
    sesionControl.setTimeZone(uTimeZone);
    sesionControl.AddSession(timeStart, timeStart);
    
    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}

// ------------------------------------------------------------------
// NOTE: OnCalcu
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time [],
                const double& open [],
                const double& high [],
                const double& low [],
                const double& close [],
                const long& tick_volume [],
                const long& volume [],
                const int& spread [])
{
    int i = 0;
    if(signal == Buy)
        if(haveSignalUp(i))
        {
            ArrowUp[i] = Low[i];
            Notifications(0);
        }
        
    if(signal == Sell)
        if(haveSignalDown(i))
        {
            ArrowDn[i] = High[i];
            Notifications(1);
        }

    return (rates_total);
}

// ------------------------------------------------------------------
bool haveSignalUp(int i)
{
    // TODO: signal up
    return sesionControl.doSessionControl();
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    return sesionControl.doSessionControl();
}

void Notifications(int type)
{
    string text = "";
    if(type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

    text += " ";

    if(!notifications)
        return;
    if(desktop_notifications)
        Alert(text);
    if(push_notifications)
        SendNotification(text);
    if(email_notifications)
        SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch(lPeriod)
    {
        case PERIOD_M1:
            return ("M1");
        case PERIOD_M5:
            return ("M5");
        case PERIOD_M15:
            return ("M15");
        case PERIOD_M30:
            return ("M30");
        case PERIOD_H1:
            return ("H1");
        case PERIOD_H4:
            return ("H4");
        case PERIOD_D1:
            return ("D1");
        case PERIOD_W1:
            return ("W1");
        case PERIOD_MN1:
            return ("MN1");
    }
    return IntegerToString(lPeriod);
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