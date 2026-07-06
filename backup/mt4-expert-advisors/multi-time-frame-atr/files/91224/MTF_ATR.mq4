// Id: 10578
//+------------------------------------------------------------------+
//|                                                      MTF_ATR.mq4 |
//|                               Copyright � 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

extern string Instrument="";
extern int ATR_Length=14;
extern int TF1=1;       // M1
extern int TF2=5;       // M5
extern int TF3=15;      // M15
extern int TF4=30;      // M30
extern int TF5=60;      // H1
extern int TF6=240;     // H4
extern int TF7=1440;    // D1
extern int TF8=10080;   // W1
extern int TF9=43200;   // MN
extern double Gate=0;
extern color UpColor=Green;
extern color DnColor=Red;
extern color NeutralColor=Blue;

string Instr;
string IndName;

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
 IndicatorDigits(Digits);

 if (Instrument=="") Instr=Symbol(); else Instr=Instrument;
 
 IndName="Multi Time Frame ATR "+Instr;
 IndicatorName = GenerateIndicatorName(IndName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   return 0;

 return(0);
}

double CalcATR(int Length, int TF, int& Direction)
{
 double ATR0=iATR(Instr, TF, Length, 0);
 double ATR1=iATR(Instr, TF, Length, 1);
 if (ATR0-ATR1>=Gate)
 {
  Direction=1;
 }
 else
 {
  if (ATR0-ATR1<=-Gate)
  {
   Direction=-1;
  }
  else
  {
   Direction=0;
  }
 }
 return (ATR0);
}

int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
 return(0);
}

string StringTF(int TF)
{
 if (TF==1) return ("M1");
 if (TF==5) return ("M5");
 if (TF==15) return ("M15");
 if (TF==30) return ("M30");
 if (TF==60) return ("H1");
 if (TF==240) return ("H4");
 if (TF==1440) return ("D1");
 if (TF==10080) return ("W1");
 if (TF==43200) return ("MN");
 return ("");
}

void DrawATR(int Num, int TF)
{
 int Dir;
 double ATR=CalcATR(ATR_Length, TF, Dir);

 string D;
 color Clr;
  
 if (Dir==1)
 {
  D=CharToStr(225); 
  Clr=UpColor;
 }
 else if (Dir==-1)
 {
  D=CharToStr(226); 
  Clr=DnColor;
 }
 else 
 {
  D=CharToStr(223);
  Clr=NeutralColor;
 }
   
 int WindowNumber=WindowFind(IndicatorName);
 if (WindowNumber!=-1)
 {
  string ObjName=IndicatorObjPrefix + "L_"+WindowNumber+"_"+Num+"_1";
  if (ObjectFind(ObjName)==-1)
  {
   ObjectCreate(ObjName, OBJ_LABEL, WindowNumber, 0, 0);
  }
  ObjectSet(ObjName, OBJPROP_XDISTANCE, 20+(Num-1)*150); 
  ObjectSet(ObjName, OBJPROP_YDISTANCE, 10); 
  ObjectSetText(ObjName, Instr, 12, "Arial", Clr);

  ObjName=IndicatorObjPrefix + "L_"+WindowNumber+"_"+Num+"_2";
  if (ObjectFind(ObjName)==-1)
  {
   ObjectCreate(ObjName, OBJ_LABEL, WindowNumber, 0, 0);
  }
  ObjectSet(ObjName, OBJPROP_XDISTANCE, 20+(Num-1)*150); 
  ObjectSet(ObjName, OBJPROP_YDISTANCE, 30); 
  ObjectSetText(ObjName, StringTF(TF), 12, "Arial", Clr);

  ObjName=IndicatorObjPrefix + "L_"+WindowNumber+"_"+Num+"_3";
  if (ObjectFind(ObjName)==-1)
  {
   ObjectCreate(ObjName, OBJ_LABEL, WindowNumber, 0, 0);
  }
  ObjectSet(ObjName, OBJPROP_XDISTANCE, 20+(Num-1)*150); 
  ObjectSet(ObjName, OBJPROP_YDISTANCE, 50); 
  ObjectSetText(ObjName, "ATR "+DoubleToStr(ATR, Digits), 12, "Arial", Clr);

  ObjName=IndicatorObjPrefix + "L_"+WindowNumber+"_"+Num+"_4";
  if (ObjectFind(ObjName)==-1)
  {
   ObjectCreate(ObjName, OBJ_LABEL, WindowNumber, 0, 0);
  }
  ObjectSet(ObjName, OBJPROP_XDISTANCE, 20+(Num-1)*150); 
  ObjectSet(ObjName, OBJPROP_YDISTANCE, 70); 
  ObjectSetText(ObjName, D, 12, "Wingdings", Clr);

 }
 
 return;
}

int start()
{
 DrawATR(9, TF1);
 DrawATR(8, TF2);
 DrawATR(7, TF3);
 DrawATR(6, TF4);
 DrawATR(5, TF5);
 DrawATR(4, TF6);
 DrawATR(3, TF7);
 DrawATR(2, TF8);
 DrawATR(1, TF9);
 
 return(0);
}


