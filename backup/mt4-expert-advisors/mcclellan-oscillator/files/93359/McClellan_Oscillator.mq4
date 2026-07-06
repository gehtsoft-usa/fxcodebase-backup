//+------------------------------------------------------------------+
//|                                         McClellan_Oscillator.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern string BaseCurrency="USD";
extern int Short_Length=19;
extern int Long_Length=39;

double MO[];
double RANA[];
string SL[];
bool Inv[];
int SNum;

int GetSymbols(string &SymbolsList[], bool &Invers[])
{
 string TempSymbolsList[];
 int SymbolsNumber=0;
 int FF = FileOpenHistory("symbols.sel", FILE_BIN|FILE_READ);
 if(FF < 0) return(-1);

 int TempSymbolsNumber = FileSize(FF) / 128;
 ArrayResize(TempSymbolsList, TempSymbolsNumber);
 ArrayResize(SymbolsList, TempSymbolsNumber);
 ArrayResize(Invers, TempSymbolsNumber);

 for(int i=0; i<TempSymbolsNumber; i++)
 {
  FileSeek(FF, 4, SEEK_CUR);
  TempSymbolsList[i] = FileReadString(FF, 12);
  FileSeek(FF, 112, SEEK_CUR);
 }
 FileClose(FF);
 
 int Pos;
   
 for (i=0;i<TempSymbolsNumber;i++)
 {
  Pos=StringFind(TempSymbolsList[i], BaseCurrency);
  if (Pos!=-1)
  {
   SymbolsList[SymbolsNumber]=TempSymbolsList[i];
   if (Pos==0)
   {
    Invers[SymbolsNumber]=false;
   }
   else
   {
    Invers[SymbolsNumber]=true;
   }
   SymbolsNumber++;
  }
  
 }
   
 return(SymbolsNumber);
}


int init()
{
 IndicatorShortName("McClellan oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MO);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,RANA);

 SNum=GetSymbols(SL, Inv);
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double C, O;
 int index;
 int i;
 double Up, Dn;
 pos=limit;
 while(pos>=0)
 {
  Up=0.;
  Dn=0.;
  for (i=0;i<SNum;i++)
  {
   index=iBarShift(SL[i], 0, Time[pos], true);
   if (index!=-1)
   {
    C=iClose(SL[i], 0, index);
    O=iOpen(SL[i], 0, index);
    if (Inv[i])
    {
     if (C>O)
     {
      Dn++;
     }
     if (C<O)
     {
      Up++;
     }
    }
    else
    {
     if (C>O)
     {
      Up++;
     }
     if (C<O)
     {
      Dn++;
     }
    }
   } 
  }
  
  
  if (Up+Dn!=0)
  {
   RANA[pos]=(Up-Dn)/(Up+Dn);
  }
  else
  {
   RANA[pos]=0;
  }
  
  pos--;
 } 
 
 double ShortMA, LongMA;
 pos=limit;
 while(pos>=0)
 {
  ShortMA=iMAOnArray(RANA, 0, Short_Length, 0, MODE_SMA, pos);
  LongMA=iMAOnArray(RANA, 0, Long_Length, 0, MODE_SMA, pos);
  MO[pos]=(ShortMA-LongMA)*(Short_Length+Long_Length);
  
  pos--;
 }
   
 return(0);
}

