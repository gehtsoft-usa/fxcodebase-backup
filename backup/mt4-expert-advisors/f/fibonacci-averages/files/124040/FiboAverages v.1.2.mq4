// More information about this indicator can be found at:
// http://fxcodebase.com/

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
#property version   "1.2"
#property strict

#property description "Average given by the Fibonacci Sequence"
#property description "And a MA based on that Line"

#property indicator_chart_window
#property indicator_buffers 4

#property indicator_color1  clrYellow
#property indicator_width1  2
#property indicator_color2  clrRed
#property indicator_width2  2
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_label3 "BUY"
#property indicator_label4 "SELL"

enum e_method{ SMA        =  1,
               EMA        =  2,
               Wilder     =  3,
               LWMA       =  4,
               SineWMA    =  5,
               TriMA      =  6,
               LSMA       =  7,
               SMMA       =  8,
               HMA        =  9,
               ZeroLagEMA = 10,
               ITrend     = 11,
               Median     = 12,
               GeoMean    = 13,
               REMA       = 14,
               ILRS       = 15,
               IE_2       = 16,
               TriMAgen   = 17
             };

extern int      Fibo_Prices   = 11;
extern int      MA_Period     = 55;
extern e_method MA_Method     = SMA;
extern int      Limit_Bars    = 0;
extern int WaitCandles = 0; // Wait number of candles before signaling
//Signaler v 1.2.1
extern bool     Popup_Alert              = true; // Popup message
extern bool     Notification_Alert       = false; // Push notification
extern bool     Email_Alert              = false; // Email
extern bool     Play_Sound               = false; // Play sound on alert
extern string   Sound_File               = ""; // Sound file
extern bool     Advanced_Alert           = false; // Advanced alert
extern string   Advanced_Key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a advanced alert key by starting a dialog with @profit_robots_bot Telegram bot -";
extern string   Comment3                 = "- Also, you need to install AdvancedNotificationsLib.dll and allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Make sure that Microsoft .NET Framework 4.6 is installed on your PC -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import

double Fibo_Numbers[];
double Fibo[];
double MA[];
double Price[];
double buy[], sell[];

//+****************************************************************+

int init(){
   
   IndicatorShortName("FiboAverages");
   IndicatorBuffers(6);
   
   int fibo = 0;
   int fibo1 = 0;
   int fibo2 = 1;
   for (int i=3; i<=Fibo_Prices; i++){
      fibo = fibo1+fibo2;
      fibo1 = fibo2;
      fibo2 = fibo;
   }
   int LimDraw = Limit_Bars > 0 ? Bars - Limit_Bars : 0;
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Fibo);
   SetIndexLabel(0,"Fibo");
   SetIndexDrawBegin(0,fibo+Fibo_Prices+LimDraw);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MA);
   SetIndexLabel(1,"MA");
   SetIndexDrawBegin(1,fibo+Fibo_Prices+MA_Period+LimDraw);

   SetIndexStyle(2, DRAW_ARROW, 0, 2);
   SetIndexArrow(2, 217);
   SetIndexBuffer(2, buy);

   SetIndexStyle(3, DRAW_ARROW, 0, 2);
   SetIndexArrow(3, 218);
   SetIndexBuffer(3, sell);
   
   SetIndexBuffer(4,Fibo_Numbers);
   SetIndexBuffer(5,Price);
   
   return(0);
}

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1
  
