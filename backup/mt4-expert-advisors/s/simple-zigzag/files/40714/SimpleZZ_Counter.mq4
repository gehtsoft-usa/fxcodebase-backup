// Id: 7481
//+------------------------------------------------------------------+
//|                                             SimpleZZ_Counter.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow

extern int Method=0;      // 0 - Step in pips
                          // 1 - Step in percent
extern double Step=100;
extern int FontSize=10;
extern color TextColor=Yellow;

double Direction[], MinBar[], MaxBar[];
double MinPrice[], MaxPrice[];
double StepPoint;

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
   IndicatorName = GenerateIndicatorName("Simple ZigZag with counter");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_ZIGZAG);
   SetIndexBuffer(0,MinPrice);
   SetIndexStyle(1,DRAW_ZIGZAG);
   SetIndexBuffer(1,MaxPrice);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,Direction);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,MinBar);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,MaxBar);
   StepPoint=Step*Point;
   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }
  
void DeleteLabels(double startBar, double endBar, string Pos, bool E)
{
 int i;
 int obj_total=ObjectsTotal();
 string obj_name;
 datetime obj_time;
 for (i=obj_total-1;i>=0;i--)
 {
  obj_name=ObjectName(i);
  if (ObjectType(obj_name)!=OBJ_TEXT) continue;
  obj_time=ObjectGet(obj_name, OBJPROP_TIME1);
  if (((obj_time>=startBar && E) || obj_time>startBar) && obj_time<=endBar && StringFind(obj_name, Pos)!=-1)
  {
   ObjectDelete(obj_name);
  }
 }
 return;
}  

string TextFormat(int bars, double pips)
{
 return (""+(DoubleToStr(MathAbs(bars)+1,0))+" bars, "+DoubleToStr(MathFloor(MathAbs(pips)/Point+0.5),0)+" pips");
}

void DrawLabel(int bar1, int bar2, double price1, double price2)
{
 int Nbar1=iBarShift(NULL, 0, bar1);
 int Nbar2=iBarShift(NULL, 0, bar2);
 string Str=TextFormat(Nbar1-Nbar2, price1-price2);
 string obj_name=IndicatorObjPrefix + ""+bar2;
 if (price2==High[Nbar2]) obj_name=obj_name+"U"; else obj_name=obj_name+"D";
 ObjectCreate(obj_name, OBJ_TEXT, 0, bar2, price2);
 ObjectSetText(obj_name, Str, FontSize, "Arial", TextColor);
 ObjectSet(obj_name, OBJPROP_PRICE1, price2);
 return;
}
  
void CalculateUp(int bar, double price)
{
 int LastBar=iBarShift(NULL, 0, MaxBar[bar]);
 int IntBar;
 if (MaxPrice[LastBar]==EMPTY_VALUE)
 {
  MaxPrice[LastBar]=High[LastBar];
 }
 if (price>MaxPrice[LastBar])
 {
  MaxPrice[LastBar]=EMPTY_VALUE;
  MaxPrice[bar]=price;
  MaxBar[bar]=Time[bar];
  if (MinBar[bar]!=EMPTY_VALUE)
  {
   IntBar=iBarShift(NULL, 0, MinBar[bar]);
   if (MaxPrice[IntBar]!=High[IntBar])
   {
    DeleteLabels(MinBar[bar], Time[bar], "U", true);
   }
   else
   {
    DeleteLabels(MinBar[bar], Time[bar], "U", false);
   }
   DeleteLabels(MinBar[bar], Time[bar], "D", false); 
   IntBar=iBarShift(NULL, 0, MinBar[bar]);
   DrawLabel(MinBar[bar], Time[bar], MinPrice[IntBar], price);
  }
  LastBar=bar;
 }
 if ((price+StepPoint<MaxPrice[LastBar] && Method==0) || (price*(1+Step/100)<MaxPrice[LastBar] && Method!=0))
 {
  Direction[bar]=-1;
  MinPrice[bar]=price;
  MinBar[bar]=Time[bar];
  if (MaxBar[bar]!=EMPTY_VALUE)
  {
   IntBar=iBarShift(NULL, 0, MaxBar[bar]);
   if (MinPrice[IntBar]!=Low[IntBar])
   {
    DeleteLabels(MaxBar[bar], Time[bar], "D", true);
   }
   else
   {
    DeleteLabels(MaxBar[bar], Time[bar], "D", false);
   } 
   DeleteLabels(MaxBar[bar], Time[bar], "U", false);
   IntBar=iBarShift(NULL, 0, MaxBar[bar]);
   DrawLabel(MaxBar[bar], Time[bar], MaxPrice[IntBar], price);
  }
 }
 return;
}  

