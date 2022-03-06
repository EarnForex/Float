//+------------------------------------------------------------+
//| Float.mq4                                                  |
//| Copyright © 2005  Barry Stander  Barry_Stander_4@yahoo.com |
//| http://www.4Africa.net/4meta/                              |
//| Float                                                      |
//| Copyright © 2020-2022  Andriy Moraru  www.EarnForex.com    |
//| https://www.earnforex.com/                                 |
//+------------------------------------------------------------+
#property copyright "Copyright © 2009-2022, EarnForex"
#property link      "https://www.earnforex.com/metatrader-indicators/Float/"
#property version   "1.01"
#property strict

#property description "Float - Trend strength, volume, Fibonacci and Dinapoli levels."

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 clrBlue
#property indicator_width1 1
#property indicator_label1 "Float Histogram"
#property indicator_color2 clrRed
#property indicator_width2 1
#property indicator_style2 STYLE_SOLID
#property indicator_label2 "Float Line"

input int    Float = 200;
input string ObjectPrefix = "FI-";
input bool   DisableDinapoli = false;
input bool   DisableFibonacci = false;
input bool   DrawVerticalLinesAsBackground = false;

int prevbars;
double Histogram[];
double Line[];

void OnInit()
{
    IndicatorShortName("Float");

    SetIndexStyle(0, DRAW_HISTOGRAM);
    SetIndexBuffer(0, Histogram);
    SetIndexDrawBegin(0, Float * 2);

    SetIndexStyle(1, DRAW_LINE);
    SetIndexBuffer(1, Line);
    SetIndexDrawBegin(1, Float * 2);
}

