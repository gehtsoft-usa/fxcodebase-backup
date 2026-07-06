//+------------------------------------------------------------------+
//|                                               Custom_Pattern.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Yellow

extern string Pattern="UND";
extern bool ShowReversePattern=true;

double Direct[], Reverse[];
int LengthPattern;

int init()
  {
   IndicatorShortName("Custom pattern");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_ARROW,0,1);
   SetIndexArrow(0,119);
   SetIndexBuffer(0,Direct);
   SetIndexStyle(1,DRAW_ARROW,0,1);
   SetIndexArrow(1,119);
   SetIndexBuffer(1,Reverse);
   LengthPattern=StringLen(StringTrimLeft(StringTrimRight(Pattern)));
   return(0);
  }

int deinit()
  {

   return(0);
  }
  
bool DirectPattern(int shift)  
{
 int i;
 string s;
 string Pat=StringTrimLeft(StringTrimRight(Pattern));
 bool Fl=true;
 for (i=1;i<=LengthPattern;i++)
 {
  s=StringSubstr(Pat, LengthPattern-i, 1);
  if ((s=="u" || s=="U") && (Close[shift+i-1]<=Open[shift+i-1])) Fl=false;
  if ((s=="d" || s=="D") && (Close[shift+i-1]>=Open[shift+i-1])) Fl=false;
 }
 return (Fl);
}

bool ReversePattern(int shift)
{
 int i;
 string s;
 string Pat=StringTrimLeft(StringTrimRight(Pattern));
 bool Fl=true;
 for (i=1;i<=LengthPattern;i++)
 {
  s=StringSubstr(Pat, LengthPattern-i, 1);
  if ((s=="u" || s=="U") && (Close[shift+i-1]>=Open[shift+i-1])) Fl=false;
  if ((s=="d" || s=="D") && (Close[shift+i-1]<=Open[shift+i-1])) Fl=false;
 }
 return (Fl);
}

int start()
{
 if(Bars<=LengthPattern) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  if (DirectPattern(pos))
  {
   Direct[pos]=High[pos];
  }
  if (ShowReversePattern)
  {
   if (ReversePattern(pos))
   {
    Reverse[pos]=High[pos];
   }
  }
  pos--;
 }

 return(0);
}

