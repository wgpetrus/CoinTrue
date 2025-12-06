import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import fetch from 'node-fetch';

// Inicializa Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// Interface para preferências de notificação
interface NotificationPreferences {
    priceVariationEnabled: boolean;
    priceThreshold: number;
    fcmToken?: string;
    watchedCryptos?: string[]; // Lista de símbolos que o usuário quer monitorar
}

// Interface para dados de preço da CoinGecko
interface CryptoPrice {
    id: string;
    symbol: string;
    name: string;
    current_price: number;
    price_change_percentage_24h: number;
}

/**
 * Cloud Function agendada para monitorar preços de criptomoedas
 * Roda a cada 15 minutos
 */
export const monitorCryptoPrices = functions.pubsub
    .schedule('every 15 minutes')
    .timeZone('America/Sao_Paulo')
    .onRun(async (_context) => {
        console.log('🔍 Starting crypto price monitoring...');

        try {
            // 1. Busca todos os usuários com notificações de variação ativadas
            const preferencesSnapshot = await db
                .collection('notification_preferences')
                .where('priceVariationEnabled', '==', true)
                .get();

            if (preferencesSnapshot.empty) {
                console.log('ℹ️ No users with price notifications enabled');
                return null;
            }

            console.log(`👥 Found ${preferencesSnapshot.size} users to notify`);

            // 2. Coleta todas as criptos que precisam ser monitoradas
            const cryptosToMonitor = new Set<string>();
            const userPreferences = new Map<string, NotificationPreferences>();

            preferencesSnapshot.forEach((doc: admin.firestore.QueryDocumentSnapshot) => {
                const prefs = doc.data() as NotificationPreferences;
                userPreferences.set(doc.id, prefs);

                // Se usuário tem lista de criptos, adiciona
                if (prefs.watchedCryptos && prefs.watchedCryptos.length > 0) {
                    prefs.watchedCryptos.forEach((crypto) => cryptosToMonitor.add(crypto));
                } else {
                    // Senão, monitora as principais
                    ['bitcoin', 'ethereum', 'cardano', 'solana'].forEach((crypto) =>
                        cryptosToMonitor.add(crypto)
                    );
                }
            });

            console.log(`💰 Monitoring ${cryptosToMonitor.size} cryptocurrencies`);

            // 3. Busca preços atuais da CoinGecko
            const cryptoIds = Array.from(cryptosToMonitor).join(',');
            const apiUrl = `https://api.coingecko.com/api/v3/coins/markets?vs_currency=brl&ids=${cryptoIds}&order=market_cap_desc&sparkline=false&price_change_percentage=24h`;

            const response = await fetch(apiUrl);
            if (!response.ok) {
                throw new Error(`CoinGecko API error: ${response.statusText}`);
            }

            const prices: CryptoPrice[] = await response.json();
            console.log(`📊 Fetched prices for ${prices.length} cryptos`);

            // 4. Para cada usuário, verifica se deve enviar notificação
            const notifications: Promise<void>[] = [];

            for (const [userId, prefs] of userPreferences.entries()) {
                if (!prefs.fcmToken) {
                    console.log(`⚠️ User ${userId} has no FCM token`);
                    continue;
                }

                // Filtra criptos que o usuário monitora
                const userCryptos = prefs.watchedCryptos || [
                    'bitcoin',
                    'ethereum',
                    'cardano',
                    'solana',
                ];

                for (const crypto of prices) {
                    if (!userCryptos.includes(crypto.id)) continue;

                    const variation = crypto.price_change_percentage_24h;
                    if (Math.abs(variation) >= prefs.priceThreshold) {
                        // Envia notificação
                        notifications.push(
                            sendPriceNotification(
                                prefs.fcmToken,
                                crypto.name,
                                crypto.symbol.toUpperCase(),
                                variation,
                                crypto.current_price,
                                userId
                            )
                        );
                    }
                }
            }

            // 5. Envia todas as notificações
            await Promise.allSettled(notifications);
            console.log(`✅ Sent ${notifications.length} notifications`);

            return null;
        } catch (error) {
            console.error('❌ Error monitoring crypto prices:', error);
            return null;
        }
    });

