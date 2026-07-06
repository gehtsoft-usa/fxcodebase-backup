// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=32374

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                         https://AppliedMachineLearning.systems   |
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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"

#property indicator_chart_window
#property indicator_buffers 14

extern color LabelColor = Blue;

extern color PivotColor = Blue;
extern int PivotStyle =  STYLE_SOLID;  

extern color R1Color = Green;
extern int R1Style  = STYLE_SOLID;  
extern color R2Color = Green;
extern int R2Style  = STYLE_SOLID; 
extern color R3Color = Green;
extern int R3Style  = STYLE_SOLID; 

extern color S1Color = Red;
extern int S1Style  = STYLE_SOLID;  
extern color S2Color = Red;
extern int S2Style  = STYLE_SOLID; 
extern color S3Color = Red;
extern int S3Style  = STYLE_SOLID; 

extern bool  Show_MR_Level           = true;
extern bool  Show_MS_Level           = true;

extern color MR1Color = Gray;
extern int MR1Style  = STYLE_SOLID;  
extern color MR2Color = Gray;
extern int MR2Style  = STYLE_SOLID; 
extern color MR3Color = Gray;
extern int MR3Style  = STYLE_SOLID; 

extern color MS1Color = Gray;
extern int MS1Style  = STYLE_SOLID;  
extern color MS2Color = Gray;
extern int MS2Style  = STYLE_SOLID; 
extern color MS3Color = Gray;
extern int MS3Style  = STYLE_SOLID; 
 
//---- input parameters

extern bool Zero = true;
extern bool One = true;
extern bool Two = true;
extern bool Three = true;

extern string  TimePeriod="D1";

enum ENUM_TYPE
{
   Pivot, // Pivot
   Camarilla, // Camarilla
   Woodie, // Woodie
   Fibonacci, // Fibonacci
   Floor, // Floor
   Fibonacci_Retracement // Fibonacci Retracement
};

extern ENUM_TYPE Type = Pivot;

enum ENUM_MODE
{
   Today, // Today
   History // History
};

extern ENUM_MODE Mode = Today;

//---- buffers
datetime time1;
datetime time2;
string Sup1 = "S 1", Res1 = "R 1";
string Sup2="S 2", Res2="R 2", Sup3="S 3", Res3="R 3";
int fontsize = 10;
double P, S1, R1, S2, R2, S3, R3,period;
double  MS1, MR1, MS2, MR2, MS3, MR3;
double x,num;
double bools[];
double p_arr[];
double s1_arr[];
double s2_arr[];
double s3_arr[];
double r1_arr[];
double r2_arr[];
double r3_arr[];
double ms1_arr[];
double ms2_arr[];
double ms3_arr[];
double mr1_arr[];
double mr2_arr[];
double mr3_arr[];

string EAName = "Pivot";
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

void PlotLine(string name,double value,double line_color,double style)
{
   ObjectCreate(IndicatorObjPrefix + name,OBJ_TREND,0,time1,value,time2,value);
   ObjectSet(IndicatorObjPrefix + name, OBJPROP_WIDTH, 1);
   ObjectSet(IndicatorObjPrefix + name, OBJPROP_STYLE, style);
   ObjectSet(IndicatorObjPrefix + name, OBJPROP_RAY, false);
   ObjectSet(IndicatorObjPrefix + name, OBJPROP_BACK, true);
   ObjectSet(IndicatorObjPrefix + name, OBJPROP_COLOR, line_color);
}

