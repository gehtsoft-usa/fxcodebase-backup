// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69685


//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
 
 

//+-------------------------------------------------------------------------------------------+
//| Indicator Global Inputs                                                                   |                                                        
//+-------------------------------------------------------------------------------------------+ 
#property indicator_chart_window
#property indicator_buffers 8

#property indicator_color1 Tomato
#property indicator_color2 DodgerBlue
#property indicator_color3 Tomato
#property indicator_color4 DodgerBlue
#property indicator_color5 Tomato
#property indicator_color6 DodgerBlue
#property indicator_color7 Tomato
#property indicator_color8 DodgerBlue

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 4
#property indicator_width6 4
#property indicator_width7 5
#property indicator_width8 5

//global external inputs
extern string Copyright                       = "enigma4x";                        
extern bool   Indicator_On                    = true;                             
extern string Note_1                          = "Price Type:";
extern string Note_2                          = "1= Candlesticks";   
extern string Note_3                          = "2= Haiken Ashi";
extern int    PriceType                       = 1;  
extern string Note_4                          = "Volume Type:";     
extern string Note_5                          = "1= NVO  (0,3,5,7,9 widths)";   
extern string Note_6                          = "2= Sonic R  (0,5,9 widths)";
extern string Note_7                          = "3= HighLow Volume  (3,9 widths)";
extern string Note_15                         = "4= Sonic R VSA  (0,3,9 widths - color coding climax)";
extern int    Volume_Type                     = 2;
extern int    Volume_Period_NVO_Sonic_R       = 20; 
extern int    Volume_Avg_Period_Sonic_R_VSA   = 10;
extern double Volume_Over_Avg_Fac_Sonic_R_VSA = 1.38;
extern int    Volume_Analy_GoBack_Sonic_R_VSA = 20;
extern string Note_8                          = "Candle Design:";
extern string Note_9                          = "1= TL";   
extern string Note_10                         = "2= Buffer";
extern string Note_11                         = "3= Mixed Buffer and TL";
extern int    Candle_Design                   = 2;  
extern string Note_12                         = "If is true then only visible Bars are calculated";
extern string Note_13                         = "False means fix Bars are calculated";
extern bool   show_only_visible_candle        = false;                           
extern string Note_14                         = "only necessary if -> false";
extern int    Fix_Volume_Bars                 = 2000;                       
extern color  color1                          = Tomato;                          // small candle
extern color  color2                          = DodgerBlue;                      // small candle
extern color  color3                          = Tomato;                          // mid candle
extern color  color4                          = DodgerBlue;                      // mid candle
extern color  color5                          = Tomato;                          // big candle
extern color  color6                          = DodgerBlue;                      // big candle
extern color  color7                          = Tomato;                          // fat candle
extern color  color8                          = DodgerBlue;                      // fat candle



string symbol, tChartPeriod,  tShortName, TAG, tObjName06, tAlert, short_name ;  



int    digits, period, digits2,win  ;

color colorVolume;

//global buffers and variables 
bool   FLAG_deinit;

//Deinit Section
int    obj_total,k;
string name, item1;

double vol_pro[3000];
double haOpen[3000];
double haClose[3000];

double VolBufferH1[3000];
double VolBufferH2[3000];
double VolBufferH3[3000];
double VolBufferH4[3000];
double VolBufferH5[3000];

int    breite_II = 2;
int    breite_III = 3;
int    breite_IV = 4;
int    breite_V = 5;

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];

double        avg,VolPriceSpread,temp_VolPriceSpread,temp_High_VolPriceSpread;

