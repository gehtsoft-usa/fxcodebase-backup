// Id: 8634
//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property show_inputs

extern color TextColor=PaleGreen;
extern color SymbolColor=Yellow;
extern color UpColor=Green;
extern color DnColor=Red;
extern int VOffset=15;
extern int HOffset=15;
extern int VStep=20;
extern int HStep=80;
extern int TextSize=12;

string SL[];
double Volumes[][5];

string ObjName="AllVolumes";

int GetSymbols(string &SymbolsList[])
{

   int FF = FileOpenHistory("symbols.sel", FILE_BIN|FILE_READ);
   if(FF < 0) return(-1);

   int SymbolsNumber = FileSize(FF) / 128;
   ArrayResize(SymbolsList, SymbolsNumber);

   for(int i = 0; i < SymbolsNumber; i++)
   {
      FileSeek(FF, 4, SEEK_CUR);
      SymbolsList[i] = FileReadString(FF, 12);
      FileSeek(FF, 112, SEEK_CUR);
   }
   FileClose(FF);
   return(SymbolsNumber);
}

double GetVolume(string _Symbol, int _Period)
{
 double V0=iVolume(_Symbol, _Period, 0);
 double V1=iVolume(_Symbol, _Period, 1);
 if (V0>=V1) return (V0); else return (-V0);
}

void FillVolumes()
{
 int ArrSize=ArraySize(SL);
 int i;
 double V0, V1;
 ArrayResize(Volumes, ArrSize);
 for (i=0;i<ArrSize;i++)
 {
  Volumes[i][0]=GetVolume(SL[i], PERIOD_M1);
  Volumes[i][1]=GetVolume(SL[i], PERIOD_H1);
  Volumes[i][2]=GetVolume(SL[i], PERIOD_D1);
  Volumes[i][3]=GetVolume(SL[i], PERIOD_W1);
  Volumes[i][4]=GetVolume(SL[i], PERIOD_MN1);
 }
 return;
}

