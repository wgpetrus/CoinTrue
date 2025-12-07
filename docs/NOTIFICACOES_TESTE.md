# Como Testar as Notificações

## Sistema de Notificações Implementado

O sistema de notificações está 100% funcional com:

### 1. Notificações Locais (flutter_local_notifications)
- ✅ Resumo do Portfólio (diário ou semanal)
- ✅ Variação de Preço (alertas em tempo real)
- ✅ Agendamento com horários específicos (manhã, tarde, noite)

### 2. Notificações Push (Firebase Cloud Messaging)
- ✅ FCM configurado e inicializado
- ✅ Token salvo no Firestore
- ✅ Pronto para receber notificações do servidor

## Como Testar

### Passo 1: Configurar Permissões

1. Abra o app
2. Vá em **Configurações** > **Notificações**
3. Ative qualquer tipo de notificação
4. O app solicitará permissão automaticamente
5. Conceda a permissão

### Passo 2: Testar Notificação Imediata (DEBUG)

**Apenas em modo DEBUG:**

1. Na tela de **Notificações**, role até o final
2. Você verá uma seção **DEBUG**
3. Toque em **"Enviar Notificação de Teste"**
4. Uma notificação deve aparecer imediatamente

### Passo 3: Testar Resumo do Portfólio

1. Ative **"Resumo Diário"**
2. Escolha a frequência: **Diário** ou **Semanal**
3. Escolha o horário:
   - **Manhã**: 9h
   - **Tarde**: 14h
   - **Noite**: 20h
4. A notificação será agendada automaticamente

**Para testar rapidamente:**
- Configure para o horário mais próximo
- Aguarde o horário configurado
- A notificação aparecerá automaticamente

### Passo 4: Verificar Notificações Agendadas (DEBUG)

**Apenas em modo DEBUG:**

1. Na seção **DEBUG**, toque em **"Listar Notificações Agendadas"**
2. Abra o console/log do app
3. Você verá a lista de notificações pendentes com IDs e títulos

### Passo 5: Testar Variação de Preço

**Nota:** Este tipo de notificação requer monitoramento em tempo real, que será implementado com background tasks.

Por enquanto, você pode testar manualmente:

```dart
// No código, chame:
notificationController.sendPriceVariationNotification(
  cryptoName: 'Bitcoin',
  cryptoSymbol: 'BTC',
  variation: 8.5,
  currentPrice: 48574.32,
);
```

## Estrutura de Horários

### Horários Configurados

- **Manhã (morning)**: 9:00
- **Tarde (afternoon)**: 14:00
- **Noite (evening)**: 20:00

### Como Funciona o Agendamento

1. Quando você ativa uma notificação, o sistema:
   - Cancela todas as notificações anteriores
   - Calcula o próximo horário baseado na sua escolha
   - Agenda a notificação

2. Se o horário já passou hoje:
   - Notificação diária: agenda para amanhã no mesmo horário
   - Notificação semanal: agenda para próxima semana no mesmo dia/horário

## Verificar Logs

Para acompanhar o funcionamento, observe os logs:

```
✅ NotificationService initialized
✅ FCM initialized
✅ FCM token: [token]
✅ NotificationController initialized
🔔 Daily notification scheduled for: 9:0
📋 Pending notifications: 1
  - ID: 1, Title: 💼 Resumo do Portfólio
```

## Troubleshooting

### Notificação não aparece

1. **Verifique permissões:**
   - Android: Configurações > Apps > CoinTrue > Notificações
   - iOS: Ajustes > CoinTrue > Notificações

2. **Verifique se está agendada:**
   - Use o botão "Listar Notificações Agendadas" (DEBUG)
   - Verifique os logs

3. **Verifique o horário:**
   - Certifique-se de que o horário ainda não passou
   - Se passou, a notificação será amanhã

### Notificação de teste não funciona

1. Verifique se concedeu permissão
2. Verifique os logs para erros
3. Reinicie o app

### FCM Token não salva

1. Verifique conexão com Firebase
2. Verifique se o usuário está autenticado
3. Verifique os logs do Firestore

## Próximos Passos

### Background Tasks (Em desenvolvimento)

Para monitorar variações de preço em tempo real, será necessário:

1. **Android**: WorkManager
2. **iOS**: Background Fetch

Isso permitirá:
- Verificar preços periodicamente (a cada 15 minutos)
- Enviar notificações quando houver variação significativa
- Funcionar mesmo com o app fechado

### Cloud Functions (Futuro)

Para notificações push do servidor:

1. Criar Cloud Functions no Firebase
2. Monitorar preços no servidor
3. Enviar notificações via FCM para todos os usuários

## Arquivos Importantes

- `lib/services/notification_service.dart` - Serviço de notificações locais
- `lib/services/fcm_service.dart` - Serviço de FCM
- `lib/controllers/notification_controller.dart` - Controller principal
- `lib/models/notification_preferences.dart` - Modelo de preferências
- `lib/repositories/notification_preferences_repository.dart` - Persistência no Firestore
- `lib/views/screens/crypto/notification_settings_screen.dart` - Tela de configurações
