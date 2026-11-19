// {"Farm":"Farm1","Air":57,"Wind":12,"Sun":88}

const d = msg.payload;
msg.payload = "Thalang,Farm=" + d.Farm +
    " Air=" + Math.round(d.Air) + "i" +
    ",Wind=" + Math.round(d.Wind) + "i" +
    ",Sun=" + Math.round(d.Sun) + "i";
msg.headers = { "Content-Type": "text/plain" };
return msg;
