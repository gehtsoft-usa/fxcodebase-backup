//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76211

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_type1 DRAW_SECTION
#property indicator_color1 WhiteSmoke
#property indicator_style1 STYLE_DOT
#property indicator_width1 1

// Inputs
input double angle_up       = 22.5;    // Up angle for levels
input double angle_dn       = 22.5;    // Down angle for levels
input int    Width          = 0;       // Line width
input int    Style          = 2;       // Line style
input int    kol_lev        = 8;       // Number of levels
input color  ResistanceColor = Brown;  // Resistance color
input color  SupportColor   = Green;   // Support color
input color  Level_0        = Gray;    // Level 0 color
input bool   lev_V          = true;    // Show vertical lines
input color  Level_V        = Gray;    // Vertical lines color
input int    Complect       = 0;       // Levels set

color clr_level;

input int ExtDepth=21;                 // ZigZag depth
input int ExtDeviation=5;              // ZigZag deviation
input int ExtBackstep=3;               // ZigZag backstep

double ZigZagBuffer[];

datetime timeFirstBar=0;
int flag;
bool work=true;
double vel_prev;
int MAHandle = INVALID_HANDLE;

int OnInit()
  {
   SetIndexBuffer(0,ZigZagBuffer,INDICATOR_DATA);
   ArraySetAsSeries(ZigZagBuffer,true);
   
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_SECTION);
   PlotIndexSetInteger(0,PLOT_LINE_STYLE,2);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   
   IndicatorSetString(INDICATOR_SHORTNAME,"ZigZag("+IntegerToString(ExtDepth)+","+IntegerToString(ExtDeviation)+","+IntegerToString(ExtBackstep)+")");
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
   ObjDel();
   Comment("");
  }
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total-1<ExtDepth) return(0);
   
   static datetime time2=0,time3=0,time4=0;
   static double ZigZag2,ZigZag3,ZigZag4;
   
   int MaxBar,limit,supr2_bar,supr3_bar,supr4_bar,counted_bars=prev_calculated;
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   
   int shift,back,lasthighpos,lastlowpos;
   double val,res,TempBuffer[];
   double curlow,curhigh,lasthigh,lastlow;
   
   int metka=0;
   
   MaxBar=rates_total-ExtDepth;
   
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   
   if(counted_bars==0 || rates_total-counted_bars>2)
     {
      limit=MaxBar;
     }
   else
     {
      supr2_bar=iBarShift(NULL,0,time2,true);
      supr3_bar=iBarShift(NULL,0,time3,true);
      supr4_bar=iBarShift(NULL,0,time4,true);
      limit=supr3_bar;
      if((supr2_bar<0)||(supr3_bar<0)||(supr4_bar<0))
        {
         limit=MaxBar;
        }
     }
   
   if(limit>=MaxBar || timeFirstBar!=time[rates_total-1])
     {
      timeFirstBar=time[rates_total-1];
      limit=MaxBar;
     }
   
   if(limit==MaxBar) ArrayResize(TempBuffer,rates_total); else ArrayResize(TempBuffer,limit+ExtBackstep+1);
   ArrayInitialize(TempBuffer,0.0);
   
   //Calculate ZigZag buffer
   for(shift=limit; shift>=0; shift--)
     {
      val=low[ArrayMinimum(low,shift,ExtDepth)];
      if(val==lastlow) val=0.0;
      else
        {
         lastlow=val;
         if((low[shift]-val)>(ExtDeviation*_Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ZigZagBuffer[shift+back];
               if((res!=0)&&(res>val)) ZigZagBuffer[shift+back]=0.0;
              }
           }
        }
      if(low[shift]==val)
        {
         ZigZagBuffer[shift]=val;
        }
      else ZigZagBuffer[shift]=0.0;
      
      val=high[ArrayMaximum(high,shift,ExtDepth)];
      if(val==lasthigh) val=0.0;
      else
        {
         lasthigh=val;
         if((val-high[shift])>(ExtDeviation*_Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=TempBuffer[shift+back];
               if((res!=0)&&(res<val)) TempBuffer[shift+back]=0.0;
              }
           }
        }
      if(high[shift]==val)
        {
         TempBuffer[shift]=val;
        }
      else TempBuffer[shift]=0.0;
     }
   
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;
   
   for(shift=limit; shift>=0; shift--)
     {
      curlow=ZigZagBuffer[shift];
      curhigh=TempBuffer[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      if(curhigh!=0)
        {
         if(lasthigh>0)
           {
            if(lasthigh<curhigh) TempBuffer[lasthighpos]=0;
            else TempBuffer[shift]=0;
           }
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow) ZigZagBuffer[lastlowpos]=0;
            else ZigZagBuffer[shift]=0;
           }
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           }
         lasthigh=-1;
        }
     }
   
   for(shift=limit; shift>=0; shift--)
     {
      res=TempBuffer[shift];
      if(res!=0.0) ZigZagBuffer[shift]=res;
     }
   
   int i=0,j=0;
   res=0;
   // Check and remove two consecutive highs
   for(shift=0; i<3; shift++)
     {
      if(ZigZagBuffer[shift]>0)
        {
         i++;
         if(i==1 && ZigZagBuffer[shift]==high[shift])
           {
            j=shift;
            res=ZigZagBuffer[shift];
           }
         if(i==2 && res>0 && ZigZagBuffer[shift]==high[shift])
           {
            if(ZigZagBuffer[shift]>=ZigZagBuffer[j]) ZigZagBuffer[j]=0; else ZigZagBuffer[shift]=0;
            res=0;
            i=0;
            j=0;
            shift=0;
           }
        }
     }
   // Check and remove two consecutive lows
   i=0; j=0; res=0;
   for(shift=0; i<3; shift++)
     {
      if(ZigZagBuffer[shift]>0)
        {
         i++;
         if(i==1 && ZigZagBuffer[shift]==low[shift])
           {
            j=shift;
            res=ZigZagBuffer[shift];
           }
         if(i==2 && res>0 && ZigZagBuffer[shift]==low[shift])
           {
            if(ZigZagBuffer[shift]<=ZigZagBuffer[j]) ZigZagBuffer[j]=0; else ZigZagBuffer[shift]=0;
            res=0;
            i=0;
            j=0;
            shift=0;
           }
        }
     }
   
   if(limit<MaxBar)
     {
      ZigZagBuffer[supr2_bar]=ZigZag2;
      ZigZagBuffer[supr3_bar]=ZigZag3;
      ZigZagBuffer[supr4_bar]=ZigZag4;
      for(int qqq=supr4_bar-1; qqq>supr3_bar; qqq--) ZigZagBuffer[qqq]=0;
      for(int ggg=supr3_bar-1; ggg>supr2_bar; ggg--) ZigZagBuffer[ggg]=0;
     }
   
   double vel1, vel2, vel3, vel4;
   int bar1, bar2, bar3, bar4;
   int count;
   if(limit==MaxBar) supr4_bar=MaxBar;
   
   ObjDel();
   // Find peaks and valleys for Gann levels
   for(int bar=supr4_bar; bar>=0; bar--)
     {
      if(ZigZagBuffer[bar]!=0)
        {
         count++;
         vel4=vel3; bar4=bar3;
         vel3=vel2; bar3=bar2;
         vel2=vel1; bar2=bar1;
         vel1=ZigZagBuffer[bar]; bar1=bar;
         if(count<3) continue;
         if((vel3<vel2)&&(vel2<vel1)){ZigZagBuffer[bar2]=0; bar=bar3+1;}
         if((vel3>vel2)&&(vel2>vel1)){ZigZagBuffer[bar2]=0; bar=bar3+1;}
         if((vel2==vel1)&&(vel1!=0 )){ZigZagBuffer[bar1]=0; bar=bar3+1;}
        }
     }
   
   time2=time[bar2];
   time3=time[bar3];
   time4=time[bar4];
   ZigZag2=vel2;
   ZigZag3=vel3;
   ZigZag4=vel4;
   
   if(bar1>=2)
     {
      if(low[bar1]==vel1)
        {
         flag=1;
         for(i=1; i<=kol_lev; i++)
           {
            PlotLine("_lev "+IntegerToString(bar1)+"_"+IntegerToString(Complect)+"_"+IntegerToString(i),vel1,bar1,bar1,0,angle_up*i, flag, time);
           }
        }
      else
        {
         flag=-1;
         for(i=1; i<=kol_lev; i++)
           {
            PlotLine("_lev "+IntegerToString(bar1)+"_"+IntegerToString(Complect)+"_"+IntegerToString(i),vel1,bar1,bar1,0,angle_dn*i, flag, time);
           }
        }
      PlotLineM("_lev "+IntegerToString(bar1)+"_"+IntegerToString(Complect)+"_",vel1,bar1,bar1,0,flag, time);
     }
   
   if(low[bar2]==vel2)
     {
      flag=1;
      for(i=1; i<=kol_lev; i++)
        {
         PlotLine("_lev "+IntegerToString(bar2)+"_"+IntegerToString(Complect)+"_"+IntegerToString(i),vel2,bar2,bar1,1,angle_up*i, flag, time);
        }
     }
   else
     {
      flag=-1;
      for(i=1; i<=kol_lev; i++)
        {
         PlotLine("_lev "+IntegerToString(bar2)+"_"+IntegerToString(Complect)+"_"+IntegerToString(i),vel2,bar2,bar1,1,angle_dn*i, flag, time);
        }
     }
   PlotLineM("_lev "+IntegerToString(bar2)+"_"+IntegerToString(Complect)+"_",vel2,bar2,bar1,1,flag, time);
   
   if(low[bar3]==vel3)
     {
      flag=1;
      for(i=1; i<=kol_lev; i++)
        {
         PlotLine("_lev "+IntegerToString(bar3)+"_"+IntegerToString(Complect)+"_"+IntegerToString(i),vel3,bar3,bar2,1,angle_up*i, flag, time);
        }
     }
   else
     {
      flag=-1;
      for(i=1; i<=kol_lev; i++)
        {
         PlotLine("_lev "+IntegerToString(bar3)+"_"+IntegerToString(Complect)+"_"+IntegerToString(i),vel3,bar3,bar2,1,angle_dn*i, flag, time);
        }
     }
   PlotLineM("_lev "+IntegerToString(bar3)+"_"+IntegerToString(Complect)+"_",vel3,bar3,bar2,1,flag, time);
   
   if(low[bar4]==vel4)
     {
      flag=1;
      for(i=1; i<=kol_lev; i++)
        {
         PlotLine("_lev "+IntegerToString(bar4)+"_"+IntegerToString(Complect)+"_"+IntegerToString(i),vel4,bar4,bar3,1,angle_up*i, flag, time);
        }
     }
   else
     {
      flag=-1;
      for(i=1; i<=kol_lev; i++)
        {
         PlotLine("_lev "+IntegerToString(bar4)+"_"+IntegerToString(Complect)+"_"+IntegerToString(i),vel4,bar4,bar3,1,angle_dn*i, flag, time);
        }
     }
   PlotLineM("_lev "+IntegerToString(bar4)+"_"+IntegerToString(Complect)+"_",vel4,bar4,bar3,1,flag, time);
   
   return(rates_total);
  }
