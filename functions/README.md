# CoinTrue - Cloud Functions

Cloud Functions para monitoramento de preços de criptomoedas e envio de notificações push.

## Funcionalidades

### 1. `monitorCryptoPrices` (Scheduled)
- **Frequência**: A cada 15 minutos
- **Função**: Monitora preços de criptomoedas e envia notificações quando variação atinge threshold
- **API**: CoinGecko (preços em BRL)
- **Timezone**: America/Sao_Paulo

### 2. `testPriceNotification` (Callable)
- **Função**: Envia notificação de teste para o usuário autenticado
- **Uso**: Para testar se FCM está funcionando

### 3. `updateWatchedCryptos` (Callable)
- **Função**: Atualiza lista de criptomoedas que o usuário quer monitorar
- **Uso**: Permite usuário escolher quais criptos receber notificações

## Setup

### 1. Instalar dependências

```bash
cd functions
npm install
```

### 2. Configurar Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### 3. Selecionar projeto

```bash
firebase use cointrue-5d529
```

## Desenvolvimento

### Compilar TypeScript

```bash
npm run build
```

### Testar localmente com emuladores

```bash
npm run serve
```

### Ver logs

```bash
npm run logs
```

## Deploy

### Deploy de todas as functions

```bash
npm run deploy
```

### Deploy de uma function específica

```bash
firebase deploy --only functions:monitorCryptoPrices
```

## Estrutura de Dados

### Firestore: `notification_preferences/{userId}`

```json
{
  "priceVariationEnabled": true,
  "priceThreshold": 5.0,
  "fcmToken": "fcm_token_here",
  "watchedCryptos": ["bitcoin", "ethereum", "cardano", "solana"],
  "fcmTokenUpdatedAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Firestore: `notification_history/{notificationId}`

```json
{
  "userId": "user_id",
  "type": "price_variation",
  "cryptoSymbol": "BTC",
  "variation": 8.5,
  "currentPrice": 350000.0,
  "sentAt": "timestamp"
}
```

## Custos

### Plano Gratuito (Spark)
- ❌ Cloud Functions não disponíveis

### Plano Blaze (Pay as you go)
- ✅ 2 milhões de invocações/mês GRÁTIS
- ✅ 400.000 GB-segundos/mês GRÁTIS
- ✅ 200.000 GHz-segundos/mês GRÁTIS

**Estimativa para uso pessoal:**
- Monitoramento a cada 15min = 2.880 invocações/mês
- **Custo: R$ 0,00** (dentro do free tier)

## Monitoramento

### Ver logs em tempo real

```bash
firebase functions:log --only monitorCryptoPrices
```

### Ver histórico de notificações no Firestore

Acesse: Firebase Console > Firestore > `notification_history`

## Troubleshooting

### Notificações não chegam

1. Verificar se FCM token está salvo no Firestore
2. Verificar logs da function: `npm run logs`
3. Testar com `testPriceNotification`
4. Verificar se app tem permissão de notificações

### Function não executa

1. Verificar se está no plano Blaze
2. Verificar logs de erro
3. Testar localmente com emuladores

### API CoinGecko com erro

- CoinGecko tem rate limit de 10-50 req/min (free tier)
- Se necessário, criar conta para aumentar limite
- Considerar cache de preços no Firestore

## Próximas Melhorias

- [ ] Cache de preços no Firestore (reduzir chamadas API)
- [ ] Notificações de resumo do portfólio com dados reais
- [ ] Suporte a mais exchanges/APIs de preços
- [ ] Notificações de preço alvo (target price)
- [ ] Analytics de notificações enviadas
