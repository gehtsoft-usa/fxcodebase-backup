// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=155310#p155310

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3
#property indicator_label1 "Section"
#property indicator_label2 "Map Highs"
#property indicator_label3 "Map Lows"

//--- indicator buffers
double Section [];
double UpMap [];
double DnMap [];

// ------------------------------------------------------------------
input string             Irsi = "== RSI Setup ==";  // == RSI Setup ==
input int                rsiPeriod = 7;                 // Period
input ENUM_APPLIED_PRICE rsiAppliedPrice = PRICE_CLOSE;        // Applied Price
input double             rsiLevelUp = 70;                 // RSI Level Over Bougth
input double             rsiLevelDn = 30;                 // RSI Level Over Sold

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class RSI
  {
   string            _symbol;
   int               _tf;
   double            _levelUp;
   double            _levelDn;

   struct RSIparameters
     {
      int            setup0;  //  Period
      int            setup1;  //  Applied Price
     };
   RSIparameters     _setup;

public:
                     RSI()
     {
      _symbol = Symbol();
      _tf = Period();
     }

                     RSI(string Symbol, int TimeFrame)
     {
      _symbol = Symbol;
      _tf = TimeFrame;
     }
                    ~RSI() { ; }

   void              setSetup(int set0, int set1, double LevelUp = 70, double LevelDn = 30)
     {
      _setup.setup0 = set0;
      _setup.setup1 = set1;
      _levelUp = LevelUp;
      _levelDn = LevelDn;
     }

   double            calculate(int buffer, int shift)
     {
      return iRSI(_symbol, _tf, _setup.setup0, _setup.setup1, shift);
     }

   double            index(int shift)
     {
      return calculate(0, shift);
     }
   double            lastValue(int buffer, bool candle = false)
     {
      double value = EMPTY_VALUE;
      int    i = 0;
      while(value == EMPTY_VALUE || i == 500)
        {
         value = calculate(buffer, i);
         i++;
        }
      if(candle)
        {
         return i;
        }
      return value;
     }

   bool              isOverBougth(int shift)
     {
      return index(shift) > _levelUp;
     }
   bool              isOverSold(int shift)
     {
      return index(shift) < _levelDn;
     }

   bool              CrossAbove_LevelUp(int shift)
     {
      if(index(shift) > _levelUp && index(shift + 1) <= _levelUp)
         return true;
      return false;
     }
   bool              CrossBelow_LevelUp(int shift)
     {
      if(index(shift) < _levelUp && index(shift + 1) >= _levelUp)
         return true;
      return false;
     }

   bool              CrossBelow_LevelDn(int shift)
     {
      if(index(shift) < _levelDn && index(shift + 1) >= _levelDn)
         return true;
      return false;
     }
   bool              CrossAbove_LevelDn(int shift)
     {
      if(index(shift) > _levelDn && index(shift + 1) <= _levelDn)
         return true;
      return false;
     }
  };
RSI* rsi;

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CNewCandle
  {
private:
   int               _initialCandles;
   string            _symbol;
   int               _tf;

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

   bool              IsNewCandle()
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

// ------------------------------------------------------------------
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, Section, INDICATOR_DATA);
   SetIndexStyle(0, DRAW_SECTION, EMPTY, 1, Blue);
   SetIndexBuffer(1, UpMap, INDICATOR_DATA);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(2, DnMap, INDICATOR_DATA);
   SetIndexStyle(2, DRAW_NONE);
   rsi = new RSI();
   rsi.setSetup(rsiPeriod, rsiAppliedPrice, rsiLevelUp, rsiLevelDn);
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "label");
  }

struct Trend
  {
   int               Current;
   int               Last;
  };
Trend trend;

double lastHigh;
double lastLow;