void PlotLineM(string name,double Price1,int Date1,int Date2,int lev0,int flag, const datetime &time[])
  {
   datetime D2;
   double P1;
   
   if(lev0==1)
     {
      D2=time[Date2];
     }
   else
     {
      D2=time[0]+(50*Period()*60);
     }
   
   ObjectDelete(0,name+" 0");
   ObjectCreate(0,name+" 0",OBJ_TREND,0,time[Date1],Price1,D2,Price1);
   ObjectSetInteger(0,name+" 0",OBJPROP_COLOR,Level_0);
   ObjectSetInteger(0,name+" 0",OBJPROP_STYLE,0);
   ObjectSetInteger(0,name+" 0",OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name+" 0",OBJPROP_RAY,false);
   
   if(flag==1)
      P1=Price1-2*_Point;
   else if(flag==-1)
      P1=Price1+4*_Point;
   
   ObjectDelete(0,name+" 0txt");
   ObjectCreate(0,name+" 0txt",OBJ_TEXT,0,time[Date1],P1);
   ObjectSetString(0,name+" 0txt",OBJPROP_TEXT,DoubleToString(Price1,_Digits));
   ObjectSetInteger(0,name+" 0txt",OBJPROP_FONTSIZE,8);
   ObjectSetString(0,name+" 0txt",OBJPROP_FONT,"Tahoma");
   ObjectSetInteger(0,name+" 0txt",OBJPROP_COLOR,Level_0);
   
   if(lev_V)
     {
      ObjectDelete(0,name+" V");
      ObjectCreate(0,name+" V",OBJ_VLINE,0,time[Date1],0);
      ObjectSetInteger(0,name+" V",OBJPROP_COLOR,Level_V);
      ObjectSetInteger(0,name+" V",OBJPROP_STYLE,2);
      ObjectSetInteger(0,name+" V",OBJPROP_WIDTH,0);
      ObjectSetInteger(0,name+" V",OBJPROP_BACK,true);
     }
  }
