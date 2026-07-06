// Id: 19144
//+------------------------------------------------------------------+
//|                                  Choppy_Market_ADX_Indicator.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 10
#property indicator_color4 Green
#property indicator_color5 Red
#property indicator_color6 Green
#property indicator_color7 Red

extern int Length=14;
extern double Alpha1=0.25;
extern double Alpha2=0.33;
extern int Level=25;
extern color Zone_Color=Green;

#define IndName "CM_ADX"

double Second[], Signal[], Cross[];
double Up[], Dn[];
double LUp[], LDn[];

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
     double temp = iCustom(NULL, 0, "Smoothed_ADX", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Smoothed_ADX' indicator");
       return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("Choppy_Market_ADX_Indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_NONE);
 SetIndexBuffer(0,Second);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Cross);
 SetIndexBuffer(3,Up);
 SetIndexStyle(3,DRAW_ARROW,0,4);
 SetIndexArrow(3,217);
 SetIndexBuffer(4,Dn);
 SetIndexStyle(4,DRAW_ARROW,0,4);
 SetIndexArrow(4,218);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,LUp);
 SetIndexStyle(6,DRAW_LINE);
 SetIndexBuffer(6,LDn);

 return(0);
}

void DeleteRecs()
{
 long current_chart_id=ChartID();

 int i;
 int OCount=ObjectsTotal(current_chart_id, EMPTY);
 string ObjName;
 for (i=OCount; i>=0; i--)
 {
  ObjName=ObjectName(i);
  if (ObjectType(ObjName)==OBJ_RECTANGLE)
  {
   if (StringFind(ObjName, IndName)>-1)
   {
    ObjectDelete(current_chart_id, ObjName);
   } 
  }
 }

 return;
}

int deinit()
{
 DeleteRecs();
 ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

 return(0);
}

void Last(int index, double &_Line, double &_X)
{
 int i;
 _Line=0.;
 _X=0.;
 for (i=index; i<Bars-2; i++)
 {
  if (Signal[i]==1. || Signal[i]==-1.)
  {
   _X=Signal[i];
   if (Signal[i]==1.)
   {
    _Line=High[i];
   }
   else
   {
    _Line=Low[i];
   }
   
   return;
  }
 }
 
 return;
}

void DrawRec(int index, int i1, int i2, double Min, double Max)
{
 string ObjName=IndicatorObjPrefix + IndName+"_"+Time[index];
 long current_chart_id=ChartID(); 
 if (ObjectFind(current_chart_id, ObjName)>=0)
 {
  ObjectDelete(current_chart_id, ObjName);
 }
 
 ObjectCreate(current_chart_id, ObjName, OBJ_RECTANGLE, 0, Time[i1], Min, Time[i2], Max);
 ObjectSet(ObjName, OBJPROP_COLOR, Zone_Color);
 
 return;
}

int FindNext(int index, double Cross_Level, int side)
{
 int i;
 
 for (i=index; i>=0; i--)
 {
  if ((Close[i]>Cross_Level && Close[i+1]<=Cross_Level && side==1) || (Close[i]<Cross_Level && Close[i+1]>=Cross_Level && side==-1))
  {
   return (i);
  }
 }
 
 return (-1);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double S_ADX0, S_DIP0, S_DIP1, S_DIM0, S_DIM1;
 double Line, X;
 pos=limit;
 while(pos>=0)
 {
  S_ADX0=iCustom(NULL, 0, "Smoothed_ADX", Length, Alpha1, Alpha2, 2, pos);
  S_DIP0=iCustom(NULL, 0, "Smoothed_ADX", Length, Alpha1, Alpha2, 0, pos);
  S_DIP1=iCustom(NULL, 0, "Smoothed_ADX", Length, Alpha1, Alpha2, 0, pos+1);
  S_DIM0=iCustom(NULL, 0, "Smoothed_ADX", Length, Alpha1, Alpha2, 1, pos);
  S_DIM1=iCustom(NULL, 0, "Smoothed_ADX", Length, Alpha1, Alpha2, 1, pos+1);
  
  if (S_ADX0<Level)
  {
   Signal[pos]=1.;
  }
  else
  {
   Signal[pos]=0.;
  }
  
  if (S_DIP0>S_DIM0 && S_DIP1<=S_DIM1)
  {
   Cross[pos]=1.;
  }

  if (S_DIP0<S_DIM0 && S_DIP1>=S_DIM1)
  {
   Cross[pos]=-1.;
  }
  
  Second[pos]=0.;
  
  Last(pos, Line, X);
  
  if (X==1. && Close[pos]>Line && Close[pos+1]<=Line)
  {
   Second[pos]=1.;
  }

  if (X==-1. && Close[pos]<Line && Close[pos+1]>=Line)
  {
   Second[pos]=-1.;
  }

  pos--;
 } 
 
 pos=limit;
 int p1, p2, p3, ii;
 double Min, Max;
 p1=0; 
 p2=0;
 while(pos>=0)
 {
  if (Signal[pos]==1. && Signal[pos+1]!=1.)
  {
   p1=pos;
   p2=0;
  }
  
  if ((Signal[pos+1]==1. && Signal[pos]!=1.) || (Signal[pos]==1. && pos==0))
  {
   p2=pos;
  }
  
  if (p1!=0 && p2!=0)
  {
   Min=Low[ArrayMinimum(Low, p1-p2+1, p2)];
   Max=High[ArrayMaximum(High, p1-p2+1, p2)];
   DrawRec(pos, p1, p2, Min, Max);
  }
  
  if (Cross[pos]==1.)
  {
   Up[pos]=Low[pos];
   
   p3=FindNext(pos, High[pos], 1);
   if (p3>-1)
   {
    Up[p3]=Low[p3];
    
   }
  }
  
  if (Cross[pos]==-1.)
  {
   Dn[pos]=High[pos];

   p3=FindNext(pos, Low[pos], -1);
   if (p3>-1)
   {
    Dn[p3]=High[p3];
    
   }
  }

  pos--;
 }
   
 return(0);
}

