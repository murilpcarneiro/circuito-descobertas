import { useState, type FormEvent } from 'react';
import type { Estande, EstandeInput } from '../types';

interface Props {
  estande: Estande | null;
  idSugerido: string;
  idsExistentes: string[];
  onCancelar: () => void;
  onSalvar: (id: string, dados: EstandeInput, novo: boolean) => Promise<void>;
}

export default function EstandeForm({ estande, idSugerido, idsExistentes, onCancelar, onSalvar }: Props) {
  const novo = estande === null;
  const [id, setId] = useState(estande?.id ?? idSugerido);
  const [nome, setNome] = useState(estande?.nome ?? '');
  const [descricao, setDescricao] = useState(estande?.descricao ?? '');
  const [localizacao, setLocalizacao] = useState(estande?.localizacao ?? '');
  const [ativo, setAtivo] = useState(estande?.ativo ?? true);
  const [erro, setErro] = useState('');
  const [salvando, setSalvando] = useState(false);

  async function enviar(e: FormEvent) {
    e.preventDefault();
    const idLimpo = id.trim().toUpperCase();
    if (novo && !/^[A-Z0-9_-]{2,20}$/.test(idLimpo)) {
      return setErro('Use de 2 a 20 caracteres: letras, números, "-" ou "_".');
    }
    if (novo && idsExistentes.includes(idLimpo)) return setErro('Já existe um estande com esse ID.');
    setSalvando(true);
    try {
      await onSalvar(idLimpo, { nome: nome.trim(), descricao: descricao.trim(), localizacao: localizacao.trim(), ativo }, novo);
    } catch (err) {
      setErro(`Erro ao salvar: ${(err as Error).message}`);
      setSalvando(false);
    }
  }

  return (
    <div className="modal-fundo" onClick={onCancelar}>
      <form className="card modal" onSubmit={enviar} onClick={(e) => e.stopPropagation()}>
        <h2>{novo ? 'Novo estande' : `Editar ${estande?.id}`}</h2>
        <label>
          ID (vai no QR code e no evento estande_id)
          <input value={id} onChange={(e) => setId(e.target.value)} disabled={!novo} required />
        </label>
        <label>
          Nome
          <input value={nome} onChange={(e) => setNome(e.target.value)} required maxLength={60} />
        </label>
        <label>
          Descrição breve
          <textarea value={descricao} onChange={(e) => setDescricao(e.target.value)} required maxLength={160} rows={3} />
        </label>
        <label>
          Localização
          <input value={localizacao} onChange={(e) => setLocalizacao(e.target.value)} required placeholder="Corredor B · Estande 4" />
        </label>
        <label className="check">
          <input type="checkbox" checked={ativo} onChange={(e) => setAtivo(e.target.checked)} />
          Estande ativo
        </label>
        {erro && <p className="erro">{erro}</p>}
        <div className="linha fim">
          <button type="button" className="secundario" onClick={onCancelar}>Cancelar</button>
          <button type="submit" disabled={salvando}>{salvando ? 'Salvando…' : 'Salvar'}</button>
        </div>
      </form>
    </div>
  );
}