void PlotLine(string name,double Price1,int Date1,int Date2,int lev0,double gr,int flag, const datetime &time[])
  {
   double level,points;
   datetime D2;
   int nBar;
   
   if(_Digits==5 || _Digits==3)
      points=_Point*10;
   else
      points=_Point;
   
   if(flag==1)
     {
      level=MathSqrt(Price1/points)+gr/180;
      level=MathPow(level,2)*points;
      clr_level=SupportColor;
     }
   else if(flag==-1)
     {
      level=MathSqrt(Price1/points)-gr/180;
      level=MathPow(level,2)*points;
      clr_level=ResistanceColor;
     }
   
   if(lev0==1)
     {
      D2=time[Date2];
     }
   else
     {
      D2=time[0]+(50*Period()*60);
     }
   
   ObjectDelete(0,name);
   ObjectCreate(0,name,OBJ_TREND,0,time[Date1],level,D2,level);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr_level);
   ObjectSetInteger(0,name,OBJPROP_STYLE,Style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,Width);
   ObjectSetInteger(0,name,OBJPROP_RAY,false);
   
   ObjectDelete(0,name+" txt");
   if(lev0==1)
     {
      nBar=Date1-8;
      ObjectCreate(0,name+" txt",OBJ_TEXT,0,time[nBar],level);
     }
   else
     {
      ObjectCreate(0,name+" txt",OBJ_TEXT,0,time[0]+8*Period()*60,level);
     }
   ObjectSetString(0,name+" txt",OBJPROP_TEXT,DoubleToString(gr,1)+"° "+DoubleToString(level,_Digits));
   ObjectSetInteger(0,name+" txt",OBJPROP_FONTSIZE,8);
   ObjectSetString(0,name+" txt",OBJPROP_FONT,"Tahoma");
   ObjectSetInteger(0,name+" txt",OBJPROP_COLOR,clr_level);
  }
void ObjDel()
  {
   for(int i=ObjectsTotal(0,0,-1)-1; i>=0; i--)
     {
      if(StringFind(ObjectName(0,i),"_",0)==0)
        {
         ObjectDelete(0,ObjectName(0,i));
        }
     }
  }
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76211

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+
 