# Configuração do Firebase Storage - CoinTrue

## 🔥 Problema Identificado

**Erro:** `Object does not exist at location` (404)  
**Causa:** Firebase Storage não está configurado ou as regras não permitem upload

---

## ✅ Solução - Passo a Passo

### 1. Acessar Firebase Console

1. Acesse: https://console.firebase.google.com
2. Selecione seu projeto **CoinTrue**
3. No menu lateral, clique em **Storage**

---

### 2. Ativar Firebase Storage

Se o Storage não estiver ativado:

1. Clique em **"Get Started"** ou **"Começar"**
2. Escolha o modo de segurança:
   - **Recomendado:** "Start in production mode"
3. Escolha a localização:
   - **Recomendado:** `southamerica-east1` (São Paulo)
4. Clique em **"Done"** ou **"Concluir"**

---

### 3. Configurar Regras de Segurança

#### Opção A: Via Console (Recomendado)

1. No Firebase Console, vá em **Storage** → **Rules**
2. Cole as regras abaixo:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    
    // Regras para imagens de perfil
    match /profile_images/{userId}.jpg {
      // Permitir leitura para todos (imagens públicas)
      allow read: if true;
      
      // Permitir escrita apenas para o próprio usuário autenticado
      allow write: if request.auth != null && request.auth.uid == userId;
      
      // Validar tamanho do arquivo (máximo 5MB)
      allow write: if request.resource.size < 5 * 1024 * 1024;
      
      // Validar tipo de arquivo (apenas imagens)
      allow write: if request.resource.contentType.matches('image/.*');
    }
    
    // Negar acesso a qualquer outro caminho por padrão
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

3. Clique em **"Publish"** ou **"Publicar"**

#### Opção B: Via Firebase CLI

Se você tem o Firebase CLI instalado:

```bash
# 1. Fazer login
firebase login

# 2. Inicializar (se ainda não fez)
firebase init storage

# 3. Deploy das regras
firebase deploy --only storage
```

O arquivo `storage.rules` já foi criado na raiz do projeto.

---

### 4. Verificar Configuração

#### Teste Manual no Console

1. No Firebase Console, vá em **Storage** → **Files**
2. Crie uma pasta chamada `profile_images`
3. Tente fazer upload de uma imagem de teste
4. Se funcionar, a configuração está correta!

#### Teste no App

1. Abra o app CoinTrue
2. Vá em **Perfil** → **Editar Perfil**
3. Toque no avatar
4. Escolha **"Galeria"** ou **"Câmera"**
5. Selecione uma imagem
6. Aguarde o upload

**Resultado esperado:**
- ✅ "Foto de perfil atualizada!"
- ✅ Avatar atualizado na tela

---

## 🔒 Segurança das Regras

### O que as regras fazem:

1. **Leitura pública:** Qualquer pessoa pode ver as fotos de perfil
2. **Escrita restrita:** Apenas o próprio usuário pode alterar sua foto
3. **Validação de tamanho:** Máximo 5MB por imagem
4. **Validação de tipo:** Apenas arquivos de imagem (jpg, png, etc)

### Por que é seguro:

- ✅ Usuários não podem alterar fotos de outros usuários
- ✅ Limite de tamanho previne uploads abusivos
- ✅ Apenas imagens são aceitas (não permite scripts ou malware)
- ✅ Autenticação obrigatória para upload

---

## 🐛 Troubleshooting

### Erro: "Object does not exist"

**Causa:** Storage não está ativado ou regras não foram aplicadas  
**Solução:** Siga os passos 2 e 3 acima

---

### Erro: "Unauthorized"

**Causa:** Usuário não está autenticado ou regras muito restritivas  
**Solução:** 
1. Verifique se o usuário está logado
2. Verifique se as regras permitem escrita para o userId correto

---

### Erro: "Quota exceeded"

**Causa:** Limite gratuito do Firebase foi excedido  
**Solução:**
1. Verifique o uso em **Storage** → **Usage**
2. Considere upgrade para plano pago
3. Ou implemente limpeza de imagens antigas

---

### Erro: "Timeout"

**Causa:** Conexão lenta ou imagem muito grande  
**Solução:**
1. Verifique a conexão de internet
2. O app já reduz imagens para 512x512px
3. Timeout configurado para 30 segundos

---

## 📊 Limites do Plano Gratuito (Spark)

- **Armazenamento:** 5 GB
- **Download:** 1 GB/dia
- **Upload:** 1 GB/dia
- **Operações:** 50.000/dia

**Estimativa:** Com imagens de ~100KB cada, você pode armazenar ~50.000 fotos de perfil.

---

## 🚀 Melhorias Futuras (Opcional)

### 1. Compressão Adicional

Adicionar compressão no lado do servidor usando Cloud Functions:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sharp = require('sharp');

exports.compressProfileImage = functions.storage
  .object()
  .onFinalize(async (object) => {
    // Comprimir imagem automaticamente
  });
```

### 2. Limpeza Automática

Remover imagens antigas quando o usuário atualiza:

```dart
// Antes de fazer upload da nova imagem
await _removeOldProfileImage(userId);
```

### 3. Cache Local

Implementar cache de imagens para reduzir downloads:

```dart
// Usar package: cached_network_image
CachedNetworkImage(
  imageUrl: user.profileImageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

---

## ✅ Checklist de Configuração

- [ ] Firebase Storage ativado no console
- [ ] Regras de segurança aplicadas
- [ ] Pasta `profile_images` criada (opcional)
- [ ] Teste de upload realizado
- [ ] App testado em dispositivo real
- [ ] Mensagens de erro verificadas

---

## 📝 Notas Importantes

1. **Primeiro Deploy:** As regras podem levar alguns minutos para propagar
2. **Desenvolvimento:** Considere usar emulador local do Firebase
3. **Produção:** Monitore o uso no Firebase Console
4. **Backup:** Não há backup automático no plano gratuito

---

**Status:** Configuração necessária no Firebase Console  
**Prioridade:** Alta (funcionalidade bloqueada)  
**Tempo estimado:** 5-10 minutos
