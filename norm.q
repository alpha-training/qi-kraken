\d .kraken

norm.ticker:{
    d:@[x;`symbol;`$];
        (d`symbol;
            d`bid;
            d`bid_qty;
            d`ask;
            d`ask_qty;
            d`last;
            d`volume;
            d`vwap;
            d`low;
            d`high;
            d`change;
            d`change_pct)
    }

norm.ohlc:{
    d:@[x;`symbol;`$];
    d[`timestamp]:"P"$-1_'d[`timestamp];
    d[`interval_begin]:"P"$-1_'d[`interval_begin];
        (d`timestamp;
                d`symbol;
                d`open;
                d`high;
                d`low;
                d`close;
                d`trades;
                d`volume;
                d`vwap;
                d`interval_begin;
                d`interval)
    }