//+-------------------------------------------------------------------------------------------+
//| Indicator Initialization                                                                  |                                                        
//+-------------------------------------------------------------------------------------------+   
int init()
   {
   FLAG_deinit = false;
  
   SetIndexStyle(0,DRAW_HISTOGRAM, 0);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM, 0);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM, 0);
   SetIndexBuffer(2, ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM, 0);
   SetIndexBuffer(3, ExtMapBuffer4);
   SetIndexStyle(4,DRAW_HISTOGRAM, 0);
   SetIndexBuffer(4, ExtMapBuffer5);
   SetIndexStyle(5,DRAW_HISTOGRAM, 0);
   SetIndexBuffer(5, ExtMapBuffer6);
   SetIndexStyle(6,DRAW_HISTOGRAM, 0);
   SetIndexBuffer(6, ExtMapBuffer7);
   SetIndexStyle(7,DRAW_HISTOGRAM, 0);
   SetIndexBuffer(7, ExtMapBuffer8);
   
   SetIndexDrawBegin(0,10);
   SetIndexDrawBegin(1,10);
   SetIndexDrawBegin(2,10);
   SetIndexDrawBegin(3,10);
   SetIndexDrawBegin(4,10);
   SetIndexDrawBegin(5,10);
   SetIndexDrawBegin(6,10);
   SetIndexDrawBegin(7,10); 

   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexBuffer(6,ExtMapBuffer7);
   SetIndexBuffer(7,ExtMapBuffer8);
   
   //Comment ("Price Type: ",PriceType," - Volume Type: ",Volume_Type," - Candle Design: ",Candle_Design," - candlevolume 0.92 beta (c) by enigma4x");

       
   return(0);
   }
  
//+-------------------------------------------------------------------------------------------+
//| Indicator De-initialization                                                               |                                                        
//+-------------------------------------------------------------------------------------------+ 
int deinit()
   {   
   obj_total= ObjectsTotal();  
   for (k= obj_total; k>=0; k--)
      {
      name= ObjectName(k); 
      if (StringSubstr(name,0,14)=="[CandleVolume]"){ObjectDelete(name);}         
      }
   ObjectDelete("CandleVolume_Msg");
   ObjectDelete("Label");
 
   return(0);   
  }
  
//+-------------------------------------------------------------------------------------------+
//| Indicator Start                                                                           |                                                        
//+-------------------------------------------------------------------------------------------+ 
int start()
   {
   //If indicator is "Off" deinitialize only once, not every tick.  
   if (!Indicator_On)    
      {
      if (!FLAG_deinit) {deinit(); FLAG_deinit = true;}
      return(0);
      }
   
   //Otherwise indicator is "On", so proceed.   
   deinit(); FLAG_deinit = false;
     
   if(show_only_visible_candle==false)
      {
      //Calculate Fix Bars
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return(-1);
      if (counted_bars > 0) counted_bars--;
      int limit = Bars - counted_bars;
      if (counted_bars > 0) limit++;
      int i=Fix_Volume_Bars;
      }
      
   else if(show_only_visible_candle)
      {
      //Calculate Visible Bars
      counted_bars = BarsPerWindow() + 1;
      int first_bar = FirstVisibleBar();
      int last_bar = first_bar - counted_bars + 1;
      if ( last_bar< 0 ) 
         {
         last_bar = 0;
         counted_bars = first_bar + 10;
         }
      i=counted_bars;
      }
      
   //goto subroutine  
   init_NVO_vol_buffer();  
   
  
    
   while (i>=0)
      {
      
      //Next two lines involve branching to three subroutines to 
      //find price, find volume, and draw the candles 
      draw_candle(Candle_Design,i,find_price(PriceType,i,"Open"),
      find_price(PriceType,i,"Close"), find_price(PriceType,i,"Low"),
      find_price(PriceType,i,"High"),find_volume(Volume_Type,i));
      i--;
      }
   Draw_CandleVolume_Messege(); 
   return(0);
   }
   