void ObjDel()
{
   for (int index=1;index<=10000;index++)
   {
      if (bools[index] == 1)
      {
         ObjectDelete(EAName + "PP["+index+"]");
         ObjectDelete(EAName + "R1["+index+"]");
         ObjectDelete(EAName + "R2["+index+"]");
         ObjectDelete(EAName + "R3["+index+"]");
         ObjectDelete(EAName + "S1["+index+"]");
         ObjectDelete(EAName + "S2["+index+"]");
         ObjectDelete(EAName + "S3["+index+"]"); 
         
         ObjectDelete(EAName + "MR1["+index+"]");
         ObjectDelete(EAName + "MR2["+index+"]");
         ObjectDelete(EAName + "MR3["+index+"]");
         ObjectDelete(EAName + "MS1["+index+"]");
         ObjectDelete(EAName + "MS2["+index+"]");
         ObjectDelete(EAName + "MS3["+index+"]"); 
      }
   }
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

int init()
{
   IndicatorName = GenerateIndicatorName("Pivot");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   EAName = IndicatorObjPrefix;
   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, bools);
   if (Mode == History)
   {
      SetIndexStyle(1, DRAW_LINE, PivotStyle, 1, PivotColor);
      SetIndexBuffer(1, p_arr);
      SetIndexStyle(2, DRAW_LINE, S1Style, 1, S1Color);
      SetIndexBuffer(2, s1_arr);
      SetIndexStyle(3, DRAW_LINE, S2Style, 1, S2Color);
      SetIndexBuffer(3, s2_arr);
      SetIndexStyle(4, DRAW_LINE, S3Style, 1, S3Color);
      SetIndexBuffer(4, s3_arr);
      SetIndexStyle(5, DRAW_LINE, R1Style, 1, R1Color);
      SetIndexBuffer(5, r1_arr);
      SetIndexStyle(6, DRAW_LINE, R2Style, 1, R2Color);
      SetIndexBuffer(6, r2_arr);
      SetIndexStyle(7, DRAW_LINE, R3Style, 1, R3Color);
      SetIndexBuffer(7, r3_arr);
      SetIndexStyle(8, DRAW_LINE, MS1Style, 1, MS1Color);
      SetIndexBuffer(8, ms1_arr);
      SetIndexStyle(9, DRAW_LINE, MS2Style, 1, MS2Color);
      SetIndexBuffer(9, ms2_arr);
      SetIndexStyle(10, DRAW_LINE, MS3Style, 1, MS3Color);
      SetIndexBuffer(10, ms3_arr);
      SetIndexStyle(11, DRAW_LINE, MR1Style, 1, MR1Color);
      SetIndexBuffer(11, mr1_arr);
      SetIndexStyle(12, DRAW_LINE, MR2Style, 1, MR2Color);
      SetIndexBuffer(12, mr2_arr);
      SetIndexStyle(13, DRAW_LINE, MR3Style, 1, MR3Color);
      SetIndexBuffer(13, mr3_arr);
   }

   if (TimePeriod=="M1" || TimePeriod=="1") 
      period=PERIOD_M1;
   else if (TimePeriod=="M5" || TimePeriod=="5") 
      period=PERIOD_M5;
   else if (TimePeriod=="M15" || TimePeriod=="15") 
      period=PERIOD_M15;
   else if (TimePeriod=="M30" || TimePeriod=="30") 
      period=PERIOD_M30;
   else if (TimePeriod=="H1" || TimePeriod=="60") 
      period=PERIOD_H1;
   else if (TimePeriod=="H4" || TimePeriod=="240") 
      period=PERIOD_H4;
   else if (TimePeriod=="D1" || TimePeriod=="1440") 
      period=PERIOD_D1;
   else if (TimePeriod=="W1" || TimePeriod=="10080") 
      period=PERIOD_W1; 
   else if (TimePeriod=="MN" || TimePeriod=="43200") 
      period=PERIOD_MN1;
   else
   {
      Comment("Wrong TimePeriod. Must be M5, M15, M30, H1, H4, D1, W1 or MN"); 
   }

   //---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Pivot Point");
   SetIndexLabel(0, "Pivot Point");
   //----
   SetIndexDrawBegin(0,1);
   //----
   return(0);
}

