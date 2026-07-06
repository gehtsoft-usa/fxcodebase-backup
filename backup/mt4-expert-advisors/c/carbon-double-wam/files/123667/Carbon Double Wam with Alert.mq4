// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67315

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red

#property indicator_level1 0
      
#property indicator_levelcolor Blue
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT
 

#property indicator_label1 "Carbon Double Wam" 


extern int Period1 = 21; 
extern int Period2 = 3; 
extern int Lag1 = 1; 
extern int Period3 = 21; 
extern int Period4 = 21; 
extern int Lag2 = 1; 

extern bool AlertFirst1_2_cross = false; // Alert on first 1/2 cross
extern bool AlertSecond1_2_cross = false; // Alert on second 1/2 cross
extern bool AlertFirstSecond_cross = false; // Alert on first/second cross
//Signaler v 1.5
extern string   AlertsSection            = ""; // == Alerts ==
extern bool     Popup_Alert              = true; // Popup message
extern bool     Notification_Alert       = false; // Push notification
extern bool     Email_Alert              = false; // Email
extern bool     Play_Sound               = false; // Play sound on alert
extern string   Sound_File               = ""; // Sound file
extern bool     Advanced_Alert           = false; // Advanced alert
extern string   Advanced_Key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a advanced alert key by starting a dialog with @profit_robots_bot Telegram bot -";
extern string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1
#define EXIT_BUY_SIGNAL 2
#define EXIT_SELL_SIGNAL -2

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDatetime;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SendNotifications(const int direction)
   {
      if (direction == 0)
         return;

      datetime currentTime = iTime(_symbol, _timeframe, 0);
      if (_lastDatetime == currentTime)
         return;

      _lastDatetime = currentTime;
      string tf = GetTimeframe();
      string alert_Subject;
      string alert_Body;
      switch (direction)
      {
         case ENTER_BUY_SIGNAL:
            alert_Subject = "Buy signal on " + _symbol + "/" + tf;
            alert_Body = "Buy signal on " + _symbol + "/" + tf;
            break;
         case ENTER_SELL_SIGNAL:
            alert_Subject = "Sell signal on " + _symbol + "/" + tf;
            alert_Body = "Sell signal on " + _symbol + "/" + tf;
            break;
         case EXIT_BUY_SIGNAL:
            alert_Subject = "Exit buy signal on " + _symbol + "/" + tf;
            alert_Body = "Exit buy signal on " + _symbol + "/" + tf;
            break;
         case EXIT_SELL_SIGNAL:
            alert_Subject = "Exit sell signal on " + _symbol + "/" + tf;
            alert_Body = "Exit sell signal on " + _symbol + "/" + tf;
            break;
      }
      SendNotifications(alert_Subject, alert_Body, _symbol, tf);
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframe();

      if (Popup_Alert)
         Alert(message);
      if (Email_Alert)
         SendMail(subject, message);
      if (Play_Sound)
         PlaySound(Sound_File);
      if (Notification_Alert)
         SendNotification(message);
      if (Advanced_Alert && Advanced_Key != "" && !IsTesting())
         AdvancedAlert(Advanced_Key, message, symbol, timeframe);
   }

   string GetTimeframe()
   {
      switch (_timeframe)
      {
         case PERIOD_M1: return "M1";
         case PERIOD_M5: return "M5";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H4: return "H4";
         case PERIOD_M15: return "M15";
         case PERIOD_M30: return "M30";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }
};

enum MA_Types{ SMA=1,  EMA=2, SMMA=3,LWMA=4 };
 
input  MA_Types MA_Type = SMA;
 
 
double Second1[];
double Second2[];
double First1[];
double First2[];

double DataA1[];
double DataB1[]; 

double DataA2[];
double DataB2[]; 

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

Signaler *signaler;

int init()
{
   if (!IsDllsAllowed() && Advanced_Alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }

   IndicatorName = GenerateIndicatorName("Carbon Double Wam");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorBuffers(8);
   
   
   IndicatorDigits(Digits);
   
    
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, First1);
   SetIndexLabel(0,"First1");
   SetIndexDrawBegin(0,0);
   
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, First2);
   SetIndexLabel(1,"First2");
   SetIndexDrawBegin(1,0);
   
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Second1);
   SetIndexLabel(2,"Second1");
   SetIndexDrawBegin(2,0);
   
   
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, Second2);
   SetIndexLabel(3,"Second2");
   SetIndexDrawBegin(3,0);
   
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, DataA1);
   
   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, DataB1);
   
   SetIndexStyle(6, DRAW_NONE);
   SetIndexBuffer(6, DataA2);
   
   SetIndexStyle(7, DRAW_NONE);
   SetIndexBuffer(7, DataB2);
   
   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
    
   return(0);
}