//+-------------------------------------------------------------------------------------------+
//| Subroutine To Find Price                                                                  |
//+-------------------------------------------------------------------------------------------+ 
double find_price(int PTpye,int i,string Price)
{
   if (PTpye==1)
   {
      if(Price=="Open")return(iOpen(0,0,i)); 
      if(Price=="Close")return(iClose(0,0,i)); 
      if(Price=="Low")return(iLow(0,0,i)); 
      return(iHigh(0,0,i)); 
   } 

   haOpen[i]=(haOpen[i+1]+haClose[i+1])/2;
   haClose[i]=(Open[i]+High[i]+Low[i]+Close[i])/4;
   
   if(Price=="Open")return(haOpen[i]); 
   if(Price=="Close")return(haClose[i]); 
   if(Price=="Low")return(iLow(0,0,i)); 
   
   return(iHigh(0,0,i)); 
} 

//+-------------------------------------------------------------------------------------------+
//| Subroutine To Find Volume                                                                 |
//+-------------------------------------------------------------------------------------------+ 
int find_volume(int VolType,int i_II)
{  
   if (VolType==1) 
   {  
      return(find_NVO_vol(VolType,i_II));     
   }
   
    if (VolType==2)
   {  
      return(find_NVO_vol(VolType,i_II));      
   }
  
    if (VolType==3)
   {  
      return(find_high_low_vol(i_II));      
   }  
   return(find_sonic_r_vsa(i_II));      
}

//+-------------------------------------------------------------------------------------------+
//| Subroutine To calculate NVO and Sonic R Volume                                                                 |
//+-------------------------------------------------------------------------------------------+ 
int find_NVO_vol(int VolType,int i)
   {
   double nvo = 0;
   
   //goto subroutine
   double x=find_NVO_x();  
   
   VolBufferH1[i] = 0;
   VolBufferH2[i] = 0;
   VolBufferH3[i] = 0;
   VolBufferH4[i] = 0;
   VolBufferH5[i] = 0;
   
   //goto subroutine   
   nvo = NormalizedVolume(i)*100 - 100;  
   
   
   if (nvo < 0)
      {
      VolBufferH1[i] = nvo*x;
      return(1);
      }
    else
      {  
      if (nvo < 38.2)
         {
         VolBufferH2[i] = nvo*x;
         if (VolType==1) {return(3);}
         else {return(5);}
         }
      else
         {
         if (nvo < 61.8)
            {
            VolBufferH3[i] = nvo*x;
            if (VolType==1) {return(5);}
            else {return(5);}
            }
         else
            {
            if (nvo < 100)
               {
               VolBufferH4[i] = nvo*x;
               if (VolType==1) {return(7);}
               else {return(5);}
               }
            else 
               {
               VolBufferH5[i] = nvo*x;
               if (VolType==1) {return(9);}
               else {return(9);}
               }
            }
         }
      }
   }   

//+-------------------------------------------------------------------------------------------+
//| Subroutine To Draw Candles                                                                |
//+-------------------------------------------------------------------------------------------+ 
 
int find_high_low_vol(int i)
{
   if (iVolume(0,0,i) > iVolume(0,0,i+1))
   {
      return(9);
   }
   return(3);
}
   
//+-------------------------------------------------------------------------------------------+
//| Subroutine To Sonic_R_VSA                                                                 |
//+-------------------------------------------------------------------------------------------+ 

int find_sonic_r_vsa(int i)
{
   VolPriceSpread             = 0;
   temp_High_VolPriceSpread   = 0;
   temp_VolPriceSpread        = 0;
   avg = 0; 
         
   //Compute Average Volume 
   int j = i; 
   avg = find_Avg_Volume(i,j)/Volume_Avg_Period_Sonic_R_VSA; 
      
   //Calculations Volumen with Pricespread  
   VolPriceSpread = Volume[i]*((High[i]-Low[i]));
   int n=i;
   
   if(VolPriceSpread == find_Hi_VolPriceSpread(n,i,temp_VolPriceSpread,temp_High_VolPriceSpread ))
   { 
      //Climax possible Up                                  
      if (Close[i] > Open[i]) 
      {
         return(9);
      }
         //Climax possible Dn  
      else if (Close[i] <= Open[i]) 
      {
         return(9);
      }
   } 
   return(5); 
}
//+-------------------------------------------------------------------------------------------+
//| Subroutine To Draw Candles                                                                |
//+-------------------------------------------------------------------------------------------+ 