int start(){
   
   Fibo_Numbers[1] = 0;
   Fibo_Numbers[2] = 1;
   for (int i=3; i<=Fibo_Prices; i++){
      Fibo_Numbers[i] = Fibo_Numbers[i-1]+Fibo_Numbers[i-2];
   }
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   if (Limit_Bars)
      limit = Limit_Bars;
   if (limit > Bars - (int)Fibo_Numbers[Fibo_Prices] - 1)
      limit = Bars - (int)Fibo_Numbers[Fibo_Prices] - 1;
   
   double Sum;
   int multiplier = 1;   
   
   for(i=limit; i>=0; i--)
   {
      Sum=0;
      for (j = 1; j <= Fibo_Prices; j++)
      {
         Sum += Close[i + (int)Fibo_Numbers[j]];
      }
      Fibo[i]=Sum/Fibo_Prices;
      
      switch(MA_Method)
      {
         case 1 : MA[i] = SMA(Fibo,MA_Period,i, multiplier); break;
         case 2 : MA[i] = EMA(Fibo[i],MA[i+(1*multiplier)],MA_Period,i); break;
         case 3 : MA[i] = Wilder(Fibo[i],MA[i+(1*multiplier)],MA_Period,i); break;  
         case 4 : MA[i] = LWMA(Fibo,MA_Period,i, multiplier); break;
         case 5 : MA[i] = SineWMA(Fibo,MA_Period,i, multiplier); break;
         case 6 : MA[i] = TriMA(Fibo,MA_Period,i, multiplier); break;
         case 7 : MA[i] = LSMA(Fibo,MA_Period,i, multiplier); break;
         case 8 : MA[i] = SMMA(Fibo,MA[i+(1*multiplier)],MA_Period,i, multiplier); break;
         case 9 : MA[i] = HMA(Fibo,MA_Period,i, multiplier); break;
         case 10: MA[i] = ZeroLagEMA(Fibo,MA[i+(1*multiplier)],MA_Period,i, multiplier); break;
         case 11: MA[i] = ITrend(Fibo,MA,MA_Period,i, multiplier); break;
         case 12: MA[i] = Median(Fibo,MA_Period,i, multiplier); break;
         case 13: MA[i] = GeoMean(Fibo,MA_Period,i, multiplier); break;
         case 14: MA[i] = REMA(Fibo[i],MA,MA_Period,0.5,i, multiplier); break;
         case 15: MA[i] = ILRS(Fibo,MA_Period,i, multiplier); break;
         case 16: MA[i] = IE2(Fibo,MA_Period,i, multiplier); break;
         case 17: MA[i] = TriMA_gen(Fibo,MA_Period,i, multiplier); break;
         default: MA[i] = SMA(Fibo,MA_Period,i, multiplier); break;
      }
      int direction = GetDirection(i);
      switch (direction)
      {
         case ENTER_BUY_SIGNAL:
            buy[i] = Fibo[i];
            sell[i] = EMPTY_VALUE;
            break;
         case ENTER_SELL_SIGNAL:
            buy[i] = EMPTY_VALUE;
            sell[i] = Fibo[i];
            break;
      }
      if (i == 0)
         SendNotifications(direction);
   }
   
   return(0);
}

int GetDirection(const int period)
{
   bool isbuy = true;
   bool issell = true;
   for (int i = 0; i <= WaitCandles; ++i)
   {
      double fib = Fibo[period + i];
      double ma = MA[period + i];
      if (fib <= ma)
         isbuy = false;
      if (fib >= ma)
         issell = false;
   }
   double fib0 = Fibo[period + WaitCandles];
   double fib1 = Fibo[period + WaitCandles + 1];
   double ma0 = MA[period + WaitCandles];
   double ma1 = MA[period + WaitCandles + 1];
   if (fib0 > ma0 && fib1 <= ma1 && isbuy)   
      return ENTER_BUY_SIGNAL;
   if (fib0 < ma0 && fib1 >= ma1 && issell)
      return ENTER_SELL_SIGNAL;
   return 0;
}

string GetTimeframe()
{
   switch (_Period)
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

datetime _lastDatetime;

void SendNotifications(const int direction)
{
   if (direction == 0 || IsTesting())
      return;

   datetime currentTime = iTime(_Symbol, _Period, 0);
   if (_lastDatetime == currentTime)
      return;

   _lastDatetime = currentTime;
   string tf = GetTimeframe();
   string alert_Subject;
   string alert_Body;
   switch (direction)
   {
      case ENTER_BUY_SIGNAL:
         alert_Subject = "Buy signal on " + _Symbol + "/" + tf;
         alert_Body = "Buy signal on " + _Symbol + "/" + tf;
         break;
      case ENTER_SELL_SIGNAL:
         alert_Subject = "Sell signal on " + _Symbol + "/" + tf;
         alert_Body = "Sell signal on " + _Symbol + "/" + tf;
         break;
   }
   SendNotifications(alert_Subject, alert_Body, _Symbol, tf);
}

void SendNotifications(const string subject, const string message, const string symbol, const string timeframe)
{
   if (Popup_Alert)
      Alert(message);
   if (Email_Alert)
      SendMail(subject, message);
   if (Play_Sound)
      PlaySound(Sound_File);
   if (Notification_Alert)
      SendNotification(message);
   if (Advanced_Alert && Advanced_Key != "")
      AdvancedAlert(Advanced_Key, message, symbol, timeframe);
}
  
double SMA(double &array[],int per,int bar, int mult=1){
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[bar+(i*mult)];
   return(Sum/per);
}                

double EMA(double price,double prev,int per,int bar){
   return bar >= Bars - 2 ? price : prev + 2.0/(1+per)*(price - prev); 
}

double Wilder(double price,double prev,int per,int bar){
   return bar >= Bars - 2 ? price : prev + (price - prev)/per; 
}

double LWMA(double &array[],int per,int bar, int mult=1){
   double Sum = 0;
   double Weight = 0;
   for(int i = 0;i < per;i++){ 
      Weight+= (per - i);
      Sum += array[bar+(i*mult)]*(per - i);
   }
   if(Weight>0)
      return Sum/Weight;
   return 0;
} double SineWMA(double &array[],int per,int bar, int mult=1){
   double pi = 3.1415926535;
   double Sum = 0;
   double Weight = 0;
   for(int i = 0;i < per;i++){ 
      Weight+= MathSin(pi*(i+1)/(per+1));
      Sum += array[bar+(i*mult)]*MathSin(pi*(i+1)/(per+1)); 
   }
   if(Weight>0)
      return Sum/Weight;
   return 0;
}

double TriMA(double &array[],int per,int bar, int mult=1){
   double sma;
   int len = (int)MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len;i++) {
      sma = SMA(array,len,bar+(i*mult),mult);
      sum += sma;
   } 
   double trima = sum/len;
   return(trima);
}

