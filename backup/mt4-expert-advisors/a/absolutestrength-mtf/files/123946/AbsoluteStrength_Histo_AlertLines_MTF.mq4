// Id: 23954
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67282

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
#property version   "1.1"
#property strict

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 1
#property indicator_buffers 2
#property indicator_color1 C'71,101,141'
#property indicator_color2 C'112,80,80'
#property indicator_width1 3
#property indicator_width2 3

extern ENUM_TIMEFRAMES TimeFrame  = PERIOD_CURRENT;
extern int TimeframeShift = 0; // Shift timeframe, times

extern int    Length =  9; // Period
extern int    Smooth =  1; // Period of smoothing
extern int    Signal =  4; // Period of Signal Line
extern ENUM_MA_METHOD ModeMA = MODE_LWMA; // Mode of Moving Average
extern int    SuperSignalsPeriod = 96;   

extern bool   ShowAlertLines   = true;
extern int    BarsToCountLines = 500;
extern color  LineUpColor      = C'71,124,141';
extern color  LineDnColor      = C'141,82,71';
extern ENUM_LINE_STYLE LinesStyle = STYLE_DOT;
extern int    LinesWidth       = 1;
extern string SignalName       ="ASH line";
extern string AlertSound       ="alert2";
extern bool   AlertsOn         = false;
extern bool   AlertsMesage     = false;
extern bool   AlertsSound      = false;
extern bool   AlertsEmail      = false;
extern bool AlertOnBarClose = false; // Alert on bar close

double Bulls[],Bears[],AvgBulls[],AvgBears[],SmthBulls[],SmthBears[],SigBulls[],SigBears[],b1[],b2[];
double Price1,Price2,hhb,llb;
bool   UpTrend = false;
bool   DnTrend = false;
int    maxArrows;
int    shift=SuperSignalsPeriod/2;
int alertIndex = 0;

ENUM_TIMEFRAMES TF;

ENUM_TIMEFRAMES GetNextTimeframe(const ENUM_TIMEFRAMES timeframe)
{
   switch (timeframe)
   {
      case PERIOD_M1:
         return PERIOD_M5;
      case PERIOD_M5:
         return PERIOD_M15;
      case PERIOD_D1:
         return PERIOD_W1;
      case PERIOD_MN1:
      case PERIOD_W1:
         return PERIOD_MN1;
      case PERIOD_H1:
         return PERIOD_H4;
      case PERIOD_H4:
         return PERIOD_D1;
      case PERIOD_M15:
         return PERIOD_M30;
      case PERIOD_M30:
         return PERIOD_H1;
      case PERIOD_CURRENT:
         return GetNextTimeframe((ENUM_TIMEFRAMES)_Period);
   }
   return timeframe;
}

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
//-------------------------------------------------------------------+
int deinit() 
{
   if (ShowAlertLines) 
      DeleteArrows(); 
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}
//+------------------------------------------------------------------+

int init()
{
   TF = TimeFrame;
   for (int i = 0; i < TimeframeShift; ++i)
   {
      TF = GetNextTimeframe(TF);
   }
   IndicatorBuffers(10);
   SetIndexBuffer(0,SigBulls); SetIndexStyle(0,DRAW_HISTOGRAM); SetIndexLabel(0,"Bulls");
   SetIndexBuffer(1,SigBears); SetIndexStyle(1,DRAW_HISTOGRAM); SetIndexLabel(1,"Bears");
   SetIndexBuffer(2,SmthBulls); 
   SetIndexBuffer(3,SmthBears); 
   SetIndexBuffer(4,Bulls);
   SetIndexBuffer(5,Bears);
   SetIndexBuffer(6,AvgBulls);
   SetIndexBuffer(7,AvgBears);
   SetIndexBuffer(8,b1);
   SetIndexBuffer(9,b2);
   if (AlertOnBarClose)
      alertIndex = 1;
   
   IndicatorName = GenerateIndicatorName(timeFrameToString(TF)+" Absolute Strenght histogram (" + IntegerToString(Length) + "," + IntegerToString(Smooth) + "," + IntegerToString(Signal) + "," + IntegerToString(SuperSignalsPeriod) + ")");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   SetIndexDrawBegin(0,Length+Smooth+Signal);
   SetIndexDrawBegin(1,Length+Smooth+Signal);
   SetIndexDrawBegin(2,Length+Smooth+Signal);
   SetIndexDrawBegin(3,Length+Smooth+Signal);
 
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);
   SetIndexEmptyValue(6,0.0);
   SetIndexEmptyValue(7,0.0);
   return(0);
}

