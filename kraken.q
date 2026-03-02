\e 1
.qi.import`ipc
.qi.frompkg[`kraken;`norm]
.qi.frompkg[`proc;`feed]
.qi.loadschemas`kraken

\d .kraken

url:.conf.KRAKEN_URL
header:"GET ",.conf.KRAKEN_ENDPOINT," HTTP/1.1\r\nHost: ws.kraken.com\r\nConnection: Upgrade\r\nUpgrade: websocket\r\n\r\n"
UN:.conf.KRAKEN_UNIVERSE
INT:.conf.KRAKEN_INTERVAL
CHANNEL:.conf.KRAKEN_CHANNEL

getParams:{[x]
    $[x like "ohlc";params:`channel`symbol`interval!(x;UN;INT);
        x like "trade";params:`channel`symbol`snapshot!(x;UN;.conf.snapshot);
        params:`channel`symbol!(x;UN)];
    `method`params!("subscribe";params)
    }
payload:getParams each $[0=type CHANNEL;CHANNEL;enlist CHANNEL]

TD:`ohlc`ticker!`KrakenBars`KrakenTicker

msg.status:{[x]
    .qi.info"qi.kraken: Status received. System is ",first x[`data]`system;
    neg[.z.w] each .j.j each payload
    }

msg.data:{[ch;data] .feed.upd[TD ch;norm[ch]data]}

.z.ws:{
    pkg:.j.k x;
    if[not`channel in key pkg;:];
    ch:`$pkg`channel;
    $[ch=`status;msg.status pkg;if[any CHANNEL like pkg`channel;msg.data[ch;pkg`data]]]
    }

start::{.feed.start[header;url]}

\d .
