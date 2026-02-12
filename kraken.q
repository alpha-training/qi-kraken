\e 1

/ Import libraries
.qi.import`ipc
.qi.import`log
.qi.frompkg[`kraken;`norm]

/ export SSL_CA_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt

\d .kraken

/ Connection Logic
url:.conf.KRAKEN_URL;
header:"GET ",.conf.KRAKEN_ENDPOINT," HTTP/1.1\r\nHost: ws.kraken.com\r\nConnection: Upgrade\r\nUpgrade: websocket\r\n\r\n"
UN:.conf.KRAKEN_UNIVERSE
INT:.conf.KRAKEN_INTERVAL
CHANNEL:.conf.KRAKEN_CHANNEL

getParams:{
    $[CHANNEL like "ohlc";:`channel`symbol`interval!(CHANNEL;UN;INT);
        CHANNEL like "ticker";:`channel`symbol`snapshot!(CHANNEL;UN;.conf.snapshot);
        :`channel`symbol!(CHANNEL;UN)]
    }
payload:`method`params!("subscribe";getParams[])

H:0Ni;

/ Kraken Data Handler

.z.ws:{[msg]
    pkg:.j.k msg;
    {if[`channel in key x;
        if[x[`channel] like "status";
            -1 "qi.kraken: Status received. System is ", first x[`data]`system;
            :neg[.z.w] .j.j payload];
        if[x[`channel] like CHANNEL;
            :neg[H](`.u.upd;.kraken.norm.name `$CHANNEL;.kraken.norm[`$CHANNEL] x[`data])]
        ];
        }each enlist pkg
    }

pc:{[h] if[h=H;.log.fatal"Lost connection to target. Exiting"]}

start:{[target]
    if[null H::.ipc.conn .qi.tosym target;
        if[null H::first c:.ipc.tryconnect target;
            .log.fatal"Could not connect to ",.qi.tostr[target]," '",last[c],"'. Exiting"]];
    .log.info "Connection sequence initiated...";
    if[not h:first c:.qi.try[url;header;0Ni];
        .log.error err:c 2;
        if[err like"*Protocol*";
            if[.z.o in`l64`m64;
                .log.info"Try setting the env variable:\nexport SSL_VERIFY_SERVER=NO"]]];
    if[h;.log.info"Connection success"];
    }

.event.addhandler[`.z.pc;`.kraken.pc]