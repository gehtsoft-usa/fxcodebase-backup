//+------------------------------------------------------------------+
//|                                                  Patterns_EA.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define MAGICMA  20343534

#define PAT_NONE 0
#define PAT_DOUBLE_INSIDE 1
#define PAT_INSIDE 2
#define PAT_OUTSIDE 4
#define PAT_PINUP 5
#define PAT_PINDOWN 6
#define PAT_PPRUP 7
#define PAT_PPRDN 8
#define PAT_DBLHC 9
#define PAT_DBHLC 10
#define PAT_CPRU 11
#define PAT_CPRD 1
#define PAT_NB 13
#define PAT_FBU 14
#define PAT_FBD 15
#define PAT_MB 16
#define PAT_HAMMER 17
#define PAT_SHOOTSTAR 18
#define PAT_EVSTAR 19
#define PAT_MORNSTAR 20
#define PAT_BEARHARAMI 21
#define PAT_BEARHARAMICROSS 22
#define PAT_BULLHARAMI 23
#define PAT_BULLHARAMICROSS 24
#define PAT_DARKCLOUD 25
#define PAT_DOJISTAR 26
#define PAT_ENGBEARLINE 27
#define PAT_ENGBULLLINE 28
#define PAT_EVDJSTAR 29
#define PAT_MORNDJSTAR 30
#define PAT_NB2 31

extern int EQ=1; // Maximum of pips distance between equal prices
extern bool Enable_DOUBLE_INSIDE=false;
extern bool Enable_INSIDE=false;
extern bool Enable_OUTSIDE=false;
extern bool Enable_PINUP=false;
extern bool Enable_PINDOWN=false;
extern bool Enable_PPRUP=false;
extern bool Enable_PPRDN=false;
extern bool Enable_DBLHC=false;
extern bool Enable_DBHLC=false;
extern bool Enable_CPRU=false;
extern bool Enable_CPRD=false;
extern bool Enable_NB=false;
extern bool Enable_NB2=false;
extern bool Enable_FBU=false;
extern bool Enable_FBD=false;
extern bool Enable_MB=false;
extern bool Enable_HAMMER=false;
extern bool Enable_SHOOTSTAR=false;
extern bool Enable_EVSTAR=false;
extern bool Enable_MORNSTAR=false;
extern bool Enable_EVDJSTAR=false;
extern bool Enable_MORNDJSTAR=false;
extern bool Enable_BEARHARAMI=false;
extern bool Enable_BEARHARAMICROSS=false;
extern bool Enable_BULLHARAMI=false;
extern bool Enable_BULLHARAMICROSS=false;
extern bool Enable_DARKCLOUD=false;
extern bool Enable_DOJISTAR=false;
extern bool Enable_ENGBEARLINE=false;
extern bool Enable_ENGBULLLINE=false;

extern string Direction="B"; // "B" - BUY, "S" - SELL
extern double Lots=0.1;
extern int Slippage=5;
extern int SL=0;
extern int TP=0;
extern bool OnlyOneOrder=false;

double EQpip;
datetime LastTime;

int CalculateCurrentOrders(string symbol)
{
 int buys=0,sells=0;
 for(int i=0;i<OrdersTotal();i++)
 {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
  {
   if(OrderType()==OP_BUY)  buys++;
   if(OrderType()==OP_SELL) sells++;
  }
 }
 if(buys>0) return(buys);
 else       return(-sells);
}

int Cmp(double price1, double price2)
{
 if (MathAbs(price1-price2)<EQpip)
 {
  return (0);
 }
 else if (price1>price2) return (1); else return (-1);
}