void draw_candle (int local_Candle_Design,int i,double Bar_Open,double Bar_Close,double Bar_Low,double Bar_High,int Candle_Width)
   {
   if(  local_Candle_Design==1 ||  local_Candle_Design==3)
      {     
      item1= StringConcatenate("[CandleVolume] ",Copyright," ",TimeToStr(Time[i],TIME_DATE|TIME_MINUTES));
      ObjectDelete(item1);
      ObjectCreate(item1, OBJ_TREND,0,Time[i],Bar_Low,Time[i],Bar_High,0,0);
      ObjectSet   (item1, OBJPROP_WIDTH, 1);
      
      if (Bar_Open>Bar_Close) ObjectSet   (item1, OBJPROP_COLOR, color1);  
      else ObjectSet   (item1, OBJPROP_COLOR, color2);  
      ObjectSet   (item1, OBJPROP_RAY,   false);
      if(  local_Candle_Design==1)
         {
            item1=StringConcatenate(item1," Body");
            ObjectDelete(item1);
            ObjectCreate(item1, OBJ_TREND,0,Time[i],Bar_Open,Time[i],Bar_Close,0,0);
            ObjectSet   (item1, OBJPROP_WIDTH, Candle_Width);
      
            if (Bar_Open>Bar_Close) ObjectSet   (item1, OBJPROP_COLOR, color1);  
            else ObjectSet   (item1, OBJPROP_COLOR, color2);  
            ObjectSet   (item1, OBJPROP_RAY,   false);
         }
      }
      
   if(  local_Candle_Design==2 ||   local_Candle_Design==3)
      {     
      ExtMapBuffer1[i]=EMPTY_VALUE;
      ExtMapBuffer2[i]=EMPTY_VALUE;
      ExtMapBuffer3[i]=EMPTY_VALUE;
      ExtMapBuffer4[i]=EMPTY_VALUE;
      ExtMapBuffer5[i]=EMPTY_VALUE;
      ExtMapBuffer6[i]=EMPTY_VALUE;
      ExtMapBuffer7[i]=EMPTY_VALUE;
      ExtMapBuffer8[i]=EMPTY_VALUE;
        
      if (Candle_Width==3)
         {
         ExtMapBuffer1[i]=Bar_Open;
         ExtMapBuffer2[i]=Bar_Close;
         }
      if (Candle_Width==5)
         {
         ExtMapBuffer3[i]=Bar_Open;
         ExtMapBuffer4[i]=Bar_Close;
         }
      if (Candle_Width==7)
         {
         ExtMapBuffer5[i]=Bar_Open;
         ExtMapBuffer6[i]=Bar_Close;
         }
      if (Candle_Width==9)
         {
         ExtMapBuffer7[i]=Bar_Open;
         ExtMapBuffer8[i]=Bar_Close;
         }     
      }
         
   } 

//+-------------------------------------------------------------------------------------------+
//| Subroutine to compute NVO_x()                                                             |
//+-------------------------------------------------------------------------------------------+ 
double  find_NVO_x()
{
   if (Period() == 1) return(0.25);
   else if (Period() == 5) return(1);
   else if (Period() == 15) return(5);
   else if (Period() == 30) return(10);
   else if (Period() == 60) return(20);
   else if (Period() == 240) return(40);
   else if (Period() == 1440) return(180);
   else if (Period() == 10080) return(2000);
   
   return(4020); 
}

