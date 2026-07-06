//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75581
// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 4
      bool ShowDots=true,Show2ndDOT=true,FillUp=false,ShowMarks=true,ShowAlert=false,ShowAlertTr=false;
//+---XARD SETTINGS(1008,144,36,9)-----------------------------------------------------------------------------------+ 
    double DotPer1=9,DotPer2=36; extern int W1=3,W2=2; int BarsCount=20000,DATA1=0;
     color BuyTriangle=clrNONE,SellTriangle=clrNONE,BuyMark=clrAqua,SellMark=clrGold;
       int Dev=1,Stp=1,SYM1=108,SYM2=108,Type,key,keyTr,DATA2; input string copy="1"; 
    double Level1UP[],Level1DN[],Level2UP[],Level2DN[]; string symbol=Symbol();    
//+------------------------------------------------------------------------------------------------------------------+ 
   int init(){int Buf=-1; key=0; keyTr=0; if(ShowDots)Type=DRAW_ARROW; else Type=DRAW_NONE;
   Buf+=1;SetIndexBuffer(Buf,Level1UP);  SetIndexStyle(Buf,Type,0,W1,clrGreen);    SetIndexArrow(Buf,SYM1);  
   Buf+=1;SetIndexBuffer(Buf,Level1DN);  SetIndexStyle(Buf,Type,0,W1,clrRed);    SetIndexArrow(Buf,SYM1);
   Buf+=1;SetIndexBuffer(Buf,Level2UP);  SetIndexStyle(Buf,Type,0,W2,clrGreenYellow);  SetIndexArrow(Buf,SYM2);  
   Buf+=1;SetIndexBuffer(Buf,Level2DN);  SetIndexStyle(Buf,Type,0,W2,clrOrangeRed);  SetIndexArrow(Buf,SYM2);
   if(DATA1==0)DATA2=40000; else DATA2=DATA1; return(0);} 
//+------------------------------------------------------------------------------------------------------------------+
   int deinit(){ChartCleaner(); return(0);}  
   int  start(){if(DotPer1>0)CountZZ(Level1UP,Level1DN,DotPer1,Dev,Stp);
                if(DotPer2>0)CountZZ(Level2UP,Level2DN,DotPer2,Dev,Stp);
//+------------------------------------------------------------------------------------------------------------------+
   if(ShowAlert && key!=Time[0]){     
   if(Level2UP[0]!=0)Alert(" "+ symbol+" "+Period()+" "+DoubleToStr(Close[0],Digits));
   if(Level2DN[0]!=0)Alert(" "+ symbol+" "+Period()+" "+DoubleToStr(Close[0],Digits));} key=Time[0]; 
   if(!Show2ndDOT) ChartCleaner(); if(Show2ndDOT) Triangels(); return(0);}
//+------------------------------------------------------------------------------------------------------------------+   
   double Triangels(){bool up; double OpenPrice,semafor2d,semafor2u,semafor1d,semafor1u,upper,lower,price1,price2,
   price3,semafor2dn,semafor2up; int zz,lev1,time1,time2,time3; if(keyTr!=Time[0]){ChartCleaner();
   double spread=MarketInfo(Symbol(),MODE_SPREAD)*Point;for(zz=BarsCount;zz>=1;zz--){price1=0;price2=0;price3=0;
   semafor2d=0; semafor2u=0; semafor2d=Level2UP[zz]; semafor2u=Level2DN[zz]; time1=Time[zz];
//+------------------------------------------------------------------------------------------------------------------+   
   if(semafor2d>0){price1=semafor2d; up=false; OpenPrice=0; upper=0;
   for(lev1=zz-1;lev1>=1;lev1--){semafor2dn=Level2UP[lev1]; semafor2up=Level2DN[lev1];
   if(semafor2up>0 || semafor2dn>0) break; if(!up){semafor1u=Level1DN[lev1]; if(semafor1u>0) upper=semafor1u;
   if(upper>0&&upper>=semafor2d){price2=upper; time2=Time[lev1]; up=true;}} else {lower=Level1UP[lev1+1];
   if(lower>0&&lower>=semafor2d){time3=Time[lev1+1]; price3=lower;}}if(price1>0&&price2>0&&price3>0){OpenPrice=10;
   if(lev1==1 && ShowAlertTr)Alert(Symbol()," ",Period()," Buy!!! ",price2+2*2*Point+spread); break;}}
   if(OpenPrice>0 && price2-price1<DATA2*Point){
   DrawTriangle(copy+"123h"+zz,time1,price1,time2,price2,time3,price3,BuyTriangle);    
   DrawArrow(copy+"123b"+lev1,time3+Period()*60,price3-2*Point,BuyMark);}}
//+------------------------------------------------------------------------------------------------------------------+
   if(semafor2u>0){price1=semafor2u; up=false; OpenPrice=0; lower=0; upper=0;
   for(lev1=zz-1;lev1>=1;lev1--){semafor2dn=Level2UP[lev1]; semafor2up=Level2DN[lev1];
   if(semafor2up>0 || semafor2dn>0) break; if(!up){semafor1d=Level1UP[lev1]; if(semafor1d>0) lower=semafor1d;
   if(lower>0&&lower<=semafor2u){price2=lower; time2=Time[lev1]; up=true;}} else {upper=Level1DN[lev1+1]; 
   if(upper>0&&upper<=semafor2u){time3=Time[lev1+1]; price3=upper;}}if(price1>0&&price2>0&&price3>0){OpenPrice=10;
   if(lev1==1 && ShowAlertTr)Alert(Symbol(),"  ",Period()," Sell!!! ",price2-2*Point); break;}}
   if(OpenPrice>0 && price1-price2<DATA2*Point){
   DrawTriangle(copy+"123s"+zz,time1,price1,time2,price2,time3,price3,SellTriangle);
   DrawArrow(copy+"123_X"+lev1,time3+Period()*60,price3-2*Point,SellMark);}}} keyTr=Time[0];} return(0);}
