// Id: 8638
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

extern int Length=10;
extern int Method=1;
extern int Price=0;
extern int Window=1;
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
double MAs[][5];
int Digit[];

string ObjName="AllMAs";

int GetSymbols(string &SymbolsList[])
{

   int FF = FileOpenHistory("symbols.sel", FILE_BIN|FILE_READ);
   if(FF < 0) return(-1);

   int SymbolsNumber = FileSize(FF) / 128;
   ArrayResize(SymbolsList, SymbolsNumber);
   ArrayResize(Digit, SymbolsNumber);

   for(int i = 0; i < SymbolsNumber; i++)
   {
      FileSeek(FF, 4, SEEK_CUR);
      SymbolsList[i] = FileReadString(FF, 12);
      Digit[i]=MarketInfo(SymbolsList[i], MODE_DIGITS); 
      FileSeek(FF, 112, SEEK_CUR);
   }
   FileClose(FF);
   return(SymbolsNumber);
}

double GetMA(string _Symbol, int _Period)
{
 double MA0=iMA(_Symbol, _Period, Length, 0, Method, Price, 0);
 double MA1=iMA(_Symbol, _Period, Length, 0, Method, Price, Window);
 if (MA0>=MA1) return (MA0); else return (-MA0);
}

void FillMAs()
{
 int ArrSize=ArraySize(SL);
 int i;
 double V0, V1;
 ArrayResize(MAs, ArrSize);
 for (i=0;i<ArrSize;i++)
 {
  MAs[i][0]=GetMA(SL[i], PERIOD_M1);
  MAs[i][1]=GetMA(SL[i], PERIOD_H1);
  MAs[i][2]=GetMA(SL[i], PERIOD_D1);
  MAs[i][3]=GetMA(SL[i], PERIOD_W1);
  MAs[i][4]=GetMA(SL[i], PERIOD_MN1);
 }
 return;
}

color GetColor(double V)
{
 if (V>=0) return (UpColor); else return (DnColor);
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
  _V_M1=DoubleToStr(MathAbs(MAs[Num][0]), Digit[Num]);
  _V_H1=DoubleToStr(MathAbs(MAs[Num][1]), Digit[Num]);
  _V_D1=DoubleToStr(MathAbs(MAs[Num][2]), Digit[Num]);
  _V_W1=DoubleToStr(MathAbs(MAs[Num][3]), Digit[Num]);
  _V_MN=DoubleToStr(MathAbs(MAs[Num][4]), Digit[Num]);
  _C_Symbol=SymbolColor;
  _C_M1=GetColor(MAs[Num][0]);
  _C_H1=GetColor(MAs[Num][1]);
  _C_D1=GetColor(MAs[Num][2]);
  _C_W1=GetColor(MAs[Num][3]);
  _C_MN=GetColor(MAs[Num][4]);
 }
 
 string ON=ObjName+DoubleToStr(Num, 0);
 if (ObjectFind(IndicatorObjPrefix+ ON+"S")==-1) ObjectCreate(IndicatorObjPrefix+ ON+"S", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(IndicatorObjPrefix+ ON+"V1")==-1) ObjectCreate(IndicatorObjPrefix+ ON+"V1", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(IndicatorObjPrefix+ ON+"V2")==-1) ObjectCreate(IndicatorObjPrefix+ ON+"V2", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(IndicatorObjPrefix+ ON+"V3")==-1) ObjectCreate(IndicatorObjPrefix+ ON+"V3", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(IndicatorObjPrefix+ ON+"V4")==-1) ObjectCreate(IndicatorObjPrefix+ ON+"V4", OBJ_LABEL, 0, 0, 0);
 if (ObjectFind(IndicatorObjPrefix+ ON+"V5")==-1) ObjectCreate(IndicatorObjPrefix+ ON+"V5", OBJ_LABEL, 0, 0, 0);

 ObjectSetText(IndicatorObjPrefix+ ON+"S", _Symbol, TextSize);
 ObjectSet(IndicatorObjPrefix+ ON+"S", OBJPROP_COLOR, _C_Symbol);
 ObjectSet(IndicatorObjPrefix+ ON+"S", OBJPROP_XDISTANCE, HOffset);
 ObjectSet(IndicatorObjPrefix+ ON+"S", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(IndicatorObjPrefix+ ON+"S", OBJPROP_CORNER, 4);
 
 ObjectSetText(IndicatorObjPrefix+ ON+"V1", _V_M1, TextSize);
 ObjectSet(IndicatorObjPrefix+ ON+"V1", OBJPROP_COLOR, _C_M1);
 ObjectSet(IndicatorObjPrefix+ ON+"V1", OBJPROP_XDISTANCE, HOffset+HStep);
 ObjectSet(IndicatorObjPrefix+ ON+"V1", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(IndicatorObjPrefix+ ON+"V1", OBJPROP_CORNER, 4);
 
 ObjectSetText(IndicatorObjPrefix+ ON+"V2", _V_H1, TextSize);
 ObjectSet(IndicatorObjPrefix+ ON+"V2", OBJPROP_COLOR, _C_H1);
 ObjectSet(IndicatorObjPrefix+ ON+"V2", OBJPROP_XDISTANCE, HOffset+2*HStep);
 ObjectSet(IndicatorObjPrefix+ ON+"V2", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(IndicatorObjPrefix+ ON+"V2", OBJPROP_CORNER, 4);
 
 ObjectSetText(IndicatorObjPrefix+ ON+"V3", _V_D1, TextSize);
 ObjectSet(IndicatorObjPrefix+ ON+"V3", OBJPROP_COLOR, _C_D1);
 ObjectSet(IndicatorObjPrefix+ ON+"V3", OBJPROP_XDISTANCE, HOffset+3*HStep);
 ObjectSet(IndicatorObjPrefix+ ON+"V3", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(IndicatorObjPrefix+ ON+"V3", OBJPROP_CORNER, 4);
 
 ObjectSetText(IndicatorObjPrefix+ ON+"V4", _V_W1, TextSize);
 ObjectSet(IndicatorObjPrefix+ ON+"V4", OBJPROP_COLOR, _C_W1);
 ObjectSet(IndicatorObjPrefix+ ON+"V4", OBJPROP_XDISTANCE, HOffset+4*HStep);
 ObjectSet(IndicatorObjPrefix+ ON+"V4", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(IndicatorObjPrefix+ ON+"V4", OBJPROP_CORNER, 4);
 
 ObjectSetText(IndicatorObjPrefix+ ON+"V5", _V_MN, TextSize);
 ObjectSet(IndicatorObjPrefix+ ON+"V5", OBJPROP_COLOR, _C_MN);
 ObjectSet(IndicatorObjPrefix+ ON+"V5", OBJPROP_XDISTANCE, HOffset+5*HStep);
 ObjectSet(IndicatorObjPrefix+ ON+"V5", OBJPROP_YDISTANCE, VOffset+(Num+1)*VStep);
 ObjectSet(IndicatorObjPrefix+ ON+"V5", OBJPROP_CORNER, 4);
 
 
 
 return;
}

void ShowMAs()
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


int init()
{
   IndicatorName = GenerateIndicatorName("AllMAs");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   return 0;
}

int deinit()
{
 ObjectsDeleteAll(ChartID(), IndicatorObjPrefix); 
 return;
}

int start()
  {
   GetSymbols(SL);
   while (true)
   {
    RefreshRates();
    FillMAs();
    ShowMAs();
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

