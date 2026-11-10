/** Prefixo gravado no QR code. O app só aceita QR que começam com ele. */
export const QR_PREFIX = 'circuito:';

export interface Estande {
  id: string;
  nome: string;
  descricao: string;
  localizacao: string;
  ativo: boolean;
}

export type EstandeInput = Omit<Estande, 'id'>;

export const qrValue = (estandeId: string) => `${QR_PREFIX}${estandeId}`;
