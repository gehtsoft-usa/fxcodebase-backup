//+------------------------------------------------------------------+
//|                                                Generic_Index.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern string Index="USD";
extern bool Inverse=false;
extern string Instrument1="EURUSD";
extern bool Use_Instrument1=true;
extern string Instrument2="USDJPY";
extern bool Use_Instrument2=true;
extern string Instrument3="GBPUSD";
extern bool Use_Instrument3=true;
extern string Instrument4="USDCHF";
extern bool Use_Instrument4=true;
extern string Instrument5="USDCAD";
extern bool Use_Instrument5=true;
extern string Instrument6="NZDUSD";
extern bool Use_Instrument6=true;
extern string Instrument7="AUDUSD";
extern bool Use_Instrument7=true;
extern string Instrument8="USDSEK";
extern bool Use_Instrument8=true;
extern string Instrument9="USDRUB";
extern bool Use_Instrument9=true;
extern string Instrument10="XAUUSD";
extern bool Use_Instrument10=true;

double GI[];
string Instruments[11];
double Weights[11];
double ScaleFactor;

void CalcInstrument(string Instrument, bool Use)
{
 string First, Second;
 int Count=Weights[0];
 if (Use)
 {
  First=StringSubstr(Instrument, 0, 3);
  Second=StringSubstr(Instrument, 3, 3);
  if (Index==First || Index==Second)
  {
   Count++;
   Instruments[Count]=Instrument;
   if (Index==First)
   {
    Weights[Count]=1;
   }
   else
   {
    Weights[Count]=-1;
   } 
  }
 }
 Weights[0]=Count;
 return;
}

void CalcWeights()
{
 int i;
 int InstrCount=Weights[0];
 if (InstrCount>0)
 {
  double X=1.;
  for (i=1;i<=InstrCount;i++)
  {
   Weights[i]=Weights[i]/InstrCount;
   if (Inverse)
   {
    Weights[i]=-Weights[i];
   }
   X=X*MathPow(1, Weights[i]);
  }
 } 
 ScaleFactor=100./X;
 return;
}

int init()
{
 IndicatorShortName("Generic Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,GI);
 
 Instruments[0]=0;
 Weights[0]=0;
 CalcInstrument(Instrument1, Use_Instrument1);
 CalcInstrument(Instrument2, Use_Instrument2);
 CalcInstrument(Instrument3, Use_Instrument3);
 CalcInstrument(Instrument4, Use_Instrument4);
 CalcInstrument(Instrument5, Use_Instrument5);
 CalcInstrument(Instrument6, Use_Instrument6);
 CalcInstrument(Instrument7, Use_Instrument7);
 CalcInstrument(Instrument8, Use_Instrument8);
 CalcInstrument(Instrument9, Use_Instrument9);
 CalcInstrument(Instrument10, Use_Instrument10);
 CalcWeights();
 
 SetLevelValue(0, 100);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 int IndexBar, IndexBar0;
 int i;
 double X;
 double Close1, Close0;
 int Count=Weights[0];
 pos=limit;
 while(pos>=0)
 {
  X=1;
  for (i=1;i<=Count;i++)
  {
   IndexBar=iBarShift(Instruments[i], 0, Time[pos], false);
   IndexBar0=iBarShift(Instruments[i], 0, Time[Bars-1], false);
   Close1=iClose(Instruments[i], 0, IndexBar);
   Close0=iClose(Instruments[i], 0, IndexBar0);
   if (Close0>0)
   {
    X=X*MathPow(Close1/Close0, Weights[i]);
   } 
  }
  GI[pos]=X*ScaleFactor;
  pos--;
 } 
 return(0);
}