double LSMA(double &array[],int per,int bar, int mult=1){   
   double Sum=0;
   for(int i=per; i>=1; i--) Sum += (i-(per+1)/3.0)*array[bar+((per-i)*mult)];
   double lsma = Sum*6/(per*(per+1));
   return(lsma);
}

double SMMA(double &array[],double prev,int per,int bar, int mult=1){
   if(bar == Bars - per)
      return SMA(array,per,bar, mult);
   else if(bar < Bars - per){
      double Sum = 0;
      for(int i = 0;i < per;i++) 
         Sum += array[bar+((i+1)*mult)];
      return (Sum - prev + array[bar])/per;
   }
   return 0;
}                

double HMA(double &array[],int per,int bar, int mult=1){
   double tmp1[];
   int len = (int)MathSqrt(per);
   ArrayResize(tmp1,len);
   if(bar == Bars - per)
      return array[bar]; 
   else if(bar < Bars - per){
      for(int i=0;i<len;i++) tmp1[i] = 2*LWMA(array,per/2,bar+(i*mult),mult) - LWMA(array,per,bar+(i*mult),mult);  
      return LWMA(tmp1,len,0); 
   }  
   return 0;
}

double ZeroLagEMA(double &price[],double prev,int per,int bar, int mult=1){
   double alfa = 2.0/(1+per); 
   int lag = (int)(0.5*(per - 1));
   if(bar >= Bars - lag)
      return price[bar];
   return alfa*(2*price[bar] - price[bar+(lag*mult)]) + (1-alfa)*prev;
}

double ITrend(double &price[],double &array[],int per,int bar, int mult=1){
   double alfa = 2.0/(per+1);
   if (bar < Bars - 7)
      return (alfa - 0.25*alfa*alfa)*price[bar] + 0.5*alfa*alfa*price[bar+(1*mult)] - (alfa - 0.75*alfa*alfa)*price[bar+(2*mult)] + 2*(1-alfa)*array[bar+(1*mult)] - (1-alfa)*(1-alfa)*array[bar+(2*mult)];
   
   return (price[bar] + 2*price[bar+(1*mult)] + price[bar+(2*mult)])/4;
}

double Median(double &price[],int per,int bar, int mult=1){
   double array[];
   ArrayResize(array,per);
   for(int i = 0; i < per;i++) array[i] = price[bar+(i*mult)];
   ArraySort(array);
   int num = (int)MathRound((per-1)/2); 
   if(MathMod(per,2) > 0) 
      return array[num];
   return 0.5*(array[num]+array[num+1]);
}

double GeoMean(double &price[],int per,int bar, int mult=1){
   if(bar < Bars - per){ 
      double gmean = MathPow(price[bar],1.0/per); 
      for(int i = 1; i < per;i++) gmean *= MathPow(price[bar+(i*mult)],1.0/per); 
      return gmean;
   }   
   return 0;
}

double REMA(double price,double &array[],int per,double lambda,int bar, int mult=1){
   double alpha =  2.0/(per + 1);
   if(bar >= Bars - 3)
      return price;
   return (array[bar+(1*mult)]*(1+2*lambda) + alpha*(price - array[bar+(1*mult)]) - lambda*array[bar+(2*mult)])/(1+lambda);    
}

double ILRS(double &price[],int per,int bar, int mult=1){
   double sum = per*(per-1)*0.5;
   double sum2 = (per-1)*per*(2*per-1)/6.0;
   double sum1 = 0;
   double sumy = 0;
   for(int i=0;i<per;i++){ 
      sum1 += i*price[bar+(i*mult)];
      sumy += price[bar+(i*mult)];
   }
   double num1 = per*sum1 - sum*sumy;
   double num2 = sum*sum - per*sum2;
   double slope = num2 != 0 ? num1/num2 : 0; 
   double ilrs = slope + SMA(price,per,bar,mult);
   return(ilrs);
}

double IE2(double &price[],int per,int bar, int mult=1){
   double ie = 0.5*(ILRS(price,per,bar,mult) + LSMA(price,per,bar,mult));
   return(ie); 
}

double TriMA_gen(double &array[],int per,int bar, int mult=1){
   int len1 = (int)MathFloor((per+1)*0.5);
   int len2 = (int)MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len2;i++) sum += SMA(array,len1,bar+(i*mult),mult);
   double trimagen = sum/len2;
   return(trimagen);
}