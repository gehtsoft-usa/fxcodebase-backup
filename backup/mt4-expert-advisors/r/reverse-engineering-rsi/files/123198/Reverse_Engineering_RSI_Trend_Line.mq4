//+------------------------------------------------------------------+
//|                           Reverse_Engineering_RSI_Trend_Line.mq4 |
//|                               Copyright © 2019, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow

#define StartLineName "RERSIStart"
#define EndLineName "RERSIEnd"

extern int RSI_Length=14;
extern int MA_Length=45;
extern ENUM_MA_METHOD MA_Method=MODE_SMA;
extern ENUM_APPLIED_PRICE Price=PRICE_CLOSE;
extern color Start_Line_Color=clrGreen;
extern color End_Line_Color=clrRed;

double RE_RSI[];
double auc[], adc[], RSI[], Pr[];
int ExpLength;

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
 IndicatorName = GenerateIndicatorName("Reverse Engineering RSI Trend line");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RE_RSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,auc);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,adc);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,RSI);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Pr);
 
 ExpLength=2*RSI_Length-1;
 
 ObjectCreate(ChartID(), IndicatorObjPrefix + StartLineName, OBJ_VLINE, 0, Time[10], 0);
 ObjectCreate(ChartID(), IndicatorObjPrefix + EndLineName, OBJ_VLINE, 0, Time[1], 0);
 
 ObjectSet(IndicatorObjPrefix + StartLineName, OBJPROP_COLOR, Start_Line_Color);
 ObjectSet(IndicatorObjPrefix + EndLineName, OBJPROP_COLOR, End_Line_Color);

 return(0);
}

int deinit()
{
  ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

 return(0);
}

int GetStartLine()
{
 datetime T=ObjectGet(IndicatorObjPrefix + StartLineName, OBJPROP_TIME1);
 int B=iBarShift(NULL, 0, T, false);
 
 return (B);
}

int GetEndLine()
{
 datetime T=ObjectGet(IndicatorObjPrefix + EndLineName, OBJPROP_TIME1);
 int B=iBarShift(NULL, 0, T, false);
 
 return (B);
}

int start()
{
 if(Bars<=3) return(0);
 int limit=Bars-2;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (Pr[pos]>Pr[pos+1])
  {
   auc[pos]=Pr[pos]-Pr[pos+1];
   adc[pos]=0.;
  }
  else
  {
   auc[pos]=0.;
   adc[pos]=Pr[pos+1]-Pr[pos];
  }
  
  RSI[pos]=iRSI(NULL, 0, RSI_Length, Price, pos);

  pos--;
 }  
 
 double AUC_MA, ADC_MA, RSI_MA, x;
 pos=limit;
 int StartB=GetStartLine();
 int EndB=GetEndLine();

 double Slope=(RSI[EndB]-RSI[StartB])/MathAbs(StartB-EndB);
 double Raw;
 
 while(pos>=0)
 {
  Raw=RSI[StartB]+(StartB-pos)*Slope;
  Raw=MathMin(Raw, 100.);
  Raw=MathMax(Raw, 0.);
  
  AUC_MA=iMAOnArray(auc, 0, ExpLength, 0, MODE_EMA, pos);
  ADC_MA=iMAOnArray(adc, 0, ExpLength, 0, MODE_EMA, pos);
  
  if (Raw!=100.)
  {
   x=(RSI_Length-1.)*(ADC_MA*Raw/(100.-Raw)-AUC_MA);
  }
  else
  {
   x=0.;
  } 
  
  if (x>=0. || RSI_MA==0.)
  {
   RE_RSI[pos]=Pr[pos]+x;
  }
  else
  {
   RE_RSI[pos]=Pr[pos]+x*(100.-RSI_MA)/RSI_MA;
  }

  pos--;
 }  
 
 return(0);
}

void OnChartEvent(const int id,         // идентификатор события   
                  const long& lparam,   // параметр события типа long 
                  const double& dparam, // параметр события типа double 
                  const string& sparam  // параметр события типа string 
  )
  
{
 if(Bars<=3) return(0);
 
 if (id==CHARTEVENT_OBJECT_CLICK)
 {
  start();
 }
}



