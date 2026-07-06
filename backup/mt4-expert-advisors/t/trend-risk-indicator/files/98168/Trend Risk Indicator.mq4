// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=61722
// Id: 13436

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+


#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4

#property indicator_color1  Chartreuse
#property indicator_color2 Chartreuse

extern int Period=3;
extern int BandBars=28;
extern double Deviation=3.5;

extern color Up = Lime;
extern color Down = Red;
extern color Neutral = Silver;
extern int CandleWidth=3;

double PrH[], PrL[];
double SmoothPrice[];
double SmoothRange[];
double Top[];
double Bottom[];
double Color[];
int Window;

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

string IndName;

int init()
  {
  
   IndicatorBuffers(8); 
   IndicatorName = GenerateIndicatorName(IndName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndName = IndicatorName;
   IndicatorDigits(Digits);
         
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Top);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Bottom);
   
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,PrH);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,PrL);
   
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,SmoothPrice);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,SmoothRange);
   
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(6,Color);
   
   SetIndexStyle(7,DRAW_NONE);
   SetIndexBuffer(7,PrL);

   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }

void DrawCandle(datetime T, double O, double H, double L, double C, color  iColor)
{
 string ObjName=IndicatorObjPrefix + ""+T;
 double MaxBody=MathMax(O, C);
 double MinBody=MathMin(O, C);

 Window=WindowFind(IndName);
 if (Window==-1) return;
 if (ObjectFind(ObjName+"R")!=-1)
 {
  ObjectSet(ObjName+"R", OBJPROP_TIME1, T);
  ObjectSet(ObjName+"R", OBJPROP_TIME2, T);
  ObjectSet(ObjName+"R", OBJPROP_PRICE1, O);
  ObjectSet(ObjName+"R", OBJPROP_PRICE2, C);
 }
 else
 {
  ObjectCreate(ObjName+"R", OBJ_TREND, Window, T, O, T, C);
 } 
 ObjectSet(ObjName+"R", OBJPROP_COLOR, iColor);
 ObjectSet(ObjName+"R", OBJPROP_RAY, false);
 ObjectSet(ObjName+"R", OBJPROP_WIDTH, CandleWidth);
 
 if (ObjectFind(ObjName+"H")!=-1)
 {
  ObjectSet(ObjName+"H", OBJPROP_TIME1, T);
  ObjectSet(ObjName+"H", OBJPROP_TIME2, T);
  ObjectSet(ObjName+"H", OBJPROP_PRICE1, MaxBody);
  ObjectSet(ObjName+"H", OBJPROP_PRICE2, H);
 }
 else
 {
  ObjectCreate(ObjName+"H", OBJ_TREND, Window, T, MaxBody, T, H);
 } 
 ObjectSet(ObjName+"H", OBJPROP_COLOR, iColor);
 ObjectSet(ObjName+"H", OBJPROP_RAY, false);
 ObjectSet(ObjName+"H", OBJPROP_WIDTH, 1);

 if (ObjectFind(ObjName+"L")!=-1)
 {
  ObjectSet(ObjName+"L", OBJPROP_TIME1, T);
  ObjectSet(ObjName+"L", OBJPROP_TIME2, T);
  ObjectSet(ObjName+"L", OBJPROP_PRICE1, MinBody);
  ObjectSet(ObjName+"L", OBJPROP_PRICE2, L);
 }
 else
 {
  ObjectCreate(ObjName+"L", OBJ_TREND, Window, T, MinBody, T, L);
 } 
 ObjectSet(ObjName+"L", OBJPROP_COLOR, iColor);
 ObjectSet(ObjName+"L", OBJPROP_RAY, false);
 ObjectSet(ObjName+"L", OBJPROP_WIDTH, 1);
 return;
}  

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;

 
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 
 pos=limit;
 
 while(pos>=0)
 {
 
    if (pos==limit)  
	{
    SmoothPrice[pos]=Close[pos];
    SmoothRange[pos]=High[pos]-Low[pos];
	}
    else 
	{
    SmoothPrice[pos]=(SmoothPrice[pos+1]*(BandBars-1)+Close[pos])/BandBars;
    SmoothRange[pos]=(SmoothRange[pos+1]*(BandBars-1)+High[pos]-Low[pos])/BandBars;
	}
  
    Top[pos]=SmoothPrice[pos]+SmoothRange[pos]*Deviation;
    Bottom[pos]=SmoothPrice[pos]-SmoothRange[pos]*Deviation;
    
  
  
	  PrH[pos]=High[pos];
	  PrL[pos]=Low[pos]; 
  pos--;
 } 
 
 pos=limit;
 
 while(pos>=0)
 {
 
			   Color[pos] = Color[pos+1];
				Check(pos);
			 
			  if (Color[pos] == 1) 
			  {
			  DrawCandle(Time[pos],Open[pos],High[pos],Low[pos],Close[pos], Up);
			  }
			  else
			  {
				  if (Color[pos] == -1)
				  {
				  DrawCandle(Time[pos],Open[pos],High[pos],Low[pos],Close[pos], Down);
				  }
				  else
				  {
					DrawCandle(Time[pos],Open[pos],High[pos],Low[pos],Close[pos], Neutral);
				  }
				  
			  }
 
  
  
  pos--;
 } 

 return(0);
}


 
void Check(int X)

  { 
    int i;
	int  T=1;
	int  D=1;
	int  N=1;
	
	for (i= X; i < X+Period-1 ; i++ )
	
	{
	    if (Close[i]< Top[i]) T=0;
		if (Close[i]> Bottom[i] ) D=0;
		if ( Close[i] <  Bottom[i] || Close[i]> Top[i] ) N=0;
			
	    if (T== 0 && D== 0 && N== 0 )
		{
		break;
		}
	
	}
	
    if (T== 1) Color[X]= 1;
	if (D== 1) Color[X]=-1;
	if (N== 1) Color[X] =0; 
    
}



