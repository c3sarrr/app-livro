// Tipa `exports` de 'cloudflare:workers' com o módulo principal do Worker.
declare namespace Cloudflare {
  interface GlobalProps {
    mainModule: typeof import('../src/index');
  }
}