void CalcPivot(const int i, double &p, 
   double &s1, double &s2, double &s3,
   double &r1, double &r2, double &r3)
{
   double high  = iHigh(NULL,period,i+1);
   double low   = iLow(NULL,period,i+1);
   double open  = iOpen(NULL,period,i+1);
   double close = iClose(NULL,period,i+1);
   switch (Type)
   {
      case Pivot:
         p = (high + low + close ) / 3;
         r1 = (2 * p) - low;
         s1 = (2 * p) - high;
         r2 = p + (high - low);
         s2 = p - (high - low);
         r3 = p + (high - low) * 2;
         s3 = p - (high - low) * 2;
         break;
      case Camarilla:
         p = close;
         r1 = p + (high - low) * 1.1 / 12;
         s1 = p - (high - low) * 1.1 / 12;
         r2 = p + (high - low) * 1.1 / 6;
         s2 = p - (high - low) * 1.1 / 6;
         r3 = p + (high - low) * 1.1 / 4;
         s3 = p - (high - low) * 1.1 / 4;
         break;
      case Woodie:
         p = open;
         r1 = p * 2 - low;
         s1 = p * 2 - high;
         r2 = p + (high - low);
         s2 = p - (high - low);
         r3 = high + 2 * (p - low);
         s3 = low - 2 * (high - p);
         break;
      case Fibonacci:
         p = (high + low + close ) / 3;
         r1 = p+ 0.382 * (high - low);
         s1 =  p- 0.382 * (high - low);
         r2 =  p+ 0.618 *(high - low);
         s2 = p - 0.618 *(high - low);
         r3 = p+ (high - low);
         s3 =  p- (high - low);
         break;
      case Floor:
         p = (high + low + close ) / 3; 
         r1 = p*2+ low;
         s1 =  high;
         r2 =  p+(high - low);
         s2 = p -(high - low);
         r3 = high+ (p - low)*2;
         s3 =  low - (high - p)*2;
         break;
      case Fibonacci_Retracement:
         p = (high + low)/2;
         r1 = low + (high - low) * 0.618;
         s1 = low + (high - low) * 0.382;
         r2 = low+(high - low) * 0.764;
         s2 = low+(high - low) * 0.236;
         r3 = low+(high - low) * 1;
         s3 = low+(high - low) * 0;
         break;
   }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   if (period <= Period()) 
   {
      return (0);
   }
   
   int limit;
   if(counted_bars == 0)
   {
      if (Zero)
      {
         ObjectCreate(EAName + "Pivot", OBJ_TEXT, 0, 0, 0);
         ObjectSetText(EAName + "Pivot", "                 Pivot Point", fontsize, "Arial", LabelColor);
      }
      if (One)
      {
         ObjectCreate(EAName + "Sup1", OBJ_TEXT, 0, 0, 0);
         ObjectSetText(EAName + "Sup1", "      S 1", fontsize, "Arial", LabelColor);
         ObjectCreate(EAName + "Res1", OBJ_TEXT, 0, 0, 0);
         ObjectSetText(EAName + "Res1", "      R 1", fontsize, "Arial", LabelColor);
         
         if (Show_MS_Level)
         {
            ObjectCreate(EAName + "MSup1", OBJ_TEXT, 0, 0, 0);
            ObjectSetText(EAName + "MSup1", "      MS 1", fontsize, "Arial", LabelColor);
         }
         
         if(Show_MR_Level)
         {
            ObjectCreate(EAName + "MRes1", OBJ_TEXT, 0, 0, 0);
            ObjectSetText(EAName + "MRes1", "      MR 1", fontsize, "Arial", LabelColor);
         }
      }
      if (Two)
      { 
         ObjectCreate(EAName + "Sup2", OBJ_TEXT, 0, 0, 0);
         ObjectSetText(EAName + "Sup2", "      S 2", fontsize, "Arial", LabelColor);
         ObjectCreate(EAName + "Res2", OBJ_TEXT, 0, 0, 0);
         ObjectSetText(EAName + "Res2", "      R 2", fontsize, "Arial", LabelColor);
         if(Show_MR_Level)
         {
            ObjectCreate(EAName + "MSup2", OBJ_TEXT, 0, 0, 0);
            ObjectSetText(EAName + "MSup2", "      MS 2", fontsize, "Arial", LabelColor);
         }
         if(Show_MR_Level)
         {
            ObjectCreate(EAName + "MRes2", OBJ_TEXT, 0, 0, 0);
            ObjectSetText(EAName + "MRes2", "      MR 2", fontsize, "Arial", LabelColor);
         }
      }
      if (Three)
      {
         ObjectCreate(EAName + "Sup3", OBJ_TEXT, 0, 0, 0);
         ObjectSetText(EAName + "Sup3", "      S 3", fontsize, "Arial", LabelColor);
         ObjectCreate(EAName + "Res3", OBJ_TEXT, 0, 0, 0);
         ObjectSetText(EAName + "Res3", "      R 3", fontsize, "Arial", LabelColor);
         if(Show_MR_Level)
         {
            ObjectCreate(EAName + "MSup3", OBJ_TEXT, 0, 0, 0);
            ObjectSetText(EAName + "MSup3", "      MS 3", fontsize, "Arial", LabelColor);
         }
         if(Show_MR_Level)
         {
            ObjectCreate(EAName + "MRes3", OBJ_TEXT, 0, 0, 0);
            ObjectSetText(EAName + "MRes3", "      MR 3", fontsize, "Arial", LabelColor);
         }
      }
   }
   if(counted_bars < 0) 
      return(-1);
   limit = (Bars - counted_bars) - 1;
   switch (Mode)
   {
      case Today:
         time1 = iTime(NULL,period, 0);  
         time2 = time1 + (time1 - iTime(NULL,period, 1));
         DrawToday(0);
         break;
      case History:
         for (int i = limit; i >= 0; --i)
         {
            DrawHistory(i);
         }
         break;
   }
   return(0);
}

