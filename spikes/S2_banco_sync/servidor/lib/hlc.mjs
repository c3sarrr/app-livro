// G02 · S2 — relógio lógico híbrido (Anexo 02 §3.4): "<ms 16 dígitos>-<contador 4>-<device_id>".
export class Hlc {
  constructor(dispositivo, { defasagemMs = 0 } = {}) {
    if (!/^[A-Za-z0-9_-]{1,64}$/.test(dispositivo)) throw new Error(`device_id inválido para HLC: ${dispositivo}`);
    this.dispositivo = dispositivo;
    this.defasagemMs = defasagemMs;
    this.ms = 0;
    this.contador = 0;
  }

  agora() {
    return Date.now() + this.defasagemMs;
  }

  enviar() {
    const t = this.agora();
    if (t > this.ms) {
      this.ms = t;
      this.contador = 0;
    } else {
      this.contador++;
    }
    return `${String(this.ms).padStart(16, '0')}-${String(this.contador).padStart(4, '0')}-${this.dispositivo}`;
  }

  receber(remoto) {
    const ms = Number(remoto.slice(0, 16));
    const c = Number(remoto.slice(17, 21));
    if (ms > this.ms || (ms === this.ms && c > this.contador)) {
      this.ms = ms;
      this.contador = c;
    }
  }
}
