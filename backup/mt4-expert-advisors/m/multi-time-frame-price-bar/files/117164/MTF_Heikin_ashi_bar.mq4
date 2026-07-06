// Id: 21528
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65655

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 9

extern string TimeFrames           = "5,15,30,60,240,1440,10080,43200";
extern int	  Wick_Width           = 1;
extern int	  Candle_Width	        = 6;
extern color  Bullish_Wick_Color   = clrAqua;
extern color  Bullish_Candle_Color = clrDodgerBlue;
extern color  Bearish_Wick_Color   = clrLightPink;
extern color  Bearish_Candle_Color = clrCrimson;
extern color  Price_Color          = clrDarkGray;

double Bullish_Wick_High[];
double Bullish_Wick_Low[];
double Bullish_Candle_High[];
double Bullish_Candle_Low[];
double Bearish_Wick_High[];
double Bearish_Wick_Low[];
double Bearish_Candle_High[];
double Bearish_Candle_Low[];
double Empty[];

string TF_arr[]; // TimeFrames
int    TF_count; // Number of TFs

string WindowName;

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

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
	
	WindowName = "MTF_Heikin_ashi_bar ("+Symbol()+")";
	IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
	IndicatorBuffers(9);
					
	color BGColor = BackgroundColor();
	
	SetIndexBuffer(0,Bullish_Wick_High);
	SetIndexBuffer(1,Bullish_Candle_High);
	SetIndexBuffer(2,Bullish_Candle_Low);
	SetIndexBuffer(3,Bullish_Wick_Low);
	
	SetIndexBuffer(4,Bearish_Wick_High);
	SetIndexBuffer(5,Bearish_Candle_High);
	SetIndexBuffer(6,Bearish_Candle_Low);
	SetIndexBuffer(7,Bearish_Wick_Low);
	SetIndexBuffer(8,Empty);
	
	SetIndexStyle(0,DRAW_HISTOGRAM,0,Wick_Width,Bullish_Wick_Color);
	SetIndexStyle(1,DRAW_HISTOGRAM,0,Candle_Width,Bullish_Candle_Color);
	SetIndexStyle(2,DRAW_HISTOGRAM,0,Candle_Width,BGColor);
	SetIndexStyle(3,DRAW_HISTOGRAM,0,Wick_Width,Bullish_Wick_Color);
	
	SetIndexStyle(4,DRAW_HISTOGRAM,0,Wick_Width,Bearish_Wick_Color);
	SetIndexStyle(5,DRAW_HISTOGRAM,0,Candle_Width,Bearish_Candle_Color);
	SetIndexStyle(6,DRAW_HISTOGRAM,0,Candle_Width,BGColor);
	SetIndexStyle(7,DRAW_HISTOGRAM,0,Wick_Width,Bearish_Wick_Color);
	
	SetIndexStyle(8,DRAW_HISTOGRAM,0,Candle_Width,BGColor);
	
	SetIndexLabel(0,"Bullish High");
	SetIndexLabel(1,"Bullish Close");
	SetIndexLabel(2,"Bullish Open");
	SetIndexLabel(4,"Bearish High");
	SetIndexLabel(5,"Bearish Open");
	SetIndexLabel(6,"Bearish Close");
	SetIndexLabel(8,"Candle Low");

	return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
	
	int i = 2;
	string TF_Label;
	int period;
	int x;
	split(TF_arr, TimeFrames, ",");
   TF_count = ArraySize(TF_arr);
   
 
	
	for (int j=0; j < TF_count; j++) {

   	TF_Label = Get_TimeFrame_Label(StringToInteger(TF_arr[j]));
      period = StringToInteger(TF_arr[j]);
   	
    
	
	for (x=10; x >= 1; x--) {
	
	 if(x== 10) 
	 {
	 double previoushaOpen=(iClose(NULL,period,x+1)+iOpen(NULL,period,x+1))/2;
	 }
	 else
	 {
	 
	  previoushaOpen= (previoushaOpen+ ((iHigh(NULL,period,x+1)+iLow(NULL,period,x+1)+iClose(NULL,period,x+1)+iOpen(NULL,period,x+1))/4))/2;
	 
	 }
	 
	 
	 
	
	}
    
	double previoushaClose=(iHigh(NULL,period,1)+iLow(NULL,period,1)+iClose(NULL,period,1)+iOpen(NULL,period,1))/4;
   
    double haOpen=(previoushaClose+previoushaOpen)/2;
	
    double haClose=(iHigh(NULL,period,0)+iLow(NULL,period,0)+iClose(NULL,period,0)+iOpen(NULL,period,0))/4;
    double haHigh=MathMax(iHigh(NULL,period,0),MathMax(haOpen,haClose));
    double haLow=MathMin(iLow(NULL,period,0),MathMin(haOpen,haClose));
	 
	 
 
	
   	// Bulish Candle
   	if (haOpen<=haClose){
   	
   	   Bullish_Wick_High[i]   = haHigh;
   	   Bullish_Candle_High[i] = haClose;
   	   Bullish_Candle_Low[i] = haOpen;
   	   Bullish_Wick_Low[i]    = haOpen;
	   
   	
   	}
   	// Bearish Candle
   	else{
   	
   	   Bearish_Wick_High[i]   = haHigh;
   	   Bearish_Candle_High[i] = haOpen;
   	   Bearish_Candle_Low[i] = haClose;
   	   Bearish_Wick_Low[i]    = haClose;
   	

   	}
   	// Down Empty
   	Empty[i] =haLow;
	Empty[i+1] = haHigh ;
  
   	
   	ObjectMakeText("Label_"+period, Time[i-2], iClose(NULL,period,0), "- "+TF_Label, clrWhite );
   	
   	i+=5;
		
	}
	
   Price((Close[0]),Price_Color);
   
	return(0);
}
//+------------------------------------------------------------------+

