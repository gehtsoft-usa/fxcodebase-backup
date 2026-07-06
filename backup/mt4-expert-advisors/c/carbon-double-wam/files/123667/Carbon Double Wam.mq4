// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67315

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red

#property indicator_level1 0
      
#property indicator_levelcolor Blue
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT
 

#property indicator_label1 "Carbon Double Wam" 


extern int Period1 = 21; 
extern int Period2 = 3; 
extern int Lag1 = 1; 
extern int Period3 = 21; 
extern int Period4 = 21; 
extern int Lag2 = 1; 
 
enum MA_Types{ SMA=1,  EMA=2, SMMA=3,LWMA=4 };
 
input  MA_Types MA_Type = SMA;
 
 
double Second1[];
double Second2[];
double First1[];
double First2[];

double DataA1[];
double DataB1[]; 

double DataA2[];
double DataB2[]; 

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
  

   IndicatorName = GenerateIndicatorName("Carbon Double Wam");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorBuffers(8);
   
   
   IndicatorDigits(Digits);
   
    
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, First1);
   SetIndexLabel(0,"First1");
   SetIndexDrawBegin(0,0);
   
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, First2);
   SetIndexLabel(1,"First2");
   SetIndexDrawBegin(1,0);
   
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Second1);
   SetIndexLabel(2,"Second1");
   SetIndexDrawBegin(2,0);
   
   
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, Second2);
   SetIndexLabel(3,"Second2");
   SetIndexDrawBegin(3,0);
   
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, DataA1);
   
   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, DataB1);
   
   SetIndexStyle(6, DRAW_NONE);
   SetIndexBuffer(6, DataA2);
   
   SetIndexStyle(7, DRAW_NONE);
   SetIndexBuffer(7, DataB2);
   
 
 
    
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   //int limit = Bars - 1;
   int limit = Bars - 2;
   
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars;
   int pos = limit;
 
   double A;
   double B;
   double A_Shift;
   double B_Shift;
   
   while (pos >= 0)
   {
 
 
   
   A=iMA(NULL,0,Period1,0,(MA_Type-1),PRICE_CLOSE,pos);
   B=iMA(NULL,0,Period2,0,(MA_Type-1),PRICE_CLOSE,pos);
   
   A_Shift=iMA(NULL,0,Period1,Lag1,(MA_Type-1),PRICE_CLOSE,pos);
   B_Shift=iMA(NULL,0,Period2,Lag2,(MA_Type-1),PRICE_CLOSE,pos);
   
   First1[pos] =A;
   First2[pos] =B;
   
   DataA1[pos]=A-A_Shift; 
   DataB1[pos]=B-B_Shift; 
   
    
   
		 
	  
      pos--;
   } 
   
   
   double C;
   double D;
   double C_Shift;
   double D_Shift;
   
   pos = limit;
 
   while (pos >= 0)
   {
   
   C=iMAOnArray(DataA1,0,Period3,0,(MA_Type-1),pos);
   D=iMAOnArray(DataB1,0,Period3,0,(MA_Type-1),pos);
   
   
   C_Shift=iMAOnArray(DataA1,0,Period3,Lag1,(MA_Type-1),pos);
   D_Shift=iMAOnArray(DataB1,0,Period3,Lag2,(MA_Type-1),pos);
   
   
    DataA2[pos]=C-C_Shift; 
	DataB2[pos]=D-D_Shift;  
	

                
    pos--;
   } 
   
   
   pos = limit;
   double E;
   double F;
 
   while (pos >= 0)
   {
   
   
   E=iMAOnArray(DataA2,0,Period4,0,(MA_Type-1),pos);
   F=iMAOnArray(DataB2,0,Period4,0,(MA_Type-1),pos);
   
        if (Point()!= 0)
		{
			First1[pos] = E/Point();
			First2[pos] = F/Point();
			Second1[pos] = -E/Point();
			Second2[pos] = -F/Point();
		}	
                
    pos--;
   } 
 
  
 
   return(0);
}