/**
 * Envia notificação de variação de preço
 */
async function sendPriceNotification(
    fcmToken: string,
    cryptoName: string,
    cryptoSymbol: string,
    variation: number,
    currentPrice: number,
    userId: string
): Promise<void> {
    const emoji = variation > 0 ? '🚀' : '📉';
    const sign = variation > 0 ? '+' : '';

    const message: admin.messaging.Message = {
        token: fcmToken,
        notification: {
            title: `${emoji} ${cryptoName} (${cryptoSymbol})`,
            body: `Variação de ${sign}${variation.toFixed(2)}% - Preço atual: R$ ${currentPrice.toFixed(2)}`,
        },
        data: {
            type: 'price_variation',
            cryptoSymbol: cryptoSymbol,
            variation: variation.toString(),
            currentPrice: currentPrice.toString(),
        },
        android: {
            priority: 'high',
            notification: {
                channelId: 'cointrue_fcm',
                priority: 'high',
                sound: 'default',
            },
        },
        apns: {
            payload: {
                aps: {
                    sound: 'default',
                    badge: 1,
                },
            },
        },
    };

    try {
        await messaging.send(message);
        console.log(`✅ Notification sent to user ${userId} for ${cryptoSymbol}`);

        // Salva histórico de notificação
        await db.collection('notification_history').add({
            userId,
            type: 'price_variation',
            cryptoSymbol,
            variation,
            currentPrice,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    } catch (error) {
        console.error(`❌ Error sending notification to ${userId}:`, error);
        throw error;
    }
}

/**
 * Cloud Function HTTP para testar notificações manualmente
 */
export const testPriceNotification = functions.https.onCall(
    async (_data, context) => {
        // Verifica autenticação
        if (!context.auth) {
            throw new functions.https.HttpsError(
                'unauthenticated',
                'User must be authenticated'
            );
        }

        const userId = context.auth.uid;

        try {
            // Busca FCM token do usuário
            const prefsDoc = await db
                .collection('notification_preferences')
                .doc(userId)
                .get();

            if (!prefsDoc.exists) {
                throw new functions.https.HttpsError(
                    'not-found',
                    'User preferences not found'
                );
            }

            const prefs = prefsDoc.data() as NotificationPreferences;
            if (!prefs.fcmToken) {
                throw new functions.https.HttpsError(
                    'failed-precondition',
                    'FCM token not found'
                );
            }

            // Envia notificação de teste
            await sendPriceNotification(
                prefs.fcmToken,
                'Bitcoin',
                'BTC',
                8.5,
                350000.0,
                userId
            );

            return { success: true, message: 'Test notification sent' };
        } catch (error) {
            console.error('Error sending test notification:', error);
            throw new functions.https.HttpsError('internal', 'Failed to send notification');
        }
    }
);

/**
 * Cloud Function para atualizar lista de criptos monitoradas
 */
export const updateWatchedCryptos = functions.https.onCall(
    async (data, context) => {
        if (!context.auth) {
            throw new functions.https.HttpsError(
                'unauthenticated',
                'User must be authenticated'
            );
        }

        const userId = context.auth.uid;
        const { cryptoIds } = data;

        if (!Array.isArray(cryptoIds)) {
            throw new functions.https.HttpsError(
                'invalid-argument',
                'cryptoIds must be an array'
            );
        }

        try {
            await db
                .collection('notification_preferences')
                .doc(userId)
                .set(
                    {
                        watchedCryptos: cryptoIds,
                        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                    },
                    { merge: true }
                );

            return { success: true, message: 'Watched cryptos updated' };
        } catch (error) {
            console.error('Error updating watched cryptos:', error);
            throw new functions.https.HttpsError('internal', 'Failed to update');
        }
    }
);