color BackgroundColor(){
   long bgcolor=clrNONE;
   ResetLastError();
   if(!ChartGetInteger(0,CHART_COLOR_BACKGROUND,0,bgcolor)){
      Print(__FUNCTION__+", Error_Code = ",GetLastError());
   }
   return((color)bgcolor);
}

void Price(double precio, color P_Color){
   ObjectDelete(IndicatorObjPrefix + "Price");
   ObjectCreate(IndicatorObjPrefix + "Price", OBJ_HLINE, WindowFind(WindowName),0,precio);
   ObjectSet(IndicatorObjPrefix + "Price", OBJPROP_COLOR, P_Color);
   ObjectSet(IndicatorObjPrefix + "Price", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(IndicatorObjPrefix + "Price", OBJPROP_WIDTH, 0);
   ObjectSet(IndicatorObjPrefix + "Price", OBJPROP_BACK, False);
}

void split(string& arr[], string str, string sym) 
{
  ArrayResize(arr, 0);
  string item;
  int pos, size;
  
  int len = StringLen(str);
  for (int i=0; i < len;) {
    pos = StringFind(str, sym, i);
    if (pos == -1) pos = len;
    
    item = StringSubstr(str, i, pos-i);
    item = StringTrimLeft(item);
    item = StringTrimRight(item);
    
    size = ArraySize(arr);
    ArrayResize(arr, size+1);
    arr[size] = item;
    
    i = pos+1;
  }
}

string Get_TimeFrame_Label(int TF){
   string Label;
   if (TF==5)     Label = "M5";
   if (TF==15)    Label = "M15";
   if (TF==30)    Label = "M30";
   if (TF==60)    Label = "H1";
   if (TF==240)   Label = "H4";
   if (TF==1440)  Label = "D1";
   if (TF==10080) Label = "W1";
   if (TF==43200) Label = "MN1";
   return(Label);
}

// Position Text
void ObjectMakeText( string nm, datetime tiempo1, double precio1, string Texto, color TColor ){
   ObjectDelete(IndicatorObjPrefix + nm);
   ObjectCreate(IndicatorObjPrefix +  nm, OBJ_TEXT, WindowFind(WindowName), tiempo1, precio1 );
   ObjectSetText(IndicatorObjPrefix +  nm, Texto, 9, "Arial", TColor );
   ObjectSet(IndicatorObjPrefix + nm, OBJPROP_TIME1, tiempo1);
   ObjectSet(IndicatorObjPrefix + nm, OBJPROP_PRICE1, precio1);
   return;
}