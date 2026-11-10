import { QRCodeSVG } from 'qrcode.react';
import { qrValue } from '../types';

export default function QrPage({ estandeId, nome }: { estandeId: string; nome: string }) {
  return (
    <main className="qr-pagina">
      <div className="qr-folha">
        <div className="marca">🧭 Circuito de Descobertas</div>
        <h1>{nome || 'Estande'}</h1>
        <QRCodeSVG value={qrValue(estandeId)} size={320} level="M" marginSize={2} />
        <p className="qr-id">{estandeId}</p>
        <p className="muted">Leia este código no app para registrar sua visita.</p>
        <button className="nao-imprimir" onClick={() => window.print()}>Imprimir</button>
      </div>
    </main>
  );
}
