// Id: 23694
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
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers   2
#property indicator_color1    C'71,101,141'
#property indicator_width1    3 
#property indicator_color2    C'112,80,80'
#property indicator_width2    3
#property indicator_minimum   0
#property indicator_maximum   1
//---- input parameters
enum asMode
{
   as_rsi,   // Use RSI mode 
   as_stoch, // Use stochastic mode
   as_adx    // Use ADX mode 
};
extern ENUM_TIMEFRAMES TimeFrame  = PERIOD_CURRENT;
extern int TimeframeShift = 0; // Shift timeframe, times
extern asMode Mode             =  as_rsi; // 0-RSI method; 1-Stoch method; 2-ADX method
extern int    Length           =  9; // Period of evaluation
extern int    Smooth           =  1; // Period of smoothing
extern int    Signal           =  4; // Period of Signal Line
extern int    Price            =  0; // Price mode : 0-Close,1-Open,2-High,3-Low,4-Median,5-Typical,6-Weighted
extern ENUM_MA_METHOD ModeMA   =  MODE_EMA; // Mode of Moving Average
extern double OverBought       =  80; // OverBought Level
extern double OverSold         =  20; // OverSold Level 
extern bool   alertsOn         = true;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;
extern bool   ShowArrows       = true;
extern string arrowsIdentifier = "abs Arrows1";
extern double arrowsUpperGap   = 1.0;
extern double arrowsLowerGap   = 1.0;
extern color  arrowsUpColor    = DeepSkyBlue;
extern color  arrowsDnColor    = C'239,16,16';
extern int    arrowsUpCode     = 233;
extern int    arrowsDnCode     = 234;
  
double Bulls[];
double Bears[];
double AvgBulls[];
double AvgBears[];
double SmthBulls[];
double SmthBears[];
double SigBulls[];
double SigBears[];

bool     returnBars;
string   indicatorFileName;
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int init()
{
   TF = TimeFrame;
   for (int i = 0; i < TimeframeShift; ++i)
   {
      TF = GetNextTimeframe(TF);
   }
   IndicatorBuffers(8);
   SetIndexBuffer(0,SigBulls); SetIndexStyle(0,DRAW_HISTOGRAM); SetIndexLabel(0,"Bulls");
   SetIndexBuffer(1,SigBears); SetIndexStyle(1,DRAW_HISTOGRAM); SetIndexLabel(1,"Bears");
   SetIndexBuffer(2,SmthBulls);
   SetIndexBuffer(3,SmthBears);
   SetIndexBuffer(4,Bulls);
   SetIndexBuffer(5,Bears);
   SetIndexBuffer(6,AvgBulls);
   SetIndexBuffer(7,AvgBears);
   SetIndexDrawBegin(0,Length+Smooth+Signal);
   SetIndexDrawBegin(1,Length+Smooth+Signal);
   SetIndexDrawBegin(2,Length+Smooth+Signal);
   SetIndexDrawBegin(3,Length+Smooth+Signal);

         //
         //
         //
         //
         //
                  
         indicatorFileName = WindowExpertName();
         returnBars        = (TF==-99);
         TF         = MathMax(TF,_Period);
         
         //
         //
         //
         //
         //

   IndicatorName = GenerateIndicatorName(timeFrameToString(TF)+" AbsoluteStrength(" + IntegerToString(Mode) + "," + IntegerToString(Length) + ","+ IntegerToString(Smooth) + "," + IntegerToString(Signal) + "," + IntegerToString(ModeMA) + ")");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   return(0);
}

//
//
//
//
//