//+-------------------------------------------------------------------------------------------+
//| Subroutine To Initiate NVO Volume Buffers                                                 |
//+-------------------------------------------------------------------------------------------+ 
void init_NVO_vol_buffer() 
   {
   ArrayResize(VolBufferH1,Bars);
   ArrayResize(VolBufferH2,Bars);
   ArrayResize(VolBufferH3,Bars);
   ArrayResize(VolBufferH4,Bars);
   ArrayResize(VolBufferH5,Bars);
 
   int i = 1;
 
   while(i<=Volume_Period_NVO_Sonic_R)
      {
      VolBufferH1[Bars-i] = 0;
      VolBufferH2[Bars-i] = 0;
      VolBufferH3[Bars-i] = 0;
      VolBufferH4[Bars-i] = 0;
      VolBufferH5[Bars-i] = 0;
      i++;
      }
   }

//+-------------------------------------------------------------------------------------------+
//| Subroutine to Compute Normalized Volume                                                   |
//+-------------------------------------------------------------------------------------------+ 
double NormalizedVolume(int i)
{
   double nv = 0;
   for (int j = i; j < (i+Volume_Period_NVO_Sonic_R); j++)
   {
      nv = nv + Volume[j];
   }
   nv = nv / Volume_Period_NVO_Sonic_R;
   return nv == 0 ? 0 : (Volume[i] / nv);
}
//+-------------------------------------------------------------------------------------------+
//| Subroutine to Compute Average Volume                                                   |
//+-------------------------------------------------------------------------------------------+ 
double find_Avg_Volume(int i,int j)
   {
   while (j < (i+Volume_Avg_Period_Sonic_R_VSA))
      { 
      avg = avg + Volume[j];       
      j++;
      } 
   return (avg);
   }
//+-------------------------------------------------------------------------------------------+
//| Subroutine to Find High VolPriceFactor                                                    |
//+-------------------------------------------------------------------------------------------+ 
double find_Hi_VolPriceSpread(int n,int i,double local_temp_VolPriceSpread,double local_temp_High_VolPriceSpread)
   {
    while(n<i+Volume_Analy_GoBack_Sonic_R_VSA)
      { 
      local_temp_VolPriceSpread = Volume[n]*((High[n]-Low[n])); 
      if (local_temp_VolPriceSpread >= local_temp_High_VolPriceSpread) {local_temp_High_VolPriceSpread = local_temp_VolPriceSpread;}  
      n++;
      }
   return (local_temp_High_VolPriceSpread);
   }
//+-------------------------------------------------------------------------------------------+
//| Subroutine to Show Message                                                                |
//+-------------------------------------------------------------------------------------------+   
void Draw_CandleVolume_Messege()
{   
   
   string Messege_Text = "PriceType: ";   
   Messege_Text = Messege_Text + PriceType ;
   Messege_Text = Messege_Text + " - Volume Type: ";
   Messege_Text = Messege_Text + Volume_Type;
   Messege_Text = Messege_Text + " - Candle Design: ";
   Messege_Text = Messege_Text + Candle_Design;
   
   
   string ObjName01    = "CandleVolume_Msg"  ;  
   ObjectCreate(ObjName01, OBJ_LABEL, 0, 0, 0);//HiLow LABEL
   ObjectSetText(ObjName01, Messege_Text , 8 ,  "Arial",  DimGray );
   ObjectSet(ObjName01, OBJPROP_CORNER, 3);
   ObjectSet(ObjName01, OBJPROP_XDISTANCE, 235 );
   ObjectSet(ObjName01, OBJPROP_YDISTANCE, 5 ); 
   
   
   string Label = "- Candlevolume Indi 0.93 beta (c) by enigma4x";   
   
   string ObjName02    = "Label";  
   ObjectCreate(ObjName02, OBJ_LABEL, 0, 0, 0);//HiLow LABEL
   ObjectSetText(ObjName02, Label , 8 ,  "Arial",  DimGray );
   ObjectSet(ObjName02, OBJPROP_CORNER, 3);
   ObjectSet(ObjName02, OBJPROP_XDISTANCE, 10 );
   ObjectSet(ObjName02, OBJPROP_YDISTANCE, 5 );  
}  
//+-------------------------------------------------------------------------------------------+
//| Indicator End                                                                             |                                                        
//+-------------------------------------------------------------------------------------------+    


