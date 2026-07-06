//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=160059#p160059

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

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Yellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_level1  0
#property indicator_minimum -3
#property indicator_maximum 3

#define PREFIX "xxx"

//--- Input parameters
input int    length              = 18;              // Calculation period length
input bool   arrow              = true;            // Show arrows
input int    arrowSize          = 1;              // Arrow size
input int    SIGNAL_BAR         = 1;              // Signal bar shift
input color  clArrowBuy         = clrBlue;        // Buy arrow color
input color  clArrowSell        = clrRed;         // Sell arrow color
input ENUM_TIMEFRAMES signalTF = PERIOD_CURRENT; // Signal timeframe

enum ENUM_ALERT_MODE
{
   Off = 0,      // Off
   Current = 1,  // At current bar
   Previous = 2  // At previous closed bar
};

input ENUM_ALERT_MODE  notificationsOn       = Current;     // Notifications
input bool   desktop_notifications = true;                   // Desktop notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file           = "Tick.wav";             // Sound file

//--- Indicator buffers
double ExtBuffer[];
double ValueBuffer[];
double Fish1Buffer[];

//--- Global variables
bool   alerted = false;
datetime lastbar = 0;
int handleATR;

//+------------------------------------------------------------------+
int OnInit()
{
   //--- Indicator buffers mapping
   SetIndexBuffer(0, ExtBuffer, INDICATOR_DATA);
   ArraySetAsSeries(ExtBuffer, true);
   
   //--- Additional buffers for calculations
   ArrayResize(ValueBuffer, length);
   ArrayResize(Fish1Buffer, length);
   ArraySetAsSeries(ValueBuffer, true);
   ArraySetAsSeries(Fish1Buffer, true);
   
   //--- Set indicator properties
   PlotIndexSetString(0, PLOT_LABEL, "UpDown");
   IndicatorSetString(INDICATOR_SHORTNAME, "Up and Down");
   
   //--- Initialize variables
   alerted = false;
   lastbar = 0;
   
   //--- Initialize ATR handle
   handleATR = iATR(_Symbol, PERIOD_CURRENT, 20);
   if(handleATR == INVALID_HANDLE)
     {
      Print("Error creating ATR indicator");
      return(INIT_FAILED);
     }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(handleATR != INVALID_HANDLE)
      IndicatorRelease(handleATR);
   ObjectsDeleteAll(0, PREFIX);
}

//+------------------------------------------------------------------+
//--- Thêm hàm lấy dữ liệu giá từ timeframe khác
void GetMTFData(ENUM_TIMEFRAMES tf, int shift, double &open, double &close, double &high, double &low, datetime &time)
{
   open  = iOpen(_Symbol, tf, shift);
   close = iClose(_Symbol, tf, shift);
   high  = iHigh(_Symbol, tf, shift);
   low   = iLow(_Symbol, tf, shift);
   time  = iTime(_Symbol, tf, shift);
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(rates_total < length) return 0;
   
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   int start = 0;
   
   //--- Main calculation loop
   for(int i = start; i < rates_total; i++)
   {
      double o, c, h, l;
      datetime t;
      if(signalTF == PERIOD_CURRENT)
      {
         o = open[i];
         c = close[i];
         h = high[i];
         l = low[i];
         t = time[i];
      }
      else
      {
         GetMTFData(signalTF, i, o, c, h, l, t);
      }
      //--- Find highest/lowest
      double MaxH = h; // Sửa lại logic cho MTF: chỉ lấy giá trị tại nến đó
      double MinL = l;
      double price = (o + c) / 2.0;
      //--- Calculate Value
      double Value = 0;
      if(MaxH - MinL == 0)
         Value = 0.33 * 2.0 * (0.0 - 0.5) + 0.67 * (i > 0 ? ValueBuffer[1] : 0);
      else
         Value = 0.33 * 2.0 * ((price - MaxH) / (MinL - MaxH) - 0.5) + 0.67 * (i > 0 ? ValueBuffer[1] : 0);
      Value = MathMin(MathMax(Value, -0.999), 0.999);
      ValueBuffer[0] = Value;
      //--- Calculate Fisher with limits
      double calc;
      if(MathAbs(1.0 - Value) < 0.000000001)
         calc = 0.5 + 0.5 * (i > 0 ? Fish1Buffer[1] : 0);
      else
         calc = 0.5 * MathLog((1.0 + Value) / (1.0 - Value)) + 0.5 * (i > 0 ? Fish1Buffer[1] : 0);
      //--- Apply limits [-3,3]
      ExtBuffer[i] = MathMax(-3.0, MathMin(3.0, calc));
      Fish1Buffer[0] = ExtBuffer[i];
      //--- Draw arrows
      if(arrow && i >= SIGNAL_BAR + 1)
      {
         if(ExtBuffer[i-SIGNAL_BAR-1] > 0.0 && ExtBuffer[i-SIGNAL_BAR] < 0.0)
            CreateArrow(t, o, c, clArrowSell, 234, false);
         if(ExtBuffer[i-SIGNAL_BAR-1] < 0.0 && ExtBuffer[i-SIGNAL_BAR] > 0.0)
            CreateArrow(t, o, c, clArrowBuy, 233, true);
      }
      //--- Shift buffers
      for(int j = length-1; j > 0; j--)
      {
         ValueBuffer[j] = ValueBuffer[j-1];
         Fish1Buffer[j] = Fish1Buffer[j-1];
      }
   }
   //--- Check for alerts
   if(notificationsOn != Off)
      CheckAlert();
   return(rates_total);
}

