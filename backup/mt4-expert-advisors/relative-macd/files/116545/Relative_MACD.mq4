// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65466

//+------------------------------------------------------------------+
//|                                                Relative_MACD.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  clrDodgerBlue
#property  indicator_color2  clrRed
#property  indicator_color3  clrLime
#property  indicator_color4  clrRed

#property indicator_width1 2
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3

extern int    FastEMA            = 12;
extern int    SlowEMA            = 26;
extern int    SignalEMA          = 9;
extern bool   Show_Percent_Lines = true;
extern double Percent_Line_1     = 5.0;
extern double Percent_Line_2     = 10.0;
extern double Percent_Line_3     = 15.0;

double ind_buffer1[];
double ind_buffer2[];
double HistogramBufferUp[];
double HistogramBufferDown[];

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

int init(){
   
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID);
   SetIndexBuffer(0,ind_buffer1);
   SetIndexDrawBegin(0,SlowEMA);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID);
   SetIndexBuffer(1,ind_buffer2);
   SetIndexDrawBegin(1,SignalEMA);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(2,HistogramBufferUp);
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(3,HistogramBufferDown);
   IndicatorName = GenerateIndicatorName("Relative MACD("+FastEMA+","+SlowEMA+","+SignalEMA+")");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   SetIndexLabel(0,"MACD");
   SetIndexLabel(1,"Signal");
   SetIndexLabel(2,"Histogram");
   
   return(0);
   
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start(){

   int limit;
   double temp, temp1;
   
   Zone_Area("Relative_MACDRedZone", Time[limit-10],0,Time[0]+84600,-2,C'44,0,0');
   Zone_Area("Relative_MACDGreenZone", Time[limit-10],2,Time[0]+84600,0,C'0,22,0');
   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   for(int i=0; i<limit; i++)
      ind_buffer1[i]=(iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i)) / (iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i)/100);
   for(i=0; i<limit; i++)
      ind_buffer2[i]=iMAOnArray(ind_buffer1,Bars,SignalEMA,0,MODE_EMA,i);
   for(i=0; i<limit; i++)
   {
      HistogramBufferUp[i] = 0;
      HistogramBufferDown[i] = 0;
      temp = ind_buffer1[i] - ind_buffer2[i];
      temp1 = ind_buffer1[i+1] - ind_buffer2[i+1];
      if (temp >= temp1)
        HistogramBufferUp[i] = temp;
      else
        HistogramBufferDown[i] = temp;  
   }
      
   return(0);
 }
 
 void Zone_Area(string Nombre, datetime tiempo1, double precio1, datetime tiempo2, double precio2, color zcolor, bool backobj = true){
   ObjectDelete(IndicatorObjPrefix + Nombre);
   ObjectCreate(IndicatorObjPrefix + Nombre,OBJ_RECTANGLE,WindowFind("Relative MACD("+FastEMA+","+SlowEMA+","+SignalEMA+")"),tiempo1,precio1,tiempo2,precio2);
   ObjectSet(IndicatorObjPrefix + Nombre,OBJPROP_COLOR,zcolor);
   ObjectSet(IndicatorObjPrefix + Nombre,OBJPROP_BACK,backobj);
   return;
}