// ------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   int i = rates_total - (prev_calculated + rsiPeriod + 1);
   if(i >= rates_total)
      i = rates_total - 1;
   for(i = 1000; i > 0; i--)
     {
      if(rsi.isOverBougth(i))
        {
         trend.Current = 1;
         if(trend.Current == trend.Last)
           {
            if((High[i] > lastHigh))
              {
            //   deleteLastHigh(i);
               uploadHigh(i, high[i]);
             //  PutLabelHigh(time[i]);
              }
           }
         else
           {
            uploadHigh(i, high[i]);
            trend.Last = 1;
            lastLow = 0;
           // PutLabelHigh(time[i]);
           }
         /*if(newCandle.IsNewCandle())
           {
            Notifications(0);
           }*/
        }
      if(rsi.isOverSold(i))
        {
         trend.Current = -1;
         if(trend.Current == trend.Last)
           {
            if((low[i] < lastLow))
              {
            //   deleteLastLow(i);
               uploadLow(i, low[i]);
             //  PutLabelLow(time[i]);
              }
           }
         else
           {
            uploadLow(i, low[i]);
            trend.Last = -1;
            lastHigh = 0;
         //   PutLabelLow(time[i]);
           }
        /* if(newCandle.IsNewCandle())
           {
            Notifications(1);
           }*/
        }
     }
   return (rates_total);
  }

// ------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void uploadHigh(int i, double value)
  {
   lastHigh = value;
   Section[i] = value;
   UpMap[i] = value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deleteLastHigh(int i)
  {
   int n = i + 1;
   while(Section[n] == EMPTY_VALUE)
     {
      n++;
     }
   Section[n] = EMPTY_VALUE;
   UpMap[n] = EMPTY_VALUE;
   ObjectDelete(0, "label" + (string)n);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void uploadLow(int i, double value)
  {
   lastLow = value;
   Section[i] = value;
   DnMap[i] = value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deleteLastLow(int i)
  {
   int n = i + 1;
   while(Section[n] == EMPTY_VALUE)
     {
      n++;
     }
   Section[n] = EMPTY_VALUE;
   DnMap[n] = EMPTY_VALUE;
   ObjectDelete(0, "label" + (string)n);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutLabelHigh(datetime tm)
  {
   int shift = iBarShift(Symbol(), 0, tm);
   string nm = "label" + (string)shift;
   double pr = iHigh(NULL, 0, shift);
   string tx = isHH(shift) ? "HH" : "LH";
   CreateLabel(nm, tm, pr, tx, Green);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutLabelLow(datetime tm)
  {
   int shift = iBarShift(Symbol(), 0, tm);
   string nm = "label" + (string) shift;
   double pr = iLow(NULL, 0, shift);
   string tx = isLL(shift) ? "LL" : "HL";
   CreateLabel(nm, tm, pr, tx, Red);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLabel(string nm, datetime tm, double pr, string tx, color cl)
  {
   ObjectCreate(0, nm, OBJ_TEXT, 0, tm, pr);
   ObjectSetString(0, nm, OBJPROP_TEXT, tx);
   ObjectSetString(0, nm, OBJPROP_FONT, "Arial Black");
   ObjectSetInteger(0, nm, OBJPROP_COLOR, cl);
   ENUM_ANCHOR_POINT anchor = cl == Green ? ANCHOR_LOWER : ANCHOR_UPPER;
   ObjectSetInteger(0, nm, OBJPROP_ANCHOR, anchor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isLL(int pos)
  {
   int n = pos + 1;
   while(DnMap[n] == EMPTY_VALUE && n + 1 < ArraySize(DnMap))
     {
      n++;
     }
   return (DnMap[n] > iLow(NULL, 0, pos));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isHH(int pos)
  {
   int n = pos + 1;
   while(UpMap[n] == EMPTY_VALUE && n + 1 < ArraySize(UpMap))
     {
      n++;
     }
   return (UpMap[n] < iHigh(NULL, 0, pos));
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notifications(int type)
  {
   string text = "";
   if(type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " New High ";
   else
      text += _Symbol + " " + GetTimeFrame(_Period) + " New Low ";
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 