//+------------------------------------------------------------------------------------------------------------------+
   void DrawArrow(string name,int time,double price,color ops_color){if(!ShowMarks) return;
   ObjectCreate(name,OBJ_ARROW,0,time,price,0,0,0,0);
      ObjectSet(name,OBJPROP_WIDTH,3);
      ObjectSet(name,OBJPROP_BACK,FillUp);
      ObjectSet(name,OBJPROP_COLOR,ops_color);
      ObjectSet(name,OBJPROP_ARROWCODE,SYMBOL_RIGHTPRICE);}
//+------------------------------------------------------------------------------------------------------------------+
void DrawTriangle(string name2,int time1,double price1,int time2,double price2,int time3,double price3,color ops_color){
   ObjectCreate(name2,OBJ_TRIANGLE,0,time1,price1,time2,price2,time3,price3);
      ObjectSet(name2,OBJPROP_WIDTH,4);
      ObjectSet(name2,OBJPROP_BACK,FillUp);
      ObjectSet(name2,OBJPROP_COLOR,ops_color);}
//+------------------------------------------------------------------------------------------------------------------+
   int CountZZ(double& ExtMapBuffer[],double& ExtMapBuffer2[],int ExtDepth,int ExtDeviation,int ExtBackstep){
   int shift, back,lasthighpos,lastlowpos, limit; double val,res,curlow,curhigh,lasthigh,lastlow;
   limit=Bars-ExtDepth; if(limit>BarsCount) limit=BarsCount; for(shift=limit; shift>=0; shift--){
   val=Low[Lowest(NULL,0,MODE_LOW,ExtDepth,shift)];
   if(val==lastlow) val=00; else {lastlow=val; if((Low[shift]-val)>(ExtDeviation*Point)) val=00;
   else {for(back=1; back<=ExtBackstep; back++){res=ExtMapBuffer[shift+back];
   if((res!=0)&&(res>val)) ExtMapBuffer[shift+back]=00;}}} ExtMapBuffer[shift]=val;
//+------------------------------------------------------------------------------------------------------------------+   
   val=High[Highest(NULL,0,MODE_HIGH,ExtDepth,shift)];
   if(val==lasthigh) val=00; else {lasthigh=val; if((val-High[shift])>(ExtDeviation*Point)) val=00;
   else {for(back=1; back<=ExtBackstep; back++){res=ExtMapBuffer2[shift+back];
   if((res!=0)&&(res<val))ExtMapBuffer2[shift+back]=00;}}} ExtMapBuffer2[shift]=val;}
   lasthigh=-1; lasthighpos=-1; lastlow=-1; lastlowpos=-1; for(shift=limit;shift>=0;shift--){
   curlow=ExtMapBuffer[shift]; curhigh=ExtMapBuffer2[shift]; if((curlow==0)&&(curhigh==0)) continue;
//+------------------------------------------------------------------------------------------------------------------+
   if(curhigh!=0){if(lasthigh>0){if(lasthigh<curhigh)ExtMapBuffer2[lasthighpos]=0;else ExtMapBuffer2[shift]=0;}
   if(lasthigh<curhigh || lasthigh<0){lasthigh=curhigh; lasthighpos=shift;}lastlow=-1;}
   if(curlow!=0){if(lastlow>0){if(lastlow>curlow)ExtMapBuffer[lastlowpos]=0; else ExtMapBuffer[shift]=0;}
   if((curlow<lastlow)||(lastlow<0)){lastlow=curlow; lastlowpos=shift;} lasthigh=-1;}}
   for(shift=limit;shift>=0;shift--){if(shift>=limit)ExtMapBuffer[shift]=00;
   else {res=ExtMapBuffer2[shift]; if(res!=00)ExtMapBuffer2[shift]=res;}} return(0);}
//+------------------------------------------------------------------------------------------------------------------+
   void ChartCleaner() {for(int a=0;a<Bars;a++){ObjectDelete(copy+"123h"+a);ObjectDelete(copy+"123b"+a);
   ObjectDelete(copy+"123s"+a);ObjectDelete(copy+"123_X"+a); GetLastError();}}
//+------------------------------------------------------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75581
// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 