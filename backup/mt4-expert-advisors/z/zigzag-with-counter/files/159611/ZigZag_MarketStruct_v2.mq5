// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71190&p=149035#p149035

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 5

//--- input parameters
input string T0                    = "== ZigZag Setup ==";  // ZigZag Setup
input bool   zzOn                  = true;                  // Draw ZigZag Line?
input int    ExtDepth              = 12;
input int    ExtDeviation          = 5;
input int    ExtBackstep           = 3;
input color  zzClr                 = Navy;                   // ZigZag Color
input string T1                    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:
input string T3                    = "== Set LL Arrows ==";     // Set LL Arrows
input bool   ArrowsLLOn              = true;                   // Arrows LLOn?
input color  ArrowLLClr            = clrYellow;                // Arrow LL Color:
input string T2                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications

//--- indicator buffers
double ZigzagBuffer[];   // main buffer
double HighMapBuffer[];  // highs
double LowMapBuffer[];   // lows
double BMSup[];
double BMSdn[];
double LLarr[];


int    level = 3;  // recounting depth
double deviation;  // deviation in points
string ObjPrefix         = "ZigZag";
color  Text_color_Top    = LimeGreen;
color  Text_color_Bottom = Red;
double vShift            = 5;  // Vertical Label shift

struct zzPoint
  {
   double            price;
   int               candle;
  };
zzPoint points[];
int     Notification_last_candle;

// ------------------------------------------------------------------

// ------------------------------------------------------------------
class CNewCandle
  {
private:
   int               _initialCandles;
   string            _symbol;
   ENUM_TIMEFRAMES   _tf;

public:
                     CNewCandle(string symbol, ENUM_TIMEFRAMES tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
                     CNewCandle()
     {
      // toma los valores del chart actual
      _initialCandles = iBars(Symbol(), Period());
      _symbol         = Symbol();
      _tf             = Period();
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

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, BMSup, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -20);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, ArrowUpClr);
   SetIndexBuffer(1, BMSdn, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 20);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, ArrowDnClr);
   SetIndexBuffer(2, LLarr, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(2, PLOT_ARROW, 233);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 20);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, ArrowLLClr);
   if(!ArrowsOn)
     {
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
     }
   if(!ArrowsLLOn)
     {
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
     }
//--- ZigZag Setup
   SetIndexBuffer(3, ZigzagBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_SECTION);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, zzClr);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 2);
   PlotIndexSetString(3, PLOT_LABEL, "ZigZag(" + (string)ExtDepth + "," + (string)ExtDeviation + "," + (string)ExtBackstep + ")");
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0.0);
   SetIndexBuffer(4, HighMapBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, LowMapBuffer, INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   if(!zzOn)
     {
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
     }
//--- to use in cycle
   deviation = ExtDeviation * _Point;
//---
   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, ObjPrefix);
  }
//+------------------------------------------------------------------+
//|  searching candle of the highest bar                              |
//+------------------------------------------------------------------+
int iHighest(const double& array[],
             int           depth,
             int           startPos)
  {
   int candle = startPos;
//--- start candle validation
   if(startPos < 0)
     {
      Print("Invalid parameter in the function iHighest, startPos =", startPos);
      return 0;
     }
   int size = ArraySize(array);
//--- depth correction if need
   if(startPos - depth < 0)
      depth = startPos;
   double max = array[startPos];
//--- start searching
   for(int i = startPos; i > startPos - depth; i--)
     {
      if(array[i] > max)
        {
         candle = i;
         max    = array[i];
        }
     }
//--- return candle of the highest bar
   return (candle);
  }
