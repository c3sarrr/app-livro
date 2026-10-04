// G02 · S2 — "modo avião" por aparelho: proxy TCP entre o aparelho e o serviço (sync) e entre o
// aparelho e a API (upload). `cortar()` derruba as conexões abertas e recusa as novas.
import net from 'node:net';

export class Proxy {
  constructor(destinoPorta, destinoHost = '127.0.0.1') {
    this.destinoPorta = destinoPorta;
    this.destinoHost = destinoHost;
    this.online = true;
    this.sockets = new Set();
    this.conexoes = 0;
    this.recusadas = 0;
    this.bytesRecebidos = 0; // servidor → aparelho
    this.bytesEnviados = 0; // aparelho → servidor
    this.server = net.createServer((c) => {
      if (!this.online) {
        this.recusadas++;
        c.destroy();
        return;
      }
      this.conexoes++;
      const u = net.connect(this.destinoPorta, this.destinoHost);
      this.sockets.add(c);
      this.sockets.add(u);
      const fim = () => {
        c.destroy();
        u.destroy();
        this.sockets.delete(c);
        this.sockets.delete(u);
      };
      c.on('error', fim).on('close', fim);
      u.on('error', fim).on('close', fim);
      c.on('data', (b) => (this.bytesEnviados += b.length));
      u.on('data', (b) => (this.bytesRecebidos += b.length));
      c.pipe(u);
      u.pipe(c);
    });
  }

  async abrir() {
    await new Promise((r) => this.server.listen(0, '127.0.0.1', r));
    this.porta = this.server.address().port;
    return this;
  }

  cortar() {
    this.online = false;
    for (const s of this.sockets) s.destroy();
    this.sockets.clear();
  }

  religar() {
    this.online = true;
  }

  async fechar() {
    this.cortar();
    await new Promise((r) => this.server.close(r));
  }
}
