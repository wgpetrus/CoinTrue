# Comandos para Deploy do Firebase Storage

## ✅ Configuração Concluída

O arquivo `firebase.json` foi atualizado para incluir o Storage.

---

## 🚀 Deploy das Regras

Execute este comando no PowerShell:

```powershell
firebase deploy --only storage
```

**Resultado esperado:**
```
✔ Deploy complete!

Project Console: https://console.firebase.google.com/project/cointrue-5d529/overview
```

---

## 🔍 Verificar Deploy

Após o deploy, verifique no Firebase Console:

1. Acesse: https://console.firebase.google.com/project/cointrue-5d529/storage
2. Clique na aba **"Rules"**
3. Você deve ver as regras aplicadas

---

## ⚠️ Se der erro

### Erro: "Storage not initialized"

**Solução:** Ative o Storage primeiro no console:

1. Acesse: https://console.firebase.google.com/project/cointrue-5d529/storage
2. Clique em **"Get Started"**
3. Escolha **"Start in production mode"**
4. Escolha localização: **southamerica-east1** (São Paulo)
5. Clique em **"Done"**
6. Tente o deploy novamente

---

### Erro: "Permission denied"

**Solução:** Faça login novamente:

```powershell
firebase logout
firebase login
firebase deploy --only storage
```

---

## 📝 Alternativa: Configurar Manualmente

Se o deploy não funcionar, configure manualmente:

1. Acesse: https://console.firebase.google.com/project/cointrue-5d529/storage/rules
2. Cole as regras do arquivo `storage.rules`
3. Clique em **"Publish"**

---

## ✅ Testar Após Deploy

1. Abra o app CoinTrue
2. Vá em **Perfil** → Toque no avatar
3. Escolha **"Galeria"**
4. Selecione uma imagem
5. Aguarde o upload

**Resultado esperado:**
- ✅ "Foto de perfil atualizada!"
- ✅ Avatar atualizado

---

## 🎯 Status

- [x] firebase.json configurado
- [x] storage.rules criado
- [ ] Deploy realizado
- [ ] Upload testado

Execute o comando acima para completar! 🚀
