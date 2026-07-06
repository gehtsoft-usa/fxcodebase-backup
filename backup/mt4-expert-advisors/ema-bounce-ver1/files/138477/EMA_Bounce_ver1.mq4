// More information about this indicator can be found at:
// http://fxcodebase.com/


//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrRed
#property indicator_color2 clrLime
#property indicator_color3 clrGold
#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 3



extern ENUM_MA_METHOD MaMethod = MODE_EMA; //MA Method
extern int MaPreiod = 50; //MA Period
extern int MaShift; //Ma Shift
extern ENUM_APPLIED_PRICE MaPrice = PRICE_CLOSE;//MA Applied Price


extern bool enabledOn       = true;  // Enabled Notify
extern bool alertsOn        = true;  // Enabled Alerts
extern bool alertsMessage   = true;  // Enabled Message 
extern bool alertsSound     = false; // Enable Sound
extern bool alertsEmail     = false; // Enable Email
extern string soundFile     ="alert2.wav"; // Sound File

extern int offset = 10; // Points offset

extern string BuyMessageText = "Buy";    // Buy Message Text
extern string SellMessageText = "Sell";  // Sell Message Text

string IndicatorName = "EMA Bounce ver1";

double b1[],b2[],b3[];
int    TimeFrame;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(3);
   
   SetIndexBuffer(0,b1); 
   SetIndexStyle(0,DRAW_ARROW); 
   SetIndexArrow(0,242);
   
   SetIndexBuffer(1,b2); 
   SetIndexStyle(1,DRAW_ARROW); 
   SetIndexArrow(1,241);
   
   SetIndexBuffer(2,b3);
   SetIndexStyle(2,DRAW_LINE); 
   IndicatorShortName(timeFrameToString(TimeFrame)+" "+IndicatorName+" ("+MaPreiod+")");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{

   b3[0] = MAValue(1);
   int signal = getSignal(b3[0], 0);
   if(signal == 1)
      b1[0] = High[0] + offset*Point;
   if(signal == 2)
      b2[0] = Low[0] - offset*Point;
   
   if (alertsOn)
   {
      if(signal == 1) doAlert(BuyMessageText);
      if(signal == 2) doAlert(SellMessageText);
   
   }
   return 0;

}


double last_high, last_low;
bool highest, lowest;
datetime time;
//0 - no signal
//1 - buy 
//2 - sell
int getSignal(double ma_1, int bar = 0)
{
   if(time != iTime(Symbol(),0,0))
   {
      time = iTime(Symbol(),0,0);
      highest = false;
      lowest = false;
          
   }
   double high = BarHighValue(bar);  
   double low = BarLowValue(bar);
   double close = BarCloseValue(bar);
   
   
   last_high = high;
   last_low = low;
   
   if(high > ma_1) highest = true;
   if(low < ma_1) lowest = true;
   
   
   if(highest && close < ma_1) return 1;
   if(lowest && close > ma_1) return 2;
      
   
   return 0;
}

double MAValue(int shift = 1)
{
    double ma = iMA(NULL, NULL, MaPreiod, MaShift, MaMethod, MaPrice, shift);
    return ma;
}

double BarCloseValue(int shift = 1)
{
    double close = iClose(NULL, NULL, shift);
    return close;  

}

double BarHighValue(int shift = 1)
{
    double close = iHigh(NULL, NULL, shift);
    return close;  

}

double BarLowValue(int shift = 1)
{
    double close = iLow(NULL, NULL, shift);
    return close;  

}
string sTfTable[] = {"M1","M2","M3","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,2,3,5,10,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          message = timeFrameToString(TimeFrame)+" "+IndicatorName+" "+Symbol()+" "+ doWhat;
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(),IndicatorName+" "),message);
             if (alertsSound)   PlaySound(soundFile);
      }
}