void DrawHistory(const int i)
{
   double p;
   double s1;
   double s2;
   double s3;
   double r1;
   double r2;
   double r3;
   int btf_i = iBarShift(NULL, period, iTime(NULL, _Period, i));
   CalcPivot(btf_i, p, s1, s2, s3, r1, r2, r3);
   if (Zero)
   {
      p_arr[i] = p;
   }
   if (One)
   {
      s1_arr[i] = s1;
      r1_arr[i] = r1;
   }
   if (Two)
   {
      s2_arr[i] = s2;
      r2_arr[i] = r2;
   }
   if (Three)
   {
      s3_arr[i] = s3;
      r3_arr[i] = r3;
   }
   if (Show_MR_Level)
   {
      mr1_arr[i] = p + (r1 - p) / 2;
      mr2_arr[i] = r1+(r2-r1)/2;
      mr3_arr[i] = r2+(r3-r2)/2;
   }
   if (Show_MS_Level)
   {
      ms1_arr[i] = p-(p-s1)/2;
      ms2_arr[i] = s1-(s1-s2)/2;
      ms3_arr[i] = s2-(s2-s3)/2;
   }
}

void DrawToday(const int i)
{
   double p;
   double s1;
   double s2;
   double s3;
   double r1;
   double r2;
   double r3;
   CalcPivot(i, p, s1, s2, s3, r1, r2, r3);

   MR1=p+(r2-p)/2;
   MR2=r1+(r2-r1)/2;
   MR3=r2+(r3-r2)/2;
   
   MS1=p-(p-s1)/2;
   MS2=s1-(s1-s2)/2;
   MS3=s2-(s2-s3)/2;
   ObjectMove(EAName + "Pivot", 0, Time[i], p);
   ObjectMove(EAName + "Sup1", 0, Time[i], s1);
   ObjectMove(EAName + "Res1", 0, Time[i], r1);
   ObjectMove(EAName + "Sup2", 0, Time[i], s2);
   ObjectMove(EAName + "Res2", 0, Time[i], r2);
   ObjectMove(EAName + "Sup3", 0, Time[i], s3);
   ObjectMove(EAName + "Res3", 0, Time[i], r3);    

   if(Show_MR_Level)
   {
      ObjectMove(EAName + "MSup1", 0, Time[i], MS1);
      ObjectMove(EAName + "MSup2", 0, Time[i], MS2);
      ObjectMove(EAName + "MSup3", 0, Time[i], MS3);
   }
   
   if(Show_MS_Level)
   {
      ObjectMove(EAName + "MRes1", 0, Time[i], MR1);   
      ObjectMove(EAName + "MRes2", 0, Time[i], MR2);
      ObjectMove(EAName + "MRes3", 0, Time[i], MR3);    
   }
   
   if (Zero)
   {
      PlotLine(EAName + "PP["+i+"]",p,PivotColor,PivotStyle);
   }
   if (One)
   {
      PlotLine(EAName + "R1["+i+"]",r1,R1Color,R1Style);
      PlotLine(EAName + "S1["+i+"]",s1,S1Color,S1Style);
      if(Show_MR_Level)
      {
         PlotLine(EAName + "MR1["+i+"]",MR1,MR1Color,MR1Style);
      }
      if(Show_MS_Level)
      {
         PlotLine(EAName + "MS1["+i+"]",MS1,MS1Color,MS1Style);
      }
   }
   if (Two)
   {
      PlotLine(EAName + "R2["+i+"]",r2,R2Color,R2Style);
      PlotLine(EAName + "S2["+i+"]",s2,S2Color,S2Style);
      
      if(Show_MR_Level)
      {
         PlotLine(EAName + "MR2["+i+"]",MR2,MR2Color,MR2Style);
      }
      if(Show_MS_Level)
      {
         PlotLine(EAName + "MS2["+i+"]",MS2,MS2Color,MS2Style);
      }
   }

   if (Three)
   {
      PlotLine(EAName + "R3["+i+"]",r3,R3Color,R3Style);
      PlotLine(EAName + "S3["+i+"]",s3,S3Color,S3Style);
      if(Show_MR_Level)
      {  
         PlotLine(EAName + "MR3["+i+"]",MR3,MR3Color,MR3Style);
      }
      if(Show_MS_Level)
      {
         PlotLine(EAName + "MS3["+i+"]",MS3,MS3Color,MS3Style);
      }
   }
   bools[i] = 1;
}
//+------------------------------------------------------------------+