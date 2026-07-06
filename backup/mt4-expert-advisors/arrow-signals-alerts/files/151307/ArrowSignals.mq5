//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=154142#p154142

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 3

//---- plot Zigzag
// clang-format off

#property indicator_label1 "Buy"
#property  indicator_type1  DRAW_ARROW
#property indicator_color1 clrAqua
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

#property indicator_label2 "Sell"
#property  indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#property indicator_label3 " "
#property indicator_color3 Red
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

// clang-format on

//--- input parameters
input  int dist = 24; // dist
int ExtDepth     = dist/2;
int ExtDeviation = 5;
int ExtBackstep  = 3;

bool showzz = false;  // Show ZigZag:

//--- indicator buffers
double ZigzagBuffer[];   // main buffer
double HighMapBuffer[];  // highs
double LowMapBuffer[];   // lows
int    level = 3;        // recounting depth
double deviation;        // deviation in points

double SignalUp[];
double SignalDn[];

input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
datetime     lastNotifyTime        = 0;
int          lastDirection         = -1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  // NOTE: oninit
  // clang-format off
       SetIndexBuffer(0, SignalUp, INDICATOR_DATA);
  PlotIndexSetInteger(0, PLOT_ARROW, 233);
  PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, Aqua);

       SetIndexBuffer(1, SignalDn, INDICATOR_DATA);
  PlotIndexSetInteger(1, PLOT_ARROW, 234);
  PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
  PlotIndexSetInteger(1, PLOT_LINE_COLOR, Red);
  
  //--- indicator buffers mapping
  SetIndexBuffer(2, ZigzagBuffer, INDICATOR_DATA);
  SetIndexBuffer(3, HighMapBuffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(4, LowMapBuffer, INDICATOR_CALCULATIONS);

  if(!showzz)
    PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
    else
    PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_SECTION);

  // clang-format on

  //--- set short name and digits
  // PlotIndexSetString(0, PLOT_LABEL, "ZigZag(" + (string)ExtDepth + "," + (string)ExtDeviation + "," + (string)ExtBackstep + ")");
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  //--- set empty value
  PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);
  //--- to use in cycle
  deviation = ExtDeviation * _Point;
  //---

  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|  searching index of the highest bar                              |