void OnDeinit(const int reason)
{
    ObjectsDeleteAll(ChartID(), ObjectPrefix);
    Comment("");
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time_timeseries[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]
               )
{
    if (Bars - prevbars < 1) return rates_total; // Do not recalculate yet.
    prevbars = Bars;
    
    bool first = true;
    long cumulativeV = 0;
    double FLOATV = 0, high_bar = 0, low_bar = 0;
    int bars_high = 0, bars_low = 0, shift, swing_time = 0, cvstart = 0, cvend = 0;

    int loopbegin = Bars - Float;
    for (shift = loopbegin; shift >= 0; shift--)
    {
        // Find bar counts.
        bars_high = iHighest(NULL, 0, MODE_HIGH, Float, 1);
        bars_low  = iLowest(NULL, 0, MODE_LOW, Float, 1);

        // Find the high and low values over the period.
        high_bar = High[bars_high];
        low_bar  =  Low[bars_low];

        // Find cumulative volume for float period.
        if (bars_high < bars_low) // Uptrend.
        {
            cvstart = bars_low;
            cvend = bars_high;
        }
        else // Downtrend.
        {
            cvstart = bars_high;
            cvend = bars_low;
        }

        if ((first) && (FLOATV == 0))
        {
            for (shift = cvstart; shift >= cvend; shift--)
            {
                FLOATV = FLOATV + Volume[shift];
                first = false;
            }
        }
    }

    // Find float time barcount.
    swing_time = MathAbs(bars_low - bars_high);

    // Find cumulative volume since last turnover.
    for (shift = cvstart; shift >= 0; shift--)
    {
        cumulativeV += Volume[shift];

        if (cumulativeV >= FLOATV) cumulativeV = 0;

        Histogram[shift] = cumulativeV * 0.001; // Blue histogram.
        Line[shift] = FLOATV * 0.001; // Red line.
    }

    Comment(
        "\n", "High was   ", bars_high, "  bars ago",
        "\n", "Low was    ", bars_low, " bars ago", "\n",
        "\n", "Float time was    = ", swing_time, " bars",
        "\n", "Float volume left = ", FLOATV - cumulativeV,
        "\n", "Float volume      = ", FLOATV);

    ObjectDelete(ObjectPrefix + "Swingtop");
    ObjectCreate(ObjectPrefix + "Swingtop", OBJ_TREND, 0, Time[cvstart], high_bar, Time[1], high_bar);
    ObjectSet(ObjectPrefix + "Swingtop", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet(ObjectPrefix + "Swingtop", OBJPROP_COLOR, clrBlue);
    ObjectSet(ObjectPrefix + "Swingtop", OBJPROP_RAY, 0);
    ObjectSet(ObjectPrefix + "Swingtop", OBJPROP_WIDTH, 1);

    ObjectDelete(ObjectPrefix + "Swingbottom");
    ObjectCreate(ObjectPrefix + "Swingbottom", OBJ_TREND, 0, Time[cvstart], low_bar, Time[1], low_bar);
    ObjectSet(ObjectPrefix + "Swingbottom", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet(ObjectPrefix + "Swingbottom", OBJPROP_COLOR, clrBlue);
    ObjectSet(ObjectPrefix + "Swingbottom", OBJPROP_RAY, 0);
    ObjectSet(ObjectPrefix + "Swingbottom", OBJPROP_WIDTH, 1);

    if ((!DisableDinapoli) || (!DisableFibonacci))
    {
        // Fibonacci.
        ObjectDelete(ObjectPrefix + "Fib23");
        ObjectDelete(ObjectPrefix + "Fib38");
        ObjectDelete(ObjectPrefix + "Fib50");
        ObjectDelete(ObjectPrefix + "Fib62");
        ObjectDelete(ObjectPrefix + "Fib76");
        ObjectDelete(ObjectPrefix + "Fib23t");
        ObjectDelete(ObjectPrefix + "Fib38t");
        ObjectDelete(ObjectPrefix + "Fib50t");
        ObjectDelete(ObjectPrefix + "Fib62t");
        ObjectDelete(ObjectPrefix + "Fib76t");

        ObjectDelete(ObjectPrefix + "Dinap0");
        ObjectDelete(ObjectPrefix + "Dinap1");
        ObjectDelete(ObjectPrefix + "Dinap2");
        ObjectDelete(ObjectPrefix + "Dinap3");
        ObjectDelete(ObjectPrefix + "Dinap4");
        ObjectDelete(ObjectPrefix + "Dinap5");

        double Fib23 = ((high_bar - low_bar) * 0.236) + low_bar;
        double Fib38 = ((high_bar - low_bar) * 0.382) + low_bar;
        double Fib50 = ((high_bar - low_bar) / 2) + low_bar;
        double Fib62 = ((high_bar - low_bar) * 0.618) + low_bar;
        double Fib76 = ((high_bar - low_bar) * 0.764) + low_bar;

        if (!DisableFibonacci)
        {
            ObjectCreate(ObjectPrefix + "Fib23", OBJ_TREND, 0, Time[cvstart], Fib23, Time[1], Fib23);
            ObjectSet(ObjectPrefix + "Fib23", OBJPROP_STYLE, STYLE_DASH);
            ObjectSet(ObjectPrefix + "Fib23", OBJPROP_COLOR, clrGreen);
            ObjectSet(ObjectPrefix + "Fib23", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Fib23", OBJPROP_WIDTH, 1);
            ObjectCreate(ObjectPrefix + "Fib23t", OBJ_TEXT, 0, Time[1], Fib23);
            ObjectSetText(ObjectPrefix + "Fib23t", "23.6", 8, "Arial", clrGreen);

            ObjectCreate(ObjectPrefix + "Fib38", OBJ_TREND, 0, Time[cvstart], Fib38, Time[1], Fib38);
            ObjectSet(ObjectPrefix + "Fib38", OBJPROP_STYLE, STYLE_DASH);
            ObjectSet(ObjectPrefix + "Fib38", OBJPROP_COLOR, clrGreen);
            ObjectSet(ObjectPrefix + "Fib38", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Fib38", OBJPROP_WIDTH, 1);
            ObjectCreate(ObjectPrefix + "Fib38t", OBJ_TEXT, 0, Time[1], Fib38);
            ObjectSetText(ObjectPrefix + "Fib38t", "38.2", 8, "Arial", clrGreen);

            ObjectCreate(ObjectPrefix + "Fib50", OBJ_TREND, 0, Time[cvstart], Fib50, Time[1], Fib50);
            ObjectSet(ObjectPrefix + "Fib50", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet(ObjectPrefix + "Fib50", OBJPROP_COLOR, clrRed);
            ObjectSet(ObjectPrefix + "Fib50", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Fib50", OBJPROP_WIDTH, 2);
            ObjectCreate(ObjectPrefix + "Fib50t", OBJ_TEXT, 0, Time[1], Fib50);
            ObjectSetText(ObjectPrefix + "Fib50t", "50", 8, "Arial", clrGreen);

            ObjectCreate(ObjectPrefix + "Fib62", OBJ_TREND, 0, Time[cvstart], Fib62, Time[1], Fib62);
            ObjectSet(ObjectPrefix + "Fib62", OBJPROP_STYLE, STYLE_DASH);
            ObjectSet(ObjectPrefix + "Fib62", OBJPROP_COLOR, clrGreen);
            ObjectSet(ObjectPrefix + "Fib62", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Fib62", OBJPROP_WIDTH, 1);
            ObjectCreate(ObjectPrefix + "Fib62t", OBJ_TEXT, 0, Time[1], Fib62);
            ObjectSetText(ObjectPrefix + "Fib62t", "61.8", 8, "Arial", clrGreen);

            ObjectCreate(ObjectPrefix + "Fib76", OBJ_TREND, 0, Time[cvstart], Fib76, Time[1], Fib76);
            ObjectSet(ObjectPrefix + "Fib76", OBJPROP_STYLE, STYLE_DASH);
            ObjectSet(ObjectPrefix + "Fib76", OBJPROP_COLOR, clrGreen);
            ObjectSet(ObjectPrefix + "Fib76", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Fib76", OBJPROP_WIDTH, 1);
            ObjectCreate(ObjectPrefix + "Fib76t", OBJ_TEXT, 0, Time[1], Fib76);
            ObjectSetText(ObjectPrefix + "Fib76t", "76.4", 8, "Arial", clrGreen);
        }

        // Dinapoli.
        if (!DisableDinapoli)
        {
            double Dinap0 = (low_bar + Fib23) / 2;
            double Dinap1 = (Fib23 + Fib38) / 2;
            double Dinap2 = (Fib38 + Fib50) / 2;
            double Dinap3 = (Fib50 + Fib62) / 2;
            double Dinap4 = (Fib62 + Fib76) / 2;
            double Dinap5 = (high_bar + Fib76) / 2;
            
            ObjectCreate(ObjectPrefix + "Dinap0", OBJ_TREND, 0, Time[cvstart], Dinap0, Time[1], Dinap0);
            ObjectSet(ObjectPrefix + "Dinap0", OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(ObjectPrefix + "Dinap0", OBJPROP_COLOR, clrRed);
            ObjectSet(ObjectPrefix + "Dinap0", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Dinap0", OBJPROP_WIDTH, 1);

            ObjectCreate(ObjectPrefix + "Dinap1", OBJ_TREND, 0, Time[cvstart], Dinap1, Time[1], Dinap1);
            ObjectSet(ObjectPrefix + "Dinap1", OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(ObjectPrefix + "Dinap1", OBJPROP_COLOR, clrRed);
            ObjectSet(ObjectPrefix + "Dinap1", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Dinap1", OBJPROP_WIDTH, 1);

            ObjectCreate(ObjectPrefix + "Dinap2", OBJ_TREND, 0, Time[cvstart], Dinap2, Time[1], Dinap2);
            ObjectSet(ObjectPrefix + "Dinap2", OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(ObjectPrefix + "Dinap2", OBJPROP_COLOR, clrRed);
            ObjectSet(ObjectPrefix + "Dinap2", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Dinap2", OBJPROP_WIDTH, 1);

            ObjectCreate(ObjectPrefix + "Dinap3", OBJ_TREND, 0, Time[cvstart], Dinap3, Time[1], Dinap3);
            ObjectSet(ObjectPrefix + "Dinap3", OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(ObjectPrefix + "Dinap3", OBJPROP_COLOR, clrRed);
            ObjectSet(ObjectPrefix + "Dinap3", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Dinap3", OBJPROP_WIDTH, 1);

            ObjectCreate(ObjectPrefix + "Dinap4", OBJ_TREND, 0, Time[cvstart], Dinap4, Time[1], Dinap4);
            ObjectSet(ObjectPrefix + "Dinap4", OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(ObjectPrefix + "Dinap4", OBJPROP_COLOR, clrRed);
            ObjectSet(ObjectPrefix + "Dinap4", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Dinap4", OBJPROP_WIDTH, 1);

            ObjectCreate(ObjectPrefix + "Dinap5", OBJ_TREND, 0, Time[cvstart], Dinap5, Time[1], Dinap5);
            ObjectSet(ObjectPrefix + "Dinap5", OBJPROP_STYLE, STYLE_DOT);
            ObjectSet(ObjectPrefix + "Dinap5", OBJPROP_COLOR, clrRed);
            ObjectSet(ObjectPrefix + "Dinap5", OBJPROP_RAY, 0);
            ObjectSet(ObjectPrefix + "Dinap5", OBJPROP_WIDTH, 1);
        }
    }

    // Vertical float lines. These draw the lines that calculate the float.
    // If you change "trendline" to "vertical line", it will draw through oscillators too. Might be fun.
    ObjectDelete(ObjectPrefix + "CVSTART");
    ObjectCreate(ObjectPrefix + "CVSTART", OBJ_TREND, 0, Time[cvstart], high_bar, Time[cvstart], low_bar * Point);
    ObjectSet(ObjectPrefix + "CVSTART", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet(ObjectPrefix + "CVSTART", OBJPROP_COLOR, clrBlue);
    ObjectSet(ObjectPrefix + "CVSTART", OBJPROP_RAY, 0);
    ObjectSet(ObjectPrefix + "CVSTART", OBJPROP_WIDTH, 1);
    ObjectSet(ObjectPrefix + "CVSTART", OBJPROP_BACK, DrawVerticalLinesAsBackground);

    ObjectDelete(ObjectPrefix + "CVEND");
    ObjectCreate(ObjectPrefix + "CVEND", OBJ_TREND, 0, Time[cvend], high_bar, Time[cvend], low_bar * Point);
    ObjectSet(ObjectPrefix + "CVEND", OBJPROP_STYLE, STYLE_SOLID);
    ObjectSet(ObjectPrefix + "CVEND", OBJPROP_COLOR, clrBlue);
    ObjectSet(ObjectPrefix + "CVEND", OBJPROP_RAY, 0);
    ObjectSet(ObjectPrefix + "CVEND", OBJPROP_WIDTH, 1);
    ObjectSet(ObjectPrefix + "CVEND", OBJPROP_BACK, DrawVerticalLinesAsBackground);

    // Vertical float predictions. These are time-based only.
    // See blue histogram for real float values.
    // If you change "trendline" to "vertical line", it will draw through oscillators too. Might be fun.
    
    ObjectDelete(ObjectPrefix + "Swingend");
    if (cvend - swing_time > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend", OBJ_TREND, 0, Time[(cvend - swing_time) + 5], high_bar, Time[cvend - swing_time + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(ObjectPrefix + "Swingend", OBJPROP_COLOR, clrRed);
        ObjectSet(ObjectPrefix + "Swingend", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend", OBJPROP_WIDTH, 1);
    }

    ObjectDelete(ObjectPrefix + "Swingend2");
    if (cvend - (swing_time * 2) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend2", OBJ_TREND, 0, Time[(cvend - (swing_time * 2)) + 5], high_bar, Time[cvend - (swing_time * 2) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend2", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(ObjectPrefix + "Swingend2", OBJPROP_COLOR, clrRed);
        ObjectSet(ObjectPrefix + "Swingend2", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend2", OBJPROP_WIDTH, 1);
    }
    
    ObjectDelete(ObjectPrefix + "Swingend3");
    if (cvend - (swing_time * 3) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend3", OBJ_TREND, 0, Time[(cvend - (swing_time * 3)) + 5], high_bar, Time[cvend - (swing_time * 3) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend3", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(ObjectPrefix + "Swingend3", OBJPROP_COLOR, clrRed);
        ObjectSet(ObjectPrefix + "Swingend3", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend3", OBJPROP_WIDTH, 1);
    }

    ObjectDelete(ObjectPrefix + "Swingend4");
    if (cvend - (swing_time * 4) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend4", OBJ_TREND, 0, Time[(cvend - (swing_time * 4)) + 5], high_bar, Time[cvend - (swing_time * 4) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend4", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(ObjectPrefix + "Swingend4", OBJPROP_COLOR, clrRed);
        ObjectSet(ObjectPrefix + "Swingend4", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend4", OBJPROP_WIDTH, 1);
    }

    ObjectDelete(ObjectPrefix + "Swingend5");
    if (cvend - (swing_time * 5) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend5", OBJ_TREND, 0, Time[(cvend - (swing_time * 5)) + 5], high_bar, Time[cvend - (swing_time * 5) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend5", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(ObjectPrefix + "Swingend5", OBJPROP_COLOR, clrRed);
        ObjectSet(ObjectPrefix + "Swingend5", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend5", OBJPROP_WIDTH, 1);
    }

    ObjectDelete(ObjectPrefix + "Swingend6");
    if (cvend - (swing_time * 6) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend6", OBJ_TREND, 0, Time[cvend - (swing_time * 6) + 5], high_bar, Time[cvend - (swing_time * 6) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend6", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(ObjectPrefix + "Swingend6", OBJPROP_COLOR, clrRed);
        ObjectSet(ObjectPrefix + "Swingend6", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend6", OBJPROP_WIDTH, 1);
    }

    ObjectDelete(ObjectPrefix + "Swingend7");
    if (cvend - (swing_time * 7) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend7", OBJ_TREND, 0, Time[cvend - (swing_time * 7) + 5], high_bar, Time[cvend - (swing_time * 7) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend7", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(ObjectPrefix + "Swingend7", OBJPROP_COLOR, clrRed);
        ObjectSet(ObjectPrefix + "Swingend7", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend7", OBJPROP_WIDTH, 1);
    }

    ObjectDelete(ObjectPrefix + "Swingend8");
    if (cvend - (swing_time * 8) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend8", OBJ_TREND, 0, Time[cvend - (swing_time * 8) + 5], high_bar, Time[cvend - (swing_time * 8) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend8", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(ObjectPrefix + "Swingend8", OBJPROP_COLOR, clrRed);
        ObjectSet(ObjectPrefix + "Swingend8", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend8", OBJPROP_WIDTH, 1);
    }

    ObjectDelete(ObjectPrefix + "Swingend9");
    if (cvend - (swing_time * 9) > 0)
    {
        ObjectCreate(ObjectPrefix + "Swingend9", OBJ_TREND, 0, Time[cvend - (swing_time * 9) + 5], high_bar, Time[cvend - (swing_time * 9) + 5], low_bar);
        ObjectSet(ObjectPrefix + "Swingend9", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet(ObjectPrefix + "Swingend9", OBJPROP_COLOR, clrRed);
        ObjectSet(ObjectPrefix + "Swingend9", OBJPROP_RAY, 0);
        ObjectSet(ObjectPrefix + "Swingend9", OBJPROP_WIDTH, 1);
    }

    return rates_total;
}
//+------------------------------------------------------------------+