void CalculateDn(int bar, double price)
{
 int LastBar=iBarShift(NULL, 0, MinBar[bar]);
 int IntBar;
 if (MinPrice[LastBar]==EMPTY_VALUE)
 {
  MinPrice[LastBar]=Low[LastBar];
 }
 if (price<MinPrice[LastBar])
 {
  MinPrice[LastBar]=EMPTY_VALUE;
  MinPrice[bar]=price;
  MinBar[bar]=Time[bar];
  if (MaxBar[bar]!=EMPTY_VALUE)
  {
   IntBar=iBarShift(NULL, 0, MaxBar[bar]);
   if (MinPrice[IntBar]!=Low[IntBar])
   {
    DeleteLabels(MaxBar[bar], Time[bar], "D", true);
   }
   else
   {
    DeleteLabels(MaxBar[bar], Time[bar], "D", false);
   } 
   DeleteLabels(MaxBar[bar], Time[bar], "U", false);
   IntBar=iBarShift(NULL, 0, MaxBar[bar]);
   DrawLabel(MaxBar[bar], Time[bar], MaxPrice[IntBar], price);
  }
  LastBar=bar;
 }
 if ((price-StepPoint>MinPrice[LastBar] && Method==0) || (price*(1-Step/100)>MinPrice[LastBar] && Method!=0))
 {
  Direction[bar]=1;
  MaxPrice[bar]=price;
  MaxBar[bar]=Time[bar];
  if (MinBar[bar]!=EMPTY_VALUE)
  {
   IntBar=iBarShift(NULL, 0, MinBar[bar]);
   if (MaxPrice[IntBar]!=High[IntBar])
   {
    DeleteLabels(MinBar[bar], Time[bar], "U", true);
   }
   else
   {
    DeleteLabels(MinBar[bar], Time[bar], "U", false);
   } 
   DeleteLabels(MinBar[bar], Time[bar], "D", false);
   IntBar=iBarShift(NULL, 0, MinBar[bar]);
   DrawLabel(MinBar[bar], Time[bar], MinPrice[IntBar], price);
  }
 }
 return;
}  

void Calculate(int bar, double price)
{
 if (Direction[bar]==1) CalculateUp(bar, price); else CalculateDn(bar, price);
 return;
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   Direction[pos]=1;
   MinBar[pos]=Time[pos];
   MaxBar[pos]=Time[pos];
   if (Close[pos]>Open[pos])
   {
    MinPrice[pos]=High[pos];
    MaxPrice[pos]=High[pos];
   }
   else
   {
    MinPrice[pos]=Low[pos];
    MaxPrice[pos]=Low[pos];
   }
  }
  else
  {
   MinBar[pos]=MinBar[pos+1];
   MaxBar[pos]=MaxBar[pos+1];
   Direction[pos]=Direction[pos+1];
   MinPrice[pos]=EMPTY_VALUE;
   MaxPrice[pos]=EMPTY_VALUE;
   if (Close[pos]<Open[pos])
   {
    Calculate(pos, High[pos]);
    Calculate(pos, Low[pos]);
   }
   else
   {
    Calculate(pos, Low[pos]);
    Calculate(pos, High[pos]);
   }
  }
  pos--;
 } 

 return(0);
}

