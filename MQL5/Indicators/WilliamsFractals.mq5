//+------------------------------------------------------------------+
//|                                             WilliamsFractals.mq5 |
//|                                         Copyright 2024, rpanchyk |
//|                                      https://github.com/rpanchyk |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2024, rpanchyk"
#property link        "https://github.com/rpanchyk"
#property version     "1.01"
#property description "Indicator shows Williams fractals"

#property indicator_chart_window
#property indicator_plots 2
#property indicator_buffers 2

// types
enum ENUM_ARROW_SIZE
  {
   SMALL_ARROW_SIZE = 1, // Small
   REGULAR_ARROW_SIZE = 2, // Regular
   BIG_ARROW_SIZE = 3, // Big
   HUGE_ARROW_SIZE = 4 // Huge
  };

// buffers
double ExtHigherHighBuffer[];
double ExtLowerLowBuffer[];

// config
input group "Section :: Main";
input bool InpDebugEnabled = false; // Enable debug (verbose logging)
input int InpPeriod = 10; // Period

input group "Section :: Style";
input int InpArrowShift = 10; // Arrow shift
input ENUM_ARROW_SIZE InpArrowSize = SMALL_ARROW_SIZE; // Arrow size
input color InpHigherHighColor = clrGreen; // Higher high color
input color InpLowerLowColor = clrRed; // Lower low color

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDebugEnabled)
     {
      Print("WilliamsFractals indicator initialization started");
     }

   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   ArraySetAsSeries(ExtHigherHighBuffer, true);
   ArrayInitialize(ExtHigherHighBuffer, 0);

   SetIndexBuffer(0, ExtHigherHighBuffer, INDICATOR_DATA);
   PlotIndexSetString(0, PLOT_LABEL, "Higher High");
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, 217);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -InpArrowShift);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpHigherHighColor);

   ArraySetAsSeries(ExtLowerLowBuffer, true);
   ArrayInitialize(ExtLowerLowBuffer, 0);

   SetIndexBuffer(1, ExtLowerLowBuffer, INDICATOR_DATA);
   PlotIndexSetString(1, PLOT_LABEL, "Lower Low");
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_ARROW, 218);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, InpArrowShift);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpLowerLowColor);

   if(InpDebugEnabled)
     {
      Print("WilliamsFractals indicator initialization finished");
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(InpDebugEnabled)
     {
      Print("WilliamsFractals indicator deinitialization started");
     }

   ArrayFill(ExtHigherHighBuffer, 0, ArraySize(ExtHigherHighBuffer), 0);
   ArrayFill(ExtLowerLowBuffer, 0, ArraySize(ExtLowerLowBuffer), 0);

   if(InpDebugEnabled)
     {
      Print("WilliamsFractals indicator deinitialization finished");
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   if(rates_total == prev_calculated || rates_total < InpPeriod || IsStopped())
     {
      return rates_total;
     }
   int gap = rates_total - prev_calculated;
   int startIndex = 1 + InpPeriod;
   int endIndex = gap > InpPeriod ? gap - startIndex : gap + startIndex;
   if(InpDebugEnabled)
     {
      PrintFormat("RatesTotal: %i, PrevCalculated: %i, StartIndex: %i, EndIndex: %i", rates_total, prev_calculated, startIndex, endIndex);
     }

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   for(int i = startIndex; i < endIndex; i++)
     {
      bool isHigherHigh = true;
      bool isLowerLow = true;

      for(int j = i - InpPeriod; j < i; j++) // go from left to current bar
        {
         isHigherHigh = isHigherHigh && high[i] > high[j];
         isLowerLow = isLowerLow && low[i] < low[j];
         if(!isHigherHigh && !isLowerLow)
           {
            break;
           }
        }

      for(int j = i + 1; j < i + 1 + InpPeriod; j++) // go from current to right bar
        {
         isHigherHigh = isHigherHigh && high[i] >= high[j];
         isLowerLow = isLowerLow && low[i] <= low[j];
         if(!isHigherHigh && !isLowerLow)
           {
            break;
           }
        }

      if(isHigherHigh)
        {
         ExtHigherHighBuffer[i] = high[i];
         if(InpDebugEnabled)
           {
            PrintFormat("Higher High found on %f at %s", ExtHigherHighBuffer[i], TimeToString(time[i]));
           }
        }
      else
        {
         ExtHigherHighBuffer[i] = 0;
        }

      if(isLowerLow)
        {
         ExtLowerLowBuffer[i] = low[i];
         if(InpDebugEnabled)
           {
            PrintFormat("Lower Low found on %f at %s", ExtLowerLowBuffer[i], TimeToString(time[i]));
           }
        }
      else
        {
         ExtLowerLowBuffer[i] = 0;
        }
     }

   return rates_total;
  }
//+------------------------------------------------------------------+