int deinit()
{
   delete signaler;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   int limit = Bars - 2;
   
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars;
   int pos = limit;
 
   double A;
   double B;
   double A_Shift;
   double B_Shift;
   
   while (pos >= 0)
   {
      A=iMA(NULL,0,Period1,0,(MA_Type-1),PRICE_CLOSE,pos);
      B=iMA(NULL,0,Period2,0,(MA_Type-1),PRICE_CLOSE,pos);
      
      A_Shift=iMA(NULL,0,Period1,Lag1,(MA_Type-1),PRICE_CLOSE,pos);
      B_Shift=iMA(NULL,0,Period2,Lag2,(MA_Type-1),PRICE_CLOSE,pos);
      
      First1[pos] =A;
      First2[pos] =B;
      
      DataA1[pos]=A-A_Shift; 
      DataB1[pos]=B-B_Shift; 
      pos--;
   } 
   
   double C;
   double D;
   double C_Shift;
   double D_Shift;
   
   pos = limit;
 
   while (pos >= 0)
   {
      C=iMAOnArray(DataA1,0,Period3,0,(MA_Type-1),pos);
      D=iMAOnArray(DataB1,0,Period3,0,(MA_Type-1),pos);
      
      C_Shift=iMAOnArray(DataA1,0,Period3,Lag1,(MA_Type-1),pos);
      D_Shift=iMAOnArray(DataB1,0,Period3,Lag2,(MA_Type-1),pos);
      
      DataA2[pos]=C-C_Shift; 
      DataB2[pos]=D-D_Shift;  

      pos--;
   } 

   pos = limit;
   double E;
   double F;
 
   while (pos >= 0)
   {
      E=iMAOnArray(DataA2,0,Period4,0,(MA_Type-1),pos);
      F=iMAOnArray(DataB2,0,Period4,0,(MA_Type-1),pos);
      
      if (Point()!= 0)
		{
			First1[pos] = E/Point();
			First2[pos] = F/Point();
			Second1[pos] = -E/Point();
			Second2[pos] = -F/Point();
		}	
                
      pos--;
   }
   int period = 0;
   static datetime lastAlert1;
   if (AlertFirst1_2_cross && lastAlert1 != Time[period])
   {
      if (First1[period] > First2[period] && First1[period + 1] <= First2[period + 1])
      {
         signaler.SendNotifications("First 1 crossed over first 2 on " + _Symbol + "/" + signaler.GetTimeframe());
         lastAlert1 = Time[period];
      }
      else if (First1[period] < First2[period] && First1[period + 1] >= First2[period + 1])
      {
         signaler.SendNotifications("First 1 crossed under first 2 on " + _Symbol + "/" + signaler.GetTimeframe());
         lastAlert1 = Time[period];
      }
   }
   static datetime lastAlert2;
   if (AlertSecond1_2_cross && lastAlert2 != Time[period])
   {
      if (Second1[period] > Second2[period] && Second1[period + 1] <= Second2[period + 1])
      {
         signaler.SendNotifications("Second 1 crossed over second 2 on " + _Symbol + "/" + signaler.GetTimeframe());
         lastAlert2 = Time[period];
      }
		else if (Second1[period] < Second2[period] && Second1[period + 1] >= Second2[period + 1])
      {
         signaler.SendNotifications("Second 1 crossed under second 2 on " + _Symbol + "/" + signaler.GetTimeframe());
         lastAlert2 = Time[period];
      }
   }
   static datetime lastAlert3;
   if (AlertFirstSecond_cross && lastAlert3 != Time[period])
   {
      if (((First1[period] > Second1[period]) && (First1[period + 1] <= Second1[period + 1]))
         || ((First1[period] > Second2[period]) && (First1[period + 1] <= Second2[period + 1])))
      {
         signaler.SendNotifications("First crossed over second on " + _Symbol + "/" + signaler.GetTimeframe());
         lastAlert3 = Time[period];
      }
		else if (((First1[period] < Second1[period]) && (First1[period + 1] >= Second1[period + 1])) 
         || ((First1[period] < Second2[period]) && (First1[period + 1] >= Second2[period + 1])))
		{
			signaler.SendNotifications("First crossed under second on " + _Symbol + "/" + signaler.GetTimeframe());
         lastAlert3 = Time[period];
      }
   }

   return(0);
}