//+------------------------------------------------------------------+
int iHighest(const double& array[],
             int           depth,
             int           startPos)
{
  int index = startPos;
  //--- start index validation
  if (startPos < 0) {
    Print("Invalid parameter in the function iHighest, startPos =", startPos);
    return 0;
  }
  int size = ArraySize(array);
  //--- depth correction if need
  if (startPos - depth < 0) depth = startPos;
  double max = array[startPos];
  //--- start searching
  for (int i = startPos; i > startPos - depth; i--) {
    if (array[i] > max) {
      index = i;
      max   = array[i];
    }
  }
  //--- return index of the highest bar
  return (index);
}
//+------------------------------------------------------------------+
//|  searching index of the lowest bar                               |
//+------------------------------------------------------------------+
int iLowest(const double& array[],
            int           depth,
            int           startPos)
{
  int index = startPos;
  //--- start index validation
  if (startPos < 0) {
    Print("Invalid parameter in the function iLowest, startPos =", startPos);
    return 0;
  }
  int size = ArraySize(array);
  //--- depth correction if need
  if (startPos - depth < 0) depth = startPos;
  double min = array[startPos];
  //--- start searching
  for (int i = startPos; i > startPos - depth; i--) {
    if (array[i] < min) {
      index = i;
      min   = array[i];
    }
  }
  //--- return index of the lowest bar
  return (index);
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
  enum looling_for {
    Pike = 1,  // searching for next high
    Sill = -1  // searching for next low
  };
  //--- initializing
  if (prev_calculated == 0) {
    ArrayInitialize(ZigzagBuffer, 0.0);
    ArrayInitialize(HighMapBuffer, 0.0);
    ArrayInitialize(LowMapBuffer, 0.0);
  }
  //---
  if (rates_total < 100) return (0);
  //--- set start position for calculations
  if (prev_calculated == 0) limit = ExtDepth;

  //--- ZigZag was already counted before
  if (prev_calculated > 0) {
    i = rates_total - 1;
    //--- searching third extremum from the last uncompleted bar
    while (counterZ < level && i > rates_total - 100) {
      res = ZigzagBuffer[i];
      if (res != 0) counterZ++;
      i--;
    }
    i++;
    limit = i;

    //--- what type of exremum we are going to find
    if (LowMapBuffer[i] != 0) {
      curlow      = LowMapBuffer[i];
      whatlookfor = Pike;
    } else {
      curhigh     = HighMapBuffer[i];
      whatlookfor = Sill;
    }
    //--- chipping
    for (i = limit + 1; i < rates_total && !IsStopped(); i++) {
      ZigzagBuffer[i]  = 0.0;
      LowMapBuffer[i]  = 0.0;
      HighMapBuffer[i] = 0.0;
    }
  }

  //--- searching High and Low
  for (shift = limit; shift < rates_total && !IsStopped(); shift++) {
    val = low[iLowest(low, ExtDepth, shift)];
    if (val == lastlow)
      val = 0.0;
    else {
      lastlow = val;
      if ((low[shift] - val) > deviation)
        val = 0.0;
      else {
        for (back = 1; back <= ExtBackstep; back++) {
          res = LowMapBuffer[shift - back];
          if ((res != 0) && (res > val)) LowMapBuffer[shift - back] = 0.0;
        }
      }
    }
    if (low[shift] == val)
      LowMapBuffer[shift] = val;
    else
      LowMapBuffer[shift] = 0.0;
    //--- high
    val = high[iHighest(high, ExtDepth, shift)];
    if (val == lasthigh)
      val = 0.0;
    else {
      lasthigh = val;
      if ((val - high[shift]) > deviation)
        val = 0.0;
      else {
        for (back = 1; back <= ExtBackstep; back++) {
          res = HighMapBuffer[shift - back];
          if ((res != 0) && (res < val)) HighMapBuffer[shift - back] = 0.0;
        }
      }
    }
    if (high[shift] == val)
      HighMapBuffer[shift] = val;
    else
      HighMapBuffer[shift] = 0.0;
  }

  //--- last preparation
  if (whatlookfor == 0)  // uncertain quantity
  {
    lastlow  = 0;
    lasthigh = 0;
  } else {
    lastlow  = curlow;
    lasthigh = curhigh;
  }

  //--- final rejection
  for (shift = limit; shift < rates_total && !IsStopped(); shift++) {
    res = 0.0;
    switch (whatlookfor) {
      case 0:  // search for peak or lawn
        if (lastlow == 0 && lasthigh == 0) {
          if (HighMapBuffer[shift] != 0) {
            lasthigh            = high[shift];
            lasthighpos         = shift;
            whatlookfor         = Sill;
            ZigzagBuffer[shift] = lasthigh;
            res                 = 1;
          }
          if (LowMapBuffer[shift] != 0) {
            lastlow             = low[shift];
            lastlowpos          = shift;
            whatlookfor         = Pike;
            ZigzagBuffer[shift] = lastlow;
            res                 = 1;
          }
        }
        break;
      case Pike:  // search for peak
        if (LowMapBuffer[shift] != 0.0 && LowMapBuffer[shift] < lastlow && HighMapBuffer[shift] == 0.0) {
          ZigzagBuffer[lastlowpos] = 0.0;
          lastlowpos               = shift;
          lastlow                  = LowMapBuffer[shift];
          ZigzagBuffer[shift]      = lastlow;
          res                      = 1;
        }
        if (HighMapBuffer[shift] != 0.0 && LowMapBuffer[shift] == 0.0) {
          lasthigh            = HighMapBuffer[shift];
          lasthighpos         = shift;
          ZigzagBuffer[shift] = lasthigh;
          whatlookfor         = Sill;
          res                 = 1;
        }
        break;
      case Sill:  // search for lawn
        if (HighMapBuffer[shift] != 0.0 && HighMapBuffer[shift] > lasthigh && LowMapBuffer[shift] == 0.0) {
          ZigzagBuffer[lasthighpos] = 0.0;
          lasthighpos               = shift;
          lasthigh                  = HighMapBuffer[shift];
          ZigzagBuffer[shift]       = lasthigh;
        }
        if (LowMapBuffer[shift] != 0.0 && HighMapBuffer[shift] == 0.0) {
          lastlow             = LowMapBuffer[shift];
          lastlowpos          = shift;
          ZigzagBuffer[shift] = lastlow;
          whatlookfor         = Pike;
        }
        break;

      default: return (rates_total);
    }

    int n     = shift - 1;
    int count = 2;  // va a contar las veces que el zz es igual a una flecha, quiero ir dos picos para atrás

    if (shift > 200)
      while (count != 0 && !IsStopped()) {
        SignalUp[n] = EMPTY_VALUE;
        SignalDn[n] = EMPTY_VALUE;

        // estoy en un low
        if (ZigzagBuffer[n] == LowMapBuffer[n] && ZigzagBuffer[n] != 0) {
          SignalUp[n] = ZigzagBuffer[n];
          Notifications(0);
          count--;
        }

        // estoy en un high
        if (ZigzagBuffer[n] == HighMapBuffer[n] && ZigzagBuffer[n] != 0) {
          SignalDn[n] = ZigzagBuffer[n];
          Notifications(1);
          count--;
        }
        n--;
      }    
  }
  
  //--- return value of prev_calculated for next call
  return (rates_total);
}

//+------------------------------------------------------------------+

void Notifications(int type)
{
  datetime currentTime  = iTime(NULL, 0, 1);
  int      curDirection = type;

  if (lastNotifyTime == currentTime) { 
    return;
  } else {
    lastNotifyTime = currentTime;
  }

  if (curDirection == lastDirection) {
    return;
  } else {
    lastDirection = curDirection;
  }

  string text = "";
  if (type == 0)
    text += _Symbol + " " + GetTimeFrame(_Period) + " Sell Now ";
  else
    text += _Symbol + " " + GetTimeFrame(_Period) + " Buy Now ";

  if (!notifications) return;
  if (desktop_notifications) Alert(text);
  if (push_notifications) SendNotification(text);
  if (email_notifications) SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
  switch (lPeriod) {
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
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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