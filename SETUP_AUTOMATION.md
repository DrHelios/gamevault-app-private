# Setup Automation - Configuration Complète

## 🎯 Résumé

Votre fork privé est maintenant configuré pour :
1. ✅ **Sync automatique** avec upstream toutes les 6 heures
2. ✅ **Re-apply paywall removal** automatiquement après chaque sync
3. ✅ **Build automatique** après chaque sync
4. ✅ **Releases privées** créées automatiquement sur GitHub

---

## 📋 Configuration Requise (À FAIRE MAINTENANT)

### Étape 1 : Ajouter le Token GitHub comme Secret

Le workflow de sync nécessite un Personal Access Token (PAT) avec plus de permissions que le `GITHUB_TOKEN` standard.

**Actions à faire sur GitHub :**

1. **Allez sur votre repo privé** :
   https://github.com/DrHelios/gamevault-app-private

2. **Settings → Secrets and variables → Actions**

3. **Cliquez sur "New repository secret"**

4. **Créez le secret** :
   - **Name:** `GH_PAT`
   - **Value:** `[Votre token GitHub - voir /home/helios/.github_token]`

5. **Cliquez "Add secret"**

---

### Étape 2 : Vérifier les Workflows

Les 2 workflows sont déjà créés :

#### `.github/workflows/sync-upstream.yml`
- **Déclenché :** Toutes les 6 heures (cron: `0 */6 * * *`)
- **Fonction :**
  1. Fetch upstream/master
  2. Merge dans votre fork
  3. Re-apply paywall removal
  4. Push les changements
  5. Déclenche automatiquement le build

#### `.github/workflows/build-windows.yml`
- **Déclenché :** À chaque push sur master
- **Fonction :**
  1. Build GameVault en Release
  2. Package le .exe avec docs
  3. Upload comme Artifact (90 jours)
  4. Crée une Release privée GitHub avec le .zip

---

## 🚀 Test Initial

### Option A : Trigger Manuel (RECOMMANDÉ)

1. Allez sur : https://github.com/DrHelios/gamevault-app-private/actions

2. Cliquez sur **"Sync with Upstream & Auto-Build"**

3. Cliquez sur **"Run workflow"** → **"Run workflow"**

4. Attendez ~5-10 minutes

5. Vérifiez les résultats :
   - ✅ Sync réussi
   - ✅ Build réussi
   - ✅ Release créée

### Option B : Attendre le Cron Automatique

Le premier sync automatique aura lieu dans max 6 heures.

---

## 📦 Où Trouver les Builds

### 1. GitHub Releases (PERMANENT)

**URL :** https://github.com/DrHelios/gamevault-app-private/releases