int deinit() 
{  
   deleteArrows(); 
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   
return(0); 
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double trend[];
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars - 1,Bars-2);
         if (returnBars) { SigBulls[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
   
   if (TF==Period())
   {
      if (ArraySize(trend)!=Bars) ArrayResize(trend,Bars);
      for(int shift=limit; shift>=0; shift--)
      {
         double Price1 = iMA(NULL,0,1,0,MODE_SMA,Price,shift);
         double Price2 = iMA(NULL,0,1,0,MODE_SMA,Price,shift+1); 
      
         if (Mode==0)
         {
            Bulls[shift] = 0.5*(MathAbs(Price1-Price2)+(Price1-Price2));
            Bears[shift] = 0.5*(MathAbs(Price1-Price2)-(Price1-Price2));
            continue;
         }
         if (Mode==1)
         {
            Bulls[shift] = Price1 - Low[Lowest(NULL,0,MODE_LOW,Length,shift)];
            Bears[shift] = High[Highest(NULL,0,MODE_HIGH,Length,shift)] - Price1;
            continue;
         }
         if (Mode==2)
         {
            Bulls[shift] = 0.5*(MathAbs(High[shift]-High[shift+1])+(High[shift]-High[shift+1]));
            Bears[shift] = 0.5*(MathAbs(Low[shift+1]-Low[shift])+(Low[shift+1]-Low[shift]));
         }
      }

      //
      //
      //
      //
      //
         
      for(int shift=limit; shift>=0; shift--)
      {
         AvgBulls[shift]=iMAOnArray(Bulls,0,Length,0,ModeMA,shift);     
         AvgBears[shift]=iMAOnArray(Bears,0,Length,0,ModeMA,shift);
      }
      for(int shift=limit; shift>=0; shift--)
      {
         int r = Bars - shift - 1;
         SmthBulls[shift]=iMAOnArray(AvgBulls,0,Smooth,0,ModeMA,shift);     
         SmthBears[shift]=iMAOnArray(AvgBears,0,Smooth,0,ModeMA,shift);
         SigBulls[shift] = EMPTY_VALUE;
         SigBears[shift] = EMPTY_VALUE;
         trend[r] = trend[r - 1];
            if (SmthBulls[shift]>SmthBears[shift]) trend[r] =  1;
            if (SmthBulls[shift]<SmthBears[shift]) trend[r] = -1;
            if (trend[r]== 1) SigBulls[shift] = 1;
            if (trend[r]==-1) SigBears[shift] = 1;
            
            //
            //
            //
            //
            //
            
            if (ShowArrows)
               {
                 deleteArrow(Time[shift]);
                 if (trend[r] != trend[r-1])
                 {
                   if (trend[r] == 1)  drawArrow(shift,arrowsUpColor,arrowsUpCode,false);
                   if (trend[r] ==-1)  drawArrow(shift,arrowsDnColor,arrowsDnCode, true);
                 }
              }
      }
      
      manageAlerts();
      return(0);
   }
   
   //
   //
   //
   //
   //

   limit = (int)MathMax(limit,MathMin(Bars,iCustom(NULL,TF,indicatorFileName,-99,0,0)*TF/Period()));
   for (int i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,TF,Time[i]);
         SigBulls[i] = iCustom(NULL,TF,indicatorFileName,PERIOD_CURRENT,Mode,Length,Smooth,Signal,Price,ModeMA,OverBought,OverSold,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,0,y);
         SigBears[i] = iCustom(NULL,TF,indicatorFileName,PERIOD_CURRENT,Mode,Length,Smooth,Signal,Price,ModeMA,OverBought,OverSold,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,ShowArrows,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,1,y);
   }
   return(0);         
}



//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      int forBar = Bars - (alertsOnCurrent ? 0 : 1) - 1;
      if (trend[forBar]!=trend[forBar-1])
      {
         if (trend[forBar]== 1) doAlert(0,"up");
         if (trend[forBar]==-1) doAlert(0,"down");
      }            
   }
}

//
//
//
//
//
 
void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

          //
          //
          //
          //
          //

          message =  timeFrameToString(_Period)+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" absolute strength changed trend to "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"  absolute strength"),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+TimeToStr(Time[i]);
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(IndicatorObjPrefix + name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(IndicatorObjPrefix + name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(IndicatorObjPrefix + name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(IndicatorObjPrefix + name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(IndicatorObjPrefix + name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

//
//
//
//
//

void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+TimeToStr(time); ObjectDelete(lookFor);
}

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}