//+------------------------------------------------------------------+

int stratBTF()
{
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) 
      return -1;
   
   int limit = Bars;
   if (counted_bars == 0) 
      limit = limit - Length + Smooth + Signal - 1;
   else
      limit -= counted_bars;
   limit--;
   
   for (int i = limit; i >= 0; i--)
   {
      int period = iBarShift(_Symbol, TF, Time[i]);
      SigBulls[i] = iCustom(_Symbol, TF, "AbsoluteStrength_Histo_AlertLines_MTF", TF, 0, 
         Length, Smooth, Signal, ModeMA, SuperSignalsPeriod, false, 0, period);
      SigBears[i] = iCustom(_Symbol, TF, "AbsoluteStrength_Histo_AlertLines_MTF", TF, 0, 
         Length, Smooth, Signal, ModeMA, SuperSignalsPeriod, false, 1, period);
   }
   if (AlertsOn)
   {
      if (SigBulls[alertIndex] > 0 && SigBulls[alertIndex + 1] == 0 && b2[alertIndex] > 0)
         doAlert(" BUY alert @ ");
      if (SigBears[alertIndex] > 0 && SigBears[alertIndex + 1] == 0 && b1[alertIndex] > 0)
         doAlert(" SELL alert @ ");
   }
   if (ShowAlertLines)
   {
      DeleteArrows();
      for (int i = alertIndex; i<BarsToCountLines ;i++)
      {
         if (SigBulls[i]>0 && SigBulls[i+1]==0 && b2[i]>0) DrawArrow(i,"up");
         if (SigBears[i]>0 && SigBears[i+1]==0 && b1[i]>0) DrawArrow(i,"down");
      }
   }
           
   return(0);
}