void UpdatePattern(int p)
{
 double MinDev=MathMax(EQpip,Point);
 double MinDev4=MathMax(EQpip*4,Point*4);
 double O0=Open[p];
 double C0=Close[p];
 double L0=Low[p];
 double H0=High[p];
 double T0=MathMax(O0, C0);
 double B0=MathMin(O0, C0);
 double BL0=T0-B0;
 double US0=H0-T0;
 double LS0=B0-L0;
 double O1=Open[p+1];
 double C1=Close[p+1];
 double L1=Low[p+1];
 double H1=High[p+1];
 double T1=MathMax(O1, C1);
 double B1=MathMin(O1, C1);
 double BL1=T1-B1;
 double US1=H1-T1;
 double LS1=B1-L1;
 double O2=Open[p+2];
 double C2=Close[p+2];
 double L2=Low[p+2];
 double H2=High[p+2];
 double T2=MathMax(O2, C2);
 double B2=MathMin(O2, C2);
 double BL2=T2-B2;
 double US2=H2-T2;
 double LS2=B2-L2;
 
 // 1-bar patterns
 if (Cmp(O0,C0)==0 && US0>MinDev4 && LS0>MinDev4) RegisterPattern(p,PAT_NB);
 if (C0==H0) RegisterPattern(p,PAT_FBU);
 if (C0==L0) RegisterPattern(p,PAT_FBD);
 if (US0<=MinDev && LS0>2*BL0) RegisterPattern(p,PAT_HAMMER);
 if (LS0<=MinDev && US0>2*BL0) RegisterPattern(p,PAT_SHOOTSTAR);
 
 // 2-bars patterns
 if (Cmp(H0,H1)<0 && Cmp(L0,L1)>0) RegisterPattern(p,PAT_INSIDE);
 if (Cmp(H0,H1)>0 && Cmp(L0,L1)<0) RegisterPattern(p,PAT_OUTSIDE);
 if (Cmp(H0,H1)==0 && Cmp(C0,C1)<0 && Cmp(L0,L1)<=0) RegisterPattern(p,PAT_DBHLC);
 if (Cmp(L0,L1)==0 && Cmp(C0,C1)>0 && Cmp(H0,H1)>=0) RegisterPattern(p,PAT_DBLHC);
 if (Cmp(BL1,BL0)==0 && Cmp(O1,C0)==0) RegisterPattern(p,PAT_MB);
 if (Cmp(H0,H1)<0 && Cmp(L0,L1)>0 && Cmp(C1,O1)>0 && Cmp(C0,O0)<0 && Cmp(BL1,BL0)>0 && Cmp(C1,O0)>0 && Cmp(O1,C0)<0) RegisterPattern(p,PAT_BEARHARAMI);
 if (Cmp(H0,H1)<0 && Cmp(L0,L1)>0 && Cmp(C1,O1)>0 && Cmp(O0,C0)==0 && Cmp(BL1,BL0)>0 && Cmp(C1,O0)>0 && Cmp(O1,C0)<0) RegisterPattern(p,PAT_BEARHARAMICROSS);
 if (Cmp(H0,H1)<0 && Cmp(L0,L1)>0 && Cmp(C1,O1)<0 && Cmp(C0,O0)>0 && Cmp(BL1,BL0)>0 && Cmp(C1,O0)<0 && Cmp(O1,C0)>0) RegisterPattern(p,PAT_BULLHARAMI);
 if (Cmp(H0,H1)<0 && Cmp(L0,L1)>0 && Cmp(C1,O1)<0 && Cmp(O0,C0)==0 && Cmp(BL1,BL0)>0 && Cmp(C1,O0)<0 && Cmp(O1,C0)>0) RegisterPattern(p,PAT_BULLHARAMICROSS);
 if (Cmp(C1,O1)>0 && Cmp(C0,O0)<0 && Cmp(H1,O0)<0 && Cmp(C0,C1)<0 && Cmp(C0,O1)>0) RegisterPattern(p,PAT_DARKCLOUD);
 if (Cmp(O0,C0)==0 && Cmp(C1,O1)>0 && Cmp(O0,H1)>0 && Cmp(C1,O1)<0 && Cmp(O0,L1)<0) RegisterPattern(p,PAT_DOJISTAR);
 if (Cmp(C1,O1)>0 && Cmp(C0,O0)<0 && Cmp(O0,C1)>0 && Cmp(C0,O1)<0) RegisterPattern(p,PAT_ENGBEARLINE);
 if (Cmp(C1,O1)<0 && Cmp(C0,O0)>0 && Cmp(O0,C1)<0 && Cmp(C0,O1)>0) RegisterPattern(p,PAT_ENGBULLLINE);
 if (Cmp(O0,C0)==0 && US0>MinDev4 && LS0>MinDev4 && Cmp(O1,C1)==0 && US1>MinDev4 && LS1>MinDev4) RegisterPattern(p,PAT_NB2);

 // 3-bars patterns
 if (Cmp(H0,H1)<0 && Cmp(L0,L1)>0 && Cmp(H1,H2)<0 && Cmp(L1,L2)>0) RegisterPattern(p,PAT_DOUBLE_INSIDE);
 if (Cmp(H1,H2)>0 && Cmp(H1,H0)>0 && Cmp(L1,L2)>0 && Cmp(L1,L0)>0 && BL1*2<US1) RegisterPattern(p,PAT_PINUP);
 if (Cmp(H1,H2)<0 && Cmp(H1,H0)<0 && Cmp(L1,L2)<0 && Cmp(L1,L0)<0 && BL1*2<LS1) RegisterPattern(p,PAT_PINDOWN);
 if (Cmp(H1,H2)>0 && Cmp(H1,H0)>0 && Cmp(L1,L2)>0 && Cmp(L1,L0)>0 && Cmp(C0,L1)<0) RegisterPattern(p,PAT_PPRDN);
 if (Cmp(H1,H2)<0 && Cmp(H1,H0)<0 && Cmp(L1,L2)<0 && Cmp(L1,L0)<0 && Cmp(C0,H1)>0) RegisterPattern(p,PAT_PPRUP);
 if (Cmp(H1,H2)<0 && Cmp(L1,L2)<0 && Cmp(H0,H1)<0 && Cmp(L0,L1)<0 && Cmp(C0,C1)>0 && Cmp(O0,C0)<0) RegisterPattern(p,PAT_CPRU);
 if (Cmp(H1,H2)>0 && Cmp(L1,L2)>0 && Cmp(H0,H1)>0 && Cmp(L0,L1)>0 && Cmp(C0,C1)<0 && Cmp(O0,C0)>0) RegisterPattern(p,PAT_CPRD);
 if (Cmp(C2,O2)>0 && Cmp(C1,O1)>0 && Cmp(C0,O0)<0 && Cmp(C2,O1)<0 && Cmp(BL2,BL1)>0 && Cmp(BL1,BL0)<0 && Cmp(C0,O2)>0 && Cmp(C0,C2)<0) RegisterPattern(p,PAT_EVSTAR);
 if (Cmp(C2,O2)<0 && Cmp(C1,O1)>0 && Cmp(C0,O0)>0 && Cmp(C2,O1)>0 && Cmp(BL2,BL1)>0 && Cmp(BL1,BL0)<0 && Cmp(C0,C2)>0 && Cmp(C0,O2)<0) RegisterPattern(p,PAT_MORNSTAR);
 if (Cmp(C2,O2)>0 && Cmp(C1,O1)==0 && Cmp(C0,O0)<0 && Cmp(C2,O1)<0 && Cmp(BL2,BL1)>0 && Cmp(BL1,BL0)<0 && Cmp(C0,O2)>0 && Cmp(C0,C2)<0) RegisterPattern(p,PAT_EVDJSTAR);
 if (Cmp(C2,O2)<0 && Cmp(C1,O1)==0 && Cmp(C0,O0)>0 && Cmp(C2,O1)>0 && Cmp(BL2,BL1)>0 && Cmp(BL1,BL0)<0 && Cmp(C0,C2)>0 && Cmp(C0,O2)<0) RegisterPattern(p,PAT_MORNDJSTAR);


 return;
}

