//+------------------------------------------------------------------+
//|                                             MultipleFractals.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

extern int MinFrame=2;
extern int MaxFrame=10;
extern bool UseLastBar=true;
extern color UpColor=Magenta;
extern color DnColor=Red;
extern int FontSize=10;

void DrawNum(int bar, int number, bool Up)
{
 string ObjName=IndicatorObjPrefix + ""+Time[bar];
 double ObjPrice;
 color ObjColor;
 string StrNumber;
 if (Up) 
 {
  ObjName=ObjName+"Up"; 
  ObjPrice=High[bar];
  ObjColor=UpColor;
 }
 else 
 {
  ObjName=ObjName+"Dn";
  ObjPrice=Low[bar];
  ObjColor=DnColor;
 } 
 if (ObjectFind(ObjName)==-1)
 {
  ObjectCreate(ObjName, OBJ_TEXT, 0, Time[bar], ObjPrice);
 }
 ObjectSet(ObjName, OBJPROP_COLOR, ObjColor);
 StrNumber=DoubleToStr(number, 0);
 ObjectSetText(ObjName, StrNumber, FontSize);

 return;
}

void DeleteNum(int bar, bool Up)
{
 string ObjName=IndicatorObjPrefix + ""+Time[bar];
 if (Up) ObjName=ObjName+"Up"; else ObjName=ObjName+"Dn";
 if (ObjectFind(ObjName)!=-1) ObjectDelete(ObjName);
 return;
}

int MaxUpFr(int bar, int MaxFr)
{
 int i;
 for (i=1;i<=MaxFr;i++)
 {
  if (High[bar]<=High[bar-i] || High[bar]<=High[bar+i]) return (i-1);
 }
 return (MaxFr);
}

int MaxDnFr(int bar, int MaxFr)
{
 int i;
 for (i=1;i<=MaxFr;i++)
 {
  if (Low[bar]>=Low[bar-i] || Low[bar]>=Low[bar+i]) return (i-1);
 }
 return (MaxFr);
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
   IndicatorName = GenerateIndicatorName("Multiple fractals");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }

int start()
{
 if(Bars<=MaxFrame) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int MaxF;
 int UpFractalStatus, DnFractalStatus;
 double Wi, Wi1;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 limit=MathMax(limit,MaxFrame);
 pos=limit;
 int Shift;
 if (UseLastBar) Shift=0; else Shift=1;
 while(pos-Shift>=0)
 {
  MaxF=MathMin(pos-Shift, MaxFrame);
  if (MaxF>=MinFrame)
  {
   UpFractalStatus=MaxUpFr(pos, MaxF);
   if (UpFractalStatus>=MinFrame)
   {
    DrawNum(pos, UpFractalStatus, true);
   }
   else
   {
    DeleteNum(pos, true);
   }
   DnFractalStatus=MaxDnFr(pos, MaxF);
   if (DnFractalStatus>=MinFrame)
   {
    DrawNum(pos, DnFractalStatus, false);
   }
   else
   {
    DeleteNum(pos, false);
   }
  }
  pos--;
 } 

 return(0);
}

