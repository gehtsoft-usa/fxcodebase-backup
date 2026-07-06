// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72564

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_color2  clrRed
#property description "The indicator generates a signal when candles from several timeframes match"
//+------------------------------------------------------------------+

double     SignalBufferRed[];
double     SignalBufferBlue[];
datetime TimeAlert=0;
input ENUM_TIMEFRAMES tf0=PERIOD_M1;
input ENUM_TIMEFRAMES tf1=PERIOD_M5;
input ENUM_TIMEFRAMES tf2=PERIOD_M15;
input ENUM_TIMEFRAMES tf3=PERIOD_M30;
input ENUM_TIMEFRAMES tf4=PERIOD_H1;
input ENUM_TIMEFRAMES tf5=PERIOD_H4;
int S=0,ExtArrowShift=0;
bool tf_1=false;
bool tf_2=false;
bool tf_3=false;
bool tf_4=false;
bool tf_5=false;
bool tf_6=false;
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,SignalBufferBlue,INDICATOR_DATA);
   SetIndexBuffer(1,SignalBufferRed,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- sets first bar from what index will be drawn
   SetIndexArrow(0, 233);
   SetIndexArrow(1, 234);
	//  PlotIndexSetInteger(0,PLOT_ARROW,233);
  //  PlotIndexSetInteger(1,PLOT_ARROW,234);
//--- arrow shifts when drawing
  //  PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,ExtArrowShift);
  //  PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-ExtArrowShift);
//--- sets drawing line empty value--
  //  PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
  //  PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

      ArrayInitialize(SignalBufferBlue,0);
      ArrayInitialize(SignalBufferRed,0);

Comment("");
   int X=300,Y=0;
   if (str_period(tf0)!="err") {ButtonCreate(0,"cm tf 1",0,X,Y,30,20,CORNER_LEFT_UPPER,str_period(tf0),"Arial",10,clrBlack,clrLightGray,clrNONE,true,false,false,true,0,"TF 1");X+=32;}
   if (str_period(tf1)!="err") {ButtonCreate(0,"cm tf 2",0,X,Y,30,20,CORNER_LEFT_UPPER,str_period(tf1),"Arial",10,clrBlack,clrLightGray,clrNONE,true,false,false,true,0,"TF 2");X+=32;}
   if (str_period(tf2)!="err") {ButtonCreate(0,"cm tf 3",0,X,Y,30,20,CORNER_LEFT_UPPER,str_period(tf2),"Arial",10,clrBlack,clrLightGray,clrNONE,true,false,false,true,0,"TF 3");X+=32;}
   if (str_period(tf3)!="err") {ButtonCreate(0,"cm tf 4",0,X,Y,30,20,CORNER_LEFT_UPPER,str_period(tf3),"Arial",10,clrBlack,clrLightGray,clrNONE,true,false,false,true,0,"TF 4");X+=32;}
   if (str_period(tf4)!="err") {ButtonCreate(0,"cm tf 5",0,X,Y,30,20,CORNER_LEFT_UPPER,str_period(tf4),"Arial",10,clrBlack,clrLightGray,clrNONE,true,false,false,true,0,"TF 5");X+=32;}
   if (str_period(tf5)!="err") {ButtonCreate(0,"cm tf 6",0,X,Y,30,20,CORNER_LEFT_UPPER,str_period(tf5),"Arial",10,clrBlack,clrLightGray,clrNONE,true,false,false,true,0,"TF 6");X+=32;}

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeInit(const int reason)
{
   if (reason!=REASON_CHARTCHANGE && reason!=REASON_RECOMPILE) ObjectsDeleteAll(0,"cm tf");
}
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,// обработано баров на предыдущем вызове 
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   ArraySetAsSeries(SignalBufferBlue,true);
   ArraySetAsSeries(SignalBufferRed,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   int i,limit;
   limit=rates_total-prev_calculated-1;
   if(rates_total<1) return(0);
   double d=(high[1]-low[1]+high[2]-low[2])/2;
   //Comment(iBarShift(NULL,tf2,time[0],false));
   
   if (Period()>tf0) ObjectSetInteger(0,"cm tf 1" ,OBJPROP_STATE,false);
   if (Period()>tf1) ObjectSetInteger(0,"cm tf 2" ,OBJPROP_STATE,false);
   if (Period()>tf2) ObjectSetInteger(0,"cm tf 3" ,OBJPROP_STATE,false);
   if (Period()>tf3) ObjectSetInteger(0,"cm tf 4" ,OBJPROP_STATE,false);
   if (Period()>tf4) ObjectSetInteger(0,"cm tf 5" ,OBJPROP_STATE,false);
   if (Period()>tf5) ObjectSetInteger(0,"cm tf 6" ,OBJPROP_STATE,false);

   if (tf_1 != ObjectGetInteger(0,"cm tf 1" ,OBJPROP_STATE))  {tf_1 = ObjectGetInteger(0,"cm tf 1" ,OBJPROP_STATE);limit=rates_total-1;}
   if (tf_2 != ObjectGetInteger(0,"cm tf 2" ,OBJPROP_STATE))  {tf_2 = ObjectGetInteger(0,"cm tf 2" ,OBJPROP_STATE);limit=rates_total-1;}
   if (tf_3 != ObjectGetInteger(0,"cm tf 3" ,OBJPROP_STATE))  {tf_3 = ObjectGetInteger(0,"cm tf 3" ,OBJPROP_STATE);limit=rates_total-1;}
   if (tf_4 != ObjectGetInteger(0,"cm tf 4" ,OBJPROP_STATE))  {tf_4 = ObjectGetInteger(0,"cm tf 4" ,OBJPROP_STATE);limit=rates_total-1;}
   if (tf_5 != ObjectGetInteger(0,"cm tf 5" ,OBJPROP_STATE))  {tf_5 = ObjectGetInteger(0,"cm tf 5" ,OBJPROP_STATE);limit=rates_total-1;}
   if (tf_6 != ObjectGetInteger(0,"cm tf 6" ,OBJPROP_STATE))  {tf_6 = ObjectGetInteger(0,"cm tf 6" ,OBJPROP_STATE);limit=rates_total-1;}
   
   if (limit>1)
   {
      ArrayInitialize(SignalBufferBlue,0);
      ArrayInitialize(SignalBufferRed,0);
   }
   
   ObjectSetInteger(0,"cm tf 1",OBJPROP_BGCOLOR,iOpen(NULL,tf0,iBarShift(NULL,tf0,time[0],false))>iClose(NULL,tf0,iBarShift(NULL,tf0,time[0],false))?clrRed:clrLime); 
   ObjectSetInteger(0,"cm tf 2",OBJPROP_BGCOLOR,iOpen(NULL,tf1,iBarShift(NULL,tf1,time[0],false))>iClose(NULL,tf1,iBarShift(NULL,tf1,time[0],false))?clrRed:clrLime); 
   ObjectSetInteger(0,"cm tf 3",OBJPROP_BGCOLOR,iOpen(NULL,tf2,iBarShift(NULL,tf2,time[0],false))>iClose(NULL,tf2,iBarShift(NULL,tf2,time[0],false))?clrRed:clrLime); 
   ObjectSetInteger(0,"cm tf 4",OBJPROP_BGCOLOR,iOpen(NULL,tf3,iBarShift(NULL,tf3,time[0],false))>iClose(NULL,tf3,iBarShift(NULL,tf3,time[0],false))?clrRed:clrLime); 
   ObjectSetInteger(0,"cm tf 5",OBJPROP_BGCOLOR,iOpen(NULL,tf4,iBarShift(NULL,tf4,time[0],false))>iClose(NULL,tf4,iBarShift(NULL,tf4,time[0],false))?clrRed:clrLime); 
   ObjectSetInteger(0,"cm tf 6",OBJPROP_BGCOLOR,iOpen(NULL,tf5,iBarShift(NULL,tf5,time[0],false))>iClose(NULL,tf5,iBarShift(NULL,tf5,time[0],false))?clrRed:clrLime); 
   
   for(i=limit; i>=0; i--)
   {
      if (S<1 && 
         (!tf_1 || iOpen(NULL,tf0,iBarShift(NULL,tf0,time[i],false))<iClose(NULL,tf0,iBarShift(NULL,tf0,time[i],false))) && 
         (!tf_2 || iOpen(NULL,tf1,iBarShift(NULL,tf1,time[i],false))<iClose(NULL,tf1,iBarShift(NULL,tf1,time[i],false))) && 
         (!tf_3 || iOpen(NULL,tf2,iBarShift(NULL,tf2,time[i],false))<iClose(NULL,tf2,iBarShift(NULL,tf2,time[i],false))) && 
         (!tf_4 || iOpen(NULL,tf3,iBarShift(NULL,tf3,time[i],false))<iClose(NULL,tf3,iBarShift(NULL,tf3,time[i],false))) && 
         (!tf_5 || iOpen(NULL,tf4,iBarShift(NULL,tf4,time[i],false))<iClose(NULL,tf4,iBarShift(NULL,tf4,time[i],false))) && 
         (!tf_6 || iOpen(NULL,tf5,iBarShift(NULL,tf5,time[i],false))<iClose(NULL,tf5,iBarShift(NULL,tf5,time[i],false))))
      {
         SignalBufferBlue[i]=low[i]-d;
         if(i==1 && TimeAlert!=time[i]) Alert(Symbol()," Buy Signal");
         TimeAlert=time[i];
         S=1;
      }
      if(S>-1 && 
         (!tf_1 || iOpen(NULL,tf0,iBarShift(NULL,tf0,time[i],false))>iClose(NULL,tf0,iBarShift(NULL,tf0,time[i],false))) && 
         (!tf_2 || iOpen(NULL,tf1,iBarShift(NULL,tf1,time[i],false))>iClose(NULL,tf1,iBarShift(NULL,tf1,time[i],false))) && 
         (!tf_3 || iOpen(NULL,tf2,iBarShift(NULL,tf2,time[i],false))>iClose(NULL,tf2,iBarShift(NULL,tf2,time[i],false))) && 
         (!tf_4 || iOpen(NULL,tf3,iBarShift(NULL,tf3,time[i],false))>iClose(NULL,tf3,iBarShift(NULL,tf3,time[i],false))) && 
         (!tf_5 || iOpen(NULL,tf4,iBarShift(NULL,tf4,time[i],false))>iClose(NULL,tf4,iBarShift(NULL,tf4,time[i],false))) && 
         (!tf_6 || iOpen(NULL,tf5,iBarShift(NULL,tf5,time[i],false))>iClose(NULL,tf5,iBarShift(NULL,tf5,time[i],false))))
        {
         SignalBufferRed[i]=high[i]+d;
         if(i==1 && TimeAlert!=time[i]) Alert(Symbol()," Sell Signal");
         TimeAlert=time[i];
         S=-1;
      }
   }

   return(rates_total);
}
//+------------------------------------------------------------------+
string str_period(ENUM_TIMEFRAMES per)
{
   if(per == PERIOD_W1)  return("W1");
   if(per == PERIOD_D1)  return("D1");
   if(per == PERIOD_H4)   return("H4");
   if(per == PERIOD_H1)   return("H1");
   if(per == PERIOD_M30)  return("M30");
   if(per == PERIOD_M15)  return("M15");
   if(per == PERIOD_M5)   return("M5");
   if(per == PERIOD_M1)   return("M1");
   return("err");
}
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,               // ID графика 
                  const string            name="Button",            // имя кнопки 
                  const int               sub_window=0,             // номер подокна 
                  const int               x=0,                      // координата по оси X 
                  const int               y=0,                      // координата по оси Y 
                  const int               width=50,                 // ширина кнопки 
                  const int               height=18,                // высота кнопки 
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // угол графика для привязки 
                  const string            text="Button",            // текст 
                  const string            font="Arial",             // шрифт 
                  const int               font_size=10,             // размер шрифта 
                  const color             clr=clrBlack,             // цвет текста 
                  const color             back_clr=C'236,233,216',  // цвет фона 
                  const color             border_clr=clrNONE,       // цвет границы 
                  const bool              state=false,              // нажата/отжата 
                  const bool              back=false,               // на заднем плане 
                  const bool              selection=false,          // выделить для перемещений 
                  const bool              hidden=true,              // скрыт в списке объектов 
                  const long              z_order=0,// приоритет на нажатие мышью 
                const string           podskazka="")                // 
  { 

   if(ObjectFind(chart_ID,name)==0) return(true); 
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0)) return(false); 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height); 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr); 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr); 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
      ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,podskazka);
   return(true); 
  } 
//+------------------------------------------------------------------+ 
