//+------------------------------------------------------------------+
//|                                          ZIG ZAG NON REPAINT.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright©2010"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow
extern int Candle=480;
extern int Length=4;
double ExtMapBuffer1[];

int init()
{
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,ExtMapBuffer1);
   
   return(0);
  }
int deinit()
  {
   return(0);
  }
int start()
  {
   int cnt,ticket,counted_bars=IndicatorCounted();
   int shift,Swing,Swing_n,uzl,i,zu,zd,mv;
   double LL,HH,BH,BL,NH,NL; 
   double Uzel[10000][3]; 
   string text;
    
if (High[1]> High[0]) {Comment("SELL !!");}
 
 else if (High[1]< High[0]) {Comment("BUY !!");}
      Swing_n=0;Swing=0;uzl=0; 
      BH =High[Candle];BL=Low[Candle];zu=Candle;zd=Candle; 

for (shift=Candle;shift>=0;shift--) { 
      LL=10000000;HH=-100000000; 
   for (i=shift+Length;i>=shift+1;i--) { 
         if (Low[i]< LL) {LL=Low[i];} 
         if (High[i]>HH) {HH=High[i];} 
         }
      if (Low[shift]<LL && High[shift]>HH){ 
      Swing=2; 
      if (Swing_n==1) {zu=shift+1;} 
      if (Swing_n==-1) {zd=shift+1;} 
   } else { 
      if (Low[shift]<LL) {Swing=-1;} 
      if (High[shift]>HH) {Swing=1;} 
   } 

   if (Swing!=Swing_n && Swing_n!=0) { 
   if (Swing==2) {
      Swing=-Swing_n;BH = High[shift];BL = Low[shift]; 
   } 
      uzl=uzl+1; 
   if (Swing==1) {
      Uzel[uzl][1]=zd;
      Uzel[uzl][2]=BL;
   } 
   if (Swing==-1) {
      Uzel[uzl][1]=zu;
      Uzel[uzl][2]=BH; 
   } 
      BH = High[shift];
      BL = Low[shift]; 
   } 

   if (Swing==1) { 
      if (High[shift]>=BH) {BH=High[shift];zu=shift;}} 
      if (Swing==-1) {
          if (Low[shift]<=BL) {BL=Low[shift]; zd=shift;}} 
      Swing_n=Swing; 
   } 
   for (i=1;i<=uzl;i++) { 
      mv=StrToInteger(DoubleToStr(Uzel[i][1],0));
      ExtMapBuffer1[mv]=Uzel[i][2];
   } 
   
   return(0);
   }