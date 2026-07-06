//+------------------------------------------------------------------+
//|                                    Investor_Preference_Index.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern string Instrument="USDJPY";
extern int ROC_Length=24;
extern int MA1_Length=15;
extern int MA2_Length=38;
extern int MA3_Length=54;

double IPI[];
double B1[], B2[];

int init()
{
 IndicatorShortName("Investor preference index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,IPI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,B1);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,B2);

 return(0);
}

int deinit()
{

 return(0);
}

double ROC(string Instr, int index1, int index2)
{
 double Pr1, Pr2;
 double Log2;
 if (Instr=="")
 {
  Pr1=Close[index1];
  Pr2=Close[index2];
 }
 else
 {
  Pr1=iClose(Instr, 0, index1);
  Pr2=iClose(Instr, 0, index2);
 }
 if (Pr1!=0. && Pr2!=0.)
 {
  Log2=MathLog(Pr2);
  if (Log2!=0.)
  {
   return (100.*MathLog(Pr1-Log2)/Log2);
  }
  else
  {
   return (0.);
  }  
 }
 else
 {
  return (0.);
 }
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 int index1, index2;
 pos=limit;
 while(pos>=0)
 {
  index1=iBarShift(Instrument, 0, Time[pos], false);
  index2=iBarShift(Instrument, 0, Time[pos+ROC_Length-1], false);
  
  if (index1>=0 && index2>=0)
  {
   B1[pos]=ROC("", pos, pos+ROC_Length-1)-ROC(Instrument, index1, index2);
  }

  pos--;
 } 
 
 double MA1, MA2;
 pos=limit;
 while(pos>=0)
 {
  MA1=iMAOnArray(B1, 0, MA1_Length, 0, MODE_SMA, pos);
  MA2=iMAOnArray(B1, 0, MA2_Length, 0, MODE_SMA, pos);
  B2[pos]=MA1-MA2;

  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  IPI[pos]=100.*(MA3_Length*iMAOnArray(B2, 0, MA3_Length, 0, MODE_SMA, pos)+1.);

  pos--;
 }  
   
 return(0);
}

