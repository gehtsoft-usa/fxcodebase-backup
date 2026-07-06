//+------------------------------------------------------------------+
//|                                           Overbough_Oversold.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

 //Added By My
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 1

//#property indicator_buffers 2
#property indicator_color1 Red

extern int Length=20;
extern int MA_Method=0;

extern double OB=70;
extern double OS=30; 

double Overbough_Oversold[];
double St[];

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
    //Added By My
   IndicatorBuffers(2);
   
   IndicatorName = GenerateIndicatorName("OB/OS");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Overbough_Oversold);
  //Deleted By Me 
  //SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,St);
   
   
    int windowIndex=WindowFind(IndicatorName);
   // finding the window number of our indicator
   
   if(windowIndex<0)
   {
      // if the number is -1, there is an error
      Print("Can\'t find window");
      return(0);
   }  
 
   ObjectCreate(IndicatorObjPrefix + "OB",OBJ_HLINE,windowIndex,0,OB);
   ObjectCreate(IndicatorObjPrefix + "OS",OBJ_HLINE,windowIndex,0,OS);
   // drawing a line in the indicator subwindow
               
   ObjectSet(IndicatorObjPrefix + "OB",OBJPROP_COLOR,GreenYellow);
   ObjectSet(IndicatorObjPrefix + "OB",OBJPROP_WIDTH,3);
   
    ObjectSet(IndicatorObjPrefix + "OS",OBJPROP_COLOR,GreenYellow);
   ObjectSet(IndicatorObjPrefix + "OS",OBJPROP_WIDTH,3);
 
   WindowRedraw();      
   // redraw the window to see the line
   
   

   return(0);
  }

int deinit()
  {
  
  
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   // delete all objects

   return(0);
  }

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  St[pos]=Close[pos]-Low[pos];
  pos--;
 } 
 pos=limit;
 double ATR;
 while(pos>=0)
 {
  ATR=iATR(NULL, 0, Length, pos);
  if (ATR!=0)
  {
   Overbough_Oversold[pos]=100*iMAOnArray(St, 0, Length, 0, MA_Method, pos)/ATR;
  } 
  pos--;
 } 

 return(0);
}

