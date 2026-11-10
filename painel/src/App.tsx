import { useEffect, useState } from 'react';
import { onAuthStateChanged, signOut, type User } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, configOk, db } from './firebase';
import Login from './components/Login';
import Painel from './components/Painel';
import QrPage from './components/QrPage';

type Status = 'carregando' | 'deslogado' | 'sem-permissao' | 'admin';

function useHash() {
  const [hash, setHash] = useState(window.location.hash);
  useEffect(() => {
    const onChange = () => setHash(window.location.hash);
    window.addEventListener('hashchange', onChange);
    return () => window.removeEventListener('hashchange', onChange);
  }, []);
  return hash;
}

export default function App() {
  const hash = useHash();
  const [user, setUser] = useState<User | null>(null);
  const [status, setStatus] = useState<Status>('carregando');

  useEffect(() => {
    return onAuthStateChanged(auth, async (u) => {
      setUser(u);
      if (!u) return setStatus('deslogado');
      if (u.isAnonymous) return setStatus('sem-permissao');
      try {
        const snap = await getDoc(doc(db, 'admins', u.uid));
        setStatus(snap.exists() ? 'admin' : 'sem-permissao');
      } catch {
        setStatus('sem-permissao');
      }
    });
  }, []);

  // Tela do QR (abre em outra aba / imprime). Não depende de login.
  if (hash.startsWith('#/qr/')) {
    const [id, query] = hash.slice('#/qr/'.length).split('?');
    const nome = new URLSearchParams(query ?? '').get('nome') ?? '';
    return <QrPage estandeId={decodeURIComponent(id)} nome={nome} />;
  }

  if (!configOk) {
    return (
      <main className="centro">
        <div className="card">
          <h1>Configuração ausente</h1>
          <p>
            Crie o arquivo <code>painel/.env</code> a partir de <code>.env.example</code> com a
            configuração do app Web do Firebase e reinicie o <code>npm run dev</code>.
          </p>
        </div>
      </main>
    );
  }

  if (status === 'carregando') return <main className="centro">Carregando…</main>;
  if (status === 'deslogado') return <Login />;

  if (status === 'sem-permissao') {
    return (
      <main className="centro">
        <div className="card">
          <h1>Sem permissão de administrador</h1>
          <p>
            Você entrou como <b>{user?.email}</b>, mas esta conta não está em <code>admins</code>.
          </p>
          <p>
            No console do Firestore, crie a coleção <code>admins</code> com um documento cujo ID é:
          </p>
          <pre className="uid">{user?.uid}</pre>
          <p className="muted">O documento pode ter um campo qualquer, ex.: nome = "Organização".</p>
          <div className="linha">
            <button onClick={() => window.location.reload()}>Já criei, recarregar</button>
            <button className="secundario" onClick={() => signOut(auth)}>Sair</button>
          </div>
        </div>
      </main>
    );
  }

  return <Painel user={user!} />;
}