color GetColor(double V)
{
 if (V>=0) return (UpColor); else return (DnColor);
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

void DrawRow(int Num)
{
 string _Symbol, _V_M1, _V_H1, _V_D1, _V_W1, _V_MN;
 color _C_Symbol, _C_M1, _C_H1, _C_D1, _C_W1, _C_MN;
 if (Num==-1)
 {
  _Symbol="Symbol";
  _V_M1="M1";
  _V_H1="H1";
  _V_D1="D1";
  _V_W1="W1";
  _V_MN="MN";
  _C_Symbol=TextColor;
  _C_M1=TextColor;
  _C_H1=TextColor;
  _C_D1=TextColor;
  _C_W1=TextColor;
  _C_MN=TextColor;
 }
 else
 {
  _Symbol=SL[Num];
  _V_M1=DoubleToStr(MathAbs(Volumes[Num][0]), 0);
  _V_H1=DoubleToStr(MathAbs(Volumes[Num][1]), 0);
  _V_D1=DoubleToStr(MathAbs(Volumes[Num][2]), 0);
  _V_W1=DoubleToStr(MathAbs(Volumes[Num][3]), 0);
  _V_MN=DoubleToStr(MathAbs(Volumes[Num][4]), 0);
  _C_Symbol=SymbolColor;
  _C_M1=GetColor(Volumes[Num][0]);
  _C_H1=GetColor(Volumes[Num][1]);
  _C_D1=GetColor(Volumes[Num][2]);
  _C_W1=GetColor(Volumes[Num][3]);
  _C_MN=GetColor(Volumes[Num][4]);
 }
 
 string ON=ObjName+DoubleToStr(Num, 0);
 if (ObjectFind(IndicatorObjPrefix + ON+"S")==-1) ObjectCreate(IndicatorObjPrefix + ON+"S", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(IndicatorObjPrefix + ON+"V1")==-1) ObjectCreate(IndicatorObjPrefix + ON+"V1", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(IndicatorObjPrefix + ON+"V2")==-1) ObjectCreate(IndicatorObjPrefix + ON+"V2", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(IndicatorObjPrefix + ON+"V3")==-1) ObjectCreate(IndicatorObjPrefix + ON+"V3", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(IndicatorObjPrefix + ON+"V4")==-1) ObjectCreate(IndicatorObjPrefix + ON+"V4", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(IndicatorObjPrefix + ON+"V5")==-1) ObjectCreate(IndicatorObjPrefix + ON+"V5", OBJ_LABEL, 0, 0, 0);

 ObjectSetText(IndicatorObjPrefix + ON+"S", _Symbol, TextSize);
 ObjectSet(IndicatorObjPrefix + ON+"S", OBJPROP_COLOR, _C_Symbol);
 ObjectSet(IndicatorObjPrefix + ON+"S", OBJPROP_XDISTANCE, HOffset);
 ObjectSet(IndicatorObjPrefix + ON+"S", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(IndicatorObjPrefix + ON+"S", OBJPROP_CORNER, 4);
 
 ObjectSetText(IndicatorObjPrefix + ON+"V1", _V_M1, TextSize);
 ObjectSet(IndicatorObjPrefix + ON+"V1", OBJPROP_COLOR, _C_M1);
 ObjectSet(IndicatorObjPrefix + ON+"V1", OBJPROP_XDISTANCE, HOffset+HStep);
 ObjectSet(IndicatorObjPrefix + ON+"V1", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(IndicatorObjPrefix + ON+"V1", OBJPROP_CORNER, 4);
 
 ObjectSetText(IndicatorObjPrefix + ON+"V2", _V_H1, TextSize);
 ObjectSet(IndicatorObjPrefix + ON+"V2", OBJPROP_COLOR, _C_H1);
 ObjectSet(IndicatorObjPrefix + ON+"V2", OBJPROP_XDISTANCE, HOffset+2*HStep);
 ObjectSet(IndicatorObjPrefix + ON+"V2", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(IndicatorObjPrefix + ON+"V2", OBJPROP_CORNER, 4);
 
 ObjectSetText(IndicatorObjPrefix + ON+"V3", _V_D1, TextSize);
 ObjectSet(IndicatorObjPrefix + ON+"V3", OBJPROP_COLOR, _C_D1);
 ObjectSet(IndicatorObjPrefix + ON+"V3", OBJPROP_XDISTANCE, HOffset+3*HStep);
 ObjectSet(IndicatorObjPrefix + ON+"V3", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(IndicatorObjPrefix + ON+"V3", OBJPROP_CORNER, 4);
 
 ObjectSetText(IndicatorObjPrefix + ON+"V4", _V_W1, TextSize);
 ObjectSet(IndicatorObjPrefix + ON+"V4", OBJPROP_COLOR, _C_W1);
 ObjectSet(IndicatorObjPrefix + ON+"V4", OBJPROP_XDISTANCE, HOffset+4*HStep);
 ObjectSet(IndicatorObjPrefix + ON+"V4", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(IndicatorObjPrefix + ON+"V4", OBJPROP_CORNER, 4);
 
 ObjectSetText(IndicatorObjPrefix + ON+"V5", _V_MN, TextSize);
 ObjectSet(IndicatorObjPrefix + ON+"V5", OBJPROP_COLOR, _C_MN);
 ObjectSet(IndicatorObjPrefix + ON+"V5", OBJPROP_XDISTANCE, HOffset+5*HStep);
 ObjectSet(IndicatorObjPrefix + ON+"V5", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(IndicatorObjPrefix + ON+"V5", OBJPROP_CORNER, 4);
 
 
 
 return;
}


int init()
{
   IndicatorName = GenerateIndicatorName("AllVolumes");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   return 0;
}


void ShowVolumes()
{
 DrawRow(-1);
 int i;
 int ArrSize=ArraySize(SL);
 for (i=0;i<ArrSize;i++)
 {
  DrawRow(i);
 }
 return;
}

int deinit()
{
 ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}

int start()
  {
   GetSymbols(SL);
   while (true)
   {
    RefreshRates();
    FillVolumes();
    ShowVolumes();
    if (IsStopped())
    {
     break;
    }
    else
    {
     Sleep(1000);
    }
   } 
   return(0);
  }

