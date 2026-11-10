import { useEffect, useMemo, useRef, useState } from 'react';
import { signOut, type User } from 'firebase/auth';
import { collection, doc, onSnapshot, serverTimestamp, setDoc, updateDoc, writeBatch } from 'firebase/firestore';
import { QRCodeSVG } from 'qrcode.react';
import { auth, db } from '../firebase';
import { qrValue, type Estande, type EstandeInput } from '../types';
import EstandeForm from './EstandeForm';

const EXEMPLOS: EstandeInput[] = [
  { nome: 'RoboRio', descricao: 'Robô que coleta lixo flutuante em igarapés.', localizacao: 'Corredor A · Estande 1', ativo: true },
  { nome: 'Açaí Track', descricao: 'Rastreabilidade do açaí do produtor ao consumidor.', localizacao: 'Corredor B · Estande 4', ativo: true },
  { nome: 'Ver-o-Dado', descricao: 'Painel aberto com dados de mobilidade de Belém.', localizacao: 'Corredor C · Estande 7', ativo: true },
];

function proximoId(estandes: Estande[]) {
  const nums = estandes.map((e) => Number(e.id.replace(/^E/i, ''))).filter((n) => Number.isFinite(n));
  const prox = (nums.length ? Math.max(...nums) : 0) + 1;
  return `E${String(prox).padStart(2, '0')}`;
}

function abrirQr(e: Estande) {
  window.open(`#/qr/${encodeURIComponent(e.id)}?nome=${encodeURIComponent(e.nome)}`, '_blank');
}

export default function Painel({ user }: { user: User }) {
  const [estandes, setEstandes] = useState<Estande[]>([]);
  const [totais, setTotais] = useState<Record<string, number>>({});
  const [totalGeral, setTotalGeral] = useState(0);
  const [destaque, setDestaque] = useState<string | null>(null);
  const [editando, setEditando] = useState<Estande | 'novo' | null>(null);
  const [erro, setErro] = useState('');
  const primeiraCarga = useRef(true);

  useEffect(() => {
    return onSnapshot(
      collection(db, 'estandes'),
      (snap) => {
        const lista = snap.docs.map((d) => ({ id: d.id, ...(d.data() as EstandeInput) }));
        lista.sort((a, b) => a.id.localeCompare(b.id, 'pt-BR', { numeric: true }));
        setEstandes(lista);
      },
      (e) => setErro(`Erro ao ler estandes: ${e.message}`),
    );
  }, []);

  // Totais calculados a partir dos registros de check-in, em tempo real.
  useEffect(() => {
    return onSnapshot(
      collection(db, 'checkins'),
      (snap) => {
        const contagem: Record<string, number> = {};
        snap.docs.forEach((d) => {
          const id = d.get('estandeId') as string;
          contagem[id] = (contagem[id] ?? 0) + 1;
        });
        setTotais(contagem);
        setTotalGeral(snap.size);
        if (!primeiraCarga.current) {
          const novo = snap.docChanges().find((c) => c.type === 'added');
          if (novo) {
            const id = novo.doc.get('estandeId') as string;
            setDestaque(id);
            setTimeout(() => setDestaque((atual) => (atual === id ? null : atual)), 4000);
          }
        }
        primeiraCarga.current = false;
      },
      (e) => setErro(`Erro ao ler check-ins: ${e.message}`),
    );
  }, []);

  const ativos = useMemo(() => estandes.filter((e) => e.ativo).length, [estandes]);

  async function salvar(id: string, dados: EstandeInput, novo: boolean) {
    if (novo) {
      await setDoc(doc(db, 'estandes', id), { ...dados, criadoEm: serverTimestamp() });
    } else {
      await updateDoc(doc(db, 'estandes', id), { ...dados, atualizadoEm: serverTimestamp() });
    }
    setEditando(null);
  }

  async function alternarAtivo(e: Estande) {
    try {
      await updateDoc(doc(db, 'estandes', e.id), { ativo: !e.ativo, atualizadoEm: serverTimestamp() });
    } catch (err) {
      setErro(`Não foi possível alterar: ${(err as Error).message}`);
    }
  }

  async function criarExemplos() {
    const batch = writeBatch(db);
    EXEMPLOS.forEach((ex, i) => {
      batch.set(doc(db, 'estandes', `E${String(i + 1).padStart(2, '0')}`), { ...ex, criadoEm: serverTimestamp() });
    });
    await batch.commit();
  }

  return (
    <div className="layout">
      <header className="topo">
        <div className="marca">🧭 Circuito de Descobertas</div>
        <div className="linha">
          <span className="muted">{user.email}</span>
          <button className="secundario" onClick={() => signOut(auth)}>Sair</button>
        </div>
      </header>

      <main className="conteudo">
        <section className="metricas">
          <div className="metrica"><span>{estandes.length}</span>estandes</div>
          <div className="metrica"><span>{ativos}</span>ativos</div>
          <div className="metrica"><span>{totalGeral}</span>check-ins confirmados</div>
        </section>

        {erro && <p className="erro" onClick={() => setErro('')}>{erro} (clique para fechar)</p>}

        <div className="cabecalho-lista">
          <h2>Estandes</h2>
          <div className="linha">
            {estandes.length === 0 && (
              <button className="secundario" onClick={criarExemplos}>Criar 3 estandes de exemplo</button>
            )}
            <button onClick={() => setEditando('novo')}>+ Novo estande</button>
          </div>
        </div>

        {estandes.length === 0 ? (
          <p className="muted">Nenhum estande cadastrado ainda.</p>
        ) : (
          <div className="grade">
            {estandes.map((e) => (
              <article key={e.id} className={`estande ${e.ativo ? '' : 'inativo'} ${destaque === e.id ? 'pulso' : ''}`}>
                <div className="estande-topo">
                  <span className="tag">{e.id}</span>
                  <span className={`status ${e.ativo ? 'on' : 'off'}`}>{e.ativo ? 'Ativo' : 'Inativo'}</span>
                </div>
                <h3>{e.nome}</h3>
                <p>{e.descricao}</p>
                <p className="muted">📍 {e.localizacao}</p>
                <div className="estande-rodape">
                  <button className="qr-mini" title="Abrir QR em outra aba" onClick={() => abrirQr(e)}>
                    <QRCodeSVG value={qrValue(e.id)} size={72} />
                  </button>
                  <div className="total">
                    <span>{totais[e.id] ?? 0}</span>
                    check-ins
                  </div>
                </div>
                <div className="linha acoes">
                  <button className="secundario" onClick={() => setEditando(e)}>Editar</button>
                  <button className="secundario" onClick={() => alternarAtivo(e)}>{e.ativo ? 'Desativar' : 'Ativar'}</button>
                  <button className="secundario" onClick={() => abrirQr(e)}>QR / imprimir</button>
                </div>
              </article>
            ))}
          </div>
        )}
      </main>

      {editando && (
        <EstandeForm
          estande={editando === 'novo' ? null : editando}
          idSugerido={proximoId(estandes)}
          idsExistentes={estandes.map((e) => e.id)}
          onCancelar={() => setEditando(null)}
          onSalvar={salvar}
        />
      )}
    </div>
  );
}