//+------------------------------------------------------------------+
void CreateArrow(datetime time, double open, double close, color clr, int code, bool up)
{
   string name = PREFIX + IntegerToString(time);
   
   double gap = 0;
   double atr[];
   if(CopyBuffer(handleATR, 0, 0, 1, atr) == 1)
      gap = 3.0 * atr[0] / 4.0;
   
   if(ObjectFind(0, name) == -1)
      ObjectCreate(0, name, OBJ_ARROW, 0, time, 0);
      
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, code);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, arrowSize);
   if(up)
      ObjectSetDouble(0, name, OBJPROP_PRICE, close - gap);
   else
      ObjectSetDouble(0, name, OBJPROP_PRICE, open + gap);
}

//+------------------------------------------------------------------+
void CheckAlert()
{
   datetime curbar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(lastbar != curbar)
   {
      alerted = false;
      lastbar = curbar;
   }
   
   if(notificationsOn == Current && !alerted)
   {
      if(ExtBuffer[1] > 0.0 && ExtBuffer[0] < 0.0)
      {
         SendNotifications(1);
         alerted = true;
      }
      if(ExtBuffer[1] < 0.0 && ExtBuffer[0] > 0.0)
      {
         SendNotifications(2);
         alerted = true;
      }
   }
   
   if(notificationsOn == Previous && !alerted)
   {
      if(ExtBuffer[2] > 0.0 && ExtBuffer[1] < 0.0)
      {
         SendNotifications(11);
         alerted = true;
      }
      if(ExtBuffer[2] < 0.0 && ExtBuffer[1] > 0.0)
      {
         SendNotifications(22);
         alerted = true;
      }
   }
}

//+------------------------------------------------------------------+
void SendNotifications(int type)
{
   string text = "Up and Down: ";
   switch(type)
   {
      case 1:  text += "Turn UP before bar closes - ";   break;
      case 2:  text += "Turn DOWN before bar closes - "; break;
      case 11: text += "Turned UP after bar closed - ";  break;
      case 22: text += "Turned DOWN after bar closed - "; break;
   }
   text += _Symbol + " " + GetTimeFrameName(Period());
   
   if(desktop_notifications) Alert(text);
   if(push_notifications)    SendNotification(text);
   if(email_notifications)   SendMail("MetaTrader Notification", text);
   if(sound_notifications)   PlaySound(sound_file);
}

//+------------------------------------------------------------------+
string GetTimeFrameName(ENUM_TIMEFRAMES period)
{
   switch(period)
   {
      case PERIOD_M1:  return "M1";
      case PERIOD_M5:  return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN1";
   }
   return IntegerToString(period);
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=160059#p160059

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