// Id: 9090
//+------------------------------------------------------------------+
//|                                                    Conqueror.mq4 |
//|                               Copyright � 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int MVA_Period=10;
extern int Range_Period1=10;
extern int Range_Period2=40;

double Up[], Dn[], Neutral[];

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
    IndicatorName = GenerateIndicatorName("Conqueror");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Up);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,Dn);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,Neutral);

   return(0);
  }

int deinit()
{
 ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
 return(0);
}
  
void CheckAndDeleteArrow(int bar)  
{
 string ObjName=IndicatorObjPrefix + "Conqueror"+Time[bar];
 if (ObjectFind(ObjName)!=-1)
 {
  ObjectDelete(ObjName);
 }
 return ;
}

void DrawArrow(int bar, int Status)
{
 string ObjName=IndicatorObjPrefix + "Conqueror"+Time[bar];
 if (ObjectFind(ObjName)==-1)
 {
  ObjectCreate(ObjName, OBJ_ARROW, 0, Time[bar], Close[bar]);
 }
 ObjectSet(ObjName, OBJPROP_PRICE1, Low[bar]);
 if (Status==0)
 {
  ObjectSet(ObjName, OBJPROP_COLOR, indicator_color1);
  ObjectSet(ObjName, OBJPROP_ARROWCODE, 241);
 } 
 if (Status==1)
 {
  ObjectSet(ObjName, OBJPROP_COLOR, indicator_color2);
  ObjectSet(ObjName, OBJPROP_ARROWCODE, 242);
 }
 if (Status==2)
 {
  ObjectSet(ObjName, OBJPROP_COLOR, indicator_color3);
  ObjectSet(ObjName, OBJPROP_ARROWCODE, 242);
 } 
 if (Status==3)
 {
  ObjectSet(ObjName, OBJPROP_COLOR, indicator_color3);
  ObjectSet(ObjName, OBJPROP_ARROWCODE, 241);
 } 
  
 return ;
}

int start()
{
 int    counted_bars=IndicatorCounted();
   
 if(Bars<=MathMax(MVA_Period, MathMax(Range_Period1, Range_Period2))) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  double MA0=iMA(NULL, 0, MVA_Period, 0, MODE_SMA, PRICE_CLOSE, pos);
  double MA1=iMA(NULL, 0, MVA_Period, 0, MODE_SMA, PRICE_CLOSE, pos+Range_Period1);
  Up[pos]=0;
  Dn[pos]=0;
  Neutral[pos]=0;
  if (Close[pos]>MA0 && MA0>MA1 && Close[pos]>Close[pos+Range_Period2])
  {
   Up[pos]=1;
  }
  else
  {
   if (Close[pos]<MA0 && MA0<MA1 && Close[pos]<Close[pos+Range_Period2])
   {
    Dn[pos]=1;
   }
   else
   {
    Neutral[pos]=1;
   }
  }
  
  if (Up[pos]==1 && Up[pos+1]==0)
  {
   DrawArrow(pos, 0);
  }
  if (Dn[pos]==1 && Up[pos+1]==0)
  {
   DrawArrow(pos, 1);
  }
  if (Neutral[pos]==1 && Neutral[pos+1]==0)
  {
   if (Up[pos+1]==1)
   {
    DrawArrow(pos, 2);
   }
   else
   {
    DrawArrow(pos, 3);
   }
  }
  if (Up[pos]==Up[pos+1] && Dn[pos]==Dn[pos+1] && Neutral[pos]==Neutral[pos+1])
  {
   CheckAndDeleteArrow(pos);
  }
  
  pos--;
 } 
 return(0);
}