**Contenu :**
- Releases taggées avec versions (ex: `v2025.01.16-143022`)
- Fichiers .zip téléchargeables
- Notes de release automatiques
- **Conservation :** Permanente (ne s'expire jamais)

**C'est là que vous devriez télécharger vos builds !**

### 2. Actions Artifacts (TEMPORAIRE)

**URL :** https://github.com/DrHelios/gamevault-app-private/actions

**Contenu :**
- Artifacts de chaque workflow run
- `gamevault-windows-no-paywall.zip`
- `gamevault-windows-build-files` (raw files)
- **Conservation :** 90 jours puis suppression automatique

**Utilisez ceci seulement pour des tests.**

---

## ⏰ Calendrier de Synchronisation

### Cron : `0 */6 * * *`

**Signification :** Toutes les 6 heures, à l'heure pile

**Horaires de sync (UTC) :**
- 00:00 (00h00)
- 06:00 (06h00)
- 12:00 (12h00)
- 18:00 (18h00)

**En heure de Paris (UTC+1/+2) :**
- Hiver : 01:00, 07:00, 13:00, 19:00
- Été : 02:00, 08:00, 14:00, 20:00

### Modifier la Fréquence

Éditez `.github/workflows/sync-upstream.yml` :

```yaml
schedule:
  - cron: '0 */12 * * *'  # Toutes les 12 heures
  # OU
  - cron: '0 0 * * *'     # Une fois par jour à minuit
  # OU
  - cron: '0 */3 * * *'   # Toutes les 3 heures
```

---

## 🔧 Personnalisation

### Changer le Nom des Releases

Éditez `.github/workflows/build-windows.yml` ligne 84 :

```powershell
$version = "v$(Get-Date -Format 'yyyy.MM.dd-HHmmss')"

# Personnaliser :
$version = "GameVault-Custom-$(Get-Date -Format 'yyyyMMdd')"
# Ou :
$version = "helios-build-$(Get-Date -Format 'yyyy.MM.dd')"
```

### Ajouter des Notifications

Ajoutez à la fin de `.github/workflows/sync-upstream.yml` :

```yaml
    - name: Send notification
      if: steps.check_updates.outputs.has_updates == 'true'
      run: |
        # Discord webhook
        curl -X POST "${{ secrets.DISCORD_WEBHOOK_URL }}" \
          -H "Content-Type: application/json" \
          -d '{"content":"✅ GameVault updated and built!"}'

        # Ou email, Telegram, Slack, etc.
```

### Désactiver les Releases Automatiques

Si vous voulez seulement les Artifacts (pas les Releases), supprimez cette section de `build-windows.yml` :

```yaml
- name: Create GitHub Release
  # ... toute cette étape
```

---

## 🐛 Troubleshooting

### Le sync échoue avec "Permission denied"

**Cause :** Secret `GH_PAT` manquant ou invalide

**Solution :**
1. Vérifiez que le secret existe : Settings → Secrets and variables
2. Vérifiez que le nom est exactement `GH_PAT`
3. Vérifiez que le token n'a pas expiré

### Le build échoue sur Windows

**Erreur courante :** `Microsoft.NET.Sdk.WindowsDesktop.targets introuvable`

**Solution :** Le runner GitHub Windows a tout ce qu'il faut, mais vérifiez :
- Le workflow utilise bien `runs-on: windows-latest`
- .NET 8 SDK est bien installé (étape "Setup .NET")

### Le paywall re-apparaît après un sync

**Cause :** Le patch n'a pas été appliqué correctement

**Solution :**
1. Vérifiez que `paywall-removal.patch` existe dans le repo
2. Vérifiez les logs du workflow "Re-apply paywall removal"
3. La fallback manuelle devrait fonctionner même si le patch échoue

### Les releases ne se créent pas

**Erreur courante :** `gh: command not found`

**Solution :** GitHub CLI (`gh`) est pré-installé sur les runners GitHub Actions.
Si l'erreur persiste, remplacez par l'API REST :

```powershell
$headers = @{
  "Authorization" = "token $env:GH_TOKEN"
  "Accept" = "application/vnd.github+json"
}

Invoke-RestMethod -Method POST -Uri "https://api.github.com/repos/$env:GITHUB_REPOSITORY/releases" `
  -Headers $headers -Body (ConvertTo-Json @{
    tag_name = $version
    name = "GameVault Private Build $version"
    body = $releaseNotes
  })
```

---

## 📊 Monitoring

### Vérifier l'État des Workflows

**Dashboard :** https://github.com/DrHelios/gamevault-app-private/actions

**Filtres utiles :**
- **Status: Success** → Voir les builds réussis
- **Event: schedule** → Voir les syncs automatiques
- **Event: push** → Voir les builds manuels

### Email de Notification

GitHub envoie automatiquement des emails si un workflow échoue.

**Configurer :** Settings → Notifications → Actions

---

## 🔄 Workflow Complet

```
┌─────────────────────┐
│ Upstream Update     │
│ (Phalcode/gamevault)│
└──────────┬──────────┘
           │
           │ Toutes les 6h (cron)
           ▼
┌─────────────────────┐
│ Sync Workflow       │
│ - Fetch upstream    │
│ - Merge changes     │
│ - Re-apply paywall  │
│ - Push to fork      │
└──────────┬──────────┘
           │
           │ Trigger automatique
           ▼
┌─────────────────────┐
│ Build Workflow      │
│ - Build Release     │
│ - Create Package    │
│ - Upload Artifact   │
│ - Create Release    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ GitHub Release      │
│ gamevault-app-      │
│ private/releases    │
│                     │
│ ✅ Téléchargeable ! │
└─────────────────────┘
```

---

## 🎯 Checklist Finale

Avant de considérer que tout est configuré :

- [ ] Secret `GH_PAT` ajouté dans Settings → Secrets
- [ ] Workflows `.github/workflows/sync-upstream.yml` présent
- [ ] Workflows `.github/workflows/build-windows.yml` présent
- [ ] Premier test manuel du workflow réussi
- [ ] Release automatique créée avec succès
- [ ] Téléchargé et testé le .exe depuis la release

---

## 📝 Maintenance

### Actions Régulières : AUCUNE ! 🎉

Tout est automatique :
- ✅ Sync : Automatique
- ✅ Build : Automatique
- ✅ Release : Automatique

### Actions Occasionnelles

**Si upstream change la structure du code :**
1. Vérifiez les logs du workflow sync
2. Si conflit sur `PhalcodeProduct.cs`, c'est géré automatiquement
3. Si conflit ailleurs, vous recevrez un email d'échec
4. Résolvez manuellement en local, puis push

**Si vous voulez updater la doc :**
1. Modifiez les .md en local
2. Commit + Push
3. Le build se déclenche automatiquement

---

## 🎁 Bonus : Script de Téléchargement

Pour télécharger automatiquement la dernière release :

```bash
#!/bin/bash
# download-latest.sh

GH_TOKEN="$(cat /home/helios/.github_token)"

# Récupérer l'URL de la dernière release
LATEST_URL=$(curl -s -H "Authorization: token $GH_TOKEN" \
  https://api.github.com/repos/DrHelios/gamevault-app-private/releases/latest \
  | grep "browser_download_url.*zip" \
  | cut -d '"' -f 4)

# Télécharger
curl -L -H "Authorization: token $GH_TOKEN" \
  -o GameVault-Latest.zip \
  "$LATEST_URL"

echo "✅ Téléchargé : GameVault-Latest.zip"
```

**Usage :**
```bash
chmod +x download-latest.sh
./download-latest.sh
```

---

## 🎉 C'est Fini !

Votre système est maintenant **100% automatique** :

1. 🔄 **Sync** toutes les 6h avec upstream
2. 🔓 **Paywall removal** automatique
3. 🔨 **Build** automatique
4. 📦 **Release** privée automatique

**Il ne vous reste plus qu'à :**
1. Ajouter le secret `GH_PAT` sur GitHub
2. Trigger un test manuel
3. Profiter ! 🎮

---

**Repo privé :** https://github.com/DrHelios/gamevault-app-private
**Actions :** https://github.com/DrHelios/gamevault-app-private/actions
**Releases :** https://github.com/DrHelios/gamevault-app-private/releases

---

*Configuration automatique générée le 2025-01-16*
