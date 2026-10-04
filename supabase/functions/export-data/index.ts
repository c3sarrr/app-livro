import { clienteDoUsuario, verificarJwt } from '../_shared/supabase.ts';
import { criarHandler } from './handler.ts';

Deno.serve(criarHandler({
  verificarJwt,
  async exportar(jwt) {
    const { data, error } = await clienteDoUsuario(jwt).rpc('export_my_data');
    return error ? { erro: error.message } : { dados: data };
  },
}));
