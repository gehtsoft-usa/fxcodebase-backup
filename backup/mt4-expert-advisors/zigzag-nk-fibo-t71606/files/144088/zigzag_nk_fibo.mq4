// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71606

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
// Declaration of  variable
extern int ExtDepth=12;
extern int ExtDeviation=5;
extern int ExtBackstep =3;
//---- Fibo features at the last high
//extern bool DynamicFiboFlag=true;                          // DynamicFibo display flag 
extern color DynamicFibo_color=Blue;                       // DynamicFibo color
extern ENUM_LINE_STYLE DynamicFibo_style=STYLE_DASHDOTDOT; // DynamicFibo style
extern int DynamicFibo_width=1;                            // DynamicFibo line width
extern bool DynamicFibo_AsRay=true;                        // DynamicFibo ray
//---- Fibo features at the second to last high
//extern bool StaticFiboFlag=true;                           // StaticFibo display flag
extern color StaticFibo_color=Red;                         // StaticFibo color
extern ENUM_LINE_STYLE StaticFibo_style=STYLE_DASH;        // StaticFibo style
extern int StaticFibo_width=1;                             // StaticFibo line width
extern bool StaticFibo_AsRay=false; 


int count_recent_three_value  = 0;
double  zigMapping[]  =  { 0 , 0 ,0 , 0};
datetime    zigMappingTime[]  =  { 0 , 0 , 0 , 0};  
extern  bool  previous_fibo    =  false; // Off Previous Fibo

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping


    count_recent_three_value = 0;
   fx_handling_zigzag_initialization();
   fx_mapping_zigzag_fib();
   if (  previous_fibo   == true){
     ObjectDelete("FIBONACCI_2");
   }



//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int  start ( )  {
  count_recent_three_value = 0;
   fx_handling_zigzag_initialization();
   fx_mapping_zigzag_fib();



return  0 ; 








}


int  fx_mapping_zigzag_fib(){

for  (   int  i  =   0  ;  i<  ArraySize(zigMapping ) ;  i ++){





  if(  zigMapping[0] <  zigMapping[1]){

fx_draw_fibonacci( 0 , "FIBONACCI_", zigMappingTime[1],zigMapping[1],  zigMappingTime[0],  zigMapping[0] ,DynamicFibo_color, DynamicFibo_style, DynamicFibo_width  , "" );

  }

    if(  zigMapping[0] >  zigMapping[1]){


 fx_draw_fibonacci( 0 , "FIBONACCI_", zigMappingTime[0],zigMapping[0],  zigMappingTime[1],  zigMapping[1] ,StaticFibo_color, StaticFibo_style, StaticFibo_width  , "" );

 

   }


if  ( previous_fibo   == false ){
   if(  zigMapping[1] >  zigMapping[2]){
    // Testing   Zigzag  mapping 
    fx_draw_fibonacci( 0 , "FIBONACCI_2", zigMappingTime[2],zigMapping[2],  zigMappingTime[1],  zigMapping[1],StaticFibo_color, StaticFibo_style, StaticFibo_width  , "" );

  }

   if(  zigMapping[1] <  zigMapping[2]){
     fx_draw_fibonacci( 0 , "FIBONACCI_2",zigMappingTime[1],zigMapping[1],  zigMappingTime[2],  zigMapping[2],DynamicFibo_color, DynamicFibo_style, DynamicFibo_width  , "" );


  }



}
  
 








}

  return   0 ;
}


int  fx_draw_fibonacci( int chart_index, string name   , datetime   time1 , double  value1  , datetime time2 ,double  value2  , color color_value , int  style, int width , string  text){

        ObjectDelete(name);
   ObjectCreate(name , OBJ_FIBO,  chart_index, time1,value1,  time2, value2);
ObjectSetInteger(0, name, OBJPROP_RAY, false);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
    ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, false);
ObjectSet(name, OBJPROP_LEVELCOLOR, color_value);
ObjectSetInteger(0,name,OBJPROP_STYLE,style);
for(int numb=0; numb<10; numb++)
     {
      // ObjectSetInteger(chart_id,name,OBJPROP_LEVELCOLOR,numb,Color);
      ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,numb,style);
      ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,numb,width);
      // ObjectSetInteger(chart_id,name,OBJPROP_LEVELWIDTH,numb,width);
     }

return 0;

}

int  fx_handling_zigzag_initialization(){
// Bars
for (   int   i  = 0  ;   i <  Bars       ;  i ++){

  double  zigZagValue = iCustom(NULL, PERIOD_CURRENT, "ZigZag", ExtDepth, ExtDeviation, ExtBackstep, 0, i);

   if  (  count_recent_three_value   ==  0  &&   zigZagValue  !=0.0   ){
        count_recent_three_value   = count_recent_three_value  +1 ;
        
        zigMapping[0] =  zigZagValue;
        zigMappingTime[0]   =   Time[i]; 
      
       
   }
   else  if  (   count_recent_three_value   == 1   &&   zigZagValue    !=  0.0 ) {
        count_recent_three_value   = count_recent_three_value  +1 ;
        zigMapping[1] =  zigZagValue;
          zigMappingTime[1]   =   Time[i]; 

   }

   else  if (  count_recent_three_value  == 2   &&    zigZagValue   !=   0.0){
count_recent_three_value   = count_recent_three_value  +1 ;
        zigMapping[2] = zigZagValue;
          zigMappingTime[2]   =   Time[i]; 

   }
   else  if (  count_recent_three_value  == 3   &&   zigZagValue   !=   0.0){
count_recent_three_value   = count_recent_three_value  +1 ;
        zigMapping[3] = zigZagValue;
          zigMappingTime[3]   =   Time[i]; 
   break;
        

   }
  

}

  return  0  ;  
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
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+




void deinit() {

  fx_deinitialization();


}



int fx_deinitialization(){
 ObjectDelete("FIBONACCI_");
 ObjectDelete("FIBONACCI_2");

return  0;
}