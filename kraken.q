\e 1

/ Import libraries
.qi.import`ipc
.qi.import`log
.qi.frompkg[`kraken;`norm]

`KrakenBars set `.kraken.KrakenBars
`KrakenTicker set `.kraken.KrakenTicker

/ export SSL_CA_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt

\d .kraken

.qi.loadschemas`kraken

/ Connection Logic
url:.conf.KRAKEN_URL;
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

H:0Ni;

/ Kraken Data Handler

sendtotp:{[t;dt] neg[H](`.u.upd;t;dt)}

insertlocal:{[t;dt]
    if[`KrakenBars~t;(t:`.kraken.KrakenBars) insert dt];
    if[`KrakenTicker~t;(t:`.kraken.KrakenTicker) insert dt];
    if[not`g=attr get[t]`sym;update `g#sym from t]
    }

.z.ws:{[msg]
    pkg:.j.k msg;
    {if[`channel in key x;
        if[x[`channel] like "status";
            -1 "qi.kraken: Status received. System is ", first x[`data]`system;
            :neg[.z.w] each .j.j each payload];
        if[any CHANNEL like x[`channel];
            t:.kraken.norm.name `$x[`channel];
            dt:.kraken.norm[`$x[`channel]] x[`data];
            $[.qi.isproc;sendtotp[t;dt];insertlocal[t;dt]]
            ];
        ];
        }each enlist pkg
    }

pc:{[h] if[h=H;.log.fatal"Lost connection to target. Exiting"]}

start:{[target]
    if[.qi.isproc;
        if[null H::.ipc.conn .qi.tosym target;
            if[null H::first c:.ipc.tryconnect target;
                .log.fatal"Could not connect to ",.qi.tostr[target]," '",last[c],"'. Exiting"]];]
    .log.info "Connection sequence initiated...";
    if[not h:first c:.qi.try[url;header;0Ni];
        .log.error err:c 2;
        if[err like"*Protocol*";
            if[.z.o in`l64`m64;
                .log.info"Try setting the env variable:\nexport SSL_VERIFY_SERVER=NO"]]];
    if[h;.log.info"Connection success"];
    }

.event.addhandler[`.z.pc;`.kraken.pc]

/

if[not .qi.isproc;t insert x;if[not`g=attr get[t]`sym;update `g#sym from t]]