int start()
{
   if (TF != _Period && TF != PERIOD_CURRENT)
      return stratBTF();

   int limit = 0;
   int i, counted_bars=IndicatorCounted();
   if (counted_bars < 0) 
      return(-1);
   if (counted_bars ==0) 
      limit=Bars-Length+Smooth+Signal-1;
   if (counted_bars < 1)
   {
      for(i=1;i<Length+Smooth+Signal;i++) 
      {
         Bulls[Bars-i]=0;    
         Bears[Bars-i]=0;  
         AvgBulls[Bars-i]=0;    
         AvgBears[Bars-i]=0;  
         SmthBulls[Bars-i]=0;    
         SmthBears[Bars-i]=0;  
         SigBulls[Bars-i]=0;    
         SigBears[Bars-i]=0;  
      }
   }

   if(counted_bars>0) 
      limit = Bars - counted_bars;
   limit--;
   
   for (i=limit; i>=0; i--)
   {
      Price1 = iMA(NULL,0,1,0,0,0,i);
      Price2 = iMA(NULL,0,1,0,0,0,i+1); 
      Bulls[i] = 0.5*(MathAbs(Price1-Price2)+(Price1-Price2));
      Bears[i] = 0.5*(MathAbs(Price1-Price2)-(Price1-Price2));
      AvgBulls[i] = iMAOnArray(Bulls,0,Length,0,ModeMA,i);     
      AvgBears[i] = iMAOnArray(Bears,0,Length,0,ModeMA,i);
      SmthBulls[i] = iMAOnArray(AvgBulls,0,Smooth,0,ModeMA,i);     
      SmthBears[i] = iMAOnArray(AvgBears,0,Smooth,0,ModeMA,i);
      if (SmthBulls[i] - SmthBears[i] > 0)
      {
         SigBulls[i] = 1;
         SigBears[i] = 0;
      } 
      else
      {
         SigBears[i] = 1;
         SigBulls[i] = 0;
      } 
   }
   
   for (i=limit; i>=shift; i--)
   {
      hhb = Highest(NULL,0,MODE_HIGH,SuperSignalsPeriod,i-shift);
      llb = Lowest(NULL,0,MODE_LOW,SuperSignalsPeriod,i-shift);
      if (i==hhb)
      {
         b1[i]=1;
         DnTrend=true;
         UpTrend=false;
      } 
      else if (i==llb)
      {
         b2[i]=1;
         UpTrend=true;
         DnTrend=false;
      }
      else if (DnTrend==true)
      {
         b1[i]=b1[i+1];
         b2[i]=0;
      }
      else if (UpTrend==true)
      {
         b2[i]=b2[i+1];
         b1[i]=0;
      }
   }

   if (AlertsOn)
   {
      if (SigBulls[0]>0 && SigBulls[1]==0 && b2[0]>0) doAlert(" BUY alert @ ");
      if (SigBears[0]>0 && SigBears[1]==0 && b1[0]>0) doAlert(" SELL alert @ ");
   }
   if (ShowAlertLines)
   {
      DeleteArrows();
      for (i=0; i<BarsToCountLines ;i++)
      {
         if (SigBulls[i]>0 && SigBulls[i+1]==0 && b2[i]>0) DrawArrow(i,"up");
         if (SigBears[i]>0 && SigBears[i+1]==0 && b1[i]>0) DrawArrow(i,"down");
      }
   }
           
   return(0);
}

//+------------------------------------------------------------------+

void DrawArrow(int i,string type)
{
   maxArrows++;
   string name  = StringConcatenate(SignalName,maxArrows);
            
   ObjectCreate(IndicatorObjPrefix + name,OBJ_VLINE,0,Time[i],0);
   
   if (type=="up")
   {
      ObjectSet(IndicatorObjPrefix + name,OBJPROP_STYLE,LinesStyle);    
      ObjectSet(IndicatorObjPrefix + name,OBJPROP_WIDTH,LinesWidth);    
      ObjectSet(IndicatorObjPrefix + name,OBJPROP_COLOR,LineUpColor);
      ObjectSet(IndicatorObjPrefix + name,OBJPROP_BACK, true);
   }
   else if (type=="down")
   {
      ObjectSet(IndicatorObjPrefix + name,OBJPROP_STYLE,LinesStyle);
      ObjectSet(IndicatorObjPrefix + name,OBJPROP_WIDTH,LinesWidth);
      ObjectSet(IndicatorObjPrefix + name,OBJPROP_COLOR,LineDnColor);
      ObjectSet(IndicatorObjPrefix + name,OBJPROP_BACK, true);
   }
}

//--------------------------------------------------------------------

void DeleteArrows()
{
   while(maxArrows>0) { ObjectDelete(StringConcatenate(SignalName,maxArrows));maxArrows--; }
}

//+-------------------------------------------------------------------

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[0]) 
   {
      previousAlert  = doWhat;
      previousTime   = Time[0];
      message = timeFrameToString(TF)+" ASH "+Symbol()+doWhat+DoubleToStr(Close[0],Digits);
      if (AlertsMesage) Alert(message);
      if (AlertsSound)  PlaySound("alert2.wav");
      if (AlertsEmail)  SendMail(StringConcatenate(Symbol(),"ASH "),message);
   }
} 

//--------------------------------------------------------------------

string sTfTable[] = {"M1","M2","M3","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,2,3,5,10,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
      if (tf==iTfTable[i]) return(sTfTable[i]);
   return("");
}

//--------------------------------------------------------------------
