// More information about this indicator can be found at:
// http://fxcodebase.com

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_chart_window
//--- input parameters
input int    Depth    = 70;   //Depth of pinbars in percents
input int    MaxRange = 1000;  //Maximum range
input int    MinRange = 200;   //Minimum range
input bool   Extremum = true; //Only extremum
extern bool       Sound_Alert                   = true;

double Pp;
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

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
    IndicatorName = GenerateIndicatorName("PinBarTracker");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   if (Point() == 0.0001 || Point() == 0.00001) Pp = 0.0001;
   if (Point() == 0.01 || Point() == 0.001) Pp = 0.01;
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
   string name = " ";
   
   for (int i = 1; i < Bars-1; i++)
    {
     if (PinUp(time[i], open[i], high[i], low[i], close[i], Depth))
      {
       name = IndicatorObjPrefix + "PinUp"+TimeToString(time[i], TIME_DATE|TIME_MINUTES); 
       ArrowSellCreate(name, time[i], high[i]);
      }
     if (PinDown(time[i], open[i], high[i], low[i], close[i], Depth))
      {
       name = IndicatorObjPrefix + "PinDown"+TimeToString(time[i], TIME_DATE|TIME_MINUTES); 
       ArrowBuyCreate(name, time[i], low[i]);
      }
    }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
  ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PinUp(datetime time, double open, double high, double low, double close, int depth)
 {
  int  range = (int)MathRound((high - low)/Pp);
  int  zone  = (int)MathRound(range * depth * 0.01);                      //////////////////////////////////////
  int  shift = iBarShift(_Symbol, PERIOD_D1, time, true);                 //                                  //
  double dayHidh = iHigh(_Symbol, PERIOD_D1, shift);                      //       |               --|        //
  double level = NormalizeDouble(low + zone * Pp, _Digits);               //       |                 |        //
  bool check = false;                                                     //       |                 |        //
                                                                          //       |                 |        //
  if (range > MinRange && range < MaxRange)                               //       |                 |        //
   {                                                                      //       |                 |- range //
    if ((Extremum && high == dayHidh) || !Extremum)                       //       |                 |        //
     check = true;                                                        //      ---     --|- level |        //
    if (open <= level && close <= level && check)                         //      | |       |        |        //
     {                                                                    //      | |       |-- zone |        //
      return(true);                                                       //      ---       |        |        //
     }                                                                    //       |      --|      --|        //
   }                                                                      //                                  //
                                                                          //////////////////////////////////////
  return(false);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PinDown(datetime time, double open, double high, double low, double close, int depth)
 {
  int  range = (int)MathRound((high - low)/Pp);
  int  zone  = (int)MathRound(range * depth * 0.01);                      //////////////////////////////////////
  int  shift = iBarShift(_Symbol, PERIOD_D1, time, true);                 //                                  //
  double dayLow = iLow(_Symbol, PERIOD_D1, shift);                        //       |      --|      --|        //
  double level = NormalizeDouble(high - zone * Pp, _Digits);              //      ---       |        |        //
  bool check = false;                                                     //      | |       |-- zone |        //
                                                                          //      | |       |        |        //
  if (range > MinRange && range < MaxRange)                               //      ---     --|- level |        //
   {                                                                      //       |                 |        //
    if ((Extremum && low == dayLow) || !Extremum)                         //       |                 |- range //
     check = true;                                                        //       |                 |        //
    if (open >= level && close >= level && check)                         //       |                 |        //
     {                                                                    //       |                 |        //
      return(true);                                                       //       |                 |        //
     }                                                                    //       |               --|        //
   }                                                                      //                                  //
                                                                          //////////////////////////////////////
  return(false);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrowSellCreate(string name, datetime time, double price)
  {
   ResetLastError();
   doAlert(name);
   
   if(ObjectCreate(0,name,OBJ_ARROW_SELL,0,time,price))
    {
     ObjectSetInteger(0,name,OBJPROP_COLOR,clrTomato);
     ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
     ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
     ObjectSetInteger(0,name,OBJPROP_BACK,true);
     ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
     ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
    }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrowBuyCreate(string name, datetime time, double price)
  {
   ResetLastError();
   doAlert(name);
   
   if(ObjectCreate(0,name,OBJ_ARROW_BUY,0,time,price))
    {
     ObjectSetInteger(0,name,OBJPROP_COLOR,clrDodgerBlue);
     ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
     ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
     ObjectSetInteger(0,name,OBJPROP_BACK,true);
     ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
     ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
    }
  }
//+-----------------------------------------------------------------+
void doAlert(string message)
{
    if (!Sound_Alert)
        return;

    static datetime previousTime;
    if (previousTime != Time[0])
    {
        previousTime   = Time[0];
        Alert(message);
        PlaySound("alert2.wav");
    }
}
