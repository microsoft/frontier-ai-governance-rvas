// S3 — private DNS and Private Endpoint resolution flow.
import { C, text, node, connect, arrow, write } from "./lib.mjs";

const els = [];
els.push(text(40, 24, 1500, "S3 - Private DNS resolution for platform services", C.data, { size: 26, align: "left" }));
els.push(text(40, 60, 1500, "Private connectivity requires DNS, endpoint, route, and owner records. A diagram is not reachability proof.", C.neutral, { size: 14, align: "left" }));

const component = node(els, 90, 125, 360, 88, C.hero, "Component", { titleSize: 16, sub: "Foundry, app host, or agent runtime", subSize: 12 });
const query = node(els, 90, 255, 360, 88, C.neutral, "DNS query", { titleSize: 16, sub: "public Azure service FQDN", subSize: 12 });
const zone = node(els, 90, 385, 360, 88, C.eval, "Private DNS zone", { titleSize: 16, sub: "privatelink zone linked to VNet", subSize: 12 });
const endpoint = node(els, 90, 515, 360, 88, C.amber, "Private IP resolution", { titleSize: 16, sub: "Private Endpoint address", subSize: 12 });

connect(els, component, query, { stroke: C.hero.st });
connect(els, query, zone, { stroke: C.neutral.st });
connect(els, zone, endpoint, { stroke: C.eval.st });

const vnet = node(els, 580, 255, 380, 210, C.data, "Internal VNet traffic", { titleSize: 18, sub: "component -> private endpoint\nTLS to Azure service\npublic endpoint disabled or excepted", subSize: 13 });
const service = node(els, 1110, 315, 260, 90, C.data, "Azure service", { titleSize: 16, sub: "data or platform dependency", subSize: 12 });

els.push(arrow(endpoint.r, endpoint.cy, vnet.x, vnet.cy, { stroke: C.data.st, curved: false }));
connect(els, vnet, service, { stroke: C.data.st });
els.push(text(580, 500, 780, "S3 records the DNS owner, endpoint owner, subnet/NSG route, public-endpoint exception, and monitoring route.", C.neutral, { size: 13, align: "left" }));

write(new URL("./s3-private-dns-resolution-flow.excalidraw", import.meta.url).pathname, els);
