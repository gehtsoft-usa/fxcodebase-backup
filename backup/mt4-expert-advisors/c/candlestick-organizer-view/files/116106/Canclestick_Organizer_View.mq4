// Id: 19757

//More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=65375

//+------------------------------------------------------------------+
//|                                   Candlestick_Organizer_View.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 18

extern bool  Organized_view       = true;
extern int	 Wick_Width           = 1;
extern int	 Candle_Width	       = 6;
extern color Bullish_Wick_Color   = clrAqua;
extern color Bullish_Candle_Color = clrDodgerBlue;
extern color Bearish_Wick_Color   = clrLightPink;
extern color Bearish_Candle_Color = clrCrimson;
extern color Price_Color          = clrDarkGray;

double Bullish_Wick_High[];
double Bullish_Wick_Low[];
double Bullish_Candle_High[];
double Bullish_Candle_Low[];
double Bearish_Wick_High[];
double Bearish_Wick_Low[];
double Bearish_Candle_High[];
double Bearish_Candle_Low[];
double Empty[];

double Org_Bullish_Wick_High[];
double Org_Bullish_Wick_Low[];
double Org_Bullish_Candle_High[];
double Org_Bullish_Candle_Low[];
double Org_Bearish_Wick_High[];
double Org_Bearish_Wick_Low[];
double Org_Bearish_Candle_High[];
double Org_Bearish_Candle_Low[];
double Org_Empty[];