//+------------------------------------------------------------------+
//|  searching candle of the lowest bar                               |
//+------------------------------------------------------------------+
int iLowest(const double& array[],
            int           depth,
            int           startPos)
  {
   int candle = startPos;
//--- start candle validation
   if(startPos < 0)
     {
      Print("Invalid parameter in the function iLowest, startPos =", startPos);
      return 0;
     }
   int size = ArraySize(array);
//--- depth correction if need
   if(startPos - depth < 0)
      depth = startPos;
   double min = array[startPos];
//--- start searching
   for(int i = startPos; i > startPos - depth; i--)
     {
      if(array[i] < min)
        {
         candle = i;
         min    = array[i];
        }
     }
//--- return candle of the lowest bar
   return (candle);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
  {
   int    i     = 0;
   int    limit = 0, counterZ = 0, whatlookfor = 0;
   int    shift = 0, back = 0, lasthighpos = 0, lastlowpos = 0;
   double val = 0, res = 0;
   double curlow = 0, curhigh = 0, lasthigh = 0, lastlow = 0;
//--- auxiliary enumeration
   enum looling_for
     {
      Pike = 1,  // searching for next high
      Sill = -1  // searching for next low
     };
//--- initializing
   if(prev_calculated == 0)
     {
      ArrayInitialize(ZigzagBuffer, 0.0);
      ArrayInitialize(HighMapBuffer, 0.0);
      ArrayInitialize(LowMapBuffer, 0.0);
      ArrayInitialize(BMSdn, 0.0);
      ArrayInitialize(BMSup, 0.0);
      ArrayInitialize(LLarr, 0.0);
     }
//---
   if(rates_total < 100)
      return (0);
//--- set start position for calculations
   if(prev_calculated == 0)
      limit = ExtDepth;
//--- ZigZag was already counted before
   if(prev_calculated > 0)
     {
      i = rates_total - 1;
      //--- searching third extremum from the last uncompleted bar
      while(counterZ < level && i > rates_total - 100)
        {
         res = ZigzagBuffer[i];
         if(res != 0)
            counterZ++;
         i--;
        }
      i++;
      limit = i;
      //--- what type of exremum we are going to find
      if(LowMapBuffer[i] != 0)
        {
         curlow      = LowMapBuffer[i];
         whatlookfor = Pike;
        }
      else
        {
         curhigh     = HighMapBuffer[i];
         whatlookfor = Sill;
        }
      //--- chipping
      for(i = limit + 1; i < rates_total && !IsStopped(); i++)
        {
         ZigzagBuffer[i]  = 0.0;
         LowMapBuffer[i]  = 0.0;
         HighMapBuffer[i] = 0.0;
         BMSdn[i]  = 0.0;
         BMSup[i]  = 0.0;
         LLarr[i] = 0.0;
        }
     }
//--- searching High and Low
   for(shift = limit; shift < rates_total && !IsStopped(); shift++)
     {
      val = low[iLowest(low, ExtDepth, shift)];
      if(val == lastlow)
         val = 0.0;
      else
        {
         lastlow = val;
         if((low[shift] - val) > deviation)
            val = 0.0;
         else
           {
            for(back = 1; back <= ExtBackstep; back++)
              {
               res = LowMapBuffer[shift - back];
               if((res != 0) && (res > val))
                  LowMapBuffer[shift - back] = 0.0;
              }
           }
        }
      if(low[shift] == val)
         LowMapBuffer[shift] = val;
      else
         LowMapBuffer[shift] = 0.0;
      //--- high
      val = high[iHighest(high, ExtDepth, shift)];
      if(val == lasthigh)
         val = 0.0;
      else
        {
         lasthigh = val;
         if((val - high[shift]) > deviation)
            val = 0.0;
         else
           {
            for(back = 1; back <= ExtBackstep; back++)
              {
               res = HighMapBuffer[shift - back];
               if((res != 0) && (res < val))
                  HighMapBuffer[shift - back] = 0.0;
              }
           }
        }
      if(high[shift] == val)
         HighMapBuffer[shift] = val;
      else
         HighMapBuffer[shift] = 0.0;
     }
//--- last preparation
   if(whatlookfor == 0)   // uncertain quantity
     {
      lastlow  = 0;
      lasthigh = 0;
     }
   else
     {
      lastlow  = curlow;
      lasthigh = curhigh;
     }
//--- final rejection
   for(shift = limit; shift < rates_total && !IsStopped(); shift++)
     {
      res = 0.0;
      switch(whatlookfor)
        {
         case 0:  // search for peak or lawn
            if(lastlow == 0 && lasthigh == 0)
              {
               if(HighMapBuffer[shift] != 0)
                 {
                  lasthigh            = high[shift];
                  lasthighpos         = shift;
                  whatlookfor         = Sill;
                  ZigzagBuffer[shift] = lasthigh;
                  res                 = 1;
                 }
               if(LowMapBuffer[shift] != 0)
                 {
                  lastlow             = low[shift];
                  lastlowpos          = shift;
                  whatlookfor         = Pike;
                  ZigzagBuffer[shift] = lastlow;
                  res                 = 1;
                 }
              }
            break;
         case Pike:  // search for peak
            if(LowMapBuffer[shift] != 0.0 && LowMapBuffer[shift] < lastlow && HighMapBuffer[shift] == 0.0)
              {
               ZigzagBuffer[lastlowpos] = 0.0;
               lastlowpos               = shift;
               lastlow                  = LowMapBuffer[shift];
               ZigzagBuffer[shift]      = lastlow;
               res                      = 1;
              }
            if(HighMapBuffer[shift] != 0.0 && LowMapBuffer[shift] == 0.0)
              {
               lasthigh            = HighMapBuffer[shift];
               lasthighpos         = shift;
               ZigzagBuffer[shift] = lasthigh;
               whatlookfor         = Sill;
               res                 = 1;
              }
            break;
         case Sill:  // search for lawn
            if(HighMapBuffer[shift] != 0.0 && HighMapBuffer[shift] > lasthigh && LowMapBuffer[shift] == 0.0)
              {
               ZigzagBuffer[lasthighpos] = 0.0;
               lasthighpos               = shift;
               lasthigh                  = HighMapBuffer[shift];
               ZigzagBuffer[shift]       = lasthigh;
              }
            if(LowMapBuffer[shift] != 0.0 && HighMapBuffer[shift] == 0.0)
              {
               lastlow             = LowMapBuffer[shift];
               lastlowpos          = shift;
               ZigzagBuffer[shift] = lastlow;
               whatlookfor         = Pike;
              }
            break;
         default:
            return (rates_total);
        }
     }
// al iniciar y en new candle
   if(prev_calculated == 0)
      for(i = 1000; i > 0 && !IsStopped(); i--)
        {
         LoadPoints(i, 5);
         LabelLastPoint();
         FindBMS(i);
        }
   if(newCandle.IsNewCandle())
     {
      for(i = 100; i > 0 && !IsStopped(); i--)
        {
         LoadPoints(i, 5);
         LabelLastPoint();
         FindBMS(i);
        }
     }
   ArraySetAsSeries(LLarr, true);
   ArraySetAsSeries(ZigzagBuffer, true);
   for(i = rates_total - 1; i >= 0 && !IsStopped(); i--)
     {
      LLarr[i] = 0.0;
      if(ZigzagBuffer[i] == 0.0)
         continue;
      if(checkLL(i))
         LLarr[i] = iLow(Symbol(), Period(), i);
     }
   ArraySetAsSeries(LLarr, false);
   ArraySetAsSeries(ZigzagBuffer, false);
   return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool checkLL(int bar)
  {
   int c = 0;
   int i;
   double p[5];
   for(i = bar; i < iBars(Symbol(),Period())  && !IsStopped(); i++)
     {
      if(c < 5 && ZigzagBuffer[i] > 0 && ZigzagBuffer[i] != EMPTY_VALUE)
        {
         p[c] = ZigzagBuffer[i];
         c++;
        }
      if(c >= 4)
        {
         if(p[0] < p[1] && p[0] < p[2] && p[0] < p[3] && p[1] < p[3])
           {
            return true;
           }
         else
           {
            return false;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+

// NOTE: AT
// ------------------------------------------------------------------
// return specific point of zz
double Value(int i, int shift, bool candle = false)
  {
   int    count = -1;
   double value = 0;
   int    bars  = Bars(NULL, 0);
   while(count != shift)
     {
      value = ZigzagBuffer[bars - i];
      i++;
      if(value != EMPTY_VALUE && value > 0)
         count++;
     }
   if(candle)
     {
      return bars - i + 1;
     }
   return value;
// return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LoadPoints(int index, int qnt)
  {
   ArrayFree(points);
   ArrayResize(points, 0);
   for(int i = 0; i < qnt + 1; i++)
     {
      double ValueToAdd = Value(index, i);
      int    candle     = Value(index, i, true);
      int    t          = ArraySize(points);
      if(ArrayResize(points, t + 1))
        {
         points[t].price  = ValueToAdd;
         points[t].candle = candle;
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PrintPoints()
  {
   for(int i = 0; i < ArraySize(points); i++)
     {
      Print("Array points, value: ", i, " price:", points[i].price);
      Print("Array points, value: ", i, " candle:", points[i].candle);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double price(int i) { return points[i].price; }
int    candle(int i) { return points[i].candle; }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLabel(int index, string side, string txt)
  {
   int      bars  = Bars(NULL, 0);
   string   id    = ObjPrefix + candle(index);
   double   price = price(index) + (vShift * _Point);
   datetime time  = iTime(_Symbol, _Period, bars - candle(index));
   color    clr   = side == "up" ? Text_color_Top : Text_color_Bottom;
   if(ObjectCreate(0, id, OBJ_TEXT, 0, time, price))
     {
      ObjectSetString(0, id, OBJPROP_FONT, "Calibri");
      ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
     }
   ObjectSetString(0, id, OBJPROP_TEXT, txt);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LabelLastPoint()
  {
   if(price(1) > price(2) && price(1) > price(3))
     {
      DrawLabel(1, "up", "HH");
     }
   if(price(1) < price(2) && price(1) > price(3))
     {
      DrawLabel(1, "up", "HL");
     }
   if(price(1) < price(2) && price(1) < price(3))
     {
      DrawLabel(1, "dn", "LL");
     }
   if(price(1) > price(2) && price(1) < price(3))
     {
      DrawLabel(1, "dn", "LH");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindBMS(int i)
  {
// if have Bull Struct:
   if(price(2) > price(4) && price(3) > price(5) && price(3) < price(4))
     {
      if(price(1) < price(2) && price(1) < price(3))
        {
         DrawLabel(1, "dn", "BMS");
         int _bar    = points[1].candle;
         BMSdn[_bar] = points[1].price;
         Notifications(1, _bar);
        }
     }
// if have Bull Struct:
   if(price(2) < price(4) && price(3) < price(5) && price(3) > price(4))
     {
      if(price(1) > price(2) && price(1) > price(3))
        {
         DrawLabel(1, "up", "BMS");
         int _bar    = points[1].candle;
         BMSup[_bar] = points[1].price;
         Notifications(0, _bar);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notifications(int type, int candle)
  {
   if(candle == Notification_last_candle)
     {
      return;
     }
   Notification_last_candle = candle;
   string text = "";
   if(type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " BMS UP ";
   if(type == 1)
      text += _Symbol + " " + GetTimeFrame(_Period) + " BMS DOWN ";
   if(type == 2)
      text += _Symbol + " " + GetTimeFrame(_Period) + " LL UP ";
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
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71190&p=149035#p149035

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 