void RegisterPattern(int p, int Pattern)
{
 string name="";
 string LongName="";
 bool up;
 int length;
 double price;
 if (Pattern==PAT_NB && Enable_NB) {name="NB"; up=true; length=1; LongName="Neutral Bar";}
 if (Pattern==PAT_FBU && Enable_FBU) {name="FBU"; up=false; length=1; LongName="Force Bar Up";}
 if (Pattern==PAT_FBD && Enable_FBD) {name="FBD"; up=true; length=1; LongName="Force Bar Down";}
 if (Pattern==PAT_HAMMER && Enable_HAMMER) {name="HAMMER"; up=true; length=1; LongName="Hammer Pattern";}
 if (Pattern==PAT_SHOOTSTAR && Enable_SHOOTSTAR) {name="SHOOTSTAR"; up=true; length=1; LongName="Shooting Star";}
 
 if (Pattern==PAT_INSIDE && Enable_INSIDE) {name="IN"; up=true; length=2; LongName="Inside";}
 if (Pattern==PAT_OUTSIDE && Enable_OUTSIDE) {name="OUT"; up=true; length=2; LongName="Outside";}
 if (Pattern==PAT_DBHLC && Enable_DBHLC) {name="DBHLC"; up=true; length=2; LongName="Double Bar High With A Lower Close";}
 if (Pattern==PAT_DBLHC && Enable_DBLHC) {name="DBLHC"; up=false; length=2; LongName="Double Bar Low With A Higher Close";}
 if (Pattern==PAT_MB && Enable_MB) {name="MB"; up=true; length=2; LongName="Mirror Bar";}
 if (Pattern==PAT_BEARHARAMI && Enable_BEARHARAMI) {name="BEARHARAMI"; up=true; length=2; LongName="Bearish Harami";}
 if (Pattern==PAT_BEARHARAMICROSS && Enable_BEARHARAMICROSS) {name="BEARHARAMICROSS"; up=true; length=2; LongName="Bearish Harami Cross";}
 if (Pattern==PAT_BULLHARAMI && Enable_BULLHARAMI) {name="BULLHARAMI"; up=true; length=2; LongName="Bullish Harami";}
 if (Pattern==PAT_BULLHARAMICROSS && Enable_BULLHARAMICROSS) {name="BULLHARAMICROSS"; up=true; length=2; LongName="Bullish Harami Cross";}
 if (Pattern==PAT_DARKCLOUD && Enable_DARKCLOUD) {name="DARKCLOUD"; up=true; length=2; LongName="Dark Cloud Cover";}
 if (Pattern==PAT_DOJISTAR && Enable_DOJISTAR) {name="DOJISTAR"; up=true; length=2; LongName="Doji Star";}
 if (Pattern==PAT_ENGBEARLINE && Enable_ENGBEARLINE) {name="ENGBEARLINE"; up=true; length=2; LongName="Engulfing Bearish Line";} 
 if (Pattern==PAT_ENGBULLLINE && Enable_ENGBULLLINE) {name="ENGBULLLINE"; up=true; length=2; LongName="Engulfing Bullish Line";}
 if (Pattern==PAT_NB2 && Enable_NB2) {name="NB2"; up=true; length=2; LongName="2 Neutral Bars";}
 
 if (Pattern==PAT_DOUBLE_INSIDE && Enable_DOUBLE_INSIDE) {name="DBLIN"; up=true; length=3; LongName="Double inside";}
 if (Pattern==PAT_PINUP && Enable_PINUP) {name="PINUP"; up=true; length=3; LongName="Pin up";}
 if (Pattern==PAT_PINDOWN && Enable_PINDOWN) {name="PINDOWN"; up=false; length=3; LongName="Pin down";}
 if (Pattern==PAT_PPRDN && Enable_PPRDN) {name="PPRDN"; up=true; length=3; LongName="Pivot Point Reversal Down";}
 if (Pattern==PAT_PPRUP && Enable_PPRUP) {name="PPRUP"; up=false; length=3; LongName="Pivot Point Reversal Up";}
 if (Pattern==PAT_CPRU && Enable_CPRU) {name="CPRU"; up=false; length=3; LongName="Close Price Reversal Up";}
 if (Pattern==PAT_CPRD && Enable_CPRD) {name="CPRD"; up=true; length=3; LongName="Close Price Reversal Down";}
 if (Pattern==PAT_EVSTAR && Enable_EVSTAR) {name="EVSTAR"; up=true; length=3; LongName="Evening Star";}
 if (Pattern==PAT_MORNSTAR && Enable_MORNSTAR) {name="MORNSTAR"; up=true; length=3; LongName="Morning Star";}
 if (Pattern==PAT_EVDJSTAR && Enable_EVDJSTAR) {name="EVDJSTAR"; up=true; length=3; LongName="Evening Doji Star";}
 if (Pattern==PAT_MORNDJSTAR && Enable_MORNDJSTAR) {name="MORNDJSTAR"; up=true; length=3; LongName="Morning Doji Star";}
 
 if (name!="")
 {
  if (Direction=="B" || Direction=="b")
  {
   OpenOrder(OP_BUY);
  }
  else
  {
   if (Direction=="S" || Direction=="s")
   {
    OpenOrder(OP_SELL);
   }
  }
 } 
}

void OpenOrder(int Dir)
{
 double SL_Level;
 double TP_Level;
 int res;
 int CCO=CalculateCurrentOrders(Symbol());
 if (Dir==OP_BUY)
 {
  if (OnlyOneOrder && CCO>0) return;
  if (TP==0) TP_Level=0; else TP_Level=NormalizeDouble(Bid+TP*Point, Digits);
  if (SL==0) SL_Level=0; else SL_Level=NormalizeDouble(Bid-SL*Point, Digits);
  res=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,SL_Level,TP_Level,"",MAGICMA,0,Blue);
  if (res==-1)
  {
   Print("LastError = ",GetLastError());
   LastTime=0;
  }  
 }
 else
 {
  if (OnlyOneOrder && CCO<0) return;
  if (TP==0) TP_Level=0; else TP_Level=NormalizeDouble(Ask-TP*Point, Digits);
  if (SL==0) SL_Level=0; else SL_Level=NormalizeDouble(Ask+SL*Point, Digits);
  res=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,SL_Level,TP_Level,"",MAGICMA,0,Blue);
  if (res==-1)
  {
   Print("LastError = ",GetLastError());
   LastTime=0;
  }  
 }
}

int init()
  {
   EQpip=EQ*Point;
   LastTime=Time[0];
   return(0);
  }

int deinit()
  {
   return(0);
  }

int start()
  {
   if(Bars<=3) return(0);
   if (LastTime!=Time[0])
   {
    LastTime=Time[0];
    UpdatePattern(1);
   } 

   return(0);
  }

