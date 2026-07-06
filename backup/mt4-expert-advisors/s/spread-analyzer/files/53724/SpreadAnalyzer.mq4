// Id: 8432
//+------------------------------------------------------------------+
//|                                               SpreadAnalyzer.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

extern bool ShowCurrent=true;
extern bool ShowM1=true;
extern bool ShowM5=true;
extern bool ShowM15=true;
extern bool ShowM30=true;
extern bool ShowH1=true;
extern bool ShowH4=true;
extern bool ShowD1=true;
extern bool ShowW1=true;
extern bool ShowMN=true;
extern color TextColor=Yellow;
extern int Corner=1;
extern int VOffset=5;
extern int HOffset=15;
extern int HStep=15;
extern int TextSize=12;

double MaxM1, MaxM5, MaxM15, MaxM30, MaxH1, MaxH4, MaxD1, MaxW1, MaxMN;
datetime LastM1, LastM5, LastM15, LastM30, LastH1, LastH4, LastD1, LastW1, LastMN;
double Spread;

string ObjName="SpreadAnalyzer";
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
  IndicatorName = GenerateIndicatorName("SpreadAnalyzer");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   return(0);
  }

int deinit()
  {
  ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

   return(0);
  }
  
void DrawRow(int Num, string Text)
{
 string ON=IndicatorObjPrefix + ObjName+DoubleToStr(Num,0);
 if (ObjectFind(ON)==-1) ObjectCreate(ON, OBJ_LABEL, 0, 0, 0);
 ObjectSetText(ON, Text, TextSize);
 ObjectSet(ON, OBJPROP_COLOR, TextColor);
 ObjectSet(ON, OBJPROP_XDISTANCE, VOffset);
 ObjectSet(ON, OBJPROP_YDISTANCE, HOffset+(Num-1)*HStep);
 ObjectSet(ON, OBJPROP_CORNER, Corner);
 return;
}
  
void CheckSpread(double Sp, int Length, datetime& LastTime, double& MaxSp)
{
 if (LastTime==iTime(NULL, Length, 0))
 {
  MaxSp=MathMax(MaxSp, Sp); 
 }
 else
 {
  LastTime=iTime(NULL, Length, 0);
  MaxSp=Sp;
 }
 return;
}  

int start()
  {
   Spread=NormalizeDouble((Ask-Bid)/Point,1);
   CheckSpread(Spread, PERIOD_M1, LastM1, MaxM1);
   CheckSpread(Spread, PERIOD_M5, LastM5, MaxM5);
   CheckSpread(Spread, PERIOD_M15, LastM15, MaxM15);
   CheckSpread(Spread, PERIOD_M30, LastM30, MaxM30);
   CheckSpread(Spread, PERIOD_H1, LastH1, MaxH1);
   CheckSpread(Spread, PERIOD_H4, LastH4, MaxH4);
   CheckSpread(Spread, PERIOD_D1, LastD1, MaxD1);
   CheckSpread(Spread, PERIOD_W1, LastW1, MaxW1);
   CheckSpread(Spread, PERIOD_MN1, LastMN, MaxMN);  
   
   int i=1; 
   
   DrawRow(1, "Spread analyzer:");
   if (ShowCurrent) {i++; DrawRow(i, "Current  spread: "+DoubleToStr(Spread, 1)+" pips"); }
   if (ShowM1) {i++; DrawRow(i, "Max. M1  spread: "+DoubleToStr(MaxM1, 1)+" pips"); }
   if (ShowM5) {i++; DrawRow(i, "Max. M5  spread: "+DoubleToStr(MaxM5, 1)+" pips"); }
   if (ShowM15) {i++; DrawRow(i, "Max. M15 spread: "+DoubleToStr(MaxM15, 1)+" pips"); }
   if (ShowM30) {i++; DrawRow(i, "Max. M30 spread: "+DoubleToStr(MaxM30, 1)+" pips"); }
   if (ShowH1) {i++; DrawRow(i, "Max. H1  spread: "+DoubleToStr(MaxH1, 1)+" pips"); }
   if (ShowH4) {i++; DrawRow(i, "Max. H4  spread: "+DoubleToStr(MaxH4, 1)+" pips"); }
   if (ShowD1) {i++; DrawRow(i, "Max. D1  spread: "+DoubleToStr(MaxD1, 1)+" pips"); }
   if (ShowW1) {i++; DrawRow(i, "Max. W1  spread: "+DoubleToStr(MaxW1, 1)+" pips"); }
   if (ShowMN) {i++; DrawRow(i, "Max. MN  spread: "+DoubleToStr(MaxMN, 1)+" pips"); }
   return(0);
  }