string WindowName;
int i;

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
	
	IndicatorName = GenerateIndicatorName("Candlestick_Organizer_View");
	IndicatorObjPrefix = "__" + IndicatorName + "__";
	IndicatorShortName(IndicatorName);

	IndicatorBuffers(18);
					
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
	
	SetIndexBuffer(9,Org_Bullish_Wick_High);
	SetIndexBuffer(10,Org_Bullish_Candle_High);
	SetIndexBuffer(11,Org_Bullish_Candle_Low);
	SetIndexBuffer(12,Org_Bullish_Wick_Low);
	
	SetIndexBuffer(13,Org_Bearish_Wick_High);
	SetIndexBuffer(14,Org_Bearish_Candle_High);
	SetIndexBuffer(15,Org_Bearish_Candle_Low);
	SetIndexBuffer(16,Org_Bearish_Wick_Low);
	SetIndexBuffer(17,Org_Empty);
	
	if (Organized_view){
	   int Draw_Histogram2 = DRAW_HISTOGRAM;
	   int Draw_Histogram = DRAW_NONE;
	}else{
	   Draw_Histogram = DRAW_HISTOGRAM;
	   Draw_Histogram2 = DRAW_NONE;
	}
	
	SetIndexStyle(0,Draw_Histogram,0,Wick_Width,Bullish_Wick_Color);
	SetIndexStyle(1,Draw_Histogram,0,Candle_Width,Bullish_Candle_Color);
	SetIndexStyle(2,Draw_Histogram,0,Candle_Width,BGColor);
	SetIndexStyle(3,Draw_Histogram,0,Wick_Width,Bullish_Wick_Color);
	
	SetIndexStyle(4,Draw_Histogram,0,Wick_Width,Bearish_Wick_Color);
	SetIndexStyle(5,Draw_Histogram,0,Candle_Width,Bearish_Candle_Color);
	SetIndexStyle(6,Draw_Histogram,0,Candle_Width,BGColor);
	SetIndexStyle(7,Draw_Histogram,0,Wick_Width,Bearish_Wick_Color);
	
	SetIndexStyle(8,Draw_Histogram,0,Candle_Width,BGColor);
	
	SetIndexLabel(0,"Bullish High");
	SetIndexLabel(1,"Bullish Close");
	SetIndexLabel(2,"Bullish Open");
	SetIndexLabel(4,"Bearish High");
	SetIndexLabel(5,"Bearish Open");
	SetIndexLabel(6,"Bearish Close");
	SetIndexLabel(8,"Candle Low");
	
	SetIndexStyle(9,Draw_Histogram2,0,Wick_Width,Bullish_Wick_Color);
	SetIndexStyle(10,Draw_Histogram2,0,Candle_Width,Bullish_Candle_Color);
	SetIndexStyle(11,Draw_Histogram2,0,Candle_Width,BGColor);
	SetIndexStyle(12,Draw_Histogram2,0,Wick_Width,Bullish_Wick_Color);
	
	SetIndexStyle(13,Draw_Histogram2,0,Wick_Width,Bearish_Wick_Color);
	SetIndexStyle(14,Draw_Histogram2,0,Candle_Width,Bearish_Candle_Color);
	SetIndexStyle(15,Draw_Histogram2,0,Candle_Width,BGColor);
	SetIndexStyle(16,Draw_Histogram2,0,Wick_Width,Bearish_Wick_Color);
	
	SetIndexStyle(17,Draw_Histogram2,0,Candle_Width,BGColor);
	
	SetIndexLabel(9,"Organized Bullish High");
	SetIndexLabel(10,"Organized Bullish Close");
	SetIndexLabel(11,"Organized Bullish Open");
	SetIndexLabel(13,"Organized Bearish High");
	SetIndexLabel(14,"Organized Bearish Open");
	SetIndexLabel(15,"Organized Bearish Close");
	SetIndexLabel(17,"Organized Candle Low");

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
	
	int current = 0;
	int candle_number = 0;
	int candle_type;
	
	for(i = current; i <= 1000; i++){
	   Bullish_Wick_High[i]=EMPTY_VALUE;
      Bullish_Wick_Low[i]=EMPTY_VALUE;
      Bullish_Candle_High[i]=EMPTY_VALUE;
      Bullish_Candle_Low[i]=EMPTY_VALUE;
      Bearish_Wick_High[i]=EMPTY_VALUE;
      Bearish_Wick_Low[i]=EMPTY_VALUE;
      Bearish_Candle_High[i]=EMPTY_VALUE;
      Bearish_Candle_Low[i]=EMPTY_VALUE;
      Empty[i]=EMPTY_VALUE;
      
      Org_Bullish_Wick_High[i]=EMPTY_VALUE;
      Org_Bullish_Wick_Low[i]=EMPTY_VALUE;
      Org_Bullish_Candle_High[i]=EMPTY_VALUE;
      Org_Bullish_Candle_Low[i]=EMPTY_VALUE;
      Org_Bearish_Wick_High[i]=EMPTY_VALUE;
      Org_Bearish_Wick_Low[i]=EMPTY_VALUE;
      Org_Bearish_Candle_High[i]=EMPTY_VALUE;
      Org_Bearish_Candle_Low[i]=EMPTY_VALUE;
      Org_Empty[i]=EMPTY_VALUE;
      current = 0;
	   candle_number = 0;
	}
	WindowRedraw();
	
	//for(int i = current; i <= MathMax(Bars-1-IndicatorCounted(),1); i++){
	for(i = current; i <= 1000; i++){

   	if (i == 0){
   	   
      	 if (Close[i]>Open[i]){
      	   
      	   Bullish_Wick_High[current]   = High[i];
      	   Bullish_Candle_High[current] = Close[i];
      	   Bullish_Candle_Low[current] = Open[i];
      	   Bullish_Wick_Low[current]    = Open[i];
      	   // Down Empty
   	      Empty[current] = Low[i];
      	   
      	   candle_type = 1;
      	
      	}
      	// Bearish Candle
      	else{
      	
      	   Bearish_Wick_High[current]   = High[i];
      	   Bearish_Candle_High[current] = Open[i];
      	   Bearish_Candle_Low[current] = Close[i];
      	   Bearish_Wick_Low[current]    = Close[i];
      	   // Down Empty
   	      Empty[current] = Low[i];
      	   
      	   candle_type = 0;
      	
      	}
   	   
   	}
   	else{
   	
   	
   	   if (candle_type == 1){
   	   
   	      if (Close[i]<Open[i]){
   	      
      	      current = i;
      	      Bearish_Wick_High[current]   = High[i];
         	   Bearish_Candle_High[current] = Open[i];
         	   Bearish_Candle_Low[current] = Close[i];
         	   Bearish_Wick_Low[current]    = Close[i];
         	   // Down Empty
   	         Empty[current] = Low[i];
         	   candle_type = 0;
         	   
         	}
         	else{
         	
         	   if (High[i] > Bullish_Wick_High[current]){
         	      Bullish_Wick_High[current]   = High[i];
            	   Bullish_Candle_High[current] = Close[current];
         	   }
         	   Bullish_Candle_Low[current] = Open[i];
            	Bullish_Wick_Low[current]   = Open[i];
         	   if (Low[i]  < Empty[current]) Empty[current] = Low[i];
         	
         	}
   	   
   	   }
   	   
   	   if (candle_type == 0){
   	   
   	      if (Close[i]>Open[i]){
   	      
      	      current = i;
      	      Bullish_Wick_High[current]   = High[i];
         	   Bullish_Candle_High[current] = Close[i];
         	   Bullish_Candle_Low[current] = Open[i];
         	   Bullish_Wick_Low[current]    = Open[i];
         	   // Down Empty
   	         Empty[current] = Low[i];
         	   candle_type = 1;
         	   
         	}
         	else{
         	
         	   if (High[i] > Bearish_Wick_High[current]){
         	      Bearish_Wick_High[current]   = High[i];
            	   Bearish_Candle_High[current] = Open[i];
         	   }
         	   Bearish_Candle_Low[current] = Close[current];
            	Bearish_Wick_Low[current]   = Close[current];
         	   if (Low[i]  < Empty[current]) Empty[current] = Low[i];
         	
         	}
   	   
   	   }
   	
   	}
		
	}
	
	int org_i = 0;
	
	for(i = 0; i <= 1000; i++){
	
	   if (Bullish_Wick_High[i]!=EMPTY_VALUE){
	      Org_Bullish_Wick_High[org_i]   = Bullish_Wick_High[i];
   	   Org_Bullish_Candle_High[org_i] = Bullish_Candle_High[i];
   	   Org_Bullish_Candle_Low[org_i] = Bullish_Candle_Low[i];
   	   Org_Bullish_Wick_Low[org_i]    = Bullish_Wick_Low[i];
   	   // Down Empty
	      Org_Empty[org_i] = Empty[i];
	      org_i++;
	   }
	   
	   if (Bearish_Wick_High[i]!=EMPTY_VALUE){
	      Org_Bearish_Wick_High[org_i]   = Bearish_Wick_High[i];
   	   Org_Bearish_Candle_High[org_i] = Bearish_Candle_High[i];
   	   Org_Bearish_Candle_Low[org_i] = Bearish_Candle_Low[i];
   	   Org_Bearish_Wick_Low[org_i]    = Bearish_Wick_Low[i];
   	   // Down Empty
	      Org_Empty[org_i] = Empty[i];
	      org_i++;